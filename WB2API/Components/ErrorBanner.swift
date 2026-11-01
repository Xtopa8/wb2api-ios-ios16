import SwiftUI

/// 错误条：图标 + 已清洗的短消息 + 重试。
struct ErrorBanner: View {
    let message: String
    var retry: () -> Void

    var body: some View {
        HStack(spacing: Metrics.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.primary)
                .lineLimit(2)
            Spacer(minLength: 0)
            Button("重试", action: retry)
                .font(.footnote.bold())
                .buttonStyle(.wbGlass)
        }
        .padding(Metrics.m)
        .wbGlassEffect(.regular.tint(.red.opacity(0.12)), in: .rect(cornerRadius: Metrics.radiusM))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
