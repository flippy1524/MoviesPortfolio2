import MoviesCore
import SwiftUI
import UIKit

struct CachedImageView<Placeholder: View>: View {
  let imagePath: String?
  var layoutWidth: CGFloat
  @ViewBuilder var placeholder: () -> Placeholder

  @Environment(\.imageCache) private var imageCache
  @State private var image: UIImage?

  var body: some View {
    Group {
      if let image {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
      } else {
        placeholder()
      }
    }
    .task(id: taskID) {
      await loadImage()
    }
  }

  private var taskID: String {
    "\(imagePath ?? "")-\(layoutWidth)"
  }

  private func loadImage() async {
    image = nil
    guard let imagePath else { return }

    let urls = ImageURLBuilder.posterURLs(path: imagePath, layoutWidth: layoutWidth)
    for await event in await imageCache.loadProgressively(
      lowResolutionURL: urls.low,
      highResolutionURL: urls.high
    ) {
      guard !Task.isCancelled else { return }
      if let loadedImage = UIImage(data: event.data) {
        image = loadedImage
      }
    }
  }
}
