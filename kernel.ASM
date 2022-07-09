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
endm:
        pop             ax
}



macro   fill       x, y, text                           ; Функция прямого вывода в видеопамять по заданным координатам
{
LOCAL   fill
LOCAL   endm
        push            dx
        push            ax
        mov             dx, 2h * (x + y * 80h)          ; Рассчет адреса
        mov             si, text
        call            fill
        jmp             endm
fill:
        mov             ax, 0xb800                      ; Начало видеобуффера (текст)
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
endm:
        pop             ax
        pop             dx
}



macro   print           text                            ; Последовательный вывод (INT 10h)
{
LOCAL   print
LOCAL   endm
        mov             si, text
        push            ax
        push            bx
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
endm:
        pop             bx
        pop             ax
}


macro   getvect         vect, oldofs, oldseg
{
        xor             ax, ax
        mov             ds, ax
        mov             dx, [ds:vect * 4]
        mov             es, [ds:vect * 4 + 2]
        mov             [oldofs], dx
        mov             [oldseg], es
}

macro   setvect         vect, new_vect
{
        xor             ax, ax
        mov             ds, ax
        mov             dx, new_vect
        mov             [ds:vect * 4], dx
        mov             [ds:vect * 4 + 2], cs
}


macro   byte_to_str     buffer, value
{
        push            ax
        push            bx
        push            cx
        push            di
        mov             al, value
        mov             bl, 10
        xor             cx, cx
@@:
        xor             ah, ah
        div             bl
        add             ah, '0'
        push            ax
        inc             cx
        or              al, al
        jne             @b
        xor             ax, ax
        mov             di, ax
@@:
        pop             ax
        mov             [buffer + di], ah
        inc di
        loop            @b
        mov             [buffer + di], ' '
        mov             [buffer + di + 1], 0x00
        pop             di
        pop             cx
        pop             bx
        pop             ax
}

macro set_ind           x, y, color_code
{
        push            ax
        push            bx
        push            dx

        mov             ax, 2 * (x + y * 80h)
        mov             di, ax

        mov             bx, 0xb800                      ; Начало видеобуффера (текст)
        mov             es, bx
        mov             dh, color_code
        xor             dl, dl
        mov             word [es:di], dx                ; Запись значения в буффер

        pop             dx
        pop             bx
        pop             ax
}


start:                                                  ; ENTRY POINT
        print           b_msg
        print           nl
        print           q_msg
        print           nl
        fill            0, 15,  label1
        fill            10, 15, label2
        fill            20, 15, label3
        fill            30, 15, label4
        fill            44, 15, label5
        getvect         8h, oldofs8h, oldseg8h
        setvect         8h, new_int8h
        getvect         9h, oldofs9h, oldseg9h
        setvect         9h, new_int9h

main:
        set_ind         29, 15, 0xA0
        byte_to_str     text, [count]
        fill            39, 15, text
        byte_to_str     text, [sec]
        fill            52, 15, text
        byte_to_str     text, [kb_cnt]
        fill            60, 15, text
        byte_to_str     text, [quit_f]
        fill            65, 15, text
        cmp             [quit_f], 1
        jz              @f
        jmp             main
@@:
        mov             ax, 5301h
        xor             bx, bx
        int             15h

        mov             ax, 530Eh
        xor             bx, bx
        mov             cx, 0102h
        int             15h

        mov             ax, 5307h
        mov             bx, 0001h
        mov             cx, 0003h
        int             15h
        hlt
        jmp             $

;-----------------------------------------------;
;               INT 8H CONTROL                  ;
;-----------------------------------------------;

new_int8h:
        set_ind         19, 15, 0xB0
        pushf
        call            dword ptr cs:oldofs8h

        push            ax
        push            bx
        push            cx
        push            dx
        push            di

        inc             [count]
        cmp             [count], 18
        jl              @f
        mov             [count], 0
        inc             [sec]
        set_ind         9, 15, 0x00
@@:
        mov             al, 20h
        out             20h, al
        set_ind         19, 15, 0x00
        pop             di
        pop             dx
        pop             cx
        pop             bx
        pop             ax
        iret

;-----------------------------------------------;
;               INT 9H CONTROL                  ;
;-----------------------------------------------;

new_int9h:
        set_ind         9, 15, 0xA0
        pushf
        call            dword ptr cs:oldofs9h
        push            ax
        push            bx
        push            cx
        push            dx
        push            di

        mov             ah, 01h
        int             16h
        jz              @f
        mov             ah, 10h
        int             16h
        push            ax
        mov             dx, ax
        push            dx
        reg_to_hex      text, dh
        fill            68, 15, text
        pop             dx
        reg_to_hex      text, dl
        fill            70, 15, text
        pop             ax
        mov             dl, [kb_cnt]
        xor             dh, dh
        mov             di, dx
        mov             [kb_wrd + di], al
        inc             [kb_cnt]
        cmp             ah, 0x01
        jnz             .n
        mov             [quit_f], 0x01
.n:
        cmp             al, 0x0d
        mov             ah, 0Eh
        int             10h
        jnz             @f
        mov             [kb_wrd + di], 0
        mov             [kb_cnt], 0
        mov             al, 0x0a
        mov             ah, 0Eh
        mov             bl, 0x07
        int             10h
@@:
        mov             al, 20h
        out             20h, al
        pop             di
        pop             dx
        pop             cx
        pop             bx
        pop             ax
        iret



oldofs8h  dw            0x0000
oldseg8h  dw            0x0000
oldofs9h  dw            0x0000
oldseg9h  dw            0x0000

count   db              0x00
kb_cnt  db              0x00
sec     db              0x00
quit_f  db              0x00
b_msg   db              "System booted", 0
q_msg   db              "ESC to shutwown", 0
int_s   db              "Main vector: ", 0
int_d   db              "Ovr. vector: ", 0
label1  db              "KEYBOARD: " , 0
label2  db              "SYSTIMER: ", 0
label3  db              "KERNEL_L: ", 0
label4  db              "TIMER_BT: ", 0
label5  db              "RUN_SEC: ", 0
nl      db              0x0d, 0x0a, 0
space   db              ' ', 0

kb_wrd  db              256 dup(0)
text    db              64 dup(?)
