#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Rollback do deploy do iter-04 (2026-10-01).

Dois niveis. Enquanto a 45.4.0 NAO estiver submetida/aprovada, nada disso e
urgente: o publico ve a 45.3.1, que nunca foi tocada.

  --level version   DELETE da versao 45.4.0 inteira. E o rollback completo e
                    limpo: some o portador do texto novo. So funciona enquanto
                    ela estiver PREPARE_FOR_SUBMISSION.
  --level fields    PATCH de name/subtitle/keywords/description de volta para
                    aso-pipeline/current/metadata/ (= o que esta NO AR na
                    45.3.1), mantendo a versao 45.4.0 de pe.

  --dry-run         mostra o que faria, sem escrever.

    python3 rollback.py --level fields --dry-run
"""
import argparse, json, os, sys, time
import urllib.request, urllib.error
import jwt

ISSUER = "98c49316-b223-4d64-955d-b55ae76ab9d2"
KID = "67JG58Q6XH"
KEY = open(os.path.expanduser("~/Documents/GambitStudio/_GambitStudio/keys/asc_api_key.p8")).read()
VERSION_ID = "61e6fb32-27fc-41d2-aa6f-4cdb75e19a99"   # 45.4.0 IOS
APPINFO_ID = "cbd87354-2689-488b-8ebf-90570f942631"   # editavel
CURRENT = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "..", "..", "current", "metadata")


def req(method, path, body=None):
    tok = jwt.encode({"iss": ISSUER, "iat": int(time.time()),
                      "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"},
                     KEY, algorithm="ES256", headers={"kid": KID, "typ": "JWT"})
    r = urllib.request.Request("https://api.appstoreconnect.apple.com" + path,
                               data=json.dumps(body).encode() if body else None,
                               method=method,
                               headers={"Authorization": "Bearer " + tok,
                                        "Content-Type": "application/json"})
    try:
        raw = urllib.request.urlopen(r).read()
        return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        return {"_error": e.read().decode()[:500], "_status": e.code}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--level", choices=["version", "fields"], required=True)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    if a.level == "version":
        print(f"DELETE /v1/appStoreVersions/{VERSION_ID}  (45.4.0 IOS)")
        if a.dry_run:
            return 0
        print(req("DELETE", f"/v1/appStoreVersions/{VERSION_ID}") or "204 OK")
        return 0

    vl = {d["attributes"]["locale"]: d["id"] for d in
          req("GET", f"/v1/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations?limit=200")["data"]}
    il = {d["attributes"]["locale"]: d["id"] for d in
          req("GET", f"/v1/appInfos/{APPINFO_ID}/appInfoLocalizations?limit=200")["data"]}

    for loc in sorted(vl):
        d = os.path.join(CURRENT, loc)
        if not os.path.isdir(d):
            print(f"  skip {loc}: sem current/metadata/{loc}")
            continue
        rd = lambda f: open(os.path.join(d, f), encoding="utf-8").read().strip("\n")
        v_attrs = {"keywords": rd("keywords.txt"), "description": rd("description.txt")}
        i_attrs = {"name": rd("name.txt"), "subtitle": rd("subtitle.txt")}
        print(f"  {loc}: keywords/description -> {vl[loc]} ; name/subtitle -> {il[loc]}")
        if a.dry_run:
            continue
        print("   ", req("PATCH", f"/v1/appStoreVersionLocalizations/{vl[loc]}",
                         {"data": {"type": "appStoreVersionLocalizations",
                                   "id": vl[loc], "attributes": v_attrs}}).get("_error", "ok"))
        print("   ", req("PATCH", f"/v1/appInfoLocalizations/{il[loc]}",
                         {"data": {"type": "appInfoLocalizations",
                                   "id": il[loc], "attributes": i_attrs}}).get("_error", "ok"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
