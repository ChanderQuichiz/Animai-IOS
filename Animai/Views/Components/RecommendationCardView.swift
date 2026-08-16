import UIKit

final class RecommendationCardView: UIControl {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    private var recommendation: Recommendation?

    var onTap: ((Recommendation) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    private func loadNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        guard let view = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else {
            return
        }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = false // Para que el UIControl capture los toques
        addSubview(view)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }

    private func setupStyles() {
        backgroundColor = AppTheme.cardBackground
        layer.cornerRadius = 12
        layer.borderWidth = 2
        addTarget(self, action: #selector(cardTapped), for: .touchUpInside)

        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel?.textColor = AppTheme.primaryDark
        subtitleLabel?.font = AppTheme.subtitleFont(size: 14)
        subtitleLabel?.textColor = AppTheme.subtitle
    }

    func configure(with recommendation: Recommendation) {
        self.recommendation = recommendation
        titleLabel?.text = recommendation.title
        subtitleLabel?.text = recommendation.subtitle
        layer.borderColor = recommendation.borderColor.cgColor
    }

    @objc private func cardTapped() {
        guard let recommendation = recommendation else { return }
        onTap?(recommendation)
    }
}
