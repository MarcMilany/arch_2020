#!/bin/bash
#_arch_fast_install_banner
set > old_vars.log

APPNAME="arch_fast_install"
VERSION="v1.6 LegasyBIOS"
BRANCH="master"
AUTHOR="ordanax"
LICENSE="GNU General Public License 3.0"

### Description (Описание)
_arch_fast_install_banner() {
    echo -e "${BLUE}
┌─┐┬─┐┌─┐┬ ┬  ┬  ┬ ┬ ┬┬ ┬┌┌┐  ┬─┐┌─┐┌─┐┌┬┐  ┬ ┬ ┬┌─┐┌┬┐┌─┐┬  ┬  
├─┤├┬┘│  ├─┤  │  │ │\││ │ │   │─ ├─┤└─┐ │   │ │\│└─┐ │ ├─┤│  │  
┴ ┴┴└─└─┘┴ ┴  └─┘┴ ┴ ┴└─┘└└┘  ┴  ┴ ┴└─┘ ┴   ┴ ┴ ┴└─┘ ┴ ┴ ┴┴─┘┴─┘${RED}
 Arch Linux Install ${VERSION} - A script made with love by ${AUTHOR}
${NC}
Arch Linux - это независимо разработанный универсальный дистрибутив GNU / Linux для архитектуры x86-64, который стремится предоставить последние стабильные версии большинства программ, следуя модели непрерывного выпуска.
 Arch Linux определяет простоту как без лишних дополнений или модификаций. Arch включает в себя многие новые функции, доступные пользователям GNU / Linux, включая systemd init system, современные файловые системы , LVM2, программный RAID, поддержку udev и initcpio (с mkinitcpio ),а также последние доступные ядра.  
Arch Linux - это дистрибутив общего назначения. После установки предоставляется только среда командной строки: вместо того, чтобы вырывать ненужные и нежелательные пакеты, пользователю предлагается возможность создать собственную систему, выбирая среди тысяч высококачественных пакетов, представленных в официальных репозиториях для x86-64 архитектуры.
Этот скрипт не задумывался, как обычный установочный с большим выбором DE, разметкой диска и т.д.
 И он не предназначен для новичков. Он предназначен для тех, кто ставил ArchLinux руками и понимает, что и для чего нужна каждая команда.  
Его цель - это моментальное разворачивание системы со всеми конфигами. Смысл в том что, все изменения вы делаете предварительно в самом скрипте и получаете возможность быстрой установки ArchLinux с вашими личными настройками (при условии, что вы его изменили под себя, в противном случае с моими настройками).${RED}
# ====================== ВНИМАНИЕ! ====================== #${NC}
Автор не несет ответственности за любое нанесение вреда при использовании скрипта. 
Вы используйте его на свой страх и риск, или изменяйте под свои личные нужды."
}

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
# Arch Linux Fast Install (arch2018) - Быстрая установка Arch Linux 
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).
# Проект (project): https://github.com/ordanax/arch2018

# В разработке принимали участие (author) :
# Алексей Бойко https://vk.com/ordanax
# Степан Скрябин https://vk.com/zurg3
# Михаил Сарвилин https://vk.com/michael170707
# Данил Антошкин https://vk.com/danil.antoshkin
# Юрий Порунцов https://vk.com/poruncov

# Лицензия (license): LGPL-3.0 (http://opensource.org/licenses/lgpl-3.0.html
# Installation guide - Arch Wiki
# (referance): https://wiki.archlinux.org/index.php/Installation_guide
# ============================================================================
# Команды по установке :
# archiso login: root (automatic login)

echo 'To check the Internet, you can ping a service'
# Для проверки интернета можно пропинговать какой-либо сервис
ping -c2 archlinux.org 

echo 'Setting up the Russian language, changing the console font to one that supports Cyrillic for ease of use'
 # Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы
loadkeys ru
setfont cyr-sun16

### Display banner (Дисплей баннер)
_arch_fast_install_banner

sleep 1
echo '2.3 Синхронизация системных часов'
# Syncing the system clock
timedatectl set-ntp true

echo 'Посмотрим текущее состояние аппаратных и программных часов'
# Let's see the current state of the hardware and software clock
sudo timedatectl

echo '2.4 Создание разделов'
# Create partitions
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +2G;

  echo n;
  echo;
  echo;
  echo;
  echo +8G;

  echo n;
  echo;
  echo;
  echo;
  echo +35G;

  echo n;
  echo p;
  echo;
  echo;
  echo a;
  echo 1;

  echo w;
) | fdisk /dev/sda

echo 'Ваша разметка диска'
# Your disk markup
fdisk -l

echo '2.4.2 Форматирование разделов диска'
# Formatting disk partitions
mkfs.ext2  /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4  /dev/sda3 -L root
mkfs.ext4  /dev/sda4 -L home

echo '2.4.3 Монтирование разделов диска'
# Mounting disk partitions
mount /dev/sda3 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda4 /mnt/home

echo '3.1 Выбор серверов-зеркал для загрузки. Ставим зеркало от Яндекс'
# The choice of mirror sites to download. Putting a mirror from Yandex
#echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
> /etc/pacman.d/mirrorlist
cat <<EOF >>/etc/pacman.d/mirrorlist

##
## Arch Linux repository mirrorlist
## Generated on 2020-05-14
## HTTP IPv4 HTTPS
##

## Russia
Server = https://mirror.rol.ru/archlinux/\$repo/os/\$arch
Server = https://mirror.yandex.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.rol.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.truenetwork.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch
#Server = http://archlinux.zepto.cloud/\$repo/os/\$arch

EOF

# Pacman Mirrorlist Generator
# https://www.archlinux.org/mirrorlist/

echo 'Обновление баз данных пакетов'
# Update the databases of packages
sudo pacman -Sy        

echo '3.2 Установка основных пакетов (base base-devel)'
# Installing basic packages (base base-devel)
pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim
#pacstrap -i /mnt base base-devel linux linux-firmware nano dhcpcd netctl vim --noconfirm

echo '3.3 Настройка системы, генерируем fstab'
# Configuring the system, generating fstab
genfstab -pU /mnt >> /mnt/etc/fstab

#echo 'Копируем созданный список зеркал (mirrorlist) в /mnt'
#Copying the created list of mirrors (mirrorlist) to /mnt
#cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

echo 'Меняем корень и переходим в нашу недавно скачанную систему'
# Change the root and go to our recently downloaded system
arch-chroot /mnt sh -c "$(curl -fsSL git.io/archmy2)"
