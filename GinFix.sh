#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Aktualisiere das System...${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}Das System wurde aktualisiert!${NC}"
echo -e "${YELLOW}Installiere Chromium...${NC}"
sudo apt install -y chromium-browser
echo -e "${GREEN}Chromium wurde installiert${NC}"
echo -e "${YELLOW}Installiere Visual Studio Code...${NC}"
sudo snap install --classic code
echo -e "${GREEN}Visual Studio Code wurde installiert${NC}"
echo -e "${YELLOW}Installiere Geany...${NC}"
sudo apt install -y geany
echo -e "${GREEN}Geany wurde installiert${NC}"
echo -e "${YELLOW}Apache-Server wird installiert${NC}"
sudo apt install apache2
echo -e "${GREEN}Apache-Server wurde installiert${NC}"
sudo ufw enable
sudo ufw allow in "Apache"
echo -e "${YELLOW}MySQL-Server wird installiert${NC}"
sudo apt install mysql-server
echo -e "${GREEN}MySQL-Server wurde installiert${NC}"

echo "Installation abgeschlossen."
