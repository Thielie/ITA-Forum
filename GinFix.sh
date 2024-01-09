#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ihr sudo-Passwort
echo -n "Geben Sie Ihr sudo-Passwort ein: "
read -s PASSWORD
echo

# Überprüfen, ob das Skript mit sudo gestartet wird
if [ "$EUID" -ne 0 ]
  then echo "Bitte führen Sie das Skript mit sudo-Rechten aus."
  exit

# Funktion, um sudo-Befehle mit vorher festgelegtem Passwort auszuführen
run_sudo() {
    echo $PASSWORD | sudo -S $@
}

# Update von Ubuntu
echo -e "${YELLOW}Aktualisiere das System...${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}Das System wurde erfolgreich aktualisiert!${NC}"

# Chromium Installation
echo -e "${YELLOW}Installiere Chromium...${NC}"
sudo apt install -y chromium-browser
echo -e "${GREEN}Chromium wurde erfolgreich installiert!${NC}"

# Visual Studio Code Installation
echo -e "${YELLOW}Installiere Visual Studio Code...${NC}"
sudo snap install --classic code
echo -e "${GREEN}Visual Studio Code wurde erfolgreich installiert!${NC}"

# Geany Installation
echo -e "${YELLOW}Installiere Geany...${NC}"
sudo apt install -y geany
echo -e "${GREEN}Geany wurde erfolgreich installiert!${NC}"

# LAMP-Stack Installation
# Apache Server installation
echo -e "${YELLOW}Apache-Server wird installiert...${NC}"
sudo apt install -y apache2
echo -e "${GREEN}Apache-Server wurde erfolgreich installiert!${NC}"
sudo ufw enable
sudo ufw allow in "Apache"

# MySQL-Server installation
echo -e "${YELLOW}MySQL-Server wird installiert...${NC}"
sudo apt install -y mysql-server
sudo systemctl enable mysql
echo -e "${GREEN}Der MySQL-Server wurde erfolgreich installiert!${NC}"

# PHP-Paket wird installiert
echo -e "${YELLOW}PHP-Paket wird installiert...${NC}"
sudo apt install -y php libapache2-mod-php php-mysql
echo -e "${GREEN}PHP-Paket wurde erfolgreich installiert!${NC}"
echo -e "${YELLOW}PHP-Paket wird nach der Version überprüft...${NC}"
php -v
echo -e "${GREEN}PHP-Paket wurde erfolgreich nach der Version überprüft!${NC}"

# WordPress Installation
# WordPress-CLI herunterladen und installieren
echo -e "${YELLOW}Installiere wp-cli...${NC}"
run_sudo apt-get install -y curl
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
echo -e "${GREEN}wp-cli wurde erfolgreich installiert!${NC}"

# WordPress Konfiguration
echo -e "${YELLOW}WordPress wird konfiguriert...${NC}"
WP_VERSION="latest"
WP_DB_NAME="wordpress"
WP_DB_USER="root"
WP_DB_PASSWORD=""
WP_DB_HOST="localhost"
WP_TABLE_PREFIX="wp_"
WP_SITE_URL="localhost"
WP_ADMIN_USER="admin"
WP_ADMIN_PASSWORD="admin"
WP_ADMIN_EMAIL="admin@example.com"
echo -e "${GREEN}WordPress wurde erfolgreich konfiguriert!${NC}"

# Neuer Benutzer Konfiguration
echo -e "${YELLOW}Ein neuer Benutzer wird konfiguriert...${NC}"
NEW_USER="cit"
NEW_USER_PASSWORD="cit"
NEW_USER_EMAIL="cit@example.com"
echo -e "${GREEN}Der neue Benutzer wurde erfolgreich konfiguriert!${NC}"

# Verzeichnis für WordPress-Installation
WP_INSTALL_DIR="/var/www/html"
echo -e "${YELLOW}Die WordPress-Installation wird in das ${WP_INSTALL_DIR} Verzeichnis gelegt...${NC}"
echo -e "${GREEN}WordPress wurde erfolgreich in das ${WP_INSTALL_DIR} Verzeichnis gelegt!${NC}"

# WordPress herunterladen und entpacken
echo -e "${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}"
wget -c https://wordpress.org/${WP_VERSION}.tar.gz
tar -xzvf ${WP_VERSION}.tar.gz -C /tmp/
rm ${WP_VERSION}.tar.gz
sudo cp -R /tmp/wordpress/* ${WP_INSTALL_DIR}
sudo rm -rf /tmp/wordpress
echo -e "${GREEN}WordPress wurde erfolgreich heruntergeladen und entpackt!${NC}"

# WordPress-Konfigurationsdatei erstellen
echo -e "${YELLOW}Eine WordPress-Konfigurationsdatei wird erstellt...${NC}"
sudo cp ${WP_INSTALL_DIR}/wp-config-sample.php ${WP_INSTALL_DIR}/wp-config.php
sudo sed -i "s/wordpress/$WP_DB_NAME/" ${WP_INSTALL_DIR}/wp-config.php
sudo sed -i "s/cit/$WP_DB_USER/" ${WP_INSTALL_DIR}/wp-config.php
sudo sed -i "s/cit/$WP_DB_PASSWORD/" ${WP_INSTALL_DIR}/wp-config.php
sudo sed -i "s/localhost/$WP_DB_HOST/" ${WP_INSTALL_DIR}/wp-config.php
sudo sed -i "s/wp_/$WP_TABLE_PREFIX/" ${WP_INSTALL_DIR}/wp-config.php
echo -e "${GREEN}Die WordPress-Konfigurationsdatei wurde erfolgreich erstellt!${NC}"

# WordPress-Verzeichnis-Berechtigungen setzen
echo -e "${YELLOW}Berechtigungen für das ${WP_INSTALL_DIR} Verzeichnis werden konfiguriert...${NC}"
sudo chown -R www-data:www-data ${WP_INSTALL_DIR}
sudo chmod -R 755 ${WP_INSTALL_DIR}
echo -e "${GREEN}Berechtigungen für das ${WP_INSTALL_DIR} Verzeichnis wurden erfolgreich konfiguriert!${NC}"

# Apache-Konfiguration
echo -e "${YELLOW}Apache wird konfiguriert...${NC}"
sudo a2enmod rewrite
sudo service apache2 restart
echo -e "${GREEN}Apache wurde erfolgreich konfiguriert und neu gestartet!${NC}"

# WordPress installieren
echo -e "${YELLOW}WordPress wird installiert...${NC}"
wp core install --url="$WP_SITE_URL" --title="My WordPress Site" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --path="${WP_INSTALL_DIR}"
echo -e "${GREEN}WordPress wurde erfolgreich installiert!${NC}"

# Neuen Benutzer hinzufügen
echo -e "${YELLOW}Der neue Benutzer wird hinzugefügt...${NC}"
wp user create $NEW_USER $NEW_USER_EMAIL --user_pass=$NEW_USER_PASSWORD --display_name=$NEW_USER --role=subscriber --path="${WP_INSTALL_DIR}"
echo -e "${GREEN}Der neue Benutzer wurde erfolgreich hinzugefügt!${NC}"

# PhpMyAdmin Installation und Konfiguration
# Konfigurationsvariablen
echo -e "${YELLOW}Konfigurationsvariablen werden erstellt...${NC}"
DB_USER="cit"
DB_USER_PASSWORD="cit"
PHPMYADMIN_DIR="/usr/share/phpmyadmin"
APACHE_CONF_DIR="/etc/apache2/conf-available"
APACHE_CONF_FILE="phpmyadmin.conf"
echo -e "${GREEN}Konfigurationsvariablen wurden erfolgreich erstellt!${NC}"

# PhpMyAdmin installieren
echo -e "${YELLOW}PhpMyAdmin wird installiert...${NC}"
sudo apt-get install -y phpmyadmin
echo -e "${GREEN}PhpMyAdmin wurde erfolgreich installiert!${NC}"

# MySQL-Benutzer für PhpMyAdmin konfigurieren
echo -e "${YELLOW}MySQL-Benutzer wird für PhpMyAdmin konfiguriert...${NC}"
mysql -u root -p <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo -e "${GREEN}MySQL-Benutzer wurde erfolgreich für PhpMyAdmin konfiguriert!${NC}"

# PhpMyAdmin Konfiguration für Apache erstellen
echo -e "${YELLOW}PhpMyAdmin Konfiguration wird für Apache erstellt...${NC}"
sudo echo "Include $PHPMYADMIN_DIR/apache.conf" > "$APACHE_CONF_DIR/$APACHE_CONF_FILE"
sudo a2enconf "$APACHE_CONF_FILE"
echo -e "${GREEN}PhpMyAdmin Konfiguration wurde erfolgreich für Apache erstellt!${NC}"

# Apache-Server neu starten
echo -e "${YELLOW}Apache-Server wird neu gestartet...${NC}"
sudo service apache2 restart
echo -e "${GREEN}Apache-Server wurde erfolgreich neu gestartet!${NC}"

echo -e "${GREEN}Die gesamte Installation wurde erfolgreich abgeschlossen!${NC}"
