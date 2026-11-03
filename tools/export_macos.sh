#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
/Applications/Godot.app/Contents/MacOS/Godot --headless --path "$PWD/game" --export-debug macOS "$PWD/exports/Dreamland.zip"
stage=$(mktemp -d "${TMPDIR:-/tmp}/Dreamland-build.XXXXXX")
trap 'rm -rf "$stage"' EXIT
ditto -x -k "$PWD/exports/Dreamland.zip" "$stage"
executable="$stage/Dreamland.app/Contents/MacOS/Dreamland"
lipo "$executable" -thin arm64 -output "$stage/Dreamland-arm64"
mv "$stage/Dreamland-arm64" "$executable"
chmod +x "$executable"
codesign --force --deep --sign - "$stage/Dreamland.app"
ditto -c -k --sequesterRsrc --keepParent "$stage/Dreamland.app" "$stage/Dreamland.zip"
mv "$stage/Dreamland.zip" "$PWD/exports/Dreamland.zip"
mkdir -p "$PWD/exports/macos"
ditto "$stage/Dreamland.app" "$PWD/exports/macos/Dreamland.app"
