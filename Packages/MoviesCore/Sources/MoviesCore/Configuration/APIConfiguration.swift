import Foundation

public struct APIConfiguration: Sendable, Equatable {
    public let environment: AppEnvironment
    public let apiKey: String
    public let baseURL: URL

    public init(
        environment: AppEnvironment,
        apiKey: String,
        baseURL: URL? = nil
    ) {
        self.environment = environment
        self.apiKey = apiKey
        self.baseURL = baseURL ?? Self.defaultBaseURL
    }

    private static var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.themoviedb.org/3") else {
            preconditionFailure("Invalid TMDB base URL constant")
        }
        return url
    }

    public static func load(from bundle: Bundle = .main) throws -> APIConfiguration {
        let environment = AppEnvironment.current(from: bundle)

        guard
            let apiKey = bundle.object(forInfoDictionaryKey: "TMDBApiKey") as? String,
            !apiKey.isEmpty,
            apiKey != "YOUR_TMDB_API_KEY_HERE"
        else {
            throw APIConfigurationError.missingAPIKey
        }

        return APIConfiguration(environment: environment, apiKey: apiKey)
    }
}

public enum APIConfigurationError: Error, Equatable, Sendable {
    case missingAPIKey

    public var localizedDescription: String {
        switch self {
        case .missingAPIKey:
            "TMDB API key is missing."
        }
    }
}
