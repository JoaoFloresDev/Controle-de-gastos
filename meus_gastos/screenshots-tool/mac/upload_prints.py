#!/usr/bin/env python3
"""Uploads the Mac App Store screenshots of a version, reconciled by checksum.

A version created by the API inherits the previous version's sets WITH the old
screenshots cloned inside (LEARNINGS #26/#35/#73), so the job is: prune what is
not ours, upload only what is missing, then PATCH the 01..05 order.

    python3 upload_prints.py <appStoreVersionId> <locale>=<dir> [<locale>=<dir> ...]
"""
import hashlib, json, os, sys, urllib.request

sys.path.insert(0, os.path.expanduser(
    "~/Documents/GambitStudio/_GambitStudio/scripts/asc"))
import api_client as a  # noqa: E402

DISPLAY_TYPE = "APP_DESKTOP"


def md5(path):
    h = hashlib.md5()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def localization_id(version_id, locale):
    r = a.request("GET", "/v1/appStoreVersions/%s/appStoreVersionLocalizations?limit=50"
                  % version_id)
    for loc in r.get("data", []):
        if loc["attributes"]["locale"] == locale:
            return loc["id"]
    raise SystemExit("locale %s não existe na versão" % locale)


def screenshot_set(loc_id):
    r = a.request("GET", "/v1/appStoreVersionLocalizations/%s/appScreenshotSets" % loc_id)
    for s in r.get("data", []):
        if s["attributes"]["screenshotDisplayType"] == DISPLAY_TYPE:
            return s["id"]
    created = a.request("POST", "/v1/appScreenshotSets", {
        "data": {"type": "appScreenshotSets",
                 "attributes": {"screenshotDisplayType": DISPLAY_TYPE},
                 "relationships": {"appStoreVersionLocalization": {
                     "data": {"type": "appStoreVersionLocalizations", "id": loc_id}}}}})
    return created["data"]["id"]


def upload_one(set_id, path):
    size = os.path.getsize(path)
    reserved = a.request("POST", "/v1/appScreenshots", {
        "data": {"type": "appScreenshots",
                 "attributes": {"fileSize": size, "fileName": os.path.basename(path)},
                 "relationships": {"appScreenshotSet": {
                     "data": {"type": "appScreenshotSets", "id": set_id}}}}})
    shot_id = reserved["data"]["id"]
    ops = reserved["data"]["attributes"]["uploadOperations"]
    with open(path, "rb") as fh:
        blob = fh.read()
    for op in ops:
        chunk = blob[op["offset"]:op["offset"] + op["length"]]
        req = urllib.request.Request(op["url"], data=chunk, method=op["method"])
        for header in op["requestHeaders"]:
            req.add_header(header["name"], header["value"])
        urllib.request.urlopen(req).read()
    a.request("PATCH", "/v1/appScreenshots/%s" % shot_id, {
        "data": {"type": "appScreenshots", "id": shot_id,
                 "attributes": {"uploaded": True, "sourceFileChecksum": md5(path)}}})
    return shot_id


def sync(version_id, locale, folder):
    files = sorted(f for f in os.listdir(folder) if f.endswith(".png"))
    if not files:
        raise SystemExit("nenhum png em %s" % folder)
    wanted = [(f, md5(os.path.join(folder, f))) for f in files]

    loc_id = localization_id(version_id, locale)
    set_id = screenshot_set(loc_id)
    existing = a.request("GET", "/v1/appScreenshotSets/%s/appScreenshots?limit=20" % set_id)

    by_checksum = {}
    for shot in existing.get("data", []):
        checksum = shot["attributes"].get("sourceFileChecksum")
        if checksum in dict(wanted).values() and checksum not in by_checksum:
            by_checksum[checksum] = shot["id"]
        else:
            a.request("DELETE", "/v1/appScreenshots/%s" % shot["id"])

    ordered = []
    for name, checksum in wanted:
        shot_id = by_checksum.get(checksum)
        if shot_id is None:
            shot_id = upload_one(set_id, os.path.join(folder, name))
        ordered.append(shot_id)

    a.request("PATCH", "/v1/appScreenshotSets/%s/relationships/appScreenshots" % set_id,
              {"data": [{"type": "appScreenshots", "id": i} for i in ordered]})
    return set_id, ordered


def main():
    version_id = sys.argv[1]
    for arg in sys.argv[2:]:
        locale, folder = arg.split("=", 1)
        set_id, ordered = sync(version_id, locale, folder)
        print("%s: set %s com %d prints" % (locale, set_id, len(ordered)))


if __name__ == "__main__":
    main()
