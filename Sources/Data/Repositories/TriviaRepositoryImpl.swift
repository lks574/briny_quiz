import Foundation

struct TriviaRepositoryImpl: TriviaRepository {
    private let apiClient: APIClient
    private let cache: QuestionCache
    private let historyStore: HistoryCache
    private let tokenStore: TriviaTokenStore
    private let ttl: TimeInterval = 24 * 60 * 60

    init(
        apiClient: APIClient,
        cache: QuestionCache,
        historyStore: HistoryCache,
        tokenStore: TriviaTokenStore
    ) {
        self.apiClient = apiClient
        self.cache = cache
        self.historyStore = historyStore
        self.tokenStore = tokenStore
    }

    func fetchQuestions(settings: QuizSettings, policy: CachePolicy) async throws -> [QuizQuestion] {
        let now = Date()
        if let cached = await cache.load(for: settings) {
            let isFresh = now.timeIntervalSince(cached.timestamp) <= ttl
            if isFresh {
                switch policy {
                case .cacheFirst, .cacheOnly:
                    return cached.questions
                case .networkFirst, .networkOnly:
                    break
                }
            } else if policy == .cacheOnly {
                throw AppError.unknown("캐시가 만료되었습니다.")
            }
        } else if policy == .cacheOnly {
            throw AppError.unknown("캐시가 없습니다.")
        }

        do {
            let questions = try await fetchFromNetwork(settings: settings)
            await cache.save(questions, for: settings, now: now)
            return questions
        } catch {
            if policy == .networkFirst, let cached = await cache.load(for: settings) {
                return cached.questions
            }
            throw error
        }
    }

    func saveResult(_ result: QuizResult) async {
        let item = HistoryItem(id: UUID().uuidString, result: result)
        await historyStore.append(item)
    }

    func fetchHistory() async -> [HistoryItem] {
        await historyStore.load()
    }

    private func fetchFromNetwork(settings: QuizSettings) async throws -> [QuizQuestion] {
        let token = await validToken()
        let endpoint = OpenTriviaEndpoint.fetchQuestions(settings: settings, token: token)
        let response = try await apiClient.request(endpoint, as: TriviaResponseDTO.self)
        switch response.responseCode {
        case 0:
            await tokenStore.markUsed()
            return response.results.compactMap { mapQuestion($0) }
        case 3, 4:
            await tokenStore.clear()
            let refreshed = await validToken()
            let retryEndpoint = OpenTriviaEndpoint.fetchQuestions(settings: settings, token: refreshed)
            let retryResponse = try await apiClient.request(retryEndpoint, as: TriviaResponseDTO.self)
            if retryResponse.responseCode == 0 {
                await tokenStore.markUsed()
                return retryResponse.results.compactMap { mapQuestion($0) }
            }
            throw AppError.triviaResponse(retryResponse.responseCode)
        default:
            throw AppError.triviaResponse(response.responseCode)
        }
    }

    private func validToken() async -> String? {
        if let token = await tokenStore.currentToken() {
            return token
        }
        let tokenResponse = try? await apiClient.request(OpenTriviaEndpoint.requestToken, as: TriviaTokenResponseDTO.self)
        if let tokenResponse, tokenResponse.responseCode == 0 {
            await tokenStore.updateToken(tokenResponse.token)
            return tokenResponse.token
        }
        return nil
    }

    private func mapQuestion(_ dto: TriviaQuestionDTO) -> QuizQuestion? {
        guard let difficulty = Difficulty(rawValue: decodeBase64(dto.difficulty).lowercased()) else { return nil }
        let typeString = decodeBase64(dto.type).lowercased()
        let type: QuestionType = typeString == "multiple" ? .multiple : .boolean
        let question = decodeBase64(dto.question)
        let correct = decodeBase64(dto.correctAnswer)
        let incorrect = dto.incorrectAnswers.map { decodeBase64($0) }
        return QuizQuestion(
            id: UUID().uuidString,
            category: decodeBase64(dto.category),
            difficulty: difficulty,
            type: type,
            question: question,
            correctAnswer: correct,
            incorrectAnswers: incorrect
        )
    }

    private func decodeBase64(_ value: String) -> String {
        guard let data = Data(base64Encoded: value), let decoded = String(data: data, encoding: .utf8) else {
            return value
        }
        return decoded
    }
}
