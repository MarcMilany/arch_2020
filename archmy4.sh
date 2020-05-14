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
# Если возникли проблемы с обновлением, или установкой пакетов 
# Выполните данные рекомендации:
# author:

echo 'Для проверки интернета можно пропинговать какой-либо сервис'
# To check the Internet, you can ping a service
ping -c2 archlinux.org

echo 'Обновление ключей системы'
# Updating of keys of a system
{
echo "Создаётся генерация мастер-ключа (брелка) pacman, введите пароль (не отображается)..."
sudo pacman-key --init
echo "Далее идёт поиск ключей..."
sudo pacman-key --populate archlinux
echo "Обновление ключей..."
sudo pacman-key --refresh-keys
echo "Обновление баз данных пакетов..."
sudo pacman -Sy
}

# ============================================================================

echo 'Создадим папку (downloads), и переходим в созданную папку'
# Create a folder (downloads), and go to the created folder
#rm -rf ~/.config/xfce4/*
mkdir ~/downloads
cd ~/downloads

echo 'Установка дополнительных шрифтов'
#
sudo pacman -S ttf-bitstream-vera freemind --noconfirm

echo 'Обновим информацию о шрифтах'
# Update information about fonts
sudo fc-cache -f -v

echo 'Установка шрифтов дополнительных AUR'
#
yay -S ttf-ms-fonts font-manager --noconfirm 

echo 'Обновим информацию о шрифтах'
# Update information about fonts
sudo fc-cache -f -v

echo 'Установка Мультимедиа утилит'
#
sudo pacman -S --noconfirm 

echo 'Установка Мультимедиа утилит AUR'
#
yay -S radiotray spotify vlc-tunein-radio vlc-pause-click-plugin audiobook-git cozy-audiobooks m4baker-git mp3gain easymp3gain-gtk2 myrulib-git --noconfirm 

echo 'Установка программ для обработки видео и аудио (конвертеры)'
#
sudo pacman -S kdenlive --noconfirm

echo 'Установка программ для обработки видео и аудио (конвертеры) AUR'
#
yay -S  --noconfirm

echo 'Установка программ для рисования и редактирования изображений'
#
sudo pacman -S gimp --noconfirm

echo 'Установка программ для рисования и редактирования изображений AUR'
#
yay -S  --noconfirm

echo 'Установка Oracle VM VirtualBox'
#
sudo pacman -S  --noconfirm

echo 'Установка Oracle VM VirtualBox AUR'
#
yay -S  --noconfirm

echo 'Установка Java JDK средство разработки и среда для создания Java-приложений'
#
sudo pacman -S --noconfirm

echo 'Установка Java JDK или Java Development Kit AUR'
#
yay -S  --noconfirm

echo 'Сетевые онлайн хранилища'
#
sudo pacman -S --noconfirm

echo 'Сетевые онлайн хранилища AUR'
#
yay -S megasync thunar-megasync yandex-disk yandex-disk-indicator dropbox --noconfirm

echo 'Утилиты для редактирования документов, PDF, DjVus, NFO, DIZ и XPS... , Читалки электронных книг, Словари, Таблицы'
#
sudo pacman -S  --noconfirm

echo 'Утилиты для редактирования документов, PDF, DjVus, NFO, DIZ и XPS... , Читалки электронных книг, Словари, Таблицы AUR'
#
yay -S sublime-text-dev unoconv hunspell-ru  masterpdfeditor --noconfirm

echo 'Утилиты для проектирования, черчения и тд...'
#
sudo pacman -S  --noconfirm

echo 'Утилиты для проектирования, черчения и тд... AUR'
#
yay -S  --noconfirm

echo 'Утилиты для работы с CD,DVD, создание ISO образов, запись на флеш-накопители'
#
sudo pacman -S  --noconfirm

echo 'Утилиты для работы с CD,DVD, создание ISO образов, запись на флеш-накопители AUR'
#
yay -S woeusb-git mintstick unetbootin --noconfirm 

echo 'Онлайн мессенжеры и Телефония, Управления чатом и группам'
#
sudo pacman -S --noconfirm

echo 'Онлайн мессенжеры и Телефония, Управления чатом и группам AUR'
#
yay -S skypeforlinux-stable-bin skype-call-recorder vk-messenger viber pidgin-extprefs --noconfirm 

echo 'Утилиты для работы с CD,DVD, создание ISO образов, запись на флеш-накопители AUR'
#
yay -S woeusb-git mintstick unetbootin --noconfirm 

echo 'Сетевые утилиты, Tor, VPN, SSH, Samba и тд...'
#
sudo pacman -S --noconfirm

echo 'Сетевые утилиты, Tor, VPN, SSH, Samba и тд... AUR'
#
yay -S --noconfirm 

echo 'Установить рекомендумые программы?'
#
echo -e "${BLUE}
'Список программ рекомендованных к установке:
keepass2-plugin-tray-icon'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
  sudo pacman -S keepass2-plugin-tray-icon --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить рекомендумые программы из AUR?'
#
echo -e "${BLUE}
'Список программ рекомендованных к установке:${GREEN}
gksu debtap caffeine-ng inxi xneur fsearch-git cherrytree timeshift mocicon multiload-ng-indicator-gtk xfce4-multiload-ng-plugin-gtk2 keepass2-plugin-tray-icon gconf-editor webtorrent-desktop xorg-xkill teamviewer corectrl'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S gksu debtap caffeine-ng inxi xneur fsearch-git cherrytree timeshift mocicon multiload-ng-indicator-gtk xfce4-multiload-ng-plugin-gtk2 keepass2-plugin-tray-icon gconf-editor webtorrent-desktop xorg-xkill teamviewer corectrl qt4 xflux flameshot-git --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Дополнительные пакеты для игр'
#
sudo pacman -S steam lutris lib32-gconf lib32-dbus-glib lib32-libnm-glib lib32-openal lib32-nss lib32-gtk2 lib32-sdl2 lib32-sdl2_image lib32-libcanberra --noconfirm

echo 'Дополнительные пакеты для игр AUR'
#
yay -S lib32-libudev0 --noconfirm

echo 'Установка Дополнителых программ'
#
echo -e "${BLUE}
'Список программ рекомендованных к установке:
galculator-gtk2'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
  sudo pacman -S galculator-gtk2 --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка Дополнителых программ AUR'
#
echo -e "${BLUE}
'Список программ рекомендованных к установке:
сюда вписать список программ'
${NC}"
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

#echo 'Установка тем'
#yay -S osx-arc-shadow papirus-maia-icon-theme-git breeze-default-cursor-theme --noconfirm

#echo 'Ставим лого ArchLinux в меню'
#wget git.io/arch_logo.png
#sudo mv -f ~/Downloads/arch_logo.png /usr/share/pixmaps/arch_logo.png

#echo 'Ставим обои на рабочий стол'
#wget git.io/bg.jpg
#sudo rm -rf /usr/share/backgrounds/xfce/* #Удаляем стандартрые обои
#sudo mv -f ~/Downloads/bg.jpg /usr/share/backgrounds/xfce/bg.jpg

echo 'Удаление созданной папки (downloads), и скрипта установки программ (arch3my)'
# Deleting the created folder (downloads) and the program installation script (arch3my)
sudo rm -R ~/downloads/
sudo rm -rf ~/arch4my

echo 'Установка завершена!'
# The installation is now complete!

echo 'Желательно перезагрузить систему для применения изменений'
# It is advisable to restart the system to apply the changes

