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


blink_text() {
    local text="$1"
    echo -e "${TURQUOISE}\033[5m$text${NC}"
}
