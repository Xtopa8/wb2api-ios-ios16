import SwiftUI

/// 状态标签：图标 + 文字，颜色只承担语义。
struct StatusTag: View {
    let text: String
    let systemImage: String
    var tint: Color = .secondary

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.tag)
            .foregroundStyle(tint)
            .padding(.horizontal, Metrics.s)
            .padding(.vertical, Metrics.xs)
            .wbGlassEffect(.regular.tint(tint.opacity(0.18)), in: .capsule)
    }
}
