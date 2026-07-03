import Foundation

public struct ImageLoadEvent: Sendable, Equatable {
    public let data: Data
    public let isFinal: Bool

    public init(data: Data, isFinal: Bool) {
        self.data = data
        self.isFinal = isFinal
    }
}
