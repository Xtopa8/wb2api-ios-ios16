import SwiftUI

/// 详情里的「标签 — 数值」行：`LabeledContent` + 可选图标，数字带滚动过渡。
struct DetailRow: View {
    private let title: String
    private let systemImage: String?
    private let value: String

    init(_ title: String, systemImage: String? = nil, value: String) {
        self.title = title
        self.systemImage = systemImage
        self.value = value
    }

    var body: some View {
        LabeledContent {
            Text(value)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .contentTransition(.numericText())
        } label: {
            if let systemImage {
                Label(title, systemImage: systemImage)
                    .foregroundStyle(.secondary)
            } else {
                Text(title)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .animation(Motion.numeric, value: value)
    }
}
