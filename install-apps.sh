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

echo -e "${BLUE}[*] Step 1: Adding PPAs and Official Repositories...${NC}"
apt-get update
# Ensure curl and gpg are installed for adding repository keys
apt-get install -y software-properties-common curl gpg

# Flatpak and IBus-Bamboo
add-apt-repository -y ppa:flatpak/stable
add-apt-repository -y ppa:bamboo-engine/ibus-bamboo

# Google Antigravity
mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | tee /etc/apt/sources.list.d/google_antigravity.list > /dev/null

echo -e "${BLUE}[*] Step 2: Enabling 32-bit architecture and Multiverse for Steam and Wine...${NC}"
dpkg --add-architecture i386
add-apt-repository -y multiverse

echo -e "${BLUE}[*] Step 3: Installing APT system packages and CLI tools...${NC}"
apt-get update
# Core GUI dependencies and platforms
apt-get install -y flatpak gnome-software-plugin-flatpak steam wine wine32 winbind ibus-bamboo antigravity
# Requested system utilities and CLI tools
apt-get install -y wireguard vim python3 htop grep curl bsdutils 7zip hostname gpg

echo -e "${BLUE}[*] Step 4: Adding Flathub repository...${NC}"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo -e "${BLUE}[*] Step 5: Installing applications from Flathub...${NC}"

# Array of Flatpak applications to install
declare -A APPS=(
    ["Firefox"]="org.mozilla.firefox"
    ["LibreOffice"]="org.libreoffice.LibreOffice"
    ["Telegram"]="org.telegram.desktop"
    ["TorrHunt"]="com.github.alexkdeveloper.torrhunt"
    ["TradingView"]="com.tradingview.TradingView"
    ["qBittorrent"]="org.qbittorrent.qBittorrent"
    ["KeePassXC"]="org.keepassxc.KeePassXC"
    ["VLC"]="org.videolan.VLC"
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

echo -e "${YELLOW}[!] ANTIGRAVITY:${NC}"
echo -e "    Launch Antigravity from your application menu. You will need to sign in with your Google account on the first launch to initialize the AI agents."

echo -e "${YELLOW}[!] RESTART NOTE: Please restart your computer now so all new apps and configurations load correctly.${NC}"
