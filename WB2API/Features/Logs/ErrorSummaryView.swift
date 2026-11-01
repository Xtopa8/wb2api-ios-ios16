import SwiftUI

/// 错误汇总：扫描概览 + 按分组聚合的错误卡。
struct ErrorSummaryView: View {
    @EnvironmentObject private var session: SessionStore

    @StateObject private var summary = Loader<ErrorSummary>()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.m) {
                if let message = summary.error {
                    ErrorBanner(message: message, retry: retry)
                }

                if let value = summary.value {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 150), spacing: Metrics.s)],
                        spacing: Metrics.s
                    ) {
                        StatTile(title: "错误分组", value: "\(value.rows.count)", tint: .orange)
                        StatTile(
                            title: "扫描日志",
                            value: Fmt.compact(value.scanned),
                            caption: "更新于 " + Fmt.ago(value.updatedAt)
                        )
                    }

                    SectionHeader(title: "错误明细", subtitle: "按出现次数排序")

                    if value.rows.isEmpty {
                        WBEmptyState(
                            "没有记录到错误",
                            systemImage: "checkmark.seal",
                            description: Text("扫描窗口内没有异常日志")
                        )
                        .padding(.vertical, Metrics.l)
                    } else {
                        LazyVStack(spacing: Metrics.s) {
                            ForEach(value.rows.indices, id: \.self) { index in
                                ErrorRowView(row: value.rows[index])
                            }
                        }
                    }
                } else if summary.isLoading || summary.error == nil {
                    LoadingSkeleton(rows: 4)
                }
            }
            .padding(Metrics.m)
        }
        .navigationTitle("错误汇总")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await refresh() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("刷新", systemImage: "arrow.clockwise", action: refreshNow)
                    .labelStyle(.iconOnly)
            }
        }
        .task { await refresh() }
    }

    private func refreshNow() {
        Task { await refresh() }
    }

    private func retry() {
        Task { await refresh() }
    }

    private func refresh() async {
        guard let client = session.client() else { return }
        await summary.load { try await client.errorSummary() }
    }
}
