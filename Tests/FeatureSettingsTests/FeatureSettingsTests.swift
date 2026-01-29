import XCTest
@testable import FeatureSettings
import Data

@MainActor
final class FeatureSettingsTests: XCTestCase {
    func testCheckUpdateSuccessLatestUpToDate() async {
        let sideEffect = MockSettingsSideEffect(fetchResult: .success(1))
        let store = SettingsStore(sideEffect: sideEffect)

        await store.send(.checkUpdateTapped)

        XCTAssertEqual(store.state.latestPackVersion, 1)
        XCTAssertEqual(store.state.statusMessage, "최신 상태입니다.")
        XCTAssertNil(store.state.errorMessage)
        XCTAssertFalse(store.state.isChecking)
    }

    func testCheckUpdateSuccessLatestAvailable() async {
        let sideEffect = MockSettingsSideEffect(fetchResult: .success(3))
        let store = SettingsStore(sideEffect: sideEffect)

        await store.send(.checkUpdateTapped)

        XCTAssertEqual(store.state.latestPackVersion, 3)
        XCTAssertEqual(store.state.statusMessage, "업데이트 가능: v3")
        XCTAssertNil(store.state.errorMessage)
        XCTAssertFalse(store.state.isChecking)
    }

    func testCheckUpdateFailureSetsError() async {
        let sideEffect = MockSettingsSideEffect(fetchResult: .failure(.unknown("테스트 오류")))
        let store = SettingsStore(sideEffect: sideEffect)

        await store.send(.checkUpdateTapped)

        XCTAssertNotNil(store.state.errorMessage)
        XCTAssertEqual(store.state.errorMessage, AppError.unknown("테스트 오류").displayMessage)
        XCTAssertFalse(store.state.isChecking)
    }

    func testDownloadSuccessUpdatesProgressAndStatus() async {
        let sideEffect = MockSettingsSideEffect(downloadResult: .success(2), progressValues: [0.2, 0.6, 1.0])
        let store = SettingsStore(sideEffect: sideEffect)

        await store.send(.downloadTapped)

        XCTAssertEqual(store.state.latestPackVersion, 2)
        XCTAssertEqual(store.state.statusMessage, "다운로드 완료: v2")
        XCTAssertEqual(store.state.downloadProgress, 1)
        XCTAssertNil(store.state.errorMessage)
        XCTAssertFalse(store.state.isDownloading)
        XCTAssertEqual(sideEffect.reportedProgress, [0.2, 0.6, 1.0])
    }

    func testDownloadFailureSetsError() async {
        let sideEffect = MockSettingsSideEffect(downloadResult: .failure(.unknown("다운로드 실패")))
        let store = SettingsStore(sideEffect: sideEffect)

        await store.send(.downloadTapped)

        XCTAssertEqual(store.state.errorMessage, AppError.unknown("다운로드 실패").displayMessage)
        XCTAssertFalse(store.state.isDownloading)
    }
}

@MainActor
private final class MockSettingsSideEffect: SettingsSideEffect {
    let fetchResult: Result<Int, AppError>
    let downloadResult: Result<Int, AppError>
    let progressValues: [Double]
    private(set) var reportedProgress: [Double] = []

    init(
        fetchResult: Result<Int, AppError> = .success(1),
        downloadResult: Result<Int, AppError> = .success(1),
        progressValues: [Double] = []
    ) {
        self.fetchResult = fetchResult
        self.downloadResult = downloadResult
        self.progressValues = progressValues
    }

    func fetchLatestPackVersion() async -> Result<Int, AppError> {
        fetchResult
    }

    func downloadLatestPack(onProgress: @escaping (Double) -> Void) async -> Result<Int, AppError> {
        for value in progressValues {
            reportedProgress.append(value)
            onProgress(value)
        }
        return downloadResult
    }
}
