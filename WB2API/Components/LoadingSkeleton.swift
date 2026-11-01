import SwiftUI

/// 骨架屏：占位红acted + 呼吸动画（Reduce Motion 下静止）。
struct LoadingSkeleton: View {
    var rows: Int = 4
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    var body: some View {
        VStack(spacing: Metrics.s) {
            ForEach(0..<rows, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Metrics.radiusM)
                    .fill(.quaternary)
                    .frame(height: 64)
            }
        }
        .redacted(reason: .placeholder)
        .opacity(pulsing ? 0.55 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulsing)
        .onAppear { pulsing = true }
        .accessibilityLabel("加载中")
    }
}
