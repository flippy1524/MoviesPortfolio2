import SwiftUI

struct ErrorStateView: View {
  let message: String
  var retryTitle: String = "Try Again"
  let onRetry: () -> Void

  var body: some View {
    VStack(spacing: AppSpacing.lg) {
      Image(systemName: "exclamationmark.triangle")
        .font(.largeTitle)
        .foregroundStyle(Color.appSecondaryText)

      Text(message)
        .font(AppTypography.body)
        .foregroundStyle(Color.appSecondaryText)
        .multilineTextAlignment(.center)

      Button(retryTitle, action: onRetry)
        .buttonStyle(.borderedProminent)
        .tint(Color.appAccent)
    }
    .padding(AppSpacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
