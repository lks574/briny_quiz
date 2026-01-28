import Observation
import SwiftUI

struct DashboardView: View {
    @Bindable var store: DashboardStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                Text("퀴즈 설정")
                    .font(DSTypography.title)
                    .foregroundStyle(DSColor.textPrimary)

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
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("질문 유형")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColor.textPrimary)
                        Picker("유형", selection: Binding(
                            get: { store.state.selectedType },
                            set: { store.send(.typeSelected($0)) }
                        )) {
                            Text("혼합").tag(QuestionType.mixed)
                            Text("객관식").tag(QuestionType.multiple)
                            Text("주관식").tag(QuestionType.boolean)
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
    let store = DashboardStore(
        sideEffect: DashboardSideEffectImpl(
            router: router,
            fetchPackCategoriesUseCase: fetchPackCategoriesUseCase
        ),
        initialSettings: .default
    )
    return NavigationStack { DashboardView(store: store) }
}
