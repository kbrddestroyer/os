Use16
org 500h



macro   reg_to_hex buffer, reg
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
        mov             al, 0x0F
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



macro   fill       x, y, text 
{
LOCAL   fill
LOCAL   endm
        mov             dx, 2h * (x + y * 80h)          ; Ðàññ÷åò àäðåñà
        mov             si, text
        call            fill
        jmp             endm
fill:
        mov             ax, 0xb800
        mov             es, ax
        lodsb
        test            al, al
        jz              .end
        mov             ah, 0x07
        mov             di, dx
        mov             word [es:di], ax
        add             dx, 2 
        jmp             fill
.end:
        ret
endm:   nop
}



macro   print           text
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
        mov             ah, 0x0E
        mov             bl, 0x07
        int             0x10
        jmp             print
.end:
        jmp             endm
endm:
        nop
}


start:                                                  ; ENTRY POINT
        vect            equ 9h
        xor             ax, ax
        mov             ds, ax
        mov             dx, [ds:vect * 4]
        mov             es, [ds:vect * 4 + 2]
        mov             [oldofs], dx
        mov             [oldseg], es
        mov             dx, new_int8h
        mov             [ds:vect * 4], dx
        mov             [ds:vect * 4 + 2], cs

        jmp             keyboard
        hlt
        jmp             $

new_int8h:
        mov             al, 'A'
        mov             ah, 0Eh
        mov             bl, 0x07
        int             10h

        mov             es, [oldseg]
        pushf
        call            dword ptr cs:oldofs
        mov             al,20h
        out             20h,al
        iret

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

oldofs  dw              0x0000
oldseg  dw              0x0000

text    db              0x00
msg     db              "System booted", 0x0d, 0x0a, 0
int_s   db              "Main vector: ", 0
int_d   db              "Ovr. vector: ", 0
nl      db              0x0d, 0x0a, 0
space   db              ' ', 0
