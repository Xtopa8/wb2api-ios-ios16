import SwiftUI

/// 单个账号的重新登录：生成授权链接 → 浏览器完成授权 → 轮询结果。
///
/// 登录态失效（12153 / session dead）时「复活」无效——refresh token 也过期了，
/// 只能走一次交互式授权。面板的登录接口按 uid 落盘，重新授权同一个账号即可覆盖。
struct ReloginView: View {
    let account: Account

    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var start: LoginStartResponse?
    @State private var result: LoginPollResponse?
    @State private var errorText: String?
    @State private var note: String?
    @State private var isStarting = false
    @State private var isDone = false

    private var realm: String { account.realm == "global" ? "global" : "cn" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Metrics.m) {
                    header

                    if let errorText {
                        ErrorBanner(message: errorText) { Task { await begin() } }
                    }

                    if let start, let url = start.url, !url.isEmpty, result == nil {
                        linkCard(url)
                        waitingCard
                    } else if result == nil {
                        beginButton
                    }

                    if let result {
                        doneCard(result)
                    }

                    if let note {
                        Text(note)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(Metrics.m)
            }
            .background(.background)
            .navigationTitle("重新登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                }
            }
            .task(id: start?.state) { await pollUntilDone() }
            .sensoryFeedbackCompat(.success, trigger: result?.uid)
        }
    }

    // MARK: - 组件

    private var header: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            Label(account.displayName, systemImage: "person.crop.circle.badge.exclamationmark")
                .font(.headline)
            Text("当前登录态已失效，需要在浏览器里重新授权一次。授权完成后回到这里会自动检测。")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("登录区域：\(realm == "global" ? "国际版" : "国内版")")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var beginButton: some View {
        Button {
            Task { await begin() }
        } label: {
            Group {
                if isStarting {
                    ProgressView()
                } else {
                    Label("生成授权链接", systemImage: "link.badge.plus")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.wbGlassProminent)
        .controlSize(.large)
        .disabled(isStarting)
    }

    private func linkCard(_ url: String) -> some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            Label("在浏览器打开授权页", systemImage: "safari")
                .font(.callout.bold())
            Text(url)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .textSelection(.enabled)

            Link(destination: URL(string: url) ?? URL(string: "https://example.com")!) {
                Label("打开授权页", systemImage: "arrow.up.right.square")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wbGlass)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var waitingCard: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            HStack(spacing: Metrics.s) {
                ProgressView().controlSize(.small)
                Text("等待授权完成…")
                    .font(.callout.bold())
            }
            Text(note ?? "每 3 秒检查一次；授权成功后这里会自动关闭。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private func doneCard(_ result: LoginPollResponse) -> some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            Label(matched(result) ? "重新登录成功" : "授权的是另一个账号", systemImage: matched(result) ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .font(.callout.bold())
                .foregroundStyle(matched(result) ? Color.green : Color.orange)

            if let nickname = result.nickname {
                Text("账号：\(nickname)")
                    .font(.footnote)
            }
            if let uid = result.uid, !matched(result) {
                Text("授权账号 UID：\(uid)\n当前账号 UID：\(account.uid)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            Button("完成") { dismiss() }
                .buttonStyle(.wbGlass)
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - 逻辑

    private func matched(_ result: LoginPollResponse) -> Bool {
        guard let uid = result.uid, !uid.isEmpty else { return true }
        return uid == account.uid
    }

    private func begin() async {
        guard let client = session.client() else { return }
        isStarting = true
        errorText = nil
        defer { isStarting = false }
        do {
            start = try await client.loginStart(realm: realm)
        } catch {
            guard !error.isCancellation else { return }
            errorText = error.humanMessage
        }
    }

    private func pollUntilDone() async {
        guard let state = start?.state, !state.isEmpty, result == nil else { return }
        let deadline = Date().addingTimeInterval(300)
        while Date() < deadline {
            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                return
            }
            if Task.isCancelled || result != nil { return }
            guard let client = session.client() else { return }
            do {
                let response = try await client.loginPoll(state: state)
                if response.done == true {
                    result = response
                    note = nil
                    return
                }
            } catch {
                note = error.humanMessage
            }
        }
        note = "授权超时（5 分钟），请重新生成链接。"
    }
}
