import Observation
import SwiftUI

@MainActor
@Observable
final class AppRouter {
    enum AppTab: Hashable {
        case dashboard
        case history
    }

    enum Route: Hashable {
        case quiz(QuizSettings)
        case result(QuizResult)
    }

    var selectedTab: AppTab = .dashboard
    var dashboardPath: [Route] = []
    var historyPath: [Route] = []

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func push(_ route: Route) {
        dashboardPath.append(route)
    }

    func pop() {
        _ = dashboardPath.popLast()
    }

    func popToRoot() {
        dashboardPath.removeAll()
    }

    func handleDeepLink(_ url: URL) {
        // Placeholder for future deep link rules.
        if url.host == "history" {
            selectTab(.history)
        }
    }
}
