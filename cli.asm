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

; Esto es para hacer el codigo mas legible
sys_exit	equ 1
stdout		equ 1
stdin 		equ 0
sys_read 	equ 3
sys_write 	equ 4
sys_open 	equ 5

SECTION .bss ; Datos no inicializados.
	
	bufLen		equ 	100 ; Longitud del buffer igual a 10 bytes.
	buffer 		resb 	bufLen ; Reservamos 10 bytes para los input de las opciones escogidas.
	
	bufLenJug	equ		50 ; Longitud del buffer 50. 	
	bufferJug1 	resb 	bufLenJug ; \;
	bufferJug2	resb 	bufLenJug ;  | Reservamos 50 bytes para 
	bufferJug3	resb 	bufLenJug ;  | el nombre de cada jugador.
	bufferJug4	resb 	bufLenJug ; /;
	
	bufLenJuego	equ		1413 ; Longitud para el buffer del juego igual a 1413 bytes.
	bufferJuego	resb 	bufLenJuego ; Reservamos bufLenJuego bytes.
	
	simboloJug	resb	1 ; Reservamos 1 byte para el simbolo de cada jugador.  
	
	bufLenArchivo	equ		1600
	bufferArchivo	resb	bufLenArchivo
	
	
SECTION .data ; Datos inicializados
	;----------------------------------------------------
	; Mensajes usados durante la ejecucion del programa.|
	;----------------------------------------------------

	promptTxt:	 		db		"BADSA > ",0
	len: 				equ 	$-promptTxt
	despedidaTxt:		db  	10,'Gracias por usar BADSA CLI! ',10,10
	len3:				equ		$-despedidaTxt
	
	errorArchivoTexto: 	db 		10,"Error: no se pudo leer el archivo del juego.", 10, 10
	errorArchivoLen:	equ 	$-errorArchivoTexto
	
	clrScr:				db 		`\33[H\33[2J`
	len9:				equ 	$-clrScr
	
	enter:				db		10,0
	lenEnter:			equ		$-enter	
	

	;-------------------------------------
	; Variables usadas en la ejecucion.  |
	;-------------------------------------


	
	;-------------------------------------
	; Archivos txt con matrices de juego.|
	;-------------------------------------
	archivoJuegoP:		db 		"pequeno.txt",0
		
	;--------------------------------------
	; Archivo con instrucciones generales.|
	;--------------------------------------
	archivoInstruc:		db		"Instrucciones.txt",0
	
		
SECTION .text
	global _start
	
_start:
	nop
	
IngresarComando:
    ; Limpia la pantalla
    mov ecx,clrScr
    mov edx,len9
    call DisplayText
    
    xor ecx,ecx
    mov cl,'t' ; Se mueve una t de true para indicar que el ciclo continua.
    push ecx ; Se guarda el valor para verificar la continuidad del ciclo.
    
	; Muestra en pantalla el menu principal y sus opciones.
	mov ecx, promptTxt
	mov edx, len
	call DisplayText
	
    ; Lee la opcion digitada por el usuario.
    mov ecx, buffer
    mov        edx, bufLen
    call ReadText
		
		
	; Abre el archivo donde esta la matriz del juego.
	;mov	ebx, archivoJuegoG
	;mov	ecx, 0 ; Read only		
	;mov	eax, sys_open
	;int	80h
		
	;ChequeaError:
		; Si ocurrio un error al intentar abrir el archivo brinca a ErrorArchivo
	;	test	eax, eax
	;	js	ErrorArchivo
	
	; Lee la matriz del juego en un buffer.
	;mov		ebx, eax
	;mov		ecx, bufferJuego
	;mov		edx, bufLenJuego
	;mov		eax, sys_read		
	;int 	80h
	
	cmp byte[buffer] , 'e'
	jne Continuar
	cmp byte[buffer+1] , 'x'
	jne Continuar
	cmp byte[buffer+2] , 'i'
	jne Continuar
	cmp byte[buffer+3] , 't'
	jne Continuar
	
	; Si la instruccion
	xor ecx,ecx 
	pop ecx
	mov cl,'f'
	push ecx
	
	Continuar:
	
	xor ecx,ecx 
	pop ecx
	cmp ecx,'t'
	je IngresarComando
	
	jne Fin
	
				
;******************************************************************************
; 						-> RUTINAS INTERMEDIAS <-                             *
;******************************************************************************
			

Int_to_ascii:					;se mueve el resultado de la suma a numero3
	;mov dword[resultado],0
	.divisiones_sucesivas:

		xor	edx,edx				;limpia el registro;Trae el valor de la direccion de memoria seleccionada[]
		mov ecx,10				
		xor	bx,bx				;limpiar registro para usalrlo como contador de digitos de 16bits

	.division:
		xor	edx,edx 			;limpia el registro edx
		div	ecx					
		push 	dx				;se hace push a dx
		inc 	bx				;se incrementa bx
		test 	eax, eax		;test utiliza un AND para hacer la verificacion
		jnz	.division			;si no es cero repite el proceso

	.acomoda_digitos:
		;mov 	edx,resultado		
		mov 	cx,bx

	.siguente_digito:
		pop ax					;recibe los digitos de la fucion division para realizar la suma
		or al,30h				;se suma 48, numero para convertir de int a ascii
		mov [edx],byte al		;utiliza edx para modificar los valores 
		inc edx						
		loop .siguente_digito	

	.imprime_numero:			;toma el resultado y utiliza el edx como valor para imprmir en pantalla
		push 	bx				
		;mov	ecx,resultado
		xor	edx,edx
		pop	dx
		inc	dx
		inc	dx
	ret

;---------------------------------------------------------------------------
; Desplega un mensaje de error notificando que no se pudo abrir el archivo |
; y finaliza la ejecucion.                                                 |
;---------------------------------------------------------------------------
ErrorArchivo:
	mov     ecx, errorArchivoTexto
	mov		edx, errorArchivoLen
    call    DisplayText
	jmp		Fin	
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
