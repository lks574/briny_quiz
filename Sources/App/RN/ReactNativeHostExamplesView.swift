import SwiftUI
import DesignSystem

struct ReactNativeHostView: View {
    let source: String

    init(source: String) {
        self.source = source
    }

    var body: some View {
        ReactNativeView(
            moduleName: "BrinyQuizRN",
            initialProperties: ["source": source]
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ReactNativeHostView(source: "stats")
    }
}
