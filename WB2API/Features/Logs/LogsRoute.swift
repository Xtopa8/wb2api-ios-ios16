import Foundation

/// 日志页的二级路由：只在这里注册一次 `navigationDestination`。
enum LogsRoute: Hashable {
    case requestLogs
    case errorSummary

    var title: String {
        switch self {
        case .requestLogs: return "请求日志"
        case .errorSummary: return "错误汇总"
        }
    }

    var systemImage: String {
        switch self {
        case .requestLogs: return "arrow.left.arrow.right"
        case .errorSummary: return "exclamationmark.triangle"
        }
    }
}
