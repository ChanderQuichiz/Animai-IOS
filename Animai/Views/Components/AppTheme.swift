import UIKit

enum AppTheme {

    static let background = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
    static let primaryBlue = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)
    static let primaryDark = UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 1)
    static let subtitle = UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1)
    static let separator = UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1)
    static let cardBackground = UIColor.white
    static let greenAccent = UIColor(red: 0.55, green: 0.78, blue: 0.45, alpha: 1)
    static let purpleAccent = UIColor(red: 0.70, green: 0.55, blue: 0.90, alpha: 1)
    static let tealAccent = UIColor(red: 0.45, green: 0.75, blue: 0.85, alpha: 1)
    static let detailBackground = UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1)
    static let detailTitle = UIColor(red: 0.10, green: 0.14, blue: 0.13, alpha: 1)

    static func titleFont(size: CGFloat = 32) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func bodyFont(size: CGFloat = 16) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func subtitleFont(size: CGFloat = 15) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func applyCardShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
    }
}
