# Movies Portfolio

iOS app for browsing trending movies from [The Movie Database (TMDB)](https://developers.themoviedb.org). Built with SwiftUI, MVVM, and a reusable **MoviesCore** package for networking, models, and image caching.

**Requirements:** iOS 18+, Xcode 16+, Swift 6

## Features

### Assignment requirements

| Requirement | Implementation |
|-------------|----------------|
| Trending movies grid with title, poster, description | `TrendingView` + `MovieCardView` |
| Infinite scroll pagination | `TrendingViewModel.loadNextPageIfNeeded` |
| Movie details (ratings, cast, director, scrollable) | `MovieDetailsView` + `MovieDetailsViewModel` |
| Search movies & TV with type filter | UIKit `SearchViewController` + `SearchViewModel` |
| Throttled search | 400ms debounce via `swift-async-algorithms` in `SearchViewModel` |
| View-size-based images | `ImageURLBuilder.posterSize(forWidth:)` + layout width passed to image views |
| MVVM architecture | Feature ViewModels + `AppDependencies` composition root |
| SwiftUI + UIKit | SwiftUI screens; Search via `SearchViewRepresentable` |
| Native networking (no Alamofire) | `URLSessionAPIClient` in MoviesCore |
| Swift 6 strict concurrency | App + MoviesCore targets |
| Dev / Prod schemes | `MoviesPortfolio2-Dev`, `MoviesPortfolio2-Prod` |
| iPad + iPhone, portrait + landscape | Adaptive grids, landscape details hero |
| SwiftLint | `.swiftlint.yml` + SPM `SwiftLintBuildToolPlugin` |

### Bonus features

| Bonus | Implementation |
|-------|----------------|
| Local favorites + indicator on items | Core Data + `FavoritesRepository`, heart on trending/search |
| Offline mode | Cached trending (page 1) + movie details in Core Data |
| Progressive image loading (low → high res) | `ImageCache.loadProgressively` |
| Image caching (memory + disk) | `ImageCache` actor in MoviesCore |
| MoviesCore `.xcframework` | `Packages/MoviesCore/Scripts/build-xcframework.sh` |

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  SwiftUI / UIKit views (Features/, DesignSystem/)       │
├─────────────────────────────────────────────────────────┤
│  ViewModels (@Observable, @MainActor)                   │
├─────────────────────────────────────────────────────────┤
│  App layer (Core/)                                      │
│  · FavoritesRepository, caching decorators              │
│  · Core Data persistence, OfflineStatus                 │
│  · AppDependencies (DI)                                 │
├─────────────────────────────────────────────────────────┤
│  MoviesCore (SPM / XCFramework)                         │
│  · Models, API client, repositories, ImageCache         │
└─────────────────────────────────────────────────────────┘
```

ViewModels receive dependencies via `AppDependencies.make…ViewModel()` factories. Views own view models with `@State` and never talk to repositories directly.

## Project structure

```
MoviesPortfolio2/
├── MoviesPortfolio2/              # Xcode project
│   ├── Config/                    # xcconfig, Secrets (gitignored), AppInfo.plist
│   └── MoviesPortfolio2/            # App target
│       ├── App/                   # Entry point
│       ├── Features/              # Trending, Search, Details, Favorites, Settings
│       ├── Core/                  # DI, persistence, repositories, offline
│       ├── DesignSystem/          # Tokens, SwiftUI/UIKit components
│       ├── UIKitBridge/           # UIViewControllerRepresentable bridges
│       └── MoviesPortfolio2Tests/ # ViewModel & display model unit tests
├── Packages/MoviesCore/           # Shared TMDB + image cache library
│   ├── Sources/MoviesCore/
│   ├── Tests/MoviesCoreTests/
│   ├── Scripts/build-xcframework.sh
│   └── XCFramework.md
├── ONGOING_ISSUES.md              # Known bugs
```

## Setup

1. **Clone** the repository.

2. **API key** — copy the secrets template and add your TMDB v3 key:
   ```bash
   cp MoviesPortfolio2/Config/Secrets.xcconfig.example MoviesPortfolio2/Config/Secrets.xcconfig
   ```
   Edit `MoviesPortfolio2/Config/Secrets.xcconfig`:
   ```
   TMDB_API_KEY = your_key_here
   ```
   No quotes. The key is injected at build time via `AppInfo.plist` — do not paste it into Info.plist manually.

3. **Open** `MoviesPortfolio2/MoviesPortfolio2.xcodeproj`.

4. **Select a scheme:**
   - **MoviesPortfolio2-Dev** — Debug, development environment
   - **MoviesPortfolio2-Prod** — Release, production environment

5. **Clean build** (⇧⌘K), then **Run** (⌘R) on a simulator or device (iOS 18+).

On first build, Xcode may prompt you to **Trust & Enable** the SwiftLint build tool plugin. For CI, pass `-skipPackagePluginValidation` to `xcodebuild`.

### SwiftLint

SwiftLint runs at build time via the [SwiftLintPlugins](https://github.com/SimplyDanny/SwiftLintPlugins) SPM build tool plugin — no `brew install` required. Rules live in [`.swiftlint.yml`](.swiftlint.yml) at the repo root.

## Testing

### MoviesCore (terminal)

```bash
cd Packages/MoviesCore
swift test
```

### App (Xcode)

1. Select scheme **MoviesPortfolio2-Dev**.
2. Choose an iOS Simulator.
3. **Product → Test** (⌘U).

Run a single test from the **Test navigator** (⌘6) or via the ◆ gutter in source files.

> Use the **Dev** scheme for tests. Tests need a Debug build with testability enabled (`@testable import MoviesPortfolio2`).

### Coverage

1. **Product → Scheme → Edit Scheme → Test → Options**
2. Enable **Code Coverage**
3. Run tests (⌘U), then open **Report navigator** (⌘9) → **Coverage**

MoviesCore tests cover models, networking, repositories, and image cache. App tests cover ViewModels, display model mapping, and `FavoritesRepository`.

## MoviesCore XCFramework

The sample app uses MoviesCore as a local Swift package. To build a binary for other Apple platforms:

```bash
cd Packages/MoviesCore
./Scripts/build-xcframework.sh
```

See [Packages/MoviesCore/XCFramework.md](Packages/MoviesCore/XCFramework.md) for integration steps.

## Known issues

- **Trending scroll flicker** — occasional cell recycling glitches in `LazyVGrid`. Details and attempted fixes: [ONGOING_ISSUES.md](ONGOING_ISSUES.md).

## Documentation

| Document | Description |
|----------|-------------|
| [ONGOING_ISSUES.md](ONGOING_ISSUES.md) | Open bugs and UX issues |
| [Packages/MoviesCore/XCFramework.md](Packages/MoviesCore/XCFramework.md) | Binary framework distribution |

## Tech stack

- **UI:** SwiftUI (primary), UIKit (search)
- **Architecture:** MVVM
- **Persistence:** Core Data (programmatic model)
- **Networking:** URLSession + Codable
- **Dependencies:** SPM (see table below)
- **Concurrency:** Swift 6, strict checking, `@MainActor` view models

### SPM dependencies

| Package | Purpose |
|---------|---------|
| MoviesCore (local) | TMDB models, networking, image cache |
| [SwiftLintPlugins](https://github.com/SimplyDanny/SwiftLintPlugins) | Lint at build time (`SwiftLintBuildToolPlugin`) |
| [swift-async-algorithms](https://github.com/apple/swift-async-algorithms) | Search query debouncing |


### AI Agent usage

Used Cursor AI agent for supporting faster implementation on the following topics
- Setup for .xcframework building of MoviesCore framework
- Unit test coverage 
- Documentation
