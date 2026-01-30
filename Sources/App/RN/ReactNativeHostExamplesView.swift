import SwiftUI
import DesignSystem

struct ReactNativeHostExamplesView: View {

    var body: some View {
        ReactNativeView(
            moduleName: "BrinyQuizRN",
            initialProperties: ["source": "stats"]
        )
        .navigationTitle("통계")
    }
}

#Preview {
    NavigationStack {
        ReactNativeHostExamplesView()
    }
}
