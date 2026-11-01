import SwiftUI

/// 模型探测原始结果：带折叠的等宽文本，支持长按选中复制。
struct ProbeResultView: View {
    let probes: JSONValue?

    @State private var isExpanded = false

    private static let foldLimit = 720

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.m) {
                if probes == nil {
                    LoadingSkeleton(rows: 4)
                } else if isEmptyProbe {
                    WBEmptyState(
                        "暂无探测记录",
                        systemImage: "waveform.path.ecg",
                        description: Text("面板尚未执行模型探测")
                    )
                    .padding(.vertical, Metrics.xl)
                } else if let text = probes?.prettyText {
                    SectionHeader(title: "探测原始结果", subtitle: "等宽文本，可长按选中复制")

                    Text(isExpanded ? text : Self.folded(text))
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard()
                        .motion(Motion.spring, value: isExpanded)

                    if text.count > Self.foldLimit {
                        Button(isExpanded ? "收起" : "展开全部", action: toggleExpanded)
                            .buttonStyle(.wbGlass)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(Metrics.m)
        }
    }

    /// `{"exists": false, "probes": {}}` 视为没有结果。
    private var isEmptyProbe: Bool {
        guard let object = probes?.objectValue else { return true }
        if object["exists"]?.boolValue == false { return true }
        if let inner = object["probes"]?.objectValue, inner.isEmpty { return true }
        return false
    }

    private func toggleExpanded() {
        isExpanded.toggle()
    }

    private static func folded(_ text: String) -> String {
        guard text.count > foldLimit else { return text }
        let end = text.index(text.startIndex, offsetBy: foldLimit)
        return String(text[..<end]) + "…"
    }
}
