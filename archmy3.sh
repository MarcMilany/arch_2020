#!/bin/bash
### Смотрите пометки (справочки) и доп.иформацию в самом скрипте!
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
#echo ""
#echo -e "${MAGENTA}==> ${BOLD}Если у Вас беспроводное соединение, запустите nmtui и подключитесь к сети. ${NC}"
#echo 'Если у Вас беспроводное соединение, запустите nmtui и подключитесь к сети.'
# If you have a wireless connection, launch nmtui and connect to the network.
###
echo -e "${GREEN}
  <<< Начинается установка первоначально необходимого софта (пакетов) и запуск необходимых служб для системы Arch Linux >>>
${NC}"
echo -e "${BLUE}:: ${NC}Установка и настройка начата в $(date +%T)" 
echo ""
echo -e "${GREEN}=> ${NC}Для проверки интернета можно пропинговать какой-либо сервис"
ping -c2 archlinux.org
echo -e "${CYAN}==> ${NC}Если пинг идёт едем дальше ... :)"
###
echo ""
echo -e "${MAGENTA}==> ${NC}Давайте проверим наш часовой пояс ... :)"
#echo 'Давайте проверим наш часовой пояс ... :)'
# Let's check our time zone ... :)
timedatectl | grep "Time zone"
###
echo ""
echo -e "${BLUE}:: ${NC}Если NetworkManager запущен смотрим состояние интерфейсов" 
# Если NetworkManager запущен смотрим состояние интерфейсов (с помощью - nmcli):  
nmcli general status
echo ""
echo -e "${BLUE}:: ${NC}Посмотреть имя хоста"
nmcli general hostname 
echo ""
echo -e "${BLUE}:: ${NC}Получаем состояние интерфейсов"
nmcli device status
echo ""
echo -e "${BLUE}:: ${NC}Смотрим список доступных подключений"
# See the list of available connections
nmcli connection show
echo ""
echo -e "${BLUE}:: ${NC}Смотрим состояние wifi подключения"
nmcli radio wifi
# ---------------------------------
# Посмотреть список доступных сетей wifi:
# nmcli device wifi list
# Теперь включаем:
# nmcli radio wifi on
# Или отключаем:
# nmcli radio wifi off
# Команда для подключения к новой сети wifi выглядит не намного сложнее. Например, давайте подключимся к сети TP-Link с паролем 12345678:
# nmcli device wifi connect "TP-Link" password 12345678 name "TP-Link Wifi"
# Если всё прошло хорошо, то вы получите уже привычное сообщение про создание подключения с именем TP-Link Wifi и это имя в дальнейшем можно использовать для редактирования этого подключения и управления им, как описано выше.
# ------------------------------
####################
echo ""
echo -e "${BLUE}:: ${NC}Посмотрим данные о нашем соединение с помощью IPinfo..." 
#echo " Посмотрим данные о нашем соединение с помощью IPinfo..."
# Let's look at the data about our connection using IP info...
echo -e "${CYAN}=> ${NC}С помощью IPinfo вы можете точно определять местонахождение ваших пользователей, настраивать их взаимодействие, предотвращать мошенничество, обеспечивать соответствие и многое другое."
echo " Надежный источник данных IP-адресов (https://ipinfo.io/) "
wget http://ipinfo.io/ip -qO -
sleep 03
####################
echo ""
echo -e "${BLUE}:: ${NC}Узнаем версию и данные о релизе Arch'a ... :) " 
#echo "Узнаем версию и данные о релизе Arch'a ... :)"
# Find out the version and release data for Arch ... :)
cat /proc/version
cat /etc/lsb-release.old
sleep 02
####################
echo ""
echo -e "${BLUE}:: ${NC}Обновим вашу систему (базу данных пакетов)"
echo -e "${YELLOW}:: ${NC}Загружаем базу данных пакетов независимо от того, есть ли какие-либо изменения в версиях"
echo ""
echo " Установка обновлений (базы данных пакетов) "
sudo pacman -Syyu --noconfirm  # Обновление баз плюс обновление пакетов (--noconfirm - не спрашивать каких-либо подтверждений)
# sudo pacman -Syyu  # Обновим вашу систему (базу данных пакетов)
sleep 01
######################
clear
echo -e "${MAGENTA}
  <<< Смена, обновление зеркал для увеличения скорости загрузки утилит (пакетов). >>> ${NC}"
echo ""
echo -e "${GREEN}==> ${NC}Сменим зеркала для увеличения скорости загрузки пакетов" 
echo -e "${BLUE}:: ${NC}Загрузка свежего списка зеркал со страницы Mirror Status, и обновление файла mirrorlist."
echo " Команда отфильтрует зеркала для Russia по протоколам (https, http), отсортирует их по скорости загрузки и обновит файл mirrorlist "
echo "" 
echo " Проверим присутствует ли пакет (reflector) "
sudo pacman -Sy --noconfirm --noprogressbar --quiet reflector  # Модуль и скрипт Python 3 для получения и фильтрации последнего списка зеркал Pacman  - пока присутствует в pkglist.x86_64
sudo pacman -S --noconfirm --needed --noprogressbar --quiet reflector
echo ""
echo " Создание резервной копии файла /etc/pacman.d/mirrorlist "
sudo cp -vf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
echo ""
echo " Загрузка свежего списка зеркал со страницы Mirror Status "
sudo reflector --verbose --country 'Russia' -l 9 -p https -p http -n 9 --save /etc/pacman.d/mirrorlist --sort rate
###
echo ""
echo -e "${CYAN}:: ${NC}Уведомление о загрузке и обновлении свежего списка зеркал"
# Собственные уведомления (notify):
notify-send "mirrorlist обновлен" -i gtk-info
###
echo ""
echo -e "${BLUE}:: ${NC}Создание резервной копии нового файла /etc/pacman.d/mirrorlist"
sudo cp -vf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacnew
###
clear
echo ""
echo -e "${BLUE}:: ${NC}Посмотреть список серверов-зеркал /mnt/etc/pacman.d/mirrorlist"
echo ""
cat /etc/pacman.d/mirrorlist  # cat читает данные из файла или стандартного ввода и выводит их на экран
echo ""
echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов" 
sudo pacman -Sy --noconfirm  # обновить списки пакетов из репозиториев
sleep 01
##########################
clear
echo ""
echo -e "${YELLOW}==> ${NC}Обновить и добавить новые ключи?"
echo " Данный этап поможет вам избежать проблем с ключами Pacmаn, если Вы использовали не свежий образ ArchLinux для установки! "
echo -e "${RED}==> ${YELLOW}Примечание: ${BOLD}- Иногда при запуске обновления ключей по hkp возникает ошибка, не переживайте просто при установке gnupg в линукс в дефолтном конфиге указан следующий сервер: (keyserver hkp://keys.gnupg.net). GnuPG - оснащен универсальной системой управления ключами, а также модулями доступа для всех типов открытых ключей. GnuPG, также известный как GPG, это инструмент командной строки с возможностью легкой интеграции с другими приложениями. Доступен богатый выбор пользовательских приложений и библиотек. ${NC}"
echo -e "${RED}==> ${BOLD}Примечание: - Однако, в ходе чтения различных руководств в интернете было выяснено, что подобный способ обновления и передачи ключей не самый лучший, т.к. эта информация передается открытым способом. И тот, кто наблюдает за траффиком, видит данные обновляемых при gpg -refresh-keys ключей. И поэтому рекомендуется использовать hkps сервера - (keyserver hkps://hkps.pool.sks-keyservers.net)! ${NC}"
echo " Будьте внимательны! Если Вы сомневаетесь в своих действиях, можно пропустить запуск обновления ключей. "   
echo ""
echo " Выполним резервное копирование каталога (/etc/pacman.d/gnupg), на всякий случай "
# Файлы конфигурации по умолчанию: ~/.gnupg/gpg.conf и ~/.gnupg/dirmngr.conf.
sudo cp -R /etc/pacman.d/gnupg /etc/pacman.d/gnupg_back
# Я тебе советовал перед созданием нового брелка удалить директории (но /root/.gnupg не удалена)
echo " Удалим директорию (/etc/pacman.d/gnupg) "
sudo rm -R /etc/pacman.d/gnupg
# sudo rm -r /etc/pacman.d/gnupg
# sudo mv /usr/lib/gnupg/scdaemon{,_}  # если демон смарт-карт зависает (это можно обойти с помощью этой команды)
echo " Выполним резервное копирование каталога (/root/.gnupg), на всякий случай "
sudo cp -R /root/.gnupg /root/.gnupg_back        
#echo " Удалим директорию (/etc/pacman.d/gnupg) "
#sudo rm -R /root/.gnupg
echo " Создаётся генерация мастер-ключа (брелка) pacman "  # gpg –refresh-keys
sudo pacman-key --init  # генерация мастер-ключа (брелка) pacman
echo " Далее идёт поиск ключей... "
sudo pacman-key --populate archlinux  # поиск ключей
echo ""
echo " Обновление ключей... "  
sudo pacman-key --refresh-keys --keyserver keys.gnupg.net  # http://pool.sks-keyservers.net/
echo ""
echo "Обновим базы данных пакетов..."
###  sudo pacman -Sy
sudo pacman -Syy  # обновление баз пакмэна (pacman) 
# sudo pacman -Syyu  # Обновим вашу систему (базу данных пакетов)
# sudo pacman -Syyu  --noconfirm  
echo ""
echo " Обновление и добавление новых ключей выполнено "
####################
clear
echo ""
echo -e "${BLUE}:: ${NC}Установить приложение Seahorse для управления вашими паролями и ключами шифрования?"
echo -e "${MAGENTA}=> ${BOLD}Seahorse - специализированное Vala / GTK / Gnome (GCR/GCK) графическое приложение для создания и централизованного хранения ключей шифрования и паролей. ${NC}"
echo " Основным назначением Seahorse является предоставление простого в использовании инструмента для управления ключами шифрования и паролями, а также операций шифрования. Приложение является графическим интерфейсом (GUI) к консольным утилитам GnuPG (GPG) и SSH (Secure Shell). "
echo -e "${CYAN}:: ${NC}GPG / GnuPG (GNU Privacy Guard) - консольная утилита для шифрования информации и создания электронных цифровых подписей с помощью различных алгоритмов (RSA, DSA, AES и др...). Утилита создана как свободная альтернатива проприетарному PGP (Pretty Good Privacy) и полностью совместима с стандартом IETF OpenPGP (может взаимодействовать с PGP и другими OpenPGP-совместимыми системами)."
echo -e "${CYAN}:: ${NC}SSH (Secure Shell - Безопасная Оболочка) — сетевой протокол прикладного уровня, позволяющий проводить удалённое управление операционной системой и туннелирование TCP-соединений (например для передачи файлов). Весь трафик шифруется, включая и передаваемые пароли, предоставляя возможность выбора используемых алгоритмов шифрования."
echo " Будьте внимательны! Процесс установки, был прописан полностью автоматическим. "
echo ""    
echo " Установка приложение Seahorse для управления ключами PGP "
sudo pacman -S seahorse --noconfirm  # Приложение GNOME для управления ключами PGP (управления паролями и ключами шифрования)
echo ""
echo " Установка Приложение GNOME для управления ключами PGP "
######################
clear
echo -e "${MAGENTA}
  <<< Синхронизации времени (Время от времени часы на компьютере могут сбиваться по различным причинам). >>> ${NC}"
echo ""
echo -e "${GREEN}==> ${NC}Если у Вас Сбиваются настройки времени (или параллельно установлена Windows...)"
#echo 'Если у Вас Сбиваются настройки времени (или параллельно установлена Windows...)
# If you have Lost the time settings (or Windows is installed in parallel...)
echo -e "${BLUE}:: ${BOLD}Посмотрим дату, время, и часовой пояс ... ${NC}"
timedatectl | grep "Time zone"
date
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'     # одновременно отображает дату и часовой пояс
echo ""
echo -e "${MAGENTA}:: ${NC}Для ИСПРАВЛЕНИЯ (синхронизации времени) предложено несколько вариантов (ntp и openntpd)."
echo -e "${CYAN}=> ${BOLD}В сценарии (скрипте) присутствуют следующие варианты: ${NC}"
echo " 1 - Установка NTP Servers (серверы точного времени) - пакет (ntp - Эталонная реализация сетевого протокола времени). Список общедоступных NTP серверов доступен на сайте http://ntp.org. "
echo -e "${CYAN}:: ${NC}На сегодняшний день существует множество технологий синхронизации часов, из которых наиболее широкую популярность получила NTP. Что такое NTP? NTP (Network Time Protocol) - стандартизированный протокол, который работает поверх UDP и используется для синхронизации локальных часов с часами на сервере точного времени (на различных операционных системах)."  # NTP Servers (серверы точного времени) - https://www.ntp-servers.net/
echo " 2 - Установка OpenNTPD - пакет (openntpd - Бесплатная и простая в использовании реализация протокола сетевого времени). По умолчанию OpenNTPd использует серверы pool.ntp.org (это огромный кластер серверов точного времени) и работает только как клиент."  # Introduction - https://www.ntppool.org/ru/ 
echo -e "${CYAN}:: ${NC}OpenNTPD - это свободная и простая в использовании реализация протокола NTP, первоначально разработанная в рамках проекта OpenBSD. OpenNTPd дает возможность синхронизировать локальные часы с удаленными серверами NTP."
echo " Будьте внимательны! В данной опции выбор всегда остаётся за вами. "
echo ""
echo " Установка NTP (Network Time Protocol) "
sudo pacman -S ntp --noconfirm  # Эталонная реализация сетевого протокола времени
echo ""
echo " Установка времени по серверу NTP (Network Time Protocol)(ru.pool.ntp.org) "
sudo ntpdate 0.ru.pool.ntp.org  # будем использовать NTP сервера из пула ru.pool.ntp.org
#sudo ntpdate 1.ru.pool.ntp.org  # Список общедоступных NTP серверов доступен на сайте http://ntp.org
#sudo ntpdate 2.ru.pool.ntp.org  # Отредактируйте /etc/ntp.conf для добавления/удаления серверов (server)
#sudo ntpdate 3.ru.pool.ntp.org  # После изменений конфигурационного файла вам надо перезапустить ntpd (sudo service ntp restart) - Просмотр статуса: (sudo ntpq -p)
echo " Синхронизации с часами BIOS "  # Синхронизируем аппаратное время с системным
echo " Устанавливаются аппаратные часы из системных часов. "
sudo hwclock --systohc  # Эта команда предполагает, что аппаратные часы настроены в формате UTC.
# sudo hwclock -w  # переведёт аппаратные часы
# sudo hwclock --adjust  # Порой значение аппаратного времени может сбиваться - выровняем!
echo ""
echo " Установка NTP (Network Time Protocol) выполнена "
echo " Время точное как на Спасской башне Московского Кремля! "
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'   # одновременно отображает дату и часовой пояс
###
#echo ""
#echo " Установка OpenNTPD"
#sudo pacman -S openntpd --noconfirm  # Бесплатная и простая в использовании реализация протокола сетевого времени
#echo " Добавим в автозагрузку OpenNTPD (openntpd.service) "
#systemctl enable openntpd.service
#echo " Установка OpenNTPD и запуск (openntpd.service) выполнен "
####################
clear
echo ""
echo -e "${BLUE}:: ${NC}Создадим папку (downloads), и перейдём в созданную папку " 
#echo " Создадим папку (downloads), и переходим в созданную папку "
# Create a folder (downloads), and go to the created folder
echo -e "${MAGENTA}=> ${NC}Почти весь процесс: по загрузке, сборке софта (пакетов) устанавливаемых из AUR - будет проходить в папке (downloads)."
echo -e "${CYAN}:: ${NC}Если Вы захотите сохранить софт (пакеты) устанавливаемых из AUR, и в последствии создать свой маленький (пользовательский репозиторий Arch), тогда перед удалением папки (downloads) в заключении работы скрипта, скопируйте нужные вам пакеты из папки (downloads) в другую директорию."
echo -e "${YELLOW}==> Примечание: ${NC}Вы можете пропустить создание папки (downloads), тогда сборка софта (пакетов) устанавливаемых из AUR - будет проходить в папке указанной (для сборки) Pacman gui (в его настройках, если таковой был установлен), или по умолчанию в одной из системных папок (tmp;...;...)." 
echo " В заключении работы сценария (скрипта) созданная папка (downloads) - Будет полностью удалена из домашней (home) директории! "
echo ""
echo " Создаём и переходим в созданную папку (downloads) "
mkdir ~/downloads  # создание папки (downloads)
cd ~/downloads  # перейдём в созданную папку
echo " Посмотрим в какой директории мы находимся "
pwd  # покажет в какой директории мы находимся
#####################
clear
echo -e "${MAGENTA}
  <<< Установка сетевого экрана (брандмауэр UFW) и антивируса (ClamAV) для Archlinux >>> ${NC}"
echo -e "${CYAN}:: ${NC}Если Вы "Дока", то настройте под свои нужды утилиту 'Iptables'(firewall)" 
echo ""
echo -e "${GREEN}==> ${NC}Установить UFW (Несложный Брандмауэр) (ufw, gufw) (GUI)(GTK)?"
echo -e "${CYAN}:: ${BOLD}Ufw расшифровывается как Uncomplicated Firewall и представляет собой программу для управления межсетевым экраном netfilter. ${NC}"
echo " Будьте внимательны! Процесс установки, был прописан полностью автоматическим. " 
echo ""    
echo " Установка UFW (Несложный Брандмауэр) "
sudo pacman -S ufw gufw --noconfirm  # Несложный и простой в использовании инструмент командной строки для управления межсетевым экраном netfilter; GUI - для управления брандмауэром Linux
# sudo pacman -S firewalld --noconfirm  # Демон межсетевого экрана с интерфейсом D-Bus 
echo " Установка Брандмауэра UFW завершена "
###
echo ""
echo -e "${BLUE}:: ${NC}Запускаем и добавляем в автозапуск Uncomplicated Firewall UFW (сетевой экран)"
echo -e "${GREEN}==> ${NC}Включаем Firewall UFW (сетевой экран)"
echo -e "${CYAN}:: ${NC}Вы сможете включить UFW (сетевой экран) позже, воспользовавшись скриптом как шпаргалкой!"
echo " Будьте внимательны! В любой ситуации выбор всегда остаётся за вами. "
echo ""  
echo " Запускаем UFW (сетевой экран) "
sudo ufw enable
sleep 01
###
echo ""
echo -e "${BLUE}:: ${NC}Проверим статус запуска Firewall UFW (сетевой экран)" 
echo -e "${MAGENTA}:: ${BOLD}Если нужно ВЫКлючить UFW (сетевой экран), то используйте команду: sudo ufw disable. ${NC}"
echo "" 
sudo ufw status
#sudo ufw status --verbose
sleep 01
###
echo ""
echo -e "${GREEN}==> ${NC}Добавляем в автозагрузку Firewall UFW (сетевой экран)"
echo -e "${CYAN}:: ${NC}Вы сможете добавить в автозагрузку UFW (сетевой экран) позже, воспользовавшись скриптом как шпаргалкой!"
echo " Будьте внимательны! В любой ситуации выбор всегда остаётся за вами. "
echo ""  
echo " Добавляем в автозагрузку UFW (сетевой экран) "
sudo systemctl enable ufw
#sudo systemctl start ufw
# sudo systemctl enable firewalld
###################
echo ""
echo -e "${GREEN}==> ${NC}Установим Clam AntiVirus (clamav, clamtk) (GUI)(GTK)"
echo -e "${CYAN}:: ${BOLD}ClamAV - это антивирусный движок с открытым исходным кодом для обнаружения троянов, вирусов, вредоносных программ и других вредоносных угроз. ${NC}"
echo " ClamAV включает в себя демон многопоточного сканера, утилиты для сканирования файлов по запросу, почтовых шлюзов с открытым исходным кодом и автоматическим обновлением сигнатур. "
echo " Поддерживает несколько форматов файлов, распаковку файлов и архивов, а также несколько языков подписи. "
echo " Будьте внимательны! Процесс установки, был прописан полностью автоматическим. "
echo ""  
echo " Установка Clam AntiVirus "
sudo pacman -S clamav clamtk --noconfirm  # Антивирусный инструментарий для Unix; Простой в использовании, легкий сканер вирусов по запросу для систем Linux
echo " Установка Clam AntiVirus завершена "
sleep 02
#######################
clear


##################
echo ""
echo -e "${BLUE}:: ${NC}Установим GPM (General Purpose Mouse) - пакет (gpm)"
echo " GPM (General Purpose Mouse) - демон, позволяющий использовать мышь в виртуальных терминалах Linux "
echo -e "${YELLOW}=> Примечание: ${BOLD}Для запуска демона gpm необходимо указать некоторые опции. С помощью опции -m определяется файл устройства мыши. Опция -t используется для указания типа мыши. Чтобы отобразить список возможных вариантов для опции -t, выполните команду gpm -m устройство -t help ${NC}"
echo " Параметры запуска демона можно также указать в файле /etc/conf.d/gpm "
pacman -S gpm --noconfirm  # Сервер мыши для консоли и xterm
# gpm -m /dev/input/mice -t help  # Для получение более подробной информации
echo ""   
echo " Запускаем обслуживания gpm сервера мыши для консоли и xterm "
sudo systemctl start gpm
echo ""   
echo " Добавляем службу gpm в автозагрузку "
sudo systemctl enable gpm
echo ""   
echo " Установка дополнительных базовых программ (пакетов) выполнена "
################




###############
echo ""
echo " Настройка раскладки клавиатуры в X.Org " 
localectl --no-convert set-x11-keymap us,ru pc105 "" grp:alt_shift_toggle
###################

#####################
echo "" 
echo " Создание шаблонов файлов в ~/Templaytes (чтобы в контекстном меню отображался пункт New Document) "
touch ~/Templates/{Empty\ Document,Text\ Document.txt,README.md,pyfile.py}
#######################

################
echo ""
echo -e "${BLUE}:: ${NC}Установим дополнения для Pacman - пакет (pacman-contrib)"
echo " Этот репозиторий содержит скрипты, предоставленные pacman "
echo -e "${YELLOW}=> Примечание: ${BOLD}Раньше это было частью pacman.git, но было перемещено, чтобы упростить обслуживание pacman. ${NC}"
echo " Скрипты, доступные в этом репозитории: checkupdates, paccache, pacdiff, paclist, paclog-pkglist, pacscripts, pacsearch, rankmirrors, updpkgsums;... "
pacman -S --noconfirm --needed pacman-contrib  # Предоставленные скрипты и инструменты для систем pacman (https://github.com/kyrias/pacman-contrib)
pacman -S --noconfirm --needed pcurses  # Инструмент управления пакетами curses с использованием libalpm (https://github.com/schuay/pcurses)
#################
echo ""
echo -e "${BLUE}:: ${NC}Установим Hwdetect - пакет (hwdetect) - Информация о железе"
echo " Hwdetect - это скрипт (консольная утилита с огромным количеством опций) обнаружения оборудования, который в основном используется для загрузки или вывода списка модулей ядра (для использования в mkinitcpio.conf), и заканчивая возможностью автоматического изменения rc.conf и mkinitcpio.conf ; (https://wiki.archlinux.org/title/Hwdetect) "
echo -e "${YELLOW}=> Примечание: ${BOLD}Это отличается от многих других инструментов, которые запрашивают только оборудование и показывают необработанную информацию, оставляя пользователю задачу связать эту информацию с необходимыми драйверами. ${NC}"
echo " Сценарий использует информацию, экспортируемую подсистемой sysfs (https://en.wikipedia.org/wiki/Sysfs), используемой ядром Linux. "
pacman -S hwdetect --noconfirm  # Скрипт (консольная утилита) просмотр модулей ядра для устройств, обнаружения оборудования с загрузочными модулями и поддержкой mkinitcpio.conf / rc.conf
#################

##################
echo ""
echo -e "${BLUE}:: ${NC}Блокируем сайты с рекламой через hosts"
echo " Сохраняем копию оригинального файла /etc/hosts "
cp /etc/hosts /etc/hosts.bak
# cp /etc/hosts ~/Documents/hosts.bak
wget -qO- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | sudo tee --append /etc/hosts
########################










