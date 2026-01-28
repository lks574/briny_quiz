import Observation
import SwiftUI

@MainActor
@Observable
final class AppRouter {
    enum AppTab: Hashable {
        case dashboard
        case history
        case settings
    }

    enum Route: Hashable {
        case quiz(QuizSettings)
        case result(QuizResult)
    }

    var selectedTab: AppTab = .dashboard
    var dashboardPath: [Route] = []
    var historyPath: [Route] = []
    var settingsPath: [Route] = []

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func push(_ route: Route) {
        push(route, on: route.preferredTab)
    }

    func push(_ route: Route, on tab: AppTab) {
        updatePath(for: tab) { path in
            path.append(route)
        }
    }

    func pop() {
        updatePath(for: selectedTab) { path in
            _ = path.popLast()
        }
    }

    func popToRoot() {
        updatePath(for: selectedTab) { path in
            path.removeAll()
        }
    }

    func handleDeepLink(_ url: URL) {
        guard let deepLink = DeepLink.parse(url) else { return }
        handleDeepLink(deepLink)
    }

    func handleDeepLink(_ deepLink: DeepLink) {
        switch deepLink {
        case .dashboard:
            selectTab(.dashboard)
            popToRoot()
        case .history:
            selectTab(.history)
            popToRoot()
        case .settings:
            selectTab(.settings)
            popToRoot()
        case .quiz:
            selectTab(.dashboard)
            popToRoot()
            push(.quiz(.default), on: .dashboard)
        }
    }

    private func updatePath(for tab: AppTab, _ update: (inout [Route]) -> Void) {
        switch tab {
        case .dashboard:
            update(&dashboardPath)
        case .history:
            update(&historyPath)
        case .settings:
            update(&settingsPath)
        }
    }
}

extension AppRouter.Route {
    var preferredTab: AppRouter.AppTab {
        switch self {
        case .quiz, .result:
            return .dashboard
        }
    }

    var hidesTabBar: Bool {
        switch self {
        case .quiz, .result:
            return true
        }
    }
}
