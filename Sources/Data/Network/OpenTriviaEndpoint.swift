import Foundation

enum OpenTriviaEndpoint: Endpoint {
    case fetchQuestions(settings: QuizSettings, token: String?)
    case requestToken
    case resetToken(String)

    var baseURL: URL {
        URL(string: "https://opentdb.com")!
    }

    var path: String {
        switch self {
        case .fetchQuestions:
            return "api.php"
        case .requestToken, .resetToken:
            return "api_token.php"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .fetchQuestions(let settings, let token):
            var items: [URLQueryItem] = [
                URLQueryItem(name: "amount", value: String(settings.amount)),
                URLQueryItem(name: "difficulty", value: settings.difficulty.rawValue),
                URLQueryItem(name: "encode", value: "base64")
            ]
            if let categoryId = settings.categoryId, !categoryId.isEmpty {
                items.append(URLQueryItem(name: "category", value: categoryId))
            }
            switch settings.type {
            case .mixed:
                break
            case .multiple:
                items.append(URLQueryItem(name: "type", value: "multiple"))
            case .boolean:
                items.append(URLQueryItem(name: "type", value: "boolean"))
            }
            if let token {
                items.append(URLQueryItem(name: "token", value: token))
            }
            return items
        case .requestToken:
            return [URLQueryItem(name: "command", value: "request")]
        case .resetToken(let token):
            return [
                URLQueryItem(name: "command", value: "reset"),
                URLQueryItem(name: "token", value: token)
            ]
        }
    }
}
