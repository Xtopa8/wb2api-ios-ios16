import SwiftUI

/// 玻璃按钮内的动作标签：空闲时显示图标，执行中换成小型进度环。
struct QueueActionLabel: View {
    let title: String
    let systemImage: String
    let isBusy: Bool

    var body: some View {
        HStack(spacing: Metrics.s) {
            if isBusy {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: systemImage)
            }
            Text(title)
        }
        .font(.body.bold())
        .frame(maxWidth: .infinity, minHeight: Metrics.minTap)
    }
}
