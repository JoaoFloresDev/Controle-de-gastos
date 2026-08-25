#!/usr/bin/env python3
"""Create App Store localizations for locales the listing does not carry yet.

Reads <dir>/<locale>/{name,subtitle,keywords,description,promotional_text,
release_notes}.txt and POSTs two records per locale:
  - appInfoLocalization        (name, subtitle)  -> the editable appInfo
  - appStoreVersionLocalization (keywords, description, promo, whatsNew,
                                 support/marketing url) -> the editable version

Read-back is mandatory: every field is fetched again after the POST and diffed,
because the ASC API accepts writes it silently drops (LEARNINGS #13/#26/#27).

Dry-run by default. Pass --apply to actually write.
"""
import argparse
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path.home() /
                       "Documents/GambitStudio/_GambitStudio/scripts/asc"))
from api_client import request  # noqa: E402

APP_ID = "6502218501"
SUPPORT_URL = "https://www.facebook.com/GambitStudioTech"
MARKETING_URL = "https://gambitstudiotech.com/"

VERSION_FIELDS = {
    "keywords": "keywords.txt",
    "description": "description.txt",
    "promotionalText": "promotional_text.txt",
    "whatsNew": "release_notes.txt",
}


def editable_ids() -> tuple:
    """The appInfo and appStoreVersion that accept writes."""
    info_id = ver_id = None
    for inf in request("GET", f"/v1/apps/{APP_ID}/appInfos")["data"]:
        if inf["attributes"].get("appStoreState") != "READY_FOR_SALE":
            info_id = inf["id"]
    for ver in request("GET", f"/v1/apps/{APP_ID}/appStoreVersions?limit=10")["data"]:
        if ver["attributes"].get("appStoreState") not in ("READY_FOR_SALE",):
            ver_id = ver["id"]
            break
    return info_id, ver_id


def existing_locales(info_id: str, ver_id: str) -> tuple:
    info = {l["attributes"]["locale"]: l["id"] for l in request(
        "GET", f"/v1/appInfos/{info_id}/appInfoLocalizations?limit=50")["data"]}
    ver = {l["attributes"]["locale"]: l["id"] for l in request(
        "GET", f"/v1/appStoreVersions/{ver_id}/appStoreVersionLocalizations?limit=50"
    )["data"]}
    return info, ver


def read_locale(src: pathlib.Path) -> dict:
    out = {}
    for name in ("name", "subtitle", "keywords", "description",
                 "promotional_text", "release_notes"):
        f = src / f"{name}.txt"
        out[name] = f.read_text().strip() if f.exists() else ""
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=str(pathlib.Path(__file__).resolve().parent.parent
                                         / "new_locales_2026-08-25"))
    ap.add_argument("--locales", default="")
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()

    root = pathlib.Path(args.dir)
    info_id, ver_id = editable_ids()
    if not info_id or not ver_id:
        sys.exit("no editable appInfo/appStoreVersion found")
    have_info, have_ver = existing_locales(info_id, ver_id)
    print(f"editable appInfo={info_id} version={ver_id}")
    print(f"store already carries {len(have_info)} locales\n")

    wanted = args.locales.split(",") if args.locales else sorted(
        p.name for p in root.iterdir() if p.is_dir())

    for loc in wanted:
        src = root / loc
        if not (src / "keywords.txt").exists():
            print(f"{loc}: no files, skipped")
            continue
        data = read_locale(src)
        if loc in have_info or loc in have_ver:
            print(f"{loc}: already on the store, skipped")
            continue
        if not args.apply:
            print(f"{loc}: DRY-RUN name={len(data['name'])} "
                  f"subtitle={len(data['subtitle'])} "
                  f"keywords={len(data['keywords'])} "
                  f"desc={len(data['description'])}")
            continue

        request("POST", "/v1/appInfoLocalizations", {"data": {
            "type": "appInfoLocalizations",
            "attributes": {"locale": loc, "name": data["name"],
                           "subtitle": data["subtitle"]},
            "relationships": {"appInfo": {"data": {
                "type": "appInfos", "id": info_id}}}}})
        request("POST", "/v1/appStoreVersionLocalizations", {"data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": loc,
                "keywords": data["keywords"],
                "description": data["description"],
                "promotionalText": data["promotional_text"],
                "whatsNew": data["release_notes"],
                "supportUrl": SUPPORT_URL,
                "marketingUrl": MARKETING_URL},
            "relationships": {"appStoreVersion": {"data": {
                "type": "appStoreVersions", "id": ver_id}}}}})

        back_info, back_ver = existing_locales(info_id, ver_id)
        bad = []
        if loc in back_info:
            got = request("GET", f"/v1/appInfoLocalizations/{back_info[loc]}"
                          )["data"]["attributes"]
            for k, want in (("name", data["name"]), ("subtitle", data["subtitle"])):
                if (got.get(k) or "") != want:
                    bad.append(k)
        else:
            bad.append("appInfoLocalization missing")
        if loc in back_ver:
            got = request("GET", f"/v1/appStoreVersionLocalizations/{back_ver[loc]}"
                          )["data"]["attributes"]
            for api_key, path in VERSION_FIELDS.items():
                want = data[path.replace(".txt", "")]
                if (got.get(api_key) or "") != want:
                    bad.append(api_key)
        else:
            bad.append("appStoreVersionLocalization missing")

        print(f"{loc}: {'OK' if not bad else 'MISMATCH after read-back: ' + ', '.join(bad)}")


if __name__ == "__main__":
    main()
