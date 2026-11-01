import Foundation

/// 单任务执行结果：对应 `POST /accounts/{uid}/tasks/auto` 的返回。
///
/// 服务端会走完「接受 → 执行 → 回读校验 → 领奖」，
/// `status` 可能是 done / error / skipped 等；`message` 是给用户看的一句话。
struct TaskRunOutcome: Sendable, Equatable {
    let ok: Bool
    let status: String
    let message: String?
    let credit: Int?
    let claimed: Bool

    init(_ value: JSONValue) {
        let obj = value.objectValue ?? [:]
        ok = obj["ok"]?.boolValue ?? false
        status = obj["status"]?.stringValue ?? (ok ? "done" : "error")
        message = obj["message"]?.stringValue
        credit = obj["credit"]?.intValue
        claimed = obj["claimed"]?.boolValue ?? false
    }

    var isSuccess: Bool { ok && status != "error" }

    var displayText: String {
        if let message, !message.isEmpty { return message }
        if let credit, credit > 0 { return "完成，+\(credit) 分" }
        return isSuccess ? "完成" : "失败"
    }
}

/// 单任务执行状态（用于行内展示）。
enum TaskRunState: Equatable, Sendable {
    case running
    case success(String)
    case failure(String)
    case cancelled

    var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }
}
