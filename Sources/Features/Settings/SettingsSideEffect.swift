import Foundation
import Data

@MainActor
public protocol SettingsSideEffect {
    func fetchLatestPackVersion() async -> Result<Int, AppError>
    func downloadLatestPack(onProgress: @escaping (Double) -> Void) async -> Result<Int, AppError>
}

@MainActor
public final class SettingsSideEffectImpl: SettingsSideEffect {
    public init() {}

    public func fetchLatestPackVersion() async -> Result<Int, AppError> {
        return .failure(.unknown("팩 서버 설정이 필요합니다."))
    }

    public func downloadLatestPack(onProgress: @escaping (Double) -> Void) async -> Result<Int, AppError> {
        _ = onProgress
        return .failure(.unknown("팩 다운로드 서버 설정이 필요합니다."))
    }
}
