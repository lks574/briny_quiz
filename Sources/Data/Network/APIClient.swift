import Foundation

final class APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let request = try endpoint.makeRequest()
        logRequest(request)
        do {
            let (data, response) = try await session.data(for: request)
            logResponse(response, data: data)
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

    private func logRequest(_ request: URLRequest) {
#if DEBUG
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "unknown-url"
        print("⬆️ [API] \(method) \(url)")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("   body: \(bodyString)")
        }
#endif
    }

    private func logResponse(_ response: URLResponse, data: Data) {
#if DEBUG
        if let http = response as? HTTPURLResponse {
            print("⬇️ [API] status: \(http.statusCode)")
        } else {
            print("⬇️ [API] response received")
        }
        if let bodyString = String(data: data, encoding: .utf8) {
            print("   body: \(bodyString)")
        }
#endif
    }
}
