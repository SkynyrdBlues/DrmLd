#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Blender.app/Contents/MacOS/Blender --version | head -n 1
git --version
git lfs version
test -f game/addons/dialogue_manager/plugin.cfg
test -f "$HOME/Library/Application Support/Godot/export_templates/4.7.2.stable/macos.zip"
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path "$PWD/game" --import
/Applications/Godot.app/Contents/MacOS/Godot --headless --path "$PWD/game" --quit-after 5
