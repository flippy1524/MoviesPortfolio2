import SwiftUI

struct MovieCardView: View {
  let item: MediaItemDisplayModel
  var onFavoriteTap: (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      PosterImageView(posterPath: item.posterPath)
        .frame(maxWidth: .infinity)

      HStack(alignment: .top, spacing: AppSpacing.xs) {
        MediaTitleText(title: item.title)
          .frame(maxWidth: .infinity, alignment: .leading)

        if let onFavoriteTap {
          FavoriteButton(isFavorite: item.isFavorite, action: onFavoriteTap)
        }
      }
      .frame(minHeight: AppMetrics.movieCardTitleMinHeight, alignment: .top)

      Text(item.overview)
        .font(AppTypography.caption)
        .foregroundStyle(Color.appSecondaryText)
        .lineLimit(2)
        .multilineTextAlignment(.leading)
        .frame(minHeight: AppMetrics.movieCardOverviewMinHeight, alignment: .top)
    }
    .frame(maxWidth: .infinity, alignment: .top)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(item.title). \(item.overview)")
    .accessibilityHint("Opens movie details.")
  }
}
