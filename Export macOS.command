#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
/Applications/Godot.app/Contents/MacOS/Godot --headless --path "$PWD/game" --export-debug macOS "$PWD/exports/Dreamland.zip"
open "$PWD/exports"
