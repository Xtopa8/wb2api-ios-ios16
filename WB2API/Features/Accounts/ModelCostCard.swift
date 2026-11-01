import SwiftUI

/// 模型成本卡：按每 1k token 成本排序，用统一水位条做相对比较。
struct ModelCostCard: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            HStack(alignment: .firstTextBaseline) {
                Text("模型成本")
                    .font(.tag)
                    .foregroundStyle(.secondary)

                Spacer(minLength: Metrics.s)

                if !costs.isEmpty {
                    Text("\(costs.count) 个模型")
                        .font(.footnote)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }

            if costs.isEmpty {
                Label("暂无成本记录", systemImage: "chart.bar")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(Array(costs.indices), id: \.self) { index in
                    VStack(alignment: .leading, spacing: Metrics.xs) {
                        HStack(spacing: Metrics.s) {
                            Text(costs[index].model ?? "未知模型")
                                .font(.footnote)
                                .lineLimit(1)

                            Spacer(minLength: Metrics.s)

                            Text(costText(costs[index].costPer1k))
                                .font(.footnote)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }

                        CreditBar(progress: ratio(costs[index].costPer1k))
                    }
                    .padding(.top, Metrics.xs)
                }
            }
        }
        .glassCard()
    }

    private var costs: [ModelCost] {
        (account.modelCosts ?? []).sorted { ($0.costPer1k ?? 0) > ($1.costPer1k ?? 0) }
    }

    private var maxCost: Double {
        costs.compactMap(\.costPer1k).max() ?? 0
    }

    private func ratio(_ value: Double?) -> Double {
        guard let value, maxCost > 0 else { return 0 }
        return min(max(value / maxCost, 0), 1)
    }

    private func costText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.4f / 1k", value)
    }
}
