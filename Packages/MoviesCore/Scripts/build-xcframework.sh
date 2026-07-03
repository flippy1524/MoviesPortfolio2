#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="MoviesCoreFramework"
FRAMEWORK_NAME="MoviesCoreFramework"
OUTPUT_NAME="MoviesCore"
ARTIFACTS_DIR="$ROOT_DIR/Artifacts"
BUILD_DIR="$ARTIFACTS_DIR/build"

REQUIRED_SLICES=(
  "ios|generic/platform=iOS"
  "ios-simulator|generic/platform=iOS Simulator"
  "macos|generic/platform=macOS"
)

OPTIONAL_SLICES=(
  "tvos|generic/platform=tvOS"
  "tvos-simulator|generic/platform=tvOS Simulator"
)

rm -rf "$BUILD_DIR" "$ARTIFACTS_DIR/${OUTPUT_NAME}.xcframework"
mkdir -p "$BUILD_DIR"

archive() {
  local name="$1"
  local destination="$2"
  local archive_path="$BUILD_DIR/${name}.xcarchive"

  echo "==> Archiving ${name} (${destination})" >&2

  (
    cd "$ROOT_DIR"
    xcodebuild archive \
      -scheme "$SCHEME" \
      -destination "$destination" \
      -archivePath "$archive_path" \
      -derivedDataPath "$BUILD_DIR/DerivedData-${name}" \
      -configuration Release \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
      SKIP_INSTALL=NO \
      ONLY_ACTIVE_ARCH=NO \
      CODE_SIGNING_ALLOWED=NO \
      >/dev/null
  )

  local framework_path="$archive_path/Products/usr/local/lib/${FRAMEWORK_NAME}.framework"
  if [[ ! -d "$framework_path" ]]; then
    echo "Framework not found at ${framework_path}" >&2
    return 1
  fi

  printf '%s\n' "$framework_path"
}

try_archive() {
  local name="$1"
  local destination="$2"
  local required="$3"

  if framework_path="$(archive "$name" "$destination")"; then
    printf '%s\n' "$framework_path"
    return 0
  fi

  if [[ "$required" == "required" ]]; then
    echo "Required slice '${name}' failed." >&2
    exit 1
  fi

  echo "Skipped optional slice '${name}' (platform SDK may be missing)." >&2
  return 1
}

FRAMEWORK_ARGS=()

add_slice() {
  local entry="$1"
  local required="$2"
  local name="${entry%%|*}"
  local destination="${entry#*|}"

  if framework_path="$(try_archive "$name" "$destination" "$required")"; then
    FRAMEWORK_ARGS+=(-framework "$framework_path")
  fi
}

for entry in "${REQUIRED_SLICES[@]}"; do
  add_slice "$entry" "required"
done

for entry in "${OPTIONAL_SLICES[@]}"; do
  add_slice "$entry" "optional" || true
done

echo "==> Creating ${OUTPUT_NAME}.xcframework" >&2

xcodebuild -create-xcframework \
  "${FRAMEWORK_ARGS[@]}" \
  -output "$ARTIFACTS_DIR/${OUTPUT_NAME}.xcframework"

echo "==> Built $ARTIFACTS_DIR/${OUTPUT_NAME}.xcframework"
du -sh "$ARTIFACTS_DIR/${OUTPUT_NAME}.xcframework"
