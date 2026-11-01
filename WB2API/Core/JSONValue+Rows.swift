import Foundation

extension JSONValue {
    /// 列表型响应的统一取行。
    ///
    /// 面板的自由结构接口（`tasks/jobs`、`request_logs`、`model_probes`）可能是
    /// 根数组、带包裹键的对象，或「id → 对象」的映射。三种都归一成行数组。
    var rows: [JSONValue] {
        switch self {
        case .array(let items):
            return items
        case .object(let object):
            for key in Self.rowWrapperKeys {
                if let items = object[key]?.arrayValue {
                    return items
                }
            }
            let values = Array(object.values)
            if !values.isEmpty, values.allSatisfy({ $0.objectValue != nil }) {
                return object.keys.sorted().compactMap { object[$0] }
            }
            return [self]
        case .null:
            return []
        default:
            return [self]
        }
    }

    /// 缩进 + 键排序的 JSON 文本：给「原始响应」用，可全选复制。
    var prettyText: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard
            let data = try? encoder.encode(self),
            let text = String(data: data, encoding: .utf8)
        else {
            return "—"
        }
        return text
    }

    private static let rowWrapperKeys = [
        "jobs", "items", "rows", "tasks", "entries",
        "logs", "requests", "recent", "data", "list"
    ]
}
