import Foundation

/// 单个账号可执行的操作。`rawValue` 直接作为接口路径的最后一段。
enum AccountCommand: String, CaseIterable, Identifiable, Sendable {
    case checkin
    case balance
    case travel
    case compensation
    case pause
    case resume
    case disable
    case revive
    case remove

    var id: String { rawValue }

    /// 操作区的 8 个常规操作；「移除」单独放在卡片底部，需要二次确认。
    static var quickActions: [AccountCommand] {
        allCases.filter { $0 != .remove }
    }

    var title: String {
        switch self {
        case .checkin: "签到"
        case .balance: "余额刷新"
        case .travel: "旅行"
        case .compensation: "补偿"
        case .pause: "暂停"
        case .resume: "恢复"
        case .disable: "禁用"
        case .revive: "复活"
        case .remove: "移除"
        }
    }

    var icon: String {
        switch self {
        case .checkin: "checkmark.seal"
        case .balance: "arrow.triangle.2.circlepath"
        case .travel: "airplane"
        case .compensation: "gift"
        case .pause: "pause.fill"
        case .resume: "play.fill"
        case .disable: "nosign"
        case .revive: "bolt.heart"
        case .remove: "trash"
        }
    }

    var hint: String {
        switch self {
        case .checkin: "领取该账号的今日签到积分"
        case .balance: "重新拉取该账号的余额"
        case .travel: "对该账号执行一次旅行巡检"
        case .compensation: "领取礼包或补偿"
        case .pause: "暂停调度该账号"
        case .resume: "恢复调度该账号"
        case .disable: "禁用后不再参与调度"
        case .revive: "重新登录以刷新失效会话"
        case .remove: "从账号池中移除，需要二次确认"
        }
    }
}
