import SwiftUI
import UIKit
import Combine

// MARK: - iOS 16.3 兼容层
//
// 上游按 iOS 26 编写：Liquid Glass（glassEffect / .glass 按钮）、
// ContentUnavailableView、双参数 onChange、sensoryFeedback、@Observable
// 全是 iOS 17/18/26 的 API。这里用改名的同签名垫片
// （wbGlassEffect / wbGlass 按钮样式 / WBEmptyState / onChangeCompat /
//  sensoryFeedbackCompat），调用点只改名字不改结构。

// MARK: 玻璃效果（Liquid Glass → ultraThinMaterial + 描边）

struct WBGlassStyle {
    var tintColor: Color?
    var isInteractive = false

    static var regular: WBGlassStyle { WBGlassStyle() }

    func interactive() -> WBGlassStyle {
        var copy = self
        copy.isInteractive = true
        return copy
    }

    func tint(_ color: Color) -> WBGlassStyle {
        var copy = self
        copy.tintColor = color
        return copy
    }
}

struct WBGlassShape {
    enum Kind {
        case capsule
        case circle
        case rect(CGFloat)
    }

    var kind: Kind

    static var capsule: WBGlassShape { WBGlassShape(kind: .capsule) }
    static var circle: WBGlassShape { WBGlassShape(kind: .circle) }
    static func rect(cornerRadius: CGFloat) -> WBGlassShape { WBGlassShape(kind: .rect(cornerRadius)) }

    var anyShape: AnyShape {
        switch kind {
        case .capsule:
            return AnyShape(Capsule())
        case .circle:
            return AnyShape(Circle())
        case .rect(let radius):
            return AnyShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }
}

struct WBGlassModifier: ViewModifier {
    let glass: WBGlassStyle
    let shape: WBGlassShape
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    shape.anyShape.fill(.ultraThinMaterial)
                    if let tint = glass.tintColor {
                        shape.anyShape.fill(tint)
                    }
                    shape.anyShape.fill(Color.white.opacity(colorScheme == .dark ? 0.04 : 0.20))
                }
            }
            .overlay {
                shape.anyShape.stroke(
                    Color.white.opacity(colorScheme == .dark ? 0.10 : 0.50),
                    lineWidth: 0.6
                )
            }
            .contentShape(shape.anyShape)
    }
}

extension View {
    /// iOS 26 `glassEffect(_:in:)` 的 iOS 16 等价实现。
    func wbGlassEffect(_ glass: WBGlassStyle = .regular, in shape: WBGlassShape = .capsule) -> some View {
        modifier(WBGlassModifier(glass: glass, shape: shape))
    }
}

// MARK: 玻璃按钮样式（.glass / .glassProminent）

struct WBGlassButtonStyle: ButtonStyle {
    var prominent = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(
                    Color.white.opacity(prominent ? 0 : 0.45),
                    lineWidth: 0.6
                )
            }
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    @ViewBuilder
    private var background: some View {
        if prominent {
            Capsule().fill(Color.accentColor)
        } else {
            Capsule().fill(.ultraThinMaterial)
        }
    }
}

extension ButtonStyle where Self == WBGlassButtonStyle {
    static var wbGlass: WBGlassButtonStyle { WBGlassButtonStyle() }
    static var wbGlassProminent: WBGlassButtonStyle { WBGlassButtonStyle(prominent: true) }
}

// MARK: 空态视图（ContentUnavailableView → iOS 16 自绘）

struct WBEmptyState: View {
    private let content: AnyView

    private init<V: View>(_ view: V) {
        content = AnyView(view)
    }

    init<L: View, D: View, A: View>(
        @ViewBuilder label: () -> L,
        @ViewBuilder description: () -> D,
        @ViewBuilder actions: () -> A
    ) {
        content = AnyView(
            VStack(spacing: 10) {
                label()
                    .labelStyle(.titleAndIcon)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                description()
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                actions()
                    .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        )
    }

    init<L: View, D: View>(
        @ViewBuilder label: () -> L,
        @ViewBuilder description: () -> D
    ) {
        content = AnyView(
            VStack(spacing: 10) {
                label()
                    .labelStyle(.titleAndIcon)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                description()
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        )
    }

    init(_ title: LocalizedStringKey, systemImage: String, description: Text) {
        content = AnyView(
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(.tertiary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                description
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        )
    }

    init(_ title: String, systemImage: String, description: String) {
        self.init(
            LocalizedStringKey(title),
            systemImage: systemImage,
            description: Text(description)
        )
    }

    static func search(text: String) -> WBEmptyState {
        WBEmptyState(
            "没有找到“\(text)”",
            systemImage: "magnifyingglass",
            description: Text("换个关键词试试")
        )
    }

    var body: some View {
        content
    }
}

// MARK: 双参数 onChange（iOS 17 API）

struct WBOnChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    let initial: Bool
    let action: (V, V) -> Void

    @State private var previous: V?

    func body(content: Content) -> some View {
        content
            .onAppear {
                previous = value
                if initial { action(value, value) }
            }
            .onChange(of: value) { newValue in
                let oldValue = previous ?? newValue
                previous = newValue
                action(oldValue, newValue)
            }
    }
}

extension View {
    func onChangeCompat<V: Equatable>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (V, V) -> Void
    ) -> some View {
        modifier(WBOnChangeModifier(value: value, initial: initial, action: action))
    }
}

// MARK: 触感反馈（iOS 17 sensoryFeedback）

enum WBSensoryFeedback {
    case success
    case warning
    case error
    case selection
    case impact
}

struct WBSensoryModifier<T: Equatable>: ViewModifier {
    let feedback: WBSensoryFeedback
    let trigger: T

    func body(content: Content) -> some View {
        content.onChange(of: trigger) { _ in
            switch feedback {
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .impact:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}

extension View {
    func sensoryFeedbackCompat<T: Equatable>(_ feedback: WBSensoryFeedback, trigger: T) -> some View {
        modifier(WBSensoryModifier(feedback: feedback, trigger: trigger))
    }
}
