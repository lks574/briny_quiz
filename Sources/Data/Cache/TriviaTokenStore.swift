import Foundation

actor TriviaTokenStore {
    private let expiryInterval: TimeInterval = 6 * 60 * 60
    private var token: String?
    private var lastUsedAt: Date?

    func currentToken(now: Date = Date()) -> String? {
        guard let token, let lastUsedAt else {
            return nil
        }
        if now.timeIntervalSince(lastUsedAt) > expiryInterval {
            return nil
        }
        return token
    }

    func updateToken(_ token: String, now: Date = Date()) {
        self.token = token
        self.lastUsedAt = now
    }

    func markUsed(now: Date = Date()) {
        if token != nil {
            lastUsedAt = now
        }
    }

    func clear() {
        token = nil
        lastUsedAt = nil
    }
}
