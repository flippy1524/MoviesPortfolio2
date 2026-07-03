import Foundation
@testable import MoviesCore

enum MockAPIConfiguration {
    static let test = APIConfiguration(
        environment: .development,
        apiKey: "test-api-key",
        baseURL: URL(string: "https://api.themoviedb.org/3")!
    )
}
