#!/bin/bash
#### Смотрите пометки (справочки) и доп.иформацию в самом скрипте! ####

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

ARCH2020_LANG="russian"  # Installer default language (Язык установки по умолчанию)
script_path=$(readlink -f ${0%/*})

### SHARED VARIABLES AND FUNCTIONS (ОБЩИЕ ПЕРЕМЕННЫЕ И ФУНКЦИИ)
### Shell color codes (Цветовые коды оболочки)
RED="\e[1;31m"; GREEN="\e[1;32m"; YELLOW="\e[1;33m"; GREY="\e[3;93m"
BLUE="\e[1;34m"; CYAN="\e[1;36m"; BOLD="\e[1;37m"; MAGENTA="\e[1;35m"; NC="\e[0m"

# Автоматическое обнаружение ошибок
set -e  # Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
#set -e "\n${RED}Error: ${YELLOW}${*}${NC}"

# Команды по установке : - archiso login: root (automatic login)
echo -e "${RED}=> ${NC}Acceptable limit for the list of arguments..."
# Допустимый лимит (предел) списка аргументов...'
getconf ARG_MAX

echo -e "${BLUE}:: ${NC}The determination of the final access rights"
# Определение окончательных прав доступа - Для суперпользователя (root) umask по умолчанию равна 0022
umask     

echo -e "${BLUE}:: ${NC}Install the Terminus font"
# Установим шрифт Terminus
pacman -Sy terminus-font --noconfirm  # Моноширинный растровый шрифт (для X11 и консоли)
#pacman -Syy terminus-font  # Моноширинный растровый шрифт (для X11 и консоли)
#man vconsole.conf

echo ""
echo -e "${BLUE}:: ${NC}Setting up the Russian language, changing the console font to one that supports Cyrillic for ease of use" 
# Настроим русский язык, изменим консольный шрифт на тот, который поддерживает кириллицу для удобства работы
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
locale-gen  # Мы ввели locale-gen для генерации тех самых локалей.

sleep 01
echo -e "${BLUE}:: ${NC}Указываем язык системы"
export LANG=ru_RU.UTF-8
#export LANG=en_US.UTF-8

echo -e "${BLUE}:: ${NC}Проверяем, что все заявленные локали были созданы:"
locale -a

echo ""
echo -e "${GREEN}=> ${NC}Убедитесь, что сетевой интерфейс указан и включен" 
echo " Показать все ip адреса и их интерфейсы "
ip a  # Смотрим какие у нас есть интернет-интерфейсы
 
echo ""
echo -e "${GREEN}=> ${NC}Для проверки интернета можно пропинговать какой-либо сервис" 
ping -c2 archlinux.org

echo -e "${CYAN}==> ${NC}Если пинг идёт едем дальше ... :)"

echo ""
echo -e "${BLUE}:: ${NC}Краткая информация о скрипте (archluks.sh)."
echo ""
echo "###########################################################"
echo "########  <<< Скрипт по установке Arch Linux >>>  #########"
echo "#### Скрипт 'arch2020.sh' создан на основе различных   ####"
echo "#### сценариев (скриптов). При работе (выполнении)     ####"
echo "#### скрипта Вы получаете возможность быстрой установ- ####"
echo "#### ки ArchLinux с вашими личными настройками (при    ####"                                         
echo "#### условии, что Вы его изменили под себя, в против-  ####"       
echo "#### ном случае с моими настройками).                  ####" 
echo "#### В скрипте прописана установка grub для LegasyBIOS ####"  
echo "#### и с DE (среда рабочего стола) Xfce.               ####"
echo "#### Этот скрипт находится в процессе 'Внесение попра- ####"
echo "#### вок в наводку орудий по результатам наблюдений с  ####"
echo "#### наблюдательных пунктов'.                          ####"
echo "#### Автор не несёт ответственности за любое нанесение ####"
echo "#### вреда при использовании скрипта.                  ####"
echo "#### Вы используйте его на свой страх и риск, или      ####"
echo "#### изменяйте скрипт под свои личные нужды.           ####"
echo "#### Лицензия (license): LGPL-3.0                      ####"
echo "#### (http://opensource.org/licenses/lgpl-3.0.html     ####" 
echo "#### В разработке принимали участие (author) :         ####"
echo "#### Алексей Бойко https://vk.com/ordanax              ####"
echo "#### Степан Скрябин https://vk.com/zurg3               ####"
echo "#### Михаил Сарвилин https://vk.com/michael170707      ####"
echo "#### Данил Антошкин https://vk.com/danil.antoshkin     ####"
echo "#### Юрий Порунцов https://vk.com/poruncov             ####"
echo "#### Анфиса Липко https://vc.ru/u/596418-anfisa-lipko  ####"
echo "#### Alex Creio https://vk.com/creio                   ####"
echo "#### Jeremy Pardo (grm34) https://www.archboot.org/    ####"
echo "#### Marc Milany - 'Не ищи меня 'Вконтакте',           ####"
echo "####                в 'Одноклассниках'' нас нету, ...  ####"
echo "#### Releases ArchLinux:                               ####"
echo "####     https://www.archlinux.org/releng/releases/    ####"
echo "#### Installation guide - Arch Wiki  (referance):      ####"
echo "# https://wiki.archlinux.org/index.php/Installation_guide #"
echo "###########################################################"

sleep 04
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
date
sleep 05

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

###########################################
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
pacman -Sy --noconfirm
sleep 1

clear
echo ""
echo -e "${BLUE}:: ${NC}Dmidecode. Получаем информацию о железе"
echo " DMI (Desktop Management Interface) - интерфейс (API), позволяющий программному обеспечению собирать данные о характеристиках компьютера. "
pacman -S dmidecode --noconfirm 

echo ""
echo -e "${BLUE}:: ${NC}Смотрим информацию о BIOS"
dmidecode -t bios  # BIOS – это предпрограмма (код, вшитый в материнскую плату компьютера)
#dmidecode --type BIOS

####################################
### Если ли надо раскомментируйте нужные вам значения ####
#echo ""
#echo -e "${BLUE}:: ${NC}Смотрим информацию о материнской плате"
#dmidecode -t baseboard
#dmidecode --type baseboard

#echo ""
#echo -e "${BLUE}:: ${NC}Смотрим информацию о разьемах на материнской плате"
#dmidecode -t connector
#dmidecode --type connector

#echo ""
#echo -e "${BLUE}:: ${NC}Информация о установленных модулях памяти и колличестве слотов под нее"
#echo " Информация об оперативной памяти "
#dmidecode -t memory
#dmidecode --type memory

#echo ""
#echo -e "${BLUE}:: ${NC}Смотрим информацию об аппаратном обеспечении"
#echo " Информация о переключателях системной платы "
#dmidecode -t system
#dmidecode --type system

#echo ""
#echo -e "${BLUE}:: ${NC}Смотрим информацию о центральном процессоре (CPU)"
#dmidecode -t processor
#dmidecode --type processor
##############################################################

sleep 01
echo -e "${BLUE}:: ${NC}Просмотреть объём используемой и свободной оперативной памяти, имеющейся в системе"
free -m

echo ""
echo -e "${BLUE}:: ${NC}Посмотрим список установленных SCSI-устройств"
echo " Список устройств scsi/sata "
lsscsi
sleep 01

clear
echo ""
echo -e "${BLUE}:: ${NC}Смотрим, какие диски есть в нашем распоряжении"
lsblk -f
sleep 01

echo ""
echo -e "${BLUE}:: ${NC}Посмотрим структуру диска созданного установщиком"
echo " Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter") "
read -p " => Укажите диск (sda/sdb например sda или sdb) : " cfd
sgdisk -p /dev/$cfd  #sda; sdb; sdc; sdd
# sgdisk -p /dev/sda

echo ""
echo -e "${RED}==> ${NC}Удалить (стереть) таблицу разделов на выбранном диске (sdX)?"
echo -e "${YELLOW}==> ${NC}Вы можете пропустить этот шаг, если не уверены в правильности выбора"
echo " Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter") "    
read -p " => Укажите диск (sda/sdb например sda или sdb) : " cfd
sgdisk --zap-all /dev/$cfd   #sda; sdb; sdc; sdd
# sgdisk --zap-all /dev/sda
echo " Создание новых записей GPT в памяти. "
echo " Структуры данных GPT уничтожены! Теперь вы можете разбить диск на разделы с помощью fdisk или других утилит. " 

clear
echo ""
echo -e "${BLUE}:: ${NC}Создание разделов диска"
# Можно вызвать подсказки нажатием на клавишу “m”
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

clear 
echo "" 
echo -e "${BLUE}:: ${NC}Ваша разметка диска" 
fdisk -l  # Ещё раз проверте правильность разбивки на разделы!
lsblk -f
#lsblk -lo 
sleep 05
# Для просмотра разделов одного выбранного диска используйте такой вариант этой же команды:
#fdisk -l /dev/sda

###   "Справка команд по работе с утилитой fdisk"
# ================================================
# Команда (m для справки): m
# Справка:
#  Работа с разбиением диска в стиле DOS (MBR)
#   a   переключение флага загрузки
#   b   редактирование вложенной метки диска BSD
#   c   переключение флага dos-совместимости 
#  Общие
#   d   удалить раздел
#   F   показать свободное неразмеченное пространство
#   l   список известных типов разделов
#   n   добавление нового раздела
#   p   вывести таблицу разделов
#   t   изменение метки типа раздела
#   v   проверка таблицы разделов
#   i   вывести информацию о разделе
#  Разное
#   m   вывод этого меню
#   u   изменение единиц измерения экрана/содержимого
#   x   дополнительная функциональность (только для экспертов)
#  Сценарий
#   I   загрузить разметку из файла сценария sfdisk
#   O   записать разметку в файл сценария sfdisk
#  Записать и выйти
#   w   запись таблицы разделов на диск и выход
#   q   выход без сохранения изменений
#  Создать новую метку
#   g   создание новой пустой таблицы разделов GPT
#   G   создание новой пустой таблицы разделов SGI (IRIX)
#   o   создание новой пустой таблицы разделов DOS
#   s   создание новой пустой таблицы разделов Sun
# -------------------------------------------------
### https://linux-faq.ru/page/komanda-fdisk
### https://www.altlinux.org/Fdisk
# ================================================

clear
echo ""
echo -e "${GREEN}==> ${NC}Форматирование разделов диска"
echo -e "${BLUE}:: ${NC}Установка название флага boot,root,swap,home"
mkfs.ext2  /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4  /dev/sda3 -L root
mkfs.ext4  /dev/sda4 -L home
# Просмотреть все идентификаторы наших разделов можно командой:
#blkid

echo ""
echo -e "${BLUE}:: ${NC}Монтирование разделов диска"
mount /dev/sda3 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda4 /mnt/home
# Посмотреть что мы намонтировали можно командой:
#mount | grep sda  # - покажет куда был примонтирован sda    

echo ""
echo -e "${BLUE}:: ${NC}Просмотреть подключённые диски с выводом информации о размере и свободном пространстве"
df -h

echo ""
echo -e "${BLUE}:: ${NC}Просмотреть все идентификаторы наших разделов"
echo ""
blkid

echo ""
echo -e "${BLUE}:: ${NC}Просмотреть информацию об использовании памяти в системе"
free -h
sleep 02

echo ""
echo -e "${BLUE}:: ${NC}Посмотреть содержмое каталога /mnt."
ls /mnt

echo ""
echo -e "${BLUE}:: ${NC}Выбор серверов-зеркал для загрузки. Ставим зеркало от Яндекс"
> /etc/pacman.d/mirrorlist
cat <<EOF >>/etc/pacman.d/mirrorlist

##
## Arch Linux repository mirrorlist
## Generated on 2021-04-03
## HTTP IPv4 HTTPS
## https://www.archlinux.org/mirrorlist/
## https://www.archlinux.org/mirrorlist/?country=RU&protocol=http&protocol=https&ip_version=4
##

## Russia
Server = https://mirror.yandex.ru/archlinux/\$repo/os/\$arch
Server = https://mirror.surf/archlinux/\$repo/os/\$arch
Server = https://mirror.rol.ru/archlinux/\$repo/os/\$arch
Server = https://mirror.nw-sys.ru/archlinux/$repo/os/\$arch
Server = https://mirror.truenetwork.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.surf/archlinux/\$repo/os/\$arch
#Server = http://mirror.rol.ru/archlinux/\$repo/os/\$arch
#Server = http://mirror.nw-sys.ru/archlinux/$repo/os/\$arch
#Server = http://mirror.truenetwork.ru/archlinux/\$repo/os/\$arch
#Server = http://mirrors.powernet.com.ru/archlinux/$repo/os/$arch
#Server = http://archlinux.zepto.cloud/\$repo/os/\$arch

##
## Arch Linux repository mirrorlist
## Generated on 2021-04-03
## HTTP IPv6 HTTPS
## https://www.archlinux.org/mirrorlist/
## https://www.archlinux.org/mirrorlist/?country=RU&ip_version=6
##

## Russia
#Server = http://mirror.yandex.ru/archlinux/$repo/os/\$arch
#Server = https://mirror.yandex.ru/archlinux/$repo/os/\$arch
#Server = http://mirror.nw-sys.ru/archlinux/$repo/os/\$arch
#Server = https://mirror.nw-sys.ru/archlinux/$repo/os/\$arch
#Server = http://mirror.surf/archlinux/$repo/os/\$arch
#Server = https://mirror.surf/archlinux/$repo/os/\$arch
#Server = http://mirrors.powernet.com.ru/archlinux/$repo/os/\$arch
#Server = http://archlinux.zepto.cloud/$repo/os/\$arch

EOF

echo -e "${BLUE}:: ${NC}Создание (backup) резервного списка зеркал mirrorlist - (mirrorlist.backup)"
cp -vf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

echo -e "${BLUE}:: ${NC}Посмотреть список серверов-зеркал для загрузки в mirrorlist"
cat /etc/pacman.d/mirrorlist

echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов" 
sudo pacman -Sy 
sleep 02

clear
echo ""  
echo -e "${GREEN}==> ${NC}Установка основных пакетов (base, base-devel) базовой системы"
echo -e "${BLUE}:: ${NC}Arch Linux, Base devel (AUR only)"
echo " Сценарий pacstrap устанавливает (base) базовую систему. Для сборки пакетов из AUR (Arch User Repository) также требуется группа base-devel. "
echo -e "${MAGENTA}=> ${BOLD}Т.е., Если нужен AUR, ставь base и base-devel, если нет, то ставь только base. ${NC}"
pacstrap /mnt base base-devel nano dhcpcd netctl which inetutils  #wget vim
clear
echo ""
echo " Установка групп (base + base-devel + packages) выполнена "

echo ""
echo -e "${GREEN}==> ${NC}Какое ядро (Kernel) Вы бы предпочли установить вместе с системой Arch Linux?"
echo -e "${BLUE}:: ${NC}Kernel (optional), Firmware"
echo " Будьте осторожны! Если Вы сомневаетесь в своих действиях, можно установить (linux Stable) ядро поставляемое вместе с Rolling Release. "
### Если ли надо раскомментируйте нужные вам значения ####
### LINUX (Stable - ядро Linux с модулями и некоторыми патчами, поставляемое вместе с Rolling Release устанавливаемой системы Arch)
#echo ""
#echo " Установка выбранного вами ядра (linux) "
#pacstrap /mnt linux linux-firmware linux-headers #linux-docs
#clear
#echo ""
#echo " Ядро (linux) операционной системы установленно " 
### LINUX_HARDENED (Ядро Hardened - ориентированная на безопасность версия с набором патчей, защищающих от эксплойтов ядра и пространства пользователя. Внедрение защитных возможностей в этом ядре происходит быстрее, чем в linux)
#echo ""
#echo " Установка выбранного вами ядра (linux-hardened) "
#pacstrap /mnt linux-hardened linux-firmware linux-hardened-headers #linux-hardened-docs
#clear
#echo ""
#echo " Ядро (linux-hardened) операционной системы установленно " 
### LINUX_LTS (Версия ядра и модулей с долгосрочной поддержкой - Long Term Support, LTS)
echo ""
echo " Установка выбранного вами ядра (linux-lts) "
pacstrap /mnt linux-lts linux-firmware linux-lts-headers linux-lts-docs
clear
echo ""
echo " Ядро (linux-lts) операционной системы установленно " 
### LINUX_ZEN (Результат коллективных усилий исследователей с целью создать лучшее из возможных ядер Linux для систем общего назначения)
#echo ""
#echo " Установка выбранного вами ядра (linux-zen) " 
#pacstrap /mnt linux-zen linux-firmware linux-zen-headers #linux-zen-docs
#clear
#echo ""
#echo " Ядро (linux-zen) операционной системы установленно " 

echo ""
echo -e "${GREEN}==> ${NC}Настройка системы, генерируем fstab" 
echo -e "${MAGENTA}=> ${BOLD}Файл /etc/fstab используется для настройки параметров монтирования различных блочных устройств, разделов на диске и удаленных файловых систем. ${NC}"
echo " Таким образом, и локальные, и удаленные файловые системы, указанные в /etc/fstab, будут правильно смонтированы без дополнительной настройки. "
echo ""
echo " Генерируем fstab методом: "
echo " UUID - genfstab -U -p /mnt > /mnt/etc/fstab "
genfstab -pU /mnt >> /mnt/etc/fstab
echo " Проверьте полученный /mnt/etc/fstab файл и отредактируйте его в случае ошибок. " 

echo -e "${BLUE}:: ${NC}Просмотреть содержимое файла fstab"
cat /mnt/etc/fstab
sleep 02
echo " Проверяем UUID: "
blkid /dev/sda*
sleep 02

clear
echo ""
echo -e "${GREEN}==> ${NC}Сменить зеркала для увеличения скорости загрузки пакетов?" 
echo -e "${BLUE}:: ${NC}Загрузка свежего списка зеркал со страницы Mirror Status, и обновление файла mirrorlist."
echo " Команда отфильтрует зеркала для Russia по протоколам (https, http), отсортирует их по скорости загрузки и обновит файл mirrorlist "
echo "" 
echo " Удалим старый файл mirrorlist из /mnt/etc/pacman.d/mirrorlist "
rm /mnt/etc/pacman.d/mirrorlist 
echo " Загрузка свежего списка зеркал со страницы Mirror Status "
pacman -S reflector --noconfirm  # Модуль и скрипт Python 3 для получения и фильтрации последнего списка зеркал Pacman  - пока присутствует в pkglist.x86_64
reflector --verbose --country 'Russia' -l 9 -p https -p http -n 9 --save /etc/pacman.d/mirrorlist --sort rate
echo "" 
echo " Копируем созданный список зеркал (mirrorlist) в /mnt "
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist 
echo " Копируем резервного списка зеркал (mirrorlist.backup) в /mnt "
cp /etc/pacman.d/mirrorlist.backup /mnt/etc/pacman.d/mirrorlist.backup 

clear
echo ""
echo -e "${BLUE}:: ${NC}Посмотреть список серверов-зеркал /mnt/etc/pacman.d/mirrorlist"
echo ""
cat /mnt/etc/pacman.d/mirrorlist

echo ""
echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов" 
sudo pacman -Sy
sleep 03

echo ""
echo -e "${GREEN}=> ${BOLD}Создадим конфигурационный файл для установки системных переменных /etc/sysctl.conf ${NC}"
echo " Sysctl - это инструмент для проверки и изменения параметров ядра во время выполнения (пакет procps-ng в официальных репозиториях ). sysctl реализован в procfs , файловой системе виртуального процесса в /proc/. "
> /etc/sysctl.conf
cat <<EOF >>/etc/sysctl.conf

#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#
# /etc/sysctl.d/99-sysctl.conf
#

#kernel.domainname = example.com

# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
# See http://lwn.net/Articles/277146/
# Note: This may impact IPv6 TCP sessions too
net.ipv4.tcp_syncookies=1

# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
#net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#
net.ipv4.tcp_timestamps=0
net.ipv4.conf.all.rp_filter=1
net.ipv4.tcp_max_syn_backlog=1280
kernel.core_uses_pid=1
#
# Fixing the indicator when writing files to a flash drive
vm.dirty_bytes = 4194304
vm.dirty_background_bytes = 4194304
#
vm.swappiness=10

EOF

echo -e "${BLUE}:: ${NC}Перемещаем и переименовываем исходный файл /etc/sysctl.conf в /etc/sysctl.d/99-sysctl.conf"
echo " Создадим backup sysctl.conf.back "
cp /etc/sysctl.conf  /etc/sysctl.conf.back  # Для начала сделаем его бэкап
echo " Копируем sysctl.conf.back в /mnt "
cp /etc/sysctl.conf.back  /mnt/etc/sysctl.conf.back
echo " Перемещаем sysctl.conf в /mnt "
mv /etc/sysctl.conf /mnt/etc/sysctl.d/99-sysctl.conf   # Перемещаем и переименовываем исходный файл

echo -e "${BLUE}:: ${NC}Добавим в файл /etc/arch-release ссылку на сведение о release"
> /etc/arch-release
cat <<EOF >>/etc/arch-release
Arch Linux release
#../usr/lib/os-release
#Request for release information (Запрос информации о релизе)
#cat /etc/arch-release
#cat /etc/*-release
#cat /etc/issue
#cat /etc/lsb-release
#cat /etc/lsb-release | cut -c21-90
#cat /proc/version

EOF

echo " Копируем arch-release в /mnt "
cp /etc/arch-release  /mnt/etc/arch-release

echo -e "${BLUE}:: ${NC}Создадим файл /etc/lsb-release (информация о релизе)"
> /etc/lsb-release.old
cat <<EOF >>/etc/lsb-release.old 
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
DISTRIB_RELEASE=rolling
DISTRIB_CODENAME="Arch"
DISTRIB_DESCRIPTION="Arch Linux"
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://www.archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://bugs.archlinux.org/"
LOGO=archlinux

EOF

echo " Копируем arch-release в /mnt "
cp /etc/lsb-release.old  /mnt/etc/lsb-release.old

###################################################
clear
echo ""
echo " Первый этап установки Arch'a закончен "
echo -e "${GREEN}=> ${BOLD}Запускаем пользовательский пост-инстал-скрипт (install.sh) для установки первоначально необходимого софта (пакетов), запуск необходимых служб, запись данных в конфиги (hhh.conf) по настройке системы. ${NC}"

cat <<EOF  >> /mnt/opt/install.sh
#!/bin/bash

### SHARED VARIABLES AND FUNCTIONS (ОБЩИЕ ПЕРЕМЕННЫЕ И ФУНКЦИИ)
### Shell color codes (Цветовые коды оболочки)
RED="\e[1;31m"; GREEN="\e[1;32m"; YELLOW="\e[1;33m"; GREY="\e[3;93m"
BLUE="\e[1;34m"; CYAN="\e[1;36m"; BOLD="\e[1;37m"; MAGENTA="\e[1;35m"; NC="\e[0m"

# Автоматическое обнаружение ошибок
set -e  # Эта команда остановит выполнение сценария после сбоя команды и будет отправлен код ошибки
#set -e "\n${RED}Error: ${YELLOW}${*}${NC}"

echo ""
echo -e "${GREEN}=> ${NC}Для проверки интернета можно пропинговать какой-либо сервис" 
ping -c2 archlinux.org

echo -e "${CYAN}==> ${NC}Если пинг идёт едем дальше ... :)"

echo ""
echo -e "${BLUE}:: ${NC}Синхронизация системных часов"  
timedatectl set-ntp true

echo -e "${BLUE}:: ${NC}Посмотрим статус службы NTP (NTP service)"
timedatectl status

echo ""
echo -e "${BLUE}:: ${NC}Обновим вашу систему (базу данных пакетов)"
echo -e "${YELLOW}:: ${NC}Загружаем базу данных пакетов независимо от того, есть ли какие-либо изменения в версиях или нет."
echo ""
# pacman -Syy  # обновление баз пакмэна (как apt-get update в дэбианоподбных)
# pacman -Syy --noconfirm --noprogressbar --quiet  # (-yy принудительно обновить даже если обновленные)
pacman -Syyu --noconfirm  # обновление баз плюс обновление пакетов 
#pacman -Syyuu --noconfirm  # Полный апдейт системы 
sleep 01

echo ""
echo -e "${BLUE}:: ${NC}Установим утилиты Logical Volume Manager 2 пакет (lvm2)"
echo " Если Вы захотите задействовать (попробовать) LVM в действии "
echo " LVM - Менеджер логических томов (англ. Logical Volume Manager). В отличие от разделов жёсткого диска, размеры логических томов можно легко менять. "
pacman -S lvm2 --noconfirm  # Утилиты Logical Volume Manager 2 (https://sourceware.org/lvm2/)

echo -e "${BLUE}:: ${NC}Прописываем имя компьютера"
# echo $hostname > /etc/hostname
echo Terminator > /etc/hostname
# echo "имя_компьютера" > /etc/hostname

echo ""
echo -e "${GREEN}==> ${NC}Устанавливаем ваш часовой пояс (localtime)."
echo " Всё завязано на времени, поэтому очень важно, чтобы часы шли правильно... :) "
echo -e "${BLUE}:: ${BOLD}Для начала вот ваши данные по дате, времени и часовому поясу: ${NC}"
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'    # одновременно отображает дату и часовой пояс
echo ""
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo ""
echo " Создадим резервную копию текущего часового пояса: " 
# cp /etc/localtime /etc/localtime.bak
cp /etc/localtime /etc/localtime.backup
echo " Запишем название часового пояса в /etc/timezone: "
echo $timezone > /etc/timezone
ls -lh /etc/localtime  # для просмотра символической ссылки, которая указывает на текущий часовой пояс, используемый в системе 

echo ""
echo -e "${GREEN}=> ${BOLD}Это ваш часовой пояс (timezone) - '$timezone' ${NC}"
echo -e "${BLUE}:: ${BOLD}Ваши данные по дате, времени и часовому поясу: ${NC}"
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'    # одновременно отображает дату и часовой пояс

echo -e "${BLUE}:: ${NC}Синхронизируем аппаратное время с системным"
echo " Устанавливаются аппаратные часы из системных часов. "
hwclock --systohc  # Эта команда предполагает, что аппаратные часы настроены в формате UTC.
# hwclock --adjust  # Порой значение аппаратного времени может сбиваться - выровняем!
# hwclock -w  # переведёт аппаратные часы

echo ""
echo -e "${GREEN}==> ${NC}Настроим состояние аппаратных и программных часов."   
echo -e "${YELLOW}==> ${NC}Вы можете пропустить этот шаг, если сейчас ваш часовой пояс настроен правильно, или Вы не уверены в правильности выбора! "
### Если ли надо раскомментируйте нужные вам значения ####
### UTC ###
#echo ""
#echo " Вы выбрали hwclock --systohc --utc "
#echo " UTC - часы дают универсальное время на нулевом часовом поясе "
#hwclock --systohc --utc
### Localtime ###
#echo ""
#echo " Вы выбрали hwclock --systohc --localtime "
#echo " Localtime - часы идут по времени локального часового пояса "
#hwclock --systohc --local

echo ""
echo -e "${BLUE}:: ${NC}Посмотрим обновление времени (если настройка не была пропущена)"
timedatectl show
# timedatectl | grep Time

echo ""
echo -e "${BLUE}:: ${NC}Изменяем имя хоста"
echo "127.0.0.1 localhost.(none)" > /etc/hosts
echo "127.0.1.1 $hostname" >> /etc/hosts
echo "::1 localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts
### echo "127.0.1.1 имя_компьютера" >> /etc/hosts
### hostname - Можно написать с Заглавной буквы
# Это дейсвие не обязательно! Мы можем это сделаем из установленной ситемы, если данные не пропишутся автоматом.

echo -e "${BLUE}:: ${NC}Добавляем русскую локаль системы"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
### Есть ещё команды по добавлению русскую локаль в систему:
# echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
# Можно раскомментирвать нужные локали (и убирать #)
#sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
#sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

echo -e "${BLUE}:: ${NC}Обновим текущую локаль системы"
locale-gen  # Мы ввели locale-gen для генерации тех самых локалей.

sleep 02
echo -e "${BLUE}:: ${NC}Указываем язык системы"
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
#echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
### Есть ещё команды : - Эта команда сама пропишет в файлике locale.conf нужные нам параметры
# export LANG=ru_RU.UTF-8
# export LANG=en_US.UTF-8

echo -e "${BLUE}:: ${NC}Вписываем KEYMAP=ru FONT=cyr-sun16 FONT=ter-v16n FONT=ter-v16b"
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
#echo 'COMPRESSION="xz"' >> /etc/mkinitcpio.conf
echo "vboxdrv" > /etc/modules-load.d/virtualbox.conf

clear
echo ""
echo -e "${BLUE}:: ${NC}Проверим корректность загрузки установленных микрокодов " 
echo -e "${MAGENTA}=> ${NC}Если таковые (микрокод-ы: amd-ucode; intel-ucode) были установлены! "
echo " Если микрокод был успешно загружен, Вы увидите несколько сообщений об этом "
echo " Будьте внимательны! Вы можете пропустить это действие. "
echo " Выполним проверку корректности загрузки установленных микрокодов "
dmesg | grep microcode
sleep 04

echo ""
echo -e "${GREEN}==> ${NC}Установить Микрокод для процессора INTEL_CPU, AMD_CPU?"
echo -e "${BLUE}:: ${BOLD}Обновление Microcode (matching CPU) ${NC}"
echo " Производители процессоров выпускают обновления стабильности и безопасности 
        для микрокода процессора "
echo " Огласите весь список, пожалуйста! :) "
echo " 1 - Для процессоров AMD установите пакет amd-ucode. "
echo " 2 - Для процессоров Intel установите пакет intel-ucode. "
echo " 3 - Если Arch находится на съемном носителе, Вы должны установить микрокод для обоих производителей процессоров. "
echo " Для Arch Linux на съемном носителе добавьте оба файла initrd в настройки загрузчика. "
echo " Их порядок не имеет значения, если они оба указаны до реального образа initramfs. "
### Если ли надо раскомментируйте нужные вам значения ####
### Для процессоров AMD ###
echo ""
echo " Устанавливаем uCode для процессоров - AMD "
pacman -S amd-ucode --noconfirm  # Образ обновления микрокода для процессоров AMD
echo " Установлены обновления стабильности и безопасности для микрокода процессора - AMD "
echo " После завершения установки пакета программного обеспечения нужно перезагрузить компьютер "
### Для процессоров INTEL ###
echo ""  
echo " Устанавливаем uCode для процессоров - INTEL "
pacman -S intel-ucode --noconfirm  # Образ обновления микрокода для процессоров INTEL
pacman -S iucode-tool --noconfirm  # Инструмент для управления пакетами микрокода Intel® IA-32 / X86-64
echo " Установлены обновления стабильности и безопасности для микрокода процессора - INTEL "
echo " После завершения установки пакета программного обеспечения нужно перезагрузить компьютер "
### Для процессоров AMD и INTEL ###
#echo ""  
#echo " Устанавливаем uCode для процессоров - AMD и INTEL "
#pacman -S amd-ucode intel-ucode --noconfirm  # Образ обновления микрокода для процессоров AMD и INTEL
#pacman -S iucode-tool --noconfirm  # Инструмент для управления пакетами микрокода Intel® IA-32 / X86-64
#echo " Установлены обновления стабильности и безопасности для микрокода процессоров - AMD и INTEL "
#echo " После завершения установки пакета программного обеспечения нужно перезагрузить компьютер "
# echo ""
# echo -e "${BLUE}:: ${NC}Обновляем grub.cfg (Сгенерируем grub.cfg)"
# grub-mkconfig -o /boot/grub/grub.cfg   # создаём конфигурационный файл 
sleep 02

clear
echo ""
echo -e "${GREEN}==> ${NC}Создадим загрузочный RAM диск (начальный RAM-диск)"
echo -e "${MAGENTA}:: ${BOLD}Arch Linux имеет mkinitcpio - это Bash скрипт используемый для создания начального загрузочного диска системы. ${NC}"
echo -e "${YELLOW}:: ${NC}Чтобы избежать ошибки при создании RAM (mkinitcpio -p), вспомните какое именно ядро Вы выбрали ранее. И загрузочный RAM диск (начальный RAM-диск) будет создан именно с таким же ядром, иначе 'ВАЙ ВАЙ'!"
echo " Будьте внимательными! Здесь представлены варианты создания RAM-диска, с конкретными ядрами. "
### Если ли надо раскомментируйте нужные вам значения ####
### для ядра LINUX ###    
#echo ""
#echo " Создадим загрузочный RAM диск - для ядра (linux) "
#mkinitcpio -p linux   # mkinitcpio -P linux  - при ошибке! 
### для ядра LINUX_HARDENED ###
#echo ""
#echo " Создадим загрузочный RAM диск - для ядра (linux-hardened) "
#mkinitcpio -p linux-hardened 
### для ядра LINUX_LTS ###
echo ""
echo " Создадим загрузочный RAM диск - для ядра (linux-lts) "
mkinitcpio -p linux-lts
### для ядра LINUX_ZEN ### 
#echo ""
#echo " Создадим загрузочный RAM диск - для ядра (linux-zen) " 
#mkinitcpio -p linux-zen 
# echo 'COMPRESSION="lz4"' >> /etc/mkinitcpio.conf

clear
echo ""
echo -e "${GREEN}==> ${NC}Установить (bootloader) загрузчик GRUB(legacy)?"
echo -e "${BLUE}:: ${NC}Установка GRUB2 - полноценной BIOS-версии в Arch Linux"
echo " Файлы загрузчика будут установлены в каталог /boot. Код GRUB (boot.img) будет встроен в начальный сектор, а загрузочный образ core.img в просвет перед первым разделом MBR, или BIOS boot partition для GPT. "
echo " Если нужно установить BIOS-версию загрузчика из-под системы, загруженной в режиме UEFI, тогда раскомментируйте вариант (GRUB --target=i386-pc) " 
echo " В этом варианте требуется принудительно задать программе установки нужную сборку GRUB - "
echo -e "${CYAN} Пример: ${NC}grub-install --target=i386-pc /dev/sdX  (sda; sdb; sdc; sdd)" 
echo -e "${YELLOW}:: ${BOLD}В этих вариантах большого отличия нет, кроме команд выполнения.${NC}"
echo -e "${YELLOW}=> Примечание: ${BOLD}Если вы используете LVM для вашего /boot, вы можете установить GRUB на нескольких физических дисках. ${NC}" 
echo ""
echo " Установим GRUB(legacy) пакет (grub) "
echo ""    
pacman -Syy  # (-yy принудительно обновить даже если обновленные)
pacman -S --noconfirm --needed grub
#pacman -S grub --noconfirm  # Файлы и утилиты для установки GRUB2 содержатся в пакете grub
uname -rm
lsblk -f
### Если ли надо раскомментируйте нужные вам значения ####
### GRUB(legacy) ###
echo ""
echo " Укажем диск куда установить GRUB (sda/sdb например sda или sdb) "
grub-install /dev/sda
# grub-install /dev/$x_cfd  # Записываем загрузчик в MBR (Master Boot Record) нашего внутреннего накопителя (sda; sdb; sdc; sdd)
# grub-install --recheck /dev/sda
# grub-install --recheck /dev/$x_cfd     # Если Вы получили сообщение об ошибке
# grub-install --boot-directory=/mnt/boot /dev/$x_cfd  # установить файлы загрузчика в другой каталог
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
### GRUB --target=i386-pc ###
#echo ""
#echo " Укажем диск куда установить GRUB (sda/sdb например sda или sdb) "
# Если нужно установить BIOS-версию загрузчика из-под системы, загруженной в режиме UEFI
#grub-install --target=i386-pc /dev/$x_cfd  # Записываем загрузчик в MBR (Master Boot Record) нашего внутреннего накопителя (sda; sdb; sdc; sdd)
# grub-install --target=i386-pc --recheck /dev/$x_cfd   # Если Вы получили сообщение об ошибке
echo " Загрузчик GRUB установлен на выбранный вами диск (раздел). "

echo ""
echo -e "${GREEN}==> ${NC}Если на компьютере будут несколько ОС (dual_boot), то это также ставим."
echo -e "${CYAN}:: ${NC}Это утилиты для обнаружения других ОС на наборе дисков, для доступа к дискам MS-DOS, а также библиотека, позволяющая реализовать файловую систему в программе пользовательского пространства."
echo -e "${YELLOW}=> ${NC}Для двойной загрузки Arch Linux с другой системой Linux, Windows, установить другой Linux без загрузчика, вам необходимо установить утилиту os-prober, необходимую для обнаружения других операционных систем."
echo " И обновить загрузчик Arch Linux, чтобы иметь возможность загружать новую ОС."
echo ""    
echo " Устанавливаем программы (пакеты) для определения другой-(их) OS "    
pacman -S os-prober mtools fuse --noconfirm  #grub-customizer  # Утилита для обнаружения других ОС на наборе дисков; Сборник утилит для доступа к дискам MS-DOS; 
echo " Программы (пакеты) установлены " 

echo ""
echo -e "${BLUE}:: ${NC}Обновляем grub.cfg (Сгенерируем grub.cfg)"
echo " Настраиваем и конфигурируем grub "
grub-mkconfig -o /boot/grub/grub.cfg

echo ""
echo -e "${GREEN}==> ${NC}Установить программы (пакеты) для Wi-fi?"
echo -e "${CYAN}:: ${NC}Если у Вас есть Wi-fi модуль и Вы сейчас его не используете, но будете использовать в будущем."
echo " Или Вы подключены через Wi-fi, то эти (пакеты) обязательно установите. "
echo ""    
echo " Устанавливаем программы (пакеты) для Wi-fi "   
pacman -S dialog wpa_supplicant iw wireless_tools net-tools --noconfirm 
echo " Программы (пакеты) для Wi-fi установлены "
sleep 01

clear
echo ""
echo -e "${GREEN}==> ${NC}Добавляем пользователя и прописываем права, (присвоение) групп. "
echo " Давайте рассмотрим варианты (действия), которые будут выполняться. "
echo " (adm + audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel), то вариант - "2" "
echo -e "${CYAN}:: ${BOLD}Далее, пользователь из установленной системы добавляет себя любимого(ую), в нужную группу /etc/group.${NC}"
echo -e "${YELLOW}=> Вы НЕ можете пропустить этот шаг (пункт)! ${NC}"
useradd -m -g users -G adm,audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash alex
# useradd -m -g users -G audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash $username
# useradd -m -g users -G wheel -s /bin/bash $username
echo ""
echo " Пользователь успешно добавлен в группы и права пользователя "

echo ""
echo -e "${GREEN}==> ${NC}Информация о пользователе (полное имя пользователя и связанная с ним информация)"
echo -e "${CYAN}:: ${NC}Пользователь в Linux может хранить большое количество связанной с ним информации, в том числе номера домашних и офисных телефонов, номер кабинета и многое другое."
echo " Мы обычно пропускаем заполнение этой информации (так как всё это необязательно) - при создании пользователя. "
echo -e "${CYAN}:: ${NC}На первом этапе достаточно имени пользователя, и подтверждаем - нажмите кнопку 'Ввод'(Enter)." 
echo " Ввод другой информации (Кабинет, Телефон в кабинете, Домашний телефон) можно пропустить - просто нажмите 'Ввод'(Enter). "
echo -e "${YELLOW}==> ${NC}Вы можете пропустить этот шаг, если не уверены в правильности выбора"
echo " Информация о my username : (достаточно имени) "
chfn $username

clear
echo ""
echo -e "${BLUE}:: ${NC}Устанавливаем (пакет) SUDO."
echo -e "${CYAN}=> ${NC}Пакет sudo позволяет системному администратору предоставить определенным пользователям (или группам пользователей) возможность запускать некоторые (или все) команды в роли пользователя root или в роли другого пользователя, указываемого в командах или в аргументах."
pacman -S --noconfirm --needed sudo
#pacman -S sudo --noconfirm  # Предоставить определенным пользователям возможность запускать некоторые команды от имени пользователя root  - пока присутствует в pkglist.x86_64

echo ""
echo -e "${GREEN}==> ${NC}Настраиваем запрос пароля "Пользователя" при выполнении команды "sudo". "
echo " Чтобы начать использовать sudo как непривилегированный пользователь, его нужно настроить должным образом. "
echo " Огласите весь список, пожалуйста! :) "
echo " 1 - Пользователям (членам) группы wheel доступ к sudo С запросом пароля "
echo " 2 - Пользователям (членам) группы wheel доступ к sudo (NOPASSWD) БЕЗ запроса пароля "
echo -e "${CYAN}:: ${NC}На данном этапе порекомендую вариант - (sudo С запросом пароля) "
### Если ли надо раскомментируйте нужные вам значения #### 
### С запросом пароля ###
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
echo ""
echo " Sudo с запросом пароля выполнено "
### БЕЗ запроса пароля ###
#sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
#echo ""
#echo " Sudo nopassword (БЕЗ запроса пароля) добавлено  "

echo ""
echo -e "${GREEN}==> ${NC}Добавим репозиторий "Multilib" - Для работы 32-битных приложений в 64-битной системе?"
echo -e "${BLUE}:: ${NC}Раскомментируем репозиторий [multilib]"
echo -e "${CYAN}:: ${BOLD}"Multilib" репозиторий может пригодится позже при установке OpenGL (multilib) для драйверов видеокарт, а также для различных библиотек необходимого вам софта. ${NC}"
echo " Чтобы исключить в дальнейшем ошибки в работе системы, рекомендую (добавить Multilib репозиторий). "
### Multilib репозиторий ###
sed -i 's/#Color/Color/' /etc/pacman.conf
#sed -i '/#Color/ s/^#//' /etc/pacman.conf
sed -i '/^Co/ aILoveCandy' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
#echo '[multilib]' >> /etc/pacman.conf
#echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
echo ""
echo " Multilib репозиторий добавлен (раскомментирован) "

echo ""
echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов"  
pacman -Sy   #--noconfirm --noprogressbar --quiet
#pacman -Syy --noconfirm --noprogressbar --quiet

clear
echo ""
echo -e "${GREEN}==> ${NC}Устанавливаем X.Org Server (иксы) и драйвера."
echo -e "${YELLOW}:: ${BOLD}X.Org Foundation Open Source Public Implementation of X11 - это свободная открытая реализация оконной системы X11.${NC}"   
echo " Xorg очень популярен среди пользователей Linux, что привело к тому, что большинство приложений с графическим интерфейсом используют X11, из-за этого Xorg доступен в большинстве дистрибутивов. "
echo -e "${BLUE}:: ${NC}Сперва определим вашу видеокарту!"
echo -e "${MAGENTA}=> ${BOLD}Вот данные по вашей видеокарте (даже, если Вы работаете на VM): ${NC}"
#echo ""
lspci | grep -e VGA -e 3D
#lspci | grep -E "VGA|3D"   # узнаем производителя и название видеокарты
lspci -nn | grep VGA
#lspci | grep VGA        # узнаем ID шины 
# После того как вы узнаете PCI-порт видеокарты, например 1с:00.0, можно получить о ней более подробную информацию:
# sudo lspci -v -s 1с:00.0
echo ""
echo -e "${RED}==> ${NC}Куда Вы устанавливаете Arch Linux на PC, или на Виртуальную машину (VBox;VMWare)?"
echo " Для того, чтобы ускорение видео работало, и часто для того, чтобы разблокировать все режимы, в которых может работать GPU (графический процессор), требуется правильный видеодрайвер. "
echo -e "${MAGENTA}=> ${BOLD}Есть три варианта установки Xorg (иксов): ${NC}"
echo " Давайте проанализируем действия, которые будут выполняться. "
echo " 1 - Если Вы устанавливаете Arch Linux на PC "
echo " 2 - Если Вы устанавливаете Arch Linux на Виртуальную машину (VBox;VMWare) "
echo " 3(0) - Вы можете пропустить установку Xorg (иксов), если используете VDS (Virtual Dedicated Server), или VPS (Virtual Private Server), тогда выбирайте вариант - "0" "
### Если ли надо раскомментируйте нужные вам значения ####
pacman -Syy --noconfirm --noprogressbar --quiet
### Устанавливаем на PC или (ноутбук) ###
echo " Выберите свой вариант (от 1-...), или по умолчанию нажмите кнопку 'Ввод' ("Enter") "
echo " Далее после своего сделанного выбора, нажмите "Y или n" для подтверждения установки. "
#pacman -S xorg-server xorg-drivers xorg-xinit
pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm 
### Устанавливаем на VirtualBox(VMWare) ###
#echo " Выберите свой вариант (от 1-...), или по умолчанию нажмите кнопку 'Ввод' ("Enter") "
#echo " Далее после своего сделанного выбора, нажмите "Y или n" для подтверждения установки. "
#pacman -S xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils 
# pacman -S xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils --noconfirm
### Дополнительно : ###
# pacman -S mesa xorg-apps xorg-twm xterm xorg-xclock xf86-input-synaptics --noconfirm  

#echo -e "${BLUE}:: ${NC}Установка гостевых дополнений vbox"
#modprobe -a vboxguest vboxsf vboxvideo
#cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
#echo -e "\nvboxguest\nvboxsf\nvboxvideo" >> /home/$username/.xinitrc
#sed -i 's/#!\/bin\/sh/#!\/bin\/sh\n\/usr\/bin\/VBoxClient-all/' /home/$username/.xinitrc
sleep 02

clear
echo ""
echo -e "${GREEN}==> ${NC}Ставим DE (графическое окружение) среда рабочего стола."
echo " DE (от англ. desktop environment - среда рабочего стола), это обёртка для ядра Linux, предоставляющая основные функции дистрибутива в удобном для конечного пользователя наглядном виде (окна, кнопочки, стрелочки и пр.). "
### Xfce воплощает традиционную философию UNIX ###
echo ""    
echo " Установка Xfce + Goodies for Xfce "     
pacman -S xfce4 xfce4-goodies --noconfirm
echo ""
echo " DE (среда рабочего стола) Xfce успешно установлено "

echo ""
echo -e "${GREEN}==> ${NC}Настройка автовхода без DM (Display manager) менеджера входа в Xfce"
echo -e "${MAGENTA}=> ${BOLD}Файл ~/.xinitrc представляет собой шелл-скрипт передаваемый xinit посредством команды startx. ${NC}"
echo -e "${MAGENTA}:: ${NC}Он используется для запуска Среды рабочего стола, Оконного менеджера и других программ запускаемых с X сервером (например запуска демонов, и установки переменных окружений."
echo -e "${CYAN}:: ${NC}Программа xinit запускает Xorg сервер и работает в качестве программы первого клиента на системах не использующих Экранный менеджер."
### Автовход без DM (Display manager) ###
echo ""  
  echo " Действия по настройке автовхода без DM (Display manager) "  
  echo " Поскольку реализация автозагрузки окружения реализована через startx - (иксы), то если Вы установили X.Org Server возможно пакет (xorg-xinit) - уже установлен " 
pacman -S --noconfirm --needed xorg-xinit       
# pacman -S xorg-xinit --noconfirm   # Программа инициализации X.Org
# Если файл .xinitrc не существует, то копируем его из /etc/X11/xinit/xinitrc
# в папку пользователя cp /etc/X11/xinit/xinitrc ~/.xinitrc
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc # копируем файл .xinitrc в каталог пользователя
chown $username:users /home/$username/.xinitrc  # даем доступ пользователю к файлу
chmod +x /home/$username/.xinitrc   # получаем права на исполнения скрипта
sed -i 52,55d /home/$username/.xinitrc  # редактируем файл -> и прописываем команду на запуск
# # Данные блоки нужны для того, чтобы StartX автоматически запускал нужное окружение, соответственно в секции Window Manager of your choice раскомментируйте нужную сессию
echo "exec startxfce4 " >> /home/$username/.xinitrc  
mkdir /etc/systemd/system/getty@tty1.service.d/  # создаём папку
echo " [Service] " > /etc/systemd/system/getty@tty1.service.d/override.conf
echo " ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo   ExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux >> /etc/systemd/system/getty@tty1.service.d/override.conf
# Делаем автоматический запуск Иксов в нужной виртуальной консоли после залогинивания нашего пользователя
echo ' [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx ' >> /etc/profile 
echo ""
echo " Действия по настройке автовхода без DM (Display manager) выполнены "

clear 
echo ""
echo -e "${GREEN}==> ${NC}Ставим DM (Display manager) менеджера входа."
echo " DM - Менеджер дисплеев, или Логин менеджер, обычно представляет собой графический пользовательский интерфейс, который отображается в конце процесса загрузки вместо оболочки по умолчанию. "
### LightDM ###
  echo ""  
  echo " Установка LightDM (менеджера входа) "
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm
pacman -S light-locker --noconfirm  # Простой шкафчик сессий для LightDM
echo " Установка DM (менеджера входа) завершена "
echo ""
echo " Подключаем автозагрузку менеджера входа "
#systemctl enable lightdm.service
systemctl enable lightdm.service -f
sleep 1 

clear
echo ""
echo -e "${GREEN}==> ${NC}Установить сетевые утилиты Networkmanager?"
echo -e "${BLUE}:: ${NC}'Networkmanager' - сервис для работы интернета."
echo " NetworkManager можно установить с пакетом networkmanager, который содержит демон, интерфейс командной строки (nmcli) и интерфейс на основе curses (nmtui). Вместе с собой устанавливает программы (пакеты) для настройки сети. "
echo -e "${CYAN}=> ${NC}После запуска демона NetworkManager он автоматически подключается к любым доступным системным соединениям, которые уже были настроены. Любые пользовательские подключения или ненастроенные подключения потребуют nmcli или апплета для настройки и подключения."
echo -e "${CYAN}=> ${NC}Поддержка OpenVPN в Network Manager также внесена в список устанавливаемых программ (пакетов)."
echo ""
echo " Ставим сетевые утилиты Networkmanager "    
pacman -S networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm
#pacman -Sy networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm
echo ""
echo -e "${BLUE}:: ${NC}Подключаем Networkmanager в автозагрузку" 
#systemctl enable NetworkManager
systemctl enable NetworkManager.service
echo " NetworkManager успешно добавлен в автозагрузку "
sleep 02

clear
echo ""
echo -e "${GREEN}==> ${NC}Добавим службу Dhcpcd в автозагрузку (для проводного интернета)?"
echo " Добавим dhcpcd в автозагрузку (для проводного интернета, который получает настройки от роутера). "
echo -e "${CYAN}:: ${NC}Dhcpcd - свободная реализация клиента DHCP и DHCPv6. Пакет dhcpcd является частью группы base, поэтому, скорее всего он уже установлен в вашей системе."
echo " Если необходимо добавить службу Dhcpcd в автозагрузку это можно сделать уже в установленной системе Arch'a "
echo ""    
#systemctl enable dhcpcd   # для активации проводных соединений
systemctl enable dhcpcd.service
echo " Dhcpcd успешно добавлен в автозагрузку "

echo ""
echo -e "${BLUE}:: ${NC}Ставим шрифты"  # https://www.archlinux.org/packages/
pacman -S ttf-dejavu --noconfirm  # Семейство шрифтов на основе Bitstream Vera Fonts с более широким набором символов
pacman -S ttf-liberation --noconfirm  # Шрифты Red Hats Liberation
pacman -S ttf-anonymous-pro --noconfirm  # Семейство из четырех шрифтов фиксированной ширины, разработанных специально с учетом кодирования
pacman -S terminus-font --noconfirm  # Моноширинный растровый шрифт (для X11 и консоли)

echo ""
echo -e "${BLUE}:: ${NC}Монтирование разделов NTFS и создание ссылок" 
pacman -S ntfs-3g --noconfirm  # Драйвер и утилиты файловой системы NTFS; "NTFS file support (Windows Drives)"

echo ""
echo -e "${BLUE}:: ${NC}Установка базовых программ и пакетов"
echo -e " Установка базовых программ (пакетов): wget, curl, git "
pacman -S wget git --noconfirm  #curl  - пока присутствует в pkglist.x86_64

echo ""
echo -e "${GREEN}==> ${NC}Установка ZSH (bourne shell) командной оболочки"
echo -e "${CYAN}:: ${NC}Z shell, zsh - является мощной, одной из современных командных оболочек, которая работает как в интерактивном режиме, так и в качестве интерпретатора языка сценариев (скриптовый интерпретатор)."
echo " Он совместим с bash (не по умолчанию, только в режиме emulate sh), но имеет преимущества, такие как улучшенное завершение и подстановка. "
echo " Будьте внимательны! Процесс установки, был прописан полностью автоматическим. В данной опции выбор всегда остаётся за вами. "
echo -e "${MAGENTA}=> ${BOLD}Вот какая оболочка (shell) используется в данный момент: ${NC}"
echo $SHELL
echo "" 
echo " Установка ZSH (shell) оболочки "
pacman -S zsh zsh-syntax-highlighting zsh-autosuggestions grml-zsh-config --noconfirm
pacman -S zsh-completions zsh-history-substring-search  --noconfirm  
echo 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> /etc/zsh/zshrc
echo 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> /etc/zsh/zshrc
#echo 'prompt adam2' >> /etc/zsh/zshrc
echo 'prompt fire' >> /etc/zsh/zshrc

echo ""
echo -e "${BLUE}:: ${NC}Сменим командную оболочку пользователя с Bash на ZSH ?"
echo -e "${YELLOW}=> Примечание: ${BOLD}Если вы пока не хотите использовать ZSH (shell) оболочку, то команды выполнения нужно закомментировать!${NC}"
echo " Будьте внимательны! В данной опции выбор всегда остаётся за вами. "
echo "" 
chsh -s /bin/zsh
chsh -s /bin/zsh $username
echo ""
echo " Важно! При первом запуске консоли (терминала) - нажмите "0" "
echo " Пользовательская оболочка ИЗМЕНЕНА (сразу будет), с BASH на на ZSH "

echo ""
echo -e "${GREEN}==> ${NC}Создаём папки в директории пользователя (Downloads, Music, Pictures, Videos, Documents)."
echo -e "${BLUE}:: ${NC}Создание полного набора локализованных пользовательских каталогов по умолчанию (Загрузки, Шаблоны, Общедоступные, Документы, Музыка, Изображения, Видео) в пределах "HOME" каталога."
echo -e "${CYAN}:: ${NC}По умолчанию в системе Arch Linux в каталоге "HOME" НЕ создаются папки (Загрузки, Шаблоны, Общедоступные, Документы, Музыка, Изображения, Видео), кроме папки Рабочий стол (Desktop)."
echo ""  
echo " Создание пользовательских каталогов по умолчанию "     
pacman -S xdg-user-dirs --noconfirm  # Управляйте пользовательскими каталогами, такими как ~ / Desktop и ~ / Music
# pacman -S xdg-user-dirs-gtk --noconfirm  # Создаёт каталоги пользователей и просит их переместить
xdg-user-dirs-update 
# xdg-user-dirs-gtk-update  # Обновить закладки в thunar (левое меню)
echo "" 
echo " Создание каталогов успешно выполнено "

#read -p "Введите допольнительные пакеты которые вы хотите установить: " packages 
#pacman -S $packages --noconfirm

#exit

EOF

##########################
arch-chroot /mnt /bin/bash  /opt/install.sh

echo ""
echo -e "${GREEN}==> ${NC}Создаём root пароль (Root Password)"
echo " Пароль должен содержать от 6 до 15 символов, включающих цифры (1-0) и знаки (!'':[@]),     
        и латинские буквы разного регистра! "
echo -e "${MAGENTA}=> ${BOLD}По умолчанию, на большинстве систем Linux в консоле не показывается введенный пароль. 
Это сделано из соображений безопасности, чтобы никто не мог увидеть длину вашего пароля.${NC}"  
echo " => Root Password (Пароль суперпользователя) - вводим (прописываем) 2 раза "              
arch-chroot /mnt /bin/bash -x << _EOF_
passwd
t@@r00
t@@r00
_EOF_

echo ""
echo -e "${GREEN}==> ${NC}Устанавливаем пароль пользователя (User Password)"
echo " Пароль должен содержать от 6 до 15 символов, включающих цифры (1-0) и знаки (!'':[@]),    
        и латинские буквы разного регистра! "
echo -e "${MAGENTA}=> ${BOLD}По умолчанию, на большинстве систем Linux в консоле не показывается введенный пароль. 
Это сделано из соображений безопасности, чтобы никто не мог увидеть длину вашего пароля.${NC}"
echo " => User Password (Пароль пользователя) - вводим (прописываем) 2 раза "
# passwd $username
arch-chroot /mnt /bin/bash -x << _EOF_
passwd alex
555
555
_EOF_

echo ""
echo -e "${BLUE}:: ${NC}Проверим статус пароля для всех учетных записей пользователей в вашей системе"
echo -e "${CYAN}:: ${NC}В выведенном списке те записи, которые сопровождены значением (лат.буквой) P - значит на этой учетной записи установлен пароль!"
echo -e "${CYAN} Пример: ${NC}(root P 10/11/2020 -1 -1 -1 -1; или $username P 10/11/2020 0 99999 7 -1)"
arch-chroot /mnt /bin/bash -x << _EOF_
passwd -Sa  # -S, --status вывести статус пароля
_EOF_

sleep 02
clear
echo ""
echo -e "${BLUE}:: ${BOLD}Очистка кэша pacman 'pacman -Sc' ${NC}"
echo -e "${CYAN}=> ${NC}Очистка кэша неустановленных пакетов (оставив последние версии оных), и репозиториев..."
pacman --noconfirm -Sc  # Очистка кэша неустановленных пакетов (оставив последние версии оных) 

echo "" 
echo -e "${CYAN}=> ${NC}Удалить кэш ВСЕХ установленных пакетов 'pacman -Scc' (высвобождая место на диске)?"
echo " Процесс удаления кэша ВСЕХ установленных пакетов - БЫЛ прописан полностью автоматическим! "
echo -e "${YELLOW}==> ${NC} Будьте внимательны! Если Вы сомневаетесь в своих действиях, ещё раз обдумайте..."
echo ""
echo " Удаление кэша ВСЕХ установленных пакетов пропущено "           
pacman --noconfirm -Scc  # Удалит кеш всех пакетов (можно раз в неделю вручную запускать команду)

clear             
echo -e "${GREEN}
  <<< Поздравляем! Установка завершена. Перезагрузите систему. >>> 
${NC}"
echo -e "${BLUE}:: ${BOLD}Посмотрим дату и время ... ${NC}"
date
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'     # одновременно отображает дату и часовой пояс

echo -e "${BLUE}:: ${BOLD}Отобразить время работы системы ... ${NC}"
uptime

echo -e "${MAGENTA}==> ${BOLD}После перезагрузки и входа в систему проверьте ваши персональные настройки. ${NC}"
echo -e "${MAGENTA}==> ${BOLD}Если у Вас беспроводное соединение, запустите nmtui (Network Manager Text User Interface) и подключитесь к сети. ${NC}"
echo -e "${YELLOW}==> ...${NC}"
echo -e "${BLUE}:: ${NC}Если хотите подключить AUR, установить дополнительный софт (пакеты), установить мои конфиги для DE/XFCE, тогда после перезагрузки и входа в систему выполните команду:"
echo -e "${YELLOW}==> ${CYAN}wget git.io/archmy3l && sh archmy3l ${NC}"
echo -e "${CYAN}:: ${NC}Цель скрипта (archmy3l) - это установка первоначально необходимого софта (пакетов) и запуск необходимых служб."
echo -e "${CYAN}:: ${NC}Скриптом можно пользоваться как шпаргалкой, открыв его в текстовом редакторе, копируя команды по установке необходимых пакетов, и запуска служб."
echo -e "${GREEN}
  <<< Желаю Вам удачи во всех начинаниях, верных и точных решений! >>> ${NC}"
echo ""
echo -e "${RED}### ${BLUE}########################################################### ${RED}### ${NC}" 
echo -e "${RED}==> ${BOLD}Выходим из установленной системы ${NC}"

echo -e "${BLUE}:: ${BOLD}Теперь вам надо ввести (exit) reboot, чтобы перезагрузиться ${NC}"
umount -a
exit
exit
umount -Rf /mnt

# umount -a
# reboot

