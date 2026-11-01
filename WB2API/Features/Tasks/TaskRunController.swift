import Foundation
import Combine

/// 单次执行结果（跨任务组回传用，必须 Sendable）。
struct TaskRunResult: Sendable {
    let taskID: String
    let state: TaskRunState
}

/// 批量执行选中任务：账号之间并发、账号内部串行。
///
/// 后端对同一账号有 per-account 互斥锁（并发进会 409），所以并发单位是账号而不是任务；
/// 账号内一个跑完再跑下一个，既符合后端约束，也让上游看到的是正常节奏。
@MainActor
final class TaskRunController: ObservableObject {
    @Published private(set) var states: [String: TaskRunState] = [:]
    @Published private(set) var isRunning = false
    @Published private(set) var total = 0
    @Published private(set) var finishedCount = 0
    /// 真正跑完的任务 id（停止后用来只清掉已完成的选择）
    @Published private(set) var finishedIDs: Set<String> = []

    /// 账号并发数（后端 per-account 锁允许的最大并行度）
    private let accountConcurrency = 2

    @Published private var stopRequested = false

    var progressText: String { "\(finishedCount)/\(total)" }

    var successCount: Int {
        states.values.filter { if case .success = $0 { return true }; return false }.count
    }

    var failureCount: Int {
        states.values.filter { if case .failure = $0 { return true }; return false }.count
    }

    func state(for task: AccountTask) -> TaskRunState? { states[task.id] }

    /// 执行这些任务；已在跑时直接返回，避免重复提交。
    func run(_ tasks: [AccountTask], client: APIClient) async {
        guard !isRunning, !tasks.isEmpty else { return }
        isRunning = true
        stopRequested = false
        states = [:]
        finishedIDs = []
        finishedCount = 0
        total = tasks.count

        // 按账号分组：账号内顺序执行，账号间按批并发
        let groups = Dictionary(grouping: tasks, by: \.uid)
            .values
            .map { $0.sorted { $0.id < $1.id } }
            .sorted { ($0.first?.uid ?? "") < ($1.first?.uid ?? "") }

        for batch in groups.chunked(into: accountConcurrency) {
            if stopRequested { break }
            for items in batch {
                for task in items { states[task.id] = .running }
            }

            await withTaskGroup(of: [TaskRunResult].self) { group in
                for items in batch {
                    // 子任务只捕获 Sendable 值（client / 任务数组），不碰主线程状态
                    group.addTask {
                        await Self.execute(items, client: client)
                    }
                }
                for await results in group {
                    for result in results where !result.state.isCancelled {
                        states[result.taskID] = result.state
                        finishedIDs.insert(result.taskID)
                        finishedCount += 1
                    }
                }
            }
        }

        // 被停止时，没轮到跑的任务不能一直挂着「执行中」
        for (id, state) in states where state == .running {
            states[id] = nil
        }
        isRunning = false
    }

    /// 停止：当前批次跑完后不再发起下一批。
    func stop() { stopRequested = true }

    /// 顺序执行一个账号的任务，返回每个任务的结果。
    private nonisolated static func execute(
        _ items: [AccountTask],
        client: APIClient
    ) async -> [TaskRunResult] {
        var results: [TaskRunResult] = []
        for task in items {
            if Task.isCancelled { break }
            do {
                let outcome = try await client.runTask(uid: task.uid, code: task.code)
                results.append(
                    TaskRunResult(
                        taskID: task.id,
                        state: outcome.isSuccess ? .success(outcome.displayText) : .failure(outcome.displayText)
                    )
                )
            } catch {
                results.append(
                    TaskRunResult(
                        taskID: task.id,
                        state: error.isCancellation ? .cancelled : .failure(error.humanMessage)
                    )
                )
            }
        }
        return results
    }
}

extension Array {
    /// 按固定长度切块（最后一块可以短）。
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return isEmpty ? [] : [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
