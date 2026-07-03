import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case transport(Error)

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse):
            true
        case let (.httpStatus(left), .httpStatus(right)):
            left == right
        case let (.decoding(left), .decoding(right)),
             let (.transport(left), .transport(right)):
            left.localizedDescription == right.localizedDescription
        default:
            false
        }
    }
}

public extension JSONDecoder {
    static let tmdb: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
}
