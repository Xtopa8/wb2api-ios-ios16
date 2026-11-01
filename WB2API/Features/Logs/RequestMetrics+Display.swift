import Foundation

/// 请求指标的展示派生值。
extension RequestMetrics {
    var completedLabel: String { Fmt.compact(completed) }
    var succeededLabel: String { Fmt.compact(succeeded) }
    var failedLabel: String { Fmt.compact(failed) }
    var inFlightLabel: String { Fmt.compact(inFlight) }
    var avgDurationLabel: String { Fmt.latency(avgDurationMs) }
    var startedAtLabel: String { "开始于 " + Fmt.ago(startedAt) }

    /// 后端给的是 0–100 的百分数（实测 35.3），不是 0–1 的比例。
    var successRateLabel: String { Self.percentLabel(successRate) }
    var httpSuccessRateLabel: String { Self.percentLabel(httpSuccessRate) }

    private static func percentLabel(_ value: Double?) -> String {
        guard let value else { return "—" }
        return (value / 100).formatted(.percent.precision(.fractionLength(0...1)))
    }
}
