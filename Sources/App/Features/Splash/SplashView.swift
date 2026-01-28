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
            } else if let message = store.state.errorMessage {
                VStack(spacing: DSSpacing.m) {
                    Text(message)
                        .font(DSTypography.body)
                        .foregroundStyle(DSColor.textSecondary)
                    DSButton("Retry", style: .primary) {
                        store.send(.retryTapped)
                    }
                }
            }
            Spacer()
        }
        .padding(DSSpacing.l)
        .background(DSColor.background)
        .task {
            await store.send(.onAppear)
        }
    }
}

#Preview {
    SplashView(store: SplashStore(sideEffect: SplashSideEffectImpl()))
}
