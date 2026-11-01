import SwiftUI

/// 概览页头部：大标题 + 池子摘要 + 最近同步时间。
struct OverviewHeaderView: View {
    let digest: OverviewDigest?
    let lastUpdated: Date?
    let isRefreshing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.xs) {
            HStack(alignment: .center, spacing: Metrics.s) {
                Text("概览")
                    .font(.largeTitle.bold())

                Spacer(minLength: Metrics.s)

                if isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel("正在同步")
                }

                BrandMark(size: 26)
            }

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(Motion.numeric, value: summary)

            if let syncText {
                Label(syncText, systemImage: "clock")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(Motion.gentle, value: lastUpdated)
    }

    private var summary: String {
        guard let digest else {
            return isRefreshing ? "正在读取账号池…" : "账号池状态一览"
        }
        return "\(digest.total) 个账号 · \(digest.healthy) 个可用"
    }

    private var syncText: String? {
        guard let lastUpdated else { return nil }
        return "更新于 \(lastUpdated.formatted(date: .omitted, time: .standard))"
    }
}
