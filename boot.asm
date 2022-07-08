Use16
org     0x7C00

;-----------------------------------------------;
;                BOOTLOADER CODE                ;
;-----------------------------------------------;
; bootloader для BIOS
; загружает код kernel
; kernel - [0000:0500h]

macro   print           text                            ; Последовательный вывод (INT 10h)
{
LOCAL   print
LOCAL   endm
        mov             si, text
        call            print
        jmp             endm
print:
        lodsb
        test            al, al
        jz              .end
        mov             ah, 0x0E                        ; Функция вывода символа
        mov             bl, 0x07
        int             0x10
        jmp             print
.end:
        jmp             endm
endm:   nop
}

start:
        cli
        mov             ax, cs
        mov             ds, ax
        mov             es, ax
        mov             ss, ax
        mov             sp, 0x7C00
        mov             ax, 0xB800
        mov             gs, ax
        print           msg

        mov             ax, 0000h
        mov             es, ax
        mov             bx, 500h
        mov             ch, 0
        mov             cl, 02h
        mov             dh, 0
        mov             al, 08h                         ; Кол-во секторов ядра
        mov             ah, 02h
        int             13h                             ; Загрузка сектора
        jmp             0000:0500h

 
msg     db              'OS BOOT INITIALISED', 0x0d, 0x0a, 0

times   510-($-$$)      db 0
db      0x55,           0xaa                            ; Сигнатура загрузочного сектора