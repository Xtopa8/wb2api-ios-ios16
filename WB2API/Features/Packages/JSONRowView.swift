import Foundation
import SwiftUI

/// JSON 单行：标量用 `LabeledContent`，容器用等宽文本预览。
struct JSONRowView: View {
    let label: String
    let value: JSONValue

    var body: some View {
        if isScalar {
            LabeledContent {
                Text(value.displayText)
                    .font(.body.monospacedDigit())
                    .multilineTextAlignment(.trailing)
                    .textSelection(.enabled)
            } label: {
                Text(label)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: Metrics.xs) {
                Label(label, systemImage: "curlybraces")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(prettyText)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
            .padding(.vertical, Metrics.xs)
        }
    }

    private var isScalar: Bool {
        switch value {
        case .object, .array: false
        default: true
        }
    }

    private var prettyText: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(value),
              let text = String(data: data, encoding: .utf8) else {
            return value.displayText
        }
        return text
    }
}
