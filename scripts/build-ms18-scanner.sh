#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 1 || $# -gt 2 || ( $# -eq 2 && $2 != --dry-run ) ]]; then
  echo "Usage: $0 /path/to/west-workspace [--dry-run]" >&2; exit 2
fi
workspace=$(cd -- "$1" && pwd)
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
module="$repo/hardware/prospector-zmk-module"
if command -v cygpath >/dev/null 2>&1; then
  module_cmake=$(cygpath -m "$module")
  repo_cmake=$(cygpath -m "$repo")
else
  module_cmake=$module
  repo_cmake=$repo
fi
for required in "$workspace/zmk/app/include/zmk/studio/custom.h" \
    "$module/boards/kblade/board.yml" "$module/boards/shields/prospector_ms18/prospector_ms18.overlay"; do
  [[ -f "$required" ]] || { echo "Missing pinned dependency: $required" >&2; exit 1; }
done
command=(west build -s "$workspace/zmk/app" -d "$workspace/build-ms18-scanner"
  -b kblade//zmk -S studio-rpc-usb-uart -S zmk-usb-logging --
  "-DCMAKE_PREFIX_PATH=$workspace/zephyr/share/zephyr-package/cmake"
  "-DSHIELD=prospector_ms18 scanner_display"
  "-DZMK_CONFIG=$repo/config/scanner"
  "-DEXTRA_CONF_FILE=$repo/config/ms18-touch.conf"
  "-DZMK_EXTRA_MODULES=$module_cmake;$repo_cmake")
if [[ ${2:-} == --dry-run ]]; then printf '%q ' "${command[@]}";printf '\n';exit 0;fi
cd -- "$workspace"
"${command[@]}"
