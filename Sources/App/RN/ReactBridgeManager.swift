import Foundation
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

@MainActor
final class ReactBridgeManager {
    static let shared = ReactBridgeManager()
    private let factoryDelegate: ReactFactoryDelegate
    private let factory: RCTReactNativeFactory

    private init() {
        factoryDelegate = ReactFactoryDelegate()
        factoryDelegate.dependencyProvider = RCTAppDependencyProvider()
        factory = RCTReactNativeFactory(delegate: factoryDelegate)
    }

    static func bundleURL() -> URL {
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

    func makeRootView(moduleName: String, initialProperties: [String: Any]? = nil) -> UIView {
        factory.rootViewFactory.view(withModuleName: moduleName, initialProperties: initialProperties)
    }
}

private final class ReactFactoryDelegate: RCTDefaultReactNativeFactoryDelegate {
    override func bundleURL() -> URL? {
        ReactBridgeManager.bundleURL()
    }
}
