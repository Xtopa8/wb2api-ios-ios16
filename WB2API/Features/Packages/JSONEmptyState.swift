import SwiftUI

/// JSON 页面的空状态占位，保证券码 / 补偿两页外观一致。
struct JSONEmptyState: View {
    let title: String
    let systemImage: String

    var body: some View {
        WBEmptyState {
            Label(title, systemImage: systemImage)
        } description: {
            Text("接口没有返回可展示的内容，下拉可重新获取。")
        }
        .listRowSeparator(.hidden)
    }
}
