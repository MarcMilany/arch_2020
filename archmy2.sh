#!/bin/bash
# Enter the computer name
# Enter your username
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
# Entering the computer name
echo $hostname > /etc/hostname

echo 'Установите ваш часовой пояс'
# Set your time zone
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#ln -svf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
#ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

echo 'Настроим состояние аппаратных и программных часов'
# Setting up the state of the hardware and software clock
echo 'Показать аппаратное время' 
# Show hardware time
hwclock     
echo -e "${BLUE}
'Windows и Linux работают по-разному с этими двумя часами. 
Есть два способа работы:${GREEN}
UTC - и аппаратные, и программные часы идут по Гринвичу. 
То есть часы дают универсальное время на нулевом часовом поясе. 
Например, если у вас часовой пояс GMT+3, Киев, то часы будут отставать на три часа. 
А уже пользователи локально прибавляют к этому времени поправку на часовой пояс, например, плюс +3. 
Каждый пользователь добавляет нужную ему поправку. Так делается на серверах, 
чтобы каждый пользователь мог получить правильное для своего часового пояса время.
localtime - в этом варианте программные часы тоже идут по Гринвичу, 
но аппаратные часы идут по времени локального часового пояса. 
Для пользователя разницы никакой нет, все равно нужно добавлять поправку на свой часовой пояс. 
Но при загрузке и синхронизации времени Windows вычитает из аппаратного времени 3 часа 
(или другую поправку на часовой пояс), чтобы программное время было верным.
Вы можете пропустить этот шаг, если не уверены в правильности выбора'
${NC}"
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

echo 'Проверим аппаратное время' 
# Check the hardware time
hwclock

echo 'Посмотрим текущее состояние аппаратных и программных часов'
# Let's see the current state of the hardware and software clock
sudo timedatectl

echo 'Измените имя хоста'
# Change the host name
echo "127.0.0.1	localhost.(none)" > /etc/hosts
echo "127.0.1.1	Terminator" >> /etc/hosts
echo "::1	localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts

echo '3.4 Добавляем русскую локаль системы'
# Adding the system's Russian locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo 'Обновим текущую локаль системы'
# Update the current system locale
locale-gen

sleep 1
echo 'Указываем язык системы'
# Specify the system language
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
#export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
# Enter KEYMAP=ru FONT=cyr-sun16
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
echo 'FONT_MAP=' >> /etc/vconsole.conf
echo 'CONSOLEMAP' >> /etc/vconsole.conf

echo 'Создадим загрузочный RAM диск (начальный RAM-диск)'
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

echo 'Создаем root пароль'
# Creating a root password
passwd

echo '3.5 Устанавливаем загрузчик (grub)'
# Install the boot loader (grub)
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda
#grub-install --recheck /dev/sda

echo 'Обновляем grub.cfg (Сгенерируем grub.cfg)'
# Updating grub.cfg (Generating grub.cfg)
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Если в системе будут несколько ОС, то это также ставим'
# If the system will have several operating systems, then this is also set
pacman -S os-prober mtools fuse

echo 'Ставим программу для Wi-fi'
# Install the program for Wi-fi
pacman -S dialog wpa_supplicant --noconfirm 

echo 'Добавляем пользователя и прописываем права, группы'
# Adding a user and prescribing rights, groups
#useradd -m -g users -G wheel -s /bin/bash $username
useradd -m -g users -G wheel,audio,games,lp,optical,power,scanner,storage,video,sys -s /bin/bash $username
# или есть команда с правами 'админа' :
#useradd -m -g users -G adm,audio,games,lp,optical,power,scanner,storage,video,sys,wheel -s /bin/bash $username

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

echo 'Ставим DE (от англ. desktop environment — среда рабочего стола) Xfce'
# Put DE (from the English desktop environment-desktop environment) Xfce
pacman -S xfce4 xfce4-goodies --noconfirm

echo 'Ставим DM (Display manager) менеджера входа'
# Install the DM (Display manager) of the login Manager
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfir

echo 'Ставим сетевые утилиты "Networkmanager"'
# Put the network utilities "Networkmanager"
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'Ставим шрифты'
# Put the fonts
pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-arphic-ukai ttf-arphic-uming ttf-hanazono --noconfirm 

echo 'Подключаем автозагрузку менеджера входа и интернет'
# Enabling auto-upload of the login Manager and the Internet
systemctl enable lightdm.service
sleep 1 
systemctl enable NetworkManager

echo 'Создаем нужные директории'
# Creating the necessary directories
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update 

echo 'Установка завершена! Перезагрузите систему.'
# The installation is now complete! Reboot the system.
echo 'Если хотите подключить AUR, установить мои конфиги XFCE, тогда после перезагрузки и входа в систему, установите wget (sudo pacman -S wget) и выполните команду:'
# If you want to connect AUR, install my Xfce configs, then after restarting and logging in, install wget (sudo pacman -S wget) and run the command:
echo 'wget git.io/archmy3 && sh archmy3'

echo 'Установка базовых программ и пакетов'
# Installing basic programs and packages
sudo pacman -S wget --noconfirm

echo 'Выйдем из установленной системы'
# Log out of the installed system
#exit
### Reboot with 10s timeout
_reboot() {
    for (( SECOND=10; SECOND>=1; SECOND-- )); do
        echo -ne "\r\033[K${GREEN}${MSG_REBOOT} ${SECOND}s...${NC}"
        sleep 1
    done
    reboot; exit 0
}
### Say goodbye
_exit_msg() {
    echo -e "\n${GREEN}<<< ${BLUE}${APPNAME} ${VERSION} ${BOLD}by \
${AUTHOR} ${RED}under ${LICENSE} ${GREEN}>>>${NC}"""
}
