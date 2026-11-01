import Foundation

extension Fmt {
    /// token 大数：1.2B / 340.5M / 12.1k / 960。
    static func tokens(_ value: Int?) -> String {
        guard let value else { return "—" }
        switch value {
        case 1_000_000_000...:
            return String(format: "%.2fB", Double(value) / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.1fM", Double(value) / 1_000_000)
        case 1_000...:
            return String(format: "%.1fk", Double(value) / 1_000)
        default:
            return "\(value)"
        }
    }
}
