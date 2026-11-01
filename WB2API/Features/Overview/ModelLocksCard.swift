import SwiftUI

/// 模型锁池：哪些模型被限流、锁了几个号、还要锁多久。
/// 数据来自 overview.model_locks（后端已排序）；空态显示「全部可用」。
struct ModelLocksCard: View {
    let locks: [ModelLock]

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            SectionHeader(title: "模型锁池", subtitle: subtitle)

            if locks.isEmpty {
                Label("当前没有模型级限流 —— 所有模型均可选", systemImage: "checkmark.seal.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard()
            } else {
                VStack(spacing: Metrics.s) {
                    ForEach(locks) { lock in
                        lockRow(lock)
                    }
                }
            }
        }
    }

    private var subtitle: String {
        locks.isEmpty ? "全部模型可用" : "\(locks.count) 个模型受限"
    }

    private func lockRow(_ lock: ModelLock) -> some View {
        VStack(alignment: .leading, spacing: Metrics.xs) {
            HStack {
                Text(lock.model ?? "—")
                    .font(.callout.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(lock.realmLabel)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: .capsule)
                Spacer()
                StatusTag(text: lock.stateLabel, systemImage: "lock.fill", tint: lock.stateTint)
            }

            HStack(spacing: Metrics.m) {
                Label("\(lock.servable ?? 0)/\(lock.total ?? 0) 可用", systemImage: "person.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let left = Fmt.countdown(until: lock.unlockAt ?? lock.fullyUnlockAt) {
                    Label("\(left)后解锁", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding(Metrics.s)
        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: Metrics.radiusS))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
