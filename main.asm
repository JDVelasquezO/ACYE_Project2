include macros.asm
include files.asm

.model small
.stack 100h
.data
    headers db 	0ah,0dh,'Universidad de San Carlos de Guatemala',
                0ah,0dh,'Arquitectura de Computadores y Ensambladores 1',
                0ah, 0dh,'-- Menu Principal --',
                0ah,0dh,'-- (dID) Derivar funcion --',
                0ah,0dh,'-- (iID) Integrar funcion --',
                0ah,0dh,'-- (func) Ingresar funciones --',
                0ah,0dh,'-- (print) Imprimir funciones --',
                0ah,0dh,'-- (x) Salir',
                0ah,0dh,'$'

    headersMenuFunc db 0ah, 0dh, '--- Menu de Funciones ---',
                       0ah, 0dh, 'a. Ingresar Funcion',
                       0ah, 0dh, 'b. Cargar Archivos',
                       0ah, 0dh, 'c. Regresar a menu principal',
                       0ah, 0dh, '$'

    msgInsertFunc db "Ingrese funcion a evaluar $"
    msgChargeFileFunc db "Ingrese archivo de carga de funciones $"
    msgInputNotValid db "Entrada no valida $"
    msgKeyGenerated db "Llave: $"
    msgValGenerated db "Valor: $"
    msgDerivative db "Ingresar el id de la funcion a derivar: $"
    msgFuncFound db "Funcion encontrada: $"
    msgFuncNotFound db "Funcion no encontrada $"
    test_info db "Aqui todo bien $"
    twoPonts db ": $"
    space db " ", "$"
    breakLine db " $", 13, 10

    bufferFile db 1000 dup("$"), "$"
    bufferRoute db 20 dup("$"), 0
    bufferMenuFunc db 20 dup("$"), 0
    bufferFunction db 20 dup("$"), 0
    bufferKey db 20 dup("$"), 0
    bufferId db 2 dup("$"), 0
    wordIndividual db 20 dup("$"), 0
    funcIndividual db 20 dup("$"), 0
    expression db 10 dup("$"), 0
    coefficient db 3 dup("$"), 0
    exponent db 3 dup("$"), 0
    integratedExpr db 20 dup("$"), 0
    literal db "x $"
    constant db "+C $"

    dictTable db 200 dup("$"), 0
    dictKey db 0
    dictKeyString db 2 dup("$"), 0

    counter dw 0
    counterTable dw 0
    counterChars dw 0
    counterExternTable dw 0
    number1n dw ?
    resultado db ?
    handle dw ?, 0
.code
    ;description
    main PROC
        mov ax, @data
        mov ds, ax
        mov es, ax  ; Le mandamos al segmento data extra el inicio del segmento de datos

        menu:
            clearTerminal
            print headers
            readUntilEnter bufferRoute

            cmp bufferRoute[0], 'x'
            je exitGame
            cmp bufferRoute[0], 'X'
            je exitGame

            cmp bufferRoute[0], 'd'
            je derivateFunc
            cmp bufferRoute[0], 'i'
            je integrateFunc
            cmp bufferRoute[0], 'f'
            je menuFunction
            cmp bufferRoute[0], 'p'
            je printFunctions
            jmp menu

        menuFunction:
            clearTerminal
            loadMenuFunction
            jmp menu

        derivateFunc:
            clearTerminal
            lookForFunction bufferRoute[1]
            jmp menu

        integrateFunc:
            clearTerminal
            lookForFunction bufferRoute[1]
            integration funcIndividual
            jmp menu

        printFunctions:
            clearTerminal
            printFuncs
            readUntilEnter bufferKey
            jmp menu
        
        exitGame:
            mov ax, 4C00H
            INT 21H

    main ENDP
end