import SwiftUI

public struct DSCard<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(DSSpacing.l)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.l, style: .continuous))
            .dsShadow(DSElevation.low)
    }
}
