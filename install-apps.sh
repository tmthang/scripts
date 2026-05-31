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

echo -e "${BLUE}[*] Step 1: Adding official PPAs (Flatpak and IBus-Bamboo)...${NC}"
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:flatpak/stable
add-apt-repository -y ppa:bamboo-engine/ibus-bamboo

echo -e "${BLUE}[*] Step 2: Enabling 32-bit architecture and Multiverse for Steam and Wine...${NC}"
dpkg --add-architecture i386
add-apt-repository -y multiverse

echo -e "${BLUE}[*] Step 3: Installing APT packages (Flatpak, Steam, Wine, IBus-Bamboo)...${NC}"
apt-get update
# winbind is included because MetaTrader 5 often requires it to connect to broker servers
apt-get install -y flatpak gnome-software-plugin-flatpak steam wine wine32 winbind ibus-bamboo

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

echo -e "${YELLOW}[!] MT5 INSTRUCTIONS:${NC}"
echo -e "    The MT5 installer is in your Downloads folder. Run it as your normal user via terminal:"
echo -e "    wine ~/Downloads/mt5setup.exe"

echo -e "${YELLOW}[!] VIETNAMESE TYPING (BAMBOO):${NC}"
echo -e "    After restarting your computer, go to Settings -> Keyboard -> Input Sources."
echo -e "    Click 'Add Input Source', select 'Vietnamese', and choose 'Vietnamese (Bamboo)'."
echo -e "    You can switch languages using Super+Space."

echo -e "${YELLOW}[!] RESTART NOTE: Please restart your computer now so Steam, Flatpak apps, and Bamboo all load correctly.${NC}"