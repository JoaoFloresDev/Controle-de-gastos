#!/usr/bin/env python3
"""
pull_analytics.py — Pull current App Store analytics for My Expenses: Personal Finances.

Pulls in priority order:
  1. App metadata (id, name, state) via /v1/apps
  2. Sales reports (DAILY, SUMMARY) for last 60 days → aggregate downloads by country/date
  3. Active App Store version + state
  4. Kicks off Analytics Reports ONE_TIME_SNAPSHOT for search terms (24-48h latency)

Outputs:
  reports/baseline_<YYYY-MM-DD>.md       human-readable summary
  reports/baseline_<YYYY-MM-DD>_sales.csv  daily downloads per country (raw)

Env vars (defaults match GambitStudio):
  APP_STORE_CONNECT_KEY_ID         (default: 67JG58Q6XH)
  APP_STORE_CONNECT_ISSUER_ID      (default: 98c49316-b223-4d64-955d-b55ae76ab9d2)
  APP_STORE_CONNECT_KEY_PATH       (default: ~/private_keys/AuthKey_67JG58Q6XH.p8)
  APP_STORE_CONNECT_VENDOR_NUMBER  (default: 88531754)
  APP_BUNDLE_ID                    (default: com.gambit.meusgastos)
"""

from __future__ import annotations

import csv
import gzip
import io
import json
import os
import sys
import time
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path

import jwt
import requests

# ─── Config ─────────────────────────────────────────────────────────────────
KEY_ID = os.environ.get("APP_STORE_CONNECT_KEY_ID", "67JG58Q6XH")
ISSUER_ID = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "98c49316-b223-4d64-955d-b55ae76ab9d2")
KEY_PATH = os.path.expanduser(
    os.environ.get("APP_STORE_CONNECT_KEY_PATH", "~/private_keys/AuthKey_67JG58Q6XH.p8")
)
VENDOR_NUMBER = os.environ.get("APP_STORE_CONNECT_VENDOR_NUMBER", "88531754")
BUNDLE_ID = os.environ.get("APP_BUNDLE_ID", "com.gambit.meusgastos")
APP_SKU = os.environ.get("APP_SKU", "MeusGastos")  # filters Sales Reports to this app only

API_BASE = "https://api.appstoreconnect.apple.com"
SALES_DAYS = 60  # how many days of daily sales reports to pull

OUT_DIR = Path(__file__).resolve().parent.parent / "reports"
OUT_DIR.mkdir(parents=True, exist_ok=True)
TODAY = datetime.utcnow().date()


# ─── Auth ───────────────────────────────────────────────────────────────────
def jwt_token() -> str:
    with open(KEY_PATH) as f:
        private_key = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"},
    )


def session() -> requests.Session:
    s = requests.Session()
    s.headers.update({"Authorization": f"Bearer {jwt_token()}"})
    return s


# ─── App lookup ─────────────────────────────────────────────────────────────
def find_app(sess: requests.Session) -> dict:
    r = sess.get(f"{API_BASE}/v1/apps", params={"filter[bundleId]": BUNDLE_ID, "limit": 1})
    r.raise_for_status()
    data = r.json().get("data", [])
    if not data:
        raise SystemExit(f"App with bundleId {BUNDLE_ID} not found")
    return data[0]


def app_versions(sess: requests.Session, app_id: str) -> list[dict]:
    r = sess.get(
        f"{API_BASE}/v1/apps/{app_id}/appStoreVersions",
        params={"limit": 10},
    )
    if r.status_code != 200:
        print(f"  ! appStoreVersions failed: HTTP {r.status_code}: {r.text[:200]}", file=sys.stderr)
        return []
    return r.json().get("data", [])


# ─── Sales Reports ──────────────────────────────────────────────────────────
def pull_daily_sales(sess: requests.Session, days: int) -> list[dict]:
    """Pull daily SALES SUMMARY reports for the last N days. Returns combined rows."""
    rows = []
    failed_dates = []
    for d_offset in range(1, days + 1):
        date = TODAY - timedelta(days=d_offset)
        date_str = date.isoformat()
        params = {
            "filter[frequency]": "DAILY",
            "filter[reportSubType]": "SUMMARY",
            "filter[reportType]": "SALES",
            "filter[vendorNumber]": VENDOR_NUMBER,
            "filter[reportDate]": date_str,
        }
        r = sess.get(
            f"{API_BASE}/v1/salesReports",
            params=params,
            headers={"Accept": "application/a-gzip"},
        )
        if r.status_code == 404:
            failed_dates.append(date_str)
            continue
        if r.status_code != 200:
            print(f"  [{date_str}] HTTP {r.status_code}: {r.text[:200]}", file=sys.stderr)
            failed_dates.append(date_str)
            continue
        try:
            text = gzip.GzipFile(fileobj=io.BytesIO(r.content)).read().decode("utf-8")
        except OSError:
            failed_dates.append(date_str)
            continue
        tab = "\t"
        reader = csv.DictReader(io.StringIO(text), delimiter=tab)
        row_count = 0
        for row in reader:
            row["_report_date"] = date_str
            rows.append(row)
            row_count += 1
        print(f"  [{date_str}] {row_count} rows")
    if failed_dates:
        print(f"  no report for {len(failed_dates)} dates (likely no sales): {failed_dates[:5]}...", file=sys.stderr)
    return rows


# ─── Aggregation ────────────────────────────────────────────────────────────
def aggregate(rows: list[dict], app_sku: str) -> dict:
    """Aggregate sales rows filtered to a single app by SKU.

    Sales Reports come per-vendor (all apps in account), so we must filter:
      - App installs: rows where SKU == app_sku
      - IAPs for this app: rows where Parent Identifier == app_sku
    """
    by_country = defaultdict(int)
    by_date = defaultdict(int)
    by_product_type = defaultdict(int)
    total_downloads = 0
    total_iap_units = 0
    total_proceeds_usd = 0.0
    iap_breakdown = defaultdict(int)
    FX = {"USD": 1.0, "EUR": 1.08, "GBP": 1.27, "BRL": 0.20, "MXN": 0.058, "JPY": 0.0064,
          "KRW": 0.00073, "CHF": 1.10, "CAD": 0.73, "AUD": 0.66, "INR": 0.012, "CNY": 0.137,
          "TRY": 0.029, "ZAR": 0.054, "COP": 0.00025, "CLP": 0.0011, "ARS": 0.00115}

    for r in rows:
        product_type = r.get("Product Type Identifier", "")
        units = int(r.get("Units", "0") or "0")
        country = r.get("Country Code", "??")
        date = r.get("_report_date")
        sku = r.get("SKU", "").strip()
        parent = r.get("Parent Identifier", "").strip()
        proceeds = float(r.get("Developer Proceeds", "0") or "0")
        currency = r.get("Currency of Proceeds", "USD")

        # App download rows: SKU == app_sku (and parent is empty)
        if sku == app_sku and not parent:
            total_downloads += units
            by_country[country] += units
            by_date[date] += units
            by_product_type[product_type] += units
        # IAP rows for this app: Parent Identifier == app_sku
        elif parent == app_sku:
            total_iap_units += units
            iap_breakdown[sku] += units
            total_proceeds_usd += units * proceeds * FX.get(currency, 1.0)

    return {
        "total_downloads": total_downloads,
        "total_iap_units": total_iap_units,
        "total_proceeds_usd": round(total_proceeds_usd, 2),
        "iap_breakdown": dict(iap_breakdown),
        "by_country": dict(sorted(by_country.items(), key=lambda x: -x[1])),
        "by_date": dict(sorted(by_date.items())),
        "by_product_type": dict(by_product_type),
    }


# ─── Analytics Reports ───────────────────────────────────────────────────────
# Two request types matter and are NOT interchangeable:
#   ONGOING            → collects only from creation forward; first data 24-48h; no history.
#   ONE_TIME_SNAPSHOT  → backfills up to ~1 year of history; ready in 24-48h; one-shot.
# The old script only ever created ONGOING and never downloaded the actual data,
# so search-term reports never materialized for the user. This now ensures BOTH
# request types exist (reusing any existing) and downloads + parses the data.

def ensure_analytics_requests(sess: requests.Session, app_id: str) -> dict:
    """Ensure one ONGOING and one ONE_TIME_SNAPSHOT request exist (reuse if present).

    Returns {'ongoing': <req|None>, 'snapshot': <req|None>}.
    """
    r = sess.get(f"{API_BASE}/v1/apps/{app_id}/analyticsReportRequests", params={"limit": 50})
    if r.status_code != 200:
        print(f"  ! analyticsReportRequests list failed: HTTP {r.status_code}", file=sys.stderr)
        return {"ongoing": None, "snapshot": None}
    existing = r.json().get("data", [])

    def first(access):
        # Prefer a request that hasn't been stopped due to inactivity.
        cands = [x for x in existing if x.get("attributes", {}).get("accessType") == access]
        cands.sort(key=lambda x: bool(x.get("attributes", {}).get("stoppedDueToInactivity")))
        return cands[0] if cands else None

    out = {"ongoing": first("ONGOING"), "snapshot": first("ONE_TIME_SNAPSHOT")}

    for access, key in (("ONGOING", "ongoing"), ("ONE_TIME_SNAPSHOT", "snapshot")):
        if out[key]:
            a = out[key]["attributes"]
            print(f"  reuse {access} id={out[key]['id']} stopped={a.get('stoppedDueToInactivity')}")
            continue
        body = {"data": {"type": "analyticsReportRequests",
                         "attributes": {"accessType": access},
                         "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}}
        rr = sess.post(f"{API_BASE}/v1/analyticsReportRequests", json=body)
        if rr.status_code == 201:
            out[key] = rr.json().get("data")
            print(f"  + created {access} id={out[key]['id']} (data ready in 24-48h)")
        else:
            print(f"  ! create {access} failed: HTTP {rr.status_code}: {rr.text[:160]}", file=sys.stderr)
    return out


def find_report(sess: requests.Session, request_id: str, name_contains: str, category: str | None = None) -> dict | None:
    """Find a report under a request whose name contains a substring (case-insensitive)."""
    r = sess.get(f"{API_BASE}/v1/analyticsReportRequests/{request_id}/reports", params={"limit": 200})
    if r.status_code != 200:
        return None
    for rep in r.json().get("data", []):
        a = rep.get("attributes", {})
        if name_contains.lower() in (a.get("name", "") or "").lower():
            if category is None or a.get("category") == category:
                return rep
    return None


def fetch_report_segments(sess: requests.Session, report_id: str, max_instances: int = 24) -> list[str]:
    """Return decoded TSV bodies for the most recent instances of a report."""
    r = sess.get(f"{API_BASE}/v1/analyticsReports/{report_id}/instances", params={"limit": 200})
    if r.status_code != 200:
        return []
    instances = r.json().get("data", [])
    instances.sort(key=lambda d: d.get("attributes", {}).get("processingDate", ""))
    bodies = []
    for inst in instances[-max_instances:]:
        sr = sess.get(f"{API_BASE}/v1/analyticsReportInstances/{inst['id']}/segments")
        if sr.status_code != 200:
            continue
        for seg in sr.json().get("data", []):
            url = seg.get("attributes", {}).get("url")
            if not url:
                continue
            try:
                raw = requests.get(url).content
                try:
                    bodies.append(gzip.GzipFile(fileobj=io.BytesIO(raw)).read().decode("utf-8"))
                except OSError:
                    bodies.append(raw.decode("utf-8", "replace"))
            except Exception as e:  # noqa: BLE001
                print(f"  ! segment download failed: {e}", file=sys.stderr)
    return bodies


def parse_search_terms(bodies: list[str]) -> list[dict]:
    """Aggregate impressions / product page views / downloads per search term."""
    def find_col(cols, *cands):
        low = {c.lower(): c for c in cols}
        for cand in cands:
            if cand in low:
                return low[cand]
        return None

    agg = defaultdict(lambda: {"impressions": 0, "page_views": 0, "downloads": 0})
    for body in bodies:
        reader = csv.DictReader(io.StringIO(body), delimiter="\t")
        cols = reader.fieldnames or []
        c_term = find_col(cols, "search term", "search_term")
        if not c_term:
            continue
        c_imp = find_col(cols, "impressions", "impressions unique device")
        c_pv = find_col(cols, "product page views", "page views")
        c_dl = find_col(cols, "total downloads", "downloads", "first-time downloads")
        for row in reader:
            term = (row.get(c_term) or "").strip()
            if not term or term.lower() in ("", "no search term", "n/a"):
                continue

            def num(col):
                if not col:
                    return 0
                v = (row.get(col) or "0").replace(",", "")
                try:
                    return int(float(v))
                except ValueError:
                    return 0
            a = agg[term]
            a["impressions"] += num(c_imp)
            a["page_views"] += num(c_pv)
            a["downloads"] += num(c_dl)
    out = [{"term": t, **v} for t, v in agg.items()]
    out.sort(key=lambda x: (-x["downloads"], -x["impressions"]))
    return out


def pull_search_terms(sess: requests.Session, reqs: dict) -> tuple[str, list[dict]]:
    """Try snapshot (history) first, then ongoing. Returns (status, rows)."""
    for key in ("snapshot", "ongoing"):
        req = reqs.get(key)
        if not req:
            continue
        rep = find_report(sess, req["id"], "Discovery and Engagement Detailed", "APP_STORE_ENGAGEMENT") \
            or find_report(sess, req["id"], "Discovery and Engagement")
        if not rep:
            continue
        bodies = fetch_report_segments(sess, rep["id"])
        if not bodies:
            continue  # report exists but no instances yet (not generated)
        rows = parse_search_terms(bodies)
        if rows:
            return (f"OK via {key} ({len(rows)} terms from {len(bodies)} segments)", rows)
    # Nothing ready
    snap = reqs.get("snapshot")
    ong = reqs.get("ongoing")
    if snap and not ong:
        return ("SNAPSHOT pending — historical search terms ready in ~24-48h. Rerun then.", [])
    return ("PENDING — no instances generated yet (snapshot/ongoing still processing, 24-48h).", [])


def write_search_terms_csv(rows: list[dict]) -> Path | None:
    if not rows:
        return None
    path = OUT_DIR / f"search_terms_{TODAY.isoformat()}.csv"
    with open(path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["term", "impressions", "page_views", "downloads"])
        w.writeheader()
        w.writerows(rows)
    return path


# ─── Output ─────────────────────────────────────────────────────────────────
def write_outputs(app_info: dict, agg: dict, rows: list[dict], versions: list[dict], analytics_status: str):
    today_str = TODAY.isoformat()
    csv_path = OUT_DIR / f"baseline_{today_str}_sales.csv"
    md_path = OUT_DIR / f"baseline_{today_str}.md"

    # CSV: raw rows filtered to our app (downloads + IAPs)
    app_rows = [r for r in rows
                if r.get("SKU", "") == APP_SKU
                or r.get("Parent Identifier", "") == APP_SKU]
    if app_rows:
        keys = sorted({k for r in app_rows for k in r.keys()})
        with open(csv_path, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=keys)
            w.writeheader()
            for r in app_rows:
                w.writerow(r)
        print(f"\n  → {csv_path}")

    # Markdown: summary
    days_with_data = len(agg["by_date"])
    avg_daily = agg["total_downloads"] / max(days_with_data, 1)
    lines = [
        f"# Baseline Analytics — My Expenses: Personal Finances",
        f"",
        f"**Pulled at**: {datetime.utcnow().isoformat()}Z",
        f"**Bundle ID**: `{BUNDLE_ID}`",
        f"**App ID**: `{app_info.get('id')}`",
        f"**App Name (ASC)**: {app_info.get('attributes', {}).get('name')}",
        f"**Primary Locale**: {app_info.get('attributes', {}).get('primaryLocale')}",
        f"**SKU**: `{APP_SKU}` (filtered from vendor-wide sales reports)",
        f"",
        f"## Window",
        f"",
        f"- **Range**: last {SALES_DAYS} days ({(TODAY - timedelta(days=SALES_DAYS)).isoformat()} → {(TODAY - timedelta(days=1)).isoformat()})",
        f"- **Days with data**: {days_with_data}/{SALES_DAYS}",
        f"- **Days without data**: {SALES_DAYS - days_with_data} (no sales OR Apple lag)",
        f"",
        f"## Headline KPIs",
        f"",
        f"- **Total downloads (window)**: {agg['total_downloads']}",
        f"- **Avg downloads/day**: {avg_daily:.2f}",
        f"- **Total IAP units (window)**: {agg['total_iap_units']}  {agg['iap_breakdown'] or ''}",
        f"- **Estimated proceeds (USD)**: ${agg['total_proceeds_usd']}",
        f"",
        f"## Downloads by country (top 15)",
        f"",
        f"| Country | Downloads | % of total |",
        f"|---------|-----------|------------|",
    ]
    total = max(agg["total_downloads"], 1)
    for country, n in list(agg["by_country"].items())[:15]:
        pct = n * 100 / total
        lines.append(f"| {country} | {n} | {pct:.1f}% |")

    lines.extend([
        f"",
        f"## Daily downloads timeline",
        f"",
        f"| Date | Downloads |",
        f"|------|-----------|",
    ])
    for date, n in agg["by_date"].items():
        lines.append(f"| {date} | {n} |")

    lines.extend([
        f"",
        f"## App Store versions (latest 5)",
        f"",
        f"| Version | State | Platform | Created |",
        f"|---------|-------|----------|---------|",
    ])
    for v in versions[:5]:
        a = v.get("attributes", {})
        lines.append(f"| {a.get('versionString')} | {a.get('appStoreState')} | {a.get('platform')} | {a.get('createdDate', '')[:10]} |")

    lines.extend([
        f"",
        f"## Analytics Reports (search terms, page views, CVR)",
        f"",
        f"Status: **{analytics_status}**",
        f"",
        f"> Search term impressions, product page views, and CVR live in the Analytics Reports API",
        f"> (newer than Sales Reports). First snapshot takes 24-48h to generate after request.",
        f"> Once available, rerun this script — it'll pull the data automatically.",
        f"",
        f"## How to use this baseline",
        f"",
        f"1. Compare these numbers vs the same window 30/60 days from now to measure iteration impact.",
        f"2. The top country gets the **active locale** prioritization in iters (see `../README.md` plan).",
        f"3. If daily downloads <10, PPO won't reach statistical significance in <90 days — focus 100% on ASO text.",
        f"4. Any keyword absent from search terms data (when available) is a candidate for replacement.",
        f"",
    ])
    md_path.write_text("\n".join(lines))
    print(f"  → {md_path}")


# ─── Main ───────────────────────────────────────────────────────────────────
def main():
    print(f"Pulling analytics for {BUNDLE_ID} ...")
    sess = session()

    print("\n[1/4] Finding app ...")
    app_info = find_app(sess)
    app_id = app_info["id"]
    print(f"  app_id={app_id}  name={app_info['attributes']['name']}")

    print("\n[2/4] Pulling app store versions ...")
    versions = app_versions(sess, app_id)
    print(f"  found {len(versions)} versions")

    print(f"\n[3/4] Pulling daily sales reports (last {SALES_DAYS} days) ...")
    rows = pull_daily_sales(sess, SALES_DAYS)
    print(f"  total rows from vendor (all apps): {len(rows)}")
    print(f"  filtering to SKU={APP_SKU!r} ...")
    agg = aggregate(rows, APP_SKU)
    print(f"  My Expenses: Personal Finances downloads in window: {agg['total_downloads']}")
    print(f"  My Expenses: Personal Finances IAP units: {agg['total_iap_units']} (${agg['total_proceeds_usd']} USD)")
    print(f"  countries: {len(agg['by_country'])}")
    print(f"  by country (top 5): {dict(list(agg['by_country'].items())[:5])}")

    print("\n[4/4] Analytics Reports — ensuring requests + pulling search terms ...")
    reqs = ensure_analytics_requests(sess, app_id)
    analytics_status, term_rows = pull_search_terms(sess, reqs)
    print(f"  {analytics_status}")
    st_csv = write_search_terms_csv(term_rows)
    if st_csv:
        print(f"  → {st_csv}")
        print("\n  Top search terms (by downloads, then impressions):")
        print(f"  {'downloads':>9} {'pageviews':>9} {'impr':>8}  term")
        for t in term_rows[:25]:
            print(f"  {t['downloads']:>9} {t['page_views']:>9} {t['impressions']:>8}  {t['term']}")

    print("\n[+] Writing outputs ...")
    write_outputs(app_info, agg, rows, versions, analytics_status)

    print("\nDone.")
    print(f"\nQuick summary:")
    print(f"  Downloads/day (avg over {len(agg['by_date'])} days with data): {agg['total_downloads'] / max(len(agg['by_date']), 1):.2f}")
    print(f"  Top 3 countries: {dict(list(agg['by_country'].items())[:3])}")
    if not term_rows:
        print(f"  Search terms: {analytics_status}")


if __name__ == "__main__":
    main()
