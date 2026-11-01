import SwiftUI

/// 授权链接卡片：展示链接 + 打开 / 分享。
struct LoginLinkCard: View {
    let realm: String?
    let urlString: String

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.m) {
            HStack(alignment: .firstTextBaseline) {
                Label("授权链接", systemImage: "link")
                    .font(.headline)
                Spacer(minLength: Metrics.s)
                if let realm {
                    Text(realmLabel(realm))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Text(urlString)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(4)
                .textSelection(.enabled)

            HStack(spacing: Metrics.s) {
                Button("打开授权页", systemImage: "safari", action: open)
                    .buttonStyle(.wbGlassProminent)
                    .frame(maxWidth: .infinity)

                ShareLink(item: urlString) {
                    Label("分享", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.wbGlass)
            }
            .controlSize(.large)
            .frame(minHeight: Metrics.minTap)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - 动作

    private func open() {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }

    // MARK: - 展示

    private func realmLabel(_ realm: String) -> String {
        switch realm {
        case "cn": "国内版"
        case "global": "国际版"
        default: realm
        }
    }
}
