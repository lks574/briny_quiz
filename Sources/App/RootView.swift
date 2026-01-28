import Observation
import SwiftUI

struct RootView: View {
    @Bindable var router: AppRouter
    let container: AppContainer
    let dashboardStore: DashboardStore
    let historyStore: HistoryStore

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.dashboardPath) {
                DashboardView(store: dashboardStore)
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        switch route {
                        case .quiz(let settings):
                            QuizView(store: container.makeQuizStore(settings: settings))
                                .toolbar(.hidden, for: .tabBar)
                        case .result(let result):
                            ResultView(store: container.makeResultStore(result: result))
                                .toolbar(.hidden, for: .tabBar)
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "sparkles")
            }
            .tag(AppRouter.AppTab.dashboard)

            NavigationStack(path: $router.historyPath) {
                HistoryView(store: historyStore)
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(AppRouter.AppTab.history)
        }
    }
}

struct AppEntryView: View {
    let container: AppContainer
    @Bindable var router: AppRouter
    @State private var splashStore = SplashStore()
    @State private var dashboardStore: DashboardStore?
    @State private var historyStore: HistoryStore?

    var body: some View {
        if let settings = splashStore.state.settings {
            RootView(
                router: router,
                container: container,
                dashboardStore: dashboardStore ?? container.makeDashboardStore(initialSettings: settings),
                historyStore: historyStore ?? container.makeHistoryStore()
            )
            .onAppear {
                if dashboardStore == nil {
                    dashboardStore = container.makeDashboardStore(initialSettings: settings)
                }
                if historyStore == nil {
                    historyStore = container.makeHistoryStore()
                }
            }
        } else {
            SplashView(store: splashStore)
        }
    }
}

#Preview {
    let container = AppContainer()
    return AppEntryView(container: container, router: container.appRouter)
}
