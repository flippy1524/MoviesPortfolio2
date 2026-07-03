import Foundation

public protocol ImageDataFetching: Sendable {
    func fetchData(from url: URL) async throws -> Data
}

public struct URLSessionImageDataFetcher: ImageDataFetching, Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode)
        else {
            throw ImageCacheError.invalidResponse
        }
        return data
    }
}
