import Observation
import SwiftUI

@MainActor
@Observable
final class AppRouter {
    enum Route: Hashable {
        case questionDetail(QuizQuestion)
    }

    var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }
}
