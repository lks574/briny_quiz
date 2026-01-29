import Observation
import SwiftUI
import Domain
import DesignSystem
import Data

struct DashboardView: View {
    @Bindable var store: DashboardStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("카테고리")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColor.textPrimary)
                        Picker("카테고리", selection: Binding(
                            get: { store.state.selectedCategoryId },
                            set: { store.send(.categorySelected($0)) }
                        )) {
                            ForEach(store.state.categories) { category in
                                Text(category.title).tag(category.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("난이도")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColor.textPrimary)
                        Picker("난이도", selection: Binding(
                            get: { store.state.selectedDifficulty },
                            set: { store.send(.difficultySelected($0)) }
                        )) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue.capitalized).tag(difficulty)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                DSCard {
                    HStack {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("문제 수")
                                .font(DSTypography.headline)
                                .foregroundStyle(DSColor.textPrimary)
                            Text("\(store.state.questionCount) 문제")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                        Spacer()
                        DSTag(text: "고정")
                    }
                }

                DSCard {
                    HStack {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("제한 시간")
                                .font(DSTypography.headline)
                                .foregroundStyle(DSColor.textPrimary)
                            Text("문제당 \(store.state.timeLimitSeconds)초")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                        Spacer()
                    }
                }

                DSButton("스테이지 선택", style: .primary) {
                    store.send(.stageTapped)
                }
                .disabled(store.state.isStarting)

                DSButton("빠른 시작", style: .secondary) {
                    store.send(.quickStartTapped)
                }

                if let errorMessage = store.state.errorMessage {
                    Text(errorMessage)
                        .font(DSTypography.body)
                        .foregroundStyle(DSColor.error)
                }
            }
            .padding(DSSpacing.l)
        }
        .background(DSColor.background)
        .navigationTitle("Dashboard")
        .task {
            await store.send(.onAppear)
        }
    }
}

#Preview {
    let router = AppRouter()
    let packRepository = PackRepositoryImpl()
    let fetchPackCategoriesUseCase = FetchPackCategoriesUseCase(repository: packRepository)
    let fetchAllPackStagesUseCase = FetchAllPackStagesUseCase(repository: packRepository)
    let stageProgressRepository = StageProgressRepositoryImpl(packRepository: packRepository)
    let fetchStageProgressUseCase = FetchStageProgressUseCase(repository: stageProgressRepository)
    let store = DashboardStore(
        sideEffect: DashboardSideEffectImpl(
            router: router,
            fetchPackCategoriesUseCase: fetchPackCategoriesUseCase,
            fetchAllPackStagesUseCase: fetchAllPackStagesUseCase,
            fetchStageProgressUseCase: fetchStageProgressUseCase
        ),
        initialSettings: .default
    )
    NavigationStack { DashboardView(store: store) }
}
