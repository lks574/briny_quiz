import Observation
import SwiftUI
import Domain
import DesignSystem

public struct HistoryView: View {
    @Bindable var store: HistoryStore

    public init(store: HistoryStore) {
        self.store = store
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("기간")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColor.textPrimary)

                        Picker("기간", selection: Binding(
                            get: { store.state.dateFilter },
                            set: { store.send(.dateFilterChanged($0)) }
                        )) {
                            ForEach(HistoryStore.DateFilter.allCases, id: \.self) { filter in
                                Text(filter.title).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                if store.state.isLoading {
                    ProgressView()
                } else if store.state.displayItems.isEmpty {
                    DSCard {
                        Text("기록이 없습니다.")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                } else {
                    ForEach(store.state.displayItems) { item in
                        DSCard {
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                HStack {
                                    Text(dateFormatter.string(from: item.date))
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColor.textSecondary)
                                    Spacer()
                                    Text(item.isSuccess ? "성공" : "실패")
                                        .font(DSTypography.caption)
                                        .foregroundStyle(item.isSuccess ? DSColor.primary : DSColor.error)
                                }
                                Text("점수: \(item.correctCount) / \(item.totalCount)")
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
    struct MockTriviaRepository: TriviaRepository {
        func fetchQuestions(settings: QuizSettings, policy: CachePolicy) async throws -> [QuizQuestion] { [] }
        func saveResult(_ result: QuizResult) async {}
        func fetchHistory() async -> [HistoryItem] { [] }
    }
    let store = HistoryStore(fetchHistoryUseCase: FetchHistoryUseCase(repository: MockTriviaRepository()))
    return NavigationStack { HistoryView(store: store) }
}
