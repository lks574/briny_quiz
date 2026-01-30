import Foundation
import React

@MainActor
final class ReactBridgeManager {
    static let shared = ReactBridgeManager()
    let bridge: RCTBridge

    private init() {
        bridge = RCTBridge(bundleURL: Self.bundleURL(), moduleProvider: nil, launchOptions: nil)
    }

    private static func bundleURL() -> URL {
        #if DEBUG
        guard let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(
            forBundleRoot: "index",
            fallbackExtension: nil
        ) else {
            fatalError("Failed to resolve Metro bundle URL")
        }
        return url
        #else
        guard let url = Bundle.main.url(forResource: "main", withExtension: "jsbundle") else {
            fatalError("main.jsbundle not found in app bundle")
        }
        return url
        #endif
    }
}
