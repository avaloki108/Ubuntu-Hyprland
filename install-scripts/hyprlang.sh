#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyplang #


#specific branch or release
lang_tag="v0.6.4"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the global functions script (provides REPO_ROOT/BUILD_SRC)
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Work in build/src to keep repo root clean
cd "$BUILD_SRC" || { echo "${ERROR} Failed to change directory to $BUILD_SRC"; exit 1; }

# Set the name of the log file to include the current date and time (under repo root)
LOG="$REPO_ROOT/Install-Logs/install-$(date +%d-%H%M%S)_hyprlang.log"
MLOG="$REPO_ROOT/Install-Logs/install-$(date +%d-%H%M%S)_hyprlang2.log"

# Prefer locally built hyprutils in /usr/local
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprlang dependencies${RESET} .... \n" "${INFO}"

# Check if hyprlang directory exists and remove it
if [ -d "hyprlang" ]; then
    rm -rf "hyprlang"
fi

# Clone and build 
printf "${INFO} Installing ${YELLOW}hyprlang $lang_tag${RESET} ...\n"
if git clone --recursive -b $lang_tag https://github.com/hyprwm/hyprlang.git; then
    cd hyprlang || exit 1
	cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} ${MAGENTA}hyprlang $lang_tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}hyprlang $lang_tag${RESET}" 2>&1 | tee -a "$MLOG"
    fi
    [ -f "$MLOG" ] && mv "$MLOG" "$REPO_ROOT/Install-Logs/" || true
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprlang $lang_tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}