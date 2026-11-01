import SwiftUI

/// 错误分组卡：类型 + 状态码 + 次数 + 账号/时间 + 样例行。
struct ErrorRowView: View {
    let row: ErrorRow

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            HStack(alignment: .firstTextBaseline, spacing: Metrics.s) {
                Text(row.kind ?? "未归类")
                    .font(.callout.bold())
                    .lineLimit(1)

                if let code = row.code, !code.isEmpty {
                    Text(code)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, Metrics.s)
                        .padding(.vertical, Metrics.xs / 2)
                        .background(.quaternary, in: .capsule)
                }

                Spacer(minLength: Metrics.xs)

                Text("\(row.count ?? 0)")
                    .font(.metricSmall())
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                Text("次")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: Metrics.m) {
                if let account = row.account, !account.isEmpty {
                    Label(account, systemImage: "person")
                }
                if let last = row.last, !last.isEmpty {
                    Label(last, systemImage: "clock")
                }
                if let until = row.until, !until.isEmpty,
                   let left = Fmt.countdown(until: until) {
                    Label("\(left)后恢复", systemImage: "hourglass")
                        .foregroundStyle(.orange)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)

            if let sample = sampleText {
                Text(sample)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Metrics.radiusM)
    }

    private var sampleText: String? {
        [row.sampleFull, row.sample]
            .compactMap { $0 }
            .first { !$0.isEmpty }
    }

    private var tint: Color {
        switch row.sev ?? "" {
        case "bad": return .red
        case "warn": return .orange
        default: return .secondary
        }
    }
}
