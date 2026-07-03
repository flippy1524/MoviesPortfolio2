import Foundation
import MoviesCore

final class CachingTrendingRepository: TrendingRepository, @unchecked Sendable {
  private let live: TrendingRepository
  private let offlineCache: OfflineCacheStoring
  private let offlineStatus: OfflineStatus

  init(
    live: TrendingRepository,
    offlineCache: OfflineCacheStoring,
    offlineStatus: OfflineStatus
  ) {
    self.live = live
    self.offlineCache = offlineCache
    self.offlineStatus = offlineStatus
  }

  func fetchTrending(page: Int) async throws -> PaginatedResponse<Movie> {
    do {
      let response = try await live.fetchTrending(page: page)
      await MainActor.run {
        offlineStatus.setTrendingFromCache(false)
        try? offlineCache.cacheTrending(response)
      }
      return response
    } catch {
      guard page == 1 else { throw error }

      let cached = await MainActor.run { try? offlineCache.fetchCachedTrending() }
      guard let cached else { throw error }

      await MainActor.run {
        offlineStatus.setTrendingFromCache(true)
      }
      return cached
    }
  }
}
