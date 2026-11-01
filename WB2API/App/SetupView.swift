import SwiftUI

/// 首启配置：服务器地址 + 密钥，玻璃卡片式表单。
struct SetupView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var address = SessionStore.defaultBaseURL
    @State private var key = ""
    @State private var isChecking = false
    @State private var error: String?
    @FocusState private var focused: Field?

    private enum Field { case address, key }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Metrics.l) {
                    header
                    form
                    if let error {
                        ErrorBanner(message: error, retry: { Task { await connect() } })
                    }
                    connectButton
                }
                .padding(Metrics.m)
            }
            .background(.background)
            .navigationTitle("连接面板")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(spacing: Metrics.s) {
            BrandMark(size: 56)
            Text("WorkBuddy 面板")
                .font(.largeTitle.bold())
            Text("填入面板地址与访问密钥")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, Metrics.xl)
    }

    private var form: some View {
        VStack(spacing: Metrics.m) {
            TextField("https://…", text: $address)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .focused($focused, equals: .address)
                .padding(Metrics.m)
                .wbGlassEffect(.regular, in: .rect(cornerRadius: Metrics.radiusM))

            SecureField("api_key", text: $key)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focused, equals: .key)
                .padding(Metrics.m)
                .wbGlassEffect(.regular, in: .rect(cornerRadius: Metrics.radiusM))
        }
    }

    private var connectButton: some View {
        Button(action: { Task { await connect() } }) {
            if isChecking {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("连接")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.wbGlassProminent)
        .controlSize(.large)
        .disabled(address.isEmpty || key.isEmpty || isChecking)
    }

    private func connect() async {
        isChecking = true
        error = nil
        defer { isChecking = false }
        session.baseURLString = address
        guard let base = session.baseURL else {
            error = "服务器地址无效"
            return
        }
        let probe = APIClient(baseURL: base, apiKey: key)
        do {
            _ = try await probe.overview()
            session.update(apiKey: key)
        } catch {
            self.error = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
