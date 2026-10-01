#!/usr/bin/env python3
"""Submit the PPO experiment for App Review via API (LEARNING #39): reuse the
app's empty draft reviewSubmission if one exists, add the experiment as item,
PATCH submitted:true. Prints the resulting states."""
import sys, os, json
sys.path.insert(0, os.path.expanduser("~/Documents/GambitStudio/_GambitStudio/scripts/asc"))
import api_client as a
EXP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
st = json.load(open(os.path.join(EXP, "asc_state.json"))); eid = st["experiment_id"]; APP = "6502218501"
def must(r, w):
    if "_error" in r or "errors" in r: raise SystemExit(f"FAIL {w}: {r}")
    return r
rs = None
for r in must(a.request("GET", f"/v1/apps/{APP}/reviewSubmissions?limit=20&include=items&filter[platform]=IOS"), "list rs")["data"]:
    items = (r.get("relationships", {}).get("items", {}).get("data") or [])
    if r["attributes"].get("state") == "READY_FOR_REVIEW" and not items: rs = r["id"]; break
if not rs:
    rs = must(a.request("POST", "/v1/reviewSubmissions", {"data": {"type": "reviewSubmissions", "attributes": {"platform": "IOS"},
         "relationships": {"app": {"data": {"type": "apps", "id": APP}}}}}), "create rs")["data"]["id"]
item = must(a.request("POST", "/v1/reviewSubmissionItems", {"data": {"type": "reviewSubmissionItems", "relationships": {
    "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": rs}},
    "appStoreVersionExperiment": {"data": {"type": "appStoreVersionExperiments", "id": eid}}}}}), "add item")["data"]
sub = must(a.request("PATCH", f"/v1/reviewSubmissions/{rs}", {"data": {"type": "reviewSubmissions", "id": rs, "attributes": {"submitted": True}}}), "submit")["data"]
exp = must(a.request("GET", f"/v2/appStoreVersionExperiments/{eid}"), "get exp")["data"]
st["review_submission"] = rs; st["review_item"] = item["id"]; json.dump(st, open(os.path.join(EXP, "asc_state.json"), "w"), indent=1)
print(f"SUBMITTED rs={rs} rs_state={sub['attributes'].get('state')} experiment_state={exp['attributes'].get('state')}")
