import Foundation

final class ApiService {
    static let shared = ApiService()
    private let baseURL = "http://localhost:8080"

    private init() {}

    func request<T: Decodable>(endpoint: String, method: String, body: [String: Any]? = nil, token: String? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if httpResponse.statusCode == 401 {
                NotificationCenter.default.post(name: NSNotification.Name("animai.session.expired"), object: nil)
                throw ApiError.unauthorized
            }
            throw ApiError.serverError(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            // Si el backend usa snake_case, podríamos necesitar:
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw ApiError.decodingError
        }
    }
}
