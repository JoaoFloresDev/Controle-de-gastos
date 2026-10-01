#!/usr/bin/env python3
"""Create the PPO experiment on App Store Connect from this experiment folder.

treatments/<T>/<locale>/<dt>/NN_<slug>.png  →  one treatment per <T>, one
localization per <locale>, one screenshot set per <dt> (APP_IPHONE_67/65/55).
After upload, every set is verified by sourceFileChecksum == local md5 and
inherited clones are deleted (LEARNINGS #35). Re-run with --verify any time.

Reuses the HTTP/upload helpers of the lab template
(_GambitStudio/templates/fastlane/upload_ppo.py).

Usage:
  upload_experiment.py <experiment_dir> --name "Panorama v3 ordem 2026-08-28"
  upload_experiment.py <experiment_dir> --verify
  upload_experiment.py <experiment_dir> --resume     (continue an interrupted upload)
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

TEMPLATE = Path.home() / "Documents/GambitStudio/_GambitStudio/templates/fastlane/upload_ppo.py"
KEYS = Path.home() / "Documents/GambitStudio/_GambitStudio/keys"
APP_ID = "6502218501"
BUNDLE_ID = "com.gambit.meusgastos"
DT_ASC = {"67": "APP_IPHONE_67", "65": "APP_IPHONE_65", "55": "APP_IPHONE_55"}
WORKERS = 6
RETRY_SLEEP = 120
RETRIES = 12
_lock = threading.Lock()


def load_template():
    os.environ.setdefault("APP_STORE_CONNECT_KEY_ID", "67JG58Q6XH")
    os.environ.setdefault("APP_STORE_CONNECT_ISSUER_ID", "98c49316-b223-4d64-955d-b55ae76ab9d2")
    os.environ.setdefault("APP_STORE_CONNECT_KEY_PATH", str(KEYS / "asc_api_key.p8"))
    os.environ.setdefault("APP_BUNDLE_ID", BUNDLE_ID)
    spec = importlib.util.spec_from_file_location("ppo_template", TEMPLATE)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def md5(path: Path) -> str:
    return hashlib.md5(path.read_bytes()).hexdigest()


def hdr(mod) -> dict:
    return {"Authorization": f"Bearer {mod.make_token()}"}


def with_retry(fn, *args):
    """ASC answers 429 when the hourly quota is hit — back off instead of failing the set."""
    for attempt in range(RETRIES):
        try:
            return fn(*args)
        except Exception as e:
            msg = str(e)
            transient = any(k in msg for k in ("Connection", "timed out", "Timeout", "reset by peer", "502", "503", "504"))
            if attempt == RETRIES - 1 or not ("429" in msg or transient):
                raise
            sleep = RETRY_SLEEP if "429" in msg else 20
            print(f"   transient error ({msg.splitlines()[0][:80]}), sleeping {sleep}s (attempt {attempt + 1})", flush=True)
            time.sleep(sleep)


def plan_of(exp: Path) -> dict[str, dict[str, dict[str, list[Path]]]]:
    """{treatment: {locale: {dt: [files]}}}"""
    plan = {}
    for t in sorted(p for p in (exp / "treatments").iterdir() if p.is_dir()):
        plan[t.name] = {}
        for loc in sorted(p for p in t.iterdir() if p.is_dir()):
            plan[t.name][loc.name] = {dt.name: sorted(dt.glob("[0-9][0-9]_*.png"))
                                      for dt in sorted(p for p in loc.iterdir() if p.is_dir())}
    return plan


def state_path(exp: Path) -> Path:
    return exp / "asc_state.json"


def load_state(exp: Path) -> dict:
    p = state_path(exp)
    return json.loads(p.read_text()) if p.exists() else {}


def save_state(exp: Path, st: dict) -> None:
    with _lock:
        state_path(exp).write_text(json.dumps(st, indent=1))


def verify_set(mod, set_id: str, files: list[Path]) -> str:
    data = mod.get(hdr(mod), f"/v1/appScreenshotSets/{set_id}/appScreenshots", {"limit": 50})
    want = [md5(f) for f in files]
    by_sum: dict[str, str] = {}
    for s in data.get("data", []):
        c = s["attributes"].get("sourceFileChecksum")
        if c in want and c not in by_sum:
            by_sum[c] = s["id"]
        else:
            mod.delete(hdr(mod), f"/v1/appScreenshots/{s['id']}")
    missing = [w for w in want if w not in by_sum]
    if missing:
        return f"MISSING {len(missing)}"
    ordered = [by_sum[w] for w in want]
    current = [s["id"] for s in data.get("data", []) if s["id"] in ordered]
    if current != ordered:
        mod.patch(hdr(mod), f"/v1/appScreenshotSets/{set_id}/relationships/appScreenshots",
                  {"data": [{"type": "appScreenshots", "id": i} for i in ordered]})
        return "reordered"
    return "ok"


def ensure_localizations(mod, exp: Path, st: dict, t_name: str, locales: list[str]) -> None:
    loc_ids = st["treatments"][t_name].setdefault("localizations", {})
    for locale in locales:
        if locale not in loc_ids:
            loc_ids[locale] = mod.create_localization(hdr(mod), st["treatments"][t_name]["id"], locale)["id"]
            save_state(exp, st)


def upload_set(mod, exp: Path, st: dict, t_name: str, locale: str, dt: str, files: list[Path]) -> str:
    key = f"{t_name}/{locale}/{dt}"
    if st.setdefault("sets", {}).get(key, {}).get("uploaded"):
        return f"{key}: skip"
    loc_id = st["treatments"][t_name]["localizations"][locale]
    sset = with_retry(mod.find_or_create_screenshot_set, hdr(mod), loc_id, DT_ASC[dt])
    cleared = with_retry(mod.clear_screenshots_in_set, hdr(mod), sset["id"])
    for f in files:
        with_retry(mod.upload_screenshot, hdr(mod), sset["id"], f)
    with _lock:
        st["sets"][key] = {"set_id": sset["id"], "uploaded": True, "n": len(files)}
    save_state(exp, st)
    return f"{key}: set {sset['id']} cleared {cleared}, uploaded {len(files)}"


def create_or_resume(mod, exp: Path, name: str | None, resume: bool) -> None:
    plan = plan_of(exp)
    total = sum(len(files) for t in plan.values() for loc in t.values() for files in loc.values())
    print(f"plan: {len(plan)} treatments, {len(next(iter(plan.values())))} locales, {total} PNGs", flush=True)
    st = load_state(exp)
    if not resume:
        blocking = [e for e in mod.list_existing_experiments(hdr(mod), APP_ID)
                    if e["attributes"].get("state") not in ("STOPPED", "COMPLETED")]
        if blocking:
            sys.exit("another experiment is not STOPPED — resolve first: " +
                     ", ".join(f"{e['attributes'].get('name')} [{e['attributes'].get('state')}]" for e in blocking))
        experiment = mod.create_experiment(hdr(mod), APP_ID, name)
        st = {"experiment_id": experiment["id"], "name": name, "created": time.strftime("%Y-%m-%d %H:%M"), "treatments": {}}
        save_state(exp, st)
        print(f"experiment {experiment['id']}", flush=True)
    jobs = []
    for t_name, per_locale in plan.items():
        if t_name not in st["treatments"]:
            tr = mod.create_treatment(hdr(mod), st["experiment_id"], t_name.split("_", 1)[1].replace("-", " "))
            st["treatments"][t_name] = {"id": tr["id"], "localizations": {}}
            save_state(exp, st)
        print(f"▸ {t_name} → {st['treatments'][t_name]['id']}", flush=True)
        ensure_localizations(mod, exp, st, t_name, list(per_locale))
        for locale, per_dt in per_locale.items():
            for dt, files in per_dt.items():
                if not st.get("sets", {}).get(f"{t_name}/{locale}/{dt}", {}).get("uploaded"):
                    jobs.append((t_name, locale, dt, files))
    print(f"{len(jobs)} sets to upload with {WORKERS} workers", flush=True)
    failures = []
    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futs = {pool.submit(upload_set, mod, exp, st, *job): job for job in jobs}
        for fut in as_completed(futs):
            job = futs[fut]
            try:
                print("   " + fut.result(), flush=True)
            except Exception as e:  # keep going; failed sets are retried on --resume
                failures.append(job)
                print(f"   FAILED {job[0]}/{job[1]}/{job[2]}: {e}", flush=True)
    if failures:
        print(f"{len(failures)} sets failed — rerun with --resume", flush=True)
    print("upload done — waiting 60s before the first verification pass", flush=True)
    time.sleep(60)
    verify(mod, exp)


def verify(mod, exp: Path) -> None:
    st = load_state(exp)
    plan = plan_of(exp)
    problems = []
    for key, s in st.get("sets", {}).items():
        t_name, locale, dt = key.split("/")
        note = with_retry(verify_set, mod, s["set_id"], plan[t_name][locale][dt])
        if note != "ok":
            problems.append(f"{key}: {note}")
    print(f"verified {len(st.get('sets', {}))} sets:", "ALL CLEAN" if not problems else "\n".join(problems), flush=True)
    st["last_verify"] = {"at": time.strftime("%Y-%m-%d %H:%M"), "problems": problems}
    save_state(exp, st)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("experiment")
    ap.add_argument("--name")
    ap.add_argument("--resume", action="store_true")
    ap.add_argument("--verify", action="store_true")
    args = ap.parse_args()
    exp = Path(args.experiment).resolve()
    mod = load_template()
    if args.verify:
        verify(mod, exp)
    elif args.resume:
        create_or_resume(mod, exp, None, True)
    else:
        if not args.name:
            sys.exit("--name required")
        create_or_resume(mod, exp, args.name, False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
