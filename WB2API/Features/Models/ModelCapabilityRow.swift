import SwiftUI

/// 能力一行：左侧图标 + 名称，右侧支持/不支持的语义标记。
struct ModelCapabilityRow: View {
    let title: String
    let systemImage: String
    let isEnabled: Bool

    var body: some View {
        LabeledContent {
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "minus.circle")
                .foregroundStyle(isEnabled ? .green : .secondary)
        } label: {
            Label(title, systemImage: systemImage)
        }
        .font(.callout)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title)：\(isEnabled ? "支持" : "不支持")")
    }
}

#Preview {
    VStack(spacing: Metrics.s) {
        ModelCapabilityRow(title: "图像输入", systemImage: "photo", isEnabled: true)
        ModelCapabilityRow(title: "工具调用", systemImage: "wrench.and.screwdriver", isEnabled: false)
    }
    .padding()
}
