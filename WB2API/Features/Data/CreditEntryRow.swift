import SwiftUI

/// 单条积分变动：账号 + 变动量 + 余额前后。
struct CreditEntryRow: View {
    let entry: CreditEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Metrics.m) {
            VStack(alignment: .leading, spacing: Metrics.xs) {
                Label(entry.account ?? shortUID, systemImage: "person.crop.circle")
                    .font(.subheadline)
                    .lineLimit(1)

                if let before = entry.before, let after = entry.after {
                    Text("\(Fmt.credits(before)) → \(Fmt.credits(after))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: Metrics.xs) {
                Text(deltaText)
                    .font(.body.monospacedDigit().bold())
                    .foregroundStyle(deltaTint)
                    .contentTransition(.numericText())

                if let date {
                    Text(date, format: .dateTime.month().day().hour().minute())
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, Metrics.xs)
        .frame(minHeight: Metrics.minTap)
        .accessibilityElement(children: .combine)
    }

    private var shortUID: String {
        guard let uid = entry.uid, !uid.isEmpty else { return "—" }
        return String(uid.prefix(6))
    }

    private var deltaText: String {
        guard let delta = entry.delta else { return "—" }
        return (delta > 0 ? "+" : "") + Fmt.credits(delta)
    }

    private var deltaTint: Color {
        guard let delta = entry.delta else { return .secondary }
        if delta > 0 { return .green }
        if delta < 0 { return .primary }
        return .secondary
    }

    private var date: Date? {
        Fmt.parse(entry.time)
    }
}
