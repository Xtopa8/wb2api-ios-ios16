import SwiftUI

/// 指标块：标签 + 大号等宽数字，玻璃底。
struct StatTile: View {
    let title: String
    let value: String
    var caption: String?
    var tint: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.xs) {
            Text(title)
                .font(.tag)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.metricSmall())
                .foregroundStyle(tint)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            if let caption {
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: Metrics.m, cornerRadius: Metrics.radiusM)
    }
}
