#!/bin/bash
#rm -rf ~/.config/xfce4/*
mkdir ~/downloads
cd ~/downloads

echo -e "${BLUE}
'Установка AUR (yay)'
${NC}"
sudo pacman -Syu
wget git.io/yay-install.sh && sh yay-install.sh --noconfirm

echo 'Обновим всю систему включая AUR пакеты'
yay -Syy
yay -Syu

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
sudo pacman -S aspell-ru arch-install-scripts bash-completion dosfstools f2fs-tools sane gvfs htop iftop inxi iotop nmap ntfs-3g ntp ncdu hydra isomd5sum python-isomd5sum translate-shell mc pv sox youtube-dl speedtest-cli python-pip pwgen scrot git curl xsel --noconfirm 

echo 'Установка терминальных утилит для вывода информации о системе'
sudo pacman -S screenfetch archey3 neofetch --noconfirm  

echo 'Установка Мультимедиа кодеков (multimedia codecs), и утилит'
sudo pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly libdvdcss libdvdread libdvdnav dvd+rw-tools dvdauthor dvgrab cdrdao gst-libav gst-libav gpac --noconfirm

echo 'Установка Мультимедиа утилит'
sudo pacman -S audacity audacious audacious-plugins smplayer smplayer-skins smplayer-themes smtube deadbeef easytag subdownloader mediainfo-gui vlc --noconfirm

echo 'Установка Текстовые редакторы и утилиты разработки'
sudo pacman -S gedit gedit-plugins geany geany-plugins --noconfirm

echo 'Управления электронной почтой, новостными лентами, чатом и группам'
sudo pacman -S thunderbird thunderbird-i18n-ru pidgin pidgin-hotkeys --noconfirm

echo 'Установка Браузеров и медиа-плагинов'
sudo pacman -S firefox firefox-i18n-ru firefox-spell-ru flashplugin pepper-flash --noconfirm

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

echo 'Установка Torrent клиентов - Transmission, qBittorrent, Deluge (GTK)(Qt)(GTK+)'
echo 'Установка Производится в порядке перечесления'
echo 'Установить Transmission, qBittorrent, Deluge?'
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

echo 'Установка Офиса (LibreOffice-still, или LibreOffice-fresh)'
echo 'Установка Производится в порядке перечесления'
echo 'Установить LibreOffice-still, LibreOffice-fresh?'
read -p "1 - LibreOffice-still, 2 - LibreOffice-fresh, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S libreoffice-still libreoffice-still-ru --noconfirm
elif [[ $prog_set == 2 ]]; then
sudo pacman -S libreoffice libreoffice-fresh-ru --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить рекомендумые программы?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
sudo pacman -S bleachbit gparted grub-customizer conky conky-manager dconf-editor doublecmd-gtk2 gnome-system-monitor obs-studio openshot frei0r-plugins lib32-simplescreenrecorder simplescreenrecorder redshift veracrypt onboard clonezilla moc filezilla gnome-calculator nomacs osmo synapse telegram-desktop plank psensor keepass copyq variety grsync numlockx modem-manager-gui uget xarchiver-gtk2 rofi gsmartcontrol testdisk glances tlp tlp-rdw file-roller meld cmake --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Форматируем флешки с файловой системой exFAT в Linux'
sudo pacman -S exfat-utils fuse-exfat --noconfirm 

echo 'Установка "Pacmangui","Octopi" (AUR)(GTK)(QT)'
echo 'Установка Производится в порядке перечесления'
echo 'Установить "pamac-aur", "octopi"?'
read -p "1 - Pacmanc-aur, 2 - Octopi, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S pamac-aur --noconfirm
elif [[ $prog_set == 2 ]]; then
yay -S octopi --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Обновим информацию о шрифтах'
sudo fc-cache -f -v

echo 'Применяем настройки TLP (управления питанием) в зависимости от источника питания (батарея или от сети)'
sudo tlp start

echo 'Включаем сетевой экран'
sudo ufw enable

echo 'Добавляем в автозагрузку:'
sudo systemctl enable ufw

echo 'Прверим статус запуска сетевой экран UFW'
sudo ufw status

echo 'Создать backup (дубликат) файла grub.cfg'
cp /boot/grub/grub.cfg grub.cfg.backup

#echo 'Добавить репозиторий archlinuxfr и вписать тему для Color.'
#echo '[multilib]' >> /etc/pacman.conf
#echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
#sed -i 's/#Color/Color/' /etc/pacman.conf
#echo 'ILoveCandy' >> /etc/pacman.conf
#[archlinuxfr]
#SigLevel = Never
#Server = http://repo.archlinux.fr/$arch
#pacman -Syy

#echo 'Добавить оскорбительное выражение после неверного ввода пароля в терминале'
#Откройте на редактирование файл sudoers следующей командой в терминале:
#sudo nano /etc/sudoers
#Когда откроется файл sudoers на редактирование, стрелками вниз/вверх переместитесь до строки:
## Defaults env_keep += "QTDIR KDEDIR"
# и ниже скопипастите следующую стоку:
# Defaults  badpass_message="Ты не администратор, придурок."

sudo rm -R ~/downloads/
sudo rm -rf ~/arch3my

echo 'Установка завершена!'
