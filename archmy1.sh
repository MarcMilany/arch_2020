#!/bin/bash
### Смотрите пометки (справочки) и доп.иформацию в самом скрипте!
###########################################################
#######  <<< Скрипт для установки Arch Linux >>>    #######
#### Этот скрипт находится в процессе 'Внесение попра- ####
#### вок в наводку орудий по результатам наблюдений с  ####
#### наблюдательных пунктов'.                          ####
#### Внимание! Автор не несёт ответственности за любое ####
#### нанесение вреда при использовании скрипта.        ####
#### Лицензия (license): LGPL-3.0                      ####
#### (http://opensource.org/licenses/lgpl-3.0.html     #### 
#### В разработке принимали участие (author) :         ####
#### Алексей Бойко https://vk.com/ordanax              ####
#### Степан Скрябин https://vk.com/zurg3               ####
#### Михаил Сарвилин https://vk.com/michael170707      ####
#### Данил Антошкин https://vk.com/danil.antoshkin     ####
#### Юрий Порунцов https://vk.com/poruncov             ####
#### Анфиса Липко https://vc.ru/u/596418-anfisa-lipko  ####
#### Alex Creio https://vk.com/creio                   ####
#### Jeremy Pardo (grm34) https://www.archboot.org/    ####
#### Marc Milany - 'Не ищи меня 'Вконтакте',           ####
####                в 'Одноклассниках'' нас нету, ...  ####
#### Releases ArchLinux:                               ####
####     https://www.archlinux.org/releng/releases/    ####
#### Installation guide - Arch Wiki  (referance):      ####
# https://wiki.archlinux.org/index.php/Installation_guide #
###########################################################
###
umask 0022 # Определение окончательных прав доступа - Для суперпользователя (root) umask по умолчанию равна 0022
set -e # Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
# set -euxo pipefail  # прекращает выполнение скрипта, даже если одна из частей пайпа завершилась ошибкой
###
### Help and usage (--help or -h) (Справка)
### SHARED VARIABLES AND FUNCTIONS (ОБЩИЕ ПЕРЕМЕННЫЕ И ФУНКЦИИ)
### Shell color codes (Цветовые коды оболочки)
RED="\e[1;31m"; GREEN="\e[1;32m"; YELLOW="\e[1;33m"; GREY="\e[3;93m"
BLUE="\e[1;34m"; CYAN="\e[1;36m"; BOLD="\e[1;37m"; MAGENTA="\e[1;35m"; NC="\e[0m"
################
echo ""
echo -e "${GREEN}:: ${NC}Installation Commands :=) "
echo -e "${CYAN}=> ${NC}Acceptable limit for the list of arguments..."
getconf ARG_MAX  # Допустимый лимит (предел) списка аргументов...'
echo -e "${BLUE}:: ${NC}The determination of the final access rights"
umask  # Определение окончательных прав доступа - Для суперпользователя (root) umask по умолчанию равна 0022    
################
echo ""
echo -e "${GREEN}=> ${NC}To check the Internet, you can ping a service" 
ping -c2 archlinux.org  # Утилита ping - это очень простой инструмент для диагностики сети
echo -e "${CYAN}==> ${NC}If the ping goes we go further ..."  # Если пинг идёт едем дальше ... :)
echo ""
echo -e "${GREEN}=> ${NC}Make sure that your network interface is specified and enabled" 
ip a  # Смотрим какие у нас есть интернет-интерфейсы
################
echo ""
echo -e "${BLUE}:: ${NC}Install the Terminus font"  # Установим шрифт Terminus
pacman -Sy terminus-font --noconfirm  # Моноширинный растровый шрифт (для X11 и консоли)
# man vconsole.conf
echo ""
echo -e "${BLUE}:: ${NC}Setting up the Russian language, changing the console font to one that supports Cyrillic for ease of use"  # Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы
loadkeys ru  
# loadkeys us
#setfont ter-v12n
#setfont ter-v14b
#setfont cyr-sun16
setfont ter-v16b ### Установленный setfont
#setfont ter-v20b  # Шрифт терминус и русская локаль # чтобы шрифт стал побольше
### setfont ter-v22b
### setfont ter-v32b
echo -e "${CYAN}==> ${NC}Добавим русскую локаль в систему установки"
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
echo -e "${BLUE}:: ${NC}Обновим текущую локаль системы"
locale-gen  # Мы ввели locale-gen для генерации тех самых локалей
sleep 01
echo -e "${BLUE}:: ${NC}Указываем язык системы"
export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8
echo -e "${BLUE}:: ${NC}Проверяем, что все заявленные локали были созданы:"
locale -a  # Смотрим какте локали были созданы
#######################
clear
echo -e "${GREEN}
  <<< Начинается установка минимальной системы Arch Linux >>>
${NC}"
echo -e "${BLUE}:: ${NC}Установка и настройка начата в $(date +%T)" 
echo -e "${BLUE}:: ${NC}Синхронизация системных часов"
# timedatectl set-ntp true  # Синхронизируем наши системные часы, включаем ntp, если надо сменим часовой пояс
# timedatectl set-timezone Europe/Moscow
echo " Для начала устанавливаем время по Москве, чтобы потом не оказалось, что файловые системы созданы в будущем "
timedatectl set-ntp true && timedatectl set-timezone Europe/Moscow
sleep 02
echo -e "${BLUE}:: ${NC}Посмотрим статус службы NTP (NTP service)"
timedatectl status 
echo -e "${BLUE}:: ${NC}Посмотрим дату и время без характеристик для проверки времени"
date  # команда date работает с датой и временем (можно извлекать любую дату в разнообразном формате)
sleep 03
######################
clear
echo ""
echo -e "${BLUE}:: ${NC}Если Вы хотите задействовать (попробовать) LVM в действии "
echo " LVM - Менеджер логических томов (англ. Logical Volume Manager). В отличие от разделов жёсткого диска, размеры логических томов можно легко менять. "
# Подгружаем модули:
echo " Загружаем device mapper - dm-mod модуль ядра, отвечающий за работу с LVM "
modprobe dm-mod  # Загрузит модуль ядра и любые дополнительные зависимости модуля
echo " Проверяем - dm-mod модуль ядра "
cat /proc/modules | grep dm_mod
echo ""
echo " Загружаем подсистему прозрачного шифрования диска в ядре Linux ... "
echo " Он может шифровать целые диски (включая съемные носители), разделы, тома программного RAID, логические тома, а также файлы. "
modprobe dm-crypt  # Это криптографическая цель (подсистема прозрачного шифрования диска в ядре Linux ...)
### Если ли надо раскомментируйте нужные вам значения ####
# echo " Загружаем модуль шифрование AES, отвечающий за алгоритм шифрования "
# modprobe aes  # (-c aes -s 256) - использует 256-битное шифрование AES (с алгоритмом шифрования "aes256")
# modprobe sha256  # (-h sha256) - использует 256-битный алгоритм хеширования SHA
######################################
### Если ли надо раскомментируйте нужные вам значения ####
#clear
#echo ""
#echo -e "${YELLOW}==> ${NC}Обновить и добавить новые ключи?"
#echo " Данный этап поможет вам избежать проблем с ключами Pacmаn, если Вы используете не свежий образ ArchLinux для установки! "
#echo ""
#echo " Создаётся генерация мастер-ключа (брелка) pacman "  # gpg –refresh-keys
#pacman-key --init  # генерация мастер-ключа (брелка) pacman
#echo " Далее идёт поиск ключей... "
#pacman-key --populate archlinux  # поиск ключей
# pacman-key --populate
#echo ""
#echo " Обновление ключей... "  
#pacman-key --refresh-keys --keyserver keys.gnupg.net  # http://pool.sks-keyservers.net/
#echo ""
#echo "Обновим базы данных пакетов..."
###  sudo pacman -Sy
#pacman -Syy  # обновление баз пакмэна (pacman) 
# pacman -Syyu  # Обновим вашу систему (базу данных пакетов)
# pacman -Syyu  --noconfirm
###################################### 
echo ""
echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов" 
pacman -Sy --noconfirm  # обновить списки пакетов из репозиториев
sleep 01
#####################
clear
echo ""
echo -e "${BLUE}:: ${NC}Dmidecode. Получаем информацию о железе"
echo " DMI (Desktop Management Interface) - интерфейс (API), позволяющий программному обеспечению собирать данные о характеристиках компьютера. "
pacman -S dmidecode --noconfirm  # Утилиты, относящиеся к таблице интерфейса управления рабочим столом
echo ""
echo -e "${BLUE}:: ${NC}Смотрим информацию о BIOS"
dmidecode -t bios  # BIOS – это предпрограмма (код, вшитый в материнскую плату компьютера)
sleep 01
######################
clear
echo ""
echo -e "${BLUE}:: ${NC}Просмотреть объём используемой и свободной оперативной памяти, имеющейся в системе"
free -m  # Свободная / Неиспользуемая память
echo ""
echo -e "${BLUE}:: ${NC}Посмотрим список установленных SCSI-устройств"
echo " Список устройств scsi/sata "
lsscsi  # маленькая консольная утилита выводящая список подключенных SCSI / SATA устройств
echo ""
echo -e "${BLUE}:: ${NC}Смотрим, какие диски есть в нашем распоряжении"
lsblk -f  # Команда lsblk выводит список всех блочных устройств
echo ""
echo -e "${BLUE}:: ${NC}Посмотрим структуру диска созданного установщиком"
sgdisk -p /dev/sda
#echo ""
#echo -e "${BLUE}:: ${NC}Стираем таблицу разделов на первом диске (sda):"
#echo -e "${RED}=> ${YELLOW}Примечание: ${BOLD}Перед удалением раздела или таблицы разделов сделайте резервную копию своих данных. Все данные автоматически удаляются при удалении. Так как при выполнении данной опции будет деинсталлирован сам системный загрузчик из раздела MBR жесткого диска. ${NC}"
#sgdisk --zap-all /dev/sda  #sda; sdb; sdc; sdd - sgdisk - это манипулятор таблицы разделов Unix-подобных систем
#echo " Создание новых записей GPT в памяти. "
#echo " Структуры данных GPT уничтожены! Теперь вы можете разбить диск на разделы с помощью fdisk или других утилит. "
###
clear
echo -e "${MAGENTA}
  <<< Вся разметка диска(ов) производится только утилитой - fdisk - (для управления разделами жёсткого диска) >>>
${NC}"
echo -e "${RED}=> ${YELLOW}Предупреждение: ${BOLD}Перед созданием раздела(ов) или удалением таблицы разделов сделайте резервную копию своих данных. Повторю ещё раз - если что-то напутаете при разметке дисков, то можете случайно удалить важные для вас данные. Так как при выполнении данной опции (может) будет деинсталлирован сам системный загрузчик из раздела MBR жесткого диска. ${NC}"
echo ""
echo -e "${GREEN}==> ${NC}Создание разделов диска для установки ArchLinux"
echo -e "${BLUE}:: ${NC}Вы можете изменить разметку диска"
echo " Создаем таблицу на диске MBR(DOS) и 2 первичных раздела: "
echo " Раздел boot 512M + -, выставляем флаг boot "
echo " Раздел LUKS под root, swap, home "
echo " Перемена местами не имеет значения - просто изменить команды! "

(
  echo o;

  echo n;
  echo p;
  echo;
  echo;
  echo +2G;

  echo n;
  echo p;
  echo;
  echo;
  echo a;
  echo 1;  

  echo w;
) | fdisk /dev/sda
#####################################
# Создаем таблицу на диске MBR(DOS) и 2 первичных раздела.
# boot 512M, выставляем флаг boot
# LUKS под root, swap, home
# Создаём разделы:
# [root@archiso ~]# fdisk /dev/sda
# /boot:
# (fdisk) n // new раздел
# (fdisk) p // или <Enter>, primary раздел
# (fdisk) 1 // или <Enter>, первый раздел
# (fdisk) <Enter> // первый сектор, по умолчанию
# (fdisk) +256M // последний сектор, под /boot тут хватит 256МБ
# (fdisk) a // устанавливаем boot флаг на этот раздел
# LVM:
# (fdisk) n // new раздел
# (fdisk) p // или <Enter>, primary раздел
# (fdisk) 2 // или <Enter>, второй раздел
# (fdisk) <Enter> // первый сектор, по умолчанию
# (fdisk) <Enter> // последний сектор, всё оставшееся место
# Проверяем:
# ...
# Command (m for help): p
# Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disklabel type: dos
# Disk identifier: 0xc26e076b
# Device     Boot  Start      End  Sectors  Size Id Type
# /dev/sda1  *      2048   526335   524288  256M 83 Linux
# /dev/sda2       526336 41943039 41416704 19.8G 83 Linux
# Re-playCopy to ClipboardPauseFull View
# Записываем изменения — w:
#...
# Command (m for help): w
# The partition table has been altered.
# Calling ioctl() to re-read partition table.
# Syncing disks
#####################################
###
clear 
echo "" 
echo -e "${BLUE}:: ${NC}Ваша разметка диска" 
fdisk -l  # Посмотрим список доступных (созданных) дисков и разделов 
lsblk -f  # Команда lsblk выводит список всех блочных устройств
#lsblk -lo  # Команда lsblk выводит список всех блочных устройств
sleep 03
###
clear
echo ""
echo -e "${GREEN}==> ${NC}Шифруем, открываем раздел. Создаем контейнер."
echo -e "${BLUE}:: ${NC} Шифрование LUKS:"
echo " Есть несколько вариаций, как шифровать логический объем на /dev/sd*. Мы используем luks2 формат, детальный, с запросом пароля, без лишних ключей "
echo -e "${CYAN} Пример команды: ${NC}"cryptsetup -y luksFormat --type luks2 /dev/sdX"; или ещё команда - "cryptsetup -y -v luksFormat --type luks2 /dev/sdX""
echo -e "${MAGENTA}:: ${BOLD}Эта команда выполнит инициализацию раздела, установит ключ инициализации и пароль. Сначала надо подтвердить создание виртуального шифрованного диска набрав Заглавными YES, затем нужно указать пароль. Указывайте такой пароль, чтобы его потом не забыть! ${NC}"
echo " Пароль (который будет вводиться при загрузке устройства) должен содержать от 6 до 15... символов, включающих цифры (1-0) и знаки (!'':[@]),     
        и латинские буквы разного регистра! "
echo -e "${MAGENTA}=> ${BOLD}По умолчанию, на большинстве систем Linux в консоле не показывается введенный пароль. 
Это сделано из соображений безопасности, чтобы никто не мог увидеть длину вашего пароля.${NC}"
echo ""
echo " Форматируем партицию через cryptsetup и задаём парольную фразу "
# cryptsetup -y luksFormat --type luks2 /dev/sda2  # -y: запросить подтверждение пароля; luksFormat: использовать LUKS; --type: тип — plain, luks, luks2, tcrypt  
cryptsetup -y -v luksFormat --type luks2 /dev/sda2
###
echo "" 
echo -e "${BLUE}:: ${NC}Открываем зашифрованный контейнер с именем cryptlvm, который содержит данные из /dev/sdX"
echo -e "${MAGENTA}=> ${BOLD}Открываем контейнер указывая ту же парольную фразу, с которой выполнялось шифрование luks linux ${NC}"
echo ""
echo " Форматируем партицию через cryptsetup и задаём парольную фразу "
# cryptsetup open /dev/sda2 cryptlvm
cryptsetup luksOpen /dev/sda2 cryptlvm

и запросят пароль, который будет вводиться при загрузке устройства


Теперь вы можете увидеть новое виртуальное устройство /dev/mapper/backup2 созданное с помощью команды luksFormat

Проверяем:

ls -l /dev/mapper/cryptlvm

На этом с шифрованием всё — переходим к созданию LVM разделов и установке системы.


Создание LVM разделов
Создаём Phisical Volume на /dev/mapper/cryptlvm:

pvcreate /dev/mapper/cryptlvm
vgcreate lvarch /dev/mapper/cryptlvm


ls -l /dev/mapper/cryptlvm



А с помощью следующей команды вы можете сделать резервную копию заголовков LUKS на всякий случай:

 cryptsetup luksDump /dev/sda6





Создаём разделы lvm.

lvcreate -L 4G -n swap lvarch
lvcreate -L 35G -n root lvarch
lvcreate -l 100%FREE -n home lvarch

clear
echo "Вот вывод PVDISPLAY:"
pvdisplay
read -n 1 -s -r -p "Press any key to continue"
clear
echo "Вот вывод VGDISPLAY:"
vgdisplay
read -n 1 -s -r -p "Press any key to continue"
clear
echo "Вот вывод LVDISPLAY:"
lvdisplay
read -n 1 -s -r -p "Press any key to continue"




Форматируем и включаем swap.
Создаём файловые системы:

mkfs.ext2 -L boot /dev/sda1
mkfs.ext4 -L root /dev/lvarch/root
mkfs.ext4 -L home /dev/lvarch/home
mkswap -L swap /dev/lvarch/swap

Подключаем swap
swapon /dev/lvarch/swap

Монтируем и создаем директории.
# Монтируем разделы — root в корень /mnt:
# Монтируем разделы в каталог /mnt запущенной системы:
mount /dev/lvarch/root /mnt

# Для /home — в /mnt создаём каталог home, и монтируем в него:
# mkdir /mnt/home
mkdir /mnt/{home,boot}
mount /dev/lvarch/home /mnt/home

# Аналогично для /boot:
# mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

Проверяем:
ls -l /mnt/

Установка системы
Устанавливаем саму систему и openssh:

[root@archiso ~]# pacstrap -i /mnt base base-devel openssh

Создаём файл fstab:
# genfstab -U -p /mnt >> /mnt/etc/fstab
genfstab -pU /mnt >> /mnt/etc/fstab
Проверяем его:
cat /mnt/etc/fstab

Меняем окружение на новую систему:
arch-chroot /mnt
# arch-chroot /mnt /bin/bash

clear
echo ""
echo -e "${GREEN}==> ${NC}Форматирование разделов диска"
echo -e "${BLUE}:: ${NC}Установка название флага boot,root,swap,home"
echo -e "${BLUE}:: ${NC}Монтирование разделов диска"
#### Root #######
mkfs.ext4  /dev/sda3 -L root
mount /dev/sda3 /mnt
# mkfs.ext4 /dev/$root -L root
# mount /dev/$root /mnt
#### Boot #######
mkfs.ext2  /dev/sda1 -L boot
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
# mkfs.ext2  /dev/$bootd -L boot
# mkdir /mnt/boot
# mount /dev/$bootd /mnt/boot
#### Swap #######
mkswap /dev/sda2 -L swap
swapon /dev/sda2
# mkswap /dev/$swaps -L swap
# swapon /dev/$swaps 
#### Home #######
mkfs.ext4  /dev/sda4 -L home
mkdir /mnt/home
mount /dev/sda4 /mnt/home
# mkfs.ext4 /dev/$home -L home
# mkdir /mnt/home
# mount /dev/$home /mnt/home
#############################
clear
echo ""
echo -e "${BLUE}:: ${NC}Просмотреть подключённые диски с выводом информации о размере и свободном пространстве"
df -h  # Команда df выводит в табличном виде список всех файловых систем и информацию о доступном и занятом дисковом пространстве
echo ""
echo -e "${BLUE}:: ${NC}Просмотреть все идентификаторы наших разделов"
echo ""
blkid  # Для просмотра UUID (или Universal Unique Identifier) - это универсальный уникальный идентификатор определенного устройства компьютера
echo ""
echo -e "${BLUE}:: ${NC}Просмотреть информацию об использовании памяти в системе"
free -h  # Достаточно ли свободной памяти для установки и запуска новых приложений
sleep 02
echo ""
echo -e "${BLUE}:: ${NC}Посмотреть содержмое каталога /mnt."
ls /mnt  # Посмотреть содержимое той или иной папки
########################
######## Mirrorlist ##########
clear
echo ""
echo -e "${GREEN}==> ${NC}Сменим зеркала для увеличения скорости загрузки пакетов" 
echo -e "${BLUE}:: ${NC}Загрузка свежего списка зеркал со страницы Mirror Status, и обновление файла mirrorlist."
echo " Команда отфильтрует зеркала для Russia по протоколам (https, http), отсортирует их по скорости загрузки и обновит файл mirrorlist "
echo "" 
echo " Проверим присутствует ли пакет (reflector) "
pacman -Sy --noconfirm --noprogressbar --quiet reflector  # Модуль и скрипт Python 3 для получения и фильтрации последнего списка зеркал Pacman  - пока присутствует в pkglist.x86_64
pacman -S --noconfirm --needed --noprogressbar --quiet reflector
echo ""
echo " Загрузка свежего списка зеркал со страницы Mirror Status "
reflector --verbose --country 'Russia' -l 9 -p https -p http -n 9 --save /etc/pacman.d/mirrorlist --sort rate
###
clear
echo ""
echo -e "${BLUE}:: ${NC}Посмотреть список серверов-зеркал /mnt/etc/pacman.d/mirrorlist"
echo ""
cat /etc/pacman.d/mirrorlist  # cat читает данные из файла или стандартного ввода и выводит их на экран
echo ""
echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов" 
pacman -Sy --noconfirm  # обновить списки пакетов из репозиториев
sleep 01
##########################
clear
echo ""  
echo -e "${GREEN}==> ${NC}Установка основных пакетов (base, base-devel) базовой системы"
echo -e "${BLUE}:: ${NC}Arch Linux, Base devel (AUR only)"
echo " Сценарий pacstrap устанавливает (base) базовую систему. Для сборки пакетов из AUR (Arch User Repository) также требуется группа base-devel. "
echo -e "${MAGENTA}=> ${BOLD}Т.е., Если нужен AUR, ставь base и base-devel, если нет, то ставь только base. ${NC}"
echo ""
echo " Установка базовой системы - групп "
pacstrap /mnt base base-devel nano dhcpcd netctl which inetutils  #wget vim
# pacstrap -i /mnt base base-devel nano dhcpcd netctl which inetutils --noconfirm
echo ""
echo " Установка базовой системы групп (base + base-devel + packages) выполнена "
###
clear
echo ""
echo -e "${GREEN}==> ${NC}Установим ядро (Kernel) для системы Arch Linux"
echo -e "${BLUE}:: ${NC}Kernel (optional), Firmware"
echo " Дистрибутив Arch Linux основан на ядре Linux. Помимо основной стабильной (stable) версии в Arch Linux можно использовать некоторые альтернативные ядра. "
echo -e "${BLUE}:: ${NC}Какое ядро (Kernel) Вы бы предпочли установить вместе с системой Arch Linux?"
echo " Будьте осторожны! Если Вы сомневаетесь в своих действиях, можно установить (linux Stable) ядро поставляемое вместе с Rolling Release. "
### Если ли надо раскомментируйте нужные вам значения ####
### LINUX (Stable - ядро Linux с модулями и некоторыми патчами, поставляемое вместе с Rolling Release устанавливаемой системы Arch)
#echo ""
#echo " Установка выбранного вами ядра (linux) "
#pacstrap /mnt linux linux-firmware linux-headers #linux-docs
#echo ""
#echo " Ядро (linux) операционной системы установленно " 
### LINUX_HARDENED (Ядро Hardened - ориентированная на безопасность версия с набором патчей, защищающих от эксплойтов ядра и пространства пользователя. Внедрение защитных возможностей в этом ядре происходит быстрее, чем в linux)
#echo ""
#echo " Установка выбранного вами ядра (linux-hardened) "
#pacstrap /mnt linux-hardened linux-firmware linux-hardened-headers #linux-hardened-docs
#echo ""
#echo " Ядро (linux-hardened) операционной системы установленно " 
### LINUX_LTS (Версия ядра и модулей с долгосрочной поддержкой - Long Term Support, LTS)
echo ""
echo " Установка выбранного вами ядра (linux-lts) "
pacstrap /mnt linux-lts linux-firmware linux-lts-headers linux-lts-docs
# pacstrap -i /mnt linux-lts linux-firmware linux-lts-headers linux-lts-docs --noconfirm
echo ""
echo " Ядро (linux-lts) операционной системы установленно " 
### LINUX_ZEN (Результат коллективных усилий исследователей с целью создать лучшее из возможных ядер Linux для систем общего назначения)
#echo ""
#echo " Установка выбранного вами ядра (linux-zen) " 
#pacstrap /mnt linux-zen linux-firmware linux-zen-headers #linux-zen-docs
#echo ""
#echo " Ядро (linux-zen) операционной системы установленно " 
##########################
clear
echo ""
echo -e "${GREEN}==> ${NC}Настройка системы, генерируем fstab" 
echo -e "${MAGENTA}=> ${BOLD}Файл /etc/fstab используется для настройки параметров монтирования различных блочных устройств, разделов на диске и удаленных файловых систем. ${NC}"
echo " Таким образом, и локальные, и удаленные файловые системы, указанные в /etc/fstab, будут правильно смонтированы без дополнительной настройки. "
echo ""
echo " Генерируем fstab методом - По-UUID ("UUID" "genfstab -U")  "
echo " UUID - genfstab -U -p /mnt > /mnt/etc/fstab "
genfstab -pU /mnt >> /mnt/etc/fstab
echo " Проверьте полученный /mnt/etc/fstab файл и отредактируйте его в случае ошибок. "
###
clear
echo ""
echo -e "${BLUE}:: ${NC}Просмотреть содержимое файла fstab"
cat /mnt/etc/fstab  # cat читает данные из файла или стандартного ввода и выводит их на экран
sleep 02
echo -e "${BLUE}:: ${NC}Взглянем на UUID идентификатор(ы) нашего устройства:"
echo ""
blkid
# blkid /dev/sd*  # Для просмотра UUID (или Universal Unique Identifier) - это универсальный уникальный идентификатор определенного устройства компьютера
sleep 01
##########################
clear
echo ""
echo -e "${GREEN}==> ${NC}Меняем корень и переходим в нашу недавно скачанную систему (chroot)" 
echo ""
echo " Первый этап установки Arch'a закончен " 
echo 'Установка продолжится в ARCH-LINUX chroot' 
echo ""   
# pacman -S curl --noconfirm --noprogressbar --quiet  # Утилита и библиотека для поиска URL
arch-chroot /mnt sh -c "$(curl -fsSL git.io/archmy2)"  # sh вызывает программу sh как интерпретатор и флаг -c означает выполнение 
echo " ############################################### "
echo -e "${BLUE}       ARCH LINUX FAST INSTALL ${RED}1.6 Update${NC}"
echo " ############################################### "
echo " Размонтирование всех смонтированных файловых систем (кроме корневой) "
umount -a  # файловые системы, упомянутые в fstab (cоответсвующего типа/параметров) должны быть размонтированы и остановлены (кроме тех, для которых указана опция noauto)
reboot
######################


