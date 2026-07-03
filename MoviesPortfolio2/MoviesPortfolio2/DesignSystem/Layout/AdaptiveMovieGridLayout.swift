import SwiftUI

struct AdaptiveMovieGridLayout {
  let columns: [GridItem]
  let horizontalPadding: CGFloat
  let maxContentWidth: CGFloat?

  static func make(horizontalSizeClass: UserInterfaceSizeClass?) -> AdaptiveMovieGridLayout {
    switch horizontalSizeClass {
    case .regular:
      AdaptiveMovieGridLayout(
        columns: [GridItem(.adaptive(minimum: 180), spacing: AppSpacing.lg)],
        horizontalPadding: AppSpacing.xl,
        maxContentWidth: 1_120
      )
    default:
      AdaptiveMovieGridLayout(
        columns: [
          GridItem(.adaptive(minimum: AppMetrics.posterMinColumnWidth), spacing: AppSpacing.md)
        ],
        horizontalPadding: AppSpacing.lg,
        maxContentWidth: nil
      )
    }
  }
}

extension View {
  func readableContentWidth(_ maxWidth: CGFloat?) -> some View {
    frame(maxWidth: maxWidth)
      .frame(maxWidth: .infinity)
  }
}
