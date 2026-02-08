#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# XDG-Desktop-Portal-Hyprland (build from source)

xdg_deps=(
  libdrm-dev
  libpipewire-0.3-dev
  libspa-0.2-dev
  libsdbus-c++-dev
  libwayland-client0
  wayland-protocols
  xdg-desktop-portal-gtk
)

#specific branch or release
tag="v1.3.10"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the global functions script (provides REPO_ROOT/BUILD_SRC)
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Work in build/src to keep repo root clean
cd "$BUILD_SRC" || { echo "${ERROR} Failed to change directory to $BUILD_SRC"; exit 1; }

LOG="$REPO_ROOT/Install-Logs/install-$(date +%d-%H%M%S)_xdph.log"
MLOG="$REPO_ROOT/Install-Logs/install-$(date +%d-%H%M%S)_xdph2.log"

# Remove old libexec path if exists
[[ -f "/usr/lib/xdg-desktop-portal-hyprland" ]] && sudo rm "/usr/lib/xdg-desktop-portal-hyprland"

# XDG-DESKTOP-PORTAL-HYPRLAND
printf "${NOTE} Installing ${SKY_BLUE}xdg-desktop-portal-hyprland dependencies${RESET}\n\n"

for PKG1 in "${xdg_deps[@]}"; do
  re_install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Clone, build, and install XDPH
printf "${NOTE} Cloning and Installing ${YELLOW}XDG Desktop Portal Hyprland $tag${RESET} ...\n"

# Check if xdg-desktop-portal-hyprland folder exists and remove it
if [ -d "xdg-desktop-portal-hyprland" ]; then
  printf "${NOTE} Removing existing xdg-desktop-portal-hyprland folder...\n"
  rm -rf "xdg-desktop-portal-hyprland" 2>&1 | tee -a "$LOG"
fi

if git clone --recursive -b "$tag" "https://github.com/hyprwm/xdg-desktop-portal-hyprland.git"; then
  cd "xdg-desktop-portal-hyprland" || exit 1
  cmake -DCMAKE_INSTALL_LIBEXECDIR=/usr/lib -DCMAKE_INSTALL_PREFIX=/usr -B build
  cmake --build build -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
  if sudo cmake --install build 2>&1 | tee -a "$MLOG"; then
    printf "${OK} ${MAGENTA}xdph $tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
  else
    echo -e "${ERROR} Installation failed for ${YELLOW}xdph $tag${RESET}" 2>&1 | tee -a "$MLOG"
  fi
  [ -f "$MLOG" ] && mv "$MLOG" "$REPO_ROOT/Install-Logs/" || true
  cd ..
else
  echo -e "${ERROR} Download failed for ${YELLOW}xdph $tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
