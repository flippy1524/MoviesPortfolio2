import MoviesCore
import SwiftUI

private enum DefaultImageCache {
  static let shared: ImageCache = ImageCache()
}

private struct ImageCacheKey: EnvironmentKey {
  static let defaultValue: ImageCache = DefaultImageCache.shared
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
