"""给账号状态加 model_off 字段（面板/客户端可读每账号手动关闭的模型）。"""
import re

ENTRY = "/home/ubuntu/work/doris/wb-eval/merged/internal/pool/entry.go"
STATE = "/home/ubuntu/work/doris/wb-eval/merged/internal/pool/state.go"

s = open(ENTRY, encoding="utf-8").read()
if "ModelOff []ModelOffEntry" in s:
    print("entry.go 已有字段，跳过")
else:
    anchor = '\tRateLimitedModels []RateLimitedModel `json:"rate_limited_models,omitempty"`'
    assert anchor in s, "锚点缺失"
    s = s.replace(
        anchor,
        anchor
        + '\n\t// ModelOff 手动关闭的 (账号, 模型) 组合（面板「模型开关」回显用）。\n'
        + '\tModelOff []ModelOffEntry `json:"model_off,omitempty"`',
        1,
    )
    open(ENTRY, "w", encoding="utf-8").write(s)
    print("entry.go 字段已加")

s = open(STATE, encoding="utf-8").read()
if "ModelOff:  modelOffLocked(e)," in s:
    print("state.go 已填充，跳过")
else:
    anchor = "\t\tRateLimitedModels:        p.rateLimitedModelsLocked(e, now),"
    assert anchor in s, "填充锚点缺失"
    s = s.replace(anchor, anchor + "\n\t\tModelOff:                 modelOffLocked(e),", 1)

    helper = '''
// modelOffLocked 返回账号手动关闭的模型清单（调用方需持锁）。
// 与 ModelOffOf 同口径，区别是不再取锁——statusOf 已在读锁内。
func modelOffLocked(e *entry) []ModelOffEntry {
	if e == nil || len(e.modelOff) == 0 {
		return nil
	}
	out := make([]ModelOffEntry, 0, len(e.modelOff))
	for m, o := range e.modelOff {
		out = append(out, ModelOffEntry{Model: m, Since: o.Since.Format("01-02 15:04"), Note: o.Note})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Model < out[j].Model })
	return out
}
'''
    s = s.rstrip() + "\n" + helper
    open(STATE, "w", encoding="utf-8").write(s)
    print("state.go 填充与辅助函数已加")
