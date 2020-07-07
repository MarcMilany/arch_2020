#!/bin/bash
# ============================================================================
### old_vars.log
#set > old_vars.log

#APPNAME="arch_fast_install"
#VERSION="v1.6 LegasyBIOS"
#BRANCH="master"
#AUTHOR="ordanax"
#LICENSE="GNU General Public License 3.0"

# ============================================================================
### Warning (Предупреждение)
_warning_banner() {
    echo -e "${YELLOW}
   ====================== ♥ Предупреждение ======================
${NC}
Цель сценария (скрипта) - это установка первоначально необходимого софта (пакетов) и запуск необходимых служб. 
Смысл в том, что все изменения вы делаете предварительно в самом скрипте и получаете возможность быстрой установки утилит (пакетов), которые Вы решили установить (при условии, что Вы его изменили под себя, в противном случае скрипт установит софт (пакеты) прописанный изначально.
В процессе работы сценария (скрипта) Вам будут задаваться вопросы на установку той, или иной утилиты (пакета) - будьте внимательными! Не переживайте в скрипте только две утилиты (пакета) устанавливаются из 'AUR'. Это 'Pacman gui' или 'Octopi', в зависимости от вашего выбора. Сам же 'AUR'-'yay' с помощью скрипта созданного (autor): Alex Creio https://cvc.hashbase.io/ - скачивается с сайта 'Arch Linux' (https://aur.archlinux.org/packages/yay-git/), собирается и устанавливается. Остальной софт (пакеты) скачивается и устанавливается из 'Официальных репозиториев Arch Linux'. Если Вы сомневаетесь в своих действиях, скриптом можно пользоваться как шпаргалкой, открыв его в текстовом редакторе, копируя команды по установке необходимых пакетов, и запуска необходимых служб. В любой ситуации выбор всегда за вами. Вы либо гуляете под дождем, либо просто под ним мокнете.${RED}

  ***************************** ВНИМАНИЕ! ***************************** 
${NC}
Автор не несёт ответственности за любое нанесение вреда при использовании скрипта. 
Вы используйте его на свой страх и риск, или изменяйте под свои личные нужды. 
В данный момент сценарий (скрипта) находится в процессе доработки по прописанию устанавливаемого софта (пакетов), и небольшой корректировке (Воен. Внесение поправок в наводку орудий по результатам наблюдений с наблюдательных пунктов).
${BLUE}===> ******************************************************* ${NC}"
}

# ============================================================================

### Help and usage (--help or -h) (Справка)
_help() {
    echo -e "${BLUE}
Installation guide - Arch Wiki

    ${BOLD}Options${NC}
        -h, --help          show this help message
        -l, --lang          set installer language
        -k, --keyboard      set keyboard layout

    ${BOLD}Language${NC}
        -l, --lang          english
                            russian

    ${BOLD}Keyboard${NC}
        -k, --keyboard      keyboard layout
                            (run loadkeys on start)
                            (e.q., --keyboard fr)

${BOLD}For more information, see the wiki: \
${GREY}<https://wiki.archlinux.org/index.php/Installation_guide>${NC}"
}

### Installer default language (Язык установки по умолчанию)
#ARCHMY1_LANG="russian"

### SHARED VARIABLES AND FUNCTIONS (ОБЩИЕ ПЕРЕМЕННЫЕ И ФУНКЦИИ)
### Shell color codes (Цветовые коды оболочки)
RED="\e[1;31m"; GREEN="\e[1;32m"; YELLOW="\e[1;33m"; GREY="\e[3;93m"
BLUE="\e[1;34m"; CYAN="\e[1;36m"; BOLD="\e[1;37m"; MAGENTA="\e[1;35m"; NC="\e[0m"

# Вот список цветов, которые можно применять для подсветки синтаксиса в bash:
# BLACK='\e[0;30m' GREEN='\e[0;32m' BLUE='\e[0;34m'    CYAN='\e[0;36m'
# RED='\e[0;31m'   BROWN='\e[0;33m' MAGENTA='\e[0;35m' GRAY='\e[0;37m'
# DEF='\e[0;39m'   'LRED='\e[1;31m    YELLOW='\e[1;33m' LMAGENTA='\e[1;35m' WHITE='\e[1;37m'
# DGRAY='\e[1;30m'  LGREEN='\e[1;32m' LBLUE='\e[1;34m'  LCYAN='\e[1;36m'    NC='\e[0m' # No Color
# Индивидуальные настройки подсветки синтаксиса для каждого пользователя можно настраивать в конфигурационном файле /home/$USER/.bashrc


# Checking personal setting (Проверяйте ваши персональные настройки)
### Display user entries (Отображение пользовательских записей ) 
USER_ENTRIES=(USER_LANG TIMEZONE HOST_NAME USER_NAME LINUX_FW KERNEL \
DESKTOP DISPLAY_MAN GREETER AUR_HELPER POWER GPU_DRIVER HARD_VIDEO)

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

### Execute action in chrooted environment (Выполнение действия в хромированной среде)
_chroot() {
    arch-chroot /mnt <<EOF "${1}"
EOF
}

### Check command status and exit on error (Проверьте состояние команды и завершите работу с ошибкой)
_check() {
    "${@}"
    local STATUS=$?
    if [[ ${STATUS} -ne 0 ]]; then _error "${@}"; fi
    return "${STATUS}"
}

### Display error, cleanup and kill (Ошибка отображения, очистка и убийство)
_error() {
    echo -e "\n${RED}Error: ${YELLOW}${*}${NC}"
    _note "${MSG_ERROR}"
    sleep 1; _cleanup; _exit_msg; kill -9 $$
}

### Cleanup on keyboard interrupt (Очистка при прерывании работы клавиатуры)
#trap '_error ${MSG_KEYBOARD}' 1 2 3 6

### Delete sources and umount partitions (Удаление источников и размонтирование разделов)
_cleanup() {
    _info "${MSG_CLEANUP}"
    SRC=(base bootloader desktop display firmware gpu_driver mirrorlist \
mounting partitioning user desktop_apps display_apps gpu_apps system_apps \
00-keyboard.conf language loader.conf timezone xinitrc xprofile \
background.png Grub2-themes archboot* *.log english french german)

    # Sources (rm) (Источники (rm))
    for SOURCE in "${SRC[@]}"; do
        if [[ -f "${SOURCE}" ]]; then rm -rfv "${SOURCE}"; fi
    done

    # Swap (swapoff) Своп (swapoff)
    CHECK_SWAP=$( swapon -s ); if [[ ${CHECK_SWAP} ]]; then swapoff -av; fi

    # Partitions (umount) Разделы (umount)
    if mount | grep /mnt; then umount -Rfv /mnt; fi
}

### Reboot with 10s timeout (Перезагрузка с таймаутом 10 секунд)
_reboot() {
    for (( SECOND=10; SECOND>=1; SECOND-- )); do
        echo -ne "\r\033[K${GREEN}${MSG_REBOOT} ${SECOND}s...${NC}"
        sleep 1
    done
    reboot; exit 0
}

### Say goodbye (Распрощаться)
_exit_msg() {
    echo -e "\n${GREEN}<<< ${BLUE}${APPNAME} ${VERSION} ${BOLD}by \
${AUTHOR} ${RED}under ${LICENSE} ${GREEN}>>>${NC}"""
}

# ============================================================================

### Display banner (Дисплей баннер)
_warning_banner

sleep 4
echo -e "${GREEN}=> ${NC}Для проверки интернета можно пропинговать какой-либо сервис"
#echo 'Для проверки интернета можно пропинговать какой-либо сервис'
# To check the Internet, you can ping a service
ping -c2 archlinux.org

echo -e "${YELLOW}==> ${NC}Создадим папку (downloads), и переходим в созданную папку"
#echo 'Создадим папку (downloads), и переходим в созданную папку'
# Create a folder (downloads), and go to the created folder
#rm -rf ~/.config/xfce4/*
mkdir ~/downloads
cd ~/downloads

echo -e "${GREEN}==> ${NC}${BLUE}'Установка AUR Helper (yay)'${NC}"
#echo 'Установка AUR Helper (yay)'
# Installing AUR Helper (yay)
sudo pacman -Syu
wget git.io/yay-install.sh && sh yay-install.sh --noconfirm
#sudo pacman -S --noconfirm --needed wget curl git 
#git clone https://aur.archlinux.org/yay-bin.git
#cd yay-bin
### makepkg -si
#makepkg -si --skipinteg
#cd ..
#rm -rf yay-bin

echo -e "${BLUE}:: ${NC}Обновим всю систему включая AUR пакеты" 
#echo 'Обновим всю систему включая AUR пакеты'
# Update the entire system including AUR packages
yay -Syy
yay -Syu

echo -e "${BLUE}:: ${NC}Ставим Bluetooth и Поддержка звука" 
#echo 'Ставим Bluetooth и Поддержка звука'
# Setting Bluetooth and Sound support
sudo pacman -S bluez bluez-libs bluez-cups bluez-utils --noconfirm
sudo pacman -S alsa-utils alsa-plugins alsa-firmware alsa-lib alsa-utils --noconfirm 
sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol pulseaudio-zeroconf pulseaudio-bluetooth xfce4-pulseaudio-plugin --noconfirm

echo -e "${BLUE}:: ${NC}Ставим Архиваторы Компрессионные Инструменты" 
#echo 'Ставим Архиваторы "Компрессионные Инструменты"'
# Putting Archivers "Compression Tools
sudo pacman -S zip unzip unrar p7zip zlib zziplib --noconfirm

echo -e "${BLUE}:: ${NC}Ставим дополнения к Архиваторам" 
#echo 'Ставим дополнения к Архиваторам'
# Adding extensions to Archivers
sudo pacman -S unace sharutils uudeview arj cabextract --noconfirm

echo -e "${BLUE}:: ${NC}Ставим Драйвера принтера (Поддержка печати)" 
#echo 'Ставим Драйвера принтера (Поддержка печати)'
# Putting the printer Drivers (Print support)
sudo pacman -S cups ghostscript cups-pdf --noconfirm

echo -e "${BLUE}:: ${NC}Установка базовых программ и пакетов" 
#echo 'Установка базовых программ и пакетов'
# Installing basic programs and packages
sudo pacman -S aspell-ru arch-install-scripts bash-completion dosfstools f2fs-tools sane gvfs gnu-netcat htop iftop iotop nmap ntfs-3g ntp ncdu hydra isomd5sum python-isomd5sum translate-shell mc pv reflector sox youtube-dl speedtest-cli python-pip pwgen scrot git curl xsel --noconfirm 

echo -e "${BLUE}:: ${NC}Установка терминальных утилит для вывода информации о системе" 
#echo 'Установка терминальных утилит для вывода информации о системе'
# Installing terminal utilities for displaying system information
sudo pacman -S screenfetch archey3 neofetch --noconfirm  

echo -e "${BLUE}:: ${NC}Установка Мультимедиа кодеков (multimedia codecs), и утилит" 
#echo 'Установка Мультимедиа кодеков (multimedia codecs), и утилит'
# Installing Multimedia codecs and utilities
sudo pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly libdvdcss libdvdread libdvdnav dvd+rw-tools dvdauthor dvgrab cdrdao gst-libav gst-libav gpac --noconfirm

echo -e "${BLUE}:: ${NC}Установка Мультимедиа утилит" 
#echo 'Установка Мультимедиа утилит'
# Installing Multimedia utilities
sudo pacman -S audacity audacious audacious-plugins smplayer smplayer-skins smplayer-themes smtube deadbeef easytag subdownloader mediainfo-gui vlc --noconfirm

echo -e "${BLUE}:: ${NC}Установка Текстовые редакторы и утилиты разработки" 
#echo 'Установка Текстовые редакторы и утилиты разработки'
# Installation Text editors and development tools
sudo pacman -S gedit gedit-plugins geany geany-plugins --noconfirm

echo -e "${BLUE}:: ${NC}Управления электронной почтой, новостными лентами, чатом и группам" 
#echo 'Управления электронной почтой, новостными лентами, чатом и группам'
# Manage email, news feeds, chat, and groups
sudo pacman -S thunderbird thunderbird-i18n-ru pidgin pidgin-hotkeys --noconfirm

echo -e "${BLUE}:: ${NC}Установка Браузеров и медиа-плагинов" 
#echo 'Установка Браузеров и медиа-плагинов'
# Installing Browsers and media plugins
sudo pacman -S firefox firefox-i18n-ru firefox-spell-ru flashplugin pepper-flash --noconfirm

echo -e "${BLUE}:: ${NC}Установка Брандмауэра UFW и Антивирусного пакета ClamAV (GUI)(GTK+)" 
#echo 'Установка Брандмауэра UFW и Антивирусного пакета ClamAV (GUI)(GTK+)'
# Installing the UFW Firewall and clamav Antivirus package (GUI) (GTK+)
echo -e "${BLUE}:: ${NC}Установка Производится в порядке перечисления" 
#echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo -e "${GREEN}==> ${NC}Установить UFW (Несложный Брандмауэр) (GTK)?"
#echo 'Установить UFW (Несложный Брандмауэр) (GTK)?'
# Install UFW (Uncomplicated Firewall) (GTK)?
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S ufw gufw --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo -e "${GREEN}==> ${NC}Установить Clam AntiVirus (GTK)?"
#echo 'Установить Clam AntiVirus (GTK)?'
# Install Clam AntiVirus (GTK)?
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S clamav clamtk --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo -e "${BLUE}:: ${NC}Установка Torrent клиентов - Transmission, qBittorrent, Deluge (GTK)(Qt)(GTK+)" 
#echo 'Установка Torrent клиентов - Transmission, qBittorrent, Deluge (GTK)(Qt)(GTK+)'
# Installing Torrent clients - Transmission, qBittorrent, Deluge (GTK) (Qt) (GTK+)
echo -e "${BLUE}:: ${NC}Установка Производится в порядке перечисления" 
#echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo -e "${GREEN}==> ${NC}Установить Transmission, qBittorrent, Deluge?"
#echo 'Установить Transmission, qBittorrent, Deluge?'
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

echo -e "${BLUE}:: ${NC}Установка Офиса (LibreOffice-still, или LibreOffice-fresh)" 
#echo 'Установка Офиса (LibreOffice-still, или LibreOffice-fresh)'
# Office installation (LibreOffice-still, or LibreOffice-fresh)
echo -e "${BLUE}:: ${NC}Установка Производится в порядке перечисления" 
#echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo -e "${GREEN}==> ${NC}Установить LibreOffice-still, LibreOffice-fresh?"
#echo 'Установить LibreOffice-still, LibreOffice-fresh?'
# Install the LibreOffice-still and LibreOffice-fresh?
read -p "1 - LibreOffice-still, 2 - LibreOffice-fresh, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S libreoffice-still libreoffice-still-ru --noconfirm
elif [[ $prog_set == 2 ]]; then
sudo pacman -S libreoffice libreoffice-fresh-ru --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo -e "${GREEN}==> ${NC}Установить рекомендованные программы?"
#echo 'Установить рекомендованные программы?'
# Install the recommended programs
echo -e "${BLUE}
'Список программ рекомендованных к установке:${GREEN}
bleachbit gparted grub-customizer conky conky-manager dconf-editor doublecmd-gtk2 gnome-system-monitor obs-studio openshot frei0r-plugins redshift veracrypt onboard clonezilla moc filezilla gnome-calculator nomacs osmo synapse telegram-desktop plank psensor keepass copyq variety grsync numlockx modem-manager-gui uget xarchiver-gtk2 rofi gsmartcontrol testdisk glances tlp tlp-rdw file-roller meld cmake xterm lsof dmidecode'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S bleachbit gparted grub-customizer conky conky-manager dconf-editor doublecmd-gtk2 gnome-system-monitor obs-studio openshot frei0r-plugins redshift veracrypt onboard clonezilla moc filezilla gnome-calculator nomacs osmo synapse telegram-desktop plank psensor keepass copyq variety grsync numlockx modem-manager-gui uget xarchiver-gtk2 rofi gsmartcontrol testdisk glances tlp tlp-rdw file-roller meld cmake xterm lsof dmidecode --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo -e "${BLUE}:: ${NC}Утилиты для форматирования флэш-накопителя с файловой системой exFAT в Linux" 
#echo 'Утилиты для форматирования флэш-накопителя с файловой системой exFAT в Linux'
# Utilities for formatting a flash drive with the exFAT file system in Linux
sudo pacman -S exfat-utils fuse-exfat --noconfirm 

echo -e "${BLUE}:: ${NC}Установка Pacman gui,Octopi (AUR)(GTK)(QT)" 
#echo 'Установка "Pacman gui","Octopi" (AUR)(GTK)(QT)'
# Installing "Pacman gui", "Octopi" (AUR)(GTK)(QT)
echo -e "${BLUE}:: ${NC}Установка Производится в порядке перечисления" 
#echo 'Установка Производится в порядке перечисления'
# Installation Is performed in the order listed
echo -e "${GREEN}==> ${NC}Установить pamac-aur, octopi?"
#echo 'Установить "pamac-aur", "octopi"?'
# Install "pacman-aur", "octopi"?
read -p "1 - Pacmac-aur, 2 - Octopi, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S pamac-aur --noconfirm
elif [[ $prog_set == 2 ]]; then
yay -S octopi --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo -e "${BLUE}:: ${NC}Обновим информацию о шрифтах" 
#echo 'Обновим информацию о шрифтах'
# Update information about fonts
sudo fc-cache -f -v

echo -e "${BLUE}:: ${NC}Применяем настройки TLP (управления питанием) в зависимости от источника питания (батарея или от сети)" 
#echo 'Применяем настройки TLP (управления питанием) в зависимости от источника питания (батарея или от сети)'
# Apply TLP (power management) settings depending on the power source (battery or mains)
sudo tlp start

echo -e "${YELLOW}==> ${NC}Включаем сетевой экран?"
#echo 'Включаем сетевой экран?'
# Enabling the network screen?
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo ufw enable
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

#echo 'Включаем сетевой экран'
# Enabling the network screen
#sudo ufw enable

echo -e "${YELLOW}==> ${NC}Добавляем в автозагрузку сетевой экран?"
#echo 'Добавляем в автозагрузку сетевой экран?'
# Adding the network screen to auto-upload?
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo systemctl enable ufw
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

#echo 'Добавляем в автозагрузку сетевой экран'
# Adding the network screen to auto-upload
#sudo systemctl enable ufw

sleep 1
echo -e "${BLUE}:: ${NC}Проверим статус запуска сетевой экран UFW" 
#echo 'Проверим статус запуска сетевой экран UFW'
# Check the startup status of the UFW network screen
sudo ufw status

echo -e "${BLUE}:: ${NC}Создать резервную копию (дубликат) файла grub.cfg" 
#echo 'Создать резервную копию (дубликат) файла grub.cfg'
# Create a backup (duplicate) of the grub.cfg file
sudo cp /boot/grub/grub.cfg grub.cfg.backup

###         "Дополнительные Настройки"
# ============================================================================
# Часы:
#Europe/Moscow
#%a, %d %b, %H:%M
# ----------------------------------------------------------------------------
# Conky Start Stop:
#Conky Start Stop
#Включить и выключить Conky
#bash -c 'if [[ `pidof conky` ]]; then killall conky; else bash ~/.scripts/conky-startup.sh; fi'
#Эмблемы: emblem-generic
# ----------------------------------------------------------------------------
# Клавиатура:
#xfce4-terminal   Ctrl+Alt+T
#xfce4-terminal --drop-down  F12
#light-locker-command -l   Ctrl+Alt+L
#xkill   Ctrl+Alt+X
#xfce4-taskmanager  Ctrl+Alt+M 
#xflock4   Ctrl+Alt+Delete
# ---------------------------------------------------------------------------
# Redshift:
#Redshift
#Инструмент регулирования цветовой температуры
#sh -c "sleep 30 && redshift-gtk -l 54.5293:36.27542 -t 6400:4500 -b 1.0:0.8"
#on login
# ============================================================================
# echo 'Добавить оскорбительное выражение после неверного ввода пароля в терминале'
# Откройте на редактирование файл sudoers следующей командой в терминале:
# sudo nano /etc/sudoers
# Когда откроется файл sudoers на редактирование, переместитесь до строки:
#   # Defaults env_keep += "QTDIR KDEDIR"
# и ниже скопипастите следующую стоку:
#     Defaults  badpass_message="Ты не администратор, придурок."
# ============================================================================
# Добавить (прописать) в /etc/fstab , в самый низ файла:
# с отступом от последней записи (запись оставить закомментированной)
#  #/swapfile1 swap swap defaults 0 0
# ============================================================================
# Пропишем тему для Color в pacman.conf" 
# Write the theme for Color in pacman.conf
# ILoveCandy >> /etc/pacman.conf
# sudo pacman -Syy
# Синхронизация и обновление пакетов (-yy принудительно обновить даже если обновленные)
# ============================================================================
# Прозрачность панели XFCE:
# Выберите цвет панели /bn/ - #4072BF
# Регулируйте прозрачность не панели, а
# внешний вид → стиль → выбрать сплошной цвет → в выборе цвета задайте прозрачность (ползунок снизу)
# ============================================================================
#Основное
#Имя:  Thunar Root
#Описание:  Thunar Root
#Открыть папку с привилегиями root
#Команда:  pkexec thunar %f
#Сочетание клавиш: 
#Значёк:  folder-blue
#Условия появления 
#Шаблоны имени файла:  *.txt;*.doc;*
#Каталоги  Текстовые файлы
# ----------------------------------------------------------------------------
# Дописать в файлик по адресу home/.config/Thunar/uca.xml
# uca.xml :
#<?xml encoding="UTF-8" version="1.0"?>
#<actions>
#<action>
#    <icon>Terminal</icon>
#    <name>Terminal</name>
#    <unique-id>1367866030392833-1</unique-id>
#    <command>exo-open --working-directory %f --launch TerminalEmulator</command>
#    <description></description>
#    <patterns>*</patterns>
#    <directories/>
#</action>
#<action>
#    <icon>stock_folder</icon>
#    <name>Thunar Root</name>
#    <unique-id>1367866030392883-2</unique-id>
#    <command>pkexec thunar %f</command>
#    <description>Thunar Root</description>
#    <patterns>*</patterns>
#    <directories/>
#</action>
#<action>
#    <icon>system-search</icon>
#    <name>Search</name>
#    <unique-id>1367866030392913-3</unique-id>
#    <command>catfish %f</command>
#    <description>find files and folders</description>
#    <patterns>*</patterns>
#    <directories/>
#</action>
#</actions>
#
#  Или
#<?xml encoding="UTF-8" version="1.0"?>
#<actions>
#<action>
#    <icon>utilities-terminal</icon>
#    <name>_Terminal</name>
#    <unique-id>1476165034892557-17</unique-id>
#    <command>exo-open --working-directory %f --launch TerminalEmulator</command>
#    <description>Example for a custom action</description>
#    <patterns>*</patterns>
#    <startup-notify/>
#    <directories/>
#</action>
#<action>
#    <icon>folder_color_red</icon>
#    <name>Root T_hunar</name>
#    <unique-id>1476164980531587-13</unique-id>
#    <command>pkexec thunar %f</command>
#    <description></description>
#    <patterns>*</patterns>
#    <directories/>
#</action>
#<action>
#    <icon>text-editor</icon>
#    <name>Edit as Root</name>
#    <unique-id>1476164983371929-14</unique-id>
#    <command>pkexec xed %f</command>
#    <description>Edit as root</description>
#    <patterns>*</patterns>
#    <other-files/>
#    <text-files/>
#</action>
#</actions>
#
# И установить - catfish, xorg-xkill
# ============================================================================

#echo 'Запуск звуковой системы PulseAudio'
# Starting the PulseAudio sound system
#sudo start-pulseaudio-x11
# Выполнить эту команду только после установки утилит 'Поддержка звука' и перезагрузки системы, если сервис 'Запуск системы PulseAudio (Запуск звуковой системы PulseAudio)'не включился, и не появился в автозапуске. Это можно посмотреть через, диспетчер настроек, в пункте меню 'Сеансы и автозапуск'.

echo -e "${GREEN}==> ${NC}Установка завершена!"
#echo 'Установка завершена!'
# The installation is now complete!

echo -e "${YELLOW}==> ${NC}Желательно перезагрузить систему для применения изменений"
#echo 'Желательно перезагрузить систему для применения изменений'
# It is advisable to restart the system to apply the changes

echo -e "${BLUE}==> ${NC}Скачать и произвести запуск скрипта (archmy4)?"
#echo 'Скачать и произвести запуск скрипта (archmy4)?'
# Download and run the script (archmy4)?
# echo 'wget git.io/archmy4 && sh archmy4'
echo -e "${YELLOW}==>  wget git.io/archmy4 ${NC}"
# Команды по установке :
# wget git.io/archmy4 
# wget git.io/archmy4 && sh archmy4 --noconfirm
echo -e "${GREEN}
  <<< ♥ Либо ты идешь вперед... либо в зад. >>> ${NC}"
#echo '♥ Либо ты идешь вперед... либо в зад.' 
# ♥ Either you go forward... or you go up your ass.
# ============================================================================

#echo -e "${YELLOW}==> ${NC}Загрузим архив (ветку мастер MarcMilany/arch_2020)"
#echo 'Загрузим архив (ветку мастер MarcMilany/arch_2020)'
# Upload the archive (branch master MarcMilany/arch_2020)
#wget github.com/MarcMilany/arch_2020.git/archive/master.zip
#wget github.com/MarcMilany/arch_2020.git/archive/arch_2020-master.zip
#sudo mv -f ~/Downloads/master.zip
#sudo mv -f ~/Downloads/arch_2020-master.zip
#sudo tar -xzf master.zip -C ~/ 
#sudo tar -xzf arch_2020-master.zip -C ~/
#git clone https://github.com/MarcMilany/arch_2020.git

echo -e "${BLUE}:: ${NC}Посмотрим дату и время без характеристик для проверки времени"
#echo 'Посмотрим дату и время без характеристик для проверки времени'
# Let's look at the date and time without characteristics to check the time
date
time

echo 'Удаление созданной папки (downloads), и скрипта установки программ (archmy3)'
# Deleting the created folder (downloads) and the program installation script (archmy3)
sudo rm -R ~/downloads/
sudo rm -rf ~/archmy3

echo -e "${BLUE}==> ${NC}Выйти из настроек, или перезапустить систему?"
#echo "Выйти из настроек, или перезапустить систему?"
# Exit settings, or restart the system?
echo -e "${GREEN}==> ${NC}y+Enter - выйти, просто Enter - перезапуск"
#echo "y+Enter - выйти, просто Enter - перезапуск"
# y+Enter-exit, just Enter-restart
read doing 
case $doing in
y)
  exit
 ;;
*)
sudo reboot -f
esac #окончание оператора case.
