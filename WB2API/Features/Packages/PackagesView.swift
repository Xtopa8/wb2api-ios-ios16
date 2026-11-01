import SwiftUI

/// 礼包：按账号分组展示剩余 / 已用 / 总量。
struct PackagesView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var loader = Loader<PackagesResponse>()

    private var accounts: [PackageAccount] {
        loader.value?.accounts ?? []
    }

    var body: some View {
        List {
            if let error = loader.error {
                Section {
                    ErrorBanner(message: error, retry: retry)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }

            if loader.isLoading && loader.value == nil {
                Section {
                    LoadingSkeleton(rows: 5)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            } else if accounts.isEmpty {
                WBEmptyState {
                    Label("没有礼包", systemImage: "gift")
                } description: {
                    Text("面板尚未返回任何账号礼包。")
                }
                .listRowSeparator(.hidden)
            } else {
                ForEach(accounts) { account in
                    Section {
                        if let packages = account.packages, !packages.isEmpty {
                            ForEach(packages) { item in
                                PackageRowView(item: item)
                            }
                        } else {
                            Label("该账号没有礼包", systemImage: "tray")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        HStack(alignment: .firstTextBaseline) {
                            Text(accountHeader(account))
                            Spacer(minLength: Metrics.s)
                            Text("剩 \(account.remain ?? 0) / \(account.size ?? 0)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .navigationTitle("礼包")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await load() }
        .task { await load() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("刷新", systemImage: "arrow.clockwise", action: refresh)
                    .disabled(loader.isLoading)
            }
        }
    }

    // MARK: - 动作

    private func load() async {
        guard let client = session.client() else { return }
        await loader.load { try await client.packages() }
    }

    private func refresh() {
        Task { await load() }
    }

    private func retry() {
        loader.clearError()
        Task { await load() }
    }

    // MARK: - 展示

    private func accountHeader(_ account: PackageAccount) -> String {
        if let nickname = account.nickname, !nickname.isEmpty { return nickname }
        if let uid = account.uid, !uid.isEmpty { return String(uid.prefix(8)) }
        return "未知账号"
    }
}

#Preview {
    NavigationStack {
        PackagesView()
    }
    .environmentObject(SessionStore())
}
