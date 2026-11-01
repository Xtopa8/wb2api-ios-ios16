import SwiftUI

/// 用量卡：请求、token 与最近一次调用的表现。
struct UsageCard: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            Text("用量")
                .font(.tag)
                .foregroundStyle(.secondary)

            if let usage = account.tokenUsage {
                DetailRow("请求次数", value: Fmt.compact(usage.requestCount))
                DetailRow("有效用量", value: Fmt.compact(usage.usageCount))
                DetailRow("输入 tokens", value: Fmt.compact(usage.promptTokens))
                DetailRow("输出 tokens", value: Fmt.compact(usage.completionTokens))
                DetailRow("合计 tokens", value: Fmt.compact(usage.totalTokens))

                Divider()

                DetailRow("最近延迟", value: Fmt.latency(usage.lastLatencyMs.map { Double($0) }))
                DetailRow("生成速度", value: speedText(usage.lastTokensPerSecond))
                DetailRow("最近模型", value: usage.lastModel ?? "—")
                DetailRow("最近使用", value: Fmt.ago(usage.lastUsedAt))
            } else {
                Label("还没有用量记录", systemImage: "tray")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
        .glassCard()
    }

    private func speedText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.1f tok/s", value)
    }
}
