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
    echo -e "Please run it as: sudo ./install-apps.sh"
    exit 1
fi

echo -e "${BLUE}[*] Step 1: Adding Official Repositories...${NC}"
apt-get update
# Ensure curl, gpg, and git are installed
apt-get install -y software-properties-common curl gpg git

# Google Antigravity
mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | tee /etc/apt/sources.list.d/google_antigravity.list > /dev/null

echo -e "${BLUE}[*] Step 2: Installing core packages and CLI tools...${NC}"
apt-get update

# Core GUI dependencies, Unikey, and Antigravity
apt-get install -y ibus-unikey antigravity

# Requested system utilities, CLI tools, Zsh, and Cheese (webcam)
apt-get install -y wireguard vim python3 htop grep curl bsdutils 7zip hostname gpg zsh cheese

echo -e "${BLUE}[*] Step 3: Installing Desktop Applications via APT...${NC}"
# Installing standard applications that were previously handled by Flatpak
apt-get install -y firefox libreoffice telegram-desktop qbittorrent keepassxc vlc

echo -e "${BLUE}[*] Step 4: Installing Oh My Zsh and setting default shell...${NC}"
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    
    echo -e "${YELLOW}>> Installing Oh My Zsh for user: $SUDO_USER...${NC}"
    # Run the Oh My Zsh installation script as the standard user, unattended
    sudo -u "$SUDO_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    echo -e "${YELLOW}>> Setting Zsh as the default shell for $SUDO_USER...${NC}"
    chsh -s "$(which zsh)" "$SUDO_USER"
    
    echo -e "${GREEN}[✔] Oh My Zsh installed and default shell updated!${NC}"
else
    echo -e "${RED}[X] Could not determine the standard user. Skipping Oh My Zsh installation.${NC}"
fi

echo -e "${GREEN}[✔] All installations complete!${NC}"

echo -e "${YELLOW}[!] VIETNAMESE TYPING (UNIKEY):${NC}"
echo -e "    1. After restarting your computer, open 'Input Method' from your XFCE Whisker menu."
echo -e "    2. Set the input framework to 'ibus' if it isn't already."
echo -e "    3. Open IBus Preferences, go to the 'Input Method' tab."
echo -e "    4. Click 'Add', select 'Vietnamese', and choose 'Unikey'."

echo -e "${YELLOW}[!] MISSING APPLICATIONS NOTE:${NC}"
echo -e "    Because Flatpak was removed, TradingView and TorrHunt were not installed."
echo -e "    - To install TradingView, download the official Linux .deb file from their website."

echo -e "${YELLOW}[!] ANTIGRAVITY:${NC}"
echo -e "    Launch Antigravity from your application menu. You will need to sign in with your Google account on the first launch to initialize the AI agents."

echo -e "${YELLOW}[!] ZSH NOTE: You will need to log out and log back in (or restart) for Zsh to become your active default shell.${NC}"

echo -e "${YELLOW}[!] RESTART NOTE: Please restart your computer now so all new apps, the shell change, and configurations load correctly.${NC}"
