# Простая операционная система

Не имеет файловой системы

Исходный код написан на Flat Assembler.
- BOOT.ASM - загрузчик системы. Расположен в первом секторе памяти и загружается в ОЗУ при помощи POST BIOS. Предназначается для загрузки ядра системы
- KERNEL.ASM - ядро операционной системы. На данный момент работает с выводом (INT 10h) и вводом (INT 16h)
- SYSTEM.ASM - файл, собираемый в образ дискеты

Результирующий бинарный файл может быть запущен с Floppy в Virtual Box, а также записан на USB-носитель и запущенны при помощи BIOS USB BOOT

## Установка в Virtual Box, Hyper-V, etc.

- Создайте Floppy drive из образа
- Выберите созданный диск в качестве загружаемого

## Запуск на ПК

Требуемая процессорная архитектура: x64/86

- Используя программу для записи образов (я пользуюсь **Rufus**) создайте загрузочный USB-диск
- В настройках BIOS/UEFI выберите USB boot
- Перезагрузите устройство 
