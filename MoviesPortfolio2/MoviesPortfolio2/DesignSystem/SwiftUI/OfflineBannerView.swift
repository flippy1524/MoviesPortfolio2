import SwiftUI

struct OfflineBannerView: View {
  let message: String

  var body: some View {
    Text(message)
      .font(AppTypography.caption)
      .foregroundStyle(Color.appPrimaryText)
      .frame(maxWidth: .infinity)
      .padding(.vertical, AppSpacing.sm)
      .background(Color.appCardBackground)
  }
}
