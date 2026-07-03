import Foundation

public enum ImageCacheError: Error, Equatable, Sendable {
    case invalidResponse
    case missingImage
}
