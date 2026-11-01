import SwiftUI

/// 路由到具体页面：把 switch 从页面 body 里挪出来，保持 body 只有布局。
struct LogsRouteView: View {
    let route: LogsRoute

    var body: some View {
        switch route {
        case .requestLogs:
            RequestLogsView()
        case .errorSummary:
            ErrorSummaryView()
        }
    }
}
