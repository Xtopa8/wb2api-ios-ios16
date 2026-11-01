import Foundation

/// `request_logs` 的一行：从自由 JSON 里取出展示所需字段。
struct RequestLogRow: Identifiable {
    let id: String
    let time: String?
    let requestID: String?
    let path: String?
    let account: String?
    let model: String?
    let status: Int?
    let isOK: Bool
    let outcome: String?
    let durationMs: Double?
    let attempts: Int?
    let totalTokens: Int?
    let credit: Double?

    init(index: Int, value: JSONValue) {
        let object = value.objectValue ?? [:]
        let status = object["status"]?.intValue
        let requestID = object["request_id"]?.stringValue

        self.id = requestID ?? "row-\(index)"
        self.time = object["time"]?.stringValue
        self.requestID = requestID
        self.path = object["path"]?.stringValue
        self.account = object["account"]?.stringValue
        self.model = object["model"]?.stringValue
        self.status = status
        self.isOK = object["ok"]?.boolValue ?? ((status ?? 0) < 400)
        self.outcome = object["outcome"]?.stringValue
        self.durationMs = object["duration_ms"]?.doubleValue
        self.attempts = object["attempts"]?.intValue
        self.totalTokens = object["total_tokens"]?.intValue
        self.credit = object["credit"]?.doubleValue
    }
}
