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
# Information (Информация)
_arch_fast_install_banner_2() {
    echo -e "${BLUE}  
  ***************************** Информация! *****************************  
${NC}
Продолжается работа скрипта - основанного на сценарии (скрипта)'Arch Linux Fast Install LegasyBios (arch2018)'.
Происходит установка первоначально необходимого софта (пакетов), запуск необходимых служб, запись данных в конфиги (hhh.conf) по настройке системы.
В процессе работы сценария (скрипта) Вам будет предложено выполнить следующие действия:
Ввести имя пользователя (username), ввести имя компьютера (hostname), а также установить пароль для пользователя (username) и администратора (root). 
Настроить состояние аппаратных часов 'UTC или Localtime', но Вы можете отказаться и настроить их уже из системы Arch'a.
Будут заданы вопросы: на установку той, или иной утилиты (пакета), и на какой аппаратной базе будет установлена система (для установки Xorg 'обычно называемый просто X' и драйверов) - Будьте Внимательными! 
 Смысл в том, что все изменения вы делаете предварительно в самом скрипте и получаете возможность быстрой установки утилит (пакетов), которые Вы решили установить (при условии, что Вы его изменили под себя, в противном случае скрипт установит софт (пакеты) прописанный изначально.
Не переживайте софт (пакеты) скачивается и устанавливается из 'Официальных репозиториев Arch Linux'. В любой ситуации выбор всегда за вами.
${BLUE}  
  ***************************************************************************
${NC}"   
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
_arch_fast_install_banner_2

echo -e "${BLUE}:: ${NC}Вводим имя компьютера, имя пользователя"
#echo 'Вводим имя компьютера, имя пользователя'
#echo 'Enter the computer name and user name'
# Enter the computer name
# Enter your username
#read -p "Введите имя компьютера: " hostname
#read -p "Введите имя пользователя: " username
read -p 
echo -e "${GREEN}==>  ${NC}Введите имя компьютера: " hostname
read -p
echo -e "${GREEN}==>  ${NC}Введите имя пользователя: " username

echo -e "${BLUE}:: ${NC}Прописываем имя компьютера"
#echo 'Прописываем имя компьютера'
# Entering the computer name
echo $hostname > /etc/hostname

echo -e "${BLUE}:: ${NC}"
echo 'Установите ваш часовой пояс'
# Set your time zone
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -svf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
#ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

echo -e "${BLUE}:: ${NC}Настроим состояние аппаратных и программных часов"
#echo 'Настроим состояние аппаратных и программных часов'
# Setting up the state of the hardware and software clock    
echo -e "${YELLOW}::  ${NC}Вы можете пропустить этот шаг, если не уверены в правильности выбора"
# ============================================================================
# Windows и Linux работают по-разному с этими двумя часами. 
# Есть два способа работы:${GREEN}
# UTC - и аппаратные, и программные часы идут по Гринвичу. 
# То есть часы дают универсальное время на нулевом часовом поясе. 
# Например, если у вас часовой пояс GMT+3, Киев, то часы будут отставать на три часа. 
# А уже пользователи локально прибавляют к этому времени поправку на часовой пояс, например, плюс +3. 
# Каждый пользователь добавляет нужную ему поправку. Так делается на серверах, 
# чтобы каждый пользователь мог получить правильное для своего часового пояса время.
# localtime - в этом варианте программные часы тоже идут по Гринвичу, 
# но аппаратные часы идут по времени локального часового пояса. 
# Для пользователя разницы никакой нет, все равно нужно добавлять поправку на свой часовой пояс. 
# Но при загрузке и синхронизации времени Windows вычитает из аппаратного времени 3 часа 
# (или другую поправку на часовой пояс), чтобы программное время было верным.
# Вы можете пропустить этот шаг, если не уверены в правильности выбора.
# ============================================================================
read -p "1 - UTC, 2 - Localtime, 0 - Пропустить: " prog_set
if [[ $prog_set == 1 ]]; then
hwclock --systohc --utc
elif [[ $prog_set == 2 ]]; then
hwclock --systohc --local
elif [[ $prog_set == 0 ]]; then
  echo 'Настройка пропущена.'
fi
#hwclock --systohc --utc
#hwclock --systohc --local
# Команды для исправления уже в установленной системе:
# Исправим ошибку времени, если она есть
#sudo timedatectl set-local-rtc 1 --adjust-system-clock
# Как вернуть обратно -
#sudo timedatectl set-local-rtc 0
# Для понимания сути команд статья с примерами -
# https://losst.ru/sbivaetsya-vremya-v-ubuntu-i-windows
# https://www.ekzorchik.ru/2012/04/hardware-time-settings-hwclock/

echo -e "${BLUE}:: ${NC}Проверим аппаратное время"
#echo 'Проверим аппаратное время' 
# Check the hardware time
hwclock

echo -e "${BLUE}:: ${NC}"
#echo 'Посмотрим текущее состояние аппаратных и программных часов'
# Let's see the current state of the hardware and software clock
timedatectl

echo -e "${BLUE}:: ${NC}"
#echo 'Измените имя хоста'
# Change the host name
echo "127.0.0.1	localhost.(none)" > /etc/hosts
echo "127.0.1.1	Terminator" >> /etc/hosts
echo "::1	localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts

echo -e "${BLUE}:: ${NC}"
#echo '3.4 Добавляем русскую локаль системы'
# Adding the system's Russian locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo -e "${BLUE}:: ${NC}"
#echo 'Обновим текущую локаль системы'
# Update the current system locale
locale-gen

sleep 1
echo -e "${BLUE}:: ${NC}"
#echo 'Указываем язык системы'
# Specify the system language
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
#export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8

echo -e "${BLUE}:: ${NC}"
#echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
# Enter KEYMAP=ru FONT=cyr-sun16
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
echo 'FONT_MAP=' >> /etc/vconsole.conf
echo 'CONSOLEMAP' >> /etc/vconsole.conf

echo -e "${BLUE}:: ${NC}"
#echo 'Создадим загрузочный RAM диск (начальный RAM-диск)'
# Creating a bootable RAM disk (initial RAM disk)
mkinitcpio -p linux-lts
# Команда: mkinitcpio -p linux-lts  - применяется, если Вы устанавливаете
# стабильное ядро (linux-ltc), иначе вай..вай... может быть ошибка!  
# В остальных случаях при установке Arch'a с ядром (linux) идущим вместе   
# с устанавливаемым релизом применяется команда : mkinitcpio -p linux.
# Ошибки при создании RAM mkinitcpio -p linux. Как исправить?
# https://qna.habr.com/q/545694
#mkinitcpio -p linux
#mkinitcpio -P linux

echo -e "${GREEN}:: ${NC}"
#echo 'Создаем root пароль'
# Creating a root password
passwd

echo -e "${BLUE}:: ${NC}"
#echo '3.5 Устанавливаем загрузчик (grub)'
# Install the boot loader (grub)
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda
#grub-install --recheck /dev/sda

echo -e "${BLUE}:: ${NC}"
#echo 'Обновляем grub.cfg (Сгенерируем grub.cfg)'
# Updating grub.cfg (Generating grub.cfg)
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "${BLUE}:: ${NC}"
#echo 'Если в системе будут несколько ОС, то это также ставим'
# If the system will have several operating systems, then this is also set
pacman -S os-prober mtools fuse

echo -e "${BLUE}:: ${NC}"
#echo 'Ставим программу для Wi-fi'
# Install the program for Wi-fi
pacman -S dialog wpa_supplicant --noconfirm 

echo -e "${BLUE}:: ${NC}"
#echo 'Добавляем пользователя и прописываем права, группы'
# Adding a user and prescribing rights, groups
#useradd -m -g users -G wheel -s /bin/bash $username
useradd -m -g users -G wheel,audio,games,lp,optical,power,scanner,storage,video,sys -s /bin/bash $username
# или есть команда с правами 'админа' :
#useradd -m -g users -G adm,audio,games,lp,optical,power,scanner,storage,video,sys,wheel -s /bin/bash $username

echo -e "${GREEN}:: ${NC}"
#echo 'Устанавливаем пароль пользователя'
# Setting the user password
passwd $username

echo -e "${BLUE}:: ${NC}"
#echo 'Устанавливаем SUDO'
# Installing SUDO
pacman -S sudo --noconfirm
#echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
#sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo -e "${BLUE}:: ${NC}"
#echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
# Uncomment the multilib repository For running 32-bit applications on a 64-bit system
#echo '[multilib]' >> /etc/pacman.conf
#echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/#[multilib]/[multilib]/' /etc/pacman.conf
sed -i 's/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/' /etc/pacman.conf
#echo 'ILoveCandy' >> /etc/pacman.conf
#echo '[archlinuxfr]' >> /etc/pacman.conf
#echo '[SigLevel = Never]' >> /etc/pacman.conf
#echo 'Server = http://repo.archlinux.fr/$arch' >> /etc/pacman.conf
pacman -Syy

echo -e "${BLUE}:: ${NC}"
#echo "Куда устанавливем Arch Linux на виртуальную машину?"
# Where do we install Arch Linux on the VM?
read -p "1 - Да, 0 - Нет: " vm_setting
if [[ $vm_setting == 0 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit"
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"
fi

echo -e "${BLUE}:: ${NC}"
#echo 'Ставим иксы и драйвера'
# Put the x's and drivers
pacman -S $gui_install

echo -e "${BLUE}:: ${NC}"
#echo 'Ставим DE (от англ. desktop environment — среда рабочего стола) Xfce'
# Put DE (from the English desktop environment-desktop environment) Xfce
pacman -S xfce4 xfce4-goodies --noconfirm

echo -e "${BLUE}:: ${NC}"
#echo 'Ставим DM (Display manager) менеджера входа'
# Install the DM (Display manager) of the login Manager
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfir

echo -e "${BLUE}:: ${NC}"
#echo 'Ставим сетевые утилиты "Networkmanager"'
# Put the network utilities "Networkmanager"
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo -e "${BLUE}:: ${NC}"
#echo 'Ставим шрифты'
# Put the fonts
pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-arphic-ukai ttf-arphic-uming ttf-hanazono --noconfirm 

echo -e "${BLUE}:: ${NC}"
#echo 'Подключаем автозагрузку менеджера входа и интернет'
# Enabling auto-upload of the login Manager and the Internet
systemctl enable lightdm.service
sleep 1 
systemctl enable NetworkManager

echo -e "${BLUE}:: ${NC}"
#echo 'Создаем нужные директории'
# Creating the necessary directories
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update 

echo -e "${BLUE}:: ${NC}"
#echo 'Установка базовых программ и пакетов'
# Installing basic programs and packages
sudo pacman -S wget --noconfirm

echo -e "${GREEN}
  Установка завершена! Перезагрузите систему.
${NC}"
# The installation is now complete! Reboot the system.

echo 'Если хотите подключить AUR, установить мои конфиги XFCE, тогда после перезагрузки и входа в систему, и выполните команду:'
# If you want to connect AUR, install my Xfce configs, then after restarting and logging in, install wget (sudo pacman -S wget) and run the command:
echo -e "${YELLOW}==>  wget git.io/archmy3 && sh archmy3 ${NC}"

#echo 'Выйдем из установленной системы'
# Log out of the installed system
exit








