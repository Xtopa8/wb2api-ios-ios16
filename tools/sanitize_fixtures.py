"""把真实接口响应脱敏成测试夹具：替换 uid / 昵称 / 密钥 / 域名。"""
import json, glob, os, re, hashlib

SRC = "/var/minis/shared/wb2api-ios/WB2APITests/Fixtures"
MAP = {}

def fake_uid(u):
    if not u: return u
    if u not in MAP:
        h = hashlib.sha256(u.encode()).hexdigest()
        MAP[u] = f"{h[0:8]}-{h[8:12]}-4{h[13:16]}-8{h[17:20]}-{h[20:32]}"
    return MAP[u]

def fake_name(n):
    if not n: return n
    if n not in MAP:
        MAP[n] = f"账号{len([k for k in MAP if k.startswith('账号')]) + 1}"
    return MAP[n]

def scrub(obj):
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            if k in ("api_key", "accessToken", "refreshToken", "device_token", "token"):
                out[k] = "REDACTED"
            elif k == "uid":
                out[k] = fake_uid(v) if isinstance(v, str) else v
            elif k in ("nickname", "name", "account", "nick"):
                out[k] = fake_name(v) if isinstance(v, str) else v
            elif k == "path":
                out[k] = "config.json"
            else:
                out[k] = scrub(v)
        return out
    if isinstance(obj, list):
        return [scrub(x) for x in obj]
    if isinstance(obj, str):
        # 域名与手机号/邮箱打码
        s = re.sub(r"1[3-9]\d{9}", "账号01", obj)
        s = re.sub(r"[\w.+-]+@[\w.-]+\.\w+", "user@example.com", s)
        s = s.replace("example.com", "example.com")
        return s
    return obj

for path in sorted(glob.glob(os.path.join(SRC, "*.json"))):
    try:
        data = json.load(open(path, encoding="utf-8"))
    except Exception as e:
        print("skip", path, e); continue
    cleaned = scrub(data)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(cleaned, f, ensure_ascii=False, indent=1)
    print("脱敏", os.path.basename(path), os.path.getsize(path), "B")
