import UIKit

final class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel

    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var illustrationImageView: UIImageView!
    @IBOutlet private weak var emailField: IconTextField!
    @IBOutlet private weak var passwordField: IconTextField!
    @IBOutlet private weak var loginButton: PrimaryButton!
    @IBOutlet private weak var registerPromptLabel: UILabel!
    @IBOutlet private weak var registerButton: UIButton!

    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = LoginViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.background

        // Estilos de Outlets
        titleLabel.font = AppTheme.titleFont()
        titleLabel.textColor = AppTheme.primaryDark

        subtitleLabel.font = AppTheme.subtitleFont()
        subtitleLabel.textColor = AppTheme.subtitle

        registerPromptLabel.font = AppTheme.subtitleFont()
        registerPromptLabel.textColor = AppTheme.subtitle

        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        registerButton.setTitleColor(AppTheme.primaryBlue, for: .normal)

        // La configuración de iconos y placeholders se delega al Storyboard
        // (User Defined Runtime Attributes o Interface Builder)
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        emailField.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        passwordField.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        passwordField.textField.returnKeyType = .done
        passwordField.textField.delegate = self
    }

    @objc private func textChanged() {
        viewModel.email = emailField.textField.text ?? ""
        viewModel.password = passwordField.textField.text ?? ""
    }

    @objc private func loginTapped() {
        view.endEditing(true)
        viewModel.email = emailField.textField.text ?? ""
        viewModel.password = passwordField.textField.text ?? ""

        loginButton.setLoading(true)

        Task {
            do {
                _ = try await viewModel.login()
                loginButton.setLoading(false)
                AppNavigator.showMainApp(from: self)
            } catch {
                loginButton.setLoading(false)
                showAlert(message: error.localizedDescription)
            }
        }
    }

    @objc private func registerTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginTapped()
        return true
    }
}
