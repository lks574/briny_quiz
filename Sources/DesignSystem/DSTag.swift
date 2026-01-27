import SwiftUI

struct DSTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DSTypography.caption)
            .padding(.vertical, DSSpacing.xs)
            .padding(.horizontal, DSSpacing.s)
            .background(DSColor.secondary.opacity(0.15))
            .foregroundStyle(DSColor.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.s, style: .continuous))
    }
}
