#!/bin/bash

# Arch Linux Fast Install (arch2018) - Быстрая установка Arch Linux 
# Проект (project): https://github.com/ordanax/arch2018
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).

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

echo 'Для проверки интернета можно пропинговать какой-либо сервис'
ping -c2 archlinux.org

echo 'Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы'
loadkeys ru
setfont cyr-sun16

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
