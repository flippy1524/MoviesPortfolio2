import Foundation
@testable import MoviesCore
import XCTest

final class ImageCacheTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testFetchesAndCachesInMemory() async throws {
        let url = URL(string: "https://image.tmdb.org/t/p/w500/poster.jpg")!
        let expected = Data([0x01, 0x02, 0x03])
        let fetcher = MockImageDataFetcher(responses: [url: expected])
        let diskStore = try DiskImageStore(directory: tempDirectory)
        let cache = ImageCache(fetcher: fetcher, diskStore: diskStore)

        let first = try await cache.data(for: url)
        let second = try await cache.data(for: url)

        XCTAssertEqual(first, expected)
        XCTAssertEqual(second, expected)
        let fetchCount = await fetcher.fetchCount(for: url)
        XCTAssertEqual(fetchCount, 1)
    }

    func testLoadsFromDiskWhenMemoryIsEmpty() async throws {
        let url = URL(string: "https://image.tmdb.org/t/p/w500/backdrop.jpg")!
        let expected = Data("cached-image".utf8)
        let diskStore = try DiskImageStore(directory: tempDirectory)

        let warmingFetcher = MockImageDataFetcher(responses: [url: expected])
        let warmingCache = ImageCache(fetcher: warmingFetcher, diskStore: diskStore)
        _ = try await warmingCache.data(for: url)

        let coldFetcher = MockImageDataFetcher(responses: [:])
        let coldCache = ImageCache(fetcher: coldFetcher, diskStore: diskStore)
        let loaded = try await coldCache.data(for: url)

        XCTAssertEqual(loaded, expected)
        let fetchCount = await coldFetcher.fetchCount(for: url)
        XCTAssertEqual(fetchCount, 0)
    }

    func testProgressiveLoadEmitsLowThenHighResolution() async throws {
        let lowURL = URL(string: "https://image.tmdb.org/t/p/w92/poster.jpg")!
        let highURL = URL(string: "https://image.tmdb.org/t/p/w500/poster.jpg")!
        let lowData = Data([0x01])
        let highData = Data([0x02])
        let fetcher = MockImageDataFetcher(responses: [
            lowURL: lowData,
            highURL: highData
        ])
        let diskStore = try DiskImageStore(directory: tempDirectory)
        let cache = ImageCache(fetcher: fetcher, diskStore: diskStore)

        var events: [ImageLoadEvent] = []
        for await event in await cache.loadProgressively(
            lowResolutionURL: lowURL,
            highResolutionURL: highURL
        ) {
            events.append(event)
        }

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].data, lowData)
        XCTAssertFalse(events[0].isFinal)
        XCTAssertEqual(events[1].data, highData)
        XCTAssertTrue(events[1].isFinal)
    }
}

private final class MockImageDataFetcher: ImageDataFetching, @unchecked Sendable {
    private let responses: [URL: Data]
    private let counter = FetchCounter()

    init(responses: [URL: Data]) {
        self.responses = responses
    }

    func fetchData(from url: URL) async throws -> Data {
        await counter.increment(url)

        guard let data = responses[url] else {
            throw ImageCacheError.missingImage
        }
        return data
    }

    func fetchCount(for url: URL) async -> Int {
        await counter.count(for: url)
    }
}

private actor FetchCounter {
    private var counts: [URL: Int] = [:]

    func increment(_ url: URL) {
        counts[url, default: 0] += 1
    }

    func count(for url: URL) -> Int {
        counts[url, default: 0]
    }
}
