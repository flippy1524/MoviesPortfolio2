import SwiftUI

struct GenreChipView: View {
  let title: String

  var body: some View {
    Text(title)
      .font(AppTypography.caption)
      .foregroundStyle(Color.appPrimaryText)
      .padding(.horizontal, AppSpacing.sm)
      .padding(.vertical, AppSpacing.xs)
      .background(Color.appCardBackground, in: Capsule())
  }
}
