#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#Update von Ubuntu#
echo -e "${YELLOW}Aktualisiere das System...${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}Das System wurde aktualisiert!${NC}"

#Chromium Installation#
echo -e "${YELLOW}Installiere Chromium...${NC}"
sudo apt install -y chromium-browser
echo -e "${GREEN}Chromium wurde installiert${NC}"

#Visual Studio Code Installation#
echo -e "${YELLOW}Installiere Visual Studio Code...${NC}"
sudo snap install --classic code
echo -e "${GREEN}Visual Studio Code wurde installiert${NC}"

#Geany Installation#
echo -e "${YELLOW}Installiere Geany...${NC}"
sudo apt install -y geany
echo -e "${GREEN}Geany wurde installiert${NC}"

#LAMP-Stack Installation#
#Apache Server installation 
echo -e "${YELLOW}Apache-Server wird installiert${NC}"
sudo apt install apache2
echo -e "${GREEN}Apache-Server wurde installiert${NC}"
sudo ufw enable
sudo ufw allow in "Apache"
echo -e "${YELLOW}MySQL-Server wird installiert${NC}"
mysql_root_password=""
#MySql-Server installation
sudo apt install -y mysql-server
sudo service mysql start
sudo systemctl enable mysql
echo "MySQL Server wurde erfolgreich installiert und gestartet."
#PHP-Paket wird installiert
echo -e "${YELLOW}PHP-Paket wird installiert${NC}"
sudo apt install php libapache2-mod-php php-mysql
echo -e "${GREEN}PHP-Paket wurde installiert${NC}"
echo -e "${YELLOW}PHP-Paket wird nach Version überprüft${NC}"
php -v
echo -e "${GREEN}PHP-Paket wurde nach Version überprüft${NC}"

#WordPress Installation#
#WordPress-CLI herunterladen und installieren
echo -e "${YELLOW}Der WordPress-Client wird installiert${NC}"
sudo apt-get install -y wp-cli
echo -e "${GREEN}Der WordPress-Client wurde installiert${NC}"

# WordPress Konfiguration
WP_VERSION="latest"
WP_DB_NAME="wordpress_db"
WP_DB_USER="wordpress_user"
WP_DB_PASSWORD="your_password"
WP_DB_HOST="localhost"
WP_TABLE_PREFIX="wp_"
WP_SITE_URL="http://your_domain.com"
WP_ADMIN_USER="admin"
WP_ADMIN_PASSWORD="admin_password"
WP_ADMIN_EMAIL="admin@example.com"

# Neuer Benutzer Konfiguration
NEW_USER="new_user"
NEW_USER_PASSWORD="new_user_password"
NEW_USER_EMAIL="new_user@example.com"

# Verzeichnis für WordPress-Installation
WP_INSTALL_DIR="/var/www/html"

# WordPress herunterladen und entpacken
wget -c https://wordpress.org/${WP_VERSION}.tar.gz
tar -xzvf ${WP_VERSION}.tar.gz -C /tmp/
rm ${WP_VERSION}.tar.gz
cp -R /tmp/wordpress/* ${WP_INSTALL_DIR}
rm -rf /tmp/wordpress

# WordPress-Konfigurationsdatei erstellen
cp ${WP_INSTALL_DIR}/wp-config-sample.php ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/database_name_here/$WP_DB_NAME/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/username_here/$WP_DB_USER/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/password_here/$WP_DB_PASSWORD/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/localhost/$WP_DB_HOST/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/wp_/$WP_TABLE_PREFIX/" ${WP_INSTALL_DIR}/wp-config.php

# WordPress-Verzeichnis-Berechtigungen setzen
chown -R www-data:www-data ${WP_INSTALL_DIR}
chmod -R 755 ${WP_INSTALL_DIR}

# Apache-Konfiguration
a2enmod rewrite
service apache2 restart

# WordPress installieren
wp core install --url="$WP_SITE_URL" --title="My WordPress Site" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --path="${WP_INSTALL_DIR}"

# Neuen Benutzer hinzufügen
wp user create $NEW_USER $NEW_USER_EMAIL --user_pass=$NEW_USER_PASSWORD --display_name=$NEW_USER --role=subscriber --path="${WP_INSTALL_DIR}"

# Erfolgsmeldung ausgeben
echo "WordPress wurde erfolgreich installiert. Besuche $WP_SITE_URL im Browser, um deine Seite zu sehen."
echo "Installation abgeschlossen."
