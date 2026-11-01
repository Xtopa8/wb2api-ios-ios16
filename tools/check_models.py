"""把 Swift 模型定义与真实接口夹具做一次类型对拍，提前发现解码崩溃点。"""
import json, re, os

MODELS = "/var/minis/shared/wb2api-ios/WB2API/Core/Models.swift"
FIX = "/var/minis/shared/wb2api-ios/WB2APITests/Fixtures"


def parse_structs(path):
    src = open(path, encoding="utf-8").read()
    out = {}
    for m in re.finditer(r"struct (\w+)[^{]*\{(.*?)\n\}", src, re.S):
        name, body = m.group(1), m.group(2)
        fields = {}
        for f in re.finditer(r"^\s{4}let (\w+): ([^\n]+)$", body, re.M):
            fields[f.group(1)] = f.group(2).strip()
        out[name] = fields
    return out


STRUCTS = parse_structs(MODELS)


def snake(name):
    s = re.sub(r"(?<!^)(?=[A-Z])", "_", name).lower()
    # 处理 1m 之类：creditsPer1mTokens -> credits_per_1m_tokens
    s = re.sub(r"_(\d)", r"_\1", s)
    return s


def check_type(swift_type, value, path, errs):
    t = swift_type.strip()
    optional = t.endswith("?")
    if optional:
        t = t[:-1].strip()
        if value is None:
            return
    if t.startswith("[") and t.endswith("]"):
        if not isinstance(value, list):
            errs.append(f"{path}: 期望数组，实际 {type(value).__name__}")
            return
        inner = t[1:-1].strip().rstrip("?")
        if inner in STRUCTS:
            for i, item in enumerate(value[:3]):
                check_type(inner, item, f"{path}[{i}]", errs)
        return
    base = {"Int": int, "Double": float, "String": str, "Bool": bool}
    if t in ("Int",):
        if isinstance(value, bool) or not isinstance(value, int):
            errs.append(f"{path}: 期望 Int，实际 {type(value).__name__} = {value!r}")
    elif t == "Double":
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            errs.append(f"{path}: 期望 Double，实际 {type(value).__name__} = {value!r}")
    elif t == "String":
        if not isinstance(value, str):
            errs.append(f"{path}: 期望 String，实际 {type(value).__name__} = {value!r}")
    elif t == "Bool":
        if not isinstance(value, bool):
            errs.append(f"{path}: 期望 Bool，实际 {type(value).__name__} = {value!r}")
    elif t == "JSONValue":
        pass
    elif t in STRUCTS:
        if not isinstance(value, dict):
            errs.append(f"{path}: 期望对象，实际 {type(value).__name__}")
            return
        check_object(t, value, path, errs)


def check_object(struct_name, obj, path, errs):
    fields = STRUCTS.get(struct_name)
    if fields is None:
        return
    for swift_field, swift_type in fields.items():
        key = snake(swift_field)
        if key not in obj:
            if not swift_type.endswith("?"):
                errs.append(f"{path}.{key}: 模型要求必填但 JSON 缺失（字段 {swift_field}）")
            continue
        check_type(swift_type, obj[key], f"{path}.{key}", errs)


CHECKS = [
    ("StatusResponse", "status.json", []),
    ("OverviewResponse", "overview.json", []),
    ("ModelsResponse", "models.json", []),
    ("LogsResponse", "logs.json", []),
    ("UsageSnapshot", "usage.json", []),
    ("BalanceHistory", "balance_history.json", []),
    ("PackagesResponse", "packages.json", []),
    ("ErrorSummary", "error_summary.json", []),
    ("TaskQueue", "tasks_queue.json", []),
    ("RequestMetrics", "request_metrics.json", []),
    ("CreditHistory", "credit_history.json", []),
]

errors = []
for struct_name, fixture, _ in CHECKS:
    path = os.path.join(FIX, fixture)
    if not os.path.exists(path):
        continue
    data = json.load(open(path, encoding="utf-8"))
    before = len(errors)
    check_object(struct_name, data, fixture, errors)
    added = len(errors) - before
    print(f"{fixture:<26} {struct_name:<18} {'OK' if added == 0 else str(added) + ' 处不匹配'}")

print("\n=== 明细 ===")
for e in errors[:40]:
    print(" ", e)
print("\n合计:", len(errors))
