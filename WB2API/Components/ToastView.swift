import SwiftUI

struct Toast: Identifiable, Equatable {
    enum Kind { case success, failure, info }
    let id = UUID()
    let kind: Kind
    let text: String
}

/// 顶部轻提示：玻璃胶囊 + 触感。
struct ToastOverlay: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    Label(toast.text, systemImage: icon(for: toast.kind))
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, Metrics.m)
                        .padding(.vertical, Metrics.s + 2)
                        .wbGlassEffect(.regular.interactive(), in: .capsule)
                        .padding(.top, Metrics.s)
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                        .task(id: toast.id) {
                            try? await Task.sleep(for: .seconds(2.2))
                            withAnimation(Animation.snappy) { self.toast = nil }
                        }
                }
            }
            .animation(Animation.snappy, value: toast?.id)
            .sensoryFeedbackCompat(.success, trigger: toast?.id)
    }

    private func icon(for kind: Toast.Kind) -> String {
        switch kind {
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.octagon.fill"
        case .info: return "info.circle.fill"
        }
    }
}

extension View {
    func toast(_ binding: Binding<Toast?>) -> some View {
        modifier(ToastOverlay(toast: binding))
    }
}
