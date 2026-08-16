import UIKit

final class RecommendationDetailViewController: UIViewController {

    private var recommendation: Recommendation?

    // MARK: - Outlets
    @IBOutlet private weak var backdropView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var handleView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePresentation()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        // Estilos de Outlets
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        backdropView.alpha = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        backdropView.addGestureRecognizer(tapGesture)

        containerView.backgroundColor = AppTheme.detailBackground
        containerView.layer.cornerRadius = 28
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        handleView.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1)
        handleView.layer.cornerRadius = 2.5

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = AppTheme.primaryDark
        closeButton.backgroundColor = UIColor(red: 0.88, green: 0.93, blue: 0.90, alpha: 1)
        closeButton.layer.cornerRadius = 18
        closeButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = AppTheme.detailTitle

        detailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        detailLabel.textColor = AppTheme.subtitle

        containerView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
    }

    private func configureContent() {
        guard let recommendation = recommendation else { return }
        titleLabel.text = recommendation.title
        detailLabel.text = recommendation.detailText
    }

    private func animatePresentation() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.4) {
            self.backdropView.alpha = 1
            self.containerView.transform = .identity
        }
    }

    @objc private func dismissTapped() {
        UIView.animate(withDuration: 0.25, animations: {
            self.backdropView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }

    func setRecommendation(_ recommendation: Recommendation) {
        self.recommendation = recommendation
    }
}
