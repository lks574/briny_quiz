import SwiftUI
import React

struct ReactNativeView: UIViewRepresentable {
    let moduleName: String
    let initialProperties: [String: Any]?

    init(moduleName: String, initialProperties: [String: Any]? = nil) {
        self.moduleName = moduleName
        self.initialProperties = initialProperties
    }

    func makeUIView(context: Context) -> RCTRootView {
        let view = RCTRootView(
            bridge: ReactBridgeManager.shared.bridge,
            moduleName: moduleName,
            initialProperties: initialProperties
        )
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: RCTRootView, context: Context) {
        uiView.appProperties = initialProperties
    }
}
