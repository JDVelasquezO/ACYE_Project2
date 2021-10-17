print macro string

    push ax
    push dx

    mov dx, offset string		; mover donde empieza el mensaje
	mov ah, 09h 				; Para imprimir un caracter en pantalla
	INT 21H

    pop dx
    pop ax
endm

printRegister macro register
	push ax
	push dx
	
	mov dl,register
	add dl,48 		; Se le suma 48 por el codigo ascii
	mov ah,02h
	int 21h
	
	pop dx
	pop ax
endm

ImprimirEspacio macro registro
	push ax
	push dx
	
	mov registro, 13
	CrearEspacio al
	mov registro, 10
	CrearEspacio al
	
	pop dx
	pop ax
endm

CrearEspacio macro registro
	push ax
	push dx
	
	mov dl,registro
	mov ah,02h
	int 21h
	
	pop dx
	pop ax
endm

readUntilEnter macro entrada
    local salto, fin

    xor bx, bx ;Limpiando el registro
    salto:
        mov ah, 01h
        int 21h
        cmp al, 0dh ;Verificar si es un salto de linea lo que se esta leyendo
        je fin
        mov entrada[bx], al
        inc bx
        jmp salto

    fin:
        mov al, 24h ;Agregando un signo de dolar para eliminar el salto de linea
        mov entrada[bx], al
endm

clearTerminal macro   ; clear o cls
    mov ax, 03h 
    int 10h
endm

getIn macro
    mov ah, 01h
    int 21h
endm

CadenaColor MACRO cadena, cantidad, inicio, fin
    push ax
    push bx
    push cx
    push dx

    mov bx, 0
    lea bp, cadena[bx]  ; Imprimir cadena. bp debe saber donde inicia el string
    mov al, 1       ; Escribir con colores
    mov bh, 0       ; Número de página siempre 0 por defecto
    mov bl, 2h      ; Atributos, color específico
    mov cx, cantidad       ; Cantidad de caracteres
    mov dl, inicio      ; Columna donde va a empezar
    mov dh, fin      ; Fila donde va a empezar
    mov ah, 13h     ; Funcionalidad escribir STRING
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
ENDM

CharColor MACRO char, color
    local comp

    push ax
    push bx
    push cx
    push dx

    mov al, char     ; Imprimir un caracter en específico
    mov ah, 09h     ; Imprimir un char
    mov bh, 0       ; Página
    mov bl, color   ; Color: el primer bit indica si parpadea o no, los otros 3 el color de fondo y los otros 4 el color
    mov cx, 1       ; 1 Caracter
    int 10h

    ; DESPLAZAR EL CURSOR 
    mov ah, 03h     ; Obtiene la posicion actual
    int 10h
    inc dl          ; Columnas
    cmp dl, 80
    jnz comp
    inc dh
    mov dl, 0

    comp:
    mov ah, 02h     ; Desplazar el cursor
    int 10h
    ; --------------------------------------------------------

    pop dx
    pop cx
    pop bx
    pop ax 
ENDM

convertir8bits macro param
    local cualquiera,noz
    xor ax,ax
    mov al,param
    mov cx,10
    mov bx,3
    cualquiera:
    xor dx,dx
    div cx
    push dx
    dec bx
    jnz cualquiera
    mov bx,3
    noz:
    pop dx

    push ax
    push bx
    push cx
    push dx

    add dl, 48
    mov param, dl
    writeFile param
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    dec bx
    jnz noz
endm

printRegister macro register
	push ax
	push dx
	
	mov dl,register
	add dl,48 		; Se le suma 48 por el codigo ascii
	mov ah,02h
	int 21h
	
	pop dx
	pop ax
endm

ImprimirNumero macro registro
    push ax
    push dx


    mov dl,registro
    ;ah = 2
    add dl,48
    mov ah,02h
    int 21h


    pop dx
    pop ax
endm

Imprimir8bits macro registro
    local cualquiera,noz
    xor ax,ax
    mov al,registro
    mov cx,10
    mov bx,3
    cualquiera:
    xor dx,dx
    div cx
    push dx
    dec bx
    jnz cualquiera
    mov bx,3
    noz:
    pop dx
    ImprimirNumero dl
    dec bx
    jnz noz
endm

Imprimir16bits macro registro
    local cualquiera,noz
    xor ax,ax
    mov ax,registro
    mov cx,10
    mov bx,5
    cualquiera:
    xor dx,dx
    div cx
    push dx
    dec bx
    jnz cualquiera
    mov bx,5
    noz:
    pop dx
    ImprimirNumero dl
    dec bx
    jnz noz
endm

clearBuffer macro buffer

    push di
    push cx
    push ax

    xor ax, ax
    xor di, di
    xor cx, cx
   
    MOV al, 24h

    LEA di, buffer
    MOV cx, LENGTHOF buffer
    CLD
    REP stosb

    pop ax
    pop cx
    pop di

ENDM

loadMenuFunction MACRO
    local menuFunc, fin, insertFunc, chargeFileFunc

    print headersMenuFunc
    readUntilEnter bufferMenuFunc

    menuFunc:
        cmp bufferMenuFunc[0], "a"
        je insertFunc
        cmp bufferMenuFunc[0], "b"
        je chargeFileFunc
        cmp bufferMenuFunc[0], "c"
        je fin
        jmp menuFunc

    insertFunc:
        clearTerminal
        clearBuffer bufferMenuFunc
        print msgInsertFunc
        readUntilEnter bufferMenuFunc

    chargeFileFunc:
        clearTerminal
        clearBuffer bufferMenuFunc
        print msgChargeFileFunc
        readUntilEnter bufferMenuFunc
    
    fin:
ENDM