#!/bin/bash
### SHARED VARIABLES AND FUNCTIONS (ОБЩИЕ ПЕРЕМЕННЫЕ И ФУНКЦИИ)
### Shell color codes (Цветовые коды оболочки)
RED="\e[1;31m"; GREEN="\e[1;32m"; YELLOW="\e[1;33m"; GREY="\e[3;93m"
BLUE="\e[1;34m"; CYAN="\e[1;36m"; BOLD="\e[1;37m"; MAGENTA="\e[1;35m"; NC="\e[0m"

# Автоматическое обнаружение ошибок
# Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
set -e

ischroot=0

if [ $ischroot -eq 0 ]
then

# Команды по установке :
# archiso login: root (automatic login)

echo -e "${GREEN}=> ${NC}Make sure that your network interface is specified and enabled" 
#echo 'Make sure that your network interface is specified and enabled'
# Убедитесь, что ваш сетевой интерфейс указан и включен
# Показать все ip адреса и их интерфейсы
ip a
# Смотрим какие у нас есть интернет-интерфейсы
#ip link
# Если наш интерфейс wlan0. В скобках видно, что он UP. Исправляем:
#ip link set wlan0 down
# После этого можно спокойно вызывать wifi-menu и подключатся.
# (для проводных и беспроводных сетевых интерфейсов должны работать "из коробки")
# Также можно посмотреть командой:
#iw dev

# Для беспроводной связи убедитесь, что беспроводная карта не заблокирована с помощью: 
#rfkill 

echo -e "${GREEN}=> ${NC}To check the Internet, you can ping a service" 
#echo 'To check the Internet, you can ping a service'
# Для проверки интернета можно пропинговать какой-либо сервис
ping -c2 archlinux.org
# Например Яндекс или Google: 
#ping -c5 www.google.com
#ping -c5 ya.ru

echo -e "${CYAN}==> ${NC}If the ping goes we go further ..."
#echo 'If the ping goes we go further ...' 
# Если пинг идёт едем дальше ...)

echo -e "${BLUE}:: ${NC}Setting up the Russian language, changing the console font to one that supports Cyrillic for ease of use" 
#echo 'Setting up the Russian language, changing the console font to one that supports Cyrillic for ease of use'
 # Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы
loadkeys ru
#loadkeys us
setfont cyr-sun16
#setfont ter-v16b #pacman -S terminus-font --noconfirm
# ============================================================================
# Чтобы изменить макет, добавьте соответствующее имя файла в loadkeys , пропустив путь и расширение файла. Например, чтобы установить немецкую раскладку клавиатуры:
# loadkeys de-latin1
# Консольные шрифты находятся внутри /usr/share/kbd/consolefonts/и также могут быть установлены с помощью setfont. 
# ============================================================================

echo -e "${CYAN}==> ${NC}Добавим русскую локаль в систему установки"
#echo 'Добавим русскую локаль в систему установки'
# Adding a Russian locale to the installation system
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
#nano /etc/locale.gen
# В файле /etc/locale.gen раскомментируйте (уберите # вначале) строку #ru_RU.UTF-8 UTF-8
echo -e "${BLUE}:: ${NC}Обновим текущую локаль системы"
#echo 'Обновим текущую локаль системы'
# Update the current system locale
locale-gen
# Мы ввели locale-gen для генерации тех самых локалей.

#sleep 01
echo -e "${BLUE}:: ${NC}Указываем язык системы"
#echo 'Указываем язык системы'
# Specify the system language
#echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8
# Эта команда сама пропишет в файлике locale.conf нужные нам параметры.
# Ну и конечно, раз это переменные окружения, то мы можем установить их временно в текущей сессии терминала
# При раскомментировании строки '#export ....', - Будьте Внимательными!
# Как назовёшь, так и поплывёшь...
# When you uncomment the string '#export....', Be Careful!
# As you name it, you will swim...
# ============================================================================

echo -e "${GREEN}
  <<< Начинается установка минимальной системы Arch Linux >>>
${NC}"
#echo 'Начинается установка минимальной системы Arch Linux'
# The installation of the minimum Arch Linux system starts

echo -e "${BLUE}:: ${NC}Установка и настройка начата в $(date +%T)"
#echo "Установка и настройка начата в $(date +%T)"
# Installation and configuration started in $(date +%T)

echo -e "${BLUE}:: ${NC}Синхронизируем наши системные часы, включаем ntp, если надо сменим часовой пояс"
#echo 'Синхронизируем наши системные часы, включаем ntp, если надо сменим часовой пояс'
# Sync our system clock, enable ntp, change the time zone if necessary
# Активации ntp, и проверка статуса
timedatectl set-ntp true

echo -e "${BLUE}:: ${NC}Посмотрим статус службы NTP (NTP service)"
#echo 'Посмотрим статус службы NTP (NTP service)'
# Let's see the NTP service status
timedatectl status

echo -e "${BLUE}:: ${NC}Посмотрим дату и время без характеристик для проверки времени"
#echo 'Посмотрим дату и время без характеристик для проверки времени'
# Let's look at the date and time without characteristics to check the time
date

#echo -e "${YELLOW}==> ${NC}Обновить и добавить новые ключи?"
#echo 'Обновить и добавить новые ключи?'
# Update and add new keys?
#echo " Данный этап поможет вам избежать проблем с ключами Pacmаn, если используете не свежий образ ArchLinux для установки! "
# This step will help you avoid problems with Pacman keys if you are not using a fresh ArchLinux image for installation!
#read -p "1 - Да, 0 - Нет: " x_key
#if [[ $x_key == 1 ]]; then      
#pacman-key --refresh-keys 
#elif [[ $x_key == 0 ]]; then
#  echo 'Обновление ключей пропущено.'

#echo "Обновление баз данных пакетов..."
pacman -Sy --noconfirm

echo -e "${BLUE}:: ${NC}Смотрим, какие диски есть в нашем распоряжении"
#echo 'Давайте посмотрим, какие диски у нас есть в нашем распоряжении'
# Let's see what drives we have at our disposal
lsblk -f

# Ещё раз проверте правильность разбивки на разделы!
echo -e "${BLUE}:: ${NC}Посмотрим структуру диска созданного установщиком"
#echo 'Посмотрим структуру диска созданного установщиком'
# Let's look at the disk structure created by the installer
sgdisk -p /dev/sda

echo -e "${BLUE}:: ${NC}Стираем таблицу разделов на первом диске (sda):"
#echo 'Стираем таблицу разделов на первом диске (sda):'
# Erasing the partition table on the first disk (sda)
sgdisk --zap-all /dev/sda

#echo -e "${BLUE}:: ${NC}Стираем таблицу разделов на втором и третьем диске (sdb, sdc):"
#echo 'Стираем таблицу разделов на втором и третьем диске (sdb, sdc):'
# Erasing the partition table on the second and third disk (sdb, sdc)
#sgdisk --zap-all /dev/sdb
#sgdisk --zap-all /dev/sdc

echo -e "${BLUE}:: ${NC}Создание разделов диска"
#echo 'Создание разделов диска'
# Creating disk partitions

echo ""
echo 'Нужна разметка диска?'
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " cfdisk # sends right after the keypress
    echo ''
    [[ "$cfdisk" =~ [^10] ]]
do
    :
done
 if [[ $cfdisk == 1 ]]; then
   clear
 lsblk -f
  echo ""
  read -p "Укажите диск (sda/sdb например sda или sdb) : " cfd
cfdisk /dev/$cfd
echo ""
clear
elif [[ $cfdisk == 0 ]]; then
   echo ""
   clear
   echo 'разметка пропущена.'   
fi
#
  clear
  lsblk -f
  echo ""
  read -p "Укажите ROOT раздел(sda/sdb 1.2.3.4 (sda5 например)):" root
echo ""
mkfs.ext4 /dev/$root -L root
mount /dev/$root /mnt
echo ""
########## boot  ########
 clear
 lsblk -f
  echo ""
echo 'форматируем BOOT?'
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " boots # sends right after the keypress
    echo ''
    [[ "$boots" =~ [^10] ]]
do
    :
done
 if [[ $boots == 1 ]]; then
  read -p "Укажите BOOT раздел(sda/sdb 1.2.3.4 (sda7 например)):" bootd
  mkfs.fat -F32 /dev/$bootd
  mkdir /mnt/boot
  mount /dev/$bootd /mnt/boot
  elif [[ $boots == 0 ]]; then
 read -p "Укажите BOOT раздел(sda/sdb 1.2.3.4 (sda7 например)):" bootd 
 mkdir /mnt/boot
mount /dev/$bootd /mnt/boot
fi
############ swap   ####################################################
 clear
 lsblk -f
  echo ""
echo 'добавим swap раздел?'
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " swap # sends right after the keypress
    echo ''
    [[ "$swap" =~ [^10] ]]
do
    :
done
 if [[ $swap == 1 ]]; then
  read -p "Укажите swap раздел(sda/sdb 1.2.3.4 (sda7 например)):" swaps
  mkswap /dev/$swaps -L swap
  swapon /dev/$swaps
  elif [[ $swap == 0 ]]; then
   echo 'добавление swap раздела пропущено.'   
fi
################  home     ############################################################ 
clear
echo ""
echo " Можно использовать раздел от предыдущей системы( и его не форматировать )  
далее в процессе установки можно будет удалить все скрытые файлы и папки в каталоге 
пользователя"
echo ""
echo 'Добавим раздел  HOME ?'
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " homes # sends right after the keypress
    echo ''
    [[ "$homes" =~ [^10] ]]
do
    :
done
   if [[ $homes == 0 ]]; then
     echo 'пропущено'
  elif [[ $homes == 1 ]]; then
    echo ' Форматируем HOME раздел?'
while 
    read -n1 -p  "
    1 - да
    
    0 - нет: " homeF # sends right after the keypress
    echo ''
    [[ "$homeF" =~ [^10] ]]
do
    :
done
   if [[ $homeF == 1 ]]; then
   echo ""
   lsblk -f
   read -p "Укажите HOME раздел(sda/sdb 1.2.3.4 (sda6 например)):" home
   mkfs.ext4 /dev/$home -L home
   mkdir /mnt/home 
   mount /dev/$home /mnt/home
   elif [[ $homeF == 0 ]]; then
 lsblk -f
 read -p "Укажите HOME раздел(sda/sdb 1.2.3.4 (sda6 например)):" homeV
 mkdir /mnt/home 
 mount /dev/$homeV /mnt/home
fi
fi
##################################################################################

sfdisk /dev/sda < create.disks
  
echo -e "${BLUE}:: ${NC}Ваша разметка диска" 
#echo 'Ваша разметка диска'
# Your disk markup
# Команда fdisk –l выведет список существующих разделов, если таковые существуют
fdisk /dev/sda
fdisk -l

echo -e "${BLUE}:: ${NC}Форматирование разделов диска"
#echo 'Форматирование разделов диска'
# Formatting disk partitions
echo -e "${BLUE}:: ${NC}Установка название флага boot,root,swap,home"
#echo 'Установка название флага boot,root,swap,home'
# Setting the flag name boot, root,swap, home
mkfs.ext2  /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4  /dev/sda3 -L root
mkfs.ext4  /dev/sda4 -L home
# Просмотреть все идентификаторы наших разделов можно командой:
#blkid

echo -e "${BLUE}:: ${NC}Монтирование разделов диска"
#echo 'Монтирование разделов диска'
# Mounting disk partitions
mount /dev/sda3 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda4 /mnt/home
# Посмотреть что мы намонтировали можно командой:
#mount | grep sda    
# - покажет куда был примонтирован sda
# Посмотрим информацию командой:
#free -h

### Замена исходного mirrorlist (зеркал для загрузки) на мой список серверов-зеркал
#echo '3.1 Замена исходного mirrorlist (зеркал для загрузки)'
#Ставим зеркало от Яндекс
# Удалим старый файл /etc/pacman.d/mirrorlist
#rm -rf /etc/pacman.d/mirrorlist
# Загрузка нового файла mirrorlis (список серверов-зеркал)
#wget https://raw.githubusercontent.com/MarcMilany/arch_2020/master/Mirrorlist/mirrorlist
# Переместим нового файла mirrorlist в /etc/pacman.d/mirrorlist
#mv -f ~/mirrorlist /etc/pacman.d/mirrorlist
#echo "Обновление баз данных пакетов..."
#sudo pacman -Sy
# -------------------------------------------------------------------------

echo -e "${BLUE}:: ${NC}Выбор серверов-зеркал для загрузки. Ставим зеркало от Яндекс"
#echo 'Выбор серверов-зеркал для загрузки. Ставим зеркало от Яндекс'
# The choice of mirror sites to download. Putting a mirror from Yandex
#echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
> /etc/pacman.d/mirrorlist
cat <<EOF >>/etc/pacman.d/mirrorlist

##
## Arch Linux repository mirrorlist
## Generated on 2020-07-03
## HTTP IPv4 HTTPS
##

## Russia
Server = https://mirror.rol.ru/archlinux/\$repo/os/\$arch
Server = https://mirror.yandex.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.rol.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.truenetwork.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch
#Server = http://archlinux.zepto.cloud/\$repo/os/\$arch

##
## Arch Linux repository mirrorlist
## Generated on 2020-07-03
## HTTP IPv6 HTTPS
##

## Russia
#Server = http://mirror.yandex.ru/archlinux/$repo/os/\$arch
#Server = https://mirror.yandex.ru/archlinux/$repo/os/\$arch
#Server = http://archlinux.zepto.cloud/$repo/os/\$arch

EOF

echo -e "${BLUE}:: ${NC}Создание (backup) резервного списка зеркал mirrorlist - (mirrorlist.backup)"
#echo 'Создание (backup) резервного списка зеркал mirrorlist - (mirrorlist.backup)'
# Creating a backup list of mirrors mirrorlist - (mirrorlist.backup)
cp -vf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

echo -e "${BLUE}:: ${NC}Посмотреть список серверов-зеркал для загрузки в mirrorlist"
#echo 'Посмотреть список серверов-зеркал для загрузки в mirrorlist'
# View the list of mirror servers to upload to mirrorlist
cat /etc/pacman.d/mirrorlist

echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов" 
#echo 'Обновим базы данных пакетов'
# Updating the package databases
#sudo pacman-key --init
#sudo pacman-key --populate archlinux
#sudo pacman-key --refresh-keys
sudo pacman -Sy 

# ============================================================================
# Знакомьтесь, pacman - лучший пакетный менеджер в мире линукса!
#pacman -Syy   - обновление баз пакмэна(как apt-get update в дэбианоподбных)
#pacman -Syyu  - обновление баз плюс обновление пакетов
# ----------------------------------------------------------------------------
# Если возникли проблемы с обновлением, или установкой пакетов 
# Выполните данные рекомендации:
#echo 'Обновление ключей системы'
# Updating of keys of a system
#echo "Создаётся генерация мастер-ключа (брелка) pacman, введите пароль (не отображается)..."
#sudo pacman-key --init
#echo "Далее идёт поиск ключей..."
#sudo pacman-key --populate archlinux
#echo "Обновление ключей..."
#sudo pacman-key --refresh-keys
#echo "Обновление баз данных пакетов..."
#sudo pacman -Sy
# Или:
#sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman-key --refresh-keys && sudo pacman -Sy

echo -e "${BLUE}:: ${NC}Установка основных пакетов (base base-devel)"
#echo 'Установка основных пакетов (base base-devel)'
# Installing basic packages (base base-devel)
echo 'Arch Linux, Base devel (AUR only), Kernel (optional), Firmware'
# Arch Linux, Base devel (AUR only), Kernel (optional), Firmware
pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim which inetutils  # parted
#pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim # parted
#pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim --noconfirm  # parted 
#pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim --noconfirm --noprogressbar --quiet
#pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl vim
#pacstrap /mnt base base-devel linux-hardened linux-firmware nano dhcpcd netctl vim
#pacstrap /mnt base base-devel linux-zen linux-firmware nano dhcpcd netctl vim

echo -e "${BLUE}:: ${NC}Настройка системы, генерируем fstab"
#echo 'Настройка системы, генерируем fstab'
# Configuring the system, generating fstab
genfstab -pU /mnt >> /mnt/etc/fstab
#(или genfstab -L /mnt >> /mnt/etc/fstab)
#genfstab -p -L /mnt > /mnt/etc/fstab
# Нашёл ещё две команды для генерации fstab при установке:
#genfstab -U -p /mnt >> /mnt/etc/fstab
#genfstab /mnt >> /mnt/etc/fstab

echo -e "${BLUE}:: ${NC}Просмотреть содержимое файла fstab"
#echo 'Просмотреть содержимое файла fstab'
# View the contents of the fstab file
cat /mnt/etc/fstab

echo -e "${BLUE}:: ${NC}Удалим старый файл mirrorlist из /mnt/etc/pacman.d/mirrorlist"
#echo 'Удалим старый файл mirrorlist из /mnt/etc/pacman.d/mirrorlist'
# Delete files /etc/pacman.d/mirrorlist
# Удалим mirrorlist из /mnt/etc/pacman.d/mirrorlist
rm /mnt/etc/pacman.d/mirrorlist 
#rm -rf /mnt/etc/pacman.d/mirrorlist
#Удалите файл /etc/pacman.d/mirrorlist
#rm -rf /etc/pacman.d/mirrorlist
# Удаления старой резервной копии (если она есть, если нет, то пропустите этот шаг):
#rm /etc/pacman.d/mirrorlist.old

echo -e "${BLUE}:: ${NC}Загрузка свежего списка зеркал со страницы Mirror Status, и обновляем mirrorlist"
#echo 'Загрузка свежего списка зеркал со страницы Mirror Status, и обновляем mirrorlist'
# Loading a fresh list of mirrors from the Mirror Status page, and updating the mirrorlist
# Чтобы увидеть список всех доступных опций, наберите:
#reflector --help
# Команда отфильтрует пять зеркал, отсортирует их по скорости и обновит файл mirrorlist:
#sudo pacman -Sy --noconfirm --noprogressbar --quiet reflector
reflector --verbose --country 'Russia' -l 7 -p https -p http -n 7 --save /etc/pacman.d/mirrorlist --sort rate  
#reflector --verbose --country 'Russia' -l 5 -p https -p http -n 5 --sort rate --save /etc/pacman.d/mirrorlist

echo -e "${BLUE}:: ${NC}Копируем созданный список зеркал (mirrorlist) в /mnt"
#echo 'Копируем созданный список зеркал (mirrorlist) в /mnt'
# Copying the created list of mirrors (mirrorlist) to /mnt
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

echo -e "${BLUE}:: ${NC}Копируем резервного списка зеркал (mirrorlist.backup) в /mnt"
#echo 'Копируем резервного списка зеркал (mirrorlist.backup) в /mnt'
# Copying the backup list of mirrors (mirrorlist.backup) in /mnt
cp /etc/pacman.d/mirrorlist.backup /mnt/etc/pacman.d/mirrorlist.backup

echo -e "${BLUE}:: ${NC}Посмотреть список серверов-зеркал /mnt/etc/pacman.d/mirrorlist"
#echo 'Посмотреть список серверов-зеркал /mnt/etc/pacman.d/mirrorlist'
# View the list of mirror servers /mnt/etc/pacman.d/mirrorlist
cat /mnt/etc/pacman.d/mirrorlist

echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов" 
#echo 'Обновим базы данных пакетов'
# Updating the package databases
#sudo pacman-key --init
#sudo pacman-key --refresh-keys
sudo pacman -Sy 

echo -e "${GREEN}=> ${BOLD}Создадим конфигурационный файл для установки системных переменных /etc/sysctl.conf ${NC}"
#echo 'Создадим конфигурационный файл для установки системных переменных /etc/sysctl.conf'
# Creating a configuration file for setting system variables /etc/sysctl.conf
> /mnt/etc/sysctl.conf
cat <<EOF >>/mnt/etc/sysctl.conf

#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#

#kernel.domainname = example.com

# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
# See http://lwn.net/Articles/277146/
# Note: This may impact IPv6 TCP sessions too
net.ipv4.tcp_syncookies=1

# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
#net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#
net.ipv4.tcp_timestamps=0
net.ipv4.conf.all.rp_filter=1
net.ipv4.tcp_max_syn_backlog=1280
kernel.core_uses_pid=1
#
vm.swappiness=10

EOF

###*******************************************************************

echo " Первый этап установки Arch'a закончен "
echo -e "${GREEN}=> ${BOLD}Запускаем пользовательский пост-инстал-скрипт (install_arch.sh) для установки первоначально необходимого софта (пакетов), запуск необходимых служб, запись данных в конфиги (hhh.conf) по настройке системы. ${NC}"
#echo 'Запускаем пользовательский пост-инстал-скрипт (install_arch.sh) для установки первоначально необходимого софта (пакетов), запуск необходимых служб, запись данных в конфиги (hhh.conf) по настройке системы.'
# Launch a custom post-installation script (install_arch.sh) to install the initially necessary software (packages), launch the necessary services, write data to configs (hhh.conf) for system configuration.
#post-install-script (install_arch.sh)
sed -i 's/ischroot=0/ischroot=1/' ./install_arch.sh
cp ./install_arch.sh /mnt/install_arch.sh

arch-chroot /mnt /bin/bash -x << _EOF_
sh /install_arch.sh
_EOF_

fi

if [ $ischroot -eq 1 ]
then

echo -e "${BLUE}:: ${NC}Обновим вашу систему (базу данных пакетов)"
#echo "Обновим вашу систему (базу данных пакетов)"
# Update your system (package database)
echo -e "${YELLOW}:: ${NC}Загружаем базу данных пакетов независимо от того, есть ли какие-либо изменения в версиях или нет."
#echo 'Загружаем базу данных пакетов независимо от того, есть ли какие-либо изменения в версиях или нет.'
# Loading the package database regardless of whether there are any changes in the versions or not.
pacman -Syyu  --noconfirm
# Полный апдейт системы:
#pacman -Syyuu  --noconfirm
# Не рекомендуется использовать sudo pacman -Syyu всё время!
# ============================================================================
# Знакомьтесь, pacman - лучший пакетный менеджер в мире линукса!
#pacman -Syy   - обновление баз пакмэна(как apt-get update в дэбианоподбных)
#pacman -Syyu  - обновление баз плюс обновление пакетов
# 

echo -e "${BLUE}:: ${NC}Прописываем имя компьютера"
#echo 'Прописываем имя компьютера'
# Entering the computer name
#echo $hostname > /etc/hostname
echo Terminator > /etc/hostname
#echo "имя_компьютера" > /etc/hostname
#echo HostName > /etc/hostname

echo -e "${BLUE}:: ${NC}Устанавливаем ваш часовой пояс"
#echo 'Устанавливаем ваш часовой пояс'
# Setting your time zone
#rm -v /etc/localtime
#ln -s /usr/share/zoneinfo/Europe/Moscow
#ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ls /usr/share/zoneinfo
#ls /usr/share/zoneinfo/Europe
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#timedatectl set-ntp true
#ln -svf /usr/share/zoneinfo/$timezone /etc/localtime
#ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -svf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
#ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
#read -p "Ведите свою таймзону в формате Example/Example: " timezone

echo -e "${BLUE}:: ${NC}Синхронизация системных часов" 
#echo 'Синхронизация системных часов'
# Syncing the system clock
#echo 'Синхронизируем наши системные часы, включаем ntp, если надо сменим часовой пояс'
# Sync our system clock, enable ntp, change the time zone if necessary
timedatectl set-ntp true

echo -e "${BLUE}:: ${NC}Проверим аппаратное время"
#echo 'Проверим аппаратное время' 
# Check the hardware time
#hwclock
hwclock --systohc

echo -e "${BLUE}:: ${NC}Посмотрим текущее состояние аппаратных и программных часов"
#echo 'Посмотрим текущее состояние аппаратных и программных часов'
# Let's see the current state of the hardware and software clock
timedatectl

echo -e "${BLUE}:: ${NC}Настроим состояние аппаратных и программных часов"
#echo 'Настроим состояние аппаратных и программных часов'
# Setting up the state of the hardware and software clock 
#echo 'Вы можете пропустить этот шаг, если не уверены в правильности выбора'   
hwclock --systohc --utc
##hwclock --systohc --local

echo -e "${BLUE}:: ${NC}Посмотрим обновление времени (если настройка не была пропущена)"
#echo 'Посмотрим обновление времени (если настройка не была пропущена)'
# See the time update (if the setting was not skipped)
timedatectl show
#timedatectl | grep Time

echo -e "${BLUE}:: ${NC}Изменяем имя хоста"
#echo 'Изменяем имя хоста'
# Changing the host name
echo "127.0.0.1 localhost.(none)" > /etc/hosts
echo "127.0.1.1 $hostname" >> /etc/hosts
echo "::1 localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts
#echo "127.0.1.1 имя_компьютера" >> /etc/hosts
# - Можно написать с Заглавной буквы.
# Это дейсвие не обязательно! Мы можем это сделаем из установленной ситемы, если данные не пропишутся автоматом.

echo -e "${BLUE}:: ${NC}Добавляем русскую локаль системы"
#echo 'Добавляем русскую локаль системы'
# Adding the system's Russian locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
# Есть ещё команды по добавлению русскую локаль в систему:
#echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
# Можно раскомментирвать нужные локали (и убирать #)
#sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
#sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

echo -e "${BLUE}:: ${NC}Обновим текущую локаль системы"
#echo 'Обновим текущую локаль системы'
# Update the current system locale
locale-gen
# Мы ввели locale-gen для генерации тех самых локалей.

sleep 02
echo -e "${BLUE}:: ${NC}Указываем язык системы"
#echo 'Указываем язык системы'
# Specify the system language
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
#echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
#export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8
# Эта команда сама пропишет в файлике locale.conf нужные нам параметры.

echo -e "${BLUE}:: ${NC}Вписываем KEYMAP=ru FONT=cyr-sun16"
#echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
# Enter KEYMAP=ru FONT=cyr-sun16
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
echo 'FONT_MAP=' >> /etc/vconsole.conf
echo 'CONSOLEMAP' >> /etc/vconsole.conf
echo 'COMPRESSION="lz4"' >> /etc/mkinitcpio.conf

echo -e "${BLUE}:: ${NC}Создадим загрузочный RAM диск (начальный RAM-диск)"
#echo 'Создадим загрузочный RAM диск (начальный RAM-диск)'
# Creating a bootable RAM disk (initial RAM disk)
mkinitcpio -p linux-lts
#mkinitcpio -p linux
#mkinitcpio -P linux
#mkinitcpio -p linux-zen
#echo 'COMPRESSION="lz4"' >> /etc/mkinitcpio.conf

#echo -e "${GREEN}==> ${NC}Создаём root пароль"
#echo 'Создаём root пароль'
# Creating a root password
#passwd

echo -e "${BLUE}:: ${NC}Устанавливаем загрузчик (grub)"
#echo 'Устанавливаем загрузчик (grub)'
# Install the boot loader (grub)
pacman -Syy
pacman -S grub --noconfirm 
#pacman -S grub --noconfirm --noprogressbar --quiet  
grub-install /dev/sda
#grub-install --recheck /dev/sda
#grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

echo -e "${GREEN}==> ${NC}Установить Микрокод для процессора INTEL_CPU, AMD_CPU?"
#echo 'Установить Микрокод для процессора INTEL_CPU, AMD_CPU?'
# Install the Microcode for the CPU INTEL_CPU, AMD_CPU?
#echo 'Вы можете пропустить этот шаг, если не уверены в правильности выбора'
# Если у Вас процессор Intel, то:
#pacman -S intel-ucode
pacman -S intel-ucode --noconfirm
# Если у Вас процессор AMD, то:
#pacman -S amd-ucode
#pacman -S amd-ucode --noconfirm

echo -e "${BLUE}:: ${NC}Обновляем grub.cfg (Сгенерируем grub.cfg)"
#echo 'Обновляем grub.cfg (Сгенерируем grub.cfg)'
# Updating grub.cfg (Generating grub.cfg)
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "${YELLOW}==> ${NC}Если в системе будут несколько ОС, то это также ставим"
#echo 'Если в системе будут несколько ОС, то это также ставим'
# If the system will have several operating systems, then this is also set
#pacman -S os-prober mtools fuse
pacman -S os-prober mtools fuse --noconfirm

echo -e "${BLUE}:: ${NC}Ставим программу для Wi-fi"
#echo 'Ставим программу для Wi-fi'
# Install the program for Wi-fi
pacman -S dialog wpa_supplicant iw wireless_tools net-tools --noconfirm

echo -e "${BLUE}:: ${NC}Добавляем пользователя и прописываем права, группы"
#echo 'Добавляем пользователя и прописываем права, группы'
# Adding a user and prescribing rights, groups
#useradd -m -g users -G wheel -s /bin/bash $username
useradd -m -g users -G adm,audio,games,lp,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash alex

#echo -e "${GREEN}==> ${NC}Устанавливаем пароль пользователя"
#echo 'Устанавливаем пароль пользователя'
# Setting the user password
# passwd $username 
#passwd alex

echo -e "${BLUE}:: ${NC}Устанавливаем SUDO"
#echo 'Устанавливаем SUDO'
# Installing SUDO
pacman -S sudo --noconfirm
#echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
#sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo -e "${BLUE}:: ${NC}Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе"
#echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
# Uncomment the multilib repository For running 32-bit applications on a 64-bit system
#echo 'Color = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
#echo '[multilib]' >> /etc/pacman.conf
#echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
#pacman -Syy --noconfirm --noprogressbar --quiet
# Синхронизация и обновление пакетов (-yy принудительно обновить даже если обновленные)
echo 'Multilib репозиторий добавлен'

echo -e "${BLUE}:: ${NC}Ставим иксы и драйвера"
#echo 'Ставим иксы и драйвера'
# Put the x's and drivers
pacman -S xorg-server xorg-drivers xorg-xinit   # virtualbox-guest-utils --noconfirm 
#pacman -S xorg-server xorg-drivers xorg-xinit mesa xorg-apps xorg-twm xterm xorg-xclock xf86-input-synaptics virtualbox-guest-utils --noconfirm  #linux-headers
#pacman -S xorg-server xorg-drivers xorg-apps xorg-xinit mesa xorg-twm xterm xorg-xclock xf86-input-synaptics virtualbox-guest-utils  #linux-headers
#

#echo "Какая видеокарта?"
#read -p "1 - nvidia, 2 - Amd, 3 - intel: " videocard
#if [[ $videocard == 1 ]]; then
#  pacman -S nvidia lib32-nvidia-utils nvidia-settings --noconfirm
#  nvidia-xconfig
#elif [[ $videocard == 2 ]]; then
#  pacman -S lib32-mesa xf86-video-amdgpu mesa-vdpau lib32-mesa-vdpau vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver --noconfirm
#elif [[ $videocard == 3 ]]; then
#  pacman -S lib32-mesa vulkan-intel libva-intel-driver lib32-libva-intel-driver lib32-vulkan-intel --noconfirm
#fi

#echo 'Ставим драйвера видеокарты intel'
#sudo pacman -S xf86-video-intel vdpauinfo libva-utils libva-intel-driver libva lib32-libva-intel-driver libvdpau libvdpau-va-gl lib32-libvdpau --noconfirm

#-------------------------------------------------------------------------------
# Видео драйверы, без них тоже ничего работать не будет вот список:
# xf86-video-vesa - как я понял, это универсальный драйвер для ксорга (xorg), должен работать при любых обстоятельствах, но вы знаете как, только для того чтобы поставить подходящий.
# xf86-video-ati - свободный ATI
# xf86-video-intel - свободный Intel
# xf86-video-nouveau - свободный Nvidia
# Существуют также проприетарные драйверы, то есть разработаны самой Nvidia или AMD, но они часто не поддерживают новое ядро, или ещё какие-нибудь траблы.
# virtualbox-guest-utils - для виртуалбокса, активируем коммандой:
#systemctl enable vboxservice - вводим дважды пароль
#

#echo -e "${BLUE}:: ${NC}Установка гостевых дополнений vbox"
#echo 'Установка гостевых дополнений vbox'
#Install the Guest Additions vbox
#modprobe -a vboxguest vboxsf vboxvideo
#cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
#echo -e "\nvboxguest\nvboxsf\nvboxvideo" >> /home/$username/.xinitrc
#sed -i 's/#!\/bin\/sh/#!\/bin\/sh\n\/usr\/bin\/VBoxClient-all/' /home/$username/.xinitrc

echo -e "${BLUE}:: ${NC}Ставим DE (от англ. desktop environment — среда рабочего стола) Xfce"
#echo 'Ставим DE (от англ. desktop environment — среда рабочего стола) Xfce'
# Put DE (from the English desktop environment-desktop environment) Xfce
pacman -S xfce4 xfce4-goodies --noconfirm
#pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xinitrc /home/alex/.xinitrc
chown $username:users /home/alex/.xinitrc
chmod +x /home/alex/.xinitrc
sed -i 52,55d /home/alex/.xinitrc
echo "exec startxfce4 " >> /home/alex/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin alex --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile
echo " DE (среда рабочего стола) Xfce успешно установлено "

echo -e "${BLUE}:: ${NC}Ставим DM (Display manager) менеджера входа"
#echo 'Ставим DM (Display manager) менеджера входа'
# Install the DM (Display manager) of the login Manager
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfir
echo " Установка DM (менеджера входа) завершена "

echo -e "${BLUE}:: ${NC}Ставим сетевые утилиты Networkmanager"
#echo 'Ставим сетевые утилиты "Networkmanager"'
# Put the network utilities "Networkmanager"
pacman -S networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm
# networkmanager - сервис для работы интернета. Вместе с собой устанавливает программы для настройки.
# Если вам нужна поддержка OpenVPN в Network Manager, то выполните команду:
#sudo pacman -S networkmanager-openvpn

echo -e "${BLUE}:: ${NC}Ставим шрифты"
#echo 'Ставим шрифты'
# Put the fonts
pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-arphic-ukai ttf-arphic-uming ttf-hanazono --noconfirm 
pacman -S ttf-fireflysung ttf-sazanami --noconfirm  #китайские иероглифы 

echo -e "${BLUE}:: ${NC}Подключаем автозагрузку менеджера входа и интернет"
#echo 'Подключаем автозагрузку менеджера входа и интернет'
# Enabling auto-upload of the login Manager and the Internet
systemctl enable lightdm.service
sleep 1 
systemctl enable NetworkManager
systemctl enable dhcpcd

echo -e "${BLUE}:: ${NC}Монтировании разделов NTFS и создание ссылок"
#echo 'Монтировании разделов NTFS и создание ссылок'
# NTFS support (optional)
sudo pacman -S ntfs-3g --noconfirm

echo -e "${BLUE}:: ${NC}Создаём нужные директории"
#echo 'Создаём нужные директории'
# Creating the necessary directories
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update 

echo -e "${BLUE}:: ${NC}Установка базовых программ и пакетов"
#echo 'Установка базовых программ и пакетов'
# Installing basic programs and packages
sudo pacman -S wget --noconfirm

#read -p "Введите допольнительные пакеты которые вы хотите установить: " packages 
#pacman -S $packages --noconfirm

echo -e "${GREEN}
  <<< Поздравляем! Установка завершена. Перезагрузите систему. >>> ${NC}"
#echo 'Поздравляем! Установка завершена. Перезагрузите систему.'
# Congratulations! Installation is complete. Reboot the system.

echo -e "${BLUE}:: ${BOLD}Посмотрим дату и время ... ${NC}"
#echo 'Посмотрим дату и время'
# Let's look at the date and time
date

echo -e "${BLUE}:: ${BOLD}Отобразить время работы системы ... ${NC}"
#echo 'Отобразить время работы системы'
# Display the system's operating time 
uptime

echo -e "${MAGENTA}==> ${BOLD}После перезагрузки и входа в систему проверьте ваши персональные настройки. ${NC}"
#echo 'После перезагрузки и входа в систему проверьте ваши персональные настройки.'
# After restarting and logging in, check your personal settings.

echo -e "${MAGENTA}==> ${BOLD}Если у Вас беспроводное соединение, запустите nmtui и подключитесь к сети. ${NC}"
#echo 'Если у Вас беспроводное соединение, запустите nmtui и подключитесь к сети.'
# If you have a wireless connection, launch nmtui and connect to the network.

echo -e "${YELLOW}==> ...${NC}"
echo -e "${BLUE}:: ${NC}Если хотите подключить AUR, установить дополнительный софт (пакеты), установить мои конфиги XFCE, тогда после перезагрузки и входа в систему выполните команду:"
#echo 'Если хотите подключить AUR, установить дополнительный софт (пакеты), установить мои конфиги XFCE, тогда после перезагрузки и входа в систему выполните команду:'
# If you want to connect AUR, install additional software (packages), install my Xfce configs, then after restarting and logging in, run the command:
echo -e "${YELLOW}==> ${CYAN}wget git.io/archmy3 && sh archmy3 ${NC}"

echo -e "${RED}==> ${BOLD}Выходим из установленной системы ${NC}"
#echo 'Выходим из установленной системы'
# Exiting the installed system
echo -e "${BLUE}:: ${BOLD}Теперь вам надо ввести reboot, чтобы перезагрузиться ${NC}"
#echo 'Теперь вам надо ввести reboot, чтобы перезагрузиться'
#'Now you need to enter 'reboot' to reboot"'

echo -e "${BLUE}:: ${BOLD}После перезагрузки заходим под пользователем ${NC}"
#echo 'После перезагрузки заходим под пользователем'
#Перезагрузка.После перезагрузки заходим под пользователем
#exit

fi

arch-chroot /mnt /bin/bash -x << _EOF_
passwd
t@@r00
t@@r00
_EOF_

arch-chroot /mnt /bin/bash -x << _EOF_
passwd alex
555
555
_EOF_

umount -R /mnt/boot
umount -R /mnt
reboot

