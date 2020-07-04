##############################################
# ArchLinux Fast Install v1.6 LegasyBIOS
##############################################

# Описание
Этот скрипт не задумывался, как обычный установочный с большим выбором DE, разметкой диска и т.д. И он не предназначет для новичков. Он предназначет для тех, кто ставил ArchLinux руками и понимает, что и для чего нужна каждая команда. 

Его цель - это моментальное разворачиванеи системы со всеми конфигами. Смысл в том что, все изменения вы делаете предварительно в самом скрипте и получаете возможность быстрой установки ArchLinux с вашими личными настройками (при условии, что вы его изменили под себя, в противном случае с моими настройками).

Cкрипт основан на моем чек листе ручной установке ArchLinux https://vk.cc/7JTg6U
Разметка MBR c BIOS. C UEFI скрипт по ссылке https://github.com/ordanax/arch

Cостоит из 4 частей. 

Видео с демонстрацией работы скрипта https://www.youtube.com/watch?v=nvVF_qKDUeM

# Установка (Будьте внимательны)
1) Скачать и записать на флешку ISO образ Arch Linux https://www.archlinux.org/download/
2) Команды для скачивания и запуска скрипта изменились, в связи с тем, что в установочный .iso образ Arch Linux 2020.07.01-x86_64.iso ., не входит пакет 'wget', в отличае от 
предыдущего релиза Arch Linux 2020.06.01-x86_64.iso .
  
# Примечание ! 
Если Вы скачали Arch Linux 2020.06.01-x86_64.iso ., 
Для проверки интернета можно пропинговать какой-либо сервис: ping -c2 github.com .,
Скачать и запустить скрипт можно командой:

   ```bash 
   wget git.io/archmy1 && sh archmy1
   Или эта команда:
   wget git.io/archmy1
   И запустить скрипт: 
   sh archmy1   
   ```
# Примечание ! 
Если Вы скачали Arch Linux 2020.07.01-x86_64.iso ., то команда для запуска
скрипта изменится, так как в отличии от Arch Linux 2020.06.01-x86_64.iso .,
в установочный .iso образ не входит пакет 'wget'.
Для проверки интернета можно пропинговать какой-либо сервис: ping -c2 github.com .,
Команда для запуска скрипта:

   ```bash 
   curl -L git.io/archmy1> archmy1 
   И запустить скрипт: 
   sh archmy1
   Или эта команда:
   curl -L git.io/archmy1> archmy1 && sh archmy1
   ```
   Запустится установка минимальной системы.
   2-я часть ставится автоматически и это базовая установка ArchLinux без программ. 
3) 3-я часть не обязательная. Она устанавливает программы, AUR (yay), мои конфиги XFCE.
   Предварительно установите wget командой:
   ```bash 
   sudo pacman -S wget
   ```
   Установка 3-й части производится из терминала командой:
   
   ```bash 
   wget git.io/archmy3 && sh archmy3
   ```

# Настройка скрипта под себя
Вы можете форкнуть этот срипт. Изменить разметку дисков под свои нужды, сделать копию собственного конфга XFCE, залить его на Github и производить быстрое разворачивание вашей системы.
По завершению работы скрипта вы получаете вашу готовую и настроенную систему со всеми конфигами. Вам ее нужно лишь немного привести в порядок и все.
Как и что менять написано в комментариях в самом скрипте.

# ============================================================================

# ВНИМАНИЕ!

Автор не несет ответственности за любое нанесение вреда при использовании скрипта. Используйте его на свой страх и риск или изменяйте под свои личные нужды.

Скрипт затирает диск dev/sda (First hard disk) в системе. Примечание для начинющих: 'Пожалуйста, не путайте с приоритетом загрузки устройств, и их последовательного отображения в Bios'. (Пожалуйста, не путайте! - это вчера мне было п#здато, а сегодня мне п#здец!). Поэтому если у Вас есть ценные данные на дисках сохраните их. 

Если Вам нужна установка рядом с Windows, тогда Вам нужно предварительно изменить скрипт и разметить диски. В противном случае данные и Windows будут затерты.

Если Вам не подходит автоматическая разметка дисков, тогда предварительно нужно сделать разметку дисков и настроить скрипт под свои нужды (программы, XFCE config и т.д.)
Смотрите пометки в самом скрипте!

# ============================================================================

# В разработке принимали участие:
Алексей Бойко https://vk.com/ordanax

Степан Скрябин https://vk.com/zurg3

Михаил Сарвилин https://vk.com/michael170707

Данил Антошкин https://vk.com/danil.antoshkin

Юрий Порунцов https://vk.com/poruncov

# Контакты
Наша группа по Arch Linux https://vk.com/arch4u


# История изменений

### 15.05.2020 ArchLinux Fast Install v1.6 LegasyBIOS
- Скрипт изменен (читать справку README_SOFT)

### 22.09.2019 ArchLinux Fast Install v1.6
- Удален SDDM

### 8.04.2019 ArchLinux Fast Install v1.5
- Добавлен выбор DE OpenBox

### 28.03.2019 ArchLinux Fast Install v1.4
- Добавлена устатановка conky

### 27.03.2019 ArchLinux Fast Install v1.3
- Добавлен выбор DE - Xfce и KDE
- Добавлен выбор DM - SDDM и LXDM
- Добавлен выбор загрузки системы без паузы в Grub

### 23.03.2019 ArchLinux Fast Install v1.2
- Добавлен выбор установки рекомендуемых программ

### 21.03.2019 ArchLinux Fast Install v1.1
- Исправлен баг с установкой тем
- Заменена тема курсора
- Скорректирован конфигурационный файл XFCE

### 18.03.2019 ArchLinux Fast Install v1.0
- Теперь можно вводить собственное имя хоста и юзера
- Исправлен 3-й файл с установкой тем
- aurman заменен на yay







