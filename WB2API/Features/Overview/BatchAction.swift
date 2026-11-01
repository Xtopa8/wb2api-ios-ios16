import Foundation

/// 概览页的四个批量操作。`rawValue` 直接作为 `APIClient.batch(_:)` 的参数。
enum BatchAction: String, CaseIterable, Identifiable, Sendable {
    case checkin
    case travel
    case activity
    case keepalive

    var id: String { rawValue }

    /// 接口端点路径。
    var endpoint: String { "\(rawValue)_all" }

    var title: String {
        switch self {
        case .checkin: "全部签到"
        case .travel: "旅行巡检"
        case .activity: "活跃上报"
        case .keepalive: "全部保活"
        }
    }

    var shortTitle: String {
        switch self {
        case .checkin: "签到"
        case .travel: "巡检"
        case .activity: "上报"
        case .keepalive: "保活"
        }
    }

    var icon: String {
        switch self {
        case .checkin: "checkmark.seal.fill"
        case .travel: "airplane"
        case .activity: "bolt.fill"
        case .keepalive: "heart.fill"
        }
    }

    var hint: String {
        switch self {
        case .checkin: "为全部账号领取今日签到积分"
        case .travel: "对全部账号执行一次旅行巡检"
        case .activity: "向全部账号上报一次活跃"
        case .keepalive: "刷新全部账号的会话保活"
        }
    }
}
