#!/bin/bash
echo "Hallo Welt $1"
curl "http://google.com"
echo "Chromium wird installiert"
sudo snap install chromium chromium-ffmpeg
echo "Chromium wurde installiert"
echo "Visual Studio Code wird installiert"
wget -q -O "-" https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo apt-key add -
sudo apt-get install codium
echo "Visual Studio Code wurde installiert"
echo "Geany wird installiert"
sudo apt-get install geany
echo "Geany wurde installiert"
