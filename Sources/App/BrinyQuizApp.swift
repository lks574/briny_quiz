import SwiftUI

@main
struct BrinyQuizApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(store: container.makeHomeStore(), router: container.appRouter)
        }
    }
}
