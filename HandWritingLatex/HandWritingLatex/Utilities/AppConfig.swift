import Foundation

enum AppConfig {
    static let ocrBaseURLKey = "ocrBaseURL"
    static let defaultOCRBaseURL = "http://127.0.0.1:8000"

    static let obsidianBaseURL = URL(string: "http://127.0.0.1:27123")!

    static var ocrBaseURL: URL {
        let stored = UserDefaults.standard.string(forKey: ocrBaseURLKey)
        return normalizedURL(from: stored) ?? URL(string: defaultOCRBaseURL)!
    }

    static func normalizedURL(from value: String?) -> URL? {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(string: "http://\(trimmed)")
    }
}
