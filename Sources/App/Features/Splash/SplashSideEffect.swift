import Foundation

@MainActor
protocol SplashSideEffect {
    func ensurePackReady() async -> Result<Int, AppError>
}

@MainActor
final class SplashSideEffectImpl: SplashSideEffect {
    private let packFileStore: PackFileStore

    init(packFileStore: PackFileStore = PackFileStore()) {
        self.packFileStore = packFileStore
    }

    func ensurePackReady() async -> Result<Int, AppError> {
        do {
            let version = try packFileStore.ensurePackAvailable()
            return .success(version)
        } catch {
            return .failure(AppError.map(error))
        }
    }
}
