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

workspace=${1:-${ZMK_TOUCH_WORKSPACE:-}}
if [[ -z $workspace ]] && command -v west >/dev/null 2>&1; then
  workspace=$(cd -- "$repo" && west topdir 2>/dev/null) || workspace=
fi
workspace=${workspace:-"$(dirname -- "$repo")/.kl-touch-workspace"}

if ! command -v west >/dev/null 2>&1; then
  echo "west is not installed or is not on PATH." >&2
  exit 127
fi

workspace=$(mkdir -p -- "$workspace" && cd -- "$workspace" && pwd)
if ! (cd -- "$workspace" && west topdir >/dev/null 2>&1); then
  manifest_repo="$workspace/zmk-prospector"
  if [[ ! -d "$manifest_repo/.git" ]]; then
    branch=$(git -C "$repo" branch --show-current)
    if [[ -z $branch ]]; then
      echo "Cannot bootstrap a workspace from a detached HEAD." >&2
      exit 1
    fi
    git clone --no-hardlinks --branch "$branch" "$repo" "$manifest_repo"
  fi
  cp -- "$repo/west.yml" "$manifest_repo/west.yml"
  (cd -- "$workspace" && west init -l zmk-prospector)
fi

(cd -- "$workspace" && west update --narrow --fetch-opt=--depth=1)
(cd -- "$workspace" && west zephyr-export)
echo "West dependencies updated in: $workspace"
