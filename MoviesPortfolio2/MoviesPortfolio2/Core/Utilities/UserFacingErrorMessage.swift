import Foundation
import MoviesCore

enum UserFacingErrorMessage {
  static func text(for error: Error) -> String {
    if let configError = error as? APIConfigurationError {
      return configError.localizedDescription
    }
    if let networkError = error as? NetworkError {
      switch networkError {
      case .invalidURL:
        return "Invalid request URL."
      case .invalidResponse:
        return "Unexpected server response."
      case .httpStatus(let code):
        return "Request failed (HTTP \(code))."
      case .decoding:
        return "Could not read movie data."
      case .transport:
        return "Network connection failed."
      }
    }
    return error.localizedDescription
  }
}
