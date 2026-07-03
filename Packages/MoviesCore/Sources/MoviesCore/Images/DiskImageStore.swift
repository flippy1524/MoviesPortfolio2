import Foundation

struct DiskImageStore: Sendable {
    let directory: URL

    init(directory: URL? = nil) throws {
        if let directory {
            self.directory = directory
        } else if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            self.directory = cachesDirectory.appendingPathComponent("MoviesPortfolioImages", isDirectory: true)
        } else {
            throw ImageCacheError.missingImage
        }

        try FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func data(for key: String) throws -> Data? {
        let fileURL = directory.appendingPathComponent(key)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return try Data(contentsOf: fileURL)
    }

    func store(_ data: Data, for key: String) throws {
        let fileURL = directory.appendingPathComponent(key)
        try data.write(to: fileURL, options: .atomic)
    }

    static func unsafeTemporaryStore() -> DiskImageStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("MoviesPortfolioImagesFallback", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return DiskImageStore(directory: directory)
    }

    private init(directory: URL) {
        self.directory = directory
    }
}
