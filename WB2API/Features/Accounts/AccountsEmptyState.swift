import SwiftUI

/// 账号列表的空态：搜索无结果时用系统自带的搜索空态，否则给出可操作的说明。
struct AccountsEmptyState: View {
    let isSearching: Bool
    let query: String
    let title: String
    let systemImage: String
    let message: String
    let isFiltered: Bool
    let showAll: () -> Void

    var body: some View {
        Group {
            if isSearching {
                WBEmptyState.search(text: query)
            } else {
                WBEmptyState {
                    Label(title, systemImage: systemImage)
                } description: {
                    Text(message)
                } actions: {
                    if isFiltered {
                        Button("显示全部", action: showAll)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
