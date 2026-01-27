import SwiftUI

struct QuestionDetailView: View {
    let question: QuizQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text(question.title)
                .font(DSTypography.headline)
                .foregroundStyle(DSColor.textPrimary)
            Text(question.body)
                .font(DSTypography.body)
                .foregroundStyle(DSColor.textSecondary)
            Spacer()
        }
        .padding(DSSpacing.l)
        .background(DSColor.background)
        .navigationTitle("Question")
    }
}

#Preview {
    QuestionDetailView(question: QuizQuestion(id: "1", title: "Sample", body: "Preview body"))
}
