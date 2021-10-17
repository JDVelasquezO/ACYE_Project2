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
    
    bufferRoute db 50 dup("$"), 0
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
            jmp menu
    
    exitGame:
        mov ax, 4C00H
        INT 21H

    main ENDP
end