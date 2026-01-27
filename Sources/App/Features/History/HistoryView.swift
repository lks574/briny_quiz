import Observation
import SwiftUI

struct HistoryView: View {
    @Bindable var store: HistoryStore

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                Text("히스토리")
                    .font(DSTypography.title)
                    .foregroundStyle(DSColor.textPrimary)

                if store.state.isLoading {
                    ProgressView()
                } else if store.state.items.isEmpty {
                    DSCard {
                        Text("기록이 없습니다.")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                } else {
                    ForEach(store.state.items) { item in
                        DSCard {
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                Text(dateFormatter.string(from: item.result.date))
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColor.textSecondary)
                                Text("점수: \(item.result.correctCount) / \(item.result.totalCount)")
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColor.textPrimary)
                            }
                        }
                    }
                }
            }
            .padding(DSSpacing.l)
        }
        .background(DSColor.background)
        .navigationTitle("History")
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let store = HistoryStore(fetchHistoryUseCase: FetchHistoryUseCase(repository: TriviaRepositoryImpl(apiClient: APIClient(), cache: QuestionCache(), historyStore: HistoryCache(), tokenStore: TriviaTokenStore())))
    return NavigationStack { HistoryView(store: store) }
}
