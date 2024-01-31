#!/bin/bash

# functions
success_message() {
    echo -e "${FAT}${GREEN}$1 wurde erfolgreich installiert!${NC}${NF}"
}

error_message() {
    echo -e "${FAT}${RED}Fehler bei der Installation von $1.${NC}${NF})"
}

get_user_choice() {
    local choice
    while true; do
        read -n 1 -p "$1" choice < /dev/tty
        echo ""
        
        if [ "$choice" = "j" ]; then
            return 0  # true
        elif [ "$choice" = "n" ]; then
            return 1  # false
        else
            echo -e "${FAT}${RED}Ungültige Eingabe. Bitte nur 'j' oder 'n' eingeben.${NC}${NF}"
        fi
    done
}

if ! command -v curl &> /dev/null; then
    echo "${FAT}${RED}curl ist nicht installiert. Bitte installieren Sie curl, um fortzufahren. Benutze dafür folgenden Befehl: sudo apt-get install curl${NC}${NF}"
    exit 1
fi

# Überprüfen, ob das Skript mit curl ausgeführt wird
if [[ "$(basename "$0")" != "curl" ]]; then
    echo "${FAT}${RED}Das Skript sollte mit dem Befehl 'curl' ausgeführt werden. Bitte Folgenden Befehl benutzen: curl -L https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/GinFix.sh | bash${NC}${NF}"
    exit 1
fi

blink_text() {
    local text="$1"
    echo -e "${TURQUOISE}\033[5m$text${NC}"
}
