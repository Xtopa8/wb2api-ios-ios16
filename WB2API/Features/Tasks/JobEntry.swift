import Foundation

/// 把 `tasks/jobs` 的自由结构拍平成可渲染的一行：
/// 标题 + 副标题 + 键值对 + 嵌套详情。
struct JobEntry: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let fields: [(key: String, value: String)]
    let detail: String?

    init(index: Int, value: JSONValue) {
        guard let object = value.objectValue else {
            self.id = "row-\(index)"
            self.title = value.displayText
            self.subtitle = nil
            self.fields = []
            self.detail = nil
            return
        }

        let heading = Self.firstText(in: object, keys: Self.titleKeys) ?? "作业 #\(index + 1)"
        let subheading = Self.firstText(in: object, keys: Self.subtitleKeys)

        var pairs: [(key: String, value: String)] = []
        var nested: [String] = []
        for key in object.keys.sorted() {
            guard let field = object[key] else { continue }
            switch field {
            case .object, .array:
                if !Self.hiddenKeys.contains(key) {
                    nested.append("\(key): \(field.prettyText)")
                }
            case .null:
                continue
            default:
                let text = field.displayText
                if Self.hiddenKeys.contains(key) || text == heading || text == subheading {
                    continue
                }
                pairs.append((key: key, value: text))
            }
        }

        self.id = object["id"]?.stringValue
            ?? object["job"]?.stringValue
            ?? object["key"]?.stringValue
            ?? "row-\(index)"
        self.title = heading
        self.subtitle = subheading
        self.fields = pairs
        self.detail = nested.isEmpty ? nil : nested.joined(separator: "\n")
    }

    private static func firstText(in object: [String: JSONValue], keys: [String]) -> String? {
        for key in keys {
            if let text = object[key]?.stringValue, !text.isEmpty {
                return text
            }
            if let number = object[key]?.intValue {
                return String(number)
            }
        }
        return nil
    }

    private static let titleKeys = [
        "name", "title", "job", "task", "model", "account", "uid", "key", "id"
    ]

    private static let subtitleKeys = [
        "description", "desc", "status", "state", "message", "error", "last_error", "last"
    ]

    /// 原始结构只留给 `detail`，不再重复成键值对。
    private static let hiddenKeys: Set<String> = ["raw", "payload", "detail", "data"]
}
