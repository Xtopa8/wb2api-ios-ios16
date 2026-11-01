import SwiftUI

/// 一个 JSON 分组的内容行：对象按键展开、数组按序号展开，标量直接一行。
struct JSONGroupRows: View {
    let value: JSONValue
    let label: String

    var body: some View {
        if let nested = value.objectValue, !nested.isEmpty {
            ForEach(nested.keys.sorted(), id: \.self) { key in
                JSONRowView(label: key, value: nested[key] ?? .null)
            }
        } else if let array = value.arrayValue, !array.isEmpty {
            ForEach(array.indices, id: \.self) { index in
                JSONRowView(label: "第 \(index + 1) 项", value: array[index])
            }
        } else {
            JSONRowView(label: label, value: value)
        }
    }
}
