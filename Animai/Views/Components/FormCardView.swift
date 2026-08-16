import UIKit

final class FormCardView: UIView {

    @IBOutlet private weak var stackView: UIStackView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }

    private func setupStyles() {
        backgroundColor = AppTheme.cardBackground
        layer.cornerRadius = 16
        AppTheme.applyCardShadow(to: self)

        stackView?.axis = .vertical
        stackView?.spacing = 0
    }
}
