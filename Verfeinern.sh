#!/bin/bash
# Farbdefinitionen
FAT='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[34m'
NC='\033[0m' # No Color

# Funktion für erfolgreiche Meldung
success_message() {
    echo -e "${FAT}${GREEN}$1 wurde erfolgreich installiert!${NC}${FAT}"
}

# Funktion für Fehlermeldung
error_message() {
    echo -e "${FAT}${RED}Fehler bei der Installation von $1.${NC}${FAT}"
}

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# Update von Ubuntu
#echo -e "${FAT}${YELLOW}Aktualisiere das System...${NC}"#
#if sudo apt update && sudo apt upgrade -y; 
#then
#    echo -e "${FAT}${GREEN}Das System wurde erfolgreich aktualisiert!${NC}"
#else
#    error_message "Systemaktualisierung"
#fi



# Benutzerabfrage für Chromium-Installation
read -p "${FAT}${BLUE}Möchten du Chromium installieren? (Ja/Nein)${NC}${FAT}: " user_choice < /dev/tty
if [[ $user_choice =~ ^[Jj] ]]; then
    echo -e "${FAT}${YELLOW}Installiere Chromium...${NC}${FAT}"
    if sudo apt install chromium-browser; then
        success_message "Chromium"
    else
        error_message "Chromium"
    fi
else
    echo "Chromium-Installation abgebrochen."
fi


# Visual Studio Code Installation
read -p "${FAT}${BLUE}Möchtest du Visual Studio Code installieren? (Ja/Nein)${NC}${FAT}: " user_choice < /dev/tty
if [[ $user_choice =~ ^[Jj] ]]; then
    echo -e "${FAT}${YELLOW}Installiere Visual Studio Code...${NC}${FAT}"
    if sudo snap install --classic code; then
       success_message "Visual Studio Code"
else
    error_message "Visual Studio Code"
    fi
else
    echo "Visual Studio Code-Installation abgebrochen."
fi

# Geany Installation
read -p "${FAT}${BLUE}Möchtest du Geany installieren? (Ja/Nein)${NC}${FAT}: " user_choice < /dev/tty
if [[ $user_choice =~ ^[Jj] ]]; then
    echo -e "${FAT}${YELLOW}Installiere Geany...${NC}${FAT}"
    if sudo apt install -y geany; then
        success_message "Geany"
    else
        error_message "Geany"
    fi
else
    echo "Geany-Installation abgebrochen."
fi

# LAMP-Stack Installation
# Apache Server installation
echo -e "${FAT}${YELLOW}Apache-Server wird installiert...${NC}${FAT}"
if sudo apt install -y apache2; then
    success_message "Apache-Server"
else
    error_message "Apache-Server"
fi
sudo ufw enable
sudo ufw allow in "Apache"

# MySQL-Server installation
if ! command -v mysql &> /dev/null; then
    echo -e "${FAT}${YELLOW}MySQL-Server wird installiert...${NC}${FAT}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
    if sudo apt-get install -y mysql-server; then
        sudo systemctl start mysql
        sudo systemctl enable mysql
        echo -e "${FAT}${GREEN}MySQL-Server wurde erfolgreich installiert und gestartet!${NC}${FAT}"
    else
        error_message "MySQL-Server"
    fi
fi

# PHP-Paket wird installiert
echo -e "${FAT}${YELLOW}PHP-Paket wird installiert...${NC}${FAT}"
if sudo apt install -y php libapache2-mod-php php-mysql; then
    success_message "PHP-Paket"
else
    error_message "PHP-Paket"
fi
echo -e "${FAT}${YELLOW}PHP-Paket wird nach der Version überprüft...${NC}${FAT}"
php -v
echo -e "${FAT}${GREEN}PHP-Paket wurde erfolgreich nach der Version überprüft!${NC}${FAT}"

# Erlaube MySQL-Root-Anmeldung über Socket-Mechanismus
echo -e "${FAT}${YELLOW}Erlaube MySQL-Root-Anmeldung über Socket...${NC}${FAT}"
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo -e "${FAT}${GREEN}MySQL-Root-Anmeldung über Socket wurde erfolgreich aktiviert!${NC}${FAT}"

MYSQL_ROOT_PASSWORD="root"
DB_USER="cit"
DB_PASSWORD="cit"

echo -e "${FAT}${YELLOW}MySQL-Benutzer wird für phpMyAdmin konfiguriert...${NC}${FAT}"
if sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT
then
    echo -e "${FAT}${GREEN}MySQL-Benutzer wurde erfolgreich für phpMyAdmin konfiguriert!${NC}${FAT}"
else
    error_message "MySQL-Benutzer für phpMyAdmin"
fi

# Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration
echo -e "${FAT}${YELLOW}Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration...${NC}${FAT}"
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DB_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
if sudo apt-get update && sudo apt-get install -y phpmyadmin; then
    success_message "phpmyadmin"
else
    error_message "phpMyAdmin"
fi

# PhpMyAdmin-Konfiguration für Apache erstellen
PHPMYADMIN_CONF_FILE="/etc/apache2/conf-available/phpmyadmin.conf"
echo -e "${FAT}${YELLOW}PhpMyAdmin Konfiguration wird für Apache erstellt...${NC}${FAT}"
sudo ln -s /etc/phpmyadmin/apache.conf $PHPMYADMIN_CONF_FILE
sudo a2enconf phpmyadmin
if sudo systemctl reload apache2.service; then
    echo -e "${FAT}${GREEN}PhpMyAdmin Konfiguration wurde erfolgreich für Apache erstellt!${NC}${FAT}"
else
    error_message "Apache-Server-Neustart nach phpMyAdmin-Konfiguration"
fi

# WordPress Installation
# Datenbankkonfiguration
DB_NAME="wordpress"
DB_HOST="localhost"

# WordPress Konfiguration
html="/var/www/html"
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
echo -e "${FAT}${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}${FAT}"
if wget -c https://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz -C /tmp/ && sudo mkdir -p $WP_DIR && sudo cp -R /tmp/wordpress/* $WP_DIR && sudo chown -R www-data:www-data $WP_DIR && sudo chmod -R 777 $WP_DIR && rm latest.tar.gz; then
    echo -e "${FAT}${GREEN}WordPress wurde erfolgreich heruntergeladen und entpackt!${NC}${FAT}"
else
    error_message "WordPress (Herunterladen und Entpacken)"
fi

sudo chmod -R 777 $html #Hier werden volle zugriffsrechte auf den Ordner gewährt

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# Apache-Konfiguration für mod_rewrite aktivieren
echo -e "${FAT}${YELLOW}Aktiviere mod_rewrite in Apache...${NC}${FAT}"
if sudo a2enmod rewrite && sudo systemctl restart apache2; then
    echo -e "${FAT}${GREEN}mod_rewrite wurde erfolgreich aktiviert und Apache wurde neu gestartet!${NC}${FAT}"
else
    error_message "mod_rewrite-Aktivierung und Apache-Neustart"
fi

# WP-CLI installieren
echo "Installing WP-CLI..."
if curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp; then
    success_message "WP-CLI"
else
    error_message "WP-CLI"
fi

# MySQL-Datenbank erstellen
echo -e "${FAT}${YELLOW}MySQL-Datenbank wird erstellt...${NC}${FAT}"
if mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
MYSQL_SCRIPT
then
    echo -e "${FAT}${GREEN}MySQL-Datenbank wurde erfolgreich erstellt!${NC}${FAT}"
else
    error_message "MySQL-Datenbank"
fi

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# MySQL-Benutzer für WordPress erstellen
WP_DB_USER="wordpress"
WP_DB_PASSWORD="wordpress"

echo -e "${FAT}${YELLOW}MySQL-Benutzer 'wordpress' wird erstellt...${NC}${FAT}"
if sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE USER '${WP_DB_USER}'@'localhost' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO '${WP_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
then
    echo -e "${FAT}${GREEN}MySQL-Benutzer 'wordpress' wurde erfolgreich erstellt!${NC}${FAT}"
else
    error_message "MySQL-Benutzer 'wordpress'"
fi

# WordPress Installation mit manuell erstellter wp-config.php
echo -e "${FAT}${YELLOW}WordPress wird in der Datenbank '$DB_NAME' installiert...${NC}${FAT}"

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
    echo -e "${FAT}${GREEN}WordPress wurde erfolgreich in der Datenbank '$DB_NAME' über die Befehlszeile installiert!${NC}${FAT}"
else
    error_message "WordPress-Installation"
fi

# Neuen Benutzer für WordPress erstellen
echo -e "${FAT}${YELLOW}Neuer Benutzer wird erstellt...${NC}"
if sudo -u www-data wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=administrator --path="$WP_DIR"; then
    echo -e "${FAT}${GREEN}Neuer Benutzer wurde erfolgreich erstellt!${NC}${FAT}"
else
    error_message "Neuer Benutzer für WordPress"
fi

echo -e "${FAT}${GREEN}Die gesamte Installation wurde erfolgreich abgeschlossen!${NC}${FAT}"
