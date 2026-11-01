import Foundation

/// 「数据」页内部的二级页面。
///
/// 由 `DataView` 的 `NavigationStack` 承载，在 `navigationDestination(for:)` 中统一解析。
enum DataRoute: Hashable {
    case creditHistory
    case balanceHistory
}
