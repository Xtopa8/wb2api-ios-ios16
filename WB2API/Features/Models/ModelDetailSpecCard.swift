import SwiftUI

/// 模型详情规格卡：容量/计费、能力清单、原始标识，全部字段一个不漏。
struct ModelDetailSpecCard: View {
    let model: ModelInfo

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.m) {
            SectionHeader(title: "规格", subtitle: "上下文、计费与推理强度")

            VStack(spacing: Metrics.s) {
                LabeledContent("上下文长度") {
                    Text(model.contextText).foregroundStyle(.secondary)
                }
                LabeledContent("最大输出") {
                    Text(model.maxOutputText).foregroundStyle(.secondary)
                }
                LabeledContent("计费倍率") {
                    Text(model.creditMultiplierText).foregroundStyle(.secondary)
                }
                LabeledContent("默认推理强度") {
                    Text(model.defaultEffortLabel).foregroundStyle(.secondary)
                }
            }
            .font(.callout)

            Divider()

            VStack(alignment: .leading, spacing: Metrics.s) {
                Text("能力")
                    .font(.tag)
                    .foregroundStyle(.secondary)
                ModelCapabilityRow(title: "图像输入", systemImage: "photo", isEnabled: model.supportsImages == true)
                ModelCapabilityRow(title: "推理", systemImage: "brain", isEnabled: model.supportsReasoning == true)
                ModelCapabilityRow(title: "工具调用", systemImage: "wrench.and.screwdriver", isEnabled: model.supportsToolCall == true)
                ModelCapabilityRow(title: "仅推理模式", systemImage: "lightbulb", isEnabled: model.onlyReasoning == true)
                ModelCapabilityRow(title: "默认模型", systemImage: "star", isEnabled: model.isDefault == true)
            }

            Divider()

            VStack(spacing: Metrics.s) {
                LabeledContent("模型 ID") {
                    Text(model.modelId ?? "—")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                LabeledContent("名称") {
                    Text(model.name ?? "—").foregroundStyle(.secondary)
                }
                LabeledContent("繁忙状态") {
                    Text(model.busy ?? "—").foregroundStyle(.secondary)
                }
            }
            .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}
