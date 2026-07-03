import XCTest

enum AsyncTestSupport {
  static func waitUntil(
    timeout: TimeInterval = 2,
    pollInterval: Duration = .milliseconds(50),
    file: StaticString = #filePath,
    line: UInt = #line,
    _ condition: @escaping @MainActor () -> Bool
  ) async {
    let deadline = Date().addingTimeInterval(timeout)

    while Date() < deadline {
      if await MainActor.run(body: condition) {
        return
      }
      try? await Task.sleep(for: pollInterval)
    }

    XCTFail("Condition not met before timeout", file: file, line: line)
  }
}
