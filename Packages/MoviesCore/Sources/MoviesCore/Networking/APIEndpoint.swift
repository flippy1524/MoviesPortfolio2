import Foundation

public enum APIEndpoint: Sendable, Equatable {
    case trendingMovies(page: Int)
    case movieDetails(id: Int)
    case movieCredits(id: Int)
    case searchMovies(query: String, page: Int)
    case searchTV(query: String, page: Int)

    var path: String {
        switch self {
        case .trendingMovies:
            "/trending/movie/day"
        case let .movieDetails(id):
            "/movie/\(id)"
        case let .movieCredits(id):
            "/movie/\(id)/credits"
        case .searchMovies:
            "/search/movie"
        case .searchTV:
            "/search/tv"
        }
    }

    func queryItems(apiKey: String) -> [URLQueryItem] {
        var items = [URLQueryItem(name: "api_key", value: apiKey)]

        switch self {
        case let .trendingMovies(page):
            items.append(URLQueryItem(name: "page", value: String(page)))
        case let .searchMovies(query, page), let .searchTV(query, page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: String(page)))
        case .movieDetails, .movieCredits:
            break
        }

        return items
    }
}

public struct APIRequestBuilder: Sendable {
    private let configuration: APIConfiguration

    public init(configuration: APIConfiguration) {
        self.configuration = configuration
    }

    public func url(for endpoint: APIEndpoint) throws -> URL {
        let trimmedPath = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard var components = URLComponents(
            url: configuration.baseURL.appending(path: trimmedPath),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems(apiKey: configuration.apiKey)

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return url
    }
}
