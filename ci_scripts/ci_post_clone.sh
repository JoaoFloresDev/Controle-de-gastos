#!/bin/sh

# Xcode Cloud post-clone hook for Flutter macOS app.
# Xcode Cloud doesn't know Flutter natively, so we install Flutter and run
# pub get + the macOS configuration step before xcodebuild takes over.
# Without this, Xcode Cloud fails with:
#   - "could not find included file 'ephemeral/Flutter-Generated.xcconfig'"
#   - "Unable to load contents of file list:
#      'Pods-Runner-frameworks-Release-input-files.xcfilelist'"

set -e

FLUTTER_VERSION="3.38.7"
FLUTTER_HOME="$HOME/flutter"

echo "==> Installing Flutter $FLUTTER_VERSION"
git clone --depth 1 --branch "$FLUTTER_VERSION" \
  https://github.com/flutter/flutter.git "$FLUTTER_HOME"
export PATH="$FLUTTER_HOME/bin:$PATH"

echo "==> Flutter doctor"
flutter --version
flutter doctor || true

echo "==> Pub get + macOS config"
cd "$CI_PRIMARY_REPOSITORY_PATH/meus_gastos"
flutter pub get
flutter build macos --config-only --release

echo "==> Pod install"
cd macos
pod install --repo-update

echo "==> ci_post_clone.sh done"
