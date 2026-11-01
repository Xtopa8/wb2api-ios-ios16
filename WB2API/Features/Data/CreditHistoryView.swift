import SwiftUI

/// 积分消耗明细。
///
/// 账本是「每次真实查到余额」与上一次比对后的留痕，所以刷新要先把上游余额拉一遍
/// （`POST /balance_all`），否则只是重读本地账本，看到的历史不会变。
struct CreditHistoryView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var loader = Loader<CreditHistory>()
    @State private var isSyncing = false

    private var entries: [CreditEntry] {
        loader.value?.entries ?? []
    }

    private var netChange: Int {
        entries.compactMap(\.delta).reduce(0, +)
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

            if (loader.isLoading || isSyncing) && loader.value == nil {
                Section {
                    LoadingSkeleton(rows: 6)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            } else if entries.isEmpty {
                WBEmptyState {
                    Label("暂无积分记录", systemImage: "creditcard")
                } description: {
                    Text("下拉刷新会连上游一起同步余额，产生变动后这里就有记录了。")
                }
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(entries) { entry in
                        CreditEntryRow(entry: entry)
                    }
                } header: {
                    HStack {
                        Text("最近 \(entries.count) 条")
                        if isSyncing {
                            Spacer()
                            ProgressView().controlSize(.mini)
                        }
                    }
                } footer: {
                    Text("净变动 \(netChange >= 0 ? "+" : "") \(Fmt.credits(netChange)) · 最多保留 \(loader.value?.limit ?? 0) 条")
                }
            }
        }
        .navigationTitle("积分历史")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await load(syncUpstream: true) }
        .task { await load() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("刷新", systemImage: "arrow.clockwise") {
                    Task { await load(syncUpstream: true) }
                }
                .disabled(loader.isLoading || isSyncing)
            }
        }
    }

    // MARK: - 动作

    /// - Parameter syncUpstream: true 时先触发后端全量刷新余额（会真实请求一轮上游），
    ///   账本落新流水后再读历史。
    private func load(syncUpstream: Bool = false) async {
        guard let client = session.client() else { return }
        if syncUpstream, !isSyncing {
            isSyncing = true
            // 同步失败不打断：本地账本仍是可展示的历史；节流避免连续下拉打爆上游
            await BalanceSync.refreshAll(client: client)
            isSyncing = false
        }
        await loader.load { try await client.creditHistory(limit: 200) }
    }

    private func retry() {
        loader.clearError()
        Task { await load(syncUpstream: true) }
    }
}
