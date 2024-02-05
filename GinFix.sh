#!/bin/bash

# Importiere Farbdefinitionen
source <(curl -s https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/color.sh)

# Importiere Funktionen
source <(curl -s https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/functions.sh)

# Importiere Konfigurationen
source <(curl -s https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/config.sh)

# Überprüfen, ob curl installiert ist
if ! command -v curl &> /dev/null; then
    echo -e "$(tput bold)$(tput setaf 1)Fehler: curl ist nicht installiert. Bitte installiere curl, um fortzufahren. Verwende dafür folgenden Befehl: sudo apt-get install curl. Gib danach folgenden Befehl ein: curl -L https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/GinFix.sh | bash$(tput sgr0)"
    exit 1
fi

# Überprüfen, ob das Skript lokal ausgeführt wird
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "$(tput bold)$(tput setaf 1)Fehler: Das Skript sollte nicht lokal, sondern mit curl ausgeführt werden. Verwende folgenden Befehl falls curl nicht installiert ist. sudo apt-get install curl. Verwende den folgenden Befehl: curl -L https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/GinFix.sh | bash.$(tput sgr0)"
    exit 1
fi

echo -e "$(tput bold)$(tput setaf 1)Bitte stelle sicher, dass du das Skript mit curl und folgendem Befehl ausführst: curl -L https://raw.githubusercontent.com/Thielie/ITA-Forum/MW3/GinFix.sh$(tput sgr0)"

# Benutzer nach Software-Installationen fragen
install_chromium=false
if get_user_choice "${FAT}${BLUE}Möchtest du Chromium installieren? (j/n):${NF} "; then
    install_chromium=true
fi

install_vscode=false
if get_user_choice "${FAT}${BLUE}Möchtest du Visual Studio Code installieren? (j/n):${NF} "; then
    install_vscode=true
fi

install_geany=false
if get_user_choice "${FAT}${BLUE}Möchtest du Geany installieren? (j/n):${NF} "; then
    install_geany=true
fi

# Update von Ubuntu
echo -e "${FAT}${YELLOW}Aktualisiere das System...${NC}${NF}"
if sudo apt update && sudo apt upgrade -y; 
then
    echo -e "${FAT}${GREEN}Das System wurde erfolgreich aktualisiert!${NC}${NF}"
else
    error_message "Systemaktualisierung"
fi

# Überprüfen, ob die Datei existiert
if [ -e "$FILE" ]; then
    # Datei existiert, lösche sie
    echo -e "${FAT}${YELLOW}Entferne die nosnap.pref Datei${NC}${NF}"
    if sudo rm "$FILE"; then
        echo -e "${FAT}${GREEN}nosnap.pref wurde erfolgreich entfernt${NC}${NF}"
    else
        echo -e "${FAT}${RED}Fehler beim Entfernen von nosnap.pref.${NC}${NF}"
    fi
else
    # Datei existiert nicht, überspringe den Schritt
    echo -e "${FAT}${YELLOW}Die nosnap.pref Datei existiert nicht. Schritt wird übersprungen.${NC}${NF}"
fi 

# Überprüfe, ob der Snap Store installiert ist
echo -e "${FAT}${YELLOW}Überprüfe, ob der Snap Store installiert ist...${NC}${NF}"
if snap list snap-store &> /dev/null; then
    echo -e "${FAT}${GREEN}Snap Store ist bereits installiert. Überspringe die Installation.${NC}${NF}"
else
    echo -e "${FAT}${RED}Snap Store nicht gefunden. Installiere den Snap Store...${NC}${NF}"

    # Installiere den Snap Daemon
    if sudo apt install snapd -y; then
        echo "${FAT}$(tput setaf 2)Snap Daemon erfolgreich installiert.${NF}"
    else
        echo -e "${FAT}${RED}Fehler beim Installieren des Snap Daemon!${NC}${NF}"
    fi

    # Starte den Snap Daemon
    if sudo systemctl start snapd; then
        echo "${FAT}$(tput setaf 2)Snap Daemon erfolgreich gestartet.${NF}"
    else
        echo -e "${FAT}${RED}Fehler beim Starten des Snap Daemon!${NC}${NF}"
    fi

    # Installiere den Snap Store
    if sudo snap install snap-store; then
        echo "${FAT}$(tput setaf 2)Snap Store erfolgreich installiert. 10 Sekunden Timer gestartet!${NF}"
    else
        echo -e "${FAT}${RED}Fehler beim Installieren des Snap Store!${NC}${NF}"
    fi
fi

# Installationen basierend auf Benutzerantworten
if $install_chromium; then
    echo -e "${FAT}${YELLOW}Installiere Chromium...${NC}${NF}"
    sudo apt install chromium-browser
    success_message "Chromium"
else
    echo -e "${FAT}${YELLOW}Chromium-Installation übersprungen.${NC}${NF}"
fi

if $install_vscode; then
    echo -e "${FAT}${YELLOW}Installiere Visual Studio Code...${NC}${NF}"
    sudo snap install --classic code
    success_message "Visual Studio Code"
else
    echo -e "${FAT}${YELLOW}Visual Studio Code-Installation übersprungen.${NC}${NF}"
fi

if $install_geany; then
    echo -e "${FAT}${YELLOW}Installiere Geany...${NC}${NF}"
    sudo apt install -y geany
    success_message "Geany"
else
    echo -e "${FAT}${YELLOW}Geany-Installation übersprungen.${NC}${NF}"
fi

# LAMP-Stack Installation
# Apache Server Installation
echo -e "${FAT}${YELLOW}Apache-Server wird installiert...${NC}${NF}"
if sudo apt install -y apache2; then
    success_message "Apache-Server"
else
    error_message "Apache-Server"
fi

# Aktivierung der Firewall und Zulassen von Apache-Verbindungen
sudo ufw enable
sudo ufw allow in "Apache"

# Verschieben der error.log-Datei in den html-Ordner
echo -e "${FAT}${YELLOW}Verschieben der error.log-Datei in den html-Ordner...${NC}${NF}"
if sudo mv /var/log/apache2/error.log /var/www/html/; then
    success_message "error.log-Datei"
else
    error_message "error.log-Datei"
fi

# Ändern der Berechtigungen, um die Datei nur lesbar zu machen
echo -e "${FAT}${YELLOW}Ändern der Berechtigungen für die error.log-Datei...${NC}${NF}"
if sudo chmod 444 /var/www/html/error.log; then
    echo -e "${FAT}${GREEN}Berechtigungen für die error.log-Datei erfolgreich gesetzt!${NC}${NF}"
else
    echo -e "${FAT}${RED}Fehler beim Ändern der Berechtigungen für die error.log-Datei${NC}${NF}"
fi

# Anzeige der verschobenen Datei
echo -e "${FAT}${GREEN}Die error.log-Datei wurde erfolgreich verschoben und ist jetzt nur lesbar.${NC}${NF}"

# MySQL-Server installation
if ! command -v mysql &> /dev/null; then
    echo -e "${FAT}${YELLOW}MySQL-Server wird installiert...${NC}${NF}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
    if sudo apt-get install -y mysql-server; then
        sudo systemctl start mysql
        sudo systemctl enable mysql
        echo -e "${FAT}${GREEN}MySQL-Server wurde erfolgreich installiert und gestartet!${NC}${NF}"
    else
        error_message "MySQL-Server"
    fi
fi

# PHP-Paket wird installiert
echo -e "${FAT}${YELLOW}PHP-Paket wird installiert...${NC}${NF}"
if sudo apt install -y php libapache2-mod-php php-mysql; then
    success_message "PHP-Paket"
else
    error_message "PHP-Paket"
fi

# Pfade konfigurieren und PHP-Fehlerprotokollierung anpassen
PHP_INI="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')/apache2/php.ini"
ERROR_LOG_PATH="/var/www/html/error.log"
sudo sed -i "s|;error_log = syslog|error_log = $ERROR_LOG_PATH|" "$PHP_INI"
sudo sed -i -e "s|display_errors = Off|display_errors = On|" "$PHP_INI"

# Apache Server neustarten
echo -e "${FAT}${YELLOW}Apache-Server wird neugestartet...${NC}${NF}"
if sudo systemctl restart apache2; then
    success_message "Apache-Server Neustart"
else
    error_message "Fehler beim Neustart des Apache-Servers"
fi

echo -e "${FAT}${YELLOW}PHP-Paket wird nach der Version überprüft...${NC}${NF}"
if php -v; then
    echo -e "${FAT}${GREEN}PHP-Paket wurde erfolgreich nach der Version überprüft!${NC}${NF}"
else
    echo -e "${FAT}${RED}Überprüfung der PHP-Version fehlgeschlagen${NC}${NF}"
fi

# Erlaube MySQL-Root-Anmeldung über Socket-Mechanismus
echo -e "${FAT}${YELLOW}Erlaube MySQL-Root-Anmeldung über Socket...${NC}${NF}"
if sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
   FLUSH PRIVILEGES;
MYSQL_SCRIPT
then
    echo -e "${FAT}${GREEN}MySQL-Root-Anmeldung über Socket wurde erfolgreich aktiviert!${NC}${NF}"
else
    echo -e "${FAT}${RED}Fehler beim Aktivieren der MySQL-Root-Anmeldung über Socket!${NC}${NF}"
fi


echo -e "${FAT}${YELLOW}MySQL-Benutzer wird für phpMyAdmin konfiguriert...${NC}${NF}"
if sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT
then
    echo -e "${FAT}${GREEN}MySQL-Benutzer wurde erfolgreich für phpMyAdmin konfiguriert!${NC}${NF}"
else
    error_message "MySQL-Benutzer für phpMyAdmin"
fi

# Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration
echo -e "${FAT}${YELLOW}Installiere phpMyAdmin mit Apache2 und überspringe die Paketkonfiguration...${NC}${NF}"
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
echo -e "${FAT}${YELLOW}PhpMyAdmin Konfiguration wird für Apache erstellt...${NC}${NF}"
sudo ln -s /etc/phpmyadmin/apache.conf $PHPMYADMIN_CONF_FILE
sudo a2enconf phpmyadmin
if sudo systemctl reload apache2.service; then
    echo -e "${FAT}${GREEN}PhpMyAdmin Konfiguration wurde erfolgreich für Apache erstellt!${NC}${NF}"
else
    error_message "Apache-Server-Neustart nach phpMyAdmin-Konfiguration"
fi

# WordPress herunterladen und entpacken
echo -e "${FAT}${YELLOW}WordPress wird heruntergeladen und entpackt...${NC}$(tput sgr0)"
if wget -c https://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz -C /tmp/ && sudo mkdir -p $WP_DIR && sudo cp -R /tmp/wordpress/* $WP_DIR && sudo chown -R www-data:www-data $WP_DIR && sudo chmod -R 777 $WP_DIR && rm latest.tar.gz; then
    echo -e "$(tput bold)${GREEN}WordPress wurde erfolgreich heruntergeladen und entpackt!${NC}${NF})"
else
    error_message "WordPress (Herunterladen und Entpacken)"
fi

sudo chmod -R 777 $html #Hier werden volle zugriffsrechte auf den Ordner gewährt



# Apache-Konfiguration für mod_rewrite aktivieren
echo -e "${FAT}${YELLOW}Aktiviere mod_rewrite in Apache...${NC}${NF}"
if sudo a2enmod rewrite && sudo systemctl restart apache2; then
    echo -e "${FAT}${GREEN}mod_rewrite wurde erfolgreich aktiviert und Apache wurde neu gestartet!${NC}${NF}"
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
echo -e "${FAT}${YELLOW}MySQL-Datenbank wird erstellt...${NC}${NF}"
if mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
MYSQL_SCRIPT
then
    echo -e "${FAT}${GREEN}MySQL-Datenbank wurde erfolgreich erstellt!${NC}${NF}"
else
    error_message "MySQL-Datenbank"
fi


echo -e "${FAT}${YELLOW}MySQL-Benutzer 'wordpress' wird erstellt...${NC}${NF}"
if sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE USER '${WP_DB_USER}'@'localhost' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO '${WP_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
then
    echo -e "${FAT}${GREEN}MySQL-Benutzer 'wordpress' wurde erfolgreich erstellt!${NC}${NF}"
else
    error_message "MySQL-Benutzer 'wordpress'"
fi

# Manuell wp-config.php erstellen
sudo cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sudo sed -i "s/username_here/$WP_DB_USER/" $WP_DIR/wp-config.php
sudo sed -i "s/password_here/$WP_DB_PASSWORD/" $WP_DIR/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" $WP_DIR/wp-config.php

# WordPress Installation
echo -e "${FAT}${YELLOW}WordPress wird in der Datenbank '$DB_NAME' installiert...${NC}${NF}"

# WordPress-Datenbank erstellen
if sudo -u www-data wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_DIR" \
    --skip-email; then
    echo -e "${FAT}${GREEN}WordPress wurde erfolgreich in der Datenbank '$DB_NAME' über die Befehlszeile installiert!${NC}${NF}"
else
    error_message "WordPress-Installation"
fi

# Neuen Benutzer für WordPress erstellen
echo -e "${FAT}${YELLOW}Neuer Benutzer wird erstellt...${NC}"
if sudo -u www-data wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=administrator --path="$WP_DIR"; then
    echo -e "${FAT}${GREEN}Neuer Benutzer wurde erfolgreich erstellt!${NC}${NF}"
else
    error_message "Neuer Benutzer für WordPress"
fi

# Benutzer in die Gruppe www-data hinzufügen
echo -e "${FAT}${YELLOW}Füge den eingeloggten Benutzer zur Gruppe www-data hinzu...${NC}${NF}"
if sudo usermod -aG www-data $(whoami); then
    echo -e "${FAT}${GREEN}Der Benutzer wurde erfolgreich zur Gruppe www-data hinzugefügt!${NC}${NF}"
else
    echo -e "${FAT}${RED}Fehler beim Hinzufügen des Benutzers zur Gruppe www-data.${NC}${NF}"
fi

echo -e "${FAT}${YELLOW}Berechtigungen für das HTML-Verzeichnis aktualisieren...${NC}${NF}"

# Ändere den Besitzer des HTML-Verzeichnisses zu www-data
sudo chown :www-data $html

# Füge den Benutzer zur www-data Gruppe hinzu
if sudo usermod -aG www-data $(whoami); then
    echo -e "${FAT}${GREEN}Benutzer erfolgreich zur www-data Gruppe hinzugefügt!${NC}${NF}"
else
    echo -e "${FAT}${RED}Fehler beim Hinzufügen des Benutzers zur www-data Gruppe!${NC}${NF}"
fi

# Setze Lese-, Schreib-, Ausführungs- und Erstellungsrechte für den Besitzer und die Gruppe www-data, Sticky Bit hinzufügen
if sudo chmod 1770 $html; then
    echo -e "${FAT}${GREEN}Berechtigungen erfolgreich aktualisiert!${NC}${NF}"
else
    echo -e "${FAT}${RED}Fehler beim Aktualisieren der Berechtigungen!${NC}${NF}"
fi

sudo chmod 444 /var/www/html/error.log

#Link zum html Ordner auf den Desktop
ln -s /var/www/html $HOME/Schreibtisch/html

echo -e "${FAT}${GREEN}Die gesamte Installation wurde erfolgreich abgeschlossen!${NC}${NF}"

#Neustart nach Abschluss
blink_text "${FAT}Das System wird in 10 Sekunden neu gestartet.${NF}"

sleep 10

sudo reboot
