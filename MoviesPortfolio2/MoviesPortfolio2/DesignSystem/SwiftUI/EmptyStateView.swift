import SwiftUI

struct EmptyStateView: View {
  let title: String
  var message: String?

  var body: some View {
    VStack(spacing: AppSpacing.md) {
      Image(systemName: "tray")
        .font(.largeTitle)
        .foregroundStyle(Color.appSecondaryText)

      Text(title)
        .font(AppTypography.title)
        .foregroundStyle(Color.appPrimaryText)

      if let message {
        Text(message)
          .font(AppTypography.body)
          .foregroundStyle(Color.appSecondaryText)
          .multilineTextAlignment(.center)
      }
    }
    .padding(AppSpacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
