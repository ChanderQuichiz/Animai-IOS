import UIKit
import Combine

final class WellnessViewController: UIViewController {

    private let viewModel = WellnessViewModel()
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet private weak var recommendationsTableView: UITableView!
    @IBOutlet private weak var moodCard: MoodStatusCardView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !TokenManager.shared.hasValidSession() {
            AppNavigator.handleSessionExpired(from: self)
            return
        }

        Task {
            await viewModel.fetchData()
        }
    }

    private func setupTableView() {
        recommendationsTableView.dataSource = self
        recommendationsTableView.delegate = self
        recommendationsTableView.register(
            UINib(nibName: "RecommendationTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RecommendationCell"
        )
    }

    private func bindViewModel() {
        viewModel.$recommendations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recommendationsTableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$moodCard
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mood in
                if let mood = mood {
                    self?.moodCard.configure(with: mood)
                }
            }
            .store(in: &cancellables)
    }
}

extension WellnessViewController: UITableViewDataSource, UITableViewDelegate {
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
