#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
./tools/export_macos.sh
open "$PWD/exports"
