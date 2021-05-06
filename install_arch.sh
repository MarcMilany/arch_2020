#!/bin/bash
# set -e  # Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
apptitle="Arch Linux Fast Install v1.6 LegasyBIOS - Version: 2020.07.16.00.40.38 (GPLv3)"
baseurl=https://raw.githubusercontent.com/MarcMilany/arch_2020/master/url%20links%20abbreviated/git%20url
cpl=0
skipfont="0"
fspkgs=""
iso_label="ARCH_$(date +%Y%m)"
iso_version=$(date +%Y.%m.%d)
gpg_key=
verbose=""
EDITOR=nano
#EDITOR=nano visudo  # Выполните команду с правами суперпользователя

INSTALLARCH_LANG="russian"  # Installer default language (Язык установки по умолчанию)
script_path=$(readlink -f ${0%/*})

ischroot=0

if [ $ischroot -eq 0 ]
then

  getconf ARG_MAX

  umask 

  pacman -Sy terminus-font --noconfirm  # Моноширинный растровый шрифт (для X11 и консоли)
# pacman -Syy terminus-font  # Моноширинный растровый шрифт (для X11 и консоли)
# man vconsole.conf

  loadkeys ru  # Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы
# loadkeys us
# setfont ter-v12n
# setfont ter-v14b
# setfont cyr-sun16
  setfont ter-v16b ### Установленный setfont
# setfont ter-v20b  # Шрифт терминус и русская локаль # чтобы шрифт стал побольше
### setfont ter-v22b
### setfont ter-v32b

  sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

  locale-gen  # Мы ввели locale-gen для генерации тех самых локалей.

  export LANG=ru_RU.UTF-8  # Указываем язык системы
# export LANG=en_US.UTF-8

  locale -a  # Проверяем, что все заявленные локали были созданы

  ip a  # Смотрим какие у нас есть интернет-интерфейсы

  ping -c2 archlinux.org  # Для проверки интернета можно пропинговать какой-либо сервис

  timedatectl set-ntp true && timedatectl set-timezone Europe/Moscow
  
  timedatectl status

  modprobe dm-mod  # Загрузит модуль ядра и любые дополнительные зависимости модуля
  cat /proc/modules | grep dm_mod  # Проверяем - dm-mod модуль ядра
  modprobe dm-crypt  # Это криптографическая цель (подсистема прозрачного шифрования диска в ядре Linux ...)

# pacman-key --init  # генерация мастер-ключа (брелка) pacman
# pacman-key --populate archlinux  # поиск ключей
# pacman-key --refresh-keys --keyserver keys.gnupg.net  # http://pool.sks-keyservers.net/
# pacman -Syy  # обновление баз пакмэна (pacman) 

  pacman -Sy --noconfirm

  pacman -S dmidecode --noconfirm  # Dmidecode. Получаем информацию о железе

  dmidecode -t bios  # Смотрим информацию о BIOS (код, вшитый в материнскую плату компьютера)
# dmidecode -t baseboard  # Смотрим информацию о материнской плате
# dmidecode -t connector  # Смотрим информацию о разьемах на материнской плате
# dmidecode -t memory  # Информация о установленных модулях памяти и колличестве слотов под нее
# dmidecode -t system  # Смотрим информацию об аппаратном обеспечении
# dmidecode -t processor  # Смотрим информацию о центральном процессоре (CPU)

  free -m  # Просмотреть объём используемой и свободной оперативной памяти, имеющейся в системе

  lsscsi  # Посмотрим список установленных SCSI-устройств

  lsblk -f  # Смотрим, какие диски есть в нашем распоряжении

  sgdisk -p /dev/sda  #  Смотрим структуру диска созданного установщиком
# sgdisk -p /dev/$cfd  # sda; sdb; sdc; sdd  # Посмотрим структуру диска созданного установщиком

# sgdisk --zap-all /dev/$cfd   # sda; sdb; sdc; sdd  # Удалить (стереть) таблицу разделов на выбранном диске (sdX)

#cat << _EOF_ > create.disks
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
  echo t;
  echo 2;
#  echo L;
  echo 82;
  
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
#_EOF_

#   fdisk /dev/sda < create.disks

  fdisk -l  # Ещё раз проверте правильность разбивки на разделы!
  lsblk -f

  mkfs.ext2  /dev/sda1 -L boot
  mkswap /dev/sda2 -L swap
  mkfs.ext4  /dev/sda3 -L root
  mkfs.ext4  /dev/sda4 -L home 

  mount /dev/sda3 /mnt
  mkdir /mnt/{boot,home}
  mount /dev/sda1 /mnt/boot
  swapon /dev/sda2
  mount /dev/sda4 /mnt/home

  pacman -S --noconfirm --needed reflector  # Модуль и сценарий Python 3 для получения и фильтрации последнего списка зеркал Pacman

  reflector --verbose --country 'Russia' -l 9 -p https -p http -n 9 --save /etc/pacman.d/mirrorlist --sort rate

  cat /mnt/etc/pacman.d/mirrorlist

  pacman -Sy

  pacstrap -i /mnt base base-devel nano dhcpcd netctl which inetutils --noconfirm

  pacstrap -i /mnt linux-lts linux-firmware linux-lts-headers linux-lts-docs --noconfirm

  genfstab -pU /mnt >> /mnt/etc/fstab

  cat /mnt/etc/fstab

  blkid /dev/sd*

  sed -i 's/ischroot=0/ischroot=1/' ./install_arch.sh
  cp ./install_arch.sh /mnt/install_arch.sh

  arch-chroot /mnt /bin/bash -x << _EOF_
sh /install_arch.sh
_EOF_

fi

if [ $ischroot -eq 1 ]
then

  ping -c2 archlinux.org

  timedatectl set-ntp true

  timedatectl status

  pacman -Syyu --noconfirm

  pacman -S lvm2 --noconfirm  # Утилиты Logical Volume Manager 2 (https://sourceware.org/lvm2/)
  
  echo Terminator > /etc/hostname
  
  ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  cp /etc/localtime /etc/localtime.backup
  echo $timezone > /etc/timezone
  date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'
  hwclock --systohc
# hwclock --systohc --utc  
# hwclock --systohc --local
  timedatectl show
  
  echo "127.0.0.1 localhost.(none)" > /etc/hosts
  echo "127.0.1.1 $hostname" >> /etc/hosts
  echo "::1 localhost ip6-localhost ip6-loopback" >> /etc/hosts
  echo "ff02::1 ip6-allnodes" >> /etc/hosts
  echo "ff02::2 ip6-allrouters" >> /etc/hosts

# echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
# echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
  sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

  locale-gen 

  echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
# echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
# export LANG=ru_RU.UTF-8
# export LANG=en_US.UTF-8

# echo LANG=ru_RU.UTF-8 > /etc/locale.conf
# export LANG=en_US.UTF-8

  echo 'KEYMAP=ru' >> /etc/vconsole.conf
  echo '#LOCALE=ru_RU.UTF-8' >> /etc/vconsole.conf
  echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
  echo '#FONT=ter-v16n' >> /etc/vconsole.conf
  echo '#FONT=ter-v16b' >> /etc/vconsole.conf
  echo '#FONT=ter-u16b' >> /etc/vconsole.conf
  echo 'FONT_MAP=' >> /etc/vconsole.conf
  echo '#CONSOLEFONT="cyr-sun16' >> /etc/vconsole.conf
  echo 'CONSOLEMAP=' >> /etc/vconsole.conf
  echo '#TIMEZONE=Europe/Moscow' >> /etc/vconsole.conf
  echo '#HARDWARECLOCK=UTC' >> /etc/vconsole.conf
  echo '#HARDWARECLOCK=localtime' >> /etc/vconsole.conf
  echo '#USECOLOR=yes' >> /etc/vconsole.conf
  echo 'COMPRESSION="lz4"' >> /etc/mkinitcpio.conf 
# echo 'COMPRESSION="xz"' >> /etc/mkinitcpio.conf
  echo "vboxdrv" > /etc/modules-load.d/virtualbox.conf

  dmesg | grep microcode

  pacman -S amd-ucode --noconfirm

  pacman -S intel-ucode --noconfirm

  pacman -S iucode-tool --noconfirm

  mkinitcpio -p linux-lts
  
  pacman -Syy

  pacman -S --noconfirm --needed grub

  uname -rm
  lsblk -f
#  grub-install /dev/sda
  grub-install --recheck /dev/sda

  pacman -S os-prober mtools fuse --noconfirm

  grub-mkconfig -o /boot/grub/grub.cfg

  pacman -S dialog wpa_supplicant iw wireless_tools net-tools --noconfirm

  useradd -m -g users -G adm,audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash alex
# useradd -m -g users -G audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash $username
# useradd -m -g users -G wheel -s /bin/bash $username

  pacman -S --noconfirm --needed sudo
# pacman -S sudo --noconfirm 

  sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
# sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

  sed -i 's/#Color/Color/' /etc/pacman.conf
# sed -i '/#Color/ s/^#//' /etc/pacman.conf
  sed -i '/^Co/ aILoveCandy' /etc/pacman.conf
  sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
# echo '[multilib]' >> /etc/pacman.conf
# echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

  pacman -Sy   #--noconfirm --noprogressbar --quiet
# pacman -Syy --noconfirm --noprogressbar --quiet

  lspci | grep -e VGA -e 3D
  lspci -nn | grep VGA

  pacman -Syy --noconfirm --noprogressbar --quiet

  pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm

# pacman -S xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils --noconfirm 

# pacman -S mesa xorg-apps xorg-twm xterm xorg-xclock xf86-input-synaptics --noconfirm 

# modprobe -a vboxguest vboxsf vboxvideo
# cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
# echo -e "\nvboxguest\nvboxsf\nvboxvideo" >> /home/$username/.xinitrc
# sed -i 's/#!\/bin\/sh/#!\/bin\/sh\n\/usr\/bin\/VBoxClient-all/' /home/$username/.xinitrc

  pacman -S xfce4 xfce4-goodies --noconfirm

  pacman -S --noconfirm --needed xorg-xinit

  cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc # копируем файл .xinitrc в каталог пользователя
  chown $username:users /home/$username/.xinitrc  # даем доступ пользователю к файлу
  chmod +x /home/$username/.xinitrc   # получаем права на исполнения скрипта
  sed -i 52,55d /home/$username/.xinitrc  # редактируем файл -> и прописываем команду на запуск
### Данные блоки нужны для того, чтобы StartX автоматически запускал нужное окружение, соответственно в секции Window Manager of your choice раскомментируйте нужную сессию
  echo "exec startxfce4 " >> /home/$username/.xinitrc  
  mkdir /etc/systemd/system/getty@tty1.service.d/  # создаём папку
  echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
  echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
  echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
### Делаем автоматический запуск Иксов в нужной виртуальной консоли после залогинивания нашего пользователя
  echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile 

  pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm
  pacman -S light-locker --noconfirm

# systemctl enable lightdm.service
  systemctl enable lightdm.service -f

  pacman -S networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm
# pacman -Sy networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm

# systemctl enable NetworkManager
  systemctl enable NetworkManager.service

# systemctl enable dhcpcd   # для активации проводных соединений
  systemctl enable dhcpcd.service

       pacman -S ttf-dejavu --noconfirm  # Семейство шрифтов на основе Bitstream Vera Fonts с более широким набором символов

       pacman -S ttf-liberation --noconfirm  # Шрифты Red Hats Liberation

       pacman -S ttf-anonymous-pro --noconfirm  # Семейство из четырех шрифтов фиксированной ширины, разработанных специально с учетом кодирования

       pacman -S terminus-font --noconfirm  # Моноширинный растровый шрифт (для X11 и консоли)

       pacman -S ntfs-3g --noconfirm  # Драйвер и утилиты файловой системы NTFS; "NTFS file support (Windows Drives)"

       pacman -S wget git --noconfirm  #curl  - пока присутствует в pkglist.x86_64

  echo $SHELL

       pacman -S zsh zsh-syntax-highlighting zsh-autosuggestions grml-zsh-config --noconfirm
       pacman -S zsh-completions zsh-history-substring-search  --noconfirm  
       echo 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> /etc/zsh/zshrc
       echo 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> /etc/zsh/zshrc
#      echo 'prompt adam2' >> /etc/zsh/zshrc
       echo 'prompt fire' >> /etc/zsh/zshrc 
       
       chsh -s /bin/zsh
       chsh -s /bin/zsh $username
       echo " Важно! При первом запуске консоли (терминала) - нажмите "0" "
       echo " Пользовательская оболочка ИЗМЕНЕНА (сразу будет), с BASH на на ZSH "

       pacman -S xdg-user-dirs --noconfirm  # Управляйте пользовательскими каталогами, такими как ~ / Desktop и ~ / Music
#      pacman -S xdg-user-dirs-gtk --noconfirm  # Создаёт каталоги пользователей и просит их переместить
       xdg-user-dirs-update 
#      xdg-user-dirs-gtk-update  # Обновить закладки в thunar (левое меню)

echo " Посмотрим дату и время ... "
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'     # одновременно отображает дату и часовой пояс

echo " Отобразить время работы системы ... "
uptime  # Отобразить время работы системы ...
 
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

arch-chroot /mnt /bin/bash -x << _EOF_
passwd -Sa  # -S, --status вывести статус пароля
_EOF_


umount -R /mnt/boot
umount -R /mnt
reboot








