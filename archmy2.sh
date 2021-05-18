
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
echo ""
echo " Второй этап установки Arch'a "
echo -e "${CYAN} ! ${BOLD}Продолжается работа скрипта: - будет проходить установка первоначально необходимого софта (пакетов), запуск необходимых служб, запись данных в конфиги (hhh.conf) по настройке системы. ${NC}"
echo ""
echo -e "${GREEN}=> ${NC}Для проверки интернета можно пропинговать какой-либо сервис" 
ping -c2 archlinux.org  # Утилита ping - это очень простой инструмент для диагностики сети
echo -e "${CYAN}==> ${NC}Если пинг идёт едем дальше ... :)"
###
echo ""
echo -e "${BLUE}:: ${NC}Синхронизация системных часов"  
timedatectl set-ntp true
echo -e "${BLUE}:: ${NC}Посмотрим статус службы NTP (NTP service)"
timedatectl status
echo -e "${BLUE}:: ${NC}Посмотрим текущее состояние аппаратных и программных часов"
timedatectl
#################
echo ""
echo -e "${BLUE}:: ${NC}Обновим вашу систему (базу данных пакетов)"
echo -e "${YELLOW}:: ${NC}Загружаем базу данных пакетов независимо от того, есть ли какие-либо изменения в версиях"
echo ""
pacman -Syyu --noconfirm  # Обновим вашу систему (базу данных пакетов)  
sleep 1
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
echo ""
echo -e "${BLUE}:: ${NC}Установим утилиты Logical Volume Manager 2 пакет (lvm2)"
echo " Если Вы захотите задействовать (попробовать) LVM в действии "
echo " LVM - Менеджер логических томов (англ. Logical Volume Manager). В отличие от разделов жёсткого диска, размеры логических томов можно легко менять. "
pacman -S lvm2 --noconfirm  # Утилиты Logical Volume Manager 2 (https://sourceware.org/lvm2/)
#################
clear
echo ""
echo -e "${GREEN}==> ${NC}Вводим название компьютера (host name), и имя пользователя (user name)"
echo -e "${MAGENTA}=> ${BOLD}Используйте в названии (host name) только буквы латинского алфавита (a-zA-Z0-9) (Можно написать с Заглавной буквы). Латиница - это английские буквы. Кириллица - русские. ${NC}"  
echo ""
echo " Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter") "
read -p " => Введите имя компьютера: " hostname
echo ""
echo -e "${MAGENTA}=> ${BOLD}Используйте в имени (user name) только буквы латинского алфавита (в нижнем (маленькие) регистре (a-z)(a-z0-9_-)), и цифры ${NC}"           
echo ""                    
echo " Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter") "
read -p " => Введите имя пользователя: " username 
###
echo -e "${BLUE}:: ${NC}Прописываем имя компьютера"
echo $hostname > /etc/hostname 
#################
clear
echo ""
echo -e "${GREEN}==> ${NC}Устанавливаем ваш часовой пояс (localtime)."
echo " Всё завязано на времени, поэтому очень важно, чтобы часы шли правильно... :) "
echo -e "${BLUE}:: ${BOLD}Для начала вот ваши данные по дате, времени и часовому поясу: ${NC}"
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'    # одновременно отображает дату и часовой пояс
echo ""
timedatectl list-timezones | grep Moscow 
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
# timedatectl set-timezone Europe/Moscow
echo ""
echo " Создадим резервную копию текущего часового пояса: " 
# cp /etc/localtime /etc/localtime.bak
cp /etc/localtime /etc/localtime.backup
echo " Запишем название часового пояса в /etc/timezone: "
echo Europe/Moscow > /etc/timezone
ls -lh /etc/localtime  # для просмотра символической ссылки, которая указывает на текущий часовой пояс, используемый в системе 
###
echo ""
echo -e "${GREEN}=> ${BOLD}Это ваш часовой пояс (timezone) - '$timezone' ${NC}"
echo -e "${BLUE}:: ${BOLD}Ваши данные по дате, времени и часовому поясу: ${NC}"
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'    # одновременно отображает дату и часовой пояс
###
echo -e "${BLUE}:: ${NC}Синхронизируем аппаратное время с системным"
echo " Устанавливаются аппаратные часы из системных часов. "
hwclock --systohc  # Эта команда предполагает, что аппаратные часы настроены в формате UTC.
# hwclock --adjust  # Порой значение аппаратного времени может сбиваться - выровняем!
# hwclock -w  # переведёт аппаратные часы
###
echo ""
echo -e "${BLUE}:: ${NC}Настроим состояние аппаратных и программных часов."  
echo -e "${YELLOW}=> ${NC}Вы можете пропустить этот шаг, если сейчас ваш часовой пояс настроен правильно, или Вы не уверены в правильности выбора! "
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
###
echo ""
echo -e "${BLUE}:: ${NC}Посмотрим обновление времени (если настройка не была пропущена)"
timedatectl show
# timedatectl | grep Time
######################
echo ""
echo -e "${BLUE}:: ${NC}Изменяем имя хоста"
echo "127.0.0.1 localhost.(none)" > /etc/hosts
echo "127.0.1.1 $hostname" >> /etc/hosts
echo "::1   localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts
###
echo -e "${BLUE}:: ${NC}Добавляем русскую локаль системы"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
###
echo -e "${BLUE}:: ${NC}Обновим текущую локаль системы"
locale-gen  # Мы ввели locale-gen для генерации тех самых локалей
###
sleep 02
echo -e "${BLUE}:: ${NC}Указываем язык системы"
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
#echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
echo 'LC_ADDRESS="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_IDENTIFICATION="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_MEASUREMENT="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_MONETARY="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_NAME="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_NUMERIC="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_PAPER="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_TELEPHONE="ru_RU.UTF-8"' >> /etc/locale.conf
echo 'LC_TIME="ru_RU.UTF-8"' >> /etc/locale.conf
###
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
#echo 'COMPRESSION="lz4"' >> /etc/mkinitcpio.conf 
#echo 'COMPRESSION="xz"' >> /etc/mkinitcpio.conf
echo "vboxdrv" > /etc/modules-load.d/virtualbox.conf
#######################
clear
echo ""
echo -e "${BLUE}:: ${NC}Проверим корректность загрузки установленных микрокодов " 
echo -e "${MAGENTA}=> ${NC}Если таковые (микрокод-ы: amd-ucode; intel-ucode) были установлены! "
echo " Если микрокод был успешно загружен, Вы увидите несколько сообщений об этом "
echo " Будьте внимательны! Вы можете пропустить это действие. "
echo -e "${CYAN}:: ${BOLD}Выполним проверку корректности загрузки установленных микрокодов ${NC}"
dmesg | grep microcode
sleep 02
###
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
########################
clear
echo ""
echo -e "${BLUE}:: ${NC}Редактируем /etc/mkinitcpio.conf - Добавляем хуки (порядок важен)"
echo -e "${MAGENTA}=> ${BOLD}Модули определяются в файле /etc/mkinitcpio.conf, так как мы используем шифрование и LVM - то в HOOKS перед (порядок имеет значение, смотрите примеры в самом файле) перед modconf добавляем keyboard и keymap, а перед filesystem добавляем encrypt и lvm2 ${NC}"
echo -e "${YELLOW}=> Важно! ${BOLD}Не забудьте проверить наличие хука udev или btrfs, если используете btrfs! ${NC}"
echo -e "${GREEN}=> ${BOLD}Для LEGACY:${NC}"
   #    usr, fsck and shutdown hooks
echo -e "${CYAN} Пример: ${NC}HOOKS=\"base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck\"\n"
echo -e "${GREEN}=> ${BOLD}Для UEFI-systemd:${NC}"
    #    usr, fsck and shutdown hooks.
echo -e "${CYAN} Пример: ${NC}HOOKS=\"base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems fsck\"\n"
#echo ""
echo " Будьте внимательны! Без внесения этих поправок в файл /etc/mkinitcpio.conf Вы НЕ сможете запустить систему, которую устанавливаете. "
echo ""
read -n 1 -s -r -p " Файл /etc/mkinitcpio.conf откроется в nano! \n Нажмите любую клавишу для открытия: "
echo ""
echo "sed -i \"s/autodetect modconf/autodetect keyboard keymap modconf/g\" /etc/mkinitcpio.conf"
sed -i "s/autodetect modconf/autodetect keyboard keymap modconf/g" /etc/mkinitcpio.conf
echo "sed -i \"s/block filesystems/block encrypt lvm2 filesystems/g\" /etc/mkinitcpio.conf"
sed -i "s/block filesystems/block encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
echo "sed -i \"s/filesystems keyboard fsck/filesystems fsck/g\" /etc/mkinitcpio.conf"
sed -i "s/block filesystems/block encrypt filesystems/g" /etc/mkinitcpio.conf
echo "sed -i \"s/#COMPRESSION="lz4"/COMPRESSION="lz4"/g\" /etc/mkinitcpio.conf"
sed -i "s/#COMPRESSION="lz4"/COMPRESSION="lz4"/g" /etc/mkinitcpio.conf
sleep 1   
nano /etc/mkinitcpio.conf
# nano -m /etc/mkinitcpio.conf  # -m - включить поддержку мыши
## добавить keyboard keymap encrypt lvm2
# HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck)
########################
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
#######################
clear
echo ""
echo -e "${GREEN}==> ${NC}Создаём root пароль (Root Password)"
echo " Пароль должен содержать от 6 до 15 символов, включающих цифры (1-0) и знаки (!'':[@]),     
        и латинские буквы разного регистра! "
echo -e "${MAGENTA}=> ${BOLD}По умолчанию, на большинстве систем Linux в консоле не показывается введенный пароль. 
Это сделано из соображений безопасности, чтобы никто не мог увидеть длину вашего пароля.${NC}"                 
echo " => Введите Root Password (Пароль суперпользователя), вводим пароль 2 раза "
echo " Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter") "
passwd
#######################
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
pacman -S grub-customizer --noconfirm
#pacman -S grub --noconfirm  # Файлы и утилиты для установки GRUB2 содержатся в пакете grub
uname -rm  # для определения архитектуры процессора, имени хоста системы и версии ядра, работающего в системе
lsblk -f # Команда lsblk выводит список всех блочных устройств
### Если ли надо раскомментируйте нужные вам значения ####
### GRUB(legacy) ###
echo ""
echo " Укажем диск куда установить GRUB (sda/sdb например sda или sdb) "
echo -e "${YELLOW}=> Примечание: ${BOLD}/dev/sdX - диск (а не раздел ), на котором должен быть установлен GRUB. ${NC}"
grub-install /dev/sda
#echo ""
### Если вы используете LVM для вашего /boot, вы можете установить GRUB на нескольких физических дисках.
#echo " Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter") "
#read -p " => Укажите диск куда установить GRUB (sda/sdb например sda или sdb) : " x_cfd  # To confirm the input actions, click 'Enter' ; # Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter")
#grub-install /dev/$x_cfd  # Записываем загрузчик в MBR (Master Boot Record) нашего внутреннего накопителя (sda; sdb; sdc; sdd)
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
###
echo ""
echo -e "${GREEN}==> ${NC}Если на компьютере будут несколько ОС (dual_boot), то это также ставим."
echo -e "${CYAN}:: ${NC}Это утилиты для обнаружения других ОС на наборе дисков, для доступа к дискам MS-DOS, а также библиотека, позволяющая реализовать файловую систему в программе пользовательского пространства."
echo -e "${YELLOW}=> ${NC}Для двойной загрузки Arch Linux с другой системой Linux, Windows, установить другой Linux без загрузчика, вам необходимо установить утилиту os-prober, необходимую для обнаружения других операционных систем."
echo " И обновить загрузчик Arch Linux, чтобы иметь возможность загружать новую ОС."
echo ""    
echo " Устанавливаем программы (пакеты) для определения другой-(их) OS "    
pacman -S os-prober mtools fuse --noconfirm  #grub-customizer  # Утилита для обнаружения других ОС на наборе дисков; Сборник утилит для доступа к дискам MS-DOS; 
echo " Программы (пакеты) установлены "
########################
clear
echo ""
echo -e "${BLUE}:: ${NC}Редактируем /etc/default/grub - Добавляем UUID нашего зашифрованного раздела root"
echo -e "${MAGENTA}=> ${BOLD}Сначала взглянем на UUID идентификатор(ы) нашего устройства, Запомним, Запишем или Сфоткаем его, и потом внесём (порядок в хаос) несколько правок /etc/default/grub ${NC}"
echo -e "${GREEN}=> ${BOLD}Добавляем в /etc/default/grub:${NC}"
## Прописываем команду для старта и включаем
echo -e "${CYAN} Пример: ${NC}GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=c0868972-f314-48e1-9be5-3584826dbd64:cryptlvm root=/dev/lvarch/root\"\n"
echo -e "${CYAN} Ещё одна строка: ${NC}GRUB_ENABLE_CRYPTODISK=y\"\n"
echo " Эта строка присутствует в /etc/default/grub, её просто раскомментируйте! "
echo ""
echo " Будьте внимательны! Без внесения этих поправок в файл /etc/default/grub Вы НЕ сможете запустить систему, которую устанавливаете. "
echo ""
echo -e "${BLUE}:: ${NC}Взглянем на UUID идентификатор(ы) нашего устройства:"
echo -e "${CYAN} ! ${BOLD}Вывод UUID идентификатора будет выведен и сохраняться с задержкой в 50 секунд, и надеюсь Вы успеете (запомнить, записать или сфоткать) его. ${NC}"
read -n 1 -s -r -p " Файл /etc/default/grub откроется в nano! \n Нажмите любую клавишу для продолжения: "
echo ""
# blkid
blkid /dev/sda2
# blkid /dev/sd*  # Для просмотра UUID (или Universal Unique Identifier) - это универсальный уникальный идентификатор определенного устройства компьютера
sleep 50  # приостановка работы потока  
nano /etc/default/grub
# nano -m /etc/default/grub  # -m - включить поддержку мыши
#########################
echo ""
echo -e "${BLUE}:: ${NC}Обновляем grub.cfg (Сгенерируем grub.cfg)"
echo " Настраиваем и конфигурируем grub "
grub-mkconfig -o /boot/grub/grub.cfg  # создаём конфигурационный файл
###
echo ""
echo -e "${GREEN}==> ${NC}Установить программы (пакеты) для Wi-fi?"
echo -e "${CYAN}:: ${NC}Если у Вас есть Wi-fi модуль и Вы сейчас его не используете, но будете использовать в будущем."
echo " Или Вы подключены через Wi-fi, то эти (пакеты) обязательно установите. "
echo ""    
echo " Устанавливаем программы (пакеты) для Wi-fi "   
pacman -S dialog wpa_supplicant iw wireless_tools net-tools --noconfirm  # Инструмент для отображения диалоговых окон из сценариев оболочки; Утилита, обеспечивающая согласование ключей для беспроводных сетей WPA; Утилита настройки интерфейса командной строки на основе nl80211 для беспроводных устройств; Инструменты, позволяющие управлять беспроводными расширениями; Инструменты настройки для сети Linux.
echo " Программы (пакеты) для Wi-fi установлены "
sleep 01
#####################
clear
echo ""
echo -e "${GREEN}==> ${NC}Добавляем пользователя и прописываем права, (присвоение) групп. "
echo " Давайте рассмотрим варианты (действия), которые будут выполняться. "
echo " (adm + audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel), то вариант - "2" "
echo -e "${CYAN}:: ${BOLD}Далее, пользователь из установленной системы добавляет себя любимого(ую), в нужную группу /etc/group.${NC}"
echo -e "${YELLOW}=> Вы НЕ можете пропустить этот шаг (пункт)! ${NC}"
# useradd -m -g users -G adm,audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash alex
useradd -m -g users -G adm,audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash $username
# useradd -m -g users -G audio,games,lp,disk,network,optical,power,scanner,storage,video,rfkill,sys,wheel -s /bin/bash $username
# useradd -m -g users -G wheel -s /bin/bash $username
echo ""
echo " Пользователь успешно добавлен в группы и права пользователя "
###
echo ""
echo -e "${GREEN}==> ${NC}Устанавливаем пароль пользователя (User Password)"
echo " Пароль должен содержать от 6 до 15 символов, включающих цифры (1-0) и знаки (!'':[@]),    
        и латинские буквы разного регистра! "
echo -e "${MAGENTA}=> ${BOLD}По умолчанию, на большинстве систем Linux в консоле не показывается введенный пароль. 
Это сделано из соображений безопасности, чтобы никто не мог увидеть длину вашего пароля.${NC}"
echo " => Введите User Password (Пароль пользователя) - для $username, вводим пароль 2 раза "
echo " Чтобы подтвердить действия ввода, нажмите кнопку 'Ввод' ("Enter") "
passwd $username
###
echo ""
echo -e "${BLUE}:: ${NC}Проверим статус пароля для всех учетных записей пользователей в вашей системе"
echo -e "${CYAN}:: ${NC}В выведенном списке те записи, которые сопровождены значением (лат.буквой) P - значит на этой учетной записи установлен пароль!"
echo -e "${CYAN} Пример: ${NC}(root P 10/11/2020 -1 -1 -1 -1; или $username P 10/11/2020 0 99999 7 -1)"
passwd -Sa  # -S, --status вывести статус пароля
###
echo ""
echo -e "${GREEN}==> ${NC}Информация о пользователе (полное имя пользователя и связанная с ним информация)"
echo -e "${CYAN}:: ${NC}Пользователь в Linux может хранить большое количество связанной с ним информации, в том числе номера домашних и офисных телефонов, номер кабинета и многое другое."
echo " Мы обычно пропускаем заполнение этой информации (так как всё это необязательно) - при создании пользователя. "
echo -e "${CYAN}:: ${NC}На первом этапе достаточно имени пользователя, и подтверждаем - нажмите кнопку 'Ввод'(Enter)." 
echo " Ввод другой информации (Кабинет, Телефон в кабинете, Домашний телефон) можно пропустить - просто нажмите 'Ввод'(Enter). " 
echo ""  
echo " Информация о my username : (достаточно имени) "
chfn $username
###
echo ""
echo -e "${BLUE}:: ${NC}Устанавливаем (пакет) SUDO."
echo -e "${CYAN}=> ${NC}Пакет sudo позволяет системному администратору предоставить определенным пользователям (или группам пользователей) возможность запускать некоторые (или все) команды в роли пользователя root или в роли другого пользователя, указываемого в командах или в аргументах."
pacman -S --noconfirm --needed sudo
#pacman -S sudo --noconfirm  # Предоставить определенным пользователям возможность запускать некоторые команды от имени пользователя root  - пока присутствует в pkglist.x86_64
###
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
###
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
###
echo ""
echo -e "${BLUE}:: ${NC}Обновим базы данных пакетов"  
pacman -Sy   #--noconfirm --noprogressbar --quiet (обновить списки пакетов из репозиториев)
#pacman -Syy --noconfirm --noprogressbar --quiet (обновление баз пакмэна - pacman)
#####################
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
echo " 1 - Если Вы устанавливаете Arch Linux на PC, то выбирайте вариант - "1" "
echo " 2 - Если Вы устанавливаете Arch Linux на Виртуальную машину (VBox;VMWare), то ваш вариант - "2" "
echo " 3(0) - Вы можете пропустить установку Xorg (иксов), если используете VDS (Virtual Dedicated Server), или VPS (Virtual Private Server), тогда выбирайте вариант - "0" "
echo " VPS (Virtual Private Server) обозначает виртуализацию на уровне операционной системы, VDS (Virtual Dedicated Server) - аппаратную виртуализацию. Оба термина появились и развивались параллельно, и обозначают одно и то же: виртуальный выделенный сервер, запущенный на базе физического. "
echo " Будьте внимательны! Процесс установки Xorg (иксов) не был прописан полностью автоматическим, и было принято решение дать возможность пользователю сделать выбор. В любой ситуации выбор всегда остаётся за вами. "
echo -e "${YELLOW}==> ${NC}Действия выполняются в указанном порядке" 
echo ""
while
echo " Действия ввода, выполняется сразу после нажатия клавиши "
    read -n1 -p " 
    1 - Устанавливаем на PC или (ноутбук),    2 - Устанавливаем на VirtualBox(VMWare), 

    0 - Пропустить (используется VDS, или VPS): " vm_setting  # sends right after the keypress; # отправляет сразу после нажатия клавиши
    echo ''
    [[ "$vm_setting" =~ [^120] ]]
do
    :
done
if [[ $vm_setting == 0 ]]; then
# echo ""
  echo " Установка Xorg (иксов) пропущена (используется VDS, или VPS) "  
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit"  #(или на vmware) # --confirm   всегда спрашивать подтверждение
# gui_install="xorg-server xorg-drivers --noconfirm"     # xorg-xinit 
elif [[ $vm_setting == 2 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"  #(или на vmware) # --confirm   всегда 
# gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils --noconfirm" 
fi
###
echo ""
echo -e "${BLUE}:: ${NC}Ставим иксы и драйвера"
echo " Выберите свой вариант (от 1-...), или по умолчанию нажмите кнопку 'Ввод' ("Enter") "
echo " Далее после своего сделанного выбора, нажмите "Y или n" для подтверждения установки. "
pacman -S $gui_install   # --confirm   всегда спрашивать подтверждение
echo ""
pacman -Syy --noconfirm --noprogressbar --quiet
sleep 01
###
### Дополнительно : ###
# pacman -S mesa xorg-apps xorg-twm xterm xorg-xclock xf86-input-synaptics --noconfirm  
####################
#echo ""
#echo -e "${BLUE}:: ${NC}Установка гостевых дополнений vbox"
#modprobe -a vboxguest vboxsf vboxvideo
#cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
#echo -e "\nvboxguest\nvboxsf\nvboxvideo" >> /home/$username/.xinitrc
#sed -i 's/#!\/bin\/sh/#!\/bin\/sh\n\/usr\/bin\/VBoxClient-all/' /home/$username/.xinitrc
####################
clear
echo ""
echo -e "${GREEN}==> ${NC}Ставим DE (графическое окружение) среда рабочего стола."
echo " DE (от англ. desktop environment - среда рабочего стола), это обёртка для ядра Linux, предоставляющая основные функции дистрибутива в удобном для конечного пользователя наглядном виде (окна, кнопочки, стрелочки и пр.). "
### Xfce воплощает традиционную философию UNIX ###
echo ""    
echo " Установка Xfce + Goodies for Xfce "     
pacman -S xfce4 xfce4-goodies --noconfirm  # Нетребовательное к ресурсам окружение рабочего стола; Проект Xfce Goodies Project включает дополнительное программное обеспечение и изображения, которые связаны с рабочим столом Xfce , но не являются частью официального выпуска.
echo ""
echo " DE (среда рабочего стола) Xfce успешно установлено "
###
clear
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
####################
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
#####################
clear
echo ""
echo -e "${GREEN}==> ${NC}Установить сетевые утилиты Networkmanager?"
echo -e "${BLUE}:: ${NC}'Networkmanager' - сервис для работы интернета."
echo " NetworkManager можно установить с пакетом networkmanager, который содержит демон, интерфейс командной строки (nmcli) и интерфейс на основе curses (nmtui). Вместе с собой устанавливает программы (пакеты) для настройки сети. "
echo -e "${CYAN}=> ${NC}После запуска демона NetworkManager он автоматически подключается к любым доступным системным соединениям, которые уже были настроены. Любые пользовательские подключения или ненастроенные подключения потребуют nmcli или апплета для настройки и подключения."
echo -e "${CYAN}=> ${NC}Поддержка OpenVPN в Network Manager также внесена в список устанавливаемых программ (пакетов)."
echo ""
echo " Ставим сетевые утилиты Networkmanager "        
pacman -S networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm  # Диспетчер сетевых подключений и пользовательские приложения; Плагин NetworkManager VPN для OpenVPN; Апплет для управления сетевыми подключениями; Демон, реализующий протокол точка-точка для коммутируемого доступа в сеть.
# pacman -Sy networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm
echo ""
echo -e "${BLUE}:: ${NC}Ставим дополнительные сетевые утилиты"
pacman -S pptpclient --noconfirm  # Клиент для проприетарного протокола туннелирования точка-точка от Microsoft, PPTP
pacman -S rp-pppoe --noconfirm  # Протокол точка-точка Roaring Penguin через клиент Ethernet
pacman -S xl2tpd --noconfirm  # Реализация L2TP с открытым исходным кодом, поддерживаемая Xelerance Corporation
pacman -S networkmanager-l2tp --noconfirm  # Поддержка L2TP для NetworkManager
echo ""
echo -e "${BLUE}:: ${NC}Подключаем Networkmanager в автозагрузку" 
# systemctl enable NetworkManager  # systemctl - специальный инструмент для управления службами в Linux
systemctl enable NetworkManager.service 
echo " NetworkManager успешно добавлен в автозагрузку "
sleep 02
###
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
######################
echo ""
echo -e "${BLUE}:: ${NC}Ставим шрифты"  # https://www.archlinux.org/packages/
pacman -S ttf-dejavu --noconfirm  # Семейство шрифтов на основе Bitstream Vera Fonts с более широким набором символов
pacman -S ttf-liberation --noconfirm  # Шрифты Red Hats Liberation
pacman -S ttf-anonymous-pro --noconfirm  # Семейство из четырех шрифтов фиксированной ширины, разработанных специально с учетом кодирования
pacman -S terminus-font --noconfirm  # Моноширинный растровый шрифт (для X11 и консоли)
###
echo ""
echo -e "${BLUE}:: ${NC}Монтирование разделов NTFS и создание ссылок" 
pacman -S ntfs-3g --noconfirm  # Драйвер и утилиты файловой системы NTFS; "NTFS file support (Windows Drives)"
###
echo ""
echo -e "${BLUE}:: ${NC}Установка базовых программ и пакетов"
echo -e " Установка базовых программ (пакетов): wget, curl, git, cmake "
pacman -S wget git --noconfirm  #curl  - пока присутствует в pkglist.x86_64  # Сетевая утилита для извлечения файлов из Интернета; Быстрая распределенная система контроля версий.
pacman -S cmake --noconfirm  # Кросс-платформенная система сборки с открытым исходным кодом
####################
clear
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
#####################
clear
echo ""
echo -e "${GREEN}==> ${NC}Установка ZSH (bourne shell) командной оболочки"
echo -e "${CYAN}:: ${NC}Z shell, zsh - является мощной, одной из современных командных оболочек, которая работает как в интерактивном режиме, так и в качестве интерпретатора языка сценариев (скриптовый интерпретатор)."
echo " Он совместим с bash (не по умолчанию, только в режиме emulate sh), но имеет преимущества, такие как улучшенное завершение и подстановка. "
echo " Будьте внимательны! Процесс установки, был прописан полностью автоматическим. В данной опции выбор всегда остаётся за вами. "
echo -e "${MAGENTA}=> ${BOLD}Вот какая оболочка (shell) используется в данный момент: ${NC}"
echo ""
echo $SHELL
echo ""  
echo " Установка ZSH (shell) оболочки "
pacman -S zsh zsh-syntax-highlighting zsh-autosuggestions grml-zsh-config --noconfirm
pacman -S zsh-completions zsh-history-substring-search  --noconfirm  
echo 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> /etc/zsh/zshrc
echo 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> /etc/zsh/zshrc
#echo 'prompt adam2' >> /etc/zsh/zshrc
echo 'prompt fire' >> /etc/zsh/zshrc
###
echo ""
echo -e "${BLUE}:: ${NC}Сменим командную оболочку пользователя с Bash на ZSH ?"
echo -e "${YELLOW}=> Примечание: ${BOLD}Если вы пока не хотите использовать ZSH (shell) оболочку, то команды выполнения нужно закомментировать!${NC}"
echo -e "${YELLOW}=> Важно! ${BOLD}Если Вы сменили пользовательскую оболочку, то при первом запуске консоли (терминала) - нажмите 0 (ноль), и пользовательская оболочка (сразу будет) ИЗМЕНЕНА, с BASH на ZSH. ${NC}"
echo " Будьте внимательны! В данной опции выбор всегда остаётся за вами. "
echo "" 
chsh -s /bin/zsh
chsh -s /bin/zsh $username
echo ""
echo " Важно! При первом запуске консоли (терминала) - нажмите "0" "
echo " Пользовательская оболочка ИЗМЕНЕНА (сразу будет), с BASH на на ZSH "
####################
clear
echo -e "${MAGENTA}
  <<< Установка AUR (Arch User Repository) >>> ${NC}"   
echo -e "${YELLOW}==> Внимание! ${NC}Во время установки "AUR", Вас попросят ввести (Пароль пользователя) для $username."
echo ""
echo -e "${GREEN}==> ${NC}Установка AUR Helper (yay) или (pikaur)"
echo -e "${MAGENTA}:: ${NC} AUR - Пользовательский репозиторий, поддерживаемое сообществом хранилище ПО, в который пользователи загружают скрипты для установки программного обеспечения."
echo " В AUR - есть практически всё, что можно установить на Linux. В том числе и программы, которые для других дистробутивов пришлось бы собирать из исходников. "
echo -e "${CYAN}=> ${BOLD}В сценарии скрипта присутствуют следующий вариант: ${NC}"
echo " 'AUR'-'yay-bin' (версия в разработке) - Еще один йогурт. Обертка Pacman и помощник AUR, написанные на языке go.  Предварительно скомпилирован. "
echo -e "${CYAN}:: ${NC}Установка 'AUR'-'yay-bin' проходит через сборку из исходников AUR. То есть установка производиться с помощью git clone (https://aur.archlinux.org/yay-bin.git), PKGBUILD, makepkg - скачивается с сайта 'Arch Linux' (https://aur.archlinux.org/packages/yay-bin/), собирается и устанавливается."
echo " Будьте внимательны! В этом действии выбор остаётся за вами. "
echo ""
echo " Обновим вашу систему (базу данных пакетов) "
pacman -Syu  # Обновим вашу систему (базу данных пакетов)    
echo ""
echo " Установка AUR Helper - (yay-bin) "
cd /home/$username
git clone https://aur.archlinux.org/yay-bin.git
chown -R $username:users /home/$username/yay-bin   #-R, --recursive - рекурсивная обработка всех подкаталогов;
chown -R $username:users /home/$username/yay-bin/PKGBUILD  #-R, --recursive - рекурсивная обработка всех подкаталогов;
cd /home/$username/yay-bin  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/yay-bin
echo ""
echo " Установка AUR Helper (yay-bin) завершена "
#####################
clear
echo ""
echo -e "${BLUE}:: ${NC}Обновим всю систему включая AUR пакеты" 
echo ""    
echo " Обновление баз данных пакетов, и системы через - AUR (Yay) "
yay -Syy
yay -Syu
sleep 01
#####################
clear
echo ""
echo -e "${GREEN}==> ${NC}Установить  менеджер пакетов для Archlinux?"
echo -e "${BLUE}:: ${NC}Установка Pacman gui (pamac-aur) (AUR)(GTK)" 
echo " Давайте проанализируем действия, которые выполняются "
echo " Pacman gui (pamac-aur) - Графический менеджер пакетов (интерфейс Gtk3 для libalpm) "
echo " Графический менеджер пакетов для Arch, Manjaro Linux с поддержкой Alpm, AUR, и Snap. "
echo -e "${CYAN}:: ${NC}Установка Pacman gui (pamac-aur) проходит через сборку из исходников AUR. То есть установка производиться с помощью git clone (https://aur.archlinux.org/pamac-aur.git), PKGBUILD, makepkg - скачивается с сайта 'Arch Linux' (https://aur.archlinux.org/packages/pamac-aur/), собирается и устанавливается."
echo " Будьте внимательны! В этом действии выбор остаётся за вами. "
echo ""  
echo " Установка Графического менеджера Pacman gui (pamac-aur) " 
cd /home/$username
git clone https://aur.archlinux.org/pamac-aur.git
chown -R $username:users /home/$username/pamac-aur
chown -R $username:users /home/$username/pamac-aur/PKGBUILD 
cd /home/$username/pamac-aur
sudo -u $username  makepkg -si --noconfirm  
# makepkg --noconfirm --needed -sic 
rm -Rf /home/$username/pamac-aur
echo ""
echo " Графический менеджер Pamac-aur успешно установлен! "
#####################
clear
echo ""
echo -e "${GREEN}==> ${NC}Установка дополнительных шрифтов из AUR (через - yay)"
echo -e "${MAGENTA}=> ${NC}Список утилит (пакетов) для установки: - (ttf-ms-fonts, ttf-tahoma)." 
echo -e "${CYAN}:: ${NC}Вы МОЖЕТЕ в скрипте закомментировать НЕнужные вам пакеты шрифтов!"
echo " Будьте внимательны! Процесс установки, был прописан полностью автоматическим. " 
# https://wiki.archlinux.org/title/Microsoft_fonts_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)
# https://aur.archlinux.org/packages/ttf-ms-fonts/
echo ""
echo " Обновим вашу систему (базу данных пакетов) "
pacman -Syu  # Обновим вашу систему (базу данных пакетов)    
echo ""
echo " Установка Microsoft fonts - (ttf-ms-fonts) "
cd /home/$username
git clone https://aur.archlinux.org/ttf-ms-fonts.git
chown -R $username:users /home/$username/ttf-ms-fonts   #-R, --recursive - рекурсивная обработка всех подкаталогов;
chown -R $username:users /home/$username/ttf-ms-fonts/PKGBUILD  #-R, --recursive - рекурсивная обработка всех подкаталогов;
cd /home/$username/ttf-ms-fonts  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/ttf-ms-fonts
echo ""
echo " Установка Microsoft fonts (ttf-ms-fonts) завершена "
echo ""
echo " Обновим информацию о шрифтах "  # Update information about fonts
fc-cache -f -v
# https://aur.archlinux.org/packages/ttf-tahoma/
#echo ""
#echo " Обновим вашу систему (базу данных пакетов) "
#pacman -Syu  # Обновим вашу систему (базу данных пакетов)    
echo ""
echo " Установка Шрифтов Tahoma и Tahoma Bold из проекта Wine - (ttf-tahoma) "
cd /home/$username
git clone https://aur.archlinux.org/ttf-tahoma.git
chown -R $username:users /home/$username/ttf-tahoma   #-R, --recursive - рекурсивная обработка всех подкаталогов;
chown -R $username:users /home/$username/ttf-tahoma/PKGBUILD  #-R, --recursive - рекурсивная обработка всех подкаталогов;
cd /home/$username/ttf-tahoma  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/ttf-tahoma
echo ""
echo " Установка Шрифтов Tahoma и Tahoma Bold (ttf-tahoma) завершена "
echo ""
echo " Обновим информацию о шрифтах "  # Update information about fonts
fc-cache -f -v
#######################
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
###
echo -e "${BLUE}:: ${NC}Перемещаем и переименовываем исходный файл /etc/sysctl.conf в /etc/sysctl.d/99-sysctl.conf"
cp /etc/sysctl.conf  /etc/sysctl.conf.back  # Для начала сделаем его бэкап
mv /etc/sysctl.conf /etc/sysctl.d/99-sysctl.conf   # Перемещаем и переименовываем исходный файл
###
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
###
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
######################
clear
echo ""
echo -e "${BLUE}:: ${BOLD}Очистка кэша pacman 'pacman -Sc' ${NC}"
echo -e "${CYAN}=> ${NC}Очистка кэша неустановленных пакетов (оставив последние версии оных), и репозиториев..."
pacman --noconfirm -Sc  # Очистка кэша неустановленных пакетов (оставив последние версии оных) 
###
echo "" 
echo -e "${CYAN}=> ${NC}Удалить кэш ВСЕХ установленных пакетов 'pacman -Scc' (высвобождая место на диске)?"
echo " Процесс удаления кэша ВСЕХ установленных пакетов - БЫЛ прописан полностью автоматическим! "
echo -e "${YELLOW}==> ${NC} Будьте внимательны! Если Вы сомневаетесь в своих действиях, ещё раз обдумайте..."
echo ""
echo " Удаление кэша ВСЕХ установленных пакетов пропущено "           
pacman --noconfirm -Scc  # Удалит кеш всех пакетов (можно раз в неделю вручную запускать команду)
#####################
clear             
echo -e "${GREEN}
  <<< Поздравляем! Установка завершена. Перезагрузите систему. >>> 
${NC}"
echo -e "${BLUE}:: ${BOLD}Посмотрим дату и время ... ${NC}"
date
date +'%d/%m/%Y  %H:%M:%S [%:z  %Z]'    # одновременно отображает дату и часовой пояс
echo -e "${BLUE}:: ${BOLD}Отобразить время работы системы ... ${NC}"
uptime
echo -e "${MAGENTA}==> ${BOLD}После перезагрузки и входа в систему проверьте ваши персональные настройки. ${NC}"
echo -e "${MAGENTA}==> ${BOLD}Если у Вас беспроводное соединение, запустите nmtui (Network Manager Text User Interface) и подключитесь к сети. ${NC}"
echo -e "${YELLOW}==> ...${NC}"
echo -e "${BLUE}:: ${NC}Если хотите подключить AUR, установить дополнительный софт (пакеты), установить мои конфиги для DE/XFCE, тогда после перезагрузки и входа в систему выполните команду:"
echo -e "${YELLOW}==> ${CYAN}wget git.io/archmy3 && sh archmy3 ${NC}"
echo -e "${CYAN}:: ${NC}Цель скрипта (archmy3l) - это установка первоначально необходимого софта (пакетов) и запуск необходимых служб."
echo -e "${CYAN}:: ${NC}Скриптом можно пользоваться как шпаргалкой, открыв его в текстовом редакторе, копируя команды по установке необходимых пакетов, и запуска служб."
echo -e "${GREEN}
  <<< Желаю Вам удачи во всех начинаниях, верных и точных решений! >>> ${NC}"
echo ""
echo -e "${RED}### ${BLUE}########################################################### ${RED}### ${NC}" 
echo -e "${RED}==> ${BOLD}Выходим из установленной системы ${NC}"
echo -e "${BLUE}:: ${BOLD}Теперь вам надо ввести (exit) reboot, чтобы перезагрузиться ${NC}"
exit
exit

  
### end of script
