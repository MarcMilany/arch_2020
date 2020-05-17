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
Цель сценария (скрипта) - это установка необходимого софта (пакетов) и запуск необходимых служб. 
Смысл в том, что все изменения вы делаете предварительно в самом скрипте и получаете возможность быстрой установки утилит (пакетов), которые Вы решили установить (при условии, что Вы его изменили под себя, в противном случае скрипт установит софт (пакеты) прописанный изначально.
В процессе работы сценария (скрипта) Вам будут задаваться вопросы на установку той, или иной утилиты (пакета) - будьте внимательными! Устанавливаемый софт (пакеты), шрифты - скачивается и устанавливается из 'Официальных репозиториев Arch Linux'. Так же присутствует софт (пакеты), шрифты - устанавливаемый из пользовательского репозитория 'AUR'-'yay', собираются и устанавливаются. Если Вы сомневаетесь в своих действиях, скриптом можно пользоваться как шпаргалкой, открыв его в текстовом редакторе, копируя команды по установке необходимых пакетов, и запуска необходимых служб. В любой ситуации выбор всегда за вами. Вы либо гуляете под дождем, либо просто под ним мокнете.${RED}

  ***************************** ВНИМАНИЕ! ***************************** 
${NC}
Автор не несёт ответственности за любое нанесение вреда при использовании скрипта. 
Вы используйте его на свой страх и риск, или изменяйте под свои личные нужды. 
В данный момент сценарий (скрипта) находится в процессе доработки по прописанию устанавливаемого софта (пакетов), и небольшой корректировке (Воен. Внесение поправок в наводку орудий по результатам наблюдений с наблюдательных пунктов)."

}

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

### Reboot with 10s timeout Перезагрузка с таймаутом 10 секунд
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
echo 'Для проверки интернета можно пропинговать какой-либо сервис'
# To check the Internet, you can ping a service
ping -c2 archlinux.org

echo 'Обновление баз данных пакетов'
# Update the databases of packages
sudo pacman -Sy

# ============================================================================
# Если возникли проблемы с обновлением, или установкой пакетов 
# Выполните данные рекомендации:
# author:
#echo 'Обновление ключей системы'
# Updating of keys of a system
#{
#echo "Создаётся генерация мастер-ключа (брелка) pacman, введите пароль (не отображается)..."
#sudo pacman-key --init
#echo "Далее идёт поиск ключей..."
#sudo pacman-key --populate archlinux
#echo "Обновление ключей..."
#sudo pacman-key --refresh-keys
#echo "Обновление баз данных пакетов..."
#sudo pacman -Sy
#}
#sleep 1
#
# ============================================================================

echo 'Создадим папку (downloads), и переходим в созданную папку'
# Create a folder (downloads), and go to the created folder
#rm -rf ~/.config/xfce4/*
mkdir ~/downloads
cd ~/downloads

echo 'Установка дополнительных шрифтов'
# The installation of additional fonts
echo -e "${BLUE}
'Список дополнительных шрифтов:${GREEN}
ttf-bitstream-vera freemind '
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S ttf-bitstream-vera freemind --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка дополнительных шрифтов пропущена.'
fi

echo 'Обновим информацию о шрифтах'
# Update information about fonts
sudo fc-cache -f -v

echo 'Установка дополнительных шрифтов AUR'
# The installation of additional fonts AUR
echo -e "${BLUE}
'Список дополнительных шрифтов AUR:${GREEN}
ttf-ms-fonts font-manager'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S ttf-ms-fonts font-manager --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка дополнительных шрифтов AUR пропущена.'
fi

echo 'Обновим информацию о шрифтах'
# Update information about fonts
sudo fc-cache -f -v

echo 'Установка Мультимедиа утилит'
# Installing Multimedia utilities
echo -e "${BLUE}
'Список Мультимедиа утилит:${GREEN}
сюда вписать список программ'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка Мультимедиа утилит пропущена.'
fi
 
echo 'Установка Мультимедиа утилит AUR'
# Installing Multimedia utilities AUR
echo -e "${BLUE}
'Список Мультимедиа утилит AUR:${GREEN}
radiotray spotify vlc-tunein-radio vlc-pause-click-plugin audiobook-git cozy-audiobooks m4baker-git mp3gain easymp3gain-gtk2 myrulib-git'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S radiotray spotify vlc-tunein-radio vlc-pause-click-plugin audiobook-git cozy-audiobooks m4baker-git mp3gain easymp3gain-gtk2 myrulib-git --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка Мультимедиа утилит AUR пропущена.'
fi

echo 'Установка программ для обработки видео и аудио (конвертеры)'
# Installing software for video and audio processing (converters)
sudo pacman -S kdenlive --noconfirm

echo 'Установка программ для обработки видео и аудио (конвертеры) AUR'
# Installing software for video and audio processing (converters) AUR
yay -S  --noconfirm

echo 'Установка программ для рисования и редактирования изображений'
# Installing software for drawing and editing images
sudo pacman -S gimp --noconfirm

echo 'Установка программ для рисования и редактирования изображений AUR'
# Installing software for drawing and editing images AUR
yay -S  --noconfirm

echo 'Установка Oracle VM VirtualBox'
# Installing Oracle VM VirtualBox
sudo pacman -S  --noconfirm

echo 'Установка Oracle VM VirtualBox AUR'
# Installing Oracle VM VirtualBox AUR
yay -S  --noconfirm

echo 'Установка Java JDK средство разработки и среда для создания Java-приложений'
# Installing Java JDK development tool and environment for creating Java applications
sudo pacman -S --noconfirm

echo 'Установка Java JDK или Java Development Kit AUR'
# Installing Java JDK development tool and environment for creating Java applications AUR
yay -S  --noconfirm

echo 'Сетевые онлайн хранилища'
# Online storage networks
sudo pacman -S --noconfirm

echo 'Сетевые онлайн хранилища AUR'
# Online storage networks AUR
yay -S megasync thunar-megasync yandex-disk yandex-disk-indicator dropbox --noconfirm

echo 'Утилиты для редактирования документов, PDF, DjVus, NFO, DIZ и XPS... , Читалки электронных книг, Словари, Таблицы'
# Utilities for editing documents, PDF, Djvu, NFO, DIZ and XPS..., e-book Readers, Dictionaries, Tables
sudo pacman -S  --noconfirm

echo 'Утилиты для редактирования документов, PDF, DjVus, NFO, DIZ и XPS... , Читалки электронных книг, Словари, Таблицы AUR'
# Utilities for editing documents, PDF, Djvu, NFO, DIZ and XPS..., e-book Readers, Dictionaries, Tables AUR
yay -S sublime-text-dev unoconv hunspell-ru  masterpdfeditor --noconfirm

echo 'Утилиты для проектирования, черчения и тд...'
# Utilities for designing, drawing, and so on...
sudo pacman -S  --noconfirm

echo 'Утилиты для проектирования, черчения и тд... AUR'
# Utilities for designing, drawing, and so on... AUR
yay -S  --noconfirm

echo 'Утилиты для работы с CD,DVD, создание ISO образов, запись на флеш-накопители'
# Utilities for working with CD, DVD, creating ISO images, writing to flash drives
sudo pacman -S  --noconfirm

echo 'Утилиты для работы с CD,DVD, создание ISO образов, запись на флеш-накопители AUR'
# Utilities for working with CD, DVD, creating ISO images, writing to flash drives AUR
yay -S woeusb-git mintstick unetbootin --noconfirm 

echo 'Онлайн мессенжеры и Телефония, Управления чатом и группам'
# Online messengers and Telephony, chat and group Management
sudo pacman -S --noconfirm

echo 'Онлайн мессенжеры и Телефония, Управления чатом и группам AUR'
# Online messengers and Telephony, chat and group Management AUR
yay -S skypeforlinux-stable-bin skype-call-recorder vk-messenger viber pidgin-extprefs --noconfirm 

echo 'Сетевые утилиты, Tor, VPN, SSH, Samba и тд...'
# Network utilities, Tor, VPN, SSH, Samba, etc...
sudo pacman -S --noconfirm

echo 'Сетевые утилиты, Tor, VPN, SSH, Samba и тд... AUR'
# Network utilities, Tor, VPN, SSH, Samba, etc... AUR
yay -S --noconfirm 

echo 'Установить рекомендуемые программы?'
# To install the recommended program?
echo -e "${BLUE}
'Список программ рекомендованных к установке:${GREEN}
keepass2-plugin-tray-icon simplescreenrecorder'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S keepass2-plugin-tray-icon simplescreenrecorder --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить рекомендуемые программы из AUR?'
# To install the recommended program? AUR
echo -e "${BLUE}
'Список программ рекомендованных к установке:${GREEN}
gksu debtap caffeine-ng inxi xneur fsearch-git cherrytree timeshift mocicon multiload-ng-indicator-gtk xfce4-multiload-ng-plugin-gtk2 keepass2-plugin-tray-icon gconf-editor webtorrent-desktop xorg-xkill teamviewer corectrl lib32-simplescreenrecorder'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S gksu debtap caffeine-ng inxi xneur fsearch-git cherrytree timeshift mocicon multiload-ng-indicator-gtk xfce4-multiload-ng-plugin-gtk2 keepass2-plugin-tray-icon gconf-editor webtorrent-desktop xorg-xkill teamviewer corectrl qt4 xflux flameshot-git lib32-simplescreenrecorder --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Дополнительные пакеты для игр'
# Additional packages for games
sudo pacman -S steam lutris lib32-gconf lib32-dbus-glib lib32-libnm-glib lib32-openal lib32-nss lib32-gtk2 lib32-sdl2 lib32-sdl2_image lib32-libcanberra --noconfirm

echo 'Дополнительные пакеты для игр AUR'
# Additional packages for games AUR
yay -S lib32-libudev0 --noconfirm

echo 'Установка Дополнительных программ'
# Installing Additional programs
echo -e "${BLUE}
'Список Дополнительных программ к установке:${GREEN}
galculator-gtk2'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S galculator-gtk2 --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка Дополнительных программ AUR'
# Installing Additional programs AUR
echo -e "${BLUE}
'Список Дополнительных программ к установке AUR:${GREEN}
сюда вписать список программ'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Обновим информацию о шрифтах'
# Update information about fonts
sudo fc-cache -f -v

echo 'Список всех пакетов-сирот'
# List of all orphan packages
sudo pacman -Qdt 

sleep 5
echo 'Удаление всех пакетов-сирот?'
# Deleting all orphaned packages?
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -Qdtq
elif [[ $prog_set == 0 ]]; then
  echo 'Удаление пакетов-сирот пропущено.'
fi    

echo 'Очистка кэша неустановленных пакетов'
# Clearing the cache of uninstalled packages
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -Sc 
elif [[ $prog_set == 0 ]]; then
  echo 'Очистка кэша пропущена.'
fi  

echo 'Очистка кэша пакетов'
# Clearing the package cache
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -Scc 
elif [[ $prog_set == 0 ]]; then
  echo 'Очистка кэша пропущена.'
fi 

echo 'Список Установленного софта (пакетов)'
#List of Installed software (packages)
sudo pacman -Qqe

# ============================================================================
#echo 'Установка тем'
#yay -S osx-arc-shadow papirus-maia-icon-theme-git breeze-default-cursor-theme --noconfirm

#echo 'Ставим лого ArchLinux в меню'
#wget git.io/arch_logo.png
#sudo mv -f ~/Downloads/arch_logo.png /usr/share/pixmaps/arch_logo.png

#echo 'Ставим обои на рабочий стол'
#wget git.io/bg.jpg
#sudo rm -rf /usr/share/backgrounds/xfce/* #Удаляем стандартрые обои
#sudo mv -f ~/Downloads/bg.jpg /usr/share/backgrounds/xfce/bg.jpg
# ============================================================================

sleep 5
echo -e "${GREEN}
  Установка софта (пакетов) завершена!
${NC}"
# Installation of software (packages) is complete!
#echo 'Установка завершена!'
# The installation is now complete!

echo 'Желательно перезагрузить систему для применения изменений'
# It is advisable to restart the system to apply the changes
# ============================================================================
time

echo 'Удаление созданной папки (downloads), и скрипта установки программ (arch3my)'
# Deleting the created folder (downloads) and the program installation script (arch3my)
sudo rm -R ~/downloads/
sudo rm -rf ~/arch4my


