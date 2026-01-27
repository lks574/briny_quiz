import Observation
import SwiftUI

struct HomeView: View {
    @Bindable var store: HomeStore

    var body: some View {
        List {
            if store.state.isLoading {
                loadingRow
                    .listRowBackground(DSColor.surface)
            }

            if let message = store.state.errorMessage {
                errorRow(message: message)
                    .listRowBackground(DSColor.surface)
            }

            ForEach(store.state.questions) { question in
                Button {
                    store.send(.questionSelected(question))
                } label: {
                    Text(question.title)
                        .font(DSTypography.body)
                        .foregroundStyle(DSColor.textPrimary)
                }
                .listRowBackground(DSColor.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(DSColor.background)
        .navigationTitle("Briny Quiz")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Reload") {
                    store.send(.reloadTapped)
                }
                .font(DSTypography.body.weight(.semibold))
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }

    private var loadingRow: some View {
        HStack {
            ProgressView()
            Text("Loading")
                .font(DSTypography.body)
                .foregroundStyle(DSColor.textSecondary)
        }
    }

    private func errorRow(message: String) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("Something went wrong")
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColor.textPrimary)
                Text(message)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
    }
}

#Preview {
    let router = AppRouter()
    let store = HomeStore(
        fetchQuizUseCase: FetchQuizUseCase(repository: QuizRepositoryImpl(cache: QuizCache())),
        router: router
    )
    return NavigationStack { HomeView(store: store) }
}
