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
mysql_root_password=""
sudo apt install -y mysql-server
sudo service mysql start
sudo systemctl enable mysql
echo "MySQL Server wurde erfolgreich installiert und gestartet."
echo -e "${YELLOW}PHP-Paket wird installiert${NC}"
sudo apt install php libapache2-mod-php php-mysql
echo -e "${GREEN}PHP-Paket wurde installiert${NC}"
echo -e "${YELLOW}PHP-Paket wird nach Version überprüft${NC}"
php -v
echo -e "${GREEN}PHP-Paket wurde nach Version überprüft${NC}"
echo "Installation abgeschlossen."
