[BITS 16]
[ORG 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Set VGA 320x200 256-color mode
    mov ax, 0x0013
    int 0x10

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pm_start

[BITS 32]
pm_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Fill screen dark blue/black
    mov edi, 0xA0000
    mov ecx, 320*200
    mov al, 1
    rep stosb

    ; Draw stars
    mov byte [0xA0000 + 10*320 + 45],  15
    mov byte [0xA0000 + 15*320 + 120], 15
    mov byte [0xA0000 + 8*320  + 200], 15
    mov byte [0xA0000 + 20*320 + 280], 15
    mov byte [0xA0000 + 5*320  + 310], 15
    mov byte [0xA0000 + 25*320 + 80],  15
    mov byte [0xA0000 + 12*320 + 250], 15
    mov byte [0xA0000 + 30*320 + 160], 15
    mov byte [0xA0000 + 35*320 + 300], 15
    mov byte [0xA0000 + 3*320  + 170], 15
    mov byte [0xA0000 + 40*320 + 60],  15
    mov byte [0xA0000 + 18*320 + 290], 15

    ; Draw Saturn body (orange circle)
    mov ecx, -15
.py:
    cmp ecx, 16
    jge .ring
    mov edx, -15
.px:
    cmp edx, 16
    jge .npy
    mov eax, edx
    imul eax, edx
    mov ebx, ecx
    imul ebx, ebx
    add eax, ebx
    cmp eax, 225
    jg .sp
    mov eax, ecx
    add eax, 90
    imul eax, 320
    mov ebx, edx
    add ebx, 160
    add eax, ebx
    add eax, 0xA0000
    mov byte [eax], 6
.sp:
    inc edx
    jmp .px
.npy:
    inc ecx
    jmp .py

    ; Draw Saturn ring
.ring:
    mov ecx, -4
.ry:
    cmp ecx, 5
    jge .taskbar
    mov edx, -30
.rx:
    cmp edx, 31
    jge .nry
    mov eax, edx
    imul eax, edx
    mov ebx, 25
    imul eax, ebx
    mov ebx, ecx
    imul ebx, ebx
    mov esi, 784
    imul ebx, esi
    add eax, ebx
    cmp eax, 16100
    jl .sr
    cmp eax, 22600
    jg .sr
    mov eax, ecx
    add eax, 90
    imul eax, 320
    mov ebx, edx
    add ebx, 160
    add eax, ebx
    add eax, 0xA0000
    mov byte [eax], 14
.sr:
    inc edx
    jmp .rx
.nry:
    inc ecx
    jmp .ry

    ; Status bar at bottom of VGA
.taskbar:
    mov ecx, 190
.tbar:
    cmp ecx, 200
    jge .txt
    mov eax, ecx
    imul eax, 320
    add eax, 0xA0000
    mov edi, eax
    mov ebx, 320
.trow:
    mov byte [edi], 1
    inc edi
    dec ebx
    jnz .trow
    inc ecx
    jmp .tbar

    ; Write status text in VGA text buffer
.txt:
    mov edi, 0xB8000 + (24*80*2)
    mov esi, status
    mov ah, 0x1E
.sl:
    lodsb
    or al, al
    jz .halt
    mov [edi], ax
    add edi, 2
    jmp .sl
.halt:
    cli
    hlt

gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

status db ' MyOS v1.0 | VGA Graphics | Saturn OS | N4T-dev ', 0

times 510-($-$$) db 0
dw 0xAA55
