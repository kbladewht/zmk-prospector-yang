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
