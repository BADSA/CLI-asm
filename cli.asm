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
%define sys_creat 8
%define sys_rename 38
%define sys_close 6

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
	
	pregBorrar:			db		10,"Esta seguro que desea eliminar el archivo? s/n",10,"-> "
	lenPregBorrar:		equ		$-pregBorrar
	
	pregRenom:			db		10,"Esta seguro que desea renombrar el archivo? s/n",10,"-> "
	lenPregRenom:		equ		$-pregRenom
	
	;-------------------------------------
	; Variables usadas en la ejecucion.  |
	;-------------------------------------

	;-------------------------------------
	; Archivos txt con matrices de juego.|
	;-------------------------------------
	ayudaMostrarTxt:		db 		"Ayuda/mostrar.ayuda",0
	ayudaBorrarTxt:			db 		"Ayuda/borrar.ayuda",0
	ayudaRenombrarTxt:		db 		"Ayuda/renombrar.ayuda",0
	ayudaCopiarTxt:			db 		"Ayuda/copiar.ayuda",0
	ayudaCompararTxt:		db 		"Ayuda/comparar.ayuda",0
		
	
		
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
	cmp byte[buffer+7] , 10
	je Ayudas
	cmp byte[buffer+7] , ' '
	jne ErrorComando
	cmp byte[buffer+8] , '-'
	mov ebx,9
	je ComprobarAyuda

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
	cmp byte[buffer+6] , 10
	je Ayudas
	cmp byte[buffer+6] , ' '
	jne ErrorComando
	cmp byte[buffer+7] , '-'
	mov ebx,8
	je ComprobarAyuda

	; Lee el nombre del archivo que se quiere borrar.
	.leerNombreArchivo:
		mov ecx, 7
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],10
			je BorrarArchivo
			cmp byte[buffer+ecx],' '
			je PosibleForzado
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 7] , al
			inc ecx
			jmp .ciclo
	
	PosibleForzado:
			call ComprobarForzado
			je NoPreguntaBorrar
		
	
	;--------------------------------
	; Pasos para borrar el archivo. |
	;--------------------------------
	BorrarArchivo:
		; Pregunta si esta seguro que desea borrar.
		mov edx,lenPregBorrar
		mov ecx,pregBorrar
		call DisplayText
		
		; Lee la opcion escogida.
		call LeerComando
		
		cmp byte[buffer],'s'
		jne Continuar
		
		NoPreguntaBorrar:
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
	cmp byte[buffer+9] , 10
	je Ayudas
	cmp byte[buffer+9] , ' '
	jne ErrorComando
	cmp byte[buffer+10] , '-'
	mov ebx,11
	je ComprobarAyuda
	
	; Lee el nombre del archivo que se quiere renombrar.
	leerNombreArchivo1:
		mov ecx, 10
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],' '
			je leerNombreArchivo2
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 10] , al
			inc ecx
			jmp .ciclo

	; Lee el nuevo nombre que se desea poner.
	leerNombreArchivo2:
		inc	ecx
		mov ebx, ecx
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],10
			je RenArchivo
			cmp byte[buffer+ecx],' '
			je PosibleForzado2
			mov al,byte[buffer+ecx]
			push ecx
			sub ecx,ebx
			mov byte[bufferNomArchivo2 + ecx] , al
			pop ecx
			inc ecx
			jmp .ciclo
	
	PosibleForzado2:
		call ComprobarForzado
		je NoPreguntaRen
	
	
	;-----------------------------------		
	; Pasos para renombrar el archivo. |
	;-----------------------------------
	RenArchivo:

		; Pregunta si esta seguro que desea renombrar.
		mov edx,lenPregRenom
		mov ecx,pregRenom
		call DisplayText
		
		; Lee la opcion escogida.
		call LeerComando
		
		cmp byte[buffer],'s'
		jne Continuar
	
		NoPreguntaRen:
			
			; DEBERIA SERVIR PERO NO SIRVE
			mov ebx, bufferNomArchivo             
			mov eax, sys_rename          
			mov ecx, bufferNomArchivo2              
			int 80h                    
			cmp eax, 0
			jle .sucess 	
			
			; Mostrar mensaje de no se pudo completar.
			.fail:
				mov ecx, msg_fail
				mov edx,lenFail
				call DisplayText
				jmp .Done
				
			; Mostrar mensaje de operacion exitosa.	
			.sucess:
				mov ecx,msg_success
				mov edx,lenSuccess
				call DisplayText
			
			; Simular espera por ENTER
			.Done:
				call LeerComando

		jmp Continuar
	
;---------------------------------------
; Se distingue entre Copiar y Comparar |
;---------------------------------------
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
	cmp byte[buffer+6] , 10
	je Ayudas
	cmp byte[buffer+6] , ' '
	jne ErrorComando
	cmp byte[buffer+7] , '-'
	mov ebx,8
	je ComprobarAyuda

	; Lee el nombre del archivo que se quiere copiar.
	_LeerNombreArchivo:
		mov ecx, 7
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],' '
			je _LeerNombreArchivo2
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 7] , al
			inc ecx
			jmp .ciclo
	
	; Lee el nombre que se quiere asignar a la copia.
	_LeerNombreArchivo2:
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
			
			
	;-----------------------------------		
	; Pasos para copiar el archivo.    |
	;-----------------------------------
	CopiarArchivo:
		
		; Intenta copiar el archivo	
		mov ebx, bufferNomArchivo             
		mov eax, sys_link          
		mov ecx, bufferNomArchivo2              
		int 0x80                    
		cmp eax, 0
		jle .sucess               
		
		; Mostrar mensaje de no se pudo completar.
		.fail:
			mov ecx, msg_fail
			mov edx,lenFail
			call DisplayText
			jmp .Done

		; Mostrar mensaje de operacion exitosa.
		.sucess:
			mov ecx,msg_success
			mov edx,lenSuccess
			call DisplayText

		; Espera por ENTER
		.Done:
			call LeerComando
			
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
	cmp byte[buffer+8] , 10
	je Ayudas
	cmp byte[buffer+8] , ' '
	jne ErrorComando
	cmp byte[buffer+9] , '-'
	mov ebx,10
	je ComprobarAyuda
	
	mov ecx,bien
	mov edx,lenBien
	call DisplayText
	call LeerComando
	jmp Continuar
	

;----------------------------------------------
; Verifica las letras restantes para "ayuda". |
;----------------------------------------------
ComprobarAyuda:
	cmp byte[buffer+ebx] , '-'
	jne ErrorComando
	inc ebx
	cmp byte[buffer+ebx] , 'a'
	jne ErrorComando
	inc ebx
	cmp byte[buffer+ebx] , 'y'
	jne ErrorComando
	inc ebx
	cmp byte[buffer+ebx] , 'u'
	jne ErrorComando	
	inc ebx
	cmp byte[buffer+ebx] , 'd'
	jne ErrorComando	
	inc ebx
	cmp byte[buffer+ebx] , 'a'
	jne ErrorComando	

;--------------------------------------------
; Abre el archivo correspondiente de ayuda  |
; segun el comando ingresado.               |
;--------------------------------------------
Ayudas:
	cmp byte[buffer] , 'm'
	je ayudaMostrar
	cmp byte[buffer] , 'b'
	je ayudaBorrar
	cmp byte[buffer] , 'r'
	je ayudaRenombrar
	cmp byte[buffer+2] , 'p'
	je ayudaCopiar

	ayudaComparar:
		; Abre el archivo donde esta la ayuda de comparar.
		mov	ebx, ayudaCompararTxt
		mov	ecx, 0 ; Read only		
		mov	eax, sys_open
		int	80h	
		jmp _chequeaError

	ayudaMostrar:
		; Abre el archivo donde esta la ayuda de mostrar.
		mov	ebx, ayudaMostrarTxt
		mov	ecx, 0 ; Read only		
		mov	eax, sys_open
		int	80h
		jmp _chequeaError

	ayudaBorrar:
		; Abre el archivo donde esta la ayuda de borrar.
		mov	ebx, ayudaBorrarTxt
		mov	ecx, 0 ; Read only		
		mov	eax, sys_open
		int	80h
		jmp _chequeaError

	ayudaRenombrar:
		; Abre el archivo donde esta la ayuda de renombrar.
		mov	ebx, ayudaRenombrarTxt
		mov	ecx, 0 ; Read only		
		mov	eax, sys_open
		int	80h
		jmp _chequeaError
		
	ayudaCopiar:
		; Abre el archivo donde esta la ayuda de copiar.
		mov	ebx, ayudaCopiarTxt
		mov	ecx, 0 ; Read only		
		mov	eax, sys_open
		int	80h
	
			
	; Si ocurrio un error al intentar abrir el archivo brinca a ErrorArchivo.
	_chequeaError:
		test	eax, eax
		js	ErrorArchivo

	; Sino ocurrio error, entonces se lee el archivo en un buffer.
	mov		ebx, eax
	mov		ecx, bufferArchivo
	mov		edx, bufLenArchivo
	mov		eax, sys_read		
	int 	80h
	
	; Se imprime en pantalla el archivo de ayuda.
	mov ecx,bufferArchivo
	mov edx,bufLenArchivo
	call DisplayText
		
	
	; Espera por un ENTER
	call LeerComando
	jmp Continuar

;-------------------------------------------------------------------------
; Comprueba si el argumento "--forzado" fue digitado de manera correcta. |
;-------------------------------------------------------------------------
ComprobarForzado:
	inc ecx
	cmp byte[buffer+ecx],'-'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'-'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'f'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'o'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'r'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'z'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'a'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'d'
	jne Ayudas
	inc ecx
	cmp byte[buffer+ecx],'o'
	jne Ayudas
	ret



	
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
