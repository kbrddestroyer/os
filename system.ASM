macro align value { db value-1 - ($ + value-1) mod (value) dup 0 }
HEADS = 1
SPT = 10
Begin:
        file "boot.bin",512
        file "kernel.bin"
        align 4096
        align HEADS*SPT*512
