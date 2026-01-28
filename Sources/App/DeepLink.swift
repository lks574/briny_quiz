import Foundation

enum DeepLink: Hashable {
    case dashboard
    case history
    case quiz

    static func parse(_ url: URL) -> DeepLink? {
        guard url.scheme == "brinyquiz" else { return nil }
        let host = url.host ?? ""
        let path = url.pathComponents.dropFirst()
        if host == "dashboard" || path.first == "dashboard" {
            return .dashboard
        }
        if host == "history" || path.first == "history" {
            return .history
        }
        if host == "quiz" || path.first == "quiz" {
            return .quiz
        }
        return nil
    }
}
