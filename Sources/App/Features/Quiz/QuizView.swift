import Observation
import SwiftUI

struct QuizView: View {
    @Bindable var store: QuizStore

    var body: some View {
        VStack(spacing: DSSpacing.l) {
            header

            if store.state.isLoading {
                ProgressView()
            } else if let message = store.state.errorMessage {
                DSCard {
                    Text(message)
                        .font(DSTypography.body)
                        .foregroundStyle(DSColor.textSecondary)
                }
            } else if let question = store.state.currentQuestion {
                questionView(question)
                answersView()
            }

            Spacer()

            footer
        }
        .padding(DSSpacing.l)
        .background(DSColor.background)
        .navigationTitle("Quiz")
        .task(id: store.state.settings) {
            await store.send(.onAppear)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("문제 \(store.state.currentIndex + 1) / \(max(store.state.questions.count, 1))")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColor.textSecondary)
                Text("남은 시간: \(store.state.timeRemaining)초")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColor.textPrimary)
            }
            Spacer()
            DSTag(text: store.state.settings.difficulty.rawValue.uppercased())
        }
    }

    private func questionView(_ question: QuizQuestion) -> some View {
        DSCard {
            Text(question.question)
                .font(DSTypography.headline)
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    private func answersView() -> some View {
        VStack(spacing: DSSpacing.m) {
            ForEach(store.state.currentAnswers, id: \.self) { answer in
                Button {
                    store.send(.answerSelected(answer))
                } label: {
                    HStack {
                        Text(answer)
                            .font(DSTypography.body)
                            .foregroundStyle(foregroundColor(for: answer))
                        Spacer()
                    }
                    .padding(DSSpacing.m)
                }
                .background(backgroundColor(for: answer))
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.m, style: .continuous))
            }
        }
    }

    private var footer: some View {
        HStack(spacing: DSSpacing.m) {
            DSButton("스킵", style: .secondary) {
                store.send(.skipTapped)
            }
            DSButton("다음", style: .primary) {
                store.send(.nextTapped)
            }
        }
    }

    private func backgroundColor(for answer: String) -> Color {
        guard let selected = store.state.selectedAnswer else {
            return DSColor.surface
        }
        if answer == selected {
            return DSColor.primary
        }
        return DSColor.surface
    }

    private func foregroundColor(for answer: String) -> Color {
        guard let selected = store.state.selectedAnswer else {
            return DSColor.textPrimary
        }
        if answer == selected {
            return DSColor.background
        }
        return DSColor.textPrimary
    }
}

#Preview {
    let router = AppRouter()
    let store = QuizStore(
        settings: .default,
        sideEffect: QuizSideEffectImpl(
            fetchQuestionsUseCase: FetchQuestionsUseCase(
                repository: TriviaRepositoryImpl(
                    apiClient: APIClient(),
                    cache: QuestionCache(),
                    historyStore: HistoryCache(),
                    tokenStore: TriviaTokenStore()
                )
            ),
            fetchPackQuestionsUseCase: FetchPackQuestionsUseCase(repository: PackRepositoryImpl()),
            router: router
        )
    )
    return NavigationStack { QuizView(store: store) }
}
