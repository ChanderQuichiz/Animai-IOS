import UIKit

final class PrimaryButton: UIButton {

    enum Style {
        case dark
        case blue
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaultStyle()
    }

    private func setupDefaultStyle() {
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 28
        // La altura y los colores se prefieren configurar en el Storyboard
        // o mediante una función de estilo.
    }

    func applyStyle(_ style: Style) {
        setTitleColor(.white, for: .normal)
        switch style {
        case .dark:
            backgroundColor = AppTheme.primaryDark
        case .blue:
            backgroundColor = AppTheme.primaryBlue
        }
    }

    func setLoading(_ isLoading: Bool) {
        isEnabled = !isLoading
        alpha = isLoading ? 0.7 : 1
    }
}
