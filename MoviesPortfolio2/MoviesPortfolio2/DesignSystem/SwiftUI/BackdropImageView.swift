import MoviesCore
import SwiftUI

struct BackdropImageView: View {
  let backdropPath: String?
  var stripHeight: CGFloat?

  var body: some View {
    if let stripHeight {
      stripView(height: stripHeight)
    } else {
      heroView
    }
  }

  private var heroView: some View {
    GeometryReader { geometry in
      CachedImageView(imagePath: backdropPath, layoutWidth: geometry.size.width) {
        placeholder
      }
    }
    .aspectRatio(AppMetrics.backdropAspectRatio, contentMode: .fit)
    .clipped()
  }

  private func stripView(height: CGFloat) -> some View {
    Color.clear
      .frame(height: height)
      .overlay {
        GeometryReader { geometry in
          CachedImageView(imagePath: backdropPath, layoutWidth: geometry.size.width) {
            placeholder
          }
          .frame(width: geometry.size.width, height: height)
        }
      }
      .clipped()
  }

  private var placeholder: some View {
    Color.appCardBackground
  }
}
