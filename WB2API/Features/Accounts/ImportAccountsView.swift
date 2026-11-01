import SwiftUI
import UniformTypeIdentifiers

/// 从 Cockpit 导出的 JSON 批量导入账号。
///
/// 后端接收 multipart 的 `file` 字段（32MB 上限），返回
/// `{ok, total, imported, skipped, errors}`；这里只负责选文件、上传、呈现结果。
struct ImportAccountsView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var isPicking = false
    @State private var isUploading = false
    @State private var result: ImportResult?
    @State private var errorText: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.m) {
                SectionHeader(title: "导入账号", subtitle: "选择 Cockpit 导出的 .json 文件")

                VStack(alignment: .leading, spacing: Metrics.s) {
                    Label("文件必须是账号数组（每条含 token / uid 等字段）", systemImage: "doc.text")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button {
                        isPicking = true
                    } label: {
                        Group {
                            if isUploading {
                                ProgressView()
                            } else {
                                Label("选择文件并导入", systemImage: "square.and.arrow.down")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.wbGlassProminent)
                    .controlSize(.large)
                    .disabled(isUploading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()

                if let errorText {
                    ErrorBanner(message: errorText) { isPicking = true }
                }

                if let result {
                    VStack(alignment: .leading, spacing: Metrics.s) {
                        SectionHeader(title: "导入结果", subtitle: result.headline)
                        ForEach(result.lines, id: \.self) { line in
                            Text(line)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard()
                }
            }
            .padding(Metrics.m)
        }
        .background(.background)
        .navigationTitle("导入账号")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $isPicking,
            allowedContentTypes: [.json, .text],
            allowsMultipleSelection: false
        ) { pick in
            switch pick {
            case .success(let urls):
                guard let url = urls.first else { return }
                upload(url)
            case .failure(let error):
                errorText = error.localizedDescription
            }
        }
    }

    // MARK: - 动作

    private func upload(_ url: URL) {
        Task {
            guard let client = session.client() else { return }
            isUploading = true
            errorText = nil
            result = nil
            defer { isUploading = false }

            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }

            do {
                let data = try Data(contentsOf: url)
                let raw = try await client.importCockpit(data, filename: url.lastPathComponent)
                let outcome = ActionOutcome(raw)
                guard outcome.ok else {
                    errorText = outcome.message ?? "导入失败"
                    return
                }
                result = ImportResult(raw)
            } catch {
                errorText = error.humanMessage
            }
        }
    }
}

/// `POST /import/cockpit` 的返回：`{ok, total, imported, skipped, errors:[…]}`。
struct ImportResult {
    let total: Int
    let imported: Int
    let skipped: Int
    let errors: [String]

    init(_ value: JSONValue) {
        let obj = value.objectValue ?? [:]
        total = obj["total"]?.intValue ?? 0
        imported = obj["imported"]?.intValue ?? 0
        skipped = obj["skipped"]?.intValue ?? 0
        errors = (obj["errors"]?.arrayValue ?? []).compactMap(\.stringValue)
    }

    var headline: String { "共 \(total) 条 · 导入 \(imported) · 跳过 \(skipped)" }

    var lines: [String] {
        errors.isEmpty ? ["没有错误"] : Array(errors.prefix(20))
    }
}
