import Foundation
import MoviesCore
import Observation

@MainActor
@Observable
final class OfflineStatus {
  private(set) var isTrendingFromCache = false
  private(set) var isDetailsFromCache = false

  func setTrendingFromCache(_ value: Bool) {
    isTrendingFromCache = value
  }

  func setDetailsFromCache(_ value: Bool) {
    isDetailsFromCache = value
  }
}
