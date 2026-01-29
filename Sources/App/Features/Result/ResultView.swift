import Observation
import SwiftUI
import Domain
import Data
import DesignSystem

struct ResultView: View {
    @Bindable var store: ResultStore

    var body: some View {
        VStack(spacing: DSSpacing.l) {
            DSCard {
                VStack(spacing: DSSpacing.s) {
                    Text("점수")
                        .font(DSTypography.headline)
                        .foregroundStyle(DSColor.textPrimary)
                    Text("\(store.state.result.correctCount) / \(store.state.result.totalCount)")
                        .font(DSTypography.title)
                        .foregroundStyle(DSColor.primary)
                }
                .frame(maxWidth: .infinity)
            }

            DSButton("다시 시작", style: .primary) {
                store.send(.restartTapped)
            }

            Spacer()
        }
        .padding(DSSpacing.l)
        .background(DSColor.background)
        .navigationTitle("Result")
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let result = QuizResult(id: "1", date: .now, totalCount: 10, correctCount: 7, settings: .default)
    let packRepository = PackRepositoryImpl()
    let stageProgressRepository = StageProgressRepositoryImpl(packRepository: packRepository)
    let store = ResultStore(
        result: result,
        saveResultUseCase: SaveResultUseCase(
            repository: TriviaRepositoryImpl(
                apiClient: APIClient(),
                cache: QuestionCache(),
                historyStore: HistoryCache(),
                tokenStore: TriviaTokenStore()
            )
        ),
        updateStageProgressUseCase: UpdateStageProgressUseCase(repository: stageProgressRepository),
        router: AppRouter()
    )
    return NavigationStack { ResultView(store: store) }
}
