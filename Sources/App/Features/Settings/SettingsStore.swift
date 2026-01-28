import Observation

@MainActor
@Observable
final class SettingsStore {
    struct State: Equatable {
        var currentPackVersion: Int
        var latestPackVersion: Int?
        var isChecking: Bool
        var isDownloading: Bool
        var downloadProgress: Double
        var statusMessage: String?
        var errorMessage: String?
    }

    enum Action: Equatable {
        case onAppear
        case checkUpdateTapped
        case downloadTapped
    }

    enum InternalAction: Equatable {
        case setChecking(Bool)
        case setDownloading(Bool)
        case setProgress(Double)
        case setLatestVersion(Int?)
        case setStatus(String?)
        case setError(String?)
    }

    private let sideEffect: SettingsSideEffect
    var state: State

    init(sideEffect: SettingsSideEffect) {
        self.sideEffect = sideEffect
        self.state = State(
            currentPackVersion: 1,
            latestPackVersion: nil,
            isChecking: false,
            isDownloading: false,
            downloadProgress: 0,
            statusMessage: nil,
            errorMessage: nil
        )
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear:
            break
        case .checkUpdateTapped:
            await checkUpdate()
        case .downloadTapped:
            await downloadPack()
        }
    }

    func send(_ action: Action) {
        Task { await send(action) }
    }
}

private extension SettingsStore {
    func checkUpdate() async {
        reduce(.setChecking(true))
        reduce(.setError(nil))
        let result = await sideEffect.fetchLatestPackVersion()
        switch result {
        case .success(let latest):
            reduce(.setLatestVersion(latest))
            if latest <= state.currentPackVersion {
                reduce(.setStatus("최신 상태입니다."))
            } else {
                reduce(.setStatus("업데이트 가능: v\(latest)"))
            }
        case .failure(let error):
            reduce(.setError(error.displayMessage))
        }
        reduce(.setChecking(false))
    }

    func downloadPack() async {
        reduce(.setDownloading(true))
        reduce(.setError(nil))
        reduce(.setProgress(0))
        let result = await sideEffect.downloadLatestPack(onProgress: { [weak self] progress in
            self?.reduce(.setProgress(progress))
        })
        switch result {
        case .success(let latest):
            reduce(.setLatestVersion(latest))
            reduce(.setStatus("다운로드 완료: v\(latest)"))
            reduce(.setProgress(1))
        case .failure(let error):
            reduce(.setError(error.displayMessage))
        }
        reduce(.setDownloading(false))
    }

    func reduce(_ action: InternalAction) {
        switch action {
        case .setChecking(let isChecking):
            state.isChecking = isChecking
        case .setDownloading(let isDownloading):
            state.isDownloading = isDownloading
        case .setProgress(let progress):
            state.downloadProgress = progress
        case .setLatestVersion(let latest):
            state.latestPackVersion = latest
        case .setStatus(let message):
            state.statusMessage = message
        case .setError(let message):
            state.errorMessage = message
        }
    }
}
