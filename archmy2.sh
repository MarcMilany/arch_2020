#!/bin/bash
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

echo 'Измените имя хоста '
echo "127.0.0.1	localhost.(none)" > /etc/hosts
echo "127.0.1.1	Terminator" >> /etc/hosts
echo "::1	localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts

echo '3.4 Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo 'Обновим текущую локаль системы'
locale-gen

echo 'Указываем язык системы'
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
echo 'FONT_MAP=' >> /etc/vconsole.conf
echo 'CONSOLEMAP' >> /etc/vconsole.conf

echo 'Создадим загрузочный RAM диск'
#mkinitcpio -p linux
mkinitcpio -P linux

echo 'Создаем root пароль'
passwd

echo '3.5 Устанавливаем загрузчик'
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda

echo 'Обновляем grub.cfg (Сгенерируем grub.cfg)'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Если в системе будут несколько ОС, то это также ставим'
pacman -S os-prober mtools fuse

echo 'Ставим программу для Wi-fi'
pacman -S dialog wpa_supplicant --noconfirm 

echo 'Добавляем пользователя'
useradd -m -g users -G wheel,audio,games,lp,optical,power,scanner,storage,video,sys -s /bin/bash $username

echo 'Устанавливаем пароль пользователя'
passwd $username

echo 'Устанавливаем SUDO'
pacman -S sudo --noconfirm
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
sed -i 's/#Color/Color/' /etc/pacman.conf
#echo 'ILoveCandy' >> /etc/pacman.conf
#[archlinuxfr]
#SigLevel = Never
#Server = http://repo.archlinux.fr/$arch
pacman -Syy

echo "Куда устанавливем Arch Linux на виртуальную машину?"
read -p "1 - Да, 0 - Нет: " vm_setting
if [[ $vm_setting == 0 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit mesa"
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"
fi

echo 'Ставим иксы и драйвера'
pacman -S $gui_install

echo 'Ставим Xfce, LXDM и сеть'
pacman -S xfce4 xfce4-goodies networkmanager network-manager-applet ppp --noconfirm

echo 'Ставим менеджера входа'
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable lightdm.service 
systemctl enable NetworkManager

echo 'Ставим Bluetooth and Sound support'
pacman -S bluez bluez-libs bluez-cups bluez-utils --noconfirm
pacman -S alsa-utils alsa-plugins alsa-firmware alsa-lib alsa-utils --noconfirm 
pacman -S pulseaudio pulseaudio-alsa pavucontrol pulseaudio-zeroconf pulseaudio-bluetooth xfce4-pulseaudio-plugin --noconfirm

echo 'Ставим Архиваторы "Compression Tools"'
pacman -S zip unzip unrar p7zip zlib zziplib --noconfirm

echo 'Ставим Драйвера принтера (Print support)'
sudo pacman -S cups ghostscript cups-pdf --noconfirm

echo 'Установка базовых программ и пакетов'
sudo pacman -S aspell-ru audacity audacious audacious-plugins archey3 bleachbit bash-completion conky conky-manager clamav clamtk clonezilla cmake dosfstools dconf-editor f2fs-tools file-roller filezilla firefox firefox-i18n-ru fetchmirrors geany geany-plugins gedit gedit-plugins git gconf-editor gnome-calculator gnome-system-monitor gnome-disks gsmartcontrol gvfs gparted gufw htop iftop mc meld python2-meld3 mintstick neofetch nmap ntfs-3g onboard pidgin pv sane screenfetch sox testdisk thunderbird thunderbird-i18n-ru transmission-gtk transmission-cli ufw gpm vlc youtube-dl wget --noconfirm 

echo 'Создаем нужные директории'
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update    

echo 'Установка завершена! Перезагрузите систему.'
echo 'Если хотите подключить AUR, установить мои конфиги XFCE, тогда после перезагрузки и входа в систему, установите wget (sudo pacman -S wget) и выполните команду:'
echo 'wget git.io/archmy3 && sh archmy3'

echo 'Выйдем из установленной системы'
exit


