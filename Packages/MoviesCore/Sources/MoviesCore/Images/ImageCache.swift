import CryptoKit
import Foundation

public actor ImageCache {
    private let memoryCache = MemoryImageCache()
    private let diskStore: DiskImageStore
    private let fetcher: ImageDataFetching
    private var inFlight: [URL: Task<Data, Error>] = [:]

    public init(
        fetcher: ImageDataFetching = URLSessionImageDataFetcher(),
        diskStoreDirectory: URL? = nil
    ) {
        self.fetcher = fetcher
        if let diskStore = try? DiskImageStore(directory: diskStoreDirectory) {
            self.diskStore = diskStore
        } else {
            let fallback = FileManager.default.temporaryDirectory
                .appendingPathComponent("MoviesPortfolioImages", isDirectory: true)
            self.diskStore = (try? DiskImageStore(directory: fallback)) ?? DiskImageStore.unsafeTemporaryStore()
        }
    }

    init(fetcher: ImageDataFetching, diskStore: DiskImageStore) {
        self.fetcher = fetcher
        self.diskStore = diskStore
    }

    public func data(for url: URL) async throws -> Data {
        let key = Self.cacheKey(for: url)

        if let cached = memoryCache.data(for: key) {
            return cached
        }

        if let diskData = try diskStore.data(for: key) {
            memoryCache.store(diskData, for: key)
            return diskData
        }

        if let existingTask = inFlight[url] {
            return try await existingTask.value
        }

        let task = Task<Data, Error> {
            try await fetcher.fetchData(from: url)
        }
        inFlight[url] = task

        do {
            let data = try await task.value
            inFlight[url] = nil
            memoryCache.store(data, for: key)
            try diskStore.store(data, for: key)
            return data
        } catch {
            inFlight[url] = nil
            throw error
        }
    }

    public func loadProgressively(
        lowResolutionURL: URL?,
        highResolutionURL: URL?
    ) -> AsyncStream<ImageLoadEvent> {
        AsyncStream { continuation in
            let task = Task {
                defer { continuation.finish() }

                if let lowResolutionURL {
                    if let data = try? await data(for: lowResolutionURL) {
                        let isFinal = lowResolutionURL == highResolutionURL
                        continuation.yield(ImageLoadEvent(data: data, isFinal: isFinal))
                        if isFinal {
                            return
                        }
                    }
                }

                if let highResolutionURL, highResolutionURL != lowResolutionURL {
                    if let data = try? await data(for: highResolutionURL) {
                        continuation.yield(ImageLoadEvent(data: data, isFinal: true))
                    }
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private static func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
