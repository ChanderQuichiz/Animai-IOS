import UIKit
import Combine

final class ProfileViewController: UIViewController {

    private let viewModel: ProfileViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var moodCard: MoodStatusCardView!
    @IBOutlet private weak var recommendationsTitle: UILabel!
    @IBOutlet private weak var recommendationsTableView: UITableView!
    @IBOutlet private weak var profileTitle: UILabel!
    @IBOutlet private weak var logoutRow: UIControl!
    @IBOutlet private weak var logoutLabel: UILabel!

    @IBOutlet private weak var recommendationsTableHeightConstraint: NSLayoutConstraint!

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = AppTheme.primaryDark
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private let loadingIndicator = UIActivityIndicatorView(style: .large)

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

        if !TokenManager.shared.hasValidSession() {
            AppNavigator.handleSessionExpired(from: self)
            return
        }

        Task {
            await viewModel.fetchData()
        }
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

        // Ocultar el label del nombre superior
        nameLabel.isHidden = true

        // Asegurar que el contenido no se pegue al notch y tenga espacio al final
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)

        // Configurar Loading Indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = AppTheme.primaryBlue
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Estilos de Outlets (Fuentes y Colores)
        nameLabel.font = AppTheme.titleFont(size: 24)
        nameLabel.textColor = AppTheme.primaryDark
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byWordWrapping

        recommendationsTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        recommendationsTitle.textColor = AppTheme.primaryDark
        recommendationsTitle.numberOfLines = 0

        profileTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        profileTitle.textColor = AppTheme.primaryDark
        profileTitle.numberOfLines = 0

        logoutLabel.font = AppTheme.bodyFont()
        logoutLabel.textColor = AppTheme.primaryDark
        logoutLabel.numberOfLines = 0

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
        recommendationsTableView.rowHeight = UITableView.automaticDimension
        recommendationsTableView.estimatedRowHeight = 100
    }

    private func bindData() {
        nameLabel.text = viewModel.userName

        if let vm = viewModel as? ProfileViewModel {
            vm.$isLoading
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isLoading in
                    if isLoading {
                        self?.loadingIndicator.startAnimating()
                        self?.scrollView.alpha = 0.5
                    } else {
                        self?.loadingIndicator.stopAnimating()
                        self?.scrollView.alpha = 1.0
                    }
                }
                .store(in: &cancellables)

            vm.$mood
                .receive(on: DispatchQueue.main)
                .sink { [weak self] mood in
                    if let mood = mood {
                        self?.moodCard.configure(with: mood)
                    }
                }
                .store(in: &cancellables)

            vm.$recommendations
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.recommendationsTableView.reloadData()
                }
                .store(in: &cancellables)
        }

        // Observar el contentSize para ajustar la altura de la tabla automáticamente
        recommendationsTableView.publisher(for: \.contentSize)
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] size in
                self?.updateTableViewHeight(with: size.height)
            }
            .store(in: &cancellables)
    }

    private func updateTableViewHeight(with height: CGFloat) {
        if let constraint = recommendationsTableHeightConstraint {
            constraint.constant = height
        } else {
            for constraint in recommendationsTableView.constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = height
                }
            }
        }
        view.setNeedsLayout()
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
