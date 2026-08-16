import UIKit

final class MoodStatusCardView: UIView {

    @IBOutlet private weak var emojiLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

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
        addSubview(view)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }

    private func setupStyles() {
        backgroundColor = .clear
        layer.cornerRadius = 16
        AppTheme.applyCardShadow(to: self)

        emojiLabel?.font = UIFont.systemFont(ofSize: 48)
        titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel?.textColor = AppTheme.subtitle
        statusLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        statusLabel?.textColor = AppTheme.primaryDark
    }

    func configure(with mood: MoodCard) {
        emojiLabel?.text = mood.emoji
        titleLabel?.text = mood.title
        statusLabel?.text = mood.status
    }
}
