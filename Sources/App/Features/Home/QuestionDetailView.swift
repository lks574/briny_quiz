import SwiftUI

struct QuestionDetailView: View {
    let question: QuizQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(question.body)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Question")
    }
}

#Preview {
    QuestionDetailView(question: QuizQuestion(id: "1", title: "Sample", body: "Preview body"))
}
