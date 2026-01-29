import Foundation

public struct FetchPackCategoriesUseCase {
    private let repository: PackRepository

    public init(repository: PackRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [QuizCategory] {
        try await repository.fetchCategories()
    }
}
