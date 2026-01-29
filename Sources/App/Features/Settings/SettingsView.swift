import Observation
import SwiftUI

struct SettingsView: View {
    @Bindable var store: SettingsStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("오프라인 팩")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColor.textPrimary)

                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("현재 버전: v\(store.state.currentPackVersion)")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColor.textSecondary)
                            if let latest = store.state.latestPackVersion {
                                Text("최신 버전: v\(latest)")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                        }

                        if store.state.isDownloading {
                            ProgressView(value: store.state.downloadProgress)
                                .tint(DSColor.primary)
                        }

                        if let status = store.state.statusMessage {
                            Text(status)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.textSecondary)
                        }

                        if let error = store.state.errorMessage {
                            Text(error)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.error)
                        }

                        HStack(spacing: DSSpacing.m) {
                            DSButton("업데이트 확인", style: .secondary) {
                                store.send(.checkUpdateTapped)
                            }
                            .disabled(store.state.isChecking || store.state.isDownloading)

                            DSButton("다운로드", style: .primary) {
                                store.send(.downloadTapped)
                            }
                            .disabled(store.state.isDownloading)
                        }
                    }
                }
            }
            .padding(DSSpacing.l)
        }
        .background(DSColor.background)
        .navigationTitle("Settings")
        .task {
            await store.send(.onAppear)
        }
    }
}

#Preview {
    let store = SettingsStore(sideEffect: SettingsSideEffectImpl())
    return NavigationStack { SettingsView(store: store) }
}
