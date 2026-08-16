import Foundation
import Combine

final class WellnessViewModel: ObservableObject {
    @Published var moodCard: MoodCard?
    @Published var recommendations: [Recommendation] = []
    @Published var isLoading = false
    @Published var error: String?

    private let assistantService: AssistantServiceProtocol

    init(assistantService: AssistantServiceProtocol = AssistantService.shared) {
        self.assistantService = assistantService
    }

    @MainActor
    func fetchData() async {
        isLoading = true
        error = nil
        do {
            async let mood = assistantService.getMoodCard()
            async let recs = assistantService.getRecommendations()

            self.moodCard = try await mood
            self.recommendations = try await recs
        } catch {
            self.error = "Error al cargar datos de bienestar"
            print("Wellness fetch error: \(error)")
        }
        isLoading = false
    }
}
