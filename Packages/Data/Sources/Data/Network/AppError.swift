import Foundation

public enum AppError: Error, Equatable {
    case invalidURL
    case transport(URLError)
    case httpStatus(Int, Data?)
    case decoding(String)
    case encoding(String)
    case unauthorized
    case forbidden
    case cancelled
    case triviaResponse(Int)
    case pack(String)
    case unknown(String)

    public var displayMessage: String {
        switch self {
        case .invalidURL:
            return "요청 URL이 올바르지 않습니다."
        case .transport:
            return "네트워크 연결을 확인해주세요."
        case .httpStatus(let code, _):
            return "서버 오류가 발생했습니다. (\(code))"
        case .decoding:
            return "데이터를 해석할 수 없습니다."
        case .encoding:
            return "요청을 만들 수 없습니다."
        case .unauthorized:
            return "인증이 필요합니다."
        case .forbidden:
            return "권한이 없습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .triviaResponse(let code):
            return "문제 요청에 실패했습니다. (code: \(code))"
        case .pack(let message):
            return message
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

extension AppError {
    public static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        if let urlError = error as? URLError {
            if urlError.code == .cancelled {
                return .cancelled
            }
            return .transport(urlError)
        }
        return .unknown(String(describing: error))
    }
}
