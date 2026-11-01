import SwiftUI

/// 「数据」页底部：积分历史与余额趋势的入口卡片。
struct DataHistoryLinks: View {
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(value: DataRoute.creditHistory) {
                DataHistoryRow(
                    title: "积分历史",
                    subtitle: "逐条消耗明细",
                    systemImage: "creditcard"
                )
            }

            Divider()
                .padding(.leading, Metrics.m + Metrics.l)

            NavigationLink(value: DataRoute.balanceHistory) {
                DataHistoryRow(
                    title: "余额趋势",
                    subtitle: "7 / 14 / 30 天折线",
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            }
        }
        .glassCard(padding: 0, cornerRadius: Metrics.radiusL)
    }
}
