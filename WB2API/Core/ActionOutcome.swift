import Foundation

/// 面板操作返回值的统一解读。
///
/// 后端不同端点返回的自由 JSON 形状不一（`{"ok":true,"message":"…"}`、
/// `{"error":"…"}`、纯字符串、甚至 `null`），这里把它们收敛成 `ok` + 一句人话，
/// 避免每个调用点各写一套解包。
struct ActionOutcome: Sendable {
    let ok: Bool
    let message: String?

    init(_ value: JSONValue) {
        guard let object = value.objectValue else {
            if case .string(let text) = value, !text.isEmpty {
                ok = true
                message = text
            } else {
                ok = true
                message = nil
            }
            return
        }

        ok = object["ok"]?.boolValue ?? object["success"]?.boolValue ?? true
        message = object["message"]?.stringValue
            ?? object["error"]?.stringValue
            ?? object["msg"]?.stringValue
    }
}

extension Error {
    /// 面向用户的一句话错误描述（`APIError` 已在底层做过清洗）。
    var humanMessage: String {
        (self as? APIError)?.errorDescription ?? localizedDescription
    }

    /// 是否是「任务被取消」而非真实失败。
    ///
    /// 下拉刷新会取消上一轮请求，SwiftUI 在页面切换时也会取消 `.task`，
    /// 这些都不该弹错误提示。注意 URLSession 抛的是 `URLError(.cancelled)`，
    /// 但经过 `NSError` 桥接后要按 domain + code 判定才稳。
    var isCancellation: Bool {
        if self is CancellationError { return true }
        if let urlError = self as? URLError, urlError.code == .cancelled { return true }
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}
