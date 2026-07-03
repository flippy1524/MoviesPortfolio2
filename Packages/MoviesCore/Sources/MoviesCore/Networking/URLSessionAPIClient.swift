import Foundation

public final class URLSessionAPIClient: APIClient, @unchecked Sendable {
    private let dataFetcher: URLDataFetching
    private let requestBuilder: APIRequestBuilder

    public init(configuration: APIConfiguration, session: URLSession = .shared) {
        self.dataFetcher = session
        self.requestBuilder = APIRequestBuilder(configuration: configuration)
    }

    init(configuration: APIConfiguration, dataFetcher: URLDataFetching) {
        self.dataFetcher = dataFetcher
        self.requestBuilder = APIRequestBuilder(configuration: configuration)
    }

    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = try requestBuilder.url(for: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await dataFetcher.data(for: request)
        } catch {
            throw NetworkError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder.tmdb.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}
