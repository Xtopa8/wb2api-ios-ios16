import SwiftUI

/// 任意 JSON 结果的通用列表：对象按键分组、数组按条目一节。
///
/// 券码、补偿这类接口只返回自由结构，用同一套渲染保证两页观感一致。
struct JSONRowsView: View {
    let title: String
    let value: JSONValue?
    let error: String?
    let isLoading: Bool
    let emptyTitle: String
    let emptyIcon: String
    let reload: @MainActor () async -> Void

    var body: some View {
        List {
            if let error, !error.isEmpty {
                Section {
                    ErrorBanner(message: error, retry: retry)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }

            if isLoading && value == nil {
                Section {
                    LoadingSkeleton(rows: 6)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            } else if let value {
                if value == .null {
                    JSONEmptyState(title: emptyTitle, systemImage: emptyIcon)
                } else {
                    Section {
                        JSONGroupRows(value: value, label: title)
                    } header: {
                        Text(title)
                    }
                }
            } else if error == nil {
                JSONEmptyState(title: emptyTitle, systemImage: emptyIcon)
            }
        }
        .refreshable { await reload() }
    }

    private func retry() {
        Task { await reload() }
    }
}
