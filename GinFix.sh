#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

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
if ! command -v mysql &> /dev/null
then
    echo -e "${YELLOW}MySQL-Server wird installiert...${NC}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
    sudo apt-get install -y mysql-server
    sudo systemctl start mysql
    sudo systemctl enable mysql
    echo -e "${GREEN}MySQL-Server wurde erfolgreich installiert und gestartet!${NC}"
fi

# Erlaube MySQL-Root-Anmeldung über Socket-Mechanismus
echo -e "${YELLOW}Erlaube MySQL-Root-Anmeldung über Socket...${NC}"
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo -e "${GREEN}MySQL-Root-Anmeldung über Socket wurde erfolgreich aktiviert!${NC}"

# PHP-Paket wird installiert
echo -e "${YELLOW}PHP-Paket wird installiert...${NC}"
sudo apt install -y php libapache2-mod-php php-mysql
echo -e "${GREEN}PHP-Paket wurde erfolgreich installiert!${NC}"
echo -e "${YELLOW}PHP-Paket wird nach der Version überprüft...${NC}"
php -v
echo -e "${GREEN}PHP-Paket wurde erfolgreich nach der Version überprüft!${NC}"

# PhpMyAdmin Installation
# MySQL-Benutzer für phpMyAdmin konfigurieren
DB_USER="cit"
DB_PASSWORD="cit"
echo -e "${YELLOW}MySQL-Benutzer wird für phpMyAdmin konfiguriert...${NC}"
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
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
DB_USER="cit"
DB_PASSWORD="cit"
DB_HOST="localhost"

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

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# WordPress herunterladen und entpacken
echo -e "${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}"
wget -c https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz -C /tmp/
sudo cp -R /tmp/wordpress/* $WP_DIR
sudo chown -R www-data:www-data $WP_DIR
sudo chmod -R 777 $WP_DIR
rm latest.tar.gz
echo -e "${GREEN}WordPress wurde erfolgreich heruntergeladen und entpackt!${NC}"

# Apache-Konfiguration für mod_rewrite aktivieren
echo -e "${YELLOW}Aktiviere mod_rewrite in Apache...${NC}"
sudo a2enmod rewrite
sudo systemctl restart apache2
echo -e "${GREEN}mod_rewrite wurde erfolgreich aktiviert und Apache wurde neu gestartet!${NC}"

# WP-CLI installieren
echo "Installing WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# MySQL-Datenbank erstellen
echo -e "${YELLOW}MySQL-Datenbank wird erstellt...${NC}"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo -e "${GREEN}MySQL-Datenbank wurde erfolgreich erstellt!${NC}"

# WordPress Installation mit manuell erstellter wp-config.php
echo -e "${YELLOW}WordPress wird in der Datenbank '$DB_NAME' installiert...${NC}"

# Manuell wp-config.php erstellen
sudo cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sudo sed -i "s/username_here/$DB_USER/" $WP_DIR/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" $WP_DIR/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" $WP_DIR/wp-config.php

# WordPress-Datenbank erstellen
sudo -u www-data wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_DIR" \
    --skip-email

# Überprüfen Sie, ob die Installation erfolgreich war
if [ $? -eq 0 ]; then
    echo -e "${GREEN}WordPress wurde erfolgreich in der Datenbank '$DB_NAME' über die Befehlszeile installiert!${NC}"
else
    echo -e "${RED}Fehler bei der WordPress-Installation.${NC}"
fi

# Neuen Benutzer für WordPress erstellen
echo -e "${YELLOW}Neuer Benutzer wird erstellt...${NC}"
sudo -u www-data wp user create $WP_USER $WP_USER_PASSWORD --role=author --path="$WP_DIR" --user_email="${WP_USER}@example.com"
echo -e "${GREEN}Neuer Benutzer wurde erfolgreich erstellt!${NC}"


echo -e "${GREEN}Die gesamte Installation wurde erfolgreich abgeschlossen!${NC}"
