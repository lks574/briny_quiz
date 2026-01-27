import Foundation

final class APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let request = try endpoint.makeRequest()
        do {
            let (data, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse {
                guard (200...299).contains(http.statusCode) else {
                    if http.statusCode == 401 { throw AppError.unauthorized }
                    if http.statusCode == 403 { throw AppError.forbidden }
                    throw AppError.httpStatus(http.statusCode, data)
                }
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw AppError.decoding(String(describing: error))
            }
        } catch {
            throw AppError.map(error)
        }
    }
}
