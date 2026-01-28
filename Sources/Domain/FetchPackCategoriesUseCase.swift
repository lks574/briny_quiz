import Foundation

struct FetchPackCategoriesUseCase {
    private let repository: PackRepository

    init(repository: PackRepository) {
        self.repository = repository
    }

    func execute() async throws -> [QuizCategory] {
        try await repository.fetchCategories()
    }
}
