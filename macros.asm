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

PrintText macro Text    ;Prints "Text"
    mov ax,@data
    mov ds,ax
    mov ah,09h
    lea dx,Text
    int 21h
endm

DecimalToText macro entrada, salida ;Converts decimal to text
    Local divide
    Local divide2
    Local make
    Local negative
    Local done
    xor ax,ax   ;Clear ax
    mov ax,entrada  ;Move number into ax
	xor si,si   ;Clear si
	xor cx,cx   ;Clear cx
	xor bx,bx   ;Clear bx
	xor dx,dx   ;Clear dx
	mov bx,0ah  ;Move 10 into bx
	test ax,1000000000000000    ;Compare if ax is negative
	jnz negative    ;If ax is negative go to negative
	jmp divide2 ;if ax is positive go to divide2
	negative:
		neg ax  ;Negate ax to make it positive
		mov salida[si],45   ;Move a "-" at the start of text
		inc si  ;Increment counter si
		jmp divide2    ;Go to divide 2
	divide:
		xor dx,dx   ;Clear dx
	divide2:
		div bx  ;divide ax by bx
		inc cx  ;Increment counter cx
		push dx ;Push dx register into stack
		cmp ax,00h  ;Campre if ax is 0
		je make ;IF ax is 0 go to make
		jmp divide  ;If ax is not 0 go to divide
	make:
		pop ax  ;Take out last register from stack
		add ax,30h  ;Make conversion
		mov salida[si],ax   ;Move ax into salida position si
		inc si  ;Increment counter si
		loop make ;Loop to make
		mov ax,24h  ;Move $ to ax
		mov salida[si],ax   ;Move ax into salida position si
		inc si  ;Increment si
	done:
		PrintText salida    ;Display result
endm

TextToDecimal macro buffer, des ;Converts text to decimal
    Local start, fin, negative, positive, done, negate

	xor ax,ax   ;Clears ax registry
	xor bx,bx   ;Clears bx registry
	xor cx,cx   ;Clears cx registry
	xor di,di   ;Clears di resistry, 0 = Positive, 1 = Negative
	mov bx,10	;Moves 10 into bx
	xor si,si   ;Clears si registry, for counter of position inside buffer
	start:
		mov cl,buffer[si]   ;Move buffer in position si into cl
		cmp cl,45   ;Compares if cl is "-"
		je negative ;If cl is "-" jump to negative
		jmp positive    ;If cl is not "-" jump to positive
	negative:
		inc di  ;Increment di to 1, now the number is negative
		inc si  ;Increment si by 1 to read next value
		mov cl,buffer[si]   ;Move the next value into cl
	positive:
		cmp cl,48   ;Compares if cl is 0
		jl fin  ;Jump to negate
		cmp cl,57   ;Compares if cl is 9
		jg fin  ;Jump to negate
		inc si  ;Increment si to read next value
		sub cl,48	;Substract 48 to cl to get number
		mul bx		;Multiply ax by bx
		add ax,cx	;Add to ax cx
		jmp start   ;Jump to start
	fin:
		cmp di,1    ;Compares if di = 1
		je negate   ;Go to negate to negate ax
		jmp done    ;If di = 0 go to done
	negate:
		neg ax  ;Negates ax
	done:
        mov des,ax  ;Moves register ax into des, which is output
        xor si, si
endm

loadMenuFunction MACRO
    local menuFunc, fin, insertFunc, chargeFileFunc

    menuFunc:
        clearTerminal
        print headersMenuFunc
        readUntilEnter bufferMenuFunc
        cmp bufferMenuFunc[0], "a"
        je insertFunc
        cmp bufferMenuFunc[0], "b"
        je chargeFileFunc
        cmp bufferMenuFunc[0], "c"
        je fin
        jmp menuFunc

    insertFunc:
        clearBuffer bufferFunction
        clearTerminal
        print msgInsertFunc
        readUntilEnter bufferFunction
        verifyFunction bufferFunction
        jmp menuFunc

    chargeFileFunc:
        clearTerminal
        print msgChargeFileFunc
        readUntilEnter bufferFunction
        loadFile bufferFunction
        jmp menuFunc
    
    fin:
ENDM

loadFile MACRO nameRoute
    local ciclo0, ciclo1, validateFunc, exit

    openFile nameRoute
    readFile
    closeFile
    ; PrintText bufferFile
    ; readUntilEnter bufferKey

    xor di, di
    mov counterChars, 0
    ciclo0:
        xor si, si
        xor ax, ax
        clearBuffer funcIndividual
        ciclo1:
            mov ah, bufferFile[di]
            mov funcIndividual[si], ah
            inc di
            inc si
            add counterChars, 1
            cmp bufferFile[di], 24h
            je exit
            cmp bufferFile[di], 3bh
            jne ciclo1
        print breakLine
        verifyFunction funcIndividual
        ; readUntilEnter bufferKey
        xor di, di
        add counterChars, 1
        mov di, counterChars
        
        cmp bufferFile[di], 24h
        jne ciclo0
    exit:
        print breakLine
        verifyFunction funcIndividual
        ; readUntilEnter bufferKey
ENDM

verifyFunction MACRO funcParam
    local ciclo, ok, fin, error, follow

    PrintText funcParam
    readUntilEnter bufferKey
    xor si, si
    mov counter, 0
    ciclo:
        mov bl, funcParam[si]
        mov wordIndividual, bl

        cmp wordIndividual, 78h ; Compara si es x
        je follow
        cmp wordIndividual, 2bh ; Compara si es +
        je follow
        cmp wordIndividual, 2dh ; Compara si es -
        je follow
        cmp wordIndividual, 5eh ; Compara si es ^
        je follow

        TextToDecimal wordIndividual, number1n
        cmp number1n, 0
        je error

    follow:
        mov si, counter
        cmp funcParam[si+1], 24h
        je ok
        inc si
        add counter, 1
        jmp ciclo
    
    ok:
        ; Imprimir llave y valor
        print msgKeyGenerated
        DecimalToText dictKey, resultado
        print space
        print msgValGenerated
        PrintText funcParam
        
        ; Guardar en diccionario
        keepOnTable funcParam

        clearBuffer bufferMenuFunc
        clearBuffer funcParam
        add dictKey, 1
        jmp fin

    error:
        print msgInputNotValid
        readUntilEnter bufferKey
        jmp fin

    fin:
ENDM

keepOnTable MACRO funcParam
    local ciclo, fin, continue, putFirstUnderscore, returnFirstUnderscore

    xor bx, bx
    mov bx, counterExternTable

    cmp counterExternTable, 0
    je putFirstUnderscore
    
    returnFirstUnderscore:
        mov ax, resultado
        mov dictTable[bx], al   ; Meter el primer ID
        inc bx
        add counterExternTable, 1
        mov dictTable[bx], 5fh  ; Meter el segundo _
        inc bx                  ; bx toma el tercer valor
        add counterExternTable, 1

        xor si, si
        xor di, di
        xor cx, cx
        mov si, bx
        mov counterTable, bx
        ciclo:
            mov cl, funcParam[di]
            mov dictTable[si], cl
            add counterExternTable, 1
            cmp funcParam[di+1], 24h
            je continue
            inc di
            inc si
            add counterTable, 1
            jmp ciclo

    continue:
        inc si
        mov dictTable[si], 5fh
        add counterExternTable, 1
        jmp fin

    putFirstUnderscore:
        mov dictTable[bx], 5fh  ; Meter el primer _
        inc bx
        add counterExternTable, 1
        jmp returnFirstUnderscore

    fin:
        print breakLine
        PrintText dictTable
        readUntilEnter bufferKey
ENDM

lookForFunction MACRO params
    xor si, si
    mov bl, bufferRoute[1]
    ciclo:
        cmp dictTable[si], 5fh
        jne incId
        inc si
        cmp dictTable[si], bl
        jne incId
        inc si
        cmp dictTable[si], 5fh
        jne incId
        jmp idFound

    incId:
        inc si
        jmp ciclo

    idFound:
        PrintText msgFuncFound
        print breakLine
        PrintText dictTable[si+1]
        readUntilEnter bufferKey
ENDM