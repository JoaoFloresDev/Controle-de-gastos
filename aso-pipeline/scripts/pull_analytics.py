#!/usr/bin/env python3
"""
pull_analytics.py — the ONE measuring stick of an ASO iteration of My Expenses: Personal Finances.

Why this script exists in this shape (aso_efficacy audit, 27/09/2026): 15 of 16
text iterations that reached the store had no verifiable gain — not because the
text was bad, but because nothing was measured on the right series, the right
day, the right country, against the right control. Every verdict written by hand
("+75% POSITIVE") fell apart on a 30-day window with the target country isolated.
So the numbers come from HERE, from the Sales cache, or they do not exist.

Rules it enforces (LEARNINGS #53 + aso_efficacy 27/09):
  * installs = Product Type 1* only (1, 1F, 1T, F1). Updates (7*) and
    redownloads (3*) never count.
  * D0 = the day the carrier version became READY_FOR_SALE (`live_at`), never
    the day of the PATCH.
  * windows = 30 calendar days before / 30 after D0 (never hand-picked).
  * the number that decides is the TARGET country (the storefronts whose field
    changed); a gain only outside the target is "não é do texto".
  * control = median rate ratio of >= 3 apps with no release / PPO / text change
    in the same window (from scan.py's store_events, read from disk).
  * CI 95% on the rate ratio (Poisson log-normal; `--ci bootstrap` resamples days).
  * n < 30 installs in either target window = "não dá pra saber".

Subcommands:
  baseline                     legacy pull: 60d Sales + versions + ensure the
                               App Analytics ONGOING request (the r15 history
                               only starts the day this request exists — create
                               it for every app BEFORE any iteration)
  d0 --iter DIR --live-at D    write metrics/d00_baseline.json (30d installs 1*
                               per country, last r15 weeks per territory, Astro
                               snapshot files). Status cannot be `live` without it.
  checkpoint --iter DIR --day N   the three numbers so far (target / others / control)
  final --iter DIR [--write-meta] results.final = {alvo_antes, alvo_depois, RR,
                               IC_low, IC_high, controle_mediana, n_alvo, ...}
  floor --country CC           traffic floor: >= 100 installs 1* / 30d in the
                               target country, else the lever is not keywords
  quarantine --iter DIR        refuse deploy if a PPO is APPROVED/running, a
                               version is in review, or a store event sits inside
                               +-14d (override only with --override, logged)
  gate --iter DIR              offline consistency of meta.json status vs files

Sales cache: vendor-wide daily TSVs (`YYYY-MM-DD.tsv.gz`) in $ASO_SALES_CACHE
(default ~/Documents/GambitStudio/_GambitStudio/cache/sales). Filled on demand
from /v1/salesReports; every app's pipeline shares it (one request per day per
lab, not per app — the key's quota is 3600/h, LEARNINGS #57d).

Env vars (defaults match GambitStudio):
  APP_STORE_CONNECT_KEY_ID / _ISSUER_ID / _KEY_PATH / _VENDOR_NUMBER
  APP_ID (default: 6502218501)   APP_BUNDLE_ID (default: com.gambit.meusgastos)
  APP_SKU (default: MeusGastos)  ASO_SALES_CACHE  GAMBIT_LAB
"""

from __future__ import annotations

import argparse
import csv
import gzip
import io
import json
import math
import os
import random
import statistics
import sys
import time
from collections import defaultdict
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

# ─── Config ─────────────────────────────────────────────────────────────────
KEY_ID = os.environ.get("APP_STORE_CONNECT_KEY_ID", "67JG58Q6XH")
ISSUER_ID = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "98c49316-b223-4d64-955d-b55ae76ab9d2")
KEY_PATH = os.path.expanduser(
    os.environ.get("APP_STORE_CONNECT_KEY_PATH", "~/Documents/GambitStudio/_GambitStudio/keys/asc_api_key.p8")
)
VENDOR_NUMBER = os.environ.get("APP_STORE_CONNECT_VENDOR_NUMBER", "88531754")
APP_ID = os.environ.get("APP_ID", "6502218501")
BUNDLE_ID = os.environ.get("APP_BUNDLE_ID", "com.gambit.meusgastos")
APP_SKU = os.environ.get("APP_SKU", "MeusGastos")  # legacy filter for the baseline report
LAB = Path(os.environ.get("GAMBIT_LAB", "~/Documents/GambitStudio/_GambitStudio")).expanduser()
SALES_CACHE = Path(os.environ.get("ASO_SALES_CACHE", str(LAB / "cache" / "sales"))).expanduser()

API_BASE = "https://api.appstoreconnect.apple.com"
SALES_DAYS = 60            # legacy baseline report
WINDOW_DAYS = 30           # before/after windows (aso_efficacy: 30 calendar days)
MIN_N = 30                 # below this in either target window = "não dá pra saber"
MIN_CONTROLS = 3           # fewer controls = "controle insuficiente"
TRAFFIC_FLOOR = 100        # installs 1* / 30d in the target country to run a keyword iteration
QUARANTINE_DAYS = 14       # no PPO start/stop nor feature release around a text live day
INSTALL = {"1", "1F", "1T", "F1"}
UPDATE = {"7", "7F", "7T", "F7"}
REDL = {"3", "3F", "3T", "F3"}
RUNNING_STATES = {"WAITING_FOR_REVIEW", "IN_REVIEW", "PENDING_APPLE_RELEASE",
                  "PENDING_DEVELOPER_RELEASE", "READY_FOR_REVIEW"}

OUT_DIR = Path(__file__).resolve().parent.parent / "reports"
TODAY = datetime.now(timezone.utc).date()


# ─── Auth (lazy — offline subcommands never import jwt/requests) ────────────
def jwt_token() -> str:
    import jwt
    with open(KEY_PATH) as f:
        private_key = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"},
    )


def session():
    import requests
    s = requests.Session()
    s.headers.update({"Authorization": f"Bearer {jwt_token()}"})
    return s


def api_get(sess, path, **params):
    """GET with a fresh token per call (a 20-min token dies inside long pulls, #57)."""
    sess.headers["Authorization"] = f"Bearer {jwt_token()}"
    r = sess.get(f"{API_BASE}{path}", params=params or None)
    if r.status_code != 200:
        print(f"  ! GET {path} → HTTP {r.status_code}: {r.text[:200]}", file=sys.stderr)
        return None
    return r.json()


# ─── App lookup ─────────────────────────────────────────────────────────────
def resolve_app_id(sess=None) -> str:
    if APP_ID and not APP_ID.startswith("__"):
        return APP_ID
    if sess is None:
        raise SystemExit("APP_ID not set (placeholder left) — pass --app-id or export APP_ID")
    data = (api_get(sess, "/v1/apps", **{"filter[bundleId]": BUNDLE_ID, "limit": 1}) or {}).get("data", [])
    if not data:
        raise SystemExit(f"App with bundleId {BUNDLE_ID} not found")
    return data[0]["id"]


def app_versions(sess, app_id: str) -> list[dict]:
    return (api_get(sess, f"/v1/apps/{app_id}/appStoreVersions", limit=10) or {}).get("data", [])


def app_experiments(sess, app_id: str) -> list[dict]:
    out = []
    for v in app_versions(sess, app_id):
        d = api_get(sess, f"/v1/appStoreVersions/{v['id']}/appStoreVersionExperimentsV2", limit=20)
        out.extend((d or {}).get("data", []))
    return out


# ─── Sales cache ────────────────────────────────────────────────────────────
def cache_path(d: date) -> Path:
    return SALES_CACHE / f"{d.isoformat()}.tsv.gz"


def fetch_sales_day(sess, d: date) -> bytes | None:
    """Raw gzipped vendor-wide SALES/SUMMARY/DAILY report; None when Apple has none."""
    sess.headers["Authorization"] = f"Bearer {jwt_token()}"
    r = sess.get(
        f"{API_BASE}/v1/salesReports",
        params={
            "filter[frequency]": "DAILY", "filter[reportSubType]": "SUMMARY",
            "filter[reportType]": "SALES", "filter[vendorNumber]": VENDOR_NUMBER,
            "filter[reportDate]": d.isoformat(),
        },
        headers={"Accept": "application/a-gzip"},
    )
    if r.status_code == 404:
        return None
    if r.status_code != 200:
        print(f"  [{d}] HTTP {r.status_code}: {r.text[:200]}", file=sys.stderr)
        return None
    return r.content


def ensure_sales_cache(sess, start: date, end: date) -> int:
    """Fill SALES_CACHE for start..end. A day older than 3d with no report is
    cached as an EMPTY file (Apple has nothing for it); recent 404s are retried
    next time. Returns the number of requests made."""
    SALES_CACHE.mkdir(parents=True, exist_ok=True)
    n = 0
    d = start
    while d <= end:
        p = cache_path(d)
        if not p.exists():
            raw = fetch_sales_day(sess, d)
            n += 1
            if raw is not None:
                p.write_bytes(raw)
            elif (TODAY - d).days > 3:
                p.write_bytes(b"")
        d += timedelta(days=1)
    return n


def load_sales_cache(cache_dir: Path | None = None, app_ids: set[str] | None = None):
    """per[app_id][date] = {"installs", "updates", "redl", "by_country": {cc: installs}}
    plus the sorted list of cached days. 1* only feeds installs/by_country (#53)."""
    cache_dir = Path(cache_dir or SALES_CACHE)
    per: dict = {}
    days: list[str] = []
    for p in sorted(cache_dir.glob("*.tsv.gz")):
        d = p.name[:10]
        days.append(d)
        raw = p.read_bytes()
        if not raw:
            continue
        try:
            text = gzip.GzipFile(fileobj=io.BytesIO(raw)).read().decode("utf-8")
        except OSError:
            text = raw.decode("utf-8", "ignore")
        for r in csv.DictReader(io.StringIO(text), delimiter="\t"):
            if (r.get("Parent Identifier") or "").strip():
                continue  # IAP row
            app = (r.get("Apple Identifier") or "").strip()
            if not app or (app_ids and app not in app_ids):
                continue
            pt = (r.get("Product Type Identifier") or "").strip()
            try:
                u = int(r.get("Units") or 0)
            except ValueError:
                u = 0
            day = per.setdefault(app, {}).setdefault(
                d, {"installs": 0, "updates": 0, "redl": 0, "by_country": {}})
            if pt in INSTALL:
                day["installs"] += u
                cc = (r.get("Country Code") or "").strip()
                day["by_country"][cc] = day["by_country"].get(cc, 0) + u
            elif pt in UPDATE:
                day["updates"] += u
            elif pt in REDL:
                day["redl"] += u
    return per, sorted(days)


def daily_series(per, app_id: str, d0: date, d1: date, countries=None, exclude=None, key="installs"):
    """Daily installs 1* for d0..d1 inclusive (missing day = 0). `countries`
    restricts to those storefronts; `exclude` removes them (the "others")."""
    out = []
    d = d0
    while d <= d1:
        rec = per.get(app_id, {}).get(d.isoformat())
        if rec is None:
            out.append(0)
        elif countries:
            out.append(sum(rec["by_country"].get(c, 0) for c in countries))
        elif exclude:
            out.append(sum(v for c, v in rec["by_country"].items() if c not in exclude))
        else:
            out.append(rec[key])
        d += timedelta(days=1)
    return out


def installs_by_country(per, app_id: str, d0: date, d1: date) -> dict[str, int]:
    tot: dict = defaultdict(int)
    d = d0
    while d <= d1:
        rec = per.get(app_id, {}).get(d.isoformat())
        if rec:
            for c, v in rec["by_country"].items():
                tot[c] += v
        d += timedelta(days=1)
    return dict(sorted(tot.items(), key=lambda x: -x[1]))


# ─── Statistics ─────────────────────────────────────────────────────────────
def rr_ci_poisson(a: int, da: int, b: int, db: int):
    """Rate ratio (after/before) with 95% CI — log-normal approximation on Poisson
    counts, the same computation as the aso_efficacy audit. None when a count is 0."""
    if a <= 0 or b <= 0 or da <= 0 or db <= 0:
        return None, None, None
    rr = (b / db) / (a / da)
    se = math.sqrt(1 / a + 1 / b)
    return rr, rr * math.exp(-1.96 * se), rr * math.exp(1.96 * se)


def rr_ci_bootstrap(before: list[int], after: list[int], n_iter: int = 2000, seed: int = 0):
    """Rate ratio with a 95% percentile CI by resampling DAYS (keeps the day-to-day
    burstiness that Poisson ignores). Deterministic for a given seed."""
    if not before or not after or sum(before) == 0 or sum(after) == 0:
        return None, None, None
    rng = random.Random(seed)
    rr = (sum(after) / len(after)) / (sum(before) / len(before))
    samples = []
    for _ in range(n_iter):
        b = sum(rng.choice(before) for _ in before)
        a = sum(rng.choice(after) for _ in after)
        if b > 0 and a > 0:
            samples.append((a / len(after)) / (b / len(before)))
    if len(samples) < 100:
        return rr, None, None
    samples.sort()
    return rr, samples[int(0.025 * len(samples))], samples[int(0.975 * len(samples)) - 1]


# ─── Windows + verdict ──────────────────────────────────────────────────────
def windows_for(live_at: date, until: date | None = None, window: int = WINDOW_DAYS):
    """before = the `window` days ending the day BEFORE D0; after = D0 .. D0+window-1,
    truncated at `until` (the last cached day) when the after window is not complete yet."""
    b_end = live_at - timedelta(days=1)
    b_start = b_end - timedelta(days=window - 1)
    a_start = live_at
    a_end = live_at + timedelta(days=window - 1)
    if until and until < a_end:
        a_end = until
    return b_start, b_end, a_start, a_end


def control_ratios(per, control_ids, b_start, b_end, a_start, a_end, min_before: int = 20):
    """(app_id, before, after, RR) for each control app with >= min_before installs."""
    out = []
    db = (b_end - b_start).days + 1
    da = (a_end - a_start).days + 1
    for c in control_ids:
        cb = sum(daily_series(per, c, b_start, b_end))
        ca = sum(daily_series(per, c, a_start, a_end))
        if cb < min_before or ca <= 0:
            continue
        out.append((c, cb, ca, (ca / da) / (cb / db)))
    return out


def judge(alvo_antes, alvo_depois, rr, lo, hi, rr_outros, lo_outros, controle_mediana, n_controls,
          min_n: int = MIN_N, min_controls: int = MIN_CONTROLS) -> tuple[str, str]:
    """The verdict and its one-line reason. Order matters: the n gate comes first
    because every other reading is noise below it (aso_efficacy: 9 of 16 iterations
    had < 50 installs in the target country and no answer either way)."""
    n_alvo = min(alvo_antes or 0, alvo_depois or 0)
    if n_alvo < min_n or rr is None:
        return "não dá pra saber", f"n pequeno no alvo ({alvo_antes} → {alvo_depois}; piso {min_n} por janela)"
    if hi is not None and hi < 1.0:
        return "piorou", f"IC do alvo inteiro abaixo de 1 [{lo:.2f}, {hi:.2f}]"
    target_up = lo is not None and lo > 1.0
    others_up = rr_outros is not None and lo_outros is not None and lo_outros > 1.0
    if target_up:
        if n_controls < min_controls:
            return "provável — controle insuficiente", (
                f"IC exclui 1 [{lo:.2f}, {hi:.2f}] mas só {n_controls} app(s)-controle na janela (mínimo {min_controls})")
        if controle_mediana is not None and rr > controle_mediana:
            return "ganhou", f"RR {rr:.2f} [{lo:.2f}, {hi:.2f}] acima da mediana do controle {controle_mediana:.2f}"
        return "não mudou", (
            f"IC exclui 1 [{lo:.2f}, {hi:.2f}] mas o controle andou igual ou mais (mediana {controle_mediana:.2f}) — movimento do mercado, não do texto")
    if others_up:
        return "não é do texto", f"alvo RR {rr:.2f} [{lo:.2f}, {hi:.2f}] dentro do ruído; ganho só fora do país-alvo (RR {rr_outros:.2f})"
    return "não mudou", f"IC do alvo inclui 1 [{lo:.2f}, {hi:.2f}]"


def evaluate(per, app_id: str, live_at: date, target_countries: list[str], control_ids: list[str],
             until: date | None = None, window: int = WINDOW_DAYS, ci: str = "poisson",
             min_n: int = MIN_N) -> dict:
    """results.final for one iteration — every number from the Sales cache."""
    b_start, b_end, a_start, a_end = windows_for(live_at, until, window)
    db = (b_end - b_start).days + 1
    da = (a_end - a_start).days + 1
    tc = [c.upper() for c in target_countries]
    sb = daily_series(per, app_id, b_start, b_end, countries=tc)
    sa = daily_series(per, app_id, a_start, a_end, countries=tc)
    ob = daily_series(per, app_id, b_start, b_end, exclude=set(tc))
    oa = daily_series(per, app_id, a_start, a_end, exclude=set(tc))
    alvo_antes, alvo_depois = sum(sb), sum(sa)
    outros_antes, outros_depois = sum(ob), sum(oa)
    if ci == "bootstrap":
        rr, lo, hi = rr_ci_bootstrap(sb, sa)
    else:
        rr, lo, hi = rr_ci_poisson(alvo_antes, db, alvo_depois, da)
    rr_o, lo_o, hi_o = rr_ci_poisson(outros_antes, db, outros_depois, da)
    ctrl = control_ratios(per, [c for c in control_ids if c != app_id], b_start, b_end, a_start, a_end)
    med = statistics.median([x[3] for x in ctrl]) if ctrl else None
    verdict, reason = judge(alvo_antes, alvo_depois, rr, lo, hi, rr_o, lo_o, med, len(ctrl), min_n=min_n)
    r = lambda x: None if x is None else round(x, 3)  # noqa: E731
    return {
        "alvo_antes": alvo_antes, "alvo_depois": alvo_depois,
        "RR": r(rr), "IC_low": r(lo), "IC_high": r(hi),
        "controle_mediana": r(med), "n_alvo": min(alvo_antes, alvo_depois),
        "alvo_paises": tc,
        "outros_antes": outros_antes, "outros_depois": outros_depois,
        "RR_outros": r(rr_o), "IC_outros": [r(lo_o), r(hi_o)],
        "controle_apps": [{"app_id": c, "antes": cb, "depois": ca, "RR": round(x, 3)} for c, cb, ca, x in ctrl],
        "n_controles": len(ctrl),
        "janela": {"antes": [b_start.isoformat(), b_end.isoformat()], "depois": [a_start.isoformat(), a_end.isoformat()],
                   "dias_antes": db, "dias_depois": da, "completa": da >= window},
        "metodo": f"Sales Report 1* apenas; RR depois/antes por dia; IC 95% {ci}; controle = mediana de apps sem release/PPO/texto na janela",
        "veredito": verdict, "motivo": reason,
        "fonte": "pull_analytics.py",
        "computed_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }


def traffic_floor(per, app_id: str, country: str, until: date, floor: int = TRAFFIC_FLOOR,
                  window: int = WINDOW_DAYS) -> dict:
    start = until - timedelta(days=window - 1)
    n = sum(daily_series(per, app_id, start, until, countries=[country.upper()]))
    return {"country": country.upper(), "installs_30d": n, "floor": floor, "ok": n >= floor,
            "window": [start.isoformat(), until.isoformat()],
            "lever": "keywords" if n >= floor else "ratings/prints/produto (abaixo do piso — iteração de texto não é mensurável)"}


def quarantine_check(versions: list[dict], experiments: list[dict], events: list[date],
                     today: date, days: int = QUARANTINE_DAYS) -> dict:
    """Pure part of the quarantine rule (aso_efficacy regra 3). `events` = store
    event dates of THIS app from disk (releases, PPO start/stop, text live)."""
    blockers = []
    for v in versions:
        a = v.get("attributes", {})
        if a.get("appStoreState") in RUNNING_STATES:
            blockers.append(f"versão {a.get('versionString')} em {a.get('appStoreState')}")
    for e in experiments:
        a = e.get("attributes", {})
        # LEARNINGS #39b: `started` comes back null for a running test — read startDate/state
        running = a.get("state") == "APPROVED" and a.get("startDate") and not a.get("endDate")
        if a.get("state") == "APPROVED" or running:
            blockers.append(f"experimento '{a.get('name')}' {a.get('state')}"
                            + (" rodando" if running else " (aprovado — pode iniciar a qualquer hora)"))
    near = sorted(e for e in events if abs((e - today).days) <= days)
    for e in near:
        blockers.append(f"evento de loja em {e} ({(e - today).days:+d}d) dentro da quarentena de ±{days}d")
    return {"ok": not blockers, "blockers": blockers, "quarantine_days": days, "checked_at": today.isoformat()}


# ─── meta.json helpers ──────────────────────────────────────────────────────
FINAL_KEYS = ("alvo_antes", "alvo_depois", "RR", "IC_low", "IC_high", "controle_mediana", "n_alvo")


def read_meta(iter_dir: Path) -> dict:
    return json.loads((iter_dir / "meta.json").read_text(encoding="utf-8"))


def write_meta(iter_dir: Path, meta: dict):
    (iter_dir / "meta.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def gate(meta: dict, iter_dir: Path) -> list[str]:
    """Offline consistency of status vs evidence. Empty list = consistent."""
    problems = []
    status = meta.get("status")
    if status == "live" or meta.get("live_at"):
        if not (iter_dir / "metrics" / "d00_baseline.json").exists():
            problems.append("status live / live_at sem metrics/d00_baseline.json (regra 1)")
        if not meta.get("live_at"):
            problems.append("status live sem live_at (D0 = dia READY_FOR_SALE, regra 1)")
    if meta.get("deployed") or status in ("deployed", "live", "closed"):
        state = (meta.get("carrier_version") or {}).get("state")
        if not meta.get("live_at") and state != "READY_FOR_SALE":
            problems.append("deployed sem versão portadora READY_FOR_SALE nem live_at — PATCH aplicado é `staged`, não `deployed` (regra 5)")
    if status == "closed":
        final = (meta.get("results") or {}).get("final") or {}
        missing = [k for k in FINAL_KEYS if k not in final]
        if missing:
            problems.append(f"status closed sem results.final completo — faltam {missing} (regra 5)")
        if final and final.get("fonte") != "pull_analytics.py":
            problems.append("results.final não veio do pull_analytics.py — número à mão não fecha iteração (regra 5)")
    ov = meta.get("quarantine_override")
    if ov and not (isinstance(ov, dict) and ov.get("by") and ov.get("reason")):
        problems.append("quarantine_override sem `by`/`reason` — override tem que ser rastreável (regra 3)")
    return problems


def target_countries_of(meta: dict) -> list[str]:
    """Storefronts whose field changed. Explicit `target_countries` wins; else
    derived from the locales (pt-BR→BR, en-US→US, es-MX→MX/AR/UY/CO/CL/PE, ...)."""
    if meta.get("target_countries"):
        return [c.upper() for c in meta["target_countries"]]
    loc_map = {
        "pt-BR": ["BR"], "pt-PT": ["PT"], "en-US": ["US"], "en-GB": ["GB"], "en-AU": ["AU"], "en-CA": ["CA"],
        "es-ES": ["ES"], "es-MX": ["MX", "AR", "UY", "CO", "CL", "PE"], "de-DE": ["DE"], "fr-FR": ["FR"],
        "it": ["IT"], "ja": ["JP"], "ko": ["KR"], "ru": ["RU"], "tr": ["TR"], "nl-NL": ["NL"],
    }
    locales = meta.get("locales_all") or ([meta.get("locale")] if meta.get("locale") else [])
    out: list[str] = []
    for loc in locales:
        for c in loc_map.get(loc, []):
            if c not in out:
                out.append(c)
    return out


def auto_controls(app_id: str, b_start: date, a_end: date) -> tuple[list[str], str]:
    """Apps with no store event in the window, from scan.py (disk only). Strict
    first (no release / PPO / text); when fewer than MIN_CONTROLS qualify, the
    RELAXED group of the audit (PPO ignored) — labelled as such in the result."""
    sys.path.insert(0, str(LAB / "orchestrator"))
    try:
        import scan  # type: ignore
    except Exception as e:  # noqa: BLE001
        print(f"  ! scan.py indisponível ({e}) — passe --controls <ids>", file=sys.stderr)
        return [], "indisponível"
    strict = [c for c in scan.control_candidates(b_start, a_end, exclude=app_id) if c != app_id]
    if len(strict) >= MIN_CONTROLS:
        return strict, "estrito (sem release, PPO nem texto na janela)"
    relaxed = [c for c in scan.control_candidates(b_start, a_end, exclude=app_id, relaxed=True) if c != app_id]
    return relaxed, f"relaxado (sem release nem texto; PPO ignorado) — só {len(strict)} app(s) no estrito"


# ─── App Analytics (r15) ────────────────────────────────────────────────────
def ensure_analytics_request(sess, app_id: str) -> dict | None:
    """The ONGOING request must exist BEFORE the iteration: Apple only backfills
    ~1 week, so an r15 history starts the day the request is created (the lab had
    nothing before 17/08/2026 for that reason). `/refresh-lab-data` (pull_data.py
    `_report_instances`) auto-provisions it too."""
    d = api_get(sess, f"/v1/apps/{app_id}/analyticsReportRequests", limit=50)
    existing = (d or {}).get("data", [])
    ongoing = [x for x in existing if x.get("attributes", {}).get("accessType") == "ONGOING"]
    if ongoing:
        return ongoing[0]
    body = {"data": {"type": "analyticsReportRequests", "attributes": {"accessType": "ONGOING"},
                     "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}}
    sess.headers["Authorization"] = f"Bearer {jwt_token()}"
    r = sess.post(f"{API_BASE}/v1/analyticsReportRequests", json=body)
    if r.status_code == 201:
        print("  + created ONGOING analytics report request (data in 24-48h; history starts TODAY)")
        return r.json().get("data")
    print(f"  ! analytics request create failed: HTTP {r.status_code}: {r.text[:200]}", file=sys.stderr)
    return None


def fetch_r15_weekly(sess, app_id: str, weeks: int = 6) -> list[dict] | None:
    """Last `weeks` WEEKLY instances of r15 (Discovery and Engagement Detailed):
    impressions / page views per territory. None = no ONGOING request."""
    req = ensure_analytics_request(sess, app_id)
    if not req:
        return None
    d = api_get(sess, f"/v1/analyticsReports/r15-{req['id']}/instances", limit=200, **{"filter[granularity]": "WEEKLY"})
    insts = sorted((d or {}).get("data", []), key=lambda x: x["attributes"]["processingDate"])[-weeks:]
    out = []
    for inst in insts:
        segs = (api_get(sess, f"/v1/analyticsReportInstances/{inst['id']}/segments") or {}).get("data", [])
        rows = []
        for s in segs:
            raw = sess.get(s["attributes"]["url"], timeout=120, headers={"Authorization": ""}).content
            try:
                text = gzip.GzipFile(fileobj=io.BytesIO(raw)).read().decode("utf-8")
            except OSError:
                text = raw.decode("utf-8", "ignore")
            rows.extend(csv.DictReader(io.StringIO(text), delimiter="\t"))
        out.append({"processing_date": inst["attributes"]["processingDate"], **summarize_r15(rows)})
    return out


def summarize_r15(rows: list[dict]) -> dict:
    imp: dict = defaultdict(int)
    pv: dict = defaultdict(int)
    dates = set()
    for r in rows:
        ev = (r.get("Event") or "").strip().lower()
        t = (r.get("Territory") or "??").strip()
        try:
            n = int(float(r.get("Counts") or 0))
        except ValueError:
            n = 0
        dates.add(r.get("Date"))
        if ev == "impression":
            imp[t] += n
        elif ev == "page view":
            pv[t] += n
    return {"week_start": min(dates) if dates else None,
            "impressions_by_territory": dict(sorted(imp.items(), key=lambda x: -x[1])),
            "page_views_by_territory": dict(sorted(pv.items(), key=lambda x: -x[1])),
            "impressions": sum(imp.values()), "page_views": sum(pv.values())}


def build_d0_baseline(per, app_id: str, live_at: date, iter_dir: Path, r15: list[dict] | None,
                      analytics_request_id: str | None) -> dict:
    b_start, b_end, _, _ = windows_for(live_at)
    by_c = installs_by_country(per, app_id, b_start, b_end)
    astro = sorted(p.name for p in (iter_dir / "research").glob("astro_*")) if (iter_dir / "research").exists() else []
    return {
        "live_at": live_at.isoformat(), "captured_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "window": {"start": b_start.isoformat(), "end": b_end.isoformat(), "days": WINDOW_DAYS},
        "installs_total": sum(by_c.values()), "installs_per_day": round(sum(by_c.values()) / WINDOW_DAYS, 2),
        "installs_by_country": by_c, "product_types": "1* only (LEARNINGS #53)",
        "r15_weeks": r15, "r15_note": None if r15 else "sem request ONGOING de App Analytics — criado agora; impressões só existem daqui em diante",
        "analytics_request_id": analytics_request_id,
        "astro_snapshot": astro, "astro_note": None if astro else "sem research/astro_*.json — rankings 'antes' não existem",
        "fonte": "pull_analytics.py d0",
    }


# ─── Subcommands ────────────────────────────────────────────────────────────
def _iter_dir(args) -> Path:
    p = Path(args.iter).expanduser().resolve()
    if not (p / "meta.json").exists():
        raise SystemExit(f"{p} não tem meta.json")
    return p


def _live_at(args, meta) -> date:
    s = getattr(args, "live_at", None) or meta.get("live_at")
    if not s:
        raise SystemExit("live_at ausente — D0 é o dia READY_FOR_SALE da versão portadora (regra 1); passe --live-at")
    return date.fromisoformat(str(s)[:10])


def _load(args, app_id: str, start: date, end: date):
    if not args.offline:
        sess = session()
        n = ensure_sales_cache(sess, start, min(end, TODAY - timedelta(days=1)))
        print(f"  sales cache: {n} request(s) novos")
    per, days = load_sales_cache(args.cache)
    if app_id not in per:
        print(f"  ! nenhuma linha 1* do app {app_id} no cache {args.cache} ({len(days)} dias)", file=sys.stderr)
    return per, days


def cmd_d0(args):
    iter_dir = _iter_dir(args)
    meta = read_meta(iter_dir)
    app_id = args.app_id or resolve_app_id(None if args.offline else session())
    live_at = _live_at(args, meta)
    b_start, b_end, _, _ = windows_for(live_at)
    per, _ = _load(args, app_id, b_start, b_end)
    r15, req_id = None, None
    if not args.offline:
        sess = session()
        req = ensure_analytics_request(sess, app_id)
        req_id = req["id"] if req else None
        r15 = fetch_r15_weekly(sess, app_id) if req else None
    base = build_d0_baseline(per, app_id, live_at, iter_dir, r15, req_id)
    out = iter_dir / "metrics" / "d00_baseline.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(base, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"  → {out}\n  {base['installs_total']} instalações 1* em 30d ({base['installs_per_day']}/d); "
          f"top: {dict(list(base['installs_by_country'].items())[:5])}")
    if args.write_meta:
        meta["live_at"] = live_at.isoformat()
        meta.setdefault("metrics", {})["d00_baseline"] = "metrics/d00_baseline.json"
        write_meta(iter_dir, meta)
        print("  meta.json: live_at + metrics.d00_baseline gravados")
    return 0


def _evaluate_cmd(args, write_key: str | None):
    iter_dir = _iter_dir(args)
    meta = read_meta(iter_dir)
    app_id = args.app_id or resolve_app_id(None if args.offline else session())
    live_at = _live_at(args, meta)
    tc = [c.strip() for c in args.countries.split(",")] if args.countries else target_countries_of(meta)
    if not tc:
        raise SystemExit("país-alvo desconhecido — passe --countries BR,US ou meta.json.target_countries")
    until = date.fromisoformat(args.until) if args.until else TODAY - timedelta(days=1)
    if getattr(args, "day", None):
        until = min(until, live_at + timedelta(days=args.day - 1))
    b_start, _, _, a_end = windows_for(live_at, until)
    per, days = _load(args, app_id, b_start, a_end)
    if days:
        until = min(until, date.fromisoformat(days[-1]))
    if args.controls == "auto":
        controls, ctrl_kind = auto_controls(app_id, b_start, a_end)
    else:
        controls = [c.strip() for c in (args.controls or "").split(",") if c.strip()]
        ctrl_kind = "explícito (--controls)"
    res = evaluate(per, app_id, live_at, tc, controls, until=until, ci=args.ci)
    res["controle_tipo"] = ctrl_kind
    if getattr(args, "day", None):
        res["checkpoint_day"] = args.day
    print(json.dumps(res, ensure_ascii=False, indent=2))
    print(f"\nVEREDITO: {res['veredito']} — {res['motivo']}")
    if write_key:
        meta.setdefault("results", {})
        if write_key == "final":
            meta["results"]["final"] = res
        else:
            cps = meta["results"].setdefault("checkpoints", [])
            cps.append({"day": args.day, "date": TODAY.isoformat(), "series": res})
        write_meta(iter_dir, meta)
        out = iter_dir / "metrics" / (f"final.json" if write_key == "final" else f"{TODAY.isoformat()}_d{args.day:02d}.json")
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(res, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"  → {out} + meta.json.results.{write_key}")
    return 0


def cmd_checkpoint(args):
    return _evaluate_cmd(args, "checkpoints" if args.write_meta else None)


def cmd_final(args):
    return _evaluate_cmd(args, "final" if args.write_meta else None)


def cmd_floor(args):
    app_id = args.app_id or resolve_app_id(None if args.offline else session())
    until = date.fromisoformat(args.until) if args.until else TODAY - timedelta(days=1)
    per, days = _load(args, app_id, until - timedelta(days=WINDOW_DAYS - 1), until)
    if days:
        until = min(until, date.fromisoformat(days[-1]))
    res = traffic_floor(per, app_id, args.country, until, floor=args.floor)
    print(json.dumps(res, ensure_ascii=False, indent=2))
    print(f"\n{'PISO OK' if res['ok'] else 'ABAIXO DO PISO'}: {res['installs_30d']} instalações 1*/30d em {res['country']} "
          f"(piso {res['floor']}) → alavanca = {res['lever']}")
    return 0 if res["ok"] else 2


def cmd_quarantine(args):
    iter_dir = _iter_dir(args)
    meta = read_meta(iter_dir)
    app_id = args.app_id or resolve_app_id(session())
    sess = session()
    versions = app_versions(sess, app_id)
    experiments = app_experiments(sess, app_id)
    events: list[date] = []
    sys.path.insert(0, str(LAB / "orchestrator"))
    try:
        import scan  # type: ignore
        dirname = scan.STORE_ID_TO_DIRNAME.get(app_id)
        ev = scan.store_events().get(dirname, {}) if dirname else {}
        events = sorted({d for lst in ev.values() for d in lst})
    except Exception as e:  # noqa: BLE001
        print(f"  ! scan.py indisponível ({e}) — quarentena só com o estado da ASC", file=sys.stderr)
    res = quarantine_check(versions, experiments, events, TODAY)
    print(json.dumps(res, ensure_ascii=False, indent=2))
    if res["ok"]:
        print("\nQUARENTENA LIVRE — pode deployar")
        return 0
    if args.override:
        meta["quarantine_override"] = {"by": args.override, "reason": args.reason or "(sem motivo)",
                                       "at": TODAY.isoformat(), "blockers": res["blockers"]}
        write_meta(iter_dir, meta)
        print("\nQUARENTENA VIOLADA com override EXPLÍCITO — registrado em meta.json.quarantine_override")
        return 0
    print("\nQUARENTENA: deploy RECUSADO —\n  " + "\n  ".join(res["blockers"]))
    return 3


def cmd_gate(args):
    iter_dir = _iter_dir(args)
    problems = gate(read_meta(iter_dir), iter_dir)
    if problems:
        print("GATE REPROVADO:\n  " + "\n  ".join(problems))
        return 4
    print("GATE OK — status coerente com as evidências em disco")
    return 0


# ─── Legacy baseline report (kept: extractor + Day 0 human summary) ─────────
def cmd_baseline(args):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sess = session()
    app_id = args.app_id or resolve_app_id(sess)
    print(f"Pulling analytics for {BUNDLE_ID} / {app_id} ...")
    versions = app_versions(sess, app_id)
    end = TODAY - timedelta(days=1)
    start = end - timedelta(days=SALES_DAYS - 1)
    n = ensure_sales_cache(sess, start, end)
    print(f"  sales cache: {n} request(s) novos")
    per, days = load_sales_cache(args.cache, {app_id})
    by_date = {d: (per.get(app_id, {}).get(d) or {}).get("installs", 0) for d in days if start.isoformat() <= d <= end.isoformat()}
    by_country = installs_by_country(per, app_id, start, end)
    total = sum(by_date.values())
    req = ensure_analytics_request(sess, app_id)
    status = f"ONGOING request id={req['id']}" if req else "FAILED to create — check API key permissions"
    lines = [
        "# Baseline Analytics — My Expenses: Personal Finances", "",
        f"**Pulled at**: {datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}", f"**App ID**: `{app_id}`", f"**Bundle ID**: `{BUNDLE_ID}`", "",
        "## Window", "", f"- **Range**: {start} → {end} ({SALES_DAYS} days, calendar)",
        f"- **Installs 1\\* (window)**: {total}", f"- **Installs/day**: {total / SALES_DAYS:.2f}", "",
        "## Installs 1* by country (top 15)", "", "| Country | Installs | % |", "|---|---|---|",
    ]
    for c, v in list(by_country.items())[:15]:
        lines.append(f"| {c} | {v} | {v * 100 / max(total, 1):.1f}% |")
    lines += ["", "## App Store versions (latest 5)", "", "| Version | State | Platform | Created |", "|---|---|---|---|"]
    for v in versions[:5]:
        a = v.get("attributes", {})
        lines.append(f"| {a.get('versionString')} | {a.get('appStoreState')} | {a.get('platform')} | {(a.get('createdDate') or '')[:10]} |")
    lines += ["", "## App Analytics", "", f"Status: **{status}** — the r15 history starts the day this request exists.", ""]
    md = OUT_DIR / f"baseline_{TODAY.isoformat()}.md"
    md.write_text("\n".join(lines), encoding="utf-8")
    csv_path = OUT_DIR / f"baseline_{TODAY.isoformat()}_sales.csv"
    with open(csv_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["date", "installs_1star"])
        for d, v in by_date.items():
            w.writerow([d, v])
    print(f"  → {md}\n  → {csv_path}\n  installs/day: {total / SALES_DAYS:.2f}  top: {dict(list(by_country.items())[:3])}")
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--cache", default=str(SALES_CACHE), help="sales cache dir (vendor-wide daily TSVs)")
    ap.add_argument("--app-id", default=None)
    ap.add_argument("--offline", action="store_true", help="never call the ASC — cache only")
    sub = ap.add_subparsers(dest="cmd")
    sub.add_parser("baseline", help="legacy 60d report + ensure App Analytics ONGOING request")
    p = sub.add_parser("d0", help="write metrics/d00_baseline.json at the live day")
    p.add_argument("--iter", required=True); p.add_argument("--live-at"); p.add_argument("--write-meta", action="store_true")
    for name in ("checkpoint", "final"):
        p = sub.add_parser(name)
        p.add_argument("--iter", required=True); p.add_argument("--live-at"); p.add_argument("--countries")
        p.add_argument("--controls", default="auto", help="'auto' (scan.py) or comma-separated app ids")
        p.add_argument("--until"); p.add_argument("--ci", choices=("poisson", "bootstrap"), default="poisson")
        p.add_argument("--write-meta", action="store_true")
        if name == "checkpoint":
            p.add_argument("--day", type=int, required=True)
    p = sub.add_parser("floor"); p.add_argument("--country", required=True); p.add_argument("--until")
    p.add_argument("--floor", type=int, default=TRAFFIC_FLOOR)
    p = sub.add_parser("quarantine"); p.add_argument("--iter", required=True)
    p.add_argument("--override", help="who authorized (logged in meta.json) — coordinator only")
    p.add_argument("--reason")
    p = sub.add_parser("gate"); p.add_argument("--iter", required=True)
    args = ap.parse_args(argv)
    args.cache = Path(args.cache).expanduser()
    return {"baseline": cmd_baseline, "d0": cmd_d0, "checkpoint": cmd_checkpoint, "final": cmd_final,
            "floor": cmd_floor, "quarantine": cmd_quarantine, "gate": cmd_gate}.get(args.cmd or "baseline")(args)


if __name__ == "__main__":
    sys.exit(main())
