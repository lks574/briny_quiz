import Observation
import SwiftUI

struct HomeView: View {
    @Bindable var store: HomeStore

    var body: some View {
        List {
            if store.state.isLoading {
                loadingRow
            }

            if let message = store.state.errorMessage {
                errorRow(message: message)
            }

            ForEach(store.state.questions) { question in
                Button(question.title) {
                    store.send(.questionSelected(question))
                }
            }
        }
        .navigationTitle("Briny Quiz")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Reload") {
                    store.send(.reloadTapped)
                }
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
        }
    }

    private func errorRow(message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
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
