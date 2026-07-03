import Foundation

public protocol URLDataFetching: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLDataFetching {}
