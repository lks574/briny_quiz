import Observation
import SwiftUI

struct StageView: View {
    @Bindable var store: StageStore

    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: DSSpacing.m)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                header

                if store.state.isLoading {
                    ProgressView()
                } else if let message = store.state.errorMessage {
                    DSCard {
                        Text(message)
                            .font(DSTypography.body)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: DSSpacing.m) {
                        ForEach(store.state.stages) { item in
                            Button {
                                store.send(.stageTapped(item.id))
                            } label: {
                                stageCard(item)
                            }
                            .buttonStyle(.plain)
                            .disabled(!item.isUnlocked)
                            .opacity(item.isUnlocked ? 1 : 0.5)
                        }
                    }
                }
            }
            .padding(DSSpacing.l)
        }
        .background(DSColor.background)
        .navigationTitle("Stages")
        .task {
            await store.send(.onAppear)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("카테고리: \(store.state.categoryId)")
                .font(DSTypography.caption)
                .foregroundStyle(DSColor.textSecondary)
            Text("난이도: \(store.state.difficulty.rawValue.uppercased())")
                .font(DSTypography.headline)
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    private func stageCard(_ item: StageStore.StageItem) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack {
                    Text(item.title)
                        .font(DSTypography.headline)
                        .foregroundStyle(DSColor.textPrimary)
                    Spacer()
                    if !item.isUnlocked {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(DSColor.textSecondary)
                    }
                }
                if item.isUnlocked {
                    Text("최고 점수 \(item.bestScore)/5")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.textSecondary)
                } else {
                    Text("잠금됨")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
        }
    }
}

#Preview {
    let packRepository = PackRepositoryImpl()
    let fetchPackStagesUseCase = FetchPackStagesUseCase(repository: packRepository)
    let store = StageStore(
        categoryId: "general",
        difficulty: .easy,
        sideEffect: StageSideEffectImpl(
            router: AppRouter(),
            fetchPackStagesUseCase: fetchPackStagesUseCase
        )
    )
    return NavigationStack { StageView(store: store) }
}
