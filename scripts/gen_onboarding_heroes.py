import base64
import json
import os
import sys
import urllib.request

KEY = None
with open(os.path.expanduser(
        "~/Documents/GambitStudio/_GambitStudio/keys/gemini.env")) as f:
    for line in f:
        if line.startswith("GEMINI_API_KEY="):
            KEY = line.strip().split("=", 1)[1]
assert KEY, "no key"

MODELS = ["gemini-2.5-flash-image", "gemini-3-pro-image-preview"]

STYLE = ("flat 2D vector illustration, flat colors only, palette: vivid blue #007AFF, "
         "light blue #5AC8FA, navy #0F2B50, white and soft gray accents, "
         "subject centered with generous margin, subject does not touch the edges, "
         "solid uniform pure white background, no gradients on background, "
         "no text, no words, no letters, no shadows. Subject: ")

SUBJECTS = {
    "hero_track": "a friendly open hand holding a coin above a simple minimalist wallet, a small plus symbol floating beside",
    "hero_charts": "a simple donut chart with three blue segments next to a small rising bar chart, minimal geometric shapes",
    "hero_goals": "a cute piggy bank with a target ring behind it and one coin dropping into the slot",
}

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)


def gen(model, prompt, path):
    url = (f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={KEY}")
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["IMAGE"]},
    }
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=180) as r:
        resp = json.load(r)
    for part in resp["candidates"][0]["content"]["parts"]:
        if "inlineData" in part:
            with open(path, "wb") as f:
                f.write(base64.b64decode(part["inlineData"]["data"]))
            return True
    return False


for name, subject in SUBJECTS.items():
    path = os.path.join(OUT, name + "_raw.png")
    done = False
    for model in MODELS:
        try:
            if gen(model, STYLE + subject, path):
                print(f"{name}: ok via {model}")
                done = True
                break
        except Exception as e:
            print(f"{name}: {model} failed: {e}")
    if not done:
        print(f"{name}: ALL MODELS FAILED")
        sys.exit(1)
