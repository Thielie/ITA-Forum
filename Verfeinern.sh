#!/bin/bash
# Farbdefinitionen
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funktion zum Benutzer fragen
ask_user() {
    read -p "Möchten Sie $1 installieren? (j/n): " choice
    echo $choice
}

# Funktion zum Benutzer und Passwort fragen
ask_user_and_password() {
    read -p "Wie soll der Benutzer heißen? " username
    read -p "Wie soll das Passwort lauten? " password
}

# Funktion für erfolgreiche Meldung
success_message() {
    echo -e "${GREEN}$1 wurde erfolgreich installiert!${NC}"
}

# Funktion für Fehlermeldung
error_message() {
    echo -e "${RED}Fehler bei der Installation von $1.${NC}"
}

# Update von Ubuntu
echo -e "${YELLOW}Aktualisiere das System...${NC}"
if sudo apt update && sudo apt upgrade -y; then
    success_message "Das System wurde erfolgreich aktualisiert"
else
    error_message "Das System konnte nicht aktualisiert werden"
fi

# Chromium Installation
if [ "$(ask_user 'Chromium')" == "j" ]; then
    echo "Installiere Chromium..."
    sudo apt update
    if sudo apt install -y chromium-browser; then
        success_message "Chromium"
    else
        error_message "Chromium"
    fi
else
    echo "Chromium wurde nicht installiert."
fi

# Visual Studio Code Installation
if [ "$(ask_user 'Visual Studio Code')" == "j" ]; then
    echo -e "${YELLOW}Installiere Visual Studio Code...${NC}"
    if sudo snap install --classic code; then
        success_message "Visual Studio Code"
    else
        error_message "Visual Studio Code"
    fi
else
    echo "Visual Studio Code wurde nicht installiert."
fi

# Geany Installation
if [ "$(ask_user 'Geany')" == "j" ]; then
    echo -e "${YELLOW}Installiere Geany...${NC}"
    if sudo apt install -y geany; then
        success_message "Geany"
    else
        error_message "Geany"
    fi
else
    echo "Geany wurde nicht installiert."
fi

# LAMP-Stack Installation
Apache Server installation
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

# PHP-Paket wird installiert
echo -e "${YELLOW}PHP-Paket wird installiert...${NC}"
sudo apt install -y php libapache2-mod-php php-mysql
echo -e "${GREEN}PHP-Paket wurde erfolgreich installiert!${NC}"
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
#sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
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
if [ "$(ask_user 'WordPress')" == "j" ]; then
    # Datenbankkonfiguration
    DB_NAME="wordpress"
    DB_HOST="localhost"

    # WordPress Konfiguration
    WP_DIR="/var/www/html/wp"
    WP_URL="http://localhost/wp"
    WP_TITLE="My WordPress Site"
    WP_ADMIN_USER="admin"
    WP_ADMIN_EMAIL="admin@example.com"

    ask_user_and_password
    WP_USER_PASSWORD_HASH=$(openssl passwd -1 $password)


# WordPress herunterladen und entpacken
echo -e "${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}"
wget -c https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz -C /tmp/
sudo mkdir -p $WP_DIR  # Erstellt den Ordner "wp"
sudo cp -R /tmp/wordpress/* $WP_DIR
sudo chown -R www-data:www-data $WP_DIR
sudo chmod -R 777 $WP_DIR
rm latest.tar.gz
 if [ $? -eq 0 ]; then
        success_message "WordPress (Herunterladen und Entpacken)"
    else
        error_message "WordPress (Herunterladen und Entpacken)"
    fi

# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

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
MYSQL_SCRIPT
 if [ $? -eq 0 ]; then
        success_message "MySQL-Datenbank"
    else
        error_message "MySQL-Datenbank"
    fi


# MySQL-Root-Passwort
MYSQL_ROOT_PASSWORD="root"

# MySQL-Benutzer für WordPress erstellen
WP_DB_USER="wordpress"
WP_DB_PASSWORD="wordpress"

echo -e "${YELLOW}MySQL-Benutzer 'wordpress' wird erstellt...${NC}"
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE USER '${WP_DB_USER}'@'localhost' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO '${WP_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
  if [ $? -eq 0 ]; then
        success_message "MySQL-Benutzer '$WP_DB_USER'"
    else
        error_message "MySQL-Benutzer '$WP_DB_USER'"
    fi
echo -e "${GREEN}MySQL-Benutzer 'wordpress' wurde erfolgreich erstellt!${NC}"

# WordPress Installation mit manuell erstellter wp-config.php
echo -e "${YELLOW}WordPress wird in der Datenbank '$DB_NAME' installiert...${NC}"

# Manuell wp-config.php erstellen
sudo cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sudo sed -i "s/username_here/$WP_DB_USER/" $WP_DIR/wp-config.php
sudo sed -i "s/password_here/$WP_DB_PASSWORD/" $WP_DIR/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" $WP_DIR/wp-config.php

 if [ $? -eq 0 ]; then
        success_message "WordPress (Installation)"
    else
        error_message "WordPress (Installation)"
    fi

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
sudo -u www-data wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=administrator --path="$WP_DIR"
echo -e "${GREEN}Neuer Benutzer wurde erfolgreich erstellt!${NC}"
 if [ $? -eq 0 ]; then
        success_message "Neuer Benutzer für WordPress"
    else
        error_message "Neuer Benutzer für WordPress"
    fi
else
    echo "WordPress wurde nicht installiert."
fi

echo -e "${GREEN}Die gesamte Installation wurde erfolgreich abgeschlossen!${NC}"
