import SwiftUI
import UIKit

enum AppColors {
  static let background = UIColor { traits in
    traits.userInterfaceStyle == .dark
      ? UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1)
      : UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
  }

  static let cardBackground = UIColor { traits in
    traits.userInterfaceStyle == .dark
      ? UIColor(red: 0.14, green: 0.14, blue: 0.17, alpha: 1)
      : UIColor.white
  }

  static let primaryText = UIColor.label
  static let secondaryText = UIColor.secondaryLabel
  static let accent = UIColor.systemRed
}

extension Color {
  static let appBackground = Color(AppColors.background)
  static let appCardBackground = Color(AppColors.cardBackground)
  static let appPrimaryText = Color(AppColors.primaryText)
  static let appSecondaryText = Color(AppColors.secondaryText)
  static let appAccent = Color(AppColors.accent)
}
