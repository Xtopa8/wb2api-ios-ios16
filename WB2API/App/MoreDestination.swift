import Foundation

/// 「更多」页的二级导航目标。
///
/// 全 App 只在这里注册一次 `navigationDestination(for:)`，避免同类型重复注册。
enum MoreDestination: Hashable {
    case models
    case logs
    case packages
    case vouchers
    case compensation
    case config
    case login
    case importAccounts
    case settings
    case about
}
