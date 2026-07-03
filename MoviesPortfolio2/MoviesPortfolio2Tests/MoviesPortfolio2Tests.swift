import XCTest
@testable import MoviesPortfolio2
import MoviesCore

final class MoviesPortfolio2Tests: XCTestCase {
  @MainActor
  func testAppDependenciesDefaultEnvironmentIsDevelopment() {
    let dependencies = AppDependencies()
    XCTAssertEqual(dependencies.environment, .development)
  }
}
