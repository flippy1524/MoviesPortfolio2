import SwiftUI

struct MediaTitleText: View {
  let title: String
  var lineLimit: Int = 2

  var body: some View {
    Text(title)
      .font(AppTypography.title)
      .foregroundStyle(Color.appPrimaryText)
      .lineLimit(lineLimit)
      .multilineTextAlignment(.leading)
  }
}
