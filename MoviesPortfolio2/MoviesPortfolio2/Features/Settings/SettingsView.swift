import MoviesCore
import SwiftUI

struct SettingsView: View {
  let dependencies: AppDependencies

  var body: some View {
    NavigationStack {
      List {
        Section("App") {
          SettingsRowView(
            title: "Environment",
            value: dependencies.environment.displayName,
            systemImage: "gearshape"
          )
          SettingsRowView(
            title: "MoviesCore",
            value: MoviesCoreMetadata.version,
            systemImage: "shippingbox"
          )
        }

        Section("API") {
          SettingsRowView(
            title: "TMDB API Key",
            value: dependencies.isAPIKeyConfigured ? "Configured" : "Missing",
            systemImage: dependencies.isAPIKeyConfigured ? "checkmark.seal" : "exclamationmark.triangle"
          )

          if !dependencies.isAPIKeyConfigured {
            Text(apiKeyHelpText)
              .font(AppTypography.caption)
              .foregroundStyle(Color.appSecondaryText)
          }
        }
      }
      .navigationTitle("Settings")
    }
  }

  private var apiKeyHelpText: String {
    "Copy Config/Secrets.xcconfig.example to Secrets.xcconfig and set TMDB_API_KEY, then rebuild with the Dev scheme."
  }
}

#Preview {
  SettingsView(dependencies: AppDependencies())
}
