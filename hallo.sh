#!/bin/bash
echo "Hallo Welt $1"
curl "http://google.com"
echo "Aktualisiere das System..."
sudo apt update && sudo apt upgrade -y
echo "Installiere Chromium..."
sudo apt install -y chromium-browser
echo "Installiere Visual Studio Code..."
sudo snap install --classic code
echo "Installiere Geany..."
sudo apt install -y geany
echo "Installation abgeschlossen."
