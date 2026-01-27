import Observation
import SwiftUI

struct RootView: View {
    @Bindable var store: HomeStore
    @Bindable var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView(store: store)
                .navigationDestination(for: AppRouter.Route.self) { route in
                    switch route {
                    case .questionDetail(let question):
                        QuestionDetailView(question: question)
                    }
                }
        }
    }
}

#Preview {
    let container = AppContainer()
    return RootView(store: container.makeHomeStore(), router: container.appRouter)
}
