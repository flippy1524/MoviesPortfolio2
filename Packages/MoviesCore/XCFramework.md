# MoviesCore XCFramework

Binary distribution of `MoviesCore` for iOS, iPadOS, macOS, and tvOS hosts.

## Build

From the package root:

```bash
./Scripts/build-xcframework.sh
```

Requirements:

- Xcode with iOS and macOS SDKs installed
- tvOS slices are included when the tvOS SDK is available (optional)

Output (gitignored):

```
Artifacts/MoviesCore.xcframework
```

Intermediate archives live under `Artifacts/build/` and are removed on the next run.

## Verify package tests first

```bash
swift test
```

## Add to an Xcode app

1. Drag `Artifacts/MoviesCore.xcframework` into your project navigator.
2. Target → **General** → **Frameworks, Libraries, and Embedded Content**
3. Set **Embed** to **Do Not Embed** for a Swift framework consumed by the app target.

Import in Swift:

```swift
import MoviesCore
```

## Platform notes

| Platform | Slice in XCFramework |
|----------|----------------------|
| iOS / iPadOS (device) | `ios-arm64` |
| iOS / iPadOS (Simulator) | `ios-arm64_x86_64-simulator` |
| macOS | `macos-arm64_x86_64` |
| tvOS (device) | `tvos-arm64` (when SDK installed) |
| tvOS (Simulator) | `tvos-arm64_x86_64-simulator` (when SDK installed) |

Minimum OS versions match `Package.swift`: iOS 18, macOS 15, tvOS 18.

## API key at runtime

Host apps must supply a TMDB API key through their own configuration. `MoviesCore` reads configuration via `APIConfiguration.load(from:)` and `AppEnvironment` — wire these the same way as the sample app’s `Config/AppInfo.plist` + xcconfig flow.

## Local development

The sample app uses the Swift package directly (`Packages/MoviesCore`) via Xcode’s local package dependency. Use the XCFramework when integrating into a project that does not use SPM for this module.

## Version

```swift
MoviesCoreMetadata.version
```
