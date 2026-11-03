#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
exec /Applications/Godot.app/Contents/MacOS/Godot --path "$PWD/game"
