#!/bin/bash
set > old_vars.log

APPNAME="arch_fast_install "
VERSION="v1.6 LegasyBIOS"
BRANCH="master"
AUTHOR="ordanax"
LICENSE="GNU General Public License 3.0"

### Description
_archboot_banner() {
    echo -e "${BLUE}
┌─┐┬─┐┌─┐┬ ┬  ┬  ┬ ┬ ┬┬ ┬┌┌┐  ┬─┐┌─┐┌─┐┌┬┐  ┬ ┬ ┬┌─┐┌┬┐┌─┐┬  ┬  
├─┤├┬┘│  ├─┤  │  │ │\││ │ │   │─ ├─┤└─┐ │   │ │\│└─┐ │ ├─┤│  │  
┴ ┴┴└─└─┘┴ ┴  └─┘┴ ┴ ┴└─┘└└┘  ┴  ┴ ┴└─┘ ┴   ┴ ┴ ┴└─┘ ┴ ┴ ┴┴─┘┴─┘${RED}
 Arch Linux Install ${VERSION} - A script made with love by ${AUTHOR}
${NC}
Arch Linux - это независимо разработанный универсальный дистрибутив GNU / Linux для архитектуры x86-64, который стремится предоставить последние стабильные версии большинства программ, следуя модели непрерывного выпуска. Arch Linux определяет простоту как без лишних дополнений или модификаций. Arch включает в себя многие новые функции, доступные пользователям GNU / Linux, включая systemd init system, современные файловые системы , LVM2, программный RAID, поддержку udev и initcpio (с mkinitcpio ), а также последние доступные ядра.
Arch Linux - это дистрибутив общего назначения. После установки предоставляется только среда командной строки: вместо того, чтобы вырывать ненужные и нежелательные пакеты, пользователю предлагается возможность создать собственную систему, выбирая среди тысяч высококачественных пакетов, представленных в официальных репозиториях для x86- 64 архитектуры.
Этот скрипт не задумывался, как обычный установочный с большим выбором DE, разметкой диска и т.д. И он не предназначет для новичков. Он предназначет для тех, кто ставил ArchLinux руками и понимает, что и для чего нужна каждая команда. 

Его цель - это моментальное разворачиванеи системы со всеми конфигами. Смысл в том что, все изменения вы делаете предварительно в самом скрипте и получаете возможность быстрой установки ArchLinux с вашими личными настройками (при условии, что вы его изменили под себя, в противном случае с моими настройками).
ВНИМАНИЕ!
Автор не несет ответственности за любое нанесение вреда при использовании скрипта. Используйте его на свой страх и риск или изменяйте под свои личные нужды."
}

# Arch Linux Fast Install (arch2018) - Быстрая установка Arch Linux 
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).
# Проект (project): https://github.com/ordanax/arch2018

# В разработке принимали участие (author) :
# Алексей Бойко https://vk.com/ordanax
# Степан Скрябин https://vk.com/zurg3
# Михаил Сарвилин https://vk.com/michael170707
# Данил Антошкин https://vk.com/danil.antoshkin
# Юрий Порунцов https://vk.com/poruncov

# Лицензия (license): LGPL-3.0 (http://opensource.org/licenses/lgpl-3.0.html
# Installation guide - Arch Wiki
# (referance): https://wiki.archlinux.org/index.php/Installation_guide

# Команды по установке :
# archiso login: root (automatic login)

apptitle="Arch Linux Fast Install (arch2018) - Version: v1.6 LegasyBIOS (GPLv3)"
baseurl=https://github.com/ordanax/arch2018
skipfont="0"

echo 'Для проверки интернета можно пропинговать какой-либо сервис'
_info "${MSG_INTERNET}"
INTERNET=$( ping -c2 archlinux.org )

if [[ ${INTERNET} ]]; then
    _note "congratulations, you are connected to Internet!"
else
    _error "you are not connected to Internet!"
fi

echo 'Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы'
loadkeys ru
setfont cyr-sun16

### Display banner
_arch_fast_install_banner

echo 'Скрипт сделан на основе чеклиста Бойко Алексея по Установке ArchLinux'
echo 'Ссылка на чек лист есть в группе vk.com/arch4u'

echo '2.3 Синхронизация системных часов'
timedatectl set-ntp true

echo '2.4 создание разделов'
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

echo 'Ваша разметка диска'
fdisk -l

echo '2.4.2 Форматирование разделов диска'
mkfs.ext2  /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4  /dev/sda3 -L root
mkfs.ext4  /dev/sda4 -L home

echo '2.4.3 Монтирование разделов диска'
mount /dev/sda3 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda4 /mnt/home

echo '3.1 Выбор серверов-зеркал для загрузки. Ставим зеркало от Яндекс'
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

echo '3.2 Установка основных пакетов (base)'
pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim

echo '3.3 Настройка системы, генерируем fstab'
genfstab -pU /mnt >> /mnt/etc/fstab

echo 'Меняем корень и переходим в нашу недавно скачанную систему'
arch-chroot /mnt sh -c "$(curl -fsSL git.io/archmy2)"
