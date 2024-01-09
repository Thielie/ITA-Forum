#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#Update von Ubuntu#
echo -e "${YELLOW}Aktualisiere das System...${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}Das System wurde erfolgreich aktualisiert!${NC}"

#Chromium Installation#
echo -e "${YELLOW}Installiere Chromium...${NC}"
sudo apt install -y chromium-browser
echo -e "${GREEN}Chromium wurde erfolgreich installiert!${NC}"

#Visual Studio Code Installation#
echo -e "${YELLOW}Installiere Visual Studio Code...${NC}"
sudo snap install --classic code
echo -e "${GREEN}Visual Studio Code wurde erfolgreich installiert!${NC}"

#Geany Installation#
echo -e "${YELLOW}Installiere Geany...${NC}"
sudo apt install -y geany
echo -e "${GREEN}Geany wurde erfolgreich installiert!${NC}"

#LAMP-Stack Installation#
#Apache Server installation 
echo -e "${YELLOW}Apache-Server wird installiert...${NC}"
sudo apt install apache2
echo -e "${GREEN}Apache-Server wurde erfolgreich installiert!${NC}"
sudo ufw enable
sudo ufw allow in "Apache"

#MySql-Server installation
echo -e "${YELLOW}MySQL-Server wird installiert...${NC}"
mysql_root_password=""
sudo apt install -y mysql-server
sudo service mysql start
sudo systemctl enable mysql
echo -e "${GREEN}Der MySql-Server wurde erfolgreich installiert!${NC}"
#PHP-Paket wird installiert
echo -e "${YELLOW}PHP-Paket wird installiert...${NC}"
sudo apt install php libapache2-mod-php php-mysql
echo -e "${GREEN}PHP-Paket wurde erfolgreich installiert!${NC}"
echo -e "${YELLOW}PHP-Paket wird nach der Version überprüft...${NC}"
php -v
echo -e "${GREEN}PHP-Paket wurde erfolgreich nach der Version überprüft!${NC}"

#WordPress Installation#
#WordPress-CLI herunterladen und installieren
echo -e "${YELLOW}Der WordPress-Client wird installiert...${NC}"
sudo apt-get install -y wp-cli
echo -e "${GREEN}Der WordPress-Client wurde erfolgreich installiert!${NC}"

# WordPress Konfiguration
echo -e "${YELLOW}WordPress wird konfiguriert...${NC}"
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
echo -e "${GREEN}WordPress wurde erfolgreich konfiguriert!${NC}"

# Neuer Benutzer Konfiguration
echo -e "${YELLOW}Ein neuer Benutzer wird konfiguriert...${NC}"
NEW_USER="new_user"
NEW_USER_PASSWORD="new_user_password"
NEW_USER_EMAIL="new_user@example.com"
echo -e "${GREEN}Der neue Benutzer wurde erfolgreich konfiguriert!${NC}"

# Verzeichnis für WordPress-Installation
echo -e "${YELLOW}Die WordPress installation wird in das ${WP_INSTALL_DIR} Verzeichnis gelegt...${NC}"
WP_INSTALL_DIR="/var/www/html"
echo -e "${GREEN}WordPress wurde erfolgreich in das ${WP_INSTALL_DIR} Verzeichnis gelegt!${NC}"

# WordPress herunterladen und entpacken
echo -e "${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}"
wget -c https://wordpress.org/${WP_VERSION}.tar.gz
tar -xzvf ${WP_VERSION}.tar.gz -C /tmp/
rm ${WP_VERSION}.tar.gz
cp -R /tmp/wordpress/* ${WP_INSTALL_DIR}
rm -rf /tmp/wordpress
echo -e "${GREEN}WordPress wurde erfolgreich heruntergeladen und entpackt!${NC}"

# WordPress-Konfigurationsdatei erstellen
echo -e "${YELLOW}Eine WordPress-Konfigurationsdatei wird erstellt...${NC}"
cp ${WP_INSTALL_DIR}/wp-config-sample.php ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/database_name_here/$WP_DB_NAME/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/username_here/$WP_DB_USER/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/password_here/$WP_DB_PASSWORD/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/localhost/$WP_DB_HOST/" ${WP_INSTALL_DIR}/wp-config.php
sed -i "s/wp_/$WP_TABLE_PREFIX/" ${WP_INSTALL_DIR}/wp-config.php
echo -e "${GREEN}Die WordPress-Konfigurationsdatei wurde erfolgreich erstellt!${NC}"

# WordPress-Verzeichnis-Berechtigungen setzen
echo -e "${YELLOW}Berechtigungen für das ${WP_INSTALL_DIR} Verzeichnis werden konfiguriert...${NC}"
chown -R www-data:www-data ${WP_INSTALL_DIR}
chmod -R 777 ${WP_INSTALL_DIR}
echo -e "${GREEN}Berechtigungen für das ${WP_INSTALL_DIR} Verzeichnis wurden erfolgreich konfiguriert!${NC}"

# Apache-Konfiguration
echo -e "${YELLOW}Apache wird konfiguriert...${NC}"
a2enmod rewrite
service apache2 restart
echo -e "${GREEN}Apache wurde erfolgreich konfiguriert und neu gestartet!${NC}"

# WordPress installieren
echo -e "${YELLOW}WordPress wird installiert...${NC}"
wp core install --url="$WP_SITE_URL" --title="My WordPress Site" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --path="${WP_INSTALL_DIR}"
echo -e "${GREEN}WordPress wurde erfolgreich installiert!${NC}"

# Neuen Benutzer hinzufügen
echo -e "${YELLOW}Der neue Benutzer wird hinzugefügt...${NC}"
wp user create $NEW_USER $NEW_USER_EMAIL --user_pass=$NEW_USER_PASSWORD --display_name=$NEW_USER --role=subscriber --path="${WP_INSTALL_DIR}"
echo -e "${GREEN}Der neue Benutzer wurde erfolgreich hinzugefügt!${NC}"

# Erfolgsmeldung ausgeben
echo -e "${GREEN}WordPress wurde erfolgreich installiert!${NC}"

#PhpMyAdmin installation und konfiguration'
#Konfigurationsvariablen
echo -e "${YELLOW}Konfigurationsvariablen werden erstellt...${NC}"
DB_USER="ita"
DB_USER_PASSWORD="ita"
PHPMYADMIN_DIR="/usr/share/phpmyadmin"
APACHE_CONF_DIR="/etc/apache2/conf-available"
APACHE_CONF_FILE="phpmyadmin.conf"
echo -e "${GREEN}Konfigurationsvariablen wurden erfolgreich erstellt!${NC}"

#PhpMyAdmin installieren
echo -e "${YELLOW}PhpMyAdmin wird installiert...${NC}"
apt-get install -y phpmyadmin
echo -e "${GREEN}PhpMyAdmin wurde erfolgreich installiert!${NC}"

#MySql-Benutzer für PhpMyAdmin konfigurieren
echo -e "${YELLOW}MySql-Benutzer wird für PhpMyAdmin konfiguriert...${NC}"
mysql -u root -p <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON . TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo -e "${GREEN}MySql-Benutzer wurde erfolgreich für PhpMyAdmin konfiguriert!${NC}"

#PhpMyAdmin Konfiguration für Apache erstellen
echo -e "${YELLOW}PhpMyAdmin Konfiguration wird für Apache erstellt...${NC}"
echo "Include $PHPMYADMIN_DIR/apache.conf" > "$APACHE_CONF_DIR/$APACHE_CONF_FILE"
a2enconf "$APACHE_CONF_FILE"
echo -e "${GREEN}PhpMyAdmin Konfiguration wurde erfolgreich für Apache erstellt!${NC}"

#Apache-Server neu starten
echo -e "${YELLOW}Apache-Server wird neu gestartet...${NC}"
sudo service apache2 restart
echo -e "${GREEN}Apache-Server wurde erfolgreich neu gestartet!${NC}"
echo -e "${GREEN}phpMyAdmin wurde erfolgreich installiert und konfiguriert. MySQL-Benutzer 'ita' wurde erstellt!${NC}"

echo "Installation abgeschlossen."

