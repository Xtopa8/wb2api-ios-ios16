import Charts
import SwiftUI

/// 多账号余额折线图。
struct BalanceLineChart: View {
    let series: [BalanceSeries]

    private var plottable: [BalanceSeries] {
        series.filter { !($0.points ?? []).isEmpty }
    }

    var body: some View {
        if plottable.isEmpty {
            WBEmptyState {
                Label("暂无余额曲线", systemImage: "chart.xyaxis.line")
            } description: {
                Text("面板还没有攒够余额快照。")
            }
            .frame(height: 220)
        } else {
            Chart {
                ForEach(plottable) { item in
                    ForEach(item.points ?? []) { point in
                        if let date = point.date {
                            LineMark(
                                x: .value("时间", date),
                                y: .value("积分", point.c ?? 0)
                            )
                            .foregroundStyle(by: .value("账号", name(for: item)))
                            .interpolationMethod(.monotone)
                            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                        }
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .leading, spacing: Metrics.s)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .frame(height: 220)
            .animation(Motion.numeric, value: plottable.map(\.id))
            .accessibilityLabel("余额趋势折线图")
        }
    }

    private func name(for item: BalanceSeries) -> String {
        if let name = item.name, !name.isEmpty { return name }
        if let uid = item.uid, !uid.isEmpty { return String(uid.prefix(8)) }
        return "未知账号"
    }
}

extension BalancePoint {
    /// 余额快照时间戳（秒，兼容毫秒）转 `Date`。
    var date: Date? {
        guard let t, t > 0 else { return nil }
        let seconds = t > 1_000_000_000_000 ? Double(t) / 1000 : Double(t)
        return Date(timeIntervalSince1970: seconds)
    }
}
