import SwiftUI

/// 按 JSON 值类型渲染对应控件：开关 / 数字 / 文本 / 复杂结构。
struct ConfigFieldView: View {
    let field: ConfigField
    let onChange: (JSONValue) -> Void

    @State private var text = ""
    @State private var number = 0.0
    @State private var flag = false

    var body: some View {
        Group {
            switch field.value {
            case .bool:
                Toggle(field.key, isOn: $flag)
                    .onChangeCompat(of: flag) { _, newValue in
                        guard field.value.boolValue != newValue else { return }
                        onChange(.bool(newValue))
                    }

            case .int:
                LabeledContent(field.key) {
                    TextField("0", value: $number, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        .onChangeCompat(of: number) { _, newValue in
                            let rounded = newValue.rounded()
                            guard Int(rounded) != field.value.intValue else { return }
                            onChange(.int(Int(rounded)))
                        }
                }

            case .double:
                LabeledContent(field.key) {
                    TextField("0", value: $number, format: .number.precision(.fractionLength(0...4)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        .onChangeCompat(of: number) { _, newValue in
                            guard field.value.doubleValue != newValue else { return }
                            onChange(.double(newValue))
                        }
                }

            case .string:
                TextField(field.key, text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChangeCompat(of: text) { _, newValue in
                        guard field.value.stringValue != newValue else { return }
                        onChange(.string(newValue))
                    }

            case .array, .object:
                VStack(alignment: .leading, spacing: Metrics.xs) {
                    Label(field.key, systemImage: "curlybraces")
                    Text(prettyText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                    Text("复杂结构请在「高级 JSON」中编辑")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, Metrics.xs)

            case .null:
                LabeledContent(field.key) {
                    Text("—")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task { syncFromValue() }
        .onChangeCompat(of: field.value) { _, _ in syncFromValue() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(field.key)，\(field.typeLabel)")
    }

    private func syncFromValue() {
        text = field.value.stringValue ?? ""
        number = field.value.doubleValue ?? 0
        flag = field.value.boolValue ?? false
    }

    private var prettyText: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(field.value),
              let output = String(data: data, encoding: .utf8) else {
            return field.value.displayText
        }
        return output
    }
}
