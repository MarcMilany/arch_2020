#!/bin/bash

# Arch Linux Fast Install - Быстрая установка Arch Linux
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).

# В разработке принимали участие:
# Алексей Бойко https://vk.com/ordanax
# Степан Скрябин https://vk.com/zurg3
# Михаил Сарвилин https://vk.com/michael170707
# Данил Антошкин https://vk.com/danil.antoshkin

# Команды по установке :
# archiso login: root (automatic login)
# Терминальный Мануал Arch Wiki :
# Мы можем просмотреть какие файлы сейчас находятся катологе пользователя root ls -la
# ls -la
# В пользовательском катологе пользователя root есть файл install.txt, если его открыть мы увидем тот же мануал 
# Arch Wiki, как и на официальном сайте Arch'a .
# less install.txt

# Этот мануал можно не закрывать, если у вас нет распечатанного Wiki по установке, или планшета, или второго компьютера, где можно посмотреть в шпаргалку , то нужно нажать Alt + F2 и откроется вторая консоль установки .
# Сейчас мы находимся в первой консоле Alt + F1 , и можем переключаться между консолями командами Alt + F* , где + F* нужная вам консоль . # Всего вроде там 6 консолей (менеджеров интепретации).
# Если во второй консоли запросит логин (login) просто введите - root , пример : "archiso login : root ".
# Перемещаться и читать в мануале можно с помощью стрелочек (вверх или вниз) , допустим Alt + F1 читать мануал , а Alt + F2 продолжаем установку Arch'a . 

# Installation guide - Arch Wiki
# https://wiki.archlinux.org/index.php/Installation_guide

# Важно !!! 
# При установке системы Arch Linux наличие подключения к интернету обязательно.
# Служба DHCP уже запущена при загрузке для найденных Ethernet-адаптеров. 
# Для беспроводных сетевых адаптеров запустите wifi-menu. 
# Если необходимо настроить статический IP или использовать другие средства настройки сети, остановите службу DHCP командой systemctl stop dhcpcd.service и используйте netctl.
# Подключаем интернет (пункт для тех у кого автоматически не подключился интернет):
# Если у вас проводной интернет - dhcpcd  проводное соединение подхватится автоматом
# Если выпадает ошибка с номером 213 или др.,то выполните следующие команды:
# kill 213 и вновь запускаем dhcpcd

# Если вы подключаетесь к интернет по WiFi, то нужно подключиться к вашей WiFi-сети. 
# Я не пробовал устанавливать ArchLinux на компьютере с WiFi, но приведу выдержки из руководства (отпишитесь, пожалуйста, в комментариях, работает ли этот способ). 
# Сначала необходимо определить название WiFi интерфейса, для этого выполняем команду:
# iwconfig
# Затем воспользуемся утилитой wifi-menu: 
# wifi-menu имя_интерфейса
# wifi-menu

# Если в результате выходит ошибка о не существовании wlan0, то узнайте как 
# называется ваш сетевой интерфейс с помощью iwconfig и введите wifi-menu <интерфейс>
# Статья по настройке Wi-fi - wifi-menu:
# http://rus-linux.net/MyLDP/consol/setup-wifi-in-command-line.html

# Подключение через PPPoE: 
# используйте для настройки программу pppoe-setup, для запуска — pppoe-start

# Проверим получены ли сетевые настройки:
# ipddr

# Посмотрим наши DNC сервера:
# cat /etc/resolv.conf

# Подключаем wifi
# wifi-menu
# Или если у вас проводной интернет, то подключаем службы DHCP
# dhcpcd
# ping -c 5 8.8.8.8
# ping -c 5 ya.ru
# ping -c 2 archlinux.org
# ping -c 5 google.com

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

echo '2.4.2 Форматирование дисков'
mkfs.ext2  /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4  /dev/sda3 -L root
mkfs.ext4  /dev/sda4 -L home

echo '2.4.3 Монтирование дисков'
mount /dev/sda3 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda4 /mnt/home

echo '3.1 Выбор зеркал для загрузки. Ставим зеркало от Яндекс'
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

echo '3.2 Установка основных пакетов'
pacstrap /mnt base base-devel linux-lts linux-firmware nano dhcpcd netctl vim

echo '3.3 Настройка системы, генерируем fstab'
genfstab -pU /mnt >> /mnt/etc/fstab

echo 'Меняем корень и переходим в нашу недавно скачанную систему'
arch-chroot /mnt sh -c "$(curl -fsSL git.io/archmy2)"
