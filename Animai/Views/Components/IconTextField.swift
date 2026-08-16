import UIKit

@IBDesignable
final class IconTextField: UIView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var trailingButton: UIButton!

    @IBInspectable var iconName: String? {
        didSet { iconView?.image = UIImage(systemName: iconName ?? "") }
    }

    @IBInspectable var placeholder: String? {
        didSet { textField?.placeholder = placeholder }
    }

    @IBInspectable var isSecure: Bool = false {
        didSet { textField?.isSecureTextEntry = isSecure }
    }

    var onTrailingTap: (() -> Void)?

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
        iconView?.tintColor = AppTheme.subtitle
        textField?.font = AppTheme.bodyFont()
        textField?.textColor = AppTheme.primaryDark
        separator?.backgroundColor = AppTheme.separator
        trailingButton?.tintColor = AppTheme.subtitle
        trailingButton?.addTarget(self, action: #selector(trailingTapped), for: .touchUpInside)
    }

    @objc private func trailingTapped() {
        onTrailingTap?()
    }
}
