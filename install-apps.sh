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

echo -e "${BLUE}[*] Step 1: Adding official stable PPA for Flatpak...${NC}"
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:flatpak/stable

echo -e "${BLUE}[*] Step 2: Enabling 32-bit architecture and Multiverse for Steam and Wine...${NC}"
dpkg --add-architecture i386
add-apt-repository -y multiverse

echo -e "${BLUE}[*] Step 3: Installing APT packages (Flatpak, Steam, Wine)...${NC}"
apt-get update
# winbind is included here because MetaTrader 5 often requires it to connect to broker servers
apt-get install -y flatpak gnome-software-plugin-flatpak steam wine wine32 winbind

echo -e "${BLUE}[*] Step 4: Adding Flathub repository...${NC}"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo -e "${BLUE}[*] Step 5: Installing applications from Flathub...${NC}"

# Array of Flatpak applications to install
declare -A APPS=(
    ["Firefox"]="org.mozilla.firefox"
    ["LibreOffice"]="org.libreoffice.LibreOffice"
    ["Telegram"]="org.telegram.desktop"
    ["TorrHunt"]="com.github.alexkdeveloper.torrhunt"
)

for app_name in "${!APPS[@]}"; do
    app_id="${APPS[$app_name]}"
    echo -e "${YELLOW}>> Installing $app_name ($app_id)...${NC}"
    
    flatpak install -y flathub "$app_id"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✔] $app_name installed successfully!${NC}"
    else
        echo -e "${RED}[X] Failed to install $app_name.${NC}"
    fi
done

echo -e "${BLUE}[*] Step 6: Downloading MetaTrader 5 setup file...${NC}"
# Use SUDO_USER to find your real home directory instead of downloading to the root folder
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
wget -O "$USER_HOME/Downloads/mt5setup.exe" "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
chown $SUDO_USER:$SUDO_USER "$USER_HOME/Downloads/mt5setup.exe"

echo -e "${GREEN}[✔] All installations complete!${NC}"
echo -e "${YELLOW}[!] MT5 INSTRUCTIONS: The MetaTrader 5 installer has been downloaded to your Downloads folder.${NC}"
echo -e "${YELLOW}    To install it, open a terminal as your normal user (do not use sudo) and run:${NC}"
echo -e "${YELLOW}    wine ~/Downloads/mt5setup.exe${NC}"
echo -e "${YELLOW}[!] RESTART NOTE: Please restart your computer so Steam and your Flatpak apps appear in the application launcher.${NC}"