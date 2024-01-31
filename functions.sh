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

# Überprüfen, ob curl installiert ist
if ! command -v curl &> /dev/null; then
    echo "$(tput bold)$(tput setaf 1)curl ist nicht installiert. Bitte installieren Sie curl, um fortzufahren. Benutzen Sie dafür folgenden Befehl: sudo apt-get install curl$(tput sgr0)"
    exit 1
fi

# Warnung anzeigen, wenn das Skript nicht mit curl von GitHub ausgeführt wird
if [[ "${BASH_SOURCE[0]}" != "${0}" || -n "$1" && "$1" == "-L" && "$2" == "https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/GinFix.sh" ]]; then
    # Das Skript wird mit curl von GitHub ausgeführt
    echo "Skript wird mit curl von GitHub ausgeführt."
else
    # Das Skript wird nicht mit curl von GitHub ausgeführt
    echo "$(tput bold)$(tput setaf 3)WARNUNG: Das Skript sollte idealerweise mit dem Befehl 'curl' von GitHub ausgeführt werden.$(tput sgr0)"
fi

blink_text() {
    local text="$1"
    echo -e "${TURQUOISE}\033[5m$text${NC}"
}
