import Observation
import SwiftUI

struct SplashView: View {
    @Bindable var store: SplashStore

    var body: some View {
        VStack(spacing: DSSpacing.l) {
            Spacer()
            Text("Briny Quiz")
                .font(DSTypography.title)
                .foregroundStyle(DSColor.textPrimary)

            if store.state.isLoading {
                ProgressView()
            } else if store.state.errorMessage != nil {
                DSButton("Retry", style: .primary) {
                    store.send(.retryTapped)
                }
            }
            Spacer()
        }
        .padding(DSSpacing.l)
        .background(DSColor.background)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    SplashView(store: SplashStore())
}
