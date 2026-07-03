import Foundation

public protocol APIClient: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
}
