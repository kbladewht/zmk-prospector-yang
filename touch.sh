#!/bin/bash
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314/Scripts:$PATH"
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314:$PATH"
export PATH="/c/Program Files/Git/cmd:$PATH"
export PATH="/c/Program Files/CMake/bin:$PATH"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="D:/zephyr-sdk-0.16.9"

set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [west-workspace]" >&2
  exit 2
fi
workspace=${1:-${ZMK_TOUCH_WORKSPACE:-"$(dirname -- "$repo")/.kl-touch-workspace"}}
if [[ ! -d $workspace ]]; then
  echo "Workspace not found: $workspace" >&2
  echo "Run ./touch-update.sh first." >&2
  exit 1
fi
workspace=$(cd -- "$workspace" && pwd)

export ZEPHYR_BASE="$workspace/zephyr"
export Zephyr_DIR="$ZEPHYR_BASE/share/zephyr-package/cmake"

exec bash "$repo/scripts/build-ms18-scanner.sh" "$workspace"
