import SwiftUI
import React

struct ReactNativeView: UIViewRepresentable {
    let moduleName: String
    let initialProperties: [String: Any]?

    init(moduleName: String, initialProperties: [String: Any]? = nil) {
        self.moduleName = moduleName
        self.initialProperties = initialProperties
    }

    func makeUIView(context: Context) -> UIView {
        let view = ReactBridgeManager.shared.makeRootView(
            moduleName: moduleName,
            initialProperties: initialProperties
        )
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let rootView = uiView as? RCTRootView {
            rootView.appProperties = initialProperties
        }
    }
}
