#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ihr sudo-Passwort
#echo -n "Geben Sie Ihr sudo-Passwort ein: "
#read -s PASSWORD
#echo

# Überprüfen, ob das Skript mit sudo gestartet wird
#if [ "$EUID" -ne 0 ]
#  then echo "Bitte führen Sie das Skript mit sudo-Rechten aus."
#  exit

# Funktion, um sudo-Befehle mit vorher festgelegtem Passwort auszuführen
#run_sudo() {
 #   echo $PASSWORD | sudo -S $@
#}

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

#PhpMyAdmin Installation
# MySQL-Benutzer für phpMyAdmin konfigurieren
DB_USER="cit"
DB_PASSWORD="cit"
echo -e "${YELLOW}MySQL-Benutzer wird für phpMyAdmin konfiguriert...${NC}"
sudo mysql -u root <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo -e "${GREEN}MySQL-Benutzer wurde erfolgreich für phpMyAdmin konfiguriert!${NC}"

# Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration
echo -e "${YELLOW}Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration...${NC}"
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get update
sudo apt-get install -y phpmyadmin
echo -e "${GREEN}phpMyAdmin wurde erfolgreich installiert!${NC}"

# PhpMyAdmin-Konfiguration für Apache erstellen
PHPMYADMIN_CONF_FILE="/etc/apache2/conf-available/phpmyadmin.conf"
echo -e "${YELLOW}PhpMyAdmin Konfiguration wird für Apache erstellt...${NC}"
sudo ln -s /etc/phpmyadmin/apache.conf $PHPMYADMIN_CONF_FILE
sudo a2enconf phpmyadmin
sudo systemctl reload apache2.service
echo -e "${GREEN}PhpMyAdmin Konfiguration wurde erfolgreich für Apache erstellt!${NC}"

# WordPress Installation
# Datenbankkonfiguration
DB_NAME="wordpress"
DB_USER="admin"
DB_PASSWORD="admin"
DB_HOST="127.0.0.1"  # Änderung hier

# WordPress Konfiguration
WP_DIR="/var/www/html"
WP_URL="http://localhost"
WP_TITLE="My WordPress Site"
WP_ADMIN_USER="admin"
WP_ADMIN_PASSWORD="admin"
WP_ADMIN_EMAIL="admin@example.com"

# Neuen Benutzer für WordPress erstellen
WP_USER="cit"
WP_USER_PASSWORD="cit"

# WordPress herunterladen und entpacken
echo -e "${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}"
wget -c https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz -C /tmp/
sudo cp -R /tmp/wordpress/* $WP_DIR
sudo chown -R www-data:www-data $WP_DIR
sudo chmod -R 777 $WP_DIR
rm latest.tar.gz
echo -e "${GREEN}WordPress wurde erfolgreich heruntergeladen und entpackt!${NC}"

# WordPress-Konfigurationsdatei erstellen
echo -e "${YELLOW}WordPress-Konfigurationsdatei wird erstellt...${NC}"
sudo cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sudo sed -i "s/username_here/$DB_USER/" $WP_DIR/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" $WP_DIR/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" $WP_DIR/wp-config.php
echo -e "${GREEN}WordPress-Konfigurationsdatei wurde erfolgreich erstellt!${NC}"

# Apache-Konfiguration für mod_rewrite aktivieren
echo -e "${YELLOW}Aktiviere mod_rewrite in Apache...${NC}"
sudo a2enmod rewrite
sudo service apache2 restart
echo -e "${GREEN}mod_rewrite wurde erfolgreich aktiviert und Apache wurde neu gestartet!${NC}"

# WordPress über die Befehlszeile installieren
echo -e "${YELLOW}WordPress wird über die Befehlszeile installiert...${NC}"
sudo -u www-data wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_DIR"
echo -e "${GREEN}WordPress wurde erfolgreich über die Befehlszeile installiert!${NC}"

# Neuen Benutzer für WordPress erstellen
echo -e "${YELLOW}Neuen Benutzer wird erstellt...${NC}"
sudo -u www-data wp user create $WP_USER $WP_USER_PASSWORD --role=author --path="$WP_DIR"
echo -e "${GREEN}Neuer Benutzer wurde erfolgreich erstellt!${NC}"

echo -e "${GREEN}Die gesamte Installation wurde erfolgreich abgeschlossen!${NC}"
