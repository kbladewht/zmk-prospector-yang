#!/bin/bash
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314/Scripts:$PATH"
export PATH="/c/Users/dellht/AppData/Local/Programs/Python/Python314:$PATH"
export PATH="/c/Program Files/Git/cmd:$PATH"
export PATH="/c/Program Files/CMake/bin:$PATH"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="D:/zephyr-sdk-0.16.9"

set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
workspace="/d/project/GitHub/.kl-touch-workspace"

export ZEPHYR_BASE="$workspace/zephyr"
export Zephyr_DIR="$ZEPHYR_BASE/share/zephyr-package/cmake"

module="$repo/hardware/prospector-zmk-module"
if command -v cygpath >/dev/null 2>&1; then
  module_cmake=$(cygpath -m "$module")
  repo_cmake=$(cygpath -m "$repo")
else
  module_cmake=$module
  repo_cmake=$repo
fi


command=(west build -s "$workspace/zmk/app" -d "$workspace/build-ms18t-scanner"
  -b kblade//zmk -S studio-rpc-usb-uart -S zmk-usb-logging --
  "-DCMAKE_PREFIX_PATH=$workspace/zephyr/share/zephyr-package/cmake"
  "-DSHIELD=prospector_ms18t scanner_display"
  "-DZMK_CONFIG=$repo/config/scanner"
  "-DEXTRA_CONF_FILE=$repo/config/ms18-touch.conf"
  "-DZMK_EXTRA_MODULES=$module_cmake;$repo_cmake")
cd -- "$workspace"
"${command[@]}"



FILE_SUFFIX="_lcd"
SRC_FILE="$workspace/build-ms18t-scanner/zephyr/zmk.uf2"
# Generate filename with keyword, e.g., flash_left.uf2, flash_right.uf2, flash_dongle.uf2

DEST_FILE2="../flash${FILE_SUFFIX}_833.uf2"

. "$repo/common.sh"
echo "Copying $SRC_FILE to /c/Users/dellht/Downloads/zmk_${FILE_SUFFIX}.uf2"
cp "$SRC_FILE" "/c/Users/dellht/Downloads/zmk_${FILE_SUFFIX}_ms_$(date +%H%M).uf2"

polling_check
DEST_FILE="${DRIVE_P}:/"
echo "Copying $SRC_FILE to $DEST_FILE"
cp "$SRC_FILE" "$DEST_FILE"