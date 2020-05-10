#!/bin/bash
#rm -rf ~/.config/xfce4/*
mkdir ~/Downloads
cd ~/Downloads

echo 'Установка AUR (yay)'
sudo pacman -Syu
sudo pacman -S wget --noconfirm
wget git.io/yay-install.sh && sh yay-install.sh --noconfirm

echo 'Создаем нужные директории'
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update

echo 'Установка Мультимедиа кодеков (multimedia codecs), и утилит'
sudo pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly flashplugin libdvdcss libdvdread libdvdnav dvd+rw-tools dvdauthor dvgrab cdrdao gst-libav gst-libav gstreamer0.10-plugins gecko-mediaplayer --noconfirm

echo 'Установка программ'
sudo pacman -S wget cmake git curl firefox ufw qt4 f2fs-tools dosfstools ntfs-3g alsa-lib alsa-utils file-roller p7zip unrar gvfs aspell-ru pulseaudio --noconfirm

echo 'Форматируем флешки с файловой системой exFAT в Linux'
sudo pacman -S exfat-utils fuse-exfat --noconfirm 

echo 'Установить рекомендумые программы?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
  sudo pacman -S obs-studio veracrypt freemind filezilla cherrytree gimp libreoffice libreoffice-fresh-ru kdenlive audacity screenfetch vlc qbittorrent gnome-calculator --noconfirm
  yay -S dropbox flameshot-git obs-linuxbrowser xflux sublime-text-dev hunspell-ru pamac-aur --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка тем'
yay -S osx-arc-shadow papirus-maia-icon-theme-git breeze-default-cursor-theme --noconfirm

#echo 'Ставим лого ArchLinux в меню'
#wget git.io/arch_logo.png
#sudo mv -f ~/Downloads/arch_logo.png /usr/share/pixmaps/arch_logo.png

#echo 'Ставим обои на рабочий стол'
#wget git.io/bg.jpg
#sudo rm -rf /usr/share/backgrounds/xfce/* #Удаляем стандартрые обои
#sudo mv -f ~/Downloads/bg.jpg /usr/share/backgrounds/xfce/bg.jpg

#echo 'Включаем сетевой экран'
#sudo ufw enable

#echo 'Добавляем в автозагрузку:'
#sudo systemctl enable ufw

sudo rm -rf ~/Downloads
sudo rm -rf ~/arch3my.sh

echo 'Установка завершена!'
