import Foundation

/// 余额同步节流。
///
/// 面板的后台余额刷新默认是关闭的（`schedule.balance_refresh_enabled = false`），
/// 所以 `overview` 里的积分可能一直是入池时的旧值——用户下拉刷新只重读缓存不会变。
/// 这里在用户主动刷新时先触发一轮上游余额查询，再读 overview，才拿得到真实数字。
/// 同一时刻只跑一轮，并做最短间隔限制，避免连续下拉把上游打爆。
@MainActor
enum BalanceSync {
    private static var lastSync: Date?
    private static var running = false

    /// 触发全量余额同步；失败静默（不影响页面用自己的错误提示）。
    /// - Returns: 是否真的发起了请求。
    @discardableResult
    static func refreshAll(client: APIClient, minInterval: TimeInterval = 8) async -> Bool {
        if running { return false }
        if let lastSync, Date().timeIntervalSince(lastSync) < minInterval { return false }
        running = true
        lastSync = Date()
        defer { running = false }
        _ = try? await client.refreshBalances()
        return true
    }

    /// 单账号余额同步（详情页用）。
    @discardableResult
    static func refreshAccount(_ uid: String, client: APIClient, minInterval: TimeInterval = 5) async -> Bool {
        if running { return false }
        if let lastSync, Date().timeIntervalSince(lastSync) < minInterval { return false }
        running = true
        lastSync = Date()
        defer { running = false }
        _ = try? await client.accountAction(uid, action: "balance")
        return true
    }
}
