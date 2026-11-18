#!/bin/bash
# Builds Audioware for the iPhone (CyPort: the Mac game 2.5.0 running on iOS under RED4ext with baked hooks) and stages
#   deploy/Cyberpunk 2077/red4ext/plugins/Audioware/{Audioware.dylib, mac-hooks.txt, Scripts/}
# Needs next to this repo: ../red4ext-rs (codeman101 fork, branch ios) and ../RED4ext.SDK-macos (branch mac-next).
# The hooks only exist in a CyPort app built with tools/sites/audioware.txt (25 baked sites, the list in macos/hook-offsets.txt).
# Usage: ios/build-ios.sh [--check-scripts]     --check-scripts also compiles the current CyPort script set plus these scripts (Mac libscc)
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="$HOME/.cargo/bin:$PATH"            # the rustup toolchain: Homebrew's rustc has no iOS std
SIGN_ID="${SIGN_ID:--}"   # "-" = ad-hoc: iOS loads a plugin from Documents only when it is signed by the app's team
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
rustup target add aarch64-apple-ios >/dev/null

IPHONEOS_DEPLOYMENT_TARGET=18.0 \
RED4EXT_SDK_DIR="${RED4EXT_SDK_DIR:-$PWD/../RED4ext.SDK-macos}" \
BINDGEN_EXTRA_CLANG_ARGS="-isysroot $SDK -miphoneos-version-min=18.0" \
  cargo build --release -p audioware --target aarch64-apple-ios

D="deploy/Cyberpunk 2077/red4ext/plugins/Audioware"
rm -rf deploy; mkdir -p "$D/Scripts"
cp target/aarch64-apple-ios/release/libaudioware.dylib "$D/Audioware.dylib"
rsync -a --exclude Debug --exclude Debug.reds crates/audioware/reds/ "$D/Scripts/"     # as in the Windows release: no Debug scripts
printf '# Audioware hook mode, one word: on (default), probe (pass-through detours that log their first calls), off (no hook)\non\n' > "$D/mac-hooks.txt"
codesign -f -s "$SIGN_ID" "$D/Audioware.dylib"
codesign -dv "$D/Audioware.dylib" 2>&1 | grep -E "Identifier|TeamIdentifier"
find deploy -type f | sort

if [ "${1:-}" = "--check-scripts" ]; then
  R="$PWD/../redscript-ios"; W="$(mktemp -d)/Documents/Cyberpunk 2077"
  "$R/test/make_workdir.sh" "$W"
  mkdir -p "$W/r6/scripts/Audioware"; cp -R "$D/Scripts/." "$W/r6/scripts/Audioware/"
  "$R/dist/compile_test_mac" "$W/r6" | grep -E "scc:|RESULT"
  rm -rf "${W%/Documents/*}"
fi
