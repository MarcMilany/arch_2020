#!/bin/bash
# Автоматическое обнаружение ошибок
# Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
set -e

# Команды по установке :
# archiso login: root (automatic login)

echo 'Make sure that your network interface is specified and enabled'
# Убедитесь, что ваш сетевой интерфейс указан и включен
# Показать все ip адреса и их интерфейсы
ip a

echo 'To check the Internet, you can ping a service'
# Для проверки интернета можно пропинговать какой-либо сервис
ping -c2 archlinux.org

echo -e "${CYAN}==> ${NC}If the ping goes we go further ..."
#echo 'If the ping goes we go further ...' 
# Если пинг идёт едем дальше ...)

echo 'Setting up the Russian language, changing the console font to one that supports Cyrillic for ease of use'
 # Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы
loadkeys ru
setfont cyr-sun16

echo 'Добавим русскую локаль в систему установки'
# Adding a Russian locale to the installation system
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

echo 'Обновим текущую локаль системы'
# Update the current system locale
locale-gen
# Мы ввели locale-gen для генерации тех самых локалей.

#sleep 01
echo 'Указываем язык системы'
# Specify the system language
#echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8
# Эта команда сама пропишет в файлике locale.conf нужные нам параметры

echo 'Начинается установка минимальной системы Arch Linux'
# The installation of the minimum Arch Linux system starts

echo "Установка и настройка начата в $(date +%T)"
# Installation and configuration started in $(date +%T)

echo 'Синхронизируем наши системные часы, включаем ntp, если надо сменим часовой пояс'
# Sync our system clock, enable ntp, change the time zone if necessary
# Активации ntp, и проверка статуса
timedatectl set-ntp true

echo 'Посмотрим статус службы NTP (NTP service)'
# Let's see the NTP service status
timedatectl status

echo 'Посмотрим дату и время без характеристик для проверки времени'
# Let's look at the date and time without characteristics to check the time
date

echo 'Давайте посмотрим, какие диски у нас есть в нашем распоряжении'
# Let's see what drives we have at our disposal
lsblk -f

echo 'Посмотрим структуру диска созданного установщиком'
# Let's look at the disk structure created by the installer
sgdisk -p /dev/sda

echo 'Стираем таблицу разделов на первом диске (sda):'
# Erasing the partition table on the first disk (sda)
sgdisk --zap-all /dev/sda

#echo 'Стираем таблицу разделов на втором и третьем диске (sdb, sdc):'
# Erasing the partition table on the second and third disk (sdb, sdc)
#sgdisk --zap-all /dev/sdb
#sgdisk --zap-all /dev/sdc

echo 'Создание разделов диска'
# Creating disk partitions
# Можно вызвать подсказки нажатием на клавишу “m”
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
# Команда fdisk –l выведет список существующих разделов, если таковые существуют
fdisk -l

# Для просмотра разделов одного выбранного диска используйте такой вариант этой же команды:
#fdisk -l /dev/sda

###         "Справка команд по работе с утилитой fdisk"
# ============================================================================
# Команда (m для справки): m
# Справка:

#  Работа с разбиением диска в стиле DOS (MBR)
#   a   переключение флага загрузки
#   b   редактирование вложенной метки диска BSD
#   c   переключение флага dos-совместимости 

#  Общие
#   d   удалить раздел
#   F   показать свободное неразмеченное пространство
#   l   список известных типов разделов
#   n   добавление нового раздела
#   p   вывести таблицу разделов
#   t   изменение метки типа раздела
#   v   проверка таблицы разделов
#   i   вывести информацию о разделе

#  Разное
#   m   вывод этого меню
#   u   изменение единиц измерения экрана/содержимого
#   x   дополнительная функциональность (только для экспертов)

#  Сценарий
#   I   загрузить разметку из файла сценария sfdisk
#   O   записать разметку в файл сценария sfdisk

#  Записать и выйти
#   w   запись таблицы разделов на диск и выход
#   q   выход без сохранения изменений

#  Создать новую метку
#   g   создание новой пустой таблицы разделов GPT
#   G   создание новой пустой таблицы разделов SGI (IRIX)
#   o   создание новой пустой таблицы разделов DOS
#   s   создание новой пустой таблицы разделов Sun
# ---------------------------------------------------------------------------
### https://linux-faq.ru/page/komanda-fdisk
### https://www.altlinux.org/Fdisk
# ============================================================================

echo 'Форматирование разделов диска'
# Formatting disk partitions
echo 'Установка название флага boot,root,swap,home'
# Setting the flag name boot, root,swap, home
mkfs.ext2  /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4  /dev/sda3 -L root
mkfs.ext4  /dev/sda4 -L home
# Просмотреть все идентификаторы наших разделов можно командой:
#blkid
# ---------------------------------------------------------------------------
# Или так:
#echo 'Disk formatting'
#(
#  echo y;
#) | mkfs.ext2  /dev/sda1 -L boot

#(
#  echo y;
#) | mkswap /dev/sda2 -L swap

#(
#  echo y;
#) | mkfs.ext4  /dev/sda3 -L root

#(
#  echo y;
#) | mkfs.ext4  /dev/sda4 -L home

# ============================================================================

echo '2.4.3 Монтирование разделов диска'
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

# ============================================================================
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
# -----------------------------------------------------------------------------

#echo '3.1 Выбор серверов-зеркал для загрузки. Ставим зеркало от Яндекс'
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

# ============================================================================

echo 'Создание (backup) резервного списка зеркал mirrorlist - (mirrorlist.backup)'
# Creating a backup list of mirrors mirrorlist - (mirrorlist.backup)
cp -vf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

echo 'Посмотреть список серверов-зеркал для загрузки в mirrorlist'
# View the list of mirror servers to upload to mirrorlist
cat /etc/pacman.d/mirrorlist

echo 'Обновим базы данных пакетов'
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
# ============================================================================

echo '3.2 Установка основных пакетов (base base-devel)'
# Installing basic packages (base base-devel)
echo 'Arch Linux, Base devel (AUR only), Kernel (optional), Firmware'
# Arch Linux, Base devel (AUR only), Kernel (optional), Firmware
pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim # parted
#pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim --noconfirm --noprogressbar --quiet
#pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl vim
#pacstrap /mnt base base-devel linux-hardened linux-firmware nano dhcpcd netctl vim
#pacstrap /mnt base base-devel linux-zen linux-firmware nano dhcpcd netctl vim
# ----------------------------------------------------------------------------
#pacstrap /mnt base base-devel linux-zen linux-firmware nano dhcpcd netctl zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting git ccache btrfs-progs wget terminus-font
# ----------------------------------------------------------------------------
#pacstrap -i /mnt base base-devel linux linux-firmware nano dhcpcd netctl vim --noconfirm
# Параметр-I обеспечивает побуждение перед установкой пакета
# The -i switch ensures prompting before package installation
#pacstrap /mnt linux base nano dhcpcd netctl sudo wget --noconfirm --noprogressbar --quiet
#pacstrap /mnt base base-devel linux linux-headers linux-firmware lvm2 nano networkmanager bash-completion reflector htop openssh curl wget git rsync unzip unrar p7zip gnu-netcat pv
# ----------------------------------------------------------------------------
# base - основные программы.
# linux - ядро.
# linux-firmware - файлы прошивок для linux.
# base-devel - утилиты для разработчиков. Нужны для AUR.
# man-db - просмотрщик man-страниц.
# man-pages - куча man-страниц (руководств).
# nano - простой консольный текстовый редактор. Если умете работать в vim, то можете поставить его вместо nano.
# sudo - позволяет обычным пользователем совершать действия от лица суперпользователя.
# git - приложение для работы с репозиториями Git. Нужен для AUR и много чего ещё.
# networkmanager - сервис для работы интернета. Вместе с собой устанавливает программы для настройки.
# grub - загрузчик операционной системы. Без него даже загрузиться в новую систему не сможем.
# efibootmgr - поможет grub установить себя в загрузку UEFI.
# ============================================================================

echo '3.3 Настройка системы, генерируем fstab'
# Configuring the system, generating fstab
genfstab -pU /mnt >> /mnt/etc/fstab
#(или genfstab -L /mnt >> /mnt/etc/fstab)
#genfstab -p -L /mnt > /mnt/etc/fstab
# Нашёл ещё две команды для генерации fstab при установке:
#genfstab -U -p /mnt >> /mnt/etc/fstab
#genfstab /mnt >> /mnt/etc/fstab

echo 'Просмотреть содержимое файла fstab'
# View the contents of the fstab file
cat /mnt/etc/fstab

echo 'Удалим старый файл mirrorlist из /mnt/etc/pacman.d/mirrorlist'
# Delete files /etc/pacman.d/mirrorlist
# Удалим mirrorlist из /mnt/etc/pacman.d/mirrorlist
rm /mnt/etc/pacman.d/mirrorlist 
#rm -rf /mnt/etc/pacman.d/mirrorlist
#Удалите файл /etc/pacman.d/mirrorlist
#rm -rf /etc/pacman.d/mirrorlist
# Удаления старой резервной копии (если она есть, если нет, то пропустите этот шаг):
#rm /etc/pacman.d/mirrorlist.old

echo 'Загрузка свежего списка зеркал со страницы Mirror Status, и обновляем mirrorlist'
# Loading a fresh list of mirrors from the Mirror Status page, and updating the mirrorlist
# Чтобы увидеть список всех доступных опций, наберите:
#reflector --help
# Команда отфильтрует пять зеркал, отсортирует их по скорости и обновит файл mirrorlist:
#sudo pacman -Sy --noconfirm --noprogressbar --quiet reflector
reflector --verbose --country 'Russia' -l 5 -p https -p http -n 5 --save /etc/pacman.d/mirrorlist --sort rate  
#reflector --verbose --country 'Russia' -l 5 -p https -p http -n 5 --sort rate --save /etc/pacman.d/mirrorlist

echo 'Копируем созданный список зеркал (mirrorlist) в /mnt'
# Copying the created list of mirrors (mirrorlist) to /mnt
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

echo 'Копируем резервного списка зеркал (mirrorlist.backup) в /mnt'
# Copying the backup list of mirrors (mirrorlist.backup) in /mnt
cp /etc/pacman.d/mirrorlist.backup /mnt/etc/pacman.d/mirrorlist.backup

echo 'Посмотреть список серверов-зеркал /mnt/etc/pacman.d/mirrorlist'
# View the list of mirror servers /mnt/etc/pacman.d/mirrorlist
cat /mnt/etc/pacman.d/mirrorlist

echo 'Обновим базы данных пакетов'
# Updating the package databases
#sudo pacman-key --init
#sudo pacman-key --refresh-keys
sudo pacman -Sy 

echo 'Создадим конфигурационный файл для установки системных переменных /etc/sysctl.conf'
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

# ============================================================================

###*******************************************************************
# Делаем скрипт пост инстала:
cat <<EOF  >> /mnt/opt/install.sh
#!/bin/bash

### SHARED VARIABLES AND FUNCTIONS (ОБЩИЕ ПЕРЕМЕННЫЕ И ФУНКЦИИ)
### Shell color codes (Цветовые коды оболочки)
RED="\e[1;31m"; GREEN="\e[1;32m"; YELLOW="\e[1;33m"; GREY="\e[3;93m"
BLUE="\e[1;34m"; CYAN="\e[1;36m"; BOLD="\e[1;37m"; MAGENTA="\e[1;35m"; NC="\e[0m"

# Автоматическое обнаружение ошибок
# Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
set -e


echo 'Вводим имя компьютера, и имя пользователя'
#echo 'Enter the computer name and user name'
# Enter the computer name
# Enter your username
#read -p "Введите имя компьютера: " hostname
#read -p "Введите имя пользователя: " username
echo -e "${GREEN}==> ${NC}" 
read -p " => Введите имя компьютера: " hostname
echo -e "${GREEN}==> ${NC}"
read -p " => Введите имя пользователя: " username
#read -p "Ведите свою таймзону в формате Example/Example: " timezone

echo 'Прописываем имя компьютера'
# Entering the computer name
echo $hostname > /etc/hostname
#echo "имя_компьютера" > /etc/hostname
#echo HostName > /etc/hostname

echo 'Устанавливаем ваш часовой пояс'
# Setting your time zone
#rm -v /etc/localtime
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#timedatectl set-ntp true
#ln -svf /usr/share/zoneinfo/$timezone /etc/localtime
#ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -svf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
#ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

echo 'Синхронизация системных часов'
# Syncing the system clock
#echo 'Синхронизируем наши системные часы, включаем ntp, если надо сменим часовой пояс'
# Sync our system clock, enable ntp, change the time zone if necessary
timedatectl set-ntp true

echo 'Проверим аппаратное время' 
# Check the hardware time
#hwclock
hwclock --systohc

echo 'Посмотрим текущее состояние аппаратных и программных часов'
# Let's see the current state of the hardware and software clock
timedatectl

echo 'Настроим состояние аппаратных и программных часов'
# Setting up the state of the hardware and software clock 
#echo 'Вы можете пропустить этот шаг, если не уверены в правильности выбора'   
#read -p "1 - UTC, 2 - Localtime, 0 - Пропустить: " prog_set
#if [[ $prog_set == 1 ]]; then
#hwclock --systohc --utc
#elif [[ $prog_set == 2 ]]; then
#hwclock --systohc --local
#elif [[ $prog_set == 0 ]]; then
#  echo 'Настройка пропущена.'
#fi

hwclock --systohc --utc
##hwclock --systohc --local

echo 'Посмотрим обновление времени (если настройка не была пропущена)'
# See the time update (if the setting was not skipped)
timedatectl show
#timedatectl | grep Time

echo 'Изменяем имя хоста'
# Changing the host name
echo "127.0.0.1	localhost.(none)" > /etc/hosts
echo "127.0.1.1	$hostname" >> /etc/hosts
echo "::1	localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts
#echo "127.0.1.1 имя_компьютера" >> /etc/hosts
# - Можно написать с Заглавной буквы.
# Это дейсвие не обязательно! Мы можем это сделаем из установленной ситемы, если данные не пропишутся автоматом.

echo '3.4 Добавляем русскую локаль системы'
# Adding the system's Russian locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
# Есть ещё команды по добавлению русскую локаль в систему:
#echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
# Можно раскомментирвать нужные локали (и убирать #)
#sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
#sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

echo 'Обновим текущую локаль системы'
# Update the current system locale
locale-gen
# Мы ввели locale-gen для генерации тех самых локалей.

sleep 02
echo 'Указываем язык системы'
# Specify the system language
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
#echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
#export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8
# Эта команда сама пропишет в файлике locale.conf нужные нам параметры.

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
# Enter KEYMAP=ru FONT=cyr-sun16
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
echo 'FONT_MAP=' >> /etc/vconsole.conf
echo 'CONSOLEMAP' >> /etc/vconsole.conf
echo 'COMPRESSION="lz4"' >> /etc/mkinitcpio.conf

echo 'Создадим загрузочный RAM диск (начальный RAM-диск)'
# Creating a bootable RAM disk (initial RAM disk)
mkinitcpio -p linux-lts
#mkinitcpio -p linux
#mkinitcpio -P linux
#mkinitcpio -p linux-zen
#echo 'COMPRESSION="lz4"' >> /etc/mkinitcpio.conf

echo 'Создаём root пароль'
# Creating a root password
passwd

echo 'Устанавливаем загрузчик (grub)'
# Install the boot loader (grub)
pacman -Syy
pacman -S grub --noconfirm 
#pacman -S grub --noconfirm --noprogressbar --quiet  
grub-install /dev/sda
#grub-install --recheck /dev/sda
#grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

echo 'Установить Микрокод для процессора INTEL_CPU, AMD_CPU?'
# Install the Microcode for the CPU INTEL_CPU, AMD_CPU?
#echo 'Вы можете пропустить этот шаг, если не уверены в правильности выбора'
#read -p "1 - INTEL, 2 - AMD, 0 - Нет: " prog_set
#if [[ $prog_set == 1 ]]; then
# pacman -S intel-ucode --noconfirm     
#elif [[ $prog_set == 2 ]]; then
# pacman -S amd-ucode --noconfirm    
#elif [[ $prog_set == 0 ]]; then
#  echo 'Установка программ пропущена.'
#fi

# Устанавливаем микрокод для процессора:
# Если у Вас процессор Intel, то:
#pacman -S intel-ucode
pacman -S intel-ucode --noconfirm
# Если у Вас процессор AMD, то:
#pacman -S amd-ucode
#pacman -S amd-ucode --noconfirm

echo 'Обновляем grub.cfg (Сгенерируем grub.cfg)'
# Updating grub.cfg (Generating grub.cfg)
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Если в системе будут несколько ОС, то это также ставим'
# If the system will have several operating systems, then this is also set
pacman -S os-prober mtools fuse

echo 'Ставим программу для Wi-fi'
# Install the program for Wi-fi
pacman -S dialog wpa_supplicant iw wireless_tools net-tools --noconfirm

echo 'Добавляем пользователя и прописываем права, группы'
# Adding a user and prescribing rights, groups
#useradd -m -g users -G wheel -s /bin/bash $username
useradd -m -g users -G adm,audio,games,lp,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash alex

echo 'Устанавливаем пароль пользователя'
# Setting the user password
passwd $username

echo 'Устанавливаем SUDO'
# Installing SUDO
pacman -S sudo --noconfirm
#echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
#sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
# Uncomment the multilib repository For running 32-bit applications on a 64-bit system
#echo 'Color = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
#echo '[multilib]' >> /etc/pacman.conf
#echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
#pacman -Syy --noconfirm --noprogressbar --quiet
# Синхронизация и обновление пакетов (-yy принудительно обновить даже если обновленные)

echo "Куда устанавливем Arch Linux на виртуальную машину?"
# Where do we install Arch Linux on the VM?
read -p "1 - Да, 0 - Нет: " vm_setting
if [[ $vm_setting == 0 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit"
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"
fi

echo 'Ставим иксы и драйвера'
# Put the x's and drivers
pacman -S $gui_install

# -------------------------------------------------------------------------
#pacman -S bash-completion xorg-server xorg-apps xorg-xinit mesa xorg-twm xterm xorg-xclock xf86-input-synaptics virtualbox-guest-utils linux-headers --noconfirm
# ============================================================================

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
# ============================================================================

echo 'Ставим DE (от англ. desktop environment — среда рабочего стола) Xfce'
# Put DE (from the English desktop environment-desktop environment) Xfce
pacman -S xfce4 xfce4-goodies --noconfirm

echo 'Ставим DM (Display manager) менеджера входа'
# Install the DM (Display manager) of the login Manager
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfir

echo 'Ставим сетевые утилиты "Networkmanager"'
# Put the network utilities "Networkmanager"
pacman -S networkmanager network-manager-applet ppp --noconfirm
# networkmanager - сервис для работы интернета. Вместе с собой устанавливает программы для настройки.
# Если вам нужна поддержка OpenVPN в Network Manager, то выполните команду:
#sudo pacman -S networkmanager-openvpn

echo 'Ставим шрифты'
# Put the fonts
pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-arphic-ukai ttf-arphic-uming ttf-hanazono --noconfirm 

echo 'Подключаем автозагрузку менеджера входа и интернет'
# Enabling auto-upload of the login Manager and the Internet
systemctl enable lightdm.service
sleep 1 
systemctl enable NetworkManager
#systemctl enable dhcpcd

echo 'Монтировании разделов NTFS и создание ссылок'
# NTFS support (optional)
sudo pacman -S ntfs-3g --noconfirm

echo 'Создаём нужные директории'
# Creating the necessary directories
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update 

echo 'Установка базовых программ и пакетов'
# Installing basic programs and packages
sudo pacman -S wget --noconfirm

# ============================================================================

#read -p "Введите допольнительные пакеты которые вы хотите установить: " packages 
#pacman -S $packages --noconfirm

echo 'Поздравляем! Установка завершена. Перезагрузите систему.'
# Congratulations! Installation is complete. Reboot the system.

echo 'Посмотрим дату и время'
# Let's look at the date and time
date

echo 'Отобразить время работы системы'
# Display the system's operating time 
uptime

echo 'Если у Вас беспроводное соединение, запустите nmtui и подключитесь к сети.'
# If you have a wireless connection, launch nmtui and connect to the network.

echo 'Выходим из установленной системы'
# Exiting the installed system

echo 'После перезагрузки заходим под пользователем'
#Перезагрузка.После перезагрузки заходим под пользователем
exit
#umount -Rf /mnt

# Разделы (отмонтировать) Partitions (umount) 
#umount -Rfv /mnt
#umount -R /mnt


EOF

arch-chroot /mnt /bin/bash  /opt/install.sh

read -p "Пауза 3 ceк." -t 3
reboot



