import SwiftUI

enum DSColor {
    static let primary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.56, green: 0.80, blue: 1.00, alpha: 1.00)
            : UIColor(red: 0.10, green: 0.32, blue: 0.72, alpha: 1.00)
    })

    static let secondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.38, green: 0.45, blue: 0.55, alpha: 1.00)
            : UIColor(red: 0.36, green: 0.42, blue: 0.50, alpha: 1.00)
    })

    static let background = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.08, blue: 0.10, alpha: 1.00)
            : UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00)
    })

    static let surface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1.00)
            : UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
    })

    static let textPrimary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1.00)
            : UIColor(red: 0.10, green: 0.12, blue: 0.15, alpha: 1.00)
    })

    static let textSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.72, green: 0.74, blue: 0.78, alpha: 1.00)
            : UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.00)
    })

    static let error = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 1.00, green: 0.45, blue: 0.45, alpha: 1.00)
            : UIColor(red: 0.86, green: 0.18, blue: 0.18, alpha: 1.00)
    })
}
