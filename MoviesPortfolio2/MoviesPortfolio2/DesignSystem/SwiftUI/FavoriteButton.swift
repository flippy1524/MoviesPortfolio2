import SwiftUI

struct FavoriteButton: View {
  let isFavorite: Bool
  let action: () -> Void

  var body: some View {
    Button {
      withAnimation(.spring(duration: 0.28)) {
        action()
      }
    } label: {
      Image(systemName: isFavorite ? "heart.fill" : "heart")
        .foregroundStyle(isFavorite ? Color.appAccent : Color.appSecondaryText)
        .imageScale(.medium)
        .contentTransition(.symbolEffect(.replace))
        .symbolEffect(.bounce, value: isFavorite)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
  }
}
