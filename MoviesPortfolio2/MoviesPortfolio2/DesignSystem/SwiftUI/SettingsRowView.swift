import SwiftUI

struct SettingsRowView: View {
  let title: String
  let value: String
  var systemImage: String?

  var body: some View {
    HStack(spacing: AppSpacing.md) {
      if let systemImage {
        Image(systemName: systemImage)
          .font(.system(size: AppMetrics.settingsIconSize))
          .foregroundStyle(Color.appSecondaryText)
          .frame(width: AppMetrics.settingsIconSize)
      }

      Text(title)
        .font(AppTypography.settingsLabel)
        .foregroundStyle(Color.appPrimaryText)

      Spacer()

      Text(value)
        .font(AppTypography.caption)
        .foregroundStyle(Color.appSecondaryText)
        .multilineTextAlignment(.trailing)
    }
    .padding(.vertical, AppSpacing.xs)
  }
}
