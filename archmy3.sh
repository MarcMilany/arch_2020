#!/bin/bash
# ============================================================================
### Help and usage (--help or -h) (Справка)
_help() {
    echo -e "${BLUE}
Installation guide - Arch Wiki

    ${BOLD}Options${NC}
        -h, --help          show this help message

${BOLD}For more information, see the wiki: \
${GREY}<https://wiki.archlinux.org/index.php/Installation_guide>${NC}"
}

### SHARED VARIABLES AND FUNCTIONS (ОБЩИЕ ПЕРЕМЕННЫЕ И ФУНКЦИИ)
### Shell color codes (Цветовые коды оболочки)
RED="\e[1;31m"; GREEN="\e[1;32m"; YELLOW="\e[1;33m"; GREY="\e[3;93m"
BLUE="\e[1;34m"; CYAN="\e[1;36m"; BOLD="\e[1;37m"; NC="\e[0m"

### Display some notes (Дисплей некоторые заметки)
_note() {
    echo -e "${RED}\nNote: ${BLUE}${1}${NC}"
}

### Display install steps (Отображение шагов установки)
_info() {
    echo -e "${YELLOW}\n==> ${CYAN}${1}...${NC}"; sleep 1
}

### Ask some information (Спросите немного информации)
_prompt() {
    LENTH=${*}; COUNT=${#LENTH}
    echo -ne "\n${YELLOW}==> ${GREEN}${1} ${RED}${2}"
    echo -ne "${YELLOW}\n==> "
    for (( CHAR=1; CHAR<=COUNT; CHAR++ )); do echo -ne "-"; done
    echo -ne "\n==> ${NC}"
}

### Ask confirmation (Yes/No) (Запросите подтверждение (да / нет))
_confirm() {
    unset CONFIRM; COUNT=$(( ${#1} + 6 ))
    until [[ ${CONFIRM} =~ ^(y|n|Y|N|yes|no|Yes|No|YES|NO)$ ]]; do
        echo -ne "${YELLOW}\n==> ${GREEN}${1} ${RED}[y/n]${YELLOW}\n==> "
        for (( CHAR=1; CHAR<=COUNT; CHAR++ )); do echo -ne "-"; done
        echo -ne "\n==> ${NC}"
        read -r CONFIRM
    done
}

### Select an option (Выбрать параметр)
_select() {
    COUNT=0
    echo -ne "${YELLOW}\n==> "
    for ENTRY in "${@}"; do
        echo -ne "${RED}[$(( ++COUNT ))] ${GREEN}${ENTRY} ${NC}"
    done
    LENTH=${*}; NUMBER=$(( ${#*} * 4 ))
    COUNT=$(( ${#LENTH} + NUMBER + 1 ))
    echo -ne "${YELLOW}\n==> "
    for (( CHAR=1; CHAR<=COUNT; CHAR++ )); do echo -ne "-"; done
    echo -ne "\n==> ${NC}"
}

### Download show progress bar only (Скачать показывать только индикатор выполнения)
_wget() {
    wget "${1}" --quiet --show-progress
}

# ============================================================================

echo 'Для проверки интернета можно пропинговать какой-либо сервис'
# To check the Internet, you can ping a service
ping -c2 archlinux.org


echo 'Создадим папку (downloads), и переходим в созданную папку'
# Create a folder (downloads), and go to the created folder
#rm -rf ~/.config/xfce4/*
mkdir ~/downloads
cd ~/downloads

echo -e "${BLUE}
'Установка AUR (yay)'
${NC}"
sudo pacman -Syu
wget git.io/yay-install.sh && sh yay-install.sh --noconfirm

echo 'Обновим всю систему включая AUR пакеты'
# Update the entire system including AUR packages
yay -Syy
yay -Syu

echo 'Ставим Bluetooth и Поддержка звука'
# Setting Bluetooth and Sound support
pacman -S bluez bluez-libs bluez-cups bluez-utils --noconfirm
pacman -S alsa-utils alsa-plugins alsa-firmware alsa-lib alsa-utils --noconfirm 
pacman -S pulseaudio pulseaudio-alsa pavucontrol pulseaudio-zeroconf pulseaudio-bluetooth xfce4-pulseaudio-plugin --noconfirm

echo 'Ставим Архиваторы "Компрессионные Инструменты"'
# Putting Archivers "Compression Tools
pacman -S zip unzip unrar p7zip zlib zziplib --noconfirm

echo 'Ставим дополнения к Архиваторам'
# Adding extensions to Archivers
pacman -S unace sharutils uudeview arj cabextract --noconfirm

echo 'Ставим Драйвера принтера (Поддержка печати)'
# Putting the printer Drivers (Print support)
sudo pacman -S cups ghostscript cups-pdf --noconfirm

echo 'Установка базовых программ и пакетов'
# # Installing basic programs and packages
sudo pacman -S aspell-ru arch-install-scripts bash-completion dosfstools f2fs-tools sane gvfs htop iftop inxi iotop nmap ntfs-3g ntp ncdu hydra isomd5sum python-isomd5sum translate-shell mc pv sox youtube-dl speedtest-cli python-pip pwgen scrot git curl xsel --noconfirm 

echo 'Установка терминальных утилит для вывода информации о системе'
# Installing terminal utilities for displaying system information
sudo pacman -S screenfetch archey3 neofetch --noconfirm  

echo 'Установка Мультимедиа кодеков (multimedia codecs), и утилит'
# Installing Multimedia codecs and utilities
sudo pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly libdvdcss libdvdread libdvdnav dvd+rw-tools dvdauthor dvgrab cdrdao gst-libav gst-libav gpac --noconfirm

echo 'Установка Мультимедиа утилит'
# Installing Multimedia utilities
sudo pacman -S audacity audacious audacious-plugins smplayer smplayer-skins smplayer-themes smtube deadbeef easytag subdownloader mediainfo-gui vlc --noconfirm

echo 'Установка Текстовые редакторы и утилиты разработки'
# Installation Text editors and development tools
sudo pacman -S gedit gedit-plugins geany geany-plugins --noconfirm

echo 'Управления электронной почтой, новостными лентами, чатом и группам'
# Manage email, news feeds, chat, and groups
sudo pacman -S thunderbird thunderbird-i18n-ru pidgin pidgin-hotkeys --noconfirm

echo 'Установка Браузеров и медиа-плагинов'
# Installing Browsers and media plugins
sudo pacman -S firefox firefox-i18n-ru firefox-spell-ru flashplugin pepper-flash --noconfirm

echo 'Установка Брандмауэра UFW и Антивирусного пакета ClamAV (GUI)(GTK+)'
# Installing the UFW Firewall and clamav Antivirus package (GUI) (GTK+)
echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo 'Установить UFW (Несложный Брандмауэр) (GTK)?'
# Install UFW (Uncomplicated Firewall) (GTK)?
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S ufw gufw --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить Clam AntiVirus (GTK)?'
# Install Clam AntiVirus (GTK)?
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S clamav clamtk --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка Torrent клиентов - Transmission, qBittorrent, Deluge (GTK)(Qt)(GTK+)'
# Installing Torrent clients - Transmission, qBittorrent, Deluge (GTK) (Qt) (GTK+)
echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo 'Установить Transmission, qBittorrent, Deluge?'
# Install Transmission, qBittorrent, Deluge?
read -p "1 - Transmission, 2 - qBittorrent, 3 - Deluge, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S transmission-gtk transmission-cli --noconfirm
elif [[ $prog_set == 2 ]]; then
sudo pacman -S qbittorrent --noconfirm
elif [[ $prog_set == 3 ]]; then
sudo pacman -S deluge --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка Офиса (LibreOffice-still, или LibreOffice-fresh)'
# Office installation (LibreOffice-still, or LibreOffice-fresh)
echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo 'Установить LibreOffice-still, LibreOffice-fresh?'
# Install the LibreOffice-still and LibreOffice-fresh?
read -p "1 - LibreOffice-still, 2 - LibreOffice-fresh, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S libreoffice-still libreoffice-still-ru --noconfirm
elif [[ $prog_set == 2 ]]; then
sudo pacman -S libreoffice libreoffice-fresh-ru --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить рекомендованные программы?'
# Install the recommended programs
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S bleachbit gparted grub-customizer conky conky-manager dconf-editor doublecmd-gtk2 gnome-system-monitor obs-studio openshot frei0r-plugins lib32-simplescreenrecorder simplescreenrecorder redshift veracrypt onboard clonezilla moc filezilla gnome-calculator nomacs osmo synapse telegram-desktop plank psensor keepass copyq variety grsync numlockx modem-manager-gui uget xarchiver-gtk2 rofi gsmartcontrol testdisk glances tlp tlp-rdw file-roller meld cmake xterm --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Утилиты для форматируем флеш-накопителя с файловой системой exFAT в Linux'
# Utilities for formatting a flash drive with the exFAT file system in Linux
sudo pacman -S exfat-utils fuse-exfat --noconfirm 

echo 'Установка "Pacman gui","Octopi" (AUR)(GTK)(QT)'
# Installing "Pacman gui", "Octopi" (AUR)(GTK) (QT)
echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo 'Установить "pamac-aur", "octopi"?'
# Install "pacman-aur", "octopi"?
read -p "1 - Pacmanc-aur, 2 - Octopi, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S pamac-aur --noconfirm
elif [[ $prog_set == 2 ]]; then
yay -S octopi --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Обновим информацию о шрифтах'
# Update information about fonts
sudo fc-cache -f -v

echo 'Применяем настройки TLP (управления питанием) в зависимости от источника питания (батарея или от сети)'
# Apply TLP (power management) settings depending on the power source (battery or mains)
sudo tlp start

echo 'Включаем сетевой экран'
# Enabling the network screen
sudo ufw enable

echo 'Добавляем в автозагрузку сетевой экран'
# Adding the network screen to auto-upload
sudo systemctl enable ufw

echo 'Проверим статус запуска сетевой экран UFW'
# Check the startup status of the UFW network screen
sudo ufw status

echo 'Создать резервную копию (дубликат) файла grub.cfg'
# Create a backup (duplicate) of the grub.cfg file
cp /boot/grub/grub.cfg grub.cfg.backup

# echo 'Добавить репозиторий archlinuxfr и вписать тему для Color.'
# echo '[multilib]' >> /etc/pacman.conf
# echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
# sed -i 's/#Color/Color/' /etc/pacman.conf
# echo 'ILoveCandy' >> /etc/pacman.conf
# [archlinuxfr]
# SigLevel = Never
# Server = http://repo.archlinux.fr/$arch
# pacman -Syy

# echo 'Добавить оскорбительное выражение после неверного ввода пароля в терминале'
# Откройте на редактирование файл sudoers следующей командой в терминале:
# sudo nano /etc/sudoers
# Когда откроется файл sudoers на редактирование, стрелками вниз/вверх переместитесь до строки:
## Defaults env_keep += "QTDIR KDEDIR"
# и ниже скопипастите следующую стоку:
# Defaults  badpass_message="Ты не администратор, придурок."

echo 'Удаление созданной папки (downloads), и скрипта установки программ (arch3my)'
# Deleting the created folder (downloads) and the program installation script (arch3my)
sudo rm -R ~/downloads/
sudo rm -rf ~/arch3my

echo 'Установка завершена!'
# The installation is now complete!

echo 'Желательно перезагрузить систему для применения изменений'
# It is advisable to restart the system to apply the changes

echo 'Скачать и произвести запуск скрипта (archmy4)?'
# Download and run the script (archmy4)?
# echo 'wget git.io/archmy4 && sh archmy4'
echo 'wget git.io/archmy4'
# Команды по установке :
# wget git.io/archmy4 
# wget git.io/archmy4 && sh archmy4 --noconfirm




