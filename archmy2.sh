#!/bin/bash
# Enter the computer name
# Enter your username
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
# Entering the computer name
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
mkinitcpio -p linux-lts
# mkinitcpio -p linux
# mkinitcpio -P linux

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
pacman -Syy

echo "Куда устанавливем Arch Linux на виртуальную машину?"
read -p "1 - Да, 0 - Нет: " vm_setting
if [[ $vm_setting == 0 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit"
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
pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-arphic-ukai ttf-arphic-uming ttf-hanazono --noconfirm 

echo 'Установка базовых программ и пакетов'
sudo pacman -S wget --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable lightdm.service 
systemctl enable NetworkManager

echo 'Создаем нужные директории'
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update 

echo 'Установка завершена! Перезагрузите систему.'
echo 'Если хотите подключить AUR, установить мои конфиги XFCE, тогда после перезагрузки и входа в систему, установите wget (sudo pacman -S wget) и выполните команду:'
echo 'wget git.io/archmy3 && sh archmy3'

echo 'Выйдем из установленной системы'
exit


