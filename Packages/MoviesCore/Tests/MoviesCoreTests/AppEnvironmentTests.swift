import XCTest
@testable import MoviesCore

final class AppEnvironmentTests: XCTestCase {
    func testCurrentReturnsDevelopmentWhenInfoPlistValueMissing() {
        let bundle = Bundle(for: AppEnvironmentTests.self)
        XCTAssertEqual(AppEnvironment.current(from: bundle), .development)
    }

    func testAPIConfigurationThrowsWhenAPIKeyMissing() {
        let bundle = Bundle(for: AppEnvironmentTests.self)

        XCTAssertThrowsError(try APIConfiguration.load(from: bundle)) { error in
            XCTAssertEqual(error as? APIConfigurationError, .missingAPIKey)
        }
    }
}
