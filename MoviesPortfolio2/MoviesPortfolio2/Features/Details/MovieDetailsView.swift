import SwiftUI

struct MovieDetailsView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @State private var viewModel: MovieDetailsViewModel

  init(viewModel: MovieDetailsViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    Group {
      if viewModel.isLoading && viewModel.details == nil {
        LoadingView(message: "Loading movie details…")
      } else if let errorMessage = viewModel.errorMessage, viewModel.details == nil {
        ErrorStateView(message: errorMessage, onRetry: viewModel.retry)
      } else if let details = viewModel.details {
        detailsContent(details)
      }
    }
    .background(Color.appBackground)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if viewModel.details != nil {
        ToolbarItem(placement: .topBarTrailing) {
          FavoriteButton(isFavorite: viewModel.isFavorite, action: viewModel.toggleFavorite)
        }
      }
    }
    .task {
      if viewModel.details == nil {
        viewModel.load()
      }
    }
    .onAppear {
      viewModel.syncFavoriteState()
    }
  }

  private func detailsContent(_ details: MovieDetailsDisplayModel) -> some View {
    VStack(spacing: 0) {
      if viewModel.isOfflineFallback {
        OfflineBannerView(message: "Showing cached movie details.")
      }

      GeometryReader { geometry in
        let isLandscape = geometry.size.width > geometry.size.height

        ScrollView {
          VStack(alignment: .leading, spacing: AppSpacing.lg) {
            heroSection(details, isLandscape: isLandscape)

            if !isLandscape {
              infoSection(details)
              overviewSection(details)
            }

            castSection(details)
            crewSection(details)
          }
          .readableContentWidth(contentMaxWidth)
          .padding(.bottom, AppSpacing.xl)
        }
      }
    }
  }

  private var contentMaxWidth: CGFloat? {
    horizontalSizeClass == .regular ? AppMetrics.readableContentMaxWidth : nil
  }

  private var contentHorizontalPadding: CGFloat {
    horizontalSizeClass == .regular ? AppSpacing.xl : AppSpacing.lg
  }

  private func landscapePosterWidth(isLandscape: Bool) -> CGFloat {
    guard isLandscape else { return AppMetrics.detailsPosterWidth }

    return horizontalSizeClass == .regular
      ? AppMetrics.detailsPosterWidthRegular
      : AppMetrics.detailsPosterWidthLandscape
  }

  private func landscapeBackdropHeight(isLandscape: Bool) -> CGFloat {
    guard isLandscape else { return AppMetrics.landscapeBackdropStripHeight }

    return horizontalSizeClass == .regular
      ? AppMetrics.landscapeBackdropStripHeightRegular
      : AppMetrics.landscapeBackdropStripHeight
  }

  private func heroSection(_ details: MovieDetailsDisplayModel, isLandscape: Bool) -> some View {
    Group {
      if isLandscape {
        landscapeHeroSection(details, isLandscape: isLandscape)
      } else if horizontalSizeClass == .regular {
        regularHeroSection(details)
      } else {
        compactHeroSection(details)
      }
    }
  }

  private func landscapeHeroSection(
    _ details: MovieDetailsDisplayModel,
    isLandscape: Bool
  ) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
      BackdropImageView(
        backdropPath: details.backdropPath,
        stripHeight: landscapeBackdropHeight(isLandscape: isLandscape)
      )

      HStack(alignment: .top, spacing: AppSpacing.lg) {
        posterView(details, width: landscapePosterWidth(isLandscape: isLandscape))

        VStack(alignment: .leading, spacing: AppSpacing.md) {
          heroText(details, isLandscape: isLandscape)
          metadataRow(details)

          if !details.genres.isEmpty {
            genresRow(details)
          }

          overviewSection(details, showsTitle: false)
        }
      }
      .padding(.horizontal, contentHorizontalPadding)
    }
  }

  private func compactHeroSection(_ details: MovieDetailsDisplayModel) -> some View {
    ZStack(alignment: .bottomLeading) {
      BackdropImageView(backdropPath: details.backdropPath)

      LinearGradient(
        colors: [.clear, Color.appBackground.opacity(0.85), Color.appBackground],
        startPoint: .top,
        endPoint: .bottom
      )

      HStack(alignment: .bottom, spacing: AppSpacing.md) {
        posterView(details, width: AppMetrics.detailsPosterWidth)
        heroText(details, isLandscape: false)
        Spacer(minLength: 0)
      }
      .padding(contentHorizontalPadding)
    }
  }

  private func regularHeroSection(_ details: MovieDetailsDisplayModel) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.lg) {
      BackdropImageView(backdropPath: details.backdropPath)

      HStack(alignment: .top, spacing: AppSpacing.lg) {
        posterView(details, width: AppMetrics.detailsPosterWidthRegular)
        heroText(details, isLandscape: false)
        Spacer(minLength: 0)
      }
      .padding(.horizontal, contentHorizontalPadding)
    }
  }

  private func posterView(_ details: MovieDetailsDisplayModel, width: CGFloat) -> some View {
    PosterImageView(
      posterPath: details.posterPath,
      layoutWidth: width
    )
    .frame(
      width: width,
      height: width / AppMetrics.posterAspectRatio
    )
    .accessibilityHidden(true)
  }

  private func heroText(_ details: MovieDetailsDisplayModel, isLandscape: Bool) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.xs) {
      Text(details.title)
        .font(isLandscape ? AppTypography.sectionTitle : AppTypography.largeTitle)
        .foregroundStyle(Color.appPrimaryText)
        .lineLimit(isLandscape ? 2 : 3)

      if let tagline = details.tagline {
        Text(tagline)
          .font(AppTypography.body)
          .italic()
          .foregroundStyle(Color.appSecondaryText)
          .lineLimit(2)
      }

      RatingBadgeView(rating: details.ratingText, voteCount: details.voteCountText)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(details.title). Rated \(details.ratingText).")
  }

  private func infoSection(_ details: MovieDetailsDisplayModel) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
      metadataRow(details)

      if !details.genres.isEmpty {
        genresRow(details)
      }
    }
    .padding(.horizontal, contentHorizontalPadding)
  }

  private func genresRow(_ details: MovieDetailsDisplayModel) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppSpacing.sm) {
        ForEach(details.genres, id: \.self) { genre in
          GenreChipView(title: genre)
        }
      }
    }
  }

  private func metadataRow(_ details: MovieDetailsDisplayModel) -> some View {
    HStack(spacing: AppSpacing.md) {
      if let releaseDate = details.releaseDateText {
        metadataItem(systemImage: "calendar", text: releaseDate)
      }
      if let runtime = details.runtimeText {
        metadataItem(systemImage: "clock", text: runtime)
      }
      if let status = details.status {
        metadataItem(systemImage: "info.circle", text: status)
      }
    }
    .font(AppTypography.caption)
    .foregroundStyle(Color.appSecondaryText)
  }

  private func metadataItem(systemImage: String, text: String) -> some View {
    Label(text, systemImage: systemImage)
      .labelStyle(.titleAndIcon)
  }

  private func overviewSection(_ details: MovieDetailsDisplayModel, showsTitle: Bool = true) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      if showsTitle {
        Text("Overview")
          .font(AppTypography.sectionTitle)
          .foregroundStyle(Color.appPrimaryText)
      }

      Text(details.overview)
        .font(AppTypography.body)
        .foregroundStyle(Color.appSecondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, showsTitle ? contentHorizontalPadding : 0)
  }

  private func castSection(_ details: MovieDetailsDisplayModel) -> some View {
    Group {
      if !details.cast.isEmpty {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
          Text("Cast")
            .font(AppTypography.sectionTitle)
            .foregroundStyle(Color.appPrimaryText)
            .padding(.horizontal, contentHorizontalPadding)

          ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
              ForEach(details.cast) { member in
                CastMemberView(
                  name: member.name,
                  role: member.role,
                  profilePath: member.profilePath
                )
              }
            }
            .padding(.horizontal, contentHorizontalPadding)
          }
        }
      }
    }
  }

  private func crewSection(_ details: MovieDetailsDisplayModel) -> some View {
    Group {
      if !details.directors.isEmpty {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
          Text("Director")
            .font(AppTypography.sectionTitle)
            .foregroundStyle(Color.appPrimaryText)

          Text(details.directors.joined(separator: ", "))
            .font(AppTypography.body)
            .foregroundStyle(Color.appSecondaryText)
        }
        .padding(.horizontal, contentHorizontalPadding)
      }
    }
  }
}

#Preview {
  let dependencies = AppDependencies()
  NavigationStack {
    MovieDetailsView(viewModel: dependencies.makeMovieDetailsViewModel(movieID: 550))
  }
}
