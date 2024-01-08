#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Hallo Welt $1"
curl "http://google.com"
echo "${YELLOW}Aktualisiere das System...${NC}"
sudo apt update && sudo apt upgrade -y
echo "${GREEN}Das System wurde aktualisiert!${NC}"
echo "${YELLOW}Installiere Chromium...${NC}"
sudo apt install -y chromium-browser
echo "${GREEN}Chromium wurde installiert${NC}"
echo "${YELLOW}Installiere Visual Studio Code...${NC}"
sudo snap install --classic code
echo "${GREEN}Visual Studio Code wurde installiert${NC}"
echo "${YELLOW}Installiere Geany...${NC}"
sudo apt install -y geany
echo "${GREEN}Geany wurde installiert${NC}"
echo "Installation abgeschlossen."
