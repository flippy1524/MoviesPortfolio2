import MoviesCore
import SwiftUI

struct PosterImageView: View {
  let posterPath: String?
  var layoutWidth: CGFloat = AppMetrics.posterMinColumnWidth
  var cornerRadius: CGFloat = AppMetrics.cornerRadius

  var body: some View {
    CachedImageView(imagePath: posterPath, layoutWidth: layoutWidth) {
      placeholder
    }
    .frame(maxWidth: .infinity)
    .aspectRatio(AppMetrics.posterAspectRatio, contentMode: .fit)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
  }

  private var placeholder: some View {
    ZStack {
      Color.appCardBackground
      Image(systemName: "film")
        .font(.title2)
        .foregroundStyle(Color.appSecondaryText)
    }
  }
}
