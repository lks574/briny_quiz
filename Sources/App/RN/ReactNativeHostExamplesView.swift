import SwiftUI
import DesignSystem

struct ReactNativeHostExamplesView: View {
    @State private var showsModal = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("RN Embedded")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColor.textPrimary)

                        ReactNativeView(
                            moduleName: "BrinyQuizRN",
                            initialProperties: ["source": "embedded"]
                        )
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("RN Sheet")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColor.textPrimary)

                        DSButton("Open RN Sheet", style: .primary) {
                            showsModal = true
                        }
                    }
                }
            }
            .padding(DSSpacing.l)
        }
        .background(DSColor.background)
        .navigationTitle("React Native")
        .sheet(isPresented: $showsModal) {
            NavigationStack {
                ReactNativeView(
                    moduleName: "BrinyQuizRN",
                    initialProperties: ["source": "sheet"]
                )
                .navigationTitle("RN Sheet")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReactNativeHostExamplesView()
    }
}
