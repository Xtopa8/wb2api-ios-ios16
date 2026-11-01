import SwiftUI

/// 单个礼包：名称 + 剩余 / 已用 / 总量 + 水位条。
struct PackageRowView: View {
    let item: PackageItem

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            Label(item.name ?? "未命名礼包", systemImage: "shippingbox.fill")

            HStack(spacing: Metrics.m) {
                Text("剩余 \(item.remain ?? 0)")
                Text("已用 \(item.used ?? 0)")
                Text("总量 \(item.size ?? 0)")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .monospacedDigit()

            CreditBar(progress: progress)

            if let expiry = item.endTime, !expiry.isEmpty {
                Label("到期 \(expiry)", systemImage: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, Metrics.xs)
        .frame(minHeight: Metrics.minTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name ?? "未命名礼包")，剩余 \(item.remain ?? 0)，总量 \(item.size ?? 0)")
    }

    private var progress: Double {
        guard let size = item.size, size > 0, let remain = item.remain else { return 0 }
        return min(max(Double(remain) / Double(size), 0), 1)
    }
}
