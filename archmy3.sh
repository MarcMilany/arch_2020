#!/bin/bash
#Если возникли проблемы с обновлением, или установкой пакетов 
#Выполните данные рекомендации:
#author: 

echo 'Обновление ключей системы'
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

#rm -rf ~/.config/xfce4/*
mkdir ~/Downloads
cd ~/Downloads

echo 'Установка AUR (yay)'
sudo pacman -Syu
sudo pacman -S wget --noconfirm
wget git.io/yay-install.sh && sh yay-install.sh --noconfirm

echo 'Обновим всю систему включая AUR пакеты'
yay -Syy
yay -Syu

echo 'Установка "Pacmangui","Octopi" (AUR) (GTK) (QT)'
echo 'Установить "pamac-aur" "(AUR) (GTK)"?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S pamac-aur --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить "octopi" "(AUR) (QT)"?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S octopi --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установка Мультимедиа утилит AUR'
yay -S radiotray spotify vlc-tunein-radio --noconfirm  

echo 'Установка программ'
sudo pacman -S galculator-gtk2 qt4 --noconfirm

echo 'Установить рекомендумые программы?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
  sudo pacman -S gimp kdenlive --noconfirm 
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

echo 'Установить рекомендумые программы из AUR?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
yay -S dropbox flameshot-git cherrytree pidgin-extprefs xflux sublime-text-dev hunspell-ru --noconfirm
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

echo 'Включаем сетевой экран'
sudo ufw enable

echo 'Добавляем в автозагрузку:'
sudo systemctl enable ufw

sudo rm -rf ~/Downloads
sudo rm -rf ~/arch3my.sh

echo 'Установка завершена!'
