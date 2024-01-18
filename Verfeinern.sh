#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color


# Funktion für Fehlermeldung
error_message() {
    echo -e "${RED}Fehler bei der Installation von $1.${NC}"
}

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# Update von Ubuntu
#echo -e "${YELLOW}Aktualisiere das System...${NC}"#
#if sudo apt update && sudo apt upgrade -y; 
#then
#    echo -e "${GREEN}Das System wurde erfolgreich aktualisiert!${NC}"
#else
#    error_message "Systemaktualisierung"
#fi

# Funktion für erfolgreiche Meldung
success_message() {
    echo -e "${GREEN}$1 wurde erfolgreich installiert!${NC}"
}

# Funktion für Fehlermeldung
error_message() {
    echo -e "${RED}Fehler bei der Installation von $1.${NC}"
}

# Ja/Nein-Abfrage über den Terminal-Input
yes_no_prompt() {
    read -p "Möchten Sie Chromium installieren? (Ja/Nein): " yn
    case $yn in
        [Jj]* ) return 0;;  # 0 steht für "Ja"
        [Nn]* ) return 1;;  # 1 steht für "Nein"
        * ) echo "Bitte antworten Sie mit Ja oder Nein." && return 2;;
    esac
}

# Ja/Nein-Abfrage aufrufen
result=$(yes_no_prompt)
if [ $result -eq 0 ]; then
    echo -e "${YELLOW}Installiere Chromium...${NC}"
    if sudo apt install chromium-browser; then
        success_message "Chromium"
    else
        error_message "Chromium"
    fi
else
    echo "Chromium-Installation abgebrochen."
fi

# Chromium Installation
#echo -e "${YELLOW}Installiere Chromium...${NC}"
#sudo apt install -y non-existent-package  # Non-existent package to simulate an error
#if [ $? -eq 0 ]; then
#    echo -e "${GREEN}Chromium wurde erfolgreich installiert!${NC}"
#else
#    echo -e "${RED}Fehler bei der Installation von Chromium.${NC}"
#fi



# Visual Studio Code Installation
echo -e "${YELLOW}Installiere Visual Studio Code...${NC}"
if sudo snap install --classic code; 
then
    echo -e "${GREEN}Visual Studio Code wurde erfolgreich installiert!${NC}"
else
    error_message "Visual Studio Code"
fi

# Geany Installation
echo -e "${YELLOW}Installiere Geany...${NC}"
if sudo apt install -y geany; then
    echo -e "${GREEN}Geany wurde erfolgreich installiert!${NC}"
else
    echo -e "${RED}Fehler bei der Installation von Geany.${NC}"
fi

# LAMP-Stack Installation
# Apache Server installation
echo -e "${YELLOW}Apache-Server wird installiert...${NC}"
if sudo apt install -y apache2; then
    echo -e "${GREEN}Apache-Server wurde erfolgreich installiert!${NC}"
else
    error_message "Apache-Server"
fi
sudo ufw enable
sudo ufw allow in "Apache"

# MySQL-Server installation
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}MySQL-Server wird installiert...${NC}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
    if sudo apt-get install -y mysql-server; then
        sudo systemctl start mysql
        sudo systemctl enable mysql
        echo -e "${GREEN}MySQL-Server wurde erfolgreich installiert und gestartet!${NC}"
    else
        error_message "MySQL-Server"
    fi
fi

# PHP-Paket wird installiert
echo -e "${YELLOW}PHP-Paket wird installiert...${NC}"
if sudo apt install -y php libapache2-mod-php php-mysql; then
    echo -e "${GREEN}PHP-Paket wurde erfolgreich installiert!${NC}"
else
    error_message "PHP-Paket"
fi
echo -e "${YELLOW}PHP-Paket wird nach der Version überprüft...${NC}"
php -v
echo -e "${GREEN}PHP-Paket wurde erfolgreich nach der Version überprüft!${NC}"

# Erlaube MySQL-Root-Anmeldung über Socket-Mechanismus
echo -e "${YELLOW}Erlaube MySQL-Root-Anmeldung über Socket...${NC}"
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo -e "${GREEN}MySQL-Root-Anmeldung über Socket wurde erfolgreich aktiviert!${NC}"

MYSQL_ROOT_PASSWORD="root"
DB_USER="cit"
DB_PASSWORD="cit"
EXCLUDED_DATABASES=("sys" "mysql" "phpmyadmin" "information_schema" "performance_schema")

echo -e "${YELLOW}MySQL-Benutzer wird für phpMyAdmin konfiguriert...${NC}"
if sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT
then
    echo -e "${GREEN}MySQL-Benutzer wurde erfolgreich für phpMyAdmin konfiguriert!${NC}"
else
    error_message "MySQL-Benutzer für phpMyAdmin"
fi

# Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration
echo -e "${YELLOW}Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration...${NC}"
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
if sudo apt-get update && sudo apt-get install -y phpmyadmin; then
    echo -e "${GREEN}phpMyAdmin wurde erfolgreich installiert!${NC}"
else
    error_message "phpMyAdmin"
fi

# PhpMyAdmin-Konfiguration für Apache erstellen
PHPMYADMIN_CONF_FILE="/etc/apache2/conf-available/phpmyadmin.conf"
echo -e "${YELLOW}PhpMyAdmin Konfiguration wird für Apache erstellt...${NC}"
sudo ln -s /etc/phpmyadmin/apache.conf $PHPMYADMIN_CONF_FILE
sudo a2enconf phpmyadmin
if sudo systemctl reload apache2.service; then
    echo -e "${GREEN}PhpMyAdmin Konfiguration wurde erfolgreich für Apache erstellt!${NC}"
else
    error_message "Apache-Server-Neustart nach phpMyAdmin-Konfiguration"
fi

# WordPress Installation
# Datenbankkonfiguration
DB_NAME="wordpress"
DB_HOST="localhost"

# WordPress Konfiguration
WP_DIR="/var/www/html/wp"  # Hier wird der Ordner "wp" erstellt
WP_URL="http://localhost/wp"
WP_TITLE="My WordPress Site"
WP_ADMIN_USER="admin"
WP_ADMIN_PASSWORD="admin"
WP_ADMIN_EMAIL="admin@example.com"

# Neuen Benutzer für WordPress erstellen
WP_USER="wordpress"
WP_USER_PASSWORD="wordpress"
WP_USER_EMAIL="wordpress@example.com"


# WordPress herunterladen und entpacken
echo -e "${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}"
if wget -c https://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz -C /tmp/ && sudo mkdir -p $WP_DIR && sudo cp -R /tmp/wordpress/* $WP_DIR && sudo chown -R www-data:www-data $WP_DIR && sudo chmod -R 777 $WP_DIR && rm latest.tar.gz; then
    echo -e "${GREEN}WordPress wurde erfolgreich heruntergeladen und entpackt!${NC}"
else
    error_message "WordPress (Herunterladen und Entpacken)"
fi

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# Apache-Konfiguration für mod_rewrite aktivieren
echo -e "${YELLOW}Aktiviere mod_rewrite in Apache...${NC}"
if sudo a2enmod rewrite && sudo systemctl restart apache2; then
    echo -e "${GREEN}mod_rewrite wurde erfolgreich aktiviert und Apache wurde neu gestartet!${NC}"
else
    error_message "mod_rewrite-Aktivierung und Apache-Neustart"
fi

# WP-CLI installieren
echo "Installing WP-CLI..."
if curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp; then
    echo -e "${GREEN}WP-CLI wurde erfolgreich installiert!${NC}"
else
    error_message "WP-CLI"
fi

# MySQL-Datenbank erstellen
echo -e "${YELLOW}MySQL-Datenbank wird erstellt...${NC}"
if mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
MYSQL_SCRIPT
then
    echo -e "${GREEN}MySQL-Datenbank wurde erfolgreich erstellt!${NC}"
else
    error_message "MySQL-Datenbank"
fi

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# MySQL-Benutzer für WordPress erstellen
WP_DB_USER="wordpress"
WP_DB_PASSWORD="wordpress"

echo -e "${YELLOW}MySQL-Benutzer 'wordpress' wird erstellt...${NC}"
if sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE USER '${WP_DB_USER}'@'localhost' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO '${WP_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
then
    echo -e "${GREEN}MySQL-Benutzer 'wordpress' wurde erfolgreich erstellt!${NC}"
else
    error_message "MySQL-Benutzer 'wordpress'"
fi

# WordPress Installation mit manuell erstellter wp-config.php
echo -e "${YELLOW}WordPress wird in der Datenbank '$DB_NAME' installiert...${NC}"

# Manuell wp-config.php erstellen
sudo cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sudo sed -i "s/username_here/$WP_DB_USER/" $WP_DIR/wp-config.php
sudo sed -i "s/password_here/$WP_DB_PASSWORD/" $WP_DIR/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" $WP_DIR/wp-config.php

# WordPress-Datenbank erstellen
if sudo -u www-data wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_DIR" \
    --skip-email; then
    echo -e "${GREEN}WordPress wurde erfolgreich in der Datenbank '$DB_NAME' über die Befehlszeile installiert!${NC}"
else
    error_message "WordPress-Installation"
fi

# Neuen Benutzer für WordPress erstellen
echo -e "${YELLOW}Neuer Benutzer wird erstellt...${NC}"
if sudo -u www-data wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=administrator --path="$WP_DIR"; then
    echo -e "${GREEN}Neuer Benutzer wurde erfolgreich erstellt!${NC}"
else
    error_message "Neuer Benutzer für WordPress"
fi

echo -e "${GREEN}Die gesamte Installation wurde erfolgreich abgeschlossen!${NC}"
