import Foundation

public enum AppEnvironment: String, Sendable, CaseIterable {
    case development = "Development"
    case production = "Production"

    public var displayName: String {
        rawValue
    }

    public var isDevelopment: Bool {
        self == .development
    }

    public static func current(from bundle: Bundle = .main) -> AppEnvironment {
        guard
            let value = bundle.object(forInfoDictionaryKey: "APP_ENVIRONMENT") as? String,
            let environment = AppEnvironment(rawValue: value)
        else {
            return .development
        }

        return environment
    }
}
