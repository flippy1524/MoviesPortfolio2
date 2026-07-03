import Foundation

public enum PosterSize: String, Sendable, CaseIterable {
    case w92
    case w154
    case w185
    case w342
    case w500
    case w780
    case original
}

public enum ImageURLBuilder {
    private static let baseURLString = "https://image.tmdb.org/t/p"

    public static func posterURL(path: String, size: PosterSize) -> URL? {
        let normalized = path.hasPrefix("/") ? path : "/\(path)"
        return URL(string: "\(baseURLString)/\(size.rawValue)\(normalized)")
    }

    public static func posterSize(forWidth width: CGFloat) -> PosterSize {
        switch width {
        case ..<100: .w92
        case ..<160: .w154
        case ..<220: .w185
        case ..<400: .w342
        case ..<600: .w500
        default: .w780
        }
    }

    public static func lowResolutionPosterURL(path: String) -> URL? {
        posterURL(path: path, size: .w92)
    }

    public static func posterURL(path: String, layoutWidth: CGFloat) -> URL? {
        posterURL(path: path, size: posterSize(forWidth: layoutWidth))
    }

    public static func posterURLs(path: String, layoutWidth: CGFloat) -> (low: URL?, high: URL?) {
        let high = posterURL(path: path, layoutWidth: layoutWidth)
        let low = lowResolutionPosterURL(path: path)
        if low == high {
            return (high, high)
        }
        return (low, high)
    }
}
