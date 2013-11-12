; ***********************************************************************
; Tarea Programada CLI													*
; Command Line Interface												*
; Codigo Nasm															*
; Prof. Jaime Gutierrez Alfaro											*
; Arquitectura de computadoras											*
; Instituto Tecnologico de Costa Rica									*
; Daniel Solis Mendez													*
; Melvin Alonso Elizondo Perez											*
; II Semestre / 2013													*
; ***********************************************************************

;--------------------------------------------
; Esto es para hacer el codigo mas legible  |
;--------------------------------------------
sys_exit	equ 1
stdout		equ 1
stdin 		equ 0
sys_read 	equ 3
sys_write 	equ 4
sys_open 	equ 5

%define sys_unlink 10
%define sys_link 9
%define sys_rename 26

SECTION .bss ; Datos no inicializados.
	
	bufLen				equ 	100 ; Longitud del buffer igual a 10 bytes.
	buffer 				resb 	bufLen ; 100 bytes para los comandos del usuario.

	bufLenNomArchivo	equ		50 ; Longitud del buffer 50 bytes.
	bufferNomArchivo	resb	bufLenNomArchivo  ; 50 bytes para guardar los nombres de los archivos
	bufferNomArchivo2	resb	bufLenNomArchivo  ; necesarios para los comandos.
	
	bufLenArchivo		equ		1600 ; Tamano para leer el archivo en memoria.
	bufferArchivo		resb	bufLenArchivo 
	
	
SECTION .data ; Datos inicializados
	;----------------------------------------------------
	; Mensajes usados durante la ejecucion del programa.|
	;----------------------------------------------------

	promptTxt:	 		db		"BADSA > ",0
	len: 				equ 	$-promptTxt
	
	despedidaTxt:		db  	10,'Gracias por usar BADSA CLI! ',10,10
	len3:				equ		$-despedidaTxt
	
	errorArchivoTexto: 	db 		10,"Error: no se pudo encontrar el archivo.", 10, 10
	errorArchivoLen:	equ 	$-errorArchivoTexto
	
	clrScr:				db 		`\33[H\33[2J`
	len9:				equ 	$-clrScr
	
	enter:				db		10,0
	lenEnter:			equ		$-enter	
	
	bien:				db		"bien",10
	lenBien:			equ		$-bien

	errorComando:		db		10, "ERROR:",10,"No existe comando con ese nombre.",10,"ENTER para continuar",10
	lenErrorComando:	equ		$-errorComando
	
	msgBorrando:		db		10,"Borrando el archivo...",10
	lenBorrando:		equ		$-msgBorrando
	
	msg_fail:			db		10,"No se pudo completar la operacion. :[",10
	lenFail:			equ		$-msg_fail
	
	msg_success:		db		10,"Operacion realizada satisfactoriamente :]",10
	lenSuccess:			equ		$-msg_success
	
	pregunta:			db		10,"Esta seguro que desea eliminar el archivo? s/n",10,"-> "
	lenPregunta:		equ		$-pregunta
	
	;-------------------------------------
	; Variables usadas en la ejecucion.  |
	;-------------------------------------

	;-------------------------------------
	; Archivos txt con matrices de juego.|
	;-------------------------------------
	archivoJuegoP:		db 		"pequeno.txt",0
		
	
		
SECTION .text
	global _start
	
_start:
	nop

;------------------------------------------------------------------------------
; Ciclo IngresarComando que se mantiene mientras el usuario no digite "salir" |
;------------------------------------------------------------------------------
IngresarComando:
    ; Limpia la pantalla
    mov ecx,clrScr
    mov edx,len9
    call DisplayText
    
    xor ecx,ecx
    mov cl,'t' ; Se mueve una t de true para indicar que el ciclo continua.
    push ecx ; Se guarda el valor para verificar la continuidad del ciclo.
    
	; Muestra en pantalla el prompt.
	mov ecx, promptTxt
	mov edx, len
	call DisplayText
	
    ; Lee el comando digitado por el usuario.
    mov ecx, buffer
    mov        edx, bufLen
    call ReadText		
	
	; Verificacion de la primera letra para analizar si es un posible comando.
	cmp byte[buffer] , 's'
	je ComprobarSalir
	
	cmp byte[buffer] , 'm'
	je ComprobarMostrar
	
	cmp byte[buffer] , 'b'
	je ComprobarBorrar
	
	cmp byte[buffer] , 'r'
	je ComprobarRenombrar
	
	cmp byte[buffer] , 'c'
	jne ErrorComando
	
	cmp byte[buffer+1] , 'o'
	je ComprobarCopiarOComparar
	jne ErrorComando
	
	Continuar: ; Chequea la variable del ciclo.
		xor ecx,ecx 
		pop ecx
		cmp ecx,'t'
		je IngresarComando
		jne Fin
	
;-------------------------------------------	
; Muestra texto de comando no encontrado.  |
;-------------------------------------------
ErrorComando:
		mov ecx,errorComando
		mov edx,lenErrorComando
		call DisplayText

		; Espera por ENTER para ser presionado.
		call LeerComando
		jmp Continuar
	
;-------------------------------------------------------------------------------------
; Comprueba si "salir" fue digitado y hace lo correspondiente si fue o no ingresado. |
;-------------------------------------------------------------------------------------
ComprobarSalir:
	; Verifica las letras restantes para "salir".
	cmp byte[buffer+1] , 'a'
	jne ErrorComando
	cmp byte[buffer+2] , 'l'
	jne ErrorComando
	cmp byte[buffer+3] , 'i'
	jne ErrorComando
	cmp byte[buffer+4] , 'r'
	jne ErrorComando
	
	; Si la instruccion fue salir se termina el ciclo moviendo una f a cl.
	xor ecx,ecx 
	pop ecx
	mov cl,'f'
	push ecx
	jmp Continuar
	
;---------------------------------------------------------------------------------------
; Comprueba si "mostrar" fue digitado y hace lo correspondiente si fue o no ingresado. |
;---------------------------------------------------------------------------------------
ComprobarMostrar:
	; Verifica las letras restantes para "mostrar".
	cmp byte[buffer+1] , 'o'
	jne ErrorComando
	cmp byte[buffer+2] , 's'
	jne ErrorComando
	cmp byte[buffer+3] , 't'
	jne ErrorComando
	cmp byte[buffer+4] , 'r'
	jne ErrorComando
	cmp byte[buffer+5] , 'a'
	jne ErrorComando
	cmp byte[buffer+6] , 'r'
	jne ErrorComando
	cmp byte[buffer+7] , ' '
	jne ErrorComando

	; Lee el nombre del archivo que se quiere mostrar.
	.leerNombreArchivo:
		mov ecx, 8
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],10
			je AbrirArchivo
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 8] , al
			inc ecx
			jmp .ciclo 

	; Abre el archivo donde esta la matriz del juego.
	AbrirArchivo:
	mov	ebx, bufferNomArchivo
	mov	ecx, 0 ; Read only		
	mov	eax, sys_open
	int	80h
		
	; Si ocurrio un error al intentar abrir el archivo brinca a ErrorArchivo
	ChequeaError:
		test	eax, eax
		js	ErrorArchivo

	; Sino ocurrio error, entonces se lee el archivo en un buffer.
	mov		ebx, eax
	mov		ecx, bufferArchivo
	mov		edx, bufLenArchivo
	mov		eax, sys_read		
	int 	80h
	
	; Se imprime en pantalla el archivo.
	mov ecx,bufferArchivo
	mov edx,bufLenArchivo
	call DisplayText
	
	; Simula la espera por un ENTER.
	call LeerComando
	jmp Continuar	

;---------------------------------------------------------------------------------------
; Comprueba si "borrar" fue digitado y hace lo correspondiente si fue o no ingresado.  |
;---------------------------------------------------------------------------------------
ComprobarBorrar:
	; Verifica las letras restantes para "borrar".
	cmp byte[buffer+1] , 'o'
	jne ErrorComando
	cmp byte[buffer+2] , 'r'
	jne ErrorComando
	cmp byte[buffer+3] , 'r'
	jne ErrorComando
	cmp byte[buffer+4] , 'a'
	jne ErrorComando
	cmp byte[buffer+5] , 'r'
	jne ErrorComando
	cmp byte[buffer+6] , ' '
	jne ErrorComando

	; Lee el nombre del archivo que se quiere borrar.
	.leerNombreArchivo:
		mov ecx, 7
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],10
			je BorrarArchivo
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 7] , al
			inc ecx
			jmp .ciclo
	
	;--------------------------------
	; Pasos para borrar el archivo. |
	;--------------------------------
	BorrarArchivo:
		; Pregunta si esta seguro que desea borrar.
		mov edx,lenPregunta
		mov ecx,pregunta
		call DisplayText
		
		; Lee la opcion escogida.
		call LeerComando
		
		cmp byte[buffer],'s'
		jne Continuar

		; Se dispone a borrar si la opcion fue 's'
		mov edx, lenBorrando
		mov ecx, msgBorrando
		call DisplayText
		
		; Se intenta borrar el archivo.
		mov ebx, bufferNomArchivo
		mov eax, sys_unlink
		int 0x80
		cmp eax, 0
		je .sucess
		
		; Mensaje de no se pudo borrar el archivo.
		.fail:
		mov ecx, msg_fail
		mov edx,lenFail
		call DisplayText
		jmp .Done
		
		; Mensaje de el borrado fue exitoso.
		.sucess:
		mov ecx,msg_success
		mov edx,lenSuccess
		call DisplayText
		
		; Simula la espera de un ENTER.
		.Done:
			call LeerComando
		
		jmp Continuar

;---------------------------------------------------------------------------------------
; Comprueba si "renombrar" fue digitado y hace lo correspondiente si fue o no ingresado. |
;---------------------------------------------------------------------------------------
ComprobarRenombrar:
	; Verifica las letras restantes para "renombrar".
	cmp byte[buffer+1] , 'e'
	jne ErrorComando
	cmp byte[buffer+2] , 'n'
	jne ErrorComando
	cmp byte[buffer+3] , 'o'
	jne ErrorComando
	cmp byte[buffer+4] , 'm'
	jne ErrorComando
	cmp byte[buffer+5] , 'b'
	jne ErrorComando
	cmp byte[buffer+6] , 'r'
	jne ErrorComando
	cmp byte[buffer+7] , 'a'
	jne ErrorComando
	cmp byte[buffer+8] , 'r'
	jne ErrorComando
	cmp byte[buffer+9] , ' '
	jne ErrorComando

	_LeerNombreArchivo:
		mov ecx, 10
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],' '
			je _LeerNombreArchivo2
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 10] , al
			inc ecx
			jmp .ciclo

	_LeerNombreArchivo2:
		inc	ecx
		mov ebx, ecx
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],10
			je RenArchivo
			mov al,byte[buffer+ecx]
			push ecx
			sub ecx,ebx
			mov byte[bufferNomArchivo2 + ecx] , al
			pop ecx
			inc ecx
			jmp .ciclo
			
	RenArchivo:


	mov ebx, bufferNomArchivo             ; File name Root
	mov eax, sys_rename          ; Specify sys_creat call
	mov ecx, bufferNomArchivo2              ; new name
	int 0x80                    ; Make kernel call
	cmp eax, 0
	jle .sucess 	

	.fail:
	mov ecx, msg_fail
	mov edx,lenFail
	call DisplayText
	jmp .Done

	.sucess:
	mov ecx,msg_success
	mov edx,lenSuccess
	call DisplayText

	.Done:
		call EsperaEnter

	jmp Continuar
	
	
ComprobarCopiarOComparar:
	cmp byte[buffer+2] , 'p'
	je ComprobarCopiar
	cmp byte[buffer+2] , 'm'
	je ComprobarComparar
	jne ErrorComando
	jmp Fin


;---------------------------------------------------------------------------------------
; Comprueba si "copiar" fue digitado y hace lo correspondiente si fue o no ingresado.  |
;---------------------------------------------------------------------------------------
ComprobarCopiar:
	; Verifica las letras restantes para "copiar".
	cmp byte[buffer+3] , 'i'
	jne ErrorComando
	cmp byte[buffer+4] , 'a'
	jne ErrorComando
	cmp byte[buffer+5] , 'r'
	jne ErrorComando
	cmp byte[buffer+6] , ' '
	jne ErrorComando

	_LeerNombreArchivo3:
		mov ecx, 7
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],' '
			je _LeerNombreArchivo4
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 7] , al
			inc ecx
			jmp .ciclo

	_LeerNombreArchivo4:
		inc	ecx
		mov ebx, ecx
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],10
			je CopiarArchivo
			mov al,byte[buffer+ecx]
			push ecx
			sub ecx,ebx
			mov byte[bufferNomArchivo2 + ecx] , al
			pop ecx
			inc ecx
			jmp .ciclo
			
	CopiarArchivo:
	
	
	; COPY		
	mov ebx, bufferNomArchivo             ; File name Root
	mov eax, sys_link          ; Specify sys_creat call
	mov ecx, bufferNomArchivo2              ; permission (rwxrwxrwx)
	int 0x80                    ; Make kernel call
	cmp eax, 0
	jle .sucess                   ; IF EAX is less or equal than zero
                                    ; THEN jump to EXIT
	.fail:
	mov ecx, msg_fail
	mov edx,lenFail
	call DisplayText
	jmp .Done

	.sucess:
	mov ecx,msg_success
	mov edx,lenSuccess
	call DisplayText

	.Done:
		call EsperaEnter
	jmp Continuar


;----------------------------------------------------------------------------------------
; Comprueba si "comparar" fue digitado y hace lo correspondiente si fue o no ingresado. |
;----------------------------------------------------------------------------------------
ComprobarComparar:
	; Verifica las letras restantes para "comparar".
	cmp byte[buffer+3] , 'p'
	jne ErrorComando
	cmp byte[buffer+4] , 'a'
	jne ErrorComando
	cmp byte[buffer+5] , 'r'
	jne ErrorComando
	cmp byte[buffer+6] , 'a'
	jne ErrorComando	
	cmp byte[buffer+7] , 'r'
	jne ErrorComando	
	cmp byte[buffer+8] , ' '
	jne ErrorComando
	
	mov ecx,bien
	mov edx,lenBien
	call DisplayText
	jmp Fin	
	
	
;**********************************************************************************************************************
; 												-> RUTINAS INTERMEDIAS <-                                             *
;**********************************************************************************************************************

;-------------------------------------
; Lee el comando digitado en buffer  |
;-------------------------------------	
LeerComando:
	mov ecx, buffer
	mov edx, bufLen
	call ReadText
	ret

;---------------------------------------------------------------------------
; Desplega un mensaje de error notificando que no se pudo abrir el archivo |
; y vuelve al prompt.                                                      |
;---------------------------------------------------------------------------
ErrorArchivo:
	mov     ecx, errorArchivoTexto
	mov		edx, errorArchivoLen
    call    DisplayText
    call LeerComando ; Simula la espera por el presionado de enter.
	jmp Continuar	
	
;--------------------------------------------------------------------
; Desplega algo en la salida estándar. debe "setearse" lo siguiente:|
; ecx: el puntero al mensaje a desplegar.                           |
; edx: el largo del mensaje a desplegar.                            |
; Modifica los registros eax y ebx.                                 |
;--------------------------------------------------------------------
DisplayText:
	mov eax,sys_write
	mov ebx,stdout
	int 80h
	ret
	
;-----------------------------------------------------------------
; Lee algo de la entrada estándar.debe "setearse" lo siguiente:  |
; ecx: el puntero al buffer donde se almacenará.                 |
; edx: el largo del mensaje a leer.	                             |
;-----------------------------------------------------------------
ReadText:
	mov eax,sys_read
	mov ebx,stdin
	int 80h
	ret

;----------------------------------------------------
; Realiza los movimientos de los valores necesarios |
; para finalizar la ejecucion del programa.         |
;----------------------------------------------------
Fin:
	; Muestra en consola un mensaje de salida.
	mov ecx,despedidaTxt
	mov edx,len3
	call DisplayText
	
	mov eax,sys_exit
	mov ebx,0
	int 80h
