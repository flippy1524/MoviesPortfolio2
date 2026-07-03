import SwiftUI

struct RatingBadgeView: View {
  let rating: String
  let voteCount: String

  var body: some View {
    HStack(spacing: AppSpacing.xs) {
      Image(systemName: "star.fill")
        .foregroundStyle(Color.yellow)
      Text(rating)
        .font(AppTypography.title)
        .foregroundStyle(Color.appPrimaryText)
      Text("(\(voteCount))")
        .font(AppTypography.caption)
        .foregroundStyle(Color.appSecondaryText)
    }
  }
}
