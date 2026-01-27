import SwiftUI

struct DSButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    init(_ title: String, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.m)
                .padding(.horizontal, DSSpacing.l)
        }
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.m, style: .continuous))
        .opacity(isEnabled ? 1.0 : 0.6)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DSColor.primary
        case .secondary:
            return DSColor.surface
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return DSColor.background
        case .secondary:
            return DSColor.textPrimary
        }
    }
}
