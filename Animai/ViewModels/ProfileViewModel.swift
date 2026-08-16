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

        // Ejecutamos ambas peticiones en paralelo pero manejamos sus errores de forma independiente
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    let moodData = try await self.assistantService.getMoodCard()
                    await MainActor.run { self.mood = moodData }
                } catch {
                    print("Error fetching mood: \(error)")
                }
            }

            group.addTask {
                do {
                    let recs = try await self.assistantService.getRecommendations()
                    await MainActor.run { self.recommendations = recs }
                } catch {
                    print("Error fetching recommendations: \(error)")
                }
            }
        }

        isLoading = false
    }

    func logout() {
        authService.logout()
    }
}
