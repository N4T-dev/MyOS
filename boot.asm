[BITS 16]
[ORG 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear screen with blue background
    mov ax, 0x0600
    mov bh, 0x1F      ; white text on blue background
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10

    ; Set cursor to top left
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10

    ; Print title bar
    mov si, title
    mov bl, 0x1F      ; white on blue
    call print_colored

    ; Move cursor to row 2
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0200
    int 0x10

    ; Print welcome message
    mov si, welcome
    mov bl, 0x1B      ; cyan on blue
    call print_colored

    ; Move cursor to row 4
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0400
    int 0x10

    mov si, version
    mov bl, 0x1A      ; green on blue
    call print_colored

    ; Move cursor to row 6
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0600
    int 0x10

    mov si, prompt
    mov bl, 0x1E      ; yellow on blue
    call print_colored

    ; Move cursor to row 8 for blinking cursor
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0800
    int 0x10

    mov si, cursor_line
    mov bl, 0x1F
    call print_colored

blink_loop:
    ; Show cursor block
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0802
    int 0x10
    mov ah, 0x09
    mov al, 0xDB      ; solid block character
    mov bh, 0x00
    mov bl, 0x1F
    mov cx, 1
    int 0x10

    ; Delay
    mov cx, 0xFFFF
delay1:
    loop delay1
    mov cx, 0x8FFF
delay2:
    loop delay2

    ; Hide cursor
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0802
    int 0x10
    mov ah, 0x09
    mov al, ' '
    mov bh, 0x00
    mov bl, 0x1E
    mov cx, 1
    int 0x10

    ; Delay
    mov cx, 0xFFFF
delay3:
    loop delay3
    mov cx, 0x8FFF
delay4:
    loop delay4

    jmp blink_loop

print_colored:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_colored
.done:
    ret

title    db '    *** MyOS v1.0 - Built by N4T-dev ***', 0
welcome  db '    Welcome to MyOS!', 0
version  db '    Running on x86 CPU | QEMU Virtual Machine', 0
prompt   db '    This OS was built from scratch in Assembly.', 0
cursor_line db '    > ', 0

times 510-($-$$) db 0
dw 0xAA55
