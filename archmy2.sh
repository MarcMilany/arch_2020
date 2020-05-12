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

echo 'Создадим загрузочный RAM диск (initial RAM disk)'
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
  gui_install="xorg-server xorg-drivers xorg-xinit mesa xterm xf86-input-synaptics"
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"
fi

echo 'Ставим иксы и драйвера'
pacman -S $gui_install

echo 'Ставим DE (от англ. desktop environment — среда рабочего стола) Xfce'
pacman -S xfce4 xfce4-goodies --noconfirm

echo 'Ставим DM (Display manager) менеджера входа'
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfir

echo 'Ставим сетевые утилиты "Networkmanager"'
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-bitstream-vera ttf-arphic-ukai ttf-arphic-uming ttf-hanazono --noconfirm 

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable lightdm.service 
systemctl enable NetworkManager

echo 'Ставим Bluetooth and Sound support'
pacman -S bluez bluez-libs bluez-cups bluez-utils --noconfirm
pacman -S alsa-utils alsa-plugins alsa-firmware alsa-lib alsa-utils --noconfirm 
pacman -S pulseaudio pulseaudio-alsa pavucontrol pulseaudio-zeroconf pulseaudio-bluetooth xfce4-pulseaudio-plugin --noconfirm

echo 'Ставим Архиваторы "Compression Tools"'
pacman -S zip unzip unrar p7zip zlib zziplib --noconfirm

echo 'Ставим дополнения к Архиваторам'
pacman -S unace sharutils uudeview arj cabextract --noconfirm

echo 'Ставим Драйвера принтера (Print support)'
sudo pacman -S cups ghostscript cups-pdf --noconfirm

echo 'Установка базовых программ и пакетов'
sudo pacman -S aspell-ru arch-install-scripts bash-completion dosfstools f2fs-tools sane gvfs htop iftop inxi iotop nmap ntfs-3g ntp ncdu hydra isomd5sum python-isomd5sum translate-shell mc pv sox youtube-dl speedtest-cli python-pip pwgen scrot git curl xsel cmake wget --noconfirm 

echo 'Установка терминальных утилит для вывода информации о системе'
sudo pacman -S screenfetch glances archey3 neofetch --noconfirm  

echo 'Установка Мультимедиа кодеков (multimedia codecs), и утилит'
sudo pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly libdvdcss libdvdread libdvdnav dvd+rw-tools dvdauthor dvgrab cdrdao gst-libav gst-libav --noconfirm

echo 'Установка Мультимедиа утилит'
sudo pacman -S audacity audacious audacious-plugins smplayer smplayer-skins smplayer-themes smtube deadbeef easytag subdownloader mediainfo-gui vlc --noconfirm

echo 'Установка Браузеров и медиа-плагинов'
sudo pacman -S firefox firefox-i18n-ru firefox-spell-ru flashplugin pepper-flash --noconfirm

echo 'Установка Текстовые редакторы и утилиты разработки'
sudo pacman -S gedit gedit-plugins geany geany-plugins meld --noconfirm

echo 'Управления электронной почтой, новостными лентами, чатом и группам'
sudo pacman -S thunderbird thunderbird-i18n-ru pidgin pidgin-hotkeys --noconfirm

echo 'Установка Брандмауэра UFW и Антивирусного пакета ClamAV (GUI)(GTK+)'
echo 'Установка Производится в порядке перечесления'
echo 'Установить UFW (Uncomplicated Firewall) (GTK)?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S ufw gufw --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить Clam AntiVirus (GTK)?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S clamav clamtk --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка Torrent клиентов - Transmission, qBittorrent, Deluge (GTK) (Qt)'
echo 'Установка Производится в порядке перечесления'
echo 'Установить Transmission (GTK)?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S transmission-gtk transmission-cli --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить qBittorrent (Qt)?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S qbittorrent --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить Deluge (GTK+)?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S deluge --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка Офиса (LibreOffice-still, или LibreOffice-fresh)'
echo 'Установка Производится в порядке перечесления'
echo 'Установить LibreOffice-still?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S libreoffice-still libreoffice-still-ru --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить LibreOffice-fresh?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S libreoffice libreoffice-fresh-ru --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить рекомендумые программы?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S bleachbit gparted grub-customizer conky conky-manager dconf-editor doublecmd-gtk2 gnome-system-monitor obs-studio openshot frei0r-plugins simplescreenrecorder redshift veracrypt onboard clonezilla moc filezilla gnome-calculator nomacs osmo synapse telegram-desktop plank psensor keepass copyq variety grsync numlockx modem-manager-gui uget xarchiver-gtk2 rofi gsmartcontrol testdisk tlp tlp-rdw file-roller --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Форматируем флешки с файловой системой exFAT в Linux'
sudo pacman -S exfat-utils fuse-exfat --noconfirm 

echo 'Создаем нужные директории'
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update 

echo 'Установка завершена! Перезагрузите систему.'
echo 'Если хотите подключить AUR, установить мои конфиги XFCE, тогда после перезагрузки и входа в систему, установите wget (sudo pacman -S wget) и выполните команду:'
echo 'wget git.io/archmy3 && sh archmy3'

echo 'Выйдем из установленной системы'
exit


