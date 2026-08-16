import UIKit

final class RegisterViewController: UIViewController {

    private let viewModel: RegisterViewModel
    private let datePicker = UIDatePicker()

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var fullNameField: IconTextField!
    @IBOutlet private weak var emailField: IconTextField!
    @IBOutlet private weak var passwordField: IconTextField!
    @IBOutlet private weak var confirmPasswordField: IconTextField!
    @IBOutlet private weak var birthDateField: IconTextField!
    @IBOutlet private weak var registerButton: PrimaryButton!
    @IBOutlet private weak var loginPromptLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!

    init(viewModel: RegisterViewModel = RegisterViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = RegisterViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupDatePicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.background

        titleLabel.font = AppTheme.titleFont()
        titleLabel.textColor = AppTheme.primaryDark

        subtitleLabel.font = AppTheme.subtitleFont()
        subtitleLabel.textColor = AppTheme.subtitle

        loginPromptLabel.font = AppTheme.subtitleFont()
        loginPromptLabel.textColor = AppTheme.subtitle

        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        loginButton.setTitleColor(AppTheme.primaryBlue, for: .normal)

        birthDateField.textField.tintColor = .clear
    }

    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.locale = Locale(identifier: "es_ES")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        birthDateField.textField.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(donePickingDate))
        toolbar.setItems([.flexibleSpace(), done], animated: false)
        birthDateField.textField.inputAccessoryView = toolbar
    }

    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        birthDateField.onTrailingTap = { [weak self] in
            self?.birthDateField.textField.becomeFirstResponder()
        }

        [fullNameField, emailField, passwordField, confirmPasswordField].forEach {
            $0?.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        }
    }

    @objc private func textChanged() {
        syncViewModel()
    }

    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        viewModel.birthDate = formatter.string(from: datePicker.date)

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.locale = Locale(identifier: "es_ES")
        birthDateField.textField.text = displayFormatter.string(from: datePicker.date)
    }

    @objc private func donePickingDate() {
        dateChanged()
        birthDateField.textField.resignFirstResponder()
    }

    @objc private func registerTapped() {
        view.endEditing(true)
        syncViewModel()

        registerButton.setLoading(true)

        Task {
            do {
                _ = try await viewModel.register()
                registerButton.setLoading(false)
                AppNavigator.showMainApp(from: self)
            } catch {
                registerButton.setLoading(false)
                showAlert(message: error.localizedDescription)
            }
        }
    }

    @objc private func loginTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func syncViewModel() {
        viewModel.name = fullNameField.textField.text ?? ""
        viewModel.email = emailField.textField.text ?? ""
        viewModel.password = passwordField.textField.text ?? ""
        viewModel.confirmPassword = confirmPasswordField.textField.text ?? ""
        viewModel.gender = "No especificado" // Valor por defecto ya que no hay campo en UI
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
