import SwiftUI

public enum DSElevation {
    public static let low = ShadowToken(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    public static let medium = ShadowToken(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
    public static let high = ShadowToken(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 8)
}

public struct ShadowToken {
    public let color: Color
    public let radius: Double
    public let x: Double
    public let y: Double

    public init(color: Color, radius: Double, x: Double, y: Double) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension View {
    func dsShadow(_ token: ShadowToken) -> some View {
        shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
    }
}
