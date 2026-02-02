import SwiftUI
import DesignSystem

struct ReactNativeHostExamplesView: View {

    var body: some View {
        ReactNativeView(
            moduleName: "BrinyQuizRN",
            initialProperties: ["source": "stats"]
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ReactNativeHostExamplesView()
    }
}
