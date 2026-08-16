import UIKit

final class ProfileViewController: UIViewController {

    private let viewModel: ProfileViewModelProtocol

    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var moodCard: MoodStatusCardView!
    @IBOutlet private weak var recommendationsTitle: UILabel!
    @IBOutlet private weak var recommendationsTableView: UITableView!
    @IBOutlet private weak var profileTitle: UILabel!
    @IBOutlet private weak var logoutRow: UIControl!
    @IBOutlet private weak var logoutLabel: UILabel!

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = AppTheme.primaryDark
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    init(viewModel: ProfileViewModelProtocol = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = ProfileViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationAppearance()
        refreshUserName()
    }

    private func refreshUserName() {
        nameLabel.text = viewModel.userName
    }

    private var isTabRoot: Bool {
        tabBarController != nil && navigationController?.viewControllers.first == self
    }

    private func updateNavigationAppearance() {
        if isTabRoot {
            navigationController?.setNavigationBarHidden(true, animated: false)
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        navigationItem.title = nil

        // Estilos de Outlets (Fuentes y Colores)
        nameLabel.font = AppTheme.titleFont(size: 24)
        nameLabel.textColor = AppTheme.primaryDark

        recommendationsTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        recommendationsTitle.textColor = AppTheme.primaryDark

        profileTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        profileTitle.textColor = AppTheme.primaryDark

        logoutLabel.font = AppTheme.bodyFont()
        logoutLabel.textColor = AppTheme.primaryDark

        logoutRow.backgroundColor = AppTheme.cardBackground
        logoutRow.layer.cornerRadius = 12
        logoutRow.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    private func setupTableView() {
        recommendationsTableView.dataSource = self
        recommendationsTableView.delegate = self
        recommendationsTableView.register(
            UINib(nibName: "RecommendationTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RecommendationCell"
        )
        recommendationsTableView.isScrollEnabled = false
    }

    private func bindData() {
        nameLabel.text = viewModel.userName
        moodCard.configure(with: viewModel.mood)
        recommendationsTableView.reloadData()
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Cerrar sesión",
            message: "¿Estás seguro de que deseas salir?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Salir", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.viewModel.logout()
            AppNavigator.showLogin(from: self)
        })
        present(alert, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recommendations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationCell", for: indexPath) as? RecommendationTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.recommendations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recommendation = viewModel.recommendations[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecommendationDetailViewController") as? RecommendationDetailViewController {
            detailVC.setRecommendation(recommendation)
            present(detailVC, animated: true)
        }
    }
}
