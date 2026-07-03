import MoviesCore
import SwiftUI

struct ProfileImageView: View {
  let profilePath: String?
  var size: CGFloat = AppMetrics.profileImageSize

  var body: some View {
    CachedImageView(imagePath: profilePath, layoutWidth: size) {
      placeholder
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
  }

  private var placeholder: some View {
    ZStack {
      Color.appCardBackground
      Image(systemName: "person.fill")
        .foregroundStyle(Color.appSecondaryText)
    }
  }
}
