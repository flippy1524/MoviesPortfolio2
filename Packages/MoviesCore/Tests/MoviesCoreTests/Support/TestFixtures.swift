import Foundation
@testable import MoviesCore

enum TestFixtures {
    static func data(named name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw FixtureError.missing(name)
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ type: T.Type, from name: String) throws -> T {
        let data = try data(named: name)
        return try JSONDecoder.tmdb.decode(T.self, from: data)
    }
}

enum FixtureError: Error {
    case missing(String)
}
