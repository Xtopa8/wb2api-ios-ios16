import Foundation
import Combine

/// 概览页的数据与操作。
///
/// 账号数据统一来自 `client.overview()`——公网 nginx 没有暴露 `/status`。
@MainActor
final class OverviewModel: ObservableObject {
    private let loader = Loader<OverviewResponse>()
    private let usageLoader = Loader<UsageSnapshot>()

    private var cancellables: Set<AnyCancellable> = []

    init() {
        loader.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        usageLoader.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    @Published var toast: Toast?
    @Published private(set) var runningBatch: BatchAction?

    var overview: OverviewResponse? { loader.value }
    /// usage 快照（今日 tokens 与用量趋势共用）
    var usage: UsageSnapshot? { usageLoader.value }
    var digest: OverviewDigest? { loader.value.map { OverviewDigest(overview: $0, usage: usageLoader.value) } }
    var isLoading: Bool { loader.isLoading }
    var error: String? { loader.error }
    var lastUpdated: Date? { loader.lastUpdated }

    // MARK: 读取

    func refreshIfStale(after interval: TimeInterval = 5, using client: APIClient?) async {
        if loader.isLoading { return }
        if let last = loader.lastUpdated, Date().timeIntervalSince(last) < interval { return }
        await load(using: client)
    }

    /// - Parameter syncBalance: 用户下拉/点刷新时为 true，先同步一轮上游余额再读缓存。
    func load(using client: APIClient?, syncBalance: Bool = false) async {
        guard let client else {
            toast = Toast(kind: .failure, text: "尚未配置服务器地址")
            return
        }
        if syncBalance {
            await BalanceSync.refreshAll(client: client)
        }
        await loader.load(force: syncBalance) { try await client.overview() }
        // 今日 token 来自 usage 小时桶，失败不影响主数据
        try? await usageLoader.load { try await client.usage() }
    }

    // MARK: 批量操作

    func run(_ action: BatchAction, using client: APIClient?) async {
        guard runningBatch == nil else { return }
        guard let client else {
            toast = Toast(kind: .failure, text: "尚未配置服务器地址")
            return
        }

        runningBatch = action
        defer { runningBatch = nil }

        do {
            let outcome = ActionOutcome(try await client.batch(action.endpoint))
            guard outcome.ok else {
                toast = Toast(
                    kind: .failure,
                    text: "\(action.title)失败：\(outcome.message ?? "服务器拒绝了该操作")"
                )
                return
            }
            toast = Toast(kind: .success, text: outcome.message ?? "\(action.title)已提交")
            await load(using: client)
        } catch {
            toast = Toast(kind: .failure, text: "\(action.title)失败：\(error.humanMessage)")
        }
    }
}
