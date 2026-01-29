import Foundation

public struct PackFileStore {
    private let fileManager = FileManager.default
    private let bundledVersion = 1

    public init() {}

    func currentPackURL() -> URL? {
        if let downloaded = downloadedPackURL() {
            return downloaded
        }
        return bundledPackURL()
    }

    public func ensurePackAvailable() throws -> Int {
        if let downloaded = downloadedPackURL() {
            return extractedVersion(from: downloaded)
        }
        guard let bundled = bundledPackURL() else {
            throw AppError.pack("번들 팩 파일을 찾을 수 없습니다.")
        }
        let version = bundledVersion
        let destURL = try copyBundledPackIfNeeded(bundled, version: version)
        try writeCurrentVersion(version, directory: destURL.deletingLastPathComponent())
        return version
    }

    private func downloadedPackURL() -> URL? {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let dir = support?.appendingPathComponent("QuizPack", isDirectory: true) else { return nil }
        let currentURL = dir.appendingPathComponent("current.json")
        guard let data = try? Data(contentsOf: currentURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let version = json["version"] as? Int else {
            return nil
        }
        let packURL = dir.appendingPathComponent("pack_v\(version).sqlite")
        return fileManager.fileExists(atPath: packURL.path) ? packURL : nil
    }

    private func bundledPackURL() -> URL? {
        let name = "pack_v\(bundledVersion)"
        if let url = Bundle.main.url(forResource: name, withExtension: "sqlite", subdirectory: "QuizPack") {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "sqlite") {
            return url
        }
        return Bundle.main.urls(forResourcesWithExtension: "sqlite", subdirectory: "QuizPack")?.first
    }

    private func copyBundledPackIfNeeded(_ bundledURL: URL, version: Int) throws -> URL {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let dir = support?.appendingPathComponent("QuizPack", isDirectory: true) else {
            throw AppError.pack("팩 저장 경로를 만들 수 없습니다.")
        }
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        let destURL = dir.appendingPathComponent("pack_v\(version).sqlite")
        if !fileManager.fileExists(atPath: destURL.path) {
            try fileManager.copyItem(at: bundledURL, to: destURL)
        }
        return destURL
    }

    private func writeCurrentVersion(_ version: Int, directory: URL) throws {
        let currentURL = directory.appendingPathComponent("current.json")
        let data = try JSONSerialization.data(withJSONObject: ["version": version], options: [])
        try data.write(to: currentURL, options: .atomic)
    }

    private func extractedVersion(from url: URL) -> Int {
        let name = url.deletingPathExtension().lastPathComponent
        if let suffix = name.split(separator: "_").last, let v = Int(suffix) {
            return v
        }
        return bundledVersion
    }
}
