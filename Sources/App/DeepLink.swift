import Foundation

enum DeepLink: Hashable {
    case dashboard
    case history
    case settings
    case goals
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
        if host == "settings" || path.first == "settings" {
            return .settings
        }
        if host == "goals" || path.first == "goals" {
            return .goals
        }
        if host == "quiz" || path.first == "quiz" {
            return .quiz
        }
        return nil
    }
}
