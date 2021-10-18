include macros.asm

.model small
.stack 100h
.data
    headers db 	0ah,0dh,'Universidad de San Carlos de Guatemala',
                0ah,0dh,'Arquitectura de Computadores y Ensambladores 1',
                0ah,0dh,'Grupo no.6',
                0ah,0dh,'Proyecto no.2',
                0ah,0dh,'Ingrese nombre de archivo de entrada o X si desea salir:',
                0ah,0dh,'$'

    headersMenuFunc db 0ah, 0dh, '--- Menu de Funciones ---'
                       0ah, 0dh, 'a. Ingresar Funcion',
                       0ah, 0dh, 'b. Cargar Archivos',
                       0ah, 0dh, 'c. Regresar a menu principal',
                       0ah, 0dh, '$'

    msgInsertFunc db "Ingrese funcion a evaluar $"
    msgChargeFileFunc db "Ingrese archivo de carga de funciones $"
    msgInputNotValid db "Entrada no valida $"
    test_info db "Aqui todo bien $"
    
    bufferRoute db 50 dup("$"), 0
    bufferMenuFunc db 50 dup("$"), 0
    bufferOption db 50 dup("$"), 0
    bufferKey db 50 dup("$"), 0
    number1n db ?
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
            cmp bufferRoute[0], 'f'
            je menuFunction
            jmp menu

        menuFunction:
            clearTerminal
            loadMenuFunction
            jmp menu
        
        exitGame:
            mov ax, 4C00H
            INT 21H

    main ENDP
end