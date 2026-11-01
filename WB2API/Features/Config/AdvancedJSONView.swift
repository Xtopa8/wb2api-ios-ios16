import Foundation
import SwiftUI

/// 高级编辑：整份配置的 JSON 文本编辑 + 实时校验，以 sheet 呈现。
struct AdvancedJSONView: View {
    let editor: ConfigEditor

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var validationError: String?
    @State private var isValid = true
    @FocusState private var isEditing: Bool

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .focused($isEditing)
                .scrollContentBackground(.hidden)
                .padding(Metrics.s)
                .background(.quaternary, in: .rect(cornerRadius: Metrics.radiusM))
                .padding(Metrics.m)
                .safeAreaInset(edge: .bottom) {
                    if let validationError {
                        Label(validationError, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(Metrics.m)
                            .wbGlassEffect(
                                .regular.tint(.red.opacity(0.12)),
                                in: .rect(cornerRadius: Metrics.radiusM)
                            )
                            .padding(.horizontal, Metrics.m)
                            .padding(.bottom, Metrics.s)
                    }
                }
                .navigationTitle("高级 JSON")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消", action: cancel)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("应用", action: apply)
                            .disabled(!isValid)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("格式化", systemImage: "text.alignleft", action: format)
                            .disabled(!isValid)
                    }
                }
                .task { loadDraft() }
                .onChangeCompat(of: text) { _, _ in validate() }
        }
    }

    // MARK: - 动作

    private func loadDraft() {
        text = prettyText(for: editor.draft)
        validate()
    }

    private func cancel() {
        dismiss()
    }

    private func apply() {
        guard let parsed = parse(text), parsed.objectValue != nil else {
            validate()
            return
        }
        editor.draft = parsed
        dismiss()
    }

    private func format() {
        guard let parsed = parse(text) else {
            validate()
            return
        }
        text = prettyText(for: parsed)
    }

    private func validate() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isValid = false
            validationError = "内容为空"
            return
        }
        guard let parsed = parse(text) else {
            isValid = false
            validationError = "JSON 语法错误"
            return
        }
        guard parsed.objectValue != nil else {
            isValid = false
            validationError = "顶层必须是 JSON 对象"
            return
        }
        isValid = true
        validationError = nil
    }

    // MARK: - JSON

    /// 用 JSONSerialization 做严格语法校验，再交给 JSONValue 解码。
    private func parse(_ raw: String) -> JSONValue? {
        guard let data = raw.data(using: .utf8),
              (try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])) != nil else {
            return nil
        }
        return try? JSONDecoder().decode(JSONValue.self, from: data)
    }

    private func prettyText(for value: JSONValue) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(value),
              let output = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return output
    }
}
