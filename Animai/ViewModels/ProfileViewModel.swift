import UIKit
import Combine

protocol ProfileViewModelProtocol {
    var userName: String { get }
    var mood: MoodCard? { get }
    var recommendations: [Recommendation] { get }
    var isLoading: Bool { get }
    func fetchData() async
    func logout()
}

final class ProfileViewModel: ProfileViewModelProtocol, ObservableObject {

    @Published private(set) var recommendations: [Recommendation] = []
    @Published private(set) var mood: MoodCard?
    @Published private(set) var isLoading: Bool = false

    private let tokenManager: TokenStoring
    private let authService: AuthServiceProtocol
    private let assistantService: AssistantServiceProtocol

    init(
        tokenManager: TokenStoring = TokenManager.shared,
        authService: AuthServiceProtocol = AuthService.shared,
        assistantService: AssistantServiceProtocol = AssistantService.shared
    ) {
        self.tokenManager = tokenManager
        self.authService = authService
        self.assistantService = assistantService
    }

    var userName: String {
        let name = tokenManager.getUser()?.name
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "Usuario" : name
    }

    @MainActor
    func fetchData() async {
        isLoading = true
        do {
            async let moodCard = assistantService.getMoodCard()
            async let recs = assistantService.getRecommendations()

            self.mood = try await moodCard
            self.recommendations = try await recs
        } catch {
            print("Error fetching profile data: \(error)")
        }
        isLoading = false
    }

    func logout() {
        authService.logout()
    }
}
