#!/bin/bash
# NEBULA INSTALLER MANAGER
# Powered By F Projects

PTERO="/var/www/pterodactyl"
RAW_LINK="https://github.com/FikXzModzDeveloper/Nebula-Theme-pterodactyl/raw/main/nebula.blueprint"

# ANSI Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
W='\033[1;37m'
N='\033[0m'

clear_screen() {
    clear
}

header() {
    clear
    echo -e "${C}            ☯︎  Y I N  –  Y A N G  ☯︎${N}\n"

    echo -e "${W}               ███╗   ██╗███████╗"
    echo -e "               ████╗  ██║██╔════╝"
    echo -e "               ██╔██╗ ██║█████╗  "
    echo -e "               ██║╚██╗██║██╔══╝  "
    echo -e "               ██║ ╚████║███████╗"
    echo -e "               ╚═╝  ╚═══╝╚══════╝${N}\n"

    echo -e "${B}                 NEBULA INSTALLER${N}"
    echo -e "${B}────────────────────────────────────────────────${N}"
    echo -e " ${G}Creator :${N} FallZx Infinity"
    echo -e " ${Y}YouTube :${N} FallZx -features"
    echo -e "${B}────────────────────────────────────────────────${N}"
}
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${R}[!] Harap jalankan dengan sudo/root${N}"
        exit 1
    fi
}

confirm() {
    echo -ne " ${Y}[?]${N} Lanjutkan proses? (y/n): "
    read input
    if [[ "$input" != "y" ]]; then
        return 1
    fi
    return 0
}

install_blueprint() {
    header
    echo -e "${W}Menu: Install Blueprint Framework${N}"
    echo ""
    
    if ! confirm; then return; fi

    echo -e "\n${B}[+] Update & Install Dependencies...${N}"
    sudo apt update -qq
    sudo apt install -y curl wget unzip git zip gnupg ca-certificates -qq

    echo -e "${B}[+] Setup Node.js v22...${N}"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt update -qq
    sudo apt install -y nodejs -qq

    echo -e "${B}[+] Setup Yarn & Pterodactyl...${N}"
    cd "$PTERO" || { echo -e "${R}Directory not found${N}"; return; }
    npm i -g yarn
    yarn install

    echo -e "${B}[+] Download Blueprint Release...${N}"
    wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | grep 'release.zip' | cut -d '"' -f 4)" -O "$PTERO/release.zip"
    unzip -o release.zip
    rm release.zip

    echo -e "${B}[+] Configure .blueprintrc...${N}"
    touch "$PTERO/.blueprintrc"
    echo 'WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";' > "$PTERO/.blueprintrc"
    chmod +x "$PTERO/blueprint.sh"

    echo -e "${G}[EXEC] Running Blueprint Init...${N}"
    bash "$PTERO/blueprint.sh"

    echo -e "\n${G}[✓] Blueprint Installed.${N}"
    read -n 1 -s -r -p "Tekan Enter untuk kembali..."
}

install_nebula() {
    header
    echo -e "${W}Menu: Install Nebula Theme${N}"
    echo ""

    if [[ ! -d "$PTERO" ]]; then
        echo -e "${R}[!] Folder Pterodactyl tidak ditemukan.${N}"
        read -n 1 -s -r -p "Kembali..."
        return
    fi

    if [[ ! -f "$PTERO/blueprint.sh" ]]; then
        echo -e "${R}[!] Blueprint belum terinstall.${N}"
        read -n 1 -s -r -p "Kembali..."
        return
    fi

    if ! confirm; then return; fi

    cd "$PTERO"
    
    echo -e "\n${B}[+] Downloading Nebula...${N}"
    rm -f nebula.blueprint
    wget -q -O nebula.blueprint "$RAW_LINK"

    echo -e "${G}[EXEC] Installing Nebula (Auto-Confirm)...${N}"
    
    # TRICK: Mengirim 2x Enter (\n) ke installer untuk skip "Press Return"
    # Ini tidak spam (tidak loop), hanya mengirim input yang dibutuhkan.
    if command -v blueprint &> /dev/null; then
        printf "\n\n" | blueprint -install nebula
    else
        printf "\n\n" | bash blueprint.sh -install nebula
    fi

    echo -e "\n${G}[✓] Nebula Installed.${N}"
    read -n 1 -s -r -p "Tekan Enter untuk kembali..."
}

check_root

while true; do
    header

    echo -e " ${C}┌─ MENU${N}"
    echo -e " ${C}│${N}"
    echo -e " ${C}│${W} [1]${N} Install Blueprint Framework"
    echo -e " ${C}│${W} [2]${N} Install Nebula Theme"
    echo -e " ${C}│${W} [3]${N} Exit"
    echo -e " ${C}│${N}"
    echo -e " ${C}└──────────────${N}"
    echo ""

    echo -ne " ${C}Input:${N} "
    read opt

    case $opt in
        1) install_blueprint ;;
        2) install_nebula ;;
        3) echo -e "\n${G}Good Bye.${N}"; exit 0 ;;
        *) echo -e "\n${R}Invalid Option${N}"; sleep 1 ;;
    esac
done