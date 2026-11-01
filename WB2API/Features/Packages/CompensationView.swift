import SwiftUI

/// 补偿：查看待领取补偿，并一键对所有账号执行领取。
struct CompensationView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var loader = Loader<JSONValue>()
    @State private var isClaiming = false
    @State private var isConfirmingClaim = false
    @State private var toast: Toast?

    var body: some View {
        JSONRowsView(
            title: "补偿",
            value: loader.value,
            error: loader.error,
            isLoading: loader.isLoading,
            emptyTitle: "没有待领取补偿",
            emptyIcon: "arrow.uturn.backward.circle",
            reload: load
        )
        .navigationTitle("补偿")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isClaiming {
                    ProgressView()
                } else {
                    Button("全部领取", systemImage: "hand.raised.fill", action: askClaim)
                        .disabled(loader.value == nil)
                }
            }
        }
        .confirmationDialog(
            "对所有账号领取补偿？",
            isPresented: $isConfirmingClaim,
            titleVisibility: .visible
        ) {
            Button("领取全部", action: claimAll)
            Button("取消", role: .cancel, action: dismissClaimPrompt)
        } message: {
            Text("将调用面板的 compensation_all，可能耗时数十秒。")
        }
        .toast($toast)
        .task { await load() }
    }

    // MARK: - 动作

    private func load() async {
        guard let client = session.client() else { return }
        await loader.load { try await client.compensation() }
    }

    private func askClaim() {
        isConfirmingClaim = true
    }

    private func dismissClaimPrompt() {
        isConfirmingClaim = false
    }

    private func claimAll() {
        Task { await performClaim() }
    }

    private func performClaim() async {
        guard let client = session.client() else { return }
        isClaiming = true
        defer { isClaiming = false }
        do {
            _ = try await client.batch("compensation_all")
            toast = Toast(kind: .success, text: "已发起全部领取")
            await load()
        } catch {
            toast = Toast(
                kind: .failure,
                text: (error as? APIError)?.errorDescription ?? error.localizedDescription
            )
        }
    }
}
