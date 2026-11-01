import SwiftUI

/// 请求流水的一行：状态码 + 模型 + 耗时 + 账号/用量。
struct RequestLogRowView: View {
    let row: RequestLogRow

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.xs) {
            HStack(alignment: .firstTextBaseline, spacing: Metrics.s) {
                Text(statusText)
                    .font(.footnote.monospacedDigit().bold())
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                if let outcome = row.outcome {
                    Text(outcome)
                        .font(.tag)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: Metrics.xs)
                Text(Fmt.latency(row.durationMs))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Text(row.model ?? "未知模型")
                .font(.callout.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            HStack(spacing: Metrics.m) {
                Label(row.account ?? "—", systemImage: "person")
                if let tokens = row.totalTokens, tokens > 0 {
                    Label("\(Fmt.compact(tokens)) tok", systemImage: "text.word.spacing")
                }
                if let attempts = row.attempts, attempts > 1 {
                    Label("\(attempts) 次", systemImage: "arrow.clockwise")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)

            Text(row.path ?? "—")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Metrics.radiusM)
    }

    private var statusText: String {
        row.status.map { String($0) } ?? (row.isOK ? "OK" : "ERR")
    }

    private var tint: Color {
        if row.isOK { return .green }
        return (row.status ?? 500) >= 500 ? .red : .orange
    }
}

#Preview {
    RequestLogRowView(row: RequestLogRow(index: 0, value: .object([
        "status": .int(503),
        "model": .string("cn:glm-5.3-flash"),
        "account": .string("账号1"),
        "path": .string("config.json"),
        "duration_ms": .double(19_658),
        "attempts": .int(2),
        "total_tokens": .int(101_872),
        "outcome": .string("interrupted")
    ])))
    .padding()
}
