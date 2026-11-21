#!/bin/bash
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314/Scripts:$PATH"
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314:$PATH"
export PATH="/c/Program Files/Git/cmd:$PATH"
export PATH="/c/Program Files/CMake/bin:$PATH"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="D:/zephyr-sdk-0.16.9"

set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
workspace=
dry_run=false

case $# in
  0) ;;
  1)
    if [[ $1 == --dry-run ]]; then
      dry_run=true
    else
      workspace=$1
    fi
    ;;
  2)
    workspace=$1
    [[ $2 == --dry-run ]] || {
      echo "Usage: $0 [west-workspace] [--dry-run]" >&2
      exit 2
    }
    dry_run=true
    ;;
  *)
    echo "Usage: $0 [west-workspace] [--dry-run]" >&2
    exit 2
    ;;
esac

if ! command -v west >/dev/null 2>&1; then
  echo "west is not installed or is not on PATH." >&2
  exit 127
fi

if [[ -z $workspace ]]; then
  workspace=${ZMK_TOUCH_WORKSPACE:-}
  if [[ -z $workspace ]]; then
    workspace=$(cd -- "$repo" && west topdir 2>/dev/null) || workspace=
  fi
  workspace=${workspace:-"$(dirname -- "$repo")/.kl-touch-workspace"}
fi

if [[ ! -d $workspace ]] || ! (cd -- "$workspace" && west topdir >/dev/null 2>&1); then
  echo "West workspace is not ready at: $workspace" >&2
  echo "Run ./touch-update.sh to initialize it and download dependencies." >&2
  exit 1
fi
workspace=$(cd -- "$workspace" && pwd)

if [[ ! -f "$workspace/zmk/app/include/zmk/studio/custom.h" ||
      ! -f "$workspace/zephyr/CMakeLists.txt" ]]; then
  echo "West dependencies are missing from: $workspace" >&2
  echo "Run ./touch-update.sh to download them." >&2
  exit 1
fi

export ZEPHYR_BASE="$workspace/zephyr"
export Zephyr_DIR="$ZEPHYR_BASE/share/zephyr-package/cmake"

args=("$workspace")
if [[ $dry_run == true ]]; then
  args+=(--dry-run)
fi

exec bash "$repo/scripts/build-ms18-scanner.sh" "${args[@]}"
