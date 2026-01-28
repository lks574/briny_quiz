import SwiftUI

@main
struct BrinyQuizApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            AppEntryView(container: container, router: container.appRouter)
                .onOpenURL { url in
                    container.appRouter.handleDeepLink(url)
                }
        }
    }
}
