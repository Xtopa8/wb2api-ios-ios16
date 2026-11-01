import SwiftUI

/// 单条任务作业：玻璃卡 + 滚动入场，嵌套结构折叠成等宽详情。
struct JobCardView: View {
    let entry: JobEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            Text(entry.title)
                .font(.callout.bold())
                .lineLimit(2)

            if let subtitle = entry.subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            if !entry.fields.isEmpty {
                Divider()
                VStack(spacing: Metrics.xs) {
                    ForEach(entry.fields.indices, id: \.self) { index in
                        LabeledContent {
                            Text(entry.fields[index].value)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.trailing)
                        } label: {
                            Text(entry.fields[index].key)
                        }
                    }
                }
                .font(.footnote)
            }

            if let detail = entry.detail {
                Text(detail)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(6)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Metrics.radiusM)
    }
}
