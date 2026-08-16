import UIKit

final class RecommendationTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        containerView.backgroundColor = AppTheme.cardBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 2

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = AppTheme.primaryDark
        titleLabel.numberOfLines = 0

        subtitleLabel.font = AppTheme.subtitleFont(size: 14)
        subtitleLabel.textColor = AppTheme.subtitle
        subtitleLabel.numberOfLines = 0
    }

    func configure(with recommendation: Recommendation) {
        titleLabel.text = recommendation.title
        subtitleLabel.text = recommendation.subtitle
        containerView.layer.borderColor = recommendation.borderColor.cgColor
    }
}
