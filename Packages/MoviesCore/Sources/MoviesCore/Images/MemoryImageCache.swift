import Foundation

final class MemoryImageCache: @unchecked Sendable {
    private let cache = NSCache<NSString, NSData>()

    init() {
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func data(for key: String) -> Data? {
        cache.object(forKey: key as NSString) as Data?
    }

    func store(_ data: Data, for key: String) {
        cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
    }
}
