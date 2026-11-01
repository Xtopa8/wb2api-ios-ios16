#!/usr/bin/env python3
"""拉取最近一次 CI 的 test.log，打印编译/测试错误。"""
import json, os, sys, urllib.request, zipfile, io

TOKEN = os.environ["GITHUB_TOKEN"]
REPO = "chenyynx/wb2api-ios"


def api(path):
    req = urllib.request.Request(f"https://api.github.com/repos/{REPO}{path}",
                                 headers={"Authorization": f"Bearer {TOKEN}",
                                          "Accept": "application/vnd.github+json"})
    return json.load(urllib.request.urlopen(req))


runs = api("/actions/runs?per_page=1")["workflow_runs"]
run = runs[0]
print("run:", run["id"], run["status"], run["conclusion"])
if run["status"] != "completed":
    print("仍在运行"); sys.exit(0)

arts = api(f"/actions/runs/{run['id']}/artifacts").get("artifacts", [])
target = next((a for a in arts if a["name"] in ("test-log", "build-log")), None)
if not target:
    print("无日志产物"); sys.exit(0)

req = urllib.request.Request(target["archive_download_url"],
                             headers={"Authorization": f"Bearer {TOKEN}"})
raw = urllib.request.urlopen(req).read()
z = zipfile.ZipFile(io.BytesIO(raw))
name = z.namelist()[0]
text = z.read(name).decode("utf-8", "replace")

lines = [l for l in text.splitlines() if "error:" in l or "failed:" in l]
seen = set()
for l in lines:
    l = l.split("/wb2api-ios/wb2api-ios/")[-1].strip()
    if l in seen:
        continue
    seen.add(l)
    print(" ", l[:220])
print("\n合计:", len(seen))
