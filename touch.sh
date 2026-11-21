

#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314/Scripts:$PATH"
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314:$PATH"
export PATH="/c/Program Files/Git/cmd:$PATH"
export PATH="/c/Program Files/CMake/bin:$PATH"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="D:/zephyr-sdk-0.16.9"

set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
workspace=
if command -v west >/dev/null 2>&1; then
  workspace=$(cd -- "$repo" && west topdir 2>/dev/null) || workspace=
fi
dry_run=false
update_only=false

if [[ ${1:-} == --update-only ]]; then
  update_only=true
  shift
  [[ $# -le 1 ]] || {
    echo "Usage: $0 [west-workspace] [--dry-run] | --update-only [west-workspace]" >&2
    exit 2
  }
  [[ $# -eq 0 ]] || workspace=$1
else
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
        echo "Usage: $0 [west-workspace] [--dry-run] | --update-only [west-workspace]" >&2
        exit 2
      }
      dry_run=true
      ;;
    *)
      echo "Usage: $0 [west-workspace] [--dry-run] | --update-only [west-workspace]" >&2
      exit 2
      ;;
  esac
fi

if ! command -v west >/dev/null 2>&1; then
  echo "west is not installed or is not on PATH." >&2
  exit 127
fi

if [[ -z $workspace ]]; then
  workspace=${ZMK_TOUCH_WORKSPACE:-"$(dirname -- "$repo")/.kl-touch-workspace"}
fi
workspace=$(mkdir -p -- "$workspace" && cd -- "$workspace" && pwd)

update_dependencies=false
if ! (cd -- "$workspace" && west topdir >/dev/null 2>&1); then
  if [[ $dry_run == true ]]; then
    echo "West workspace is not initialized at: $workspace"
    echo "Run ./touch.sh to initialize it, download dependencies, and build."
    exit 0
  fi

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
  update_dependencies=true
fi

if [[ ! -f "$workspace/zmk/app/include/zmk/studio/custom.h" ||
      ! -f "$workspace/zephyr/CMakeLists.txt" ]]; then
  update_dependencies=true
fi

if [[ $update_only == true || $update_dependencies == true ]]; then
  if [[ $dry_run == true ]]; then
    echo "Dependencies are missing; run ./touch-update.sh to download them."
    exit 0
  fi
  (cd -- "$workspace" && west update --narrow --fetch-opt=--depth=1)
  (cd -- "$workspace" && west zephyr-export)
fi

if [[ $update_only == true ]]; then
  echo "West dependencies updated in: $workspace"
  exit 0
fi

export ZEPHYR_BASE="$workspace/zephyr"
export Zephyr_DIR="$ZEPHYR_BASE/share/zephyr-package/cmake"

args=("$workspace")
if [[ $dry_run == true ]]; then
  args+=(--dry-run)
fi

exec bash "$repo/scripts/build-ms18-scanner.sh" "${args[@]}"
