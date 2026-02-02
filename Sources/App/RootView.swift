import Observation
import SwiftUI
import FeatureQuiz
import FeatureHistory
import FeatureSettings

struct RootView: View {
    @Bindable var router: AppRouter
    let container: AppContainer
    let dashboardStore: DashboardStore
    let historyStore: HistoryStore
    let settingsStore: SettingsStore
    @State private var showsRNExamples = false

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.dashboardPath) {
                DashboardView(store: dashboardStore)
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        destinationView(for: route)
                    }
                    .toolbar {
                      
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("통계") {
                                showsRNExamples = true
                            }
                        }
                    }
            }
            .toolbar(router.dashboardPath.last?.hidesTabBar == true ? .hidden : .visible, for: .tabBar)
            .tabItem {
                Label("Dashboard", systemImage: "sparkles")
            }
            .tag(AppRouter.AppTab.dashboard)

            NavigationStack(path: $router.historyPath) {
                HistoryView(store: historyStore)
            }
            .toolbar(router.historyPath.last?.hidesTabBar == true ? .hidden : .visible, for: .tabBar)
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(AppRouter.AppTab.history)

            NavigationStack(path: $router.settingsPath) {
                SettingsView(store: settingsStore)
            }
            .toolbar(router.settingsPath.last?.hidesTabBar == true ? .hidden : .visible, for: .tabBar)
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppRouter.AppTab.settings)
        }
        .sheet(isPresented: $showsRNExamples) {
            NavigationStack {
                ReactNativeHostExamplesView()
            }
        }
    }
}

private extension RootView {
    @ViewBuilder
    func destinationView(for route: AppRouter.Route) -> some View {
        Group {
            switch route {
            case .stage(let categoryId, let difficulty):
                StageView(store: container.makeStageStore(categoryId: categoryId, difficulty: difficulty))
            case .quiz(let settings):
                QuizView(store: container.makeQuizStore(settings: settings))
            case .result(let result):
                ResultView(store: container.makeResultStore(result: result))
            }
        }
        .toolbar(route.hidesTabBar ? .hidden : .visible, for: .tabBar)
    }
}

struct AppEntryView: View {
    let container: AppContainer
    @Bindable var router: AppRouter
    @State private var splashStore: SplashStore
    @State private var dashboardStore: DashboardStore?
    @State private var historyStore: HistoryStore?
    @State private var settingsStore: SettingsStore?

    init(container: AppContainer, router: AppRouter) {
        self.container = container
        self.router = router
        _splashStore = State(initialValue: container.makeSplashStore())
    }

    var body: some View {
        if let settings = splashStore.state.settings {
            RootView(
                router: router,
                container: container,
                dashboardStore: dashboardStore ?? container.makeDashboardStore(initialSettings: settings),
                historyStore: historyStore ?? container.makeHistoryStore(),
                settingsStore: settingsStore ?? container.makeSettingsStore()
            )
            .onAppear {
                if dashboardStore == nil {
                    dashboardStore = container.makeDashboardStore(initialSettings: settings)
                }
                if historyStore == nil {
                    historyStore = container.makeHistoryStore()
                }
                if settingsStore == nil {
                    settingsStore = container.makeSettingsStore()
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
