#!/bin/bash
# set -e  # Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
apptitle=""
baseurl=
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

  pacman -S --noconfirm --needed reflector

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
       
#       chsh -s /bin/zsh
#       chsh -s /bin/zsh $username
# echo " Важно! При первом запуске консоли (терминала) - нажмите "0" "
# echo " Пользовательская оболочка ИЗМЕНЕНА (сразу будет), с BASH на на ZSH "

### AUR Helper - (yay) ### 
  pacman -Syu    
# pacman -S --noconfirm --needed wget curl git
  cd /home/$username
  git clone https://aur.archlinux.org/yay-bin.git
  chown -R $username:users /home/$username/yay-bin   #-R, --recursive - рекурсивная обработка всех подкаталогов;
  chown -R $username:users /home/$username/yay-bin/PKGBUILD  #-R, --recursive - рекурсивная обработка всех подкаталогов;
  cd /home/$username/yay-bin  
# sudo -u $username  makepkg -si --noconfirm   #-Не спрашивать каких-либо подтверждений  
  sudo -u $username  makepkg -si --skipinteg   #-Не проверять целостность исходных файлов   
  rm -Rf /home/$username/yay-bin    # удаляем директорию сборки

  yay -Syy  # Обновление баз данных пакетов через - AUR (Yay)
  yay -Syu  # Обновление баз данных пакетов, и системы через - AUR (Yay)

##### pamac-aur ###### 
  cd /home/$username
  git clone https://aur.archlinux.org/pamac-aur.git
  chown -R $username:users /home/$username/pamac-aur
  chown -R $username:users /home/$username/pamac-aur/PKGBUILD 
  cd /home/$username/pamac-aur
  sudo -u $username  makepkg -si --noconfirm   #-Не спрашивать каких-либо подтверждений 
# sudo -u $username  makepkg -si --skipinteg   #-Не проверять целостность исходных файлов   
# makepkg --noconfirm --needed -sic 
  rm -Rf /home/$username/pamac-aur 

       pacman -S xdg-user-dirs --noconfirm  # Управляйте пользовательскими каталогами, такими как ~ / Desktop и ~ / Music
#      pacman -S xdg-user-dirs-gtk --noconfirm  # Создаёт каталоги пользователей и просит их переместить
       xdg-user-dirs-update 
#      xdg-user-dirs-gtk-update  # Обновить закладки в thunar (левое меню)

  pacman -Sy   #--noconfirm --noprogressbar --quiet

       pacman -S ufw gufw --noconfirm  # Несложный и простой в использовании инструмент командной строки для управления межсетевым экраном netfilter; GUI - для управления брандмауэром Linux
#      ufw enable  # Запускаем UFW (сетевой экран)
#      ufw status  # Проверим статус запуска Firewall UFW
       systemctl enable ufw  # Добавляем в автозагрузку UFW (сетевой экран)

       pacman -S clamav clamtk --noconfirm  # Антивирусный движок с открытым исходным кодом для обнаружения троянов, вирусов, вредоносных программ и других вредоносных угроз

       pacman -S bluez bluez-libs bluez-cups bluez-utils --noconfirm  # Демоны для стека протоколов Bluetooth; Устаревшие библиотеки для стека протоколов Bluetooth; Серверная часть CUPS для принтеров Bluetooth; Утилиты разработки и отладки для стека протоколов bluetooth.

       pacman -S alsa-utils alsa-plugins alsa-firmware alsa-lib --noconfirm  # Расширенная звуковая архитектура Linux - Утилиты; Дополнительные плагины ALSA; Бинарные файлы прошивки для программ загрузки в alsa-tools и загрузчик прошивок hotplug; Альтернативная реализация поддержки звука Linux
       pacman -S lib32-alsa-plugins --noconfirm  # Дополнительные плагины ALSA (32-бит)
       pacman -S alsa-oss lib32-alsa-oss --noconfirm  # Библиотека совместимости OSS; Библиотека совместимости OSS (32 бит)
#      pacman -S alsa-tools --noconfirm  # Расширенные инструменты для определенных звуковых карт
       pacman -S alsa-topology-conf alsa-ucm-conf --noconfirm  # Файлы конфигурации топологии ALSA; Конфигурация (и топологии) ALSA Use Case Manager
       pacman -S alsa-card-profiles --noconfirm  # Профили карт ALSA, общие для PulseAudio
       pacman -S pulseaudio pulseaudio-alsa pavucontrol pulseaudio-bluetooth pulseaudio-equalizer-ladspa --noconfirm
#      pacman -S pulseaudio --noconfirm  # Функциональный звуковой сервер общего назначения
#      pacman -S pulseaudio-alsa --noconfirm  # Конфигурация ALSA для PulseAudio 
#      pacman -S pavucontrol --noconfirm  # Регулятор громкости PulseAudio
#      pacman -S pulseaudio-bluetooth --noconfirm  # Поддержка Bluetooth для PulseAudio
#      pacman -S pulseaudio-equalizer-ladspa --noconfirm  # 15-полосный эквалайзер для PulseAudio
### pacman -S pulseaudio-equalizer --noconfirm  # Графический эквалайзер для PulseAudio
       pacman -S pulseaudio-zeroconf --noconfirm  # Поддержка Zeroconf для PulseAudio
#      pacman -S pulseaudio-lirc --noconfirm  # Поддержка IR (lirc) для PulseAudio
#      pacman -S pulseaudio-jack --noconfirm  # Поддержка разъема для PulseAudio
#      pacman -S pasystray --noconfirm  # Системный трей PulseAudio (замена # padevchooser)  
       pacman -S xfce4-pulseaudio-plugin --noconfirm  # Плагин Pulseaudio для панели Xfce4 
#      pacman -Sy pavucontrol pulseaudio-bluetooth alsa-utils pulseaudio-equalizer-ladspa --noconfirm

       pacman -S blueman --noconfirm  # blueman --диспетчер bluetooth устройств (полезно для i3)
       modprobe btusb  # Загрузите универсальный драйвер bluetooth, если это еще не сделано
       systemctl start bluetooth.service  # Запускаем (bluetooth.service)
#      systemctl start dbus
       systemctl enable bluetooth.service  # Добавляем в автозагрузку (bluetooth.service)  
      
       pacman -S zip unzip unrar p7zip zlib zziplib --noconfirm  # Компрессор / архиватор для создания и изменения zip-файлов; Для извлечения и просмотра файлов в архивах .zip; Программа распаковки RAR; Файловый архиватор из командной строки с высокой степенью сжатия; Библиотека сжатия, реализующая метод сжатия deflate, найденный в gzip и PKZIP; Легкая библиотека, которая предлагает возможность легко извлекать данные из файлов, заархивированных в один zip-файл. 
       pacman -S lha unace lrzip sharutils arj cabextract --noconfirm # Бесплатная программа для архивирования LZH / LHA; Инструмент для извлечения проприетарного формата архива ace; Многопоточное сжатие с помощью rzip / lzma, lzo и zpaq; Делает так называемые архивы оболочки из множества файлов; Бесплатный и портативный клон архиватора ARJ; Программа для извлечения файлов Microsoft CAB (.CAB).
       pacman -S uudeview --noconfirm  # UUDeview помогает передавать и получать двоичные файлы с помощью почты или групп новостей. Включает файлы библиотеки - (мощный декодер бинарных файлов) http://www.fpx.de/fp/Software/UUDeview/
       pacman -S snappy --noconfirm  # Библиотека быстрого сжатия и распаковки (на порядок быстрее других) https://github.com/google/snappy
       pacman -S minizip --noconfirm  # Mini zip и unzip на основе zlib
       pacman -S quazip --noconfirm  # Оболочка C ++ для пакета C ZIP / UNZIP Жиля Воллана
       pacman -S brotli --noconfirm  # Универсальный алгоритм сжатия без потерь, который сжимает данные с использованием комбинации современного варианта алгоритма LZ77, кодирования Хаффмана и контекстного моделирования 2-го порядка со степенью сжатия, сопоставимой с лучшими доступными в настоящее время универсальными методами сжатия.
       pacman -S pbzip2 --noconfirm  #  Параллельная реализация компрессора файлов с сортировкой блоков bzip2

       pacman -S file-roller --noconfirm  # легковесный архиватор ( для xfce-lxqt-lxde-gnome ) 
#      pacman -S ark --noconfirm  # архиватор для ( Plasma(kde)- так же можно использовать, и для другого de )       
#      pacman -S xarchiver-gtk2 --noconfirm  # легкий настольный независимый менеджер архивов 

       pacman -S accountsservice --noconfirm  # Интерфейс D-Bus для запроса учетных записей пользователей и управления ими
       pacman -S acpi --noconfirm  # Клиент для показаний батареи, мощности и температуры
       pacman -S acpid --noconfirm  # Демон для доставки событий управления питанием ACPI с поддержкой netlink
       pacman -S android-tools --noconfirm  # Инструменты платформы Android
       pacman -S android-udev --noconfirm  # Правила Udev для подключения устройств Android к вашему Linux-серверу
       pacman -S arch-install-scripts --noconfirm  # Сценарии для помощи в установке Arch Linux
       pacman -S aspell-en --noconfirm  # Английский словарь для aspell
       pacman -S aspell-ru --noconfirm  # Русский словарь для aspell
       pacman -S autofs --noconfirm  # Средство автомонтирования на основе ядра для Linux
       pacman -S b43-fwcutter --noconfirm  # Экстрактор прошивки для модуля ядра b43 (драйвер) 
       pacman -S bash-completion --noconfirm  # Программируемое завершение для оболочки bash
       pacman -S beep --noconfirm  # Продвинутая программа звукового сигнала динамика ПК
       pacman -S bind --noconfirm  # Полная, переносимая реализация протокола DNS
       pacman -S btrfs-progs --noconfirm  # Утилиты файловой системы btrfs
       pacman -S busybox --noconfirm  # Утилиты для аварийно-спасательных и встраиваемых систем
       pacman -S c-ares --noconfirm   # Библиотека AC для асинхронных DNS-запросов
       pacman -S ccache --noconfirm  # Кэш компилятора, который ускоряет перекомпиляцию за счет кеширования предыдущих компиляций
       pacman -S cmake --noconfirm  # Кросс-платформенная система сборки с открытым исходным кодом
       pacman -S cpio --noconfirm  # Инструмент для копирования файлов в или из архива cpio или tar
       pacman -S cpupower --noconfirm  # Инструмент ядра Linux для проверки и настройки функций вашего процессора, связанных с энергосбережением
       pacman -S crda --noconfirm  # Агент центрального регулирующего домена для беспроводных сетей
       pacman -S davfs2 --noconfirm  # Драйвер файловой системы, позволяющий монтировать папку WebDAV
       pacman -S desktop-file-utils --noconfirm  # Утилиты командной строки для работы с записями рабочего стола
       pacman -S dhclient --noconfirm  # Автономный DHCP-клиент из пакета dhcp
       pacman -S dnsmasq --noconfirm  # Легкий, простой в настройке сервер пересылки DNS и DHCP-сервер
       pacman -S dosfstools --noconfirm  # Утилиты файловой системы DOS
       pacman -S efibootmgr --noconfirm  # Приложение пользовательского пространства Linux для изменения диспетчера загрузки EFI
       pacman -S efitools --noconfirm  # Инструменты для управления платформами безопасной загрузки UEFI
       pacman -S ethtool --noconfirm  # Утилита для управления сетевыми драйверами и оборудованием
       pacman -S f2fs-tools --noconfirm  # Инструменты для файловой системы, дружественной к Flash (F2FS)
       pacman -S flex --noconfirm  # Инструмент для создания программ сканирования текста
       pacman -S fortune-mod --noconfirm  # Программа Fortune Cookie от BSD games
       pacman -S fsarchiver --noconfirm  # Безопасный и гибкий инструмент для резервного копирования и развертывания файловой системы
       pacman -S fuse3 --noconfirm  # Библиотека, позволяющая реализовать файловую систему в программе пользовательского пространства
       pacman -S glances --noconfirm  # Инструмент мониторинга на основе CLI на основе curses
       pacman -S gnome-nettool --noconfirm  # Графический интерфейс для различных сетевых инструментов
       pacman -S gnu-netcat --noconfirm  # GNU переписывает netcat, приложение для создания сетевых трубопроводов
       pacman -S gpm --noconfirm  # Сервер мыши для консоли и xterm
       pacman -S gptfdisk --noconfirm  # Инструмент для создания разделов в текстовом режиме, который работает с дисками с таблицей разделов GUID (GPT)
#      pacman -S grub-btrfs --noconfirm  # Включите снимки btrfs в параметры загрузки GRUB
       pacman -S gtop --noconfirm  # Панель мониторинга системы для терминала
       pacman -S gvfs --noconfirm  # Реализация виртуальной файловой системы для GIO (Разделенные пакеты: gvfs-afc, gvfs-goa, gvfs-google, gvfs-gphoto2, gvfs-mtp, еще…)
#      pacman -S gvfs-mtp --noconfirm  # Реализация виртуальной файловой системы для GIO (бэкэнд MTP; Android, медиаплеер)
#      pacman -S gvfs-afc --noconfirm  # Реализация виртуальной файловой системы для GIO (серверная часть AFC; мобильные устройства Apple)
#      pacman -S gvfs-goa --noconfirm  # Реализация виртуальной файловой системы для GIO (серверная часть Gnome Online Accounts; облачное хранилище) 
#      pacman -S gvfs-google --noconfirm  # Реализация виртуальной файловой системы для GIO (серверная часть Google Диска)
       pacman -S gvfs-gphoto2 --noconfirm  # Реализация виртуальной файловой системы для GIO (бэкэнд gphoto2; камера PTP, медиаплеер MTP)
       pacman -S gvfs-nfs --noconfirm  # Реализация виртуальной файловой системы для GIO (серверная часть NFS)
       pacman -S gvfs-smb --noconfirm  # Реализация виртуальной файловой системы для GIO (серверная часть SMB / CIFS; клиент Windows)
       pacman -S haveged --noconfirm  # Демон сбора энтропии с использованием таймингов процессора
       pacman -S hddtemp --noconfirm  # Показывает температуру вашего жесткого диска, читая информацию SMART
       pacman -S hidapi --noconfirm  # Простая библиотека для связи с устройствами USB и Bluetooth HID
       pacman -S hwinfo --noconfirm  # Инструмент обнаружения оборудования от openSUSE
       pacman -S hydra --noconfirm  # Очень быстрый взломщик входа в сеть, который поддерживает множество различных сервисов
       pacman -S hyphen-en --noconfirm  # Правила расстановки переносов в английском
       pacman -S id3lib --noconfirm  # Библиотека для чтения, записи и управления тегами ID3v1 и ID3v2
       pacman -S iftop --noconfirm  # Отображение использования полосы пропускания на интерфейсе
#      pacman -S inetutils --noconfirm  # Сборник общих сетевых программ   # присутствует
       pacman -S isomd5sum --noconfirm  # Утилиты для работы с md5sum, имплантированными в ISO-образы
       pacman -S jfsutils --noconfirm  # Утилиты файловой системы JFS
       pacman -S lib32-curl --noconfirm  # Утилита и библиотека для поиска URL (32-разрядная версия)
       pacman -S lib32-flex --noconfirm  # Инструмент для создания программ сканирования текста
       pacman -S libfm-gtk2 --noconfirm  # Библиотека GTK + 2 для управления файлами
#      pacman -S light-locker --noconfirm  # Простой шкафчик сессий для LightDM   # присутствует
       pacman -S lksctp-tools --noconfirm  # Реализация протокола SCTP (http://lksctp.sourceforge.net/)
       pacman -S logrotate --noconfirm  # Автоматическая ротация системных журналов
       pacman -S lsb-release --noconfirm  # Программа запроса версии LSB   # присутствует
       pacman -S lsof --noconfirm  # Перечисляет открытые файлы для запуска процессов Unix
       pacman -S man-db --noconfirm  # Утилита для чтения страниц руководства
       pacman -S man-pages --noconfirm  # Страницы руководства Linux
       pacman -S mc --noconfirm  # Файловый менеджер, эмулирующий Norton Commander
       pacman -S memtest86+ --noconfirm  # Усовершенствованный инструмент диагностики памяти
       pacman -S mlocate --noconfirm  # Слияние реализации locate / updatedb
       pacman -S mtpfs --noconfirm  # Файловая система FUSE, поддерживающая чтение и запись с любого устройства MTP
       pacman -S ncdu --noconfirm  # Анализатор использования диска с интерфейсом ncurses
       pacman -S nfs-utils --noconfirm  # Программы поддержки для сетевых файловых систем
       pacman -S nss-mdns --noconfirm  # Плагин glibc, обеспечивающий разрешение имени хоста через mDNS
### pacman -S openbsd-netcat --noconfirm  #  Швейцарский армейский нож TCP / IP. Вариант OpenBSD (Важно конфликтует с gnu-netcat - GNU переписывает netcat, приложение для создания сетевых трубопроводов)
#      pacman -S pacman-contrib --noconfirm  # Предоставленные скрипты и инструменты для систем pacman  # присутствует
       pacman -S patchutils --noconfirm  # Небольшая коллекция программ, работающих с файлами патчей
       pacman -S pciutils --noconfirm  # Библиотека и инструменты доступа к пространству конфигурации шины PCI
       pacman -S php --noconfirm  # Язык сценариев общего назначения, особенно подходящий для веб-разработки
       pacman -S poppler-data --noconfirm  # Кодирование данных для библиотеки рендеринга PDF Poppler
       pacman -S powertop --noconfirm  # Инструмент для диагностики проблем с энергопотреблением и управлением питанием
       pacman -S pv --noconfirm  # Инструмент на основе терминала для мониторинга прохождения данных по конвейеру
       pacman -S pwgen --noconfirm  # Генератор паролей для создания легко запоминающихся паролей
#      pacman -S python --noconfirm  # Новое поколение языка сценариев высокого уровня Python  # присутствует
#      pacman -S python2 --noconfirm  # Язык сценариев высокого уровня Python (Конфликты: python <3) # возможно присутствует
       pacman -S python-isomd5sum --noconfirm  # Привязки Python3 для isomd5sum
       pacman -S python-pip --noconfirm  # Рекомендуемый PyPA инструмент для установки пакетов Python
       pacman -S qt5-translations --noconfirm  # кросс-платформенное приложение и UI-фреймворк (переводы)
       pacman -S reiserfsprogs --noconfirm  # Утилиты Reiserfs
       pacman -S ruby --noconfirm  # Объектно-ориентированный язык для быстрого и простого программирования
       pacman -S s-nail --noconfirm  # Среда для отправки и получения почты
       pacman -S sane --noconfirm  # Доступ к сканеру теперь простой
       pacman -S scrot --noconfirm  # Простая утилита для создания снимков экрана из командной строки для X
       pacman -S sg3_utils --noconfirm  # Универсальные утилиты SCSI
       pacman -S sdparm --noconfirm  # Утилита, аналогичная hdparm, но для устройств SCSI
       pacman -S sof-firmware --noconfirm  # Звук открыть прошивку
       pacman -S solid --noconfirm  # Аппаратная интеграция и обнаружение
       pacman -S sox --noconfirm  # Швейцарский армейский нож инструментов обработки звука
       pacman -S smartmontools --noconfirm  # Управление и мониторинг жестких дисков ATA и SCSI с поддержкой SMAR
       pacman -S speedtest-cli --noconfirm  # Интерфейс командной строки для тестирования пропускной способности интернета с помощью speedtest.net
       pacman -S squashfs-tools --noconfirm  # Инструменты для squashfs, файловой системы Linux с высокой степенью сжатия, доступной только для чтения 
       pacman -S syslinux --noconfirm  # Коллекция загрузчиков, которые загружаются с файловых систем FAT, ext2 / 3/4 и btrfs, с компакт-дисков и через PXE
       pacman -S systemd-ui --noconfirm  # Графический интерфейс для systemd
       pacman -S termite --noconfirm  #  Простой терминал на базе VTE
       pacman -S termite-terminfo --noconfirm  # Terminfo для Termite, простого терминала на базе VTE
       pacman -S translate-shell --noconfirm  # Интерфейс командной строки и интерактивная оболочка для Google Translate
       pacman -S udiskie --noconfirm  # Автоматическое монтирование съемных дисков с использованием udisks
       pacman -S usb_modeswitch --noconfirm  # Активация переключаемых USB-устройств в Linux
       pacman -S wimlib --noconfirm  # Библиотека и программа для извлечения, создания и изменения файлов WIM
       pacman -S xsel --noconfirm  # XSel - это программа командной строки для получения и установки содержимого выделения X
       pacman -S xterm --noconfirm  # Эмулятор терминала X
#      pacman -S xorg-xclock --noconfirm  # X часы
       pacman -S xorg-twm --noconfirm  # Вкладка Window Manager для системы X Window
       pacman -S xorg-xkill --noconfirm  # Убить клиента его X-ресурсом
       pacman -S yelp --noconfirm  # Получите помощь с GNOME
       pacman -S youtube-dl --noconfirm  # Программа командной строки для загрузки видео с YouTube.com и еще нескольких 

       pacman -S htop iotop --noconfirm  # Интерактивный просмотрщик запущенных процессов; просмотр процессов ввода-вывода по использованию жесткого диска
#      pacman -S atop --noconfirm  # Сбор статистики и наблюдение за системой в реальном времени

       pacman -S screenfetch --noconfirm  # Скрипт CLI Bash для отображения информации о системе
       pacman -S neofetch --noconfirm  # Инструмент системной информации CLI, написанный на BASH, который поддерживает отображение изображений
       pacman -S archey3 --noconfirm  # Простой скрипт Python, который печатает основную системную информацию и ASCII-изображение логотипа Arch Linux

       pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore libdvdcss libdvdread libdvdnav dvd+rw-tools dvdauthor dvgrab cdrdao gpac --noconfirm 
       pacman -S gstreamer gstreamer-vaapi gst-libav gst-plugins-bad gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly --noconfirm   # https://gstreamer.freedesktop.org/

       pacman -S audacious audacious-plugins --noconfirm  # Легкий, продвинутый аудиоплеер, ориентированный на качество звука
       pacman -S smplayer smplayer-skins smplayer-themes smtube --noconfirm  # Медиаплеер со встроенными кодеками, который может воспроизводить практически все видео и аудио форматы
       pacman -S vlc --noconfirm  # Многоплатформенный проигрыватель MPEG, VCD / DVD и DivX 
       
       pacman -S gedit gedit-plugins --noconfirm  # Текстовый редактор GNOME
       gsettings set org.gnome.gedit.preferences.encodings candidate-encodings "['UTF-8', 'WINDOWS-1251', 'KOI8-R', 'CURRENT', 'ISO-8859-15', 'UTF-16']"

       pacman -S geany geany-plugins --noconfirm  # Быстрая и легкая IDE

       pacman -S thunderbird thunderbird-i18n-ru --noconfirm  # программа для чтения почты и новостей от mozilla.org
#      pacman -S thunderbird-i18n-en-us --noconfirm  # Английский (США) языковой пакет для Thunderbird

       pacman -S pidgin pidgin-hotkeys --noconfirm  # клиент обмена мгновенными сообщениями

       pacman -S firefox --noconfirm  # Автономный веб-браузер от mozilla.org
       pacman -S firefox-i18n-ru --noconfirm  # Русский языковой пакет для Firefox
       pacman -S firefox-spell-ru --noconfirm  # Русский словарь проверки орфографии для Firefox
       pacman -S firefox-ublock-origin --noconfirm  # Надстройка эффективного блокировщика для различных браузеров.

       pacman -S transmission-gtk transmission-cli --noconfirm  # графический интерфейс GTK 3, и демон, с CLI
#      pacman -S transmission-qt transmission-cli --noconfirm  # графический интерфейс Qt 5, и демон, с CLI
#      pacman -S qbittorrent --noconfirm  # Усовершенствованный клиент BitTorrent, написанный на C ++, основанный на инструментарии Qt и libtorrent-rasterbar
#      pacman -S deluge --noconfirm  # BitTorrent-клиент написанное на Python 3, с несколькими пользовательскими интерфейсами в модели клиент / сервер

       pacman -S libreoffice-still --noconfirm  # Филиал обслуживания LibreOffice
       pacman -S libreoffice-still-ru --noconfirm  # Пакет русского языка для LibreOffice still
       pacman -S libreoffice-extension-writer2latex --noconfirm  # набор расширений LibreOffice для преобразования и работы с LaTeX в LibreOffice
       pacman -S hunspell --noconfirm  # Библиотека и программа для проверки орфографии и морфологического анализатора
       pacman -S hyphen --noconfirm  # Библиотека для качественной расстановки переносов и выравнивания
       pacman -S mythes --noconfirm  # libmythes  Простой тезаурус (Словарь понятий или терминов). В нем можно найти слова синонимы или антонимы к интересующему понятию (слову, термину).
       pacman -S unoconv --noconfirm  # Конвертер документов на основе Libreoffice

#      pacman -S libreoffice-fresh --noconfirm  # Ветвь LibreOffice, содержащая новые функции и улучшения программы
#      pacman -S libreoffice-fresh-ru --noconfirm  # Пакет русского языка для LibreOffice Fresh

       pacman -S gparted --noconfirm  # (создавать, удалять, перемещать, копировать, изменять размер и др.) без потери данных.
       pacman -S grub-customizer --noconfirm  # Графический менеджер настроек grub2
       pacman -S dconf-editor --noconfirm  # редактор dconf
       pacman -S conky conky-manager --noconfirm  # Легкий системный монитор для X; Графический интерфейс для управления конфигурационными файлами Conky с возможностью просмотра и редактирования тем
       pacman -S obs-studio --noconfirm  # для записи видео и потокового вещания
       pacman -S filezilla --noconfirm  # графический клиент для работы с FTP/SFTP
       pacman -S telegram-desktop --noconfirm  # Официальный клиент Telegram Desktop
       pacman -S discord --noconfirm  # Единый голосовой и текстовый чат для геймеров
       pacman -S flameshot --noconfirm  # для создания снимков экрана
       pacman -S redshift --noconfirm  # Регулирует цветовую температуру экрана в соответствии с окружающей обстановкой (временем суток)
       pacman -S bleachbit --noconfirm  # Это мощное приложение, предназначенное для тщательной очистки компьютера и удаления ненужных файлов, что помогает освободить место на дисках и удалить конфиденциальные данные.
       pacman -S cherrytree --noconfirm  # Приложение для создания иерархических заметок 
       pacman -S doublecmd-gtk2 --noconfirm  # двухпанельный файловый менеджер (GTK2)
       pacman -S keepass --noconfirm  # Простой в использовании менеджер паролей для Windows, Linux, Mac OS X и мобильных устройств
#      pacman -S keepassxc --noconfirm  # менеджер паролей
       pacman -S veracrypt --noconfirm  # Шифрование диска с надежной защитой на основе TrueCrypt
       pacman -S nomacs --noconfirm  # для просмотра изображений Qt
       pacman -S onboard --noconfirm  # Экранная клавиатура
       pacman -S meld --noconfirm  # для сравнения файлов, каталогов и рабочих копий
       pacman -S plank --noconfirm  # самая элегантная, простая док-панель в мире для linux
       pacman -S uget --noconfirm  # менеджер загрузок
       pacman -S openshot --noconfirm  # Бесплатный видеоредактор
#      pacman -S galculator-gtk2 --noconfirm  # Научный калькулятор на основе GTK + (версия GTK2)
       pacman -S galculator --noconfirm  # Научный калькулятор на основе GTK + (версия GTK3) (Обратные конфликты: galculator-gtk2)
#      pacman -S gnome-calculator --noconfirm  # Научный калькулятор GNOME

       pacman -S edk2-ovmf --noconfirm  # Прошивки для виртуальных машин (x86_64, i686)  
       pacman -S gnome-system-monitor --noconfirm  # Просмотр текущих процессов и мониторинг состояния системы
       pacman -S gnome-disk-utility --noconfirm  # Утилита управления дисками для GNOME
       pacman -S gnome-multi-writer --noconfirm  # Записать файл ISO на несколько USB-устройств одновременно
       pacman -S gpart --noconfirm  # Инструмент для спасения / угадывания таблицы разделов
       pacman -S frei0r-plugins --noconfirm  # Минималистичный плагин API для видеоэффектов
       pacman -S fuseiso --noconfirm  # Модуль FUSE для монтирования образов файловой системы ISO
       pacman -S clonezilla --noconfirm  # Раздел ncurses и программа для создания образов / клонирования дисков
       pacman -S crypto++ --noconfirm  # Бесплатная библиотека классов C ++ криптографических схем
       pacman -S psensor --noconfirm  # Графический аппаратный монитор температуры для Linux
       pacman -S copyq --noconfirm  # Менеджер буфера обмена с возможностью поиска и редактирования истории
       pacman -S rsync --noconfirm  # Быстрый и универсальный инструмент для копирования удаленных и локальных файлов
       pacman -S grsync --noconfirm  # GTK + GUI для rsync для синхронизации папок, файлов и создания резервных копий
       pacman -S numlockx --noconfirm  # Включает клавишу numlock в X11
       pacman -S modem-manager-gui --noconfirm  # Интерфейс для демона ModemManager, способного управлять определенными функциями модема
       pacman -S pacmanlogviewer --noconfirm  # Проверьте файлы журнала pacman
       pacman -S rofi --noconfirm  # Переключатель окон, средство запуска приложений и замена dmenu
       pacman -S gsmartcontrol --noconfirm  # Графический пользовательский интерфейс для инструмента проверки состояния жесткого диска smartctl
       pacman -S ranger --noconfirm  # Простой файловый менеджер в стиле vim
       pacman -S testdisk --noconfirm  # Проверяет и восстанавливает разделы + PhotoRec, инструмент восстановления на основе сигнатур
       pacman -S dmidecode --noconfirm  # Утилиты, относящиеся к таблице интерфейса управления рабочим столом
       pacman -S qemu --noconfirm  # Универсальный компьютерный эмулятор и виртуализатор с открытым исходным кодом
       pacman -S qemu-arch-extra --noconfirm  # QEMU для зарубежных архитектур
       pacman -S virt-manager --noconfirm  # Настольный пользовательский интерфейс для управления виртуальными машинами
       pacman -S w3m --noconfirm  # Текстовый веб-браузер, а также пейджер

       pacman -S broadcom-wl-dkms --noconfirm  # Драйвер беспроводной сети Broadcom 802.11 Linux STA
       pacman -S ebtables --noconfirm  # Утилиты фильтрации Ethernet-моста 
       pacman -S ipset --noconfirm  # Инструмент администрирования наборов IP
       pacman -S iwd --noconfirm  # Демон беспроводной сети Интернет
       pacman -S linux-atm --noconfirm  # Драйверы и инструменты для поддержки сети банкоматов под Linux
       pacman -S ndisc6 --noconfirm  # Сборник сетевых утилит IPv6
       pacman -S xl2tpd --noconfirm  # Реализация L2TP с открытым исходным кодом, поддерживаемая Xelerance Corporation
       pacman -S networkmanager-l2tp --noconfirm  # Поддержка L2TP для NetworkManager
       pacman -S pptpclient --noconfirm  # Клиент для проприетарного протокола туннелирования точка-точка от Microsoft, PPTP
       pacman -S rp-pppoe --noconfirm  # Протокол точка-точка Roaring Penguin через клиент Ethernet
       pacman -S wvdial --noconfirm  # Программа номеронабирателя для подключения к Интернету

       pacman -S tlp tlp-rdw --noconfirm  # Для увеличения продолжительности времени работы от батареи 
#      pacman -S tp_smapi acpi_call --noconfirm  # Для ThinkPad (ноутбуков), или Интел платформ Sandy Bridge
#      pacman -S acpi_call-dkms --noconfirm  # если ядра не из официальных репозиториев
#      pacman -S acpi_call --noconfirm  # Модуль ядра Linux, который позволяет вызывать методы ACPI через / proc / acpi / call
#      systemctl enable acpid
       systemctl disable systemd-rfkill.service
       systemctl mask systemd-rfkill.socket systemd-rfkill.service
       systemctl enable tlp.service
#      systemctl enable tlp-sleep.service
       tlp start

       pacman -S exfat-utils fuse-exfat --noconfirm  # Утилиты для файловой системы exFAT; Утилиты для файловой системы exFAT
# Важно! exfatprogs и exfat-utils (У них конфликтующие зависимости) - Ставим один из пакетов иначе конфликт!
#       pacman -S exfatprogs --noconfirm  # Утилиты файловой системы exFAT файловой системы в пространстве пользователя драйвера ядра Linux файловой системы exFAT

       pacman -S --noconfirm --needed openssh  # Инструмент подключения для удаленного входа по протоколу SSH
       systemctl enable sshd.service  # Добавляем в автозагрузку ssh(server)

       pacman -S flatpak --noconfirm  # Среда изолированной программной среды и распространения приложений Linux (ранее xdg-app)
       pacman -S elfutils patch --noconfirm  # Утилиты для обработки объектных файлов ELF и отладочной информации DWARF, и Утилита для применения патчей к оригинальным источникам
#      pacman -S discover --noconfirm  # Графический интерфейс управления ресурсами KDE и Plasma 
       pacman -S gnome-software --noconfirm  # Программные инструменты GNOME - ПОДТЯГИВАЕТ МНОГО ЗАВИСИМОСТЕЙ!
       pacman -S gnome-software-packagekit-plugin --noconfirm  # Плагин поддержки PackageKit для программного обеспечения GNOME

  lspci | grep -e VGA -e 3D
  lspci -nn | grep VGA

### Установка Проприетарных драйверов для NVIDIA ###
  pacman -S nvidia nvidia-settings nvidia-utils lib32-nvidia-utils --noconfirm  # Драйверы NVIDIA для linux
  pacman -S libvdpau lib32-libvdpau --noconfirm   # Библиотека Nvidia VDPAU
  pacman -S opencl-nvidia opencl-headers lib32-opencl-nvidia --noconfirm  # Реализация OpenCL для NVIDIA; Файлы заголовков OpenCL (Open Computing Language); Реализация OpenCL для NVIDIA (32-бит) 
  pacman -S xf86-video-nouveau --noconfirm  # - свободный Nvidia (Драйвер 3D-ускорения с открытым исходным кодом) - ВОЗМОЖНО уже установлен с (X.org)
# nvidia-xconfig     # сгенерировать конфиг nvidia-xconfig (для настройки xorg.conf)
   
### Установка Свободных драйверов для AMD/(ATI) ###
  pacman -S mesa-vdpau lib32-mesa-vdpau libva-mesa-driver lib32-libva-mesa-driver --noconfirm  #lib32-mesa # Драйверы Mesa
sudo pacman -S vulkan-radeon lib32-vulkan-radeon --noconfirm  # Драйвер Radeon Vulkan mesa; Драйвер Radeon Vulkan mesa (32-разрядный)
  pacman -S libvdpau-va-gl --noconfirm  # Драйвер VDPAU с бэкэндом OpenGL / VAAPI
  pacman -S xf86-video-amdgpu --noconfirm  # Видеодрайвер X.org amdgpu - ВОЗМОЖНО уже установлен с (X.org)
  pacman -S xf86-video-ati --noconfirm  # Видеодрайвер X.org ati - ВОЗМОЖНО уже установлен с (X.org)
  pacman -S vulkan-icd-loader --noconfirm  # Загрузчик устанавливаемого клиентского драйвера (ICD) Vulkan
  pacman -S lib32-vulkan-icd-loader --noconfirm  # Загрузчик устанавливаемого клиентского драйвера (ICD) Vulkan (32-разрядный)
    
### Установка Свободных драйверов для Intel ###
  pacman -S vdpauinfo libva-utils libva libvdpau libvdpau-va-gl lib32-libvdpau --noconfirm  
  pacman -S vulkan-intel libva-intel-driver lib32-libva-intel-driver lib32-vulkan-intel --noconfirm #lib32-mesa
  pacman -S xf86-video-intel --noconfirm  # X.org Intel i810 / i830 / i915 / 945G / G965 + видеодрайверы - ВОЗМОЖНО уже установлен с (X.org)
    
### Установка дополнительных инструментов и драйверов ###
  pacman -S lib32-mesa --noconfirm   # Реализация спецификации OpenGL с открытым исходным кодом (32-разрядная версия)
  pacman -S lib32-libva-vdpau-driver --noconfirm  # Серверная часть VDPAU для VA API (32-разрядная версия) https://freedesktop.org/wiki/Software/vaapi/ 
  pacman -S lib32-mesa-demos --noconfirm  # Демонстрации и инструменты Mesa (32-разрядная версия)
  pacman -S libva-vdpau-driver --noconfirm  # Серверная часть VDPAU для VA API   https://freedesktop.org/wiki/Software/vaapi/
  pacman -S mesa-demos --noconfirm  # Демоверсии Mesa и инструменты, включая glxinfo + glxgears
  pacman -S xf86-input-elographics --noconfirm  # Драйвер ввода X.org Elographics TouchScreen
  pacman -S xorg-twm --noconfirm  # Вкладка Window Manager для системы X Window
  pacman -S ipw2100-fw --noconfirm  # Микропрограмма драйверов Intel Centrino для IPW2100
  pacman -S ipw2200-fw --noconfirm  # Прошивка для Intel PRO / Wireless 2200BG

### Установка поддержки Драйвера принтера (Поддержка печати) CUPS ###
  pacman -S cups cups-filters cups-pdf cups-pk-helper --noconfirm  # Система печати CUPS - пакет демона; Фильтры OpenPrinting CUPS; PDF-принтер для чашек; Помощник, который заставляет system-config-printer использовать PolicyKit
  pacman -S system-config-printer ghostscript --noconfirm  # Инструмент настройки принтера CUPS и апплет состояния; Интерпретатор для языка PostScript
  pacman -S libcups simple-scan --noconfirm  # Система печати CUPS - клиентские библиотеки и заголовки; Простая утилита сканирования
  pacman -S gsfonts gutenprint --noconfirm  # (URW) ++ Базовый набор шрифтов [Уровень 2]; Драйверы принтера высшего качества для систем POSIX ;  # python-imaging ???
# Драйверы для HP DeskJet, OfficeJet, Photosmart, Business Inkjet и некоторых LaserJet 
  pacman -S splix --noconfirm  # Драйверы CUPS для принтеров SPL (Samsung Printer Language)
  pacman -S hplip --noconfirm  # Драйверы для HP DeskJet, OfficeJet, Photosmart, Business Inkjet и некоторых LaserJet  
# Рабочая группа Foomatic в OpenPrinting в Linux Foundation предоставляет PPD для многих драйверов принтеров
  pacman -S foomatic-db --noconfirm  # Foomatic - собранная информация о принтерах, драйверах и параметрах драйверов в файлах XML, используемая foomatic-db-engine для создания файлов PPD.
  pacman -S foomatic-db-engine --noconfirm  # Foomatic - движок базы данных Foomatic генерирует файлы PPD из данных в базе данных Foomatic XML. Он также содержит сценарии для непосредственного создания очередей печати и обработки заданий.
  pacman -S foomatic-db-ppds --noconfirm  # Foomatic - PPD от производителей принтеров
  pacman -S foomatic-db-nonfree --noconfirm  # Foomatic - расширение базы данных, состоящее из предоставленных производителем файлов PPD, выпущенных по несвободным лицензиям
  pacman -S foomatic-db-nonfree-ppds --noconfirm  # Foomatic - бесплатные PPD от производителей принтеров
  pacman -S foomatic-db-gutenprint-ppds --noconfirm  # Упрощенные готовые файлы PPD

### Запускаем Драйвера принтера CUPS (cupsd.service) ###
# systemctl start org.cups.cupsd.service 
#sudo systemctl start cups-browsed.service 
### Добавляем в автозапуск Драйвера принтера CUPS (cupsd.service) ### 
# systemctl enable org.cups.cupsd.service 
#sudo systemctl enable cups-browsed.service

       pacman -S gvfs-mtp --noconfirm  # Реализация виртуальной файловой системы для GIO (бэкэнд MTP; Android, медиаплеер)
       pacman -S gvfs-afc --noconfirm  # Реализация виртуальной файловой системы для GIO (бэкэнд AFC; мобильные устройства Apple)

       pacman -S --noconfirm --needed cronie  # Демон, который запускает указанные программы в запланированное время и связанные инструменты
       systemctl enable cronie.service  # Добавляем в автозагрузку планировщик заданий (cronie.service)

#      pacman -S alacarte --noconfirm  # Редактор меню для gnome

pacman --noconfirm -Sc  # Очистка кэша неустановленных пакетов (оставив последние версии оных)

pacman --noconfirm -Scc  # Удалит кеш всех пакетов (можно раз в неделю вручную запускать команду) 

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

date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'     # одновременно отображает дату и часовой пояс
uptime  # Отобразить время работы системы ...

umount -R /mnt/boot
umount -R /mnt
reboot





