openFile macro name

    mov handle, 0000h

    mov ah, 3dh
    mov al, 000b
    lea dx, name
    int 21h

    mov handle, ax                      ;handle is a global variable

ENDM

readFile macro

    mov ah, 3fh
    mov bx, handle                      ;handle is a global variable
    mov cx, LENGTHOF bufferFile
    lea dx, bufferFile                  ;bufferFile is a global variable
    int 21h

ENDM

closeFile macro

    mov ah, 3eh
    mov bx, handle                      ;handle is a global variable
    int 21h

ENDM

createFile macro name
    mov ah, 3ch
    mov cx, 00h
    lea dx, name

    int 21h

    mov handle, ax                          ;handle is a global variable
ENDM

writeFile macro content
    mov ah, 40h
    mov bx, handle                          ;handle is a global variable
    mov cx, LENGTHOF content
    lea dx, content
    int 21h
ENDM