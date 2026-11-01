import Foundation
import Combine

/// 全局会话：服务器地址 + api_key + 客户端工厂。
/// 地址存 UserDefaults，密钥存 Keychain。
@MainActor
final class SessionStore: ObservableObject {
    /// 不预置任何服务地址：由使用者填入自己部署的面板。
    static let defaultBaseURL = ""

    private static let baseURLKey = "wb2api.baseURL"

    var baseURLString: String {
        didSet { UserDefaults.standard.set(baseURLString, forKey: Self.baseURLKey) }
    }

    @Published private(set) var apiKey: String
    var isConfigured: Bool {
        !apiKey.isEmpty && !baseURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init() {
        baseURLString = UserDefaults.standard.string(forKey: Self.baseURLKey) ?? Self.defaultBaseURL
        apiKey = Keychain.read() ?? ""
    }

    var baseURL: URL? {
        var s = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.hasPrefix("http") { s = "https://" + s }
        while s.hasSuffix("/") { s.removeLast() }
        return URL(string: s)
    }

    func client(session: URLSession = .shared) -> APIClient? {
        guard let baseURL else { return nil }
        return APIClient(baseURL: baseURL, apiKey: apiKey, session: session)
    }

    func update(apiKey newValue: String) {
        apiKey = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if apiKey.isEmpty {
            Keychain.delete()
        } else {
            Keychain.save(apiKey)
        }
    }

    func signOut() {
        update(apiKey: "")
    }
}
