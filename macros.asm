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

DecimalToAscii macro register
    push ax
    push dx

    mov dl, register
    add dl, 97
    mov resultado, dl
    mov ah, 02h
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
    mov bx,2
    cualquiera:
    xor dx,dx
    div cx
    push dx
    dec bx
    jnz cualquiera
    mov bx,2
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

ImprimirTexto macro Texto ; Ingresar Texto para imprimir
    ;mov ax,@data
    ;mov ds,ax
    mov ah,09h
    lea dx,Texto
    int 21h
endm

loadMenuFunction MACRO
    local menuFunc, fin, insertFunc, chargeFileFunc, solveLinearFunc

    menuFunc:
        clearTerminal
        print headersMenuFunc
        readUntilEnter bufferMenuFunc
        cmp bufferMenuFunc[0], "a"
        je insertFunc
        cmp bufferMenuFunc[0], "b"
        je chargeFileFunc
        cmp bufferMenuFunc[0], "c"
        je solveLinearFunc
        cmp bufferMenuFunc[0], "d"
        je solveCuadraticFunc
        cmp bufferMenuFunc[0], "e"
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

    solveLinearFunc:
        clearTerminal
        print textoFuncion
        clearBuffer bufferTeclado
        readUntilEnter bufferTeclado
        print breakLine
        ResolverFuncion
        readUntilEnter bufferKey
        jmp menuFunc

    solveCuadraticFunc:
        clearTerminal
        clearBuffer bufferFunction
        print msgInsertFunc
        readUntilEnter bufferFunction
        solveCuadratic bufferFunction
        Formula
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
            cmp bufferFile[di], 3bh
            je verifyBreakLine
            jmp ciclo1
        ; print breakLine

        verifyBreakLine:
            verifyFunction funcIndividual
            xor di, di
            add counterChars, 1
            mov di, counterChars
            cmp bufferFile[di+1], 0ah
            je incrementCounter
            jmp exit

        incrementCounter:
            add counterChars, 2
            mov di, counterChars
            jmp ciclo0

    exit:
ENDM

verifyFunction MACRO funcParam
    local ciclo, ok, fin, error, follow

    ; PrintText funcParam
    ; readUntilEnter bufferKey
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
        cmp wordIndividual, 30h ; Compara si es 0
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
        xor dx, dx
        print msgKeyGenerated
        
        DecimalToAscii dictKey

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
    je putFirstUnderscore   ; Ir a Meter el primer _
    
    returnFirstUnderscore:
        mov al, resultado
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
        ; readUntilEnter bufferKey
ENDM

lookForFunction MACRO idParam
    local ciclo, incId, idFound, ciclo1, printMsgFound, notFound, fin
    
    xor si, si
    mov bl, idParam
    mov counterResIntegral, 0
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
        cmp dictTable[si], 24h
        je notFound
        jmp ciclo

    idFound:
        clearBuffer funcIndividual
        xor cx, cx
        xor di, di
        ciclo1:
            inc si
            mov cl, dictTable[si]
            mov funcIndividual[di], cl
            cmp dictTable[si+1], 5fh
            je printMsgFound
            inc di
            jmp ciclo1

    printMsgFound:
        PrintText msgFuncFound
        PrintText funcIndividual
        readUntilEnter bufferKey
        jmp fin

    notFound:
        PrintText msgFuncNotFound
        readUntilEnter bufferKey

    fin:
ENDM

printFuncs MACRO params
    local ciclo0, ciclo1, exit

    xor di, di
    mov counterChars, 0
    ciclo0:
        xor si, si
        xor ax, ax
        clearBuffer funcIndividual
        ciclo1:
            mov ah, dictTable[di]
            mov funcIndividual[si], ah
            inc di
            inc si
            add counterChars, 1
            cmp dictTable[di], 24h
            je exit
            cmp dictTable[di], 5fh  ; Compara si es _
            jne ciclo1
        print breakLine
        PrintText funcIndividual
        ; readUntilEnter bufferKey
        xor di, di
        add counterChars, 1
        mov di, counterChars
        
        cmp dictTable[di], 24h
        jne ciclo0
    exit:
        ; print breakLine
        ; PrintText funcIndividual
ENDM

integration MACRO func
    local ciclo0, ciclo1, exit, continue
    mov capturedSign, 2bh
    xor di, di
    mov counterChars, 0
    ciclo0:
        xor si, si
        xor ax, ax
        clearBuffer expression
        ciclo1:
            mov ah, func[di]
            mov expression[si], ah
            inc di
            inc si
            add counterChars, 1
            cmp func[di], 24h
            je exit
            cmp func[di], 2bh ; Compara si es +
            je continue
            cmp func[di], 2dh ; Compara si es -
            je continue
            jmp ciclo1

        continue:
            xor dx, dx
            mov dl, func[di]
            mov capturedSign, dl
            evaluateExpr expression
            xor di, di
            add counterChars, 1
            mov di, counterChars
            
            cmp func[di], 24h
            jne ciclo0
    exit:
        evaluateExpr expression
ENDM

evaluateExpr MACRO expr
    local ciclo, printDivision, quitLessSign, follow, assignCoefficient, searchCoefficient, continue, defineExponent, setExponent, searchExponent, nonExponent, fin

    xor ax, ax
    xor di, di
    clearBuffer coefficient

    xor si, si
    ciclo:  ; Ciclo para saber si viene al menos una x
        cmp expr[si], 78h
        je follow
        cmp expr[si], 24h
        je nonExponent
        inc si
        jmp ciclo
    
    follow:
        cmp expr[0], 78h    ; Se compara con x
        je assignCoefficient
        jmp searchCoefficient

    assignCoefficient:
        mov ax, 1d
        mov coefficient, 31h
        jmp defineExponent

    searchCoefficient:
        mov al, expr[di]
        mov coefficient[di], al
        inc di
        cmp expr[di], 24h
        je defineExponent
        cmp expr[di], 78h       ; Se compara con x
        je defineExponent
        jmp searchCoefficient

    defineExponent:
        xor bx, bx
        inc di
        cmp expr[di], 24h
        je setExponent
        cmp expr[di], 5eh   ; Se compara la sig posicion a x con ^
        je searchExponent   ; Si existe, se busca el numero
        ; jmp setExponent     ; Si no existe, se setea un 1

    setExponent:
        mov bx, 1d
        add bx, 1
        mov number3n, bx
        jmp continue

    searchExponent:
        mov bl, expr[di+1]
        add bl, 1
        mov exponent, bl
        TextToDecimal exponent, number3n

    continue:
        ; mov number2n, 0
        xor cx, cx
        xor ax, ax
        
        TextToDecimal coefficient, number1n
        mov ax, number1n
        mov cx, number3n
        cwd
        idiv cx

        cmp ax, 0
        je printDivision

        mov number2n, ax
        DecimalToText number2n, resultado2  ; Imprime coeficiente
        PrintText literal
        PrintText raisedTo
        DecimalToText number3n, resultado3  ; Imprime exponente
        PrintText capturedSign
        jmp fin

    printDivision:
        ; ------ Imprime coeficiente fraccionario ----------
        PrintText coefficient
        PrintText over
        DecimalToText number3n, resultado3
        ; --------------------------------------------------
        PrintText literal
        PrintText raisedTo
        DecimalToText number3n, resultado3  ; Imprime exponente
        PrintText capturedSign
        jmp fin

    nonExponent:
        PrintText expr
        PrintText literal
        PrintText addSign

    fin:
ENDM

derivate MACRO func
    local ciclo0, ciclo1, exit, continue
    mov capturedSign, 2bh
    xor di, di
    mov counterChars, 0
    ciclo0:
        xor si, si
        xor ax, ax
        clearBuffer expression
        ciclo1:
            mov ah, func[di]
            mov expression[si], ah
            inc di
            inc si
            add counterChars, 1
            cmp func[di], 24h
            je exit
            cmp func[di], 2bh ; Compara si es +
            je continue
            cmp func[di], 2dh ; Compara si es -
            je continue
            jmp ciclo1

        continue:
            xor dx, dx
            mov dl, func[di]
            mov capturedSign, dl
            evaluateExpr2 expression
            xor di, di
            add counterChars, 1
            mov di, counterChars
            
            cmp func[di], 24h
            jne ciclo0
    exit:
        evaluateExpr2 expression
ENDM

evaluateExpr2 MACRO expr
    local ciclo, printDivision, quitLessSign, follow, assignCoefficient, searchCoefficient, continue, defineExponent, setExponent, searchExponent, nonExponent, fin

    xor ax, ax
    xor di, di
    clearBuffer coefficient

    xor si, si
    ciclo:  ; Ciclo para saber si viene al menos una x
        cmp expr[si], 78h
        je follow
        cmp expr[si], 24h
        je fin
        inc si
        jmp ciclo
    
    follow:
        cmp expr[0], 78h    ; Se compara con x
        je assignCoefficient
        jmp searchCoefficient

    assignCoefficient:
        mov ax, 1d
        mov coefficient, 31h
        jmp defineExponent

    searchCoefficient:
        mov al, expr[di]
        mov coefficient[di], al
        inc di
        cmp expr[di], 24h
        je defineExponent
        cmp expr[di], 78h       ; Se compara con x
        je defineExponent
        jmp searchCoefficient

    defineExponent:
        xor bx, bx
        inc di
        cmp expr[di], 24h
        je setExponent
        cmp expr[di], 5eh   ; Se compara la sig posicion a x con ^
        je searchExponent   ; Si existe, se busca el numero

    setExponent:
        PrintText coefficient
        jmp fin

    searchExponent:
        mov bl, expr[di+1]
        mov exponent, bl
        TextToDecimal exponent, number3n

    continue:
        ; mov number2n, 0
        xor cx, cx
        xor ax, ax
        xor bx, bx
        
        TextToDecimal coefficient, number1n
        mov ax, number1n
        mov cx, number3n
        cwd
        imul cx

        mov number2n, ax
        DecimalToText number2n, resultado2  ; Imprime coeficiente
        PrintText literal
        PrintText raisedTo

        mov bx, number3n
        sub bx, 1
        mov number4n, bx
        DecimalToText number4n, resultado3  ; Imprime exponente
        PrintText capturedSign
        jmp fin

    nonExponent:
        PrintText zero

    fin:
ENDM

ResolverFuncion macro
    

    Local Coeficiente
    Local EsUnoM
    Local DeterminarSignoB
    Local DeterminarB
    Local Operaciones
    Local RespPos
    Local ResEntero
    Local fin

    push ax
    push bx

    mov si, 0d
    mov mEsNegativa, 0d
    mov bEsNegativo, 0d
    mov MDec,0d
    mov MUn,1d
    mov BDec,0d
    mov BUn,1d

    cmp bufferTeclado[si], 45d
    jnz Coeficiente

    mov mEsNegativa, 1d
    inc si

    Coeficiente:
        cmp bufferTeclado[si], 120d
        jz DeterminarSignoB
        
        mov al, bufferTeclado[si]
        sub al, 48d
        mov MUn, al

        inc si
        cmp bufferTeclado[si], 120d
        jz DeterminarSignoB


        mov MDec, al
        mov al, bufferTeclado[si]
        sub al, 48d
        mov MUn, al
        inc si
        jmp DeterminarSignoB


    DeterminarSignoB:
        inc si
        cmp bufferTeclado[si], 43d
        jnz DeterminarB
        mov bEsNegativo, 1d

    DeterminarB:
        xor ax, ax
        inc si
        mov al, bufferTeclado[si]
        sub al, 48d
        mov BUn, al
        
        inc si
        cmp bufferTeclado[si], 36d
        jz Operaciones

        mov BDec, al
        mov al, bufferTeclado[si]
        sub al, 48d
        mov BUn, al   
        inc si

    Operaciones:

        xor ax, ax
        mov al, MDec
        mov bl, 10d
        mul bl

        mov MDec, al

        mov al, MDec
        mov ah, MUn

        add ah, al
        mov valorDeM, ah


        xor ax, ax
        mov al, BDec
        mov bl, 10d
        mul bl

        mov BDec, al        

        mov al, BDec
        mov ah, BUn

        add ah, al
        mov valorDeB, ah


        mov al, mEsNegativa
        mov ah, bEsNegativo
        cmp ah, al
        jz RespPos
        ImprimirTexto signoMenos
        xor ax, ax

    RespPos:
    

    mov al, valorDeB
    mov bl, valorDeM

    div bl

    cmp ah, 0d
    jz ResEntero

    Imprimir8bits valorDeB
    ImprimirTexto signoDiv
    Imprimir8bits valorDeM
    jmp fin

    ResEntero:
        mov respuesta, al
        Imprimir8bits respuesta

    fin:

    pop bx
    pop ax

endm

DibujarPlanos macro

    Local ciclo1
    Local ciclo2

    mov ah,0d
    mov al, 12h
    int 10h

    xor ax,ax
    mov valorX, 320
    mov valorY,0

    mov ah, 0ch
    mov al, 0Ah
    mov bh, 0d

    ciclo1:        
        mov cx, valorX
        mov dx, valorY
        int 10h
        
        inc valorY
        cmp valorY, 480
        jnz ciclo1


    mov valorx, 0d
    mov valorY, 240
    
    ciclo2:
        mov cx, valorX
        mov dx, valorY
        int 10h

        inc valorX
        cmp valorX, 640
        jnz ciclo2

endm

FuncionGraf macro

    Local ciclo

    xor ax, ax
    xor bx, bx

    mov ah, 0ch
    mov al, 0Ch
    mov bh, 0d

    mov valorX,221d
    mov valorXReal, -99d
    ;mov valorY, 640d
    ciclo:
        mov cx, valorX
        mov dx, valorY
        int 10h
        
        inc valorX
        inc valorXReal
        cmp valorX, 419
        jnz ciclo

endm

solveCuadratic MACRO func
    local ciclo0, ciclo1, exit, continue
    mov capturedSign, 2bh
    xor di, di
    mov counterChars, 0
    ciclo0:
        xor si, si
        xor ax, ax
        clearBuffer expression
        ciclo1:
            mov ah, func[di]
            mov expression[si], ah
            inc di
            inc si
            add counterChars, 1
            cmp func[di], 24h
            je exit
            cmp func[di], 2bh ; Compara si es +
            je continue
            cmp func[di], 2dh ; Compara si es -
            je continue
            jmp ciclo1

        continue:
            xor dx, dx
            mov dl, func[di]
            mov capturedSign, dl
            evaluateExpr3 expression
            xor di, di
            add counterChars, 1
            mov di, counterChars
            
            cmp func[di], 24h
            jne ciclo0
    exit:
        evaluateExpr3 expression
ENDM

evaluateExpr3 MACRO expr
    local searchCoefficient, continue, fin, firstCoef, secondCoef, thirdCoef

    xor ax, ax
    xor di, di
    clearBuffer coefficient

    searchCoefficient:
        mov al, expr[di]
        mov coefficient[di], al
        inc di
        cmp expr[di], 24h
        je continue
        cmp expr[di], 78h       ; Se compara con x
        je continue
        jmp searchCoefficient

    continue:
        ; mov number2n, 0
        xor cx, cx
        xor ax, ax
        xor bx, bx
        
        cmp counterCuadratic, 0
        je firstCoef
        cmp counterCuadratic, 1
        je secondCoef
        jmp thirdCoef

        firstCoef:
            ; PrintText coefficient
            TextToDecimal coefficient, vara
            jmp fin

        secondCoef:
            ; PrintText coefficient
            TextToDecimal coefficient, varb
            jmp fin

        thirdCoef:
            ; PrintText coefficient
            TextToDecimal coefficient, varc

    fin:
        add counterCuadratic, 1
ENDM

Formula macro
    local espositivo1,espositivo2,esnegativo1,esnegativo2,seguir1,seguir2
    OperarRaiz
    OperarNumeradorPositivo
    OperarNumeroadorNegativo
    OperarDenominador
endm

OperarRaiz macro
    local menor,mayor,igual
    push ax
    push bx
    push cx
    ;4*a*c
    xor ax,ax
    xor bx,bx
    mov ax,vara
    mov bx,varc
    imul bx
    mov bx,4
    imul bx
    mov vartmp,ax

    ;B^2
    xor ax,ax
    xor bx,bx
    mov ax,varb
    mov bx,varb
    imul bx
    mov vartmp2,ax
    
    ;B^2-4ac
    xor ax,ax
    xor bx,bx
    mov ax,vartmp2
    mov bx,vartmp
    sub ax,bx
    mov vartmp,ax

    ;raiz(B^2-4ac)
    xor ax,ax
    xor bx,bx
    mov bx, vartmp
    xor cx, cx

    mul cx
    mov ax, cx
    cmp ax, bx
    ja mayor
    jb menor
    jc igual 

    menor:
        inc cx
        mov ax, cx
        mul cx
        cmp ax, bx
        ja mayor
        je igual
        jb menor

    mayor:
        dec cx
        jmp igual
    igual:
    mov vartmp,cx

    pop cx
    pop bx
    pop ax
endm
OperarNumeradorPositivo macro
    push ax
    push bx
    ;-b
    xor ax,ax
    xor bx,bx
    mov ax,varb
    neg ax

    ;-b+raiz(B^2-4ac)
    xor bx,bx
    mov bx,vartmp
    add ax,bx

    
    mov numerador1,ax

    Imprimir16bits numerador1
    readUntilEnter bufferKey
    pop bx
    pop ax
endm
OperarNumeroadorNegativo macro
    push ax
    push bx
    ;-b
    xor ax,ax
    xor bx,bx
    mov ax,varb
    neg ax

    ;-b+raiz(B^2-4ac)
    xor bx,bx
    mov bx,vartmp
    sub ax,bx
    
    mov numerador2,ax

    Imprimir16bits numerador2
    readUntilEnter bufferKey
    pop bx
    pop ax
endm
OperarDenominador macro
    push ax
    push bx
    xor ax,ax
    xor bx,bx
    mov ax,vara
    mov bx,2
    imul bx

    mov denominador1,ax
    mov denominador2,ax

    Imprimir16bits denominador1
    readUntilEnter bufferKey
    pop bx
    pop ax
endm