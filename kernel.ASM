Use16
org 500h

macro   reg_to_hex buffer, reg                          ; Функция конветации HEX значения в последовательность ASCII-кодов
{
LOCAL   translate
LOCAL   endm
        push            ax
        mov             ah, reg
        sar             ah, 4
        call            translate
        mov             [buffer], ah
        mov             ah, reg
        call            translate
        mov             [buffer + 1], ah
        mov             [buffer + 2], 0
        pop ax
        jmp             endm
translate:
        mov             al, 0x0F                        ; null-terminator в конце строки
        and             ah, al
        cmp             ah, 10
        jb              .1
        jnb             .2
.1:
        add             ah, '0'
        jmp             .end
.2:
        add             ah, 'A' - 10
.end:
        ret
endm:   nop
}

macro   fill       x, y, text                           ; Функция прямого вывода в видеопамять по заданным координатам
{
LOCAL   fill
LOCAL   endm
        mov             dx, 2h * (x + y * 80h)          ; Рассчет адреса
        mov             si, text
        call            fill
        jmp             endm
fill:
        mov             ax, 0xB800                      ; Начало видеобуффера (текст)
        mov             es, ax
        lodsb
        test            al, al
        jz              .end                            ; При 0 - выход
        mov             ah, 0x07
        mov             di, dx
        mov             word [es:di], ax                ; Запись значения в буффер
        add             dx, 2                           ; Сдвиг адреса на 2 байта (размер CHAR - 2 байта)
        jmp             fill                            ; Повтор действия
.end:
        ret
endm:   nop
}

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

start:                                                  ; ENTRY POINT
        print           msg
        fill            0, 10, msg

        xor             ax, ax
        mov             es, ax
        mov             dx, [es:8*4]

        reg_to_hex      text, dh

        print           text

        reg_to_hex      text, dl

        print           text

        in              al, 0x20
        reg_to_hex      text, al
        print           0x0a
        print           0x0d
        print           text

        jmp             keyboard
        hlt
        jmp             $

keyboard:
        mov             ah, 0h
        int             16h
        cmp             al, 0x0d
        jz              .newline
        mov             ah, 0Eh
        int             10h
        jmp             keyboard
.newline:
        mov             ah, 0Eh
        int             10h
        mov             ah, 3h
        xor             bh, bh
        int             10h
        mov             ah, 2h
        inc             dh
        xor             bh, bh
        int             10h
        jmp             keyboard
.end:
        ret

text    db              0x00
msg     db              "System booted", 0x0d, 0x0a, 0