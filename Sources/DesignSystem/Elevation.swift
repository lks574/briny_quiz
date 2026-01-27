import SwiftUI

enum DSElevation {
    static let low = ShadowToken(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    static let medium = ShadowToken(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
    static let high = ShadowToken(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 8)
}

struct ShadowToken {
    let color: Color
    let radius: Double
    let x: Double
    let y: Double
}

extension View {
    func dsShadow(_ token: ShadowToken) -> some View {
        shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
    }
}
