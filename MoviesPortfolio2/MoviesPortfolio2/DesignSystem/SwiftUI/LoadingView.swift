import SwiftUI

struct LoadingView: View {
  var message: String?

  var body: some View {
    VStack(spacing: AppSpacing.md) {
      ProgressView()
      if let message {
        Text(message)
          .font(AppTypography.caption)
          .foregroundStyle(Color.appSecondaryText)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
