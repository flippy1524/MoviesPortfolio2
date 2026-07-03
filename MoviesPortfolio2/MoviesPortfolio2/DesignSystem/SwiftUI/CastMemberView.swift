import SwiftUI

struct CastMemberView: View {
  let name: String
  let role: String
  let profilePath: String?

  var body: some View {
    VStack(spacing: AppSpacing.sm) {
      ProfileImageView(profilePath: profilePath)

      Text(name)
        .font(AppTypography.caption.weight(.semibold))
        .foregroundStyle(Color.appPrimaryText)
        .lineLimit(2)
        .multilineTextAlignment(.center)

      Text(role)
        .font(AppTypography.caption)
        .foregroundStyle(Color.appSecondaryText)
        .lineLimit(2)
        .multilineTextAlignment(.center)
    }
    .frame(width: 88)
  }
}
