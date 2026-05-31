#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Prompt for sudo if not root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!] This script requires administrative privileges (sudo) to install packages.${NC}"
    echo -e "Please run it as: sudo ./install_flatpak_apps.sh"
    exit 1
fi

echo -e "${BLUE}[*] Adding official stable PPA for Flatpak...${NC}"
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:flatpak/stable

echo -e "${BLUE}[*] Installing Flatpak and GNOME Software integration...${NC}"
apt-get update
apt-get install -y flatpak gnome-software-plugin-flatpak

echo -e "${BLUE}[*] Adding Flathub repository...${NC}"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Array of applications to install
# App Name -> Flatpak Application ID
declare -A APPS=(
    ["LibreOffice"]="org.libreoffice.LibreOffice"
    ["Firefox"]="org.mozilla.firefox"
    ["Telegram"]="org.telegram.desktop"
    ["TorrHunt"]="com.github.alexkdeveloper.torrhunt"
)

echo -e "${BLUE}[*] Installing applications from Flathub...${NC}"

for app_name in "${!APPS[@]}"; do
    app_id="${APPS[$app_name]}"
    echo -e "${YELLOW}>> Installing $app_name ($app_id)...${NC}"
    
    # We use -y to automatically say yes to any prompts during installation
    flatpak install -y flathub "$app_id"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✔] $app_name installed successfully!${NC}"
    else
        echo -e "${RED}[X] Failed to install $app_name.${NC}"
    fi
done

echo -e "${GREEN}[✔] All installations complete!${NC}"
echo -e "${YELLOW}[!] Note: Please restart your computer (or log out and back in) so that the newly installed Flatpak apps appear in your application launcher.${NC}"
