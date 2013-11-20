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
sys_close	equ	6
sys_creat	equ	8
%define sys_unlink 10
%define sys_link 9
%define sys_rename 38

SECTION .bss ; Datos no inicializados.
	
	bufLen				equ 	100 ; Longitud del buffer igual a 10 bytes.
	buffer 				resb 	bufLen ; 100 bytes para los comandos del usuario.

	bufLenNomArchivo	equ		50 ; Longitud del buffer 50 bytes.
	bufferNomArchivo	resb	bufLenNomArchivo  ; 50 bytes para guardar los nombres de los archivos
	bufferNomArchivo2	resb	bufLenNomArchivo  ; necesarios para los comandos.
	
	bufLenArchivo		equ		3000 ; Tamano para leer el archivo en memoria.
	bufferArchivo		resb	bufLenArchivo 
	
	bufLenArchivo2		equ		3000 ; Tamano para leer el archivo en memoria.
	bufferArchivo2		resb	bufLenArchivo2 
	
	
	
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
	
	errorComando:		db		10, "ERROR:",10,
						db		"Comando no valido.",10
						db		"ENTER para IngresarComando",10
								
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
	
	archivoIgualesTxt:		db		"Los archivos son iguales en contenido",10
	lenArchivoIguales:		equ		$-archivoIgualesTxt
	
	archivoDiferenteTxt:	db		"Los archivos son diferentes en las lineas:",10
	lenArchivoDiferente:	equ		$-archivoDiferenteTxt
	
	archivo1Txt:				db " Hasta este punto el archivo 1 no contiene mas informacion",10
	lenArchivo1Txt:			equ $-archivo1Txt
	
	archivo2Txt:				db " Hasta este punto el archivo 2 no contiene mas informacion",10
	lenArchivo2Txt:			equ $-archivo2Txt
	
	; Borrar first help
	borrarFhTxt:			db	"borrar: falta un fichero como operando",10
							db	"Digite 'borrar --ayuda' para mas informacion.",10
							db		"ENTER para IngresarComando",10
	borrarFhLen:			equ	$-borrarFhTxt

	; Mostrar first help
	mostrarFhTxt:			db	"mostrar: falta un fichero como operando",10
							db	"Digite 'mostrar --ayuda' para mas informacion.",10
							db		"ENTER para IngresarComando",10
	mostrarFhLen:			equ	$-mostrarFhTxt
	
	; Comparar first help
	compararFhTxt:			db	"comparar: faltan dos ficheros como operandos",10
							db	"Digite 'comparar --ayuda' para mas informacion.",10
							db		"ENTER para IngresarComando",10
	compararFhLen:			equ	$-compararFhTxt
	
	; Renombrar first help
	renombrarFhTxt:			db	"renombrar: faltan dos nombres como operando",10
							db	"Digite 'renombrar --ayuda' para mas informacion.",10
							db		"ENTER para IngresarComando",10
	renombrarFhLen:			equ	$-renombrarFhTxt

	; Copiar first help
	copiarFhTxt:			db	"copiar: faltan dos ficheros como operandos",10
							db	"Digite 'copiar --ayuda' para mas informacion.",10
							db		"ENTER para IngresarComando",10
	copiarFhLen:			equ	$-copiarFhTxt
	
	
	; Textos para los logs
	comandoInvalidoTxt:		db	"Comando no valido.",10
	comandoInvalidoLen:		equ $-comandoInvalidoTxt
	textoIngresadoTxt:		db	"Texto ingresado: "
	textoIngresadoLen:		equ	$-textoIngresadoTxt
	enterTxt:				db	10
	enterLen:				equ $-enterTxt
	errorArchNomTxt:	 	db 	"No se pudo encontrar el archivo.",10
	errorArchNomLen:		equ $-errorArchNomTxt
	archivoNombreTxt:		db	"Nombre del archivo: "
	archivoNombreLen:		equ	$-archivoNombreTxt
	
	
	;-------------------------------------
	; Variables usadas en la ejecucion.  |
	;-------------------------------------
	contador: 			db 		1
	cuentaLineas: 		db 		0
	indexBuffer: 		dd 		0
	cantLineas:			dd		0
	resultado:  		times  16 dd 0
	cantCaracteres:		db		0
	tipoError:			dd		0
	numArchivo:			db		0
	
	;--------------------------------------
	; Archivos txt con ayudas de comandos.|
	;--------------------------------------
	ayudaMostrarTxt:		db 		"Ayuda/mostrar.ayuda",0
	ayudaBorrarTxt:			db 		"Ayuda/borrar.ayuda",0
	ayudaRenombrarTxt:		db 		"Ayuda/renombrar.ayuda",0
	ayudaCopiarTxt:			db 		"Ayuda/copiar.ayuda",0
	ayudaCompararTxt:		db 		"Ayuda/comparar.ayuda",0
	archivoLogsTxt:			db		"logs.txt",0
	
		
	
		
SECTION .text
	global _start
	
_start:
	nop

;------------------------------------------------------------------------------
; Ciclo IngresarComando que se mantiene mientras el usuario no digite "salir" |
;------------------------------------------------------------------------------
IngresarComando:

	call LimpiarBuffers
	
    ; Limpia la pantalla
    mov ecx,clrScr
    mov edx,len9
    call DisplayText
    
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

	
;-------------------------------------------	
; Muestra texto de comando no encontrado.  |
;-------------------------------------------
ErrorComando:
	mov ecx,1
	mov dword[tipoError],ecx
	call RegistrarError

	; Muestra texto de error.
	mov ecx,errorComando
	mov edx,lenErrorComando
	call DisplayText

	; Espera por ENTER para ser presionado.
	call LeerComando	
	
	jmp IngresarComando
	
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
	cmp byte[buffer+5] , 10
	je Sale
	cmp byte[buffer+5] ,' '
	jne ErrorComando
	
	Sale:
	; Si la instruccion fue salir se termina el ciclo moviendo una f a cl.
	jmp Fin
	
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
	je PrimeraAyuda
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

	; Abre el archivo que se quiere mostrar
	AbrirArchivo:
		mov	ebx, bufferNomArchivo
		mov	ecx, 0 ; Read only		
		mov	eax, sys_open
		int	80h
		
	; Si ocurrio un error al intentar abrir el archivo brinca a ErrorArchivo
	ChequeaError:
		mov dword[numArchivo],1
		test	eax, eax
		js	ErrorArchivo

	; Sino ocurrio error, entonces se lee el archivo en un buffer.
	push eax
	mov		ebx, eax
	mov		ecx, bufferArchivo
	mov		edx, bufLenArchivo
	mov		eax, sys_read		
	int 	80h

	pop ebx
	call CerrarArchivo
	
	; Se imprime en pantalla el archivo.
	mov ecx,bufferArchivo
	mov edx,bufLenArchivo
	call DisplayText
	
	; Simula la espera por un ENTER.
	call LeerComando
	jmp IngresarComando	

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
	je PrimeraAyuda
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
	
	; Llama a la funcion ComprobarForzado para analizar si el parametro fue escrito.
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
		jne IngresarComando
		
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
				mov dword[numArchivo],1
				call RegistrarError
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
		
		jmp IngresarComando

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
	je PrimeraAyuda
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
		jne IngresarComando
	
		NoPreguntaRen:
			
			; Renombrar archivo
			mov ebx, bufferNomArchivo             
			mov eax, sys_rename          
			mov ecx, bufferNomArchivo2              
			int 80h                    
			cmp eax, 0
			jle .sucess 	
			
			; Mostrar mensaje de no se pudo completar.
			.fail:
				mov dword[numArchivo],1
				call RegistrarError
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

		jmp IngresarComando
	
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
	je PrimeraAyuda
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
			mov dword[numArchivo],1
			call RegistrarError
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
			
		jmp IngresarComando


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
	je PrimeraAyuda
	cmp byte[buffer+8] , ' '
	jne ErrorComando
	cmp byte[buffer+9] , '-'
	mov ebx,10
	je ComprobarAyuda
	
	; Lee el nombre del archivo que se quiere renombrar.
	leerNombreArchivoCmp1:
		mov ecx, 9
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],' '
			je leerNombreArchivoCmp2
			mov al,byte[buffer+ecx]
			mov byte[bufferNomArchivo + ecx - 9] , al
			inc ecx
			jmp .ciclo

	; Lee el nuevo nombre que se desea poner.
	leerNombreArchivoCmp2:
		inc	ecx
		mov ebx, ecx
		xor eax,eax
		.ciclo:
			cmp byte[buffer+ecx],10
			je CompArchivos
			mov al,byte[buffer+ecx]
			push ecx
			sub ecx,ebx
			mov byte[bufferNomArchivo2 + ecx] , al
			pop ecx
			inc ecx
			jmp .ciclo
		

CompArchivos:
	.AbrirArchivo:
	mov	ebx, bufferNomArchivo
	mov	ecx, 0 ; Read only		
	mov	eax, sys_open
	int	80h
		
	; Si ocurrio un error al intentar abrir el archivo brinca a ErrorArchivo
	.ChequeaError:
		mov dword[numArchivo],1
		test	eax, eax
		js	ErrorArchivo

	; Sino ocurrio error, entonces se lee el archivo en un buffer.
	mov		ebx, eax
	mov		ecx, bufferArchivo
	mov		edx, bufLenArchivo
	mov		eax, sys_read		
	int 	80h
	
	; Abre el archivo #2
	mov	ebx, bufferNomArchivo2
	mov	ecx, 0 ; Read only		
	mov	eax, sys_open
	int	80h
		
	; Si ocurrio un error al intentar abrir el archivo brinca a ErrorArchivo
	.ChequeaError2:
		mov dword[numArchivo],0
		test	eax, eax
		js	ErrorArchivo

	; Sino ocurrio error, entonces se lee el archivo en un buffer.
	mov		ebx, eax
	mov		ecx, bufferArchivo2
	mov		edx, bufLenArchivo2
	mov		eax, sys_read		
	int 	80h
	
	mov byte[contador],1
	xor ecx,ecx
	xor eax,eax
	xor ebx,ebx
	xor edx,edx

;----------------------------------------------------------------------------		
;	Ciclo principal en la etapa de comparar las lineas de los archivos  	|	
;----------------------------------------------------------------------------

	.comparar:
		mov dl,byte[bufferArchivo+ecx]
		mov bl,byte[bufferArchivo2+eax]
		cmp dl,0
		je .termina1
		cmp bl,0
		je .termina2
		cmp dl,bl
		jne .agregarMensajeLinea
		cmp bl,10
		je .continuaArchivo1
		cmp dl,10
		je .continuaArchivo2
		cmp dl,bl
		je .continua

;ciclo mueve el ecx al proximo enter, siendo ecx el indice del buffer con
;la informacion del archivo
;recorriendo la linea hasta el final para IngresarComando
;al terminar binca a la parte donde se aumenta el contador de lineas
			
	.continuaArchivo1:
		mov dl,byte[bufferArchivo+ecx]
		cmp edx,0
		je .termina1
		cmp edx,10
		je .aumentarLinea
		inc ecx
		jmp .continuaArchivo1

;ciclo mueve el eax al proximo enter, siendo ecx el indice del buffer con
;la informacion del archivo numero 2
;recorriendo la linea hasta el final para IngresarComando
;al terminar binca a la parte donde se aumenta el contador de lineas
	.continuaArchivo2:
		mov bl,byte[bufferArchivo2+eax]
		cmp ebx,0
		je .termina2
		cmp ebx,10
		je .aumentarLinea
		inc eax
		jmp .continuaArchivo2

;Funciones auxiliares de la funcion agregar linea;
;cuando se imprime en cual linea de los archivos hay diferencias,
;entonces se recorren los dos archivos hasta el enter mas cercano
;incrementando el eax y ecx que son los indices para moverse por 
;los diferentes archivos
;NOTA: Comentario para Auxiliar 2 tambien.
		
	.continuaArchivo1Aux:
		mov dl,byte[bufferArchivo+ecx]
		cmp dl,0
		je .termina1
		cmp dl,10
		je .continuaArchivo2Aux
		inc ecx
		jmp .continuaArchivo1Aux
	
	.continuaArchivo2Aux:
		mov bl,byte[bufferArchivo2+eax]
		cmp bl,0
		je .termina2
		cmp bl,10
		je .aumentarLinea
		inc eax
		jmp .continuaArchivo2Aux

;Fucion que incrementa los indices de los archivos
;se le delega este paso a una sola funcion ya que es necesario
;utilizarla desde diferentes funciones dentro de la Funcionalidad del
;comando comparar
;Se retorna al ciclo principal para seguir comparando

	.continua:
		inc ecx
		inc eax
		jmp .comparar
		
;ciclo para aumentar el contador de lineas
;Lleva la cuneta de la linea actual en proceso
;se incrementa cada vez que los archivos juntos salten de linea

	.aumentarLinea:
		xor edx,edx
		mov edx,dword[contador]
		inc edx
		mov dword[contador],edx
		jmp .continua

;Etiqueta para agregar msj cuando los archivos son diferentes
;si se ah puesto el msj lo pone y si ya esta puesto entonces continau
;a agregar la linea donde se dio el cambio
		
	.agregarMensajeLinea:
		push eax
		push ecx
		mov al,byte[cantLineas]
		cmp al,1
		je .agregarLinea
		
		mov ecx,archivoDiferenteTxt
		mov edx,lenArchivoDiferente
		call DisplayText
		
		jmp .agregarLinea

;se muestra en pantalla la linea donde se genero el cambio entre los archivos
		
	.agregarLinea:
		mov byte[cantLineas],1
		mov eax,dword[contador]
		call Int_to_ascii
		call DisplayText
		pop ecx
		pop eax
		jmp .continuaArchivo1Aux
		
	.termina1:
		mov al,byte[cantLineas]
		cmp al,1
		je .msjArchivo2
		cmp bl,0
		je .finIgual
	
	.msjArchivo1:
		mov ecx,archivo2Txt
		mov edx,lenArchivo2Txt
		call DisplayText
		jmp .fin
		
	.termina2:
		mov al,byte[cantLineas]
		cmp al,1
		je .msjArchivo1
		cmp dl,0
		je .finIgual
	
	.msjArchivo2:
		mov ecx,archivo1Txt
		mov edx,lenArchivo1Txt
		call DisplayText
		
		jmp .fin
		
	.finIgual:		
		mov edx,lenArchivoIguales
		mov ecx,archivoIgualesTxt
		call DisplayText
		call ReadText
		jmp IngresarComando
	
	.fin:
		call ReadText
		jmp IngresarComando
	
;-----------------------------------------------------
; Verifica cual texto de primera ayuda debe mostrar. |
;-----------------------------------------------------
PrimeraAyuda:
	cmp byte[buffer] , 'm'
	je PriAyudaMostrar
	cmp byte[buffer] , 'b'
	je PriAyudaBorrar
	cmp byte[buffer] , 'r'
	je PriAyudaRenombrar
	cmp byte[buffer+2] , 'p'
	je PriAyudaCopiar
	
	PriAyudaComparar:
		mov ecx, compararFhTxt
		mov edx, compararFhLen
		jmp ImprimeFh
	
	PriAyudaMostrar:
		mov ecx, mostrarFhTxt
		mov edx, mostrarFhLen
		jmp ImprimeFh
	
	PriAyudaBorrar:
		mov ecx, borrarFhTxt
		mov edx, borrarFhLen
		jmp ImprimeFh
	 
	PriAyudaCopiar:
		mov ecx, copiarFhTxt
		mov edx, copiarFhLen
		jmp ImprimeFh
	
	PriAyudaRenombrar:
		mov ecx, renombrarFhTxt
		mov edx, renombrarFhLen

	ImprimeFh:
	; Se imprime en pantalla el texto de primer ayuda.
	call DisplayText
	
	; Espera por un ENTER
	call LeerComando
	jmp IngresarComando


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
	jmp IngresarComando

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

LimpiaBufferComando:
	mov ecx,0
	ciclo1:
		cmp byte[buffer+ecx],0
		je l2
		mov byte[buffer+ecx],0
		inc ecx
		jmp ciclo1
	l2:
		ret

LimpiaBufferNoms:
	mov ecx,0
	ciclo2:
		cmp byte[bufferNomArchivo+ecx],0
		je l3
		mov byte[bufferNomArchivo+ecx],0
		inc ecx
		jmp ciclo2		
	
	l3:
	mov ecx,0
	ciclo3:
		cmp byte[bufferNomArchivo2+ecx],0
		je l4
		mov byte[bufferNomArchivo2+ecx],0
		inc ecx
		jmp ciclo3	
		
	l4:
		ret
		
LimpiaBufferArchivo:
	mov ecx,0
	ciclo4:
		cmp byte[bufferArchivo+ecx],0
		je LimpiezaTerminada
		mov byte[bufferArchivo+ecx],0
		inc ecx
		jmp ciclo4
				
	LimpiezaTerminada:
		ret
		
;-----------------------------------------
; Ciclos para limpiar los buffer usados. |
;-----------------------------------------
LimpiarBuffers:
	call LimpiaBufferComando
	call LimpiaBufferNoms
	call LimpiaBufferArchivo
	ret
	

;----------------------------------------------------
; Subrutina para registrar cuando ocurre un error.  |
;----------------------------------------------------
RegistrarError:	
	
	; Abre el archivo que se quiere mostrar
	_AbrirArchivo:
		mov	ebx, archivoLogsTxt
		mov	ecx, 2 
		mov	eax, sys_open
		int	80h
		
	; Si ocurrio un error al intentar abrir el archivo brinca a ErrorArchivo
	_ChequeaError:
		test	eax, eax
		jns	AbrirEnAppend
		
	CrearArchivo:
		mov eax,sys_creat
		mov ebx,archivoLogsTxt
		mov ecx,511
		int 80h
		
	; Se cierra
	mov ebx,eax
	call CerrarArchivo
	
		
	AbrirEnAppend:
	; Abrir archivo de logs
	mov eax, sys_open
	mov ebx, archivoLogsTxt
	mov ecx, 0x401 ; Abrirlo en modo append.
	int 80h

	revisaError:
		test	eax, eax
		js	ErrorArchivo
		
	; Distinguir el tipo de error que fue
	; 1 Comando invalido
	; 0 Archivo no existente
	cmp dword[tipoError],1
	jne errorArchivo
	
	errorComandoInvalido: 
		; Cuenta cantidad de caracteres que se deben escribir
		mov ecx,0
		sigPos:
			cmp byte[buffer + ecx],0
			je gotCantidadCaracteres
			inc ecx
			jmp sigPos
		
		gotCantidadCaracteres:
			mov dword[cantCaracteres],ecx
		
		; Escribir justificacion del log.
		push eax ; guardar file descriptor
		mov ebx, eax
		mov eax, sys_write
		mov ecx, comandoInvalidoTxt
		mov edx,comandoInvalidoLen
		int 80h
		
		; Escribe "texto ingresado" en los logs.
		pop ebx ; sacar file descriptor
		push ebx ; guardar file descriptor
		mov eax, sys_write
		mov ecx,textoIngresadoTxt
		mov edx,textoIngresadoLen
		int 80h 
		
		; Escribir en el archivo de logs
		pop ebx ; sacar file descriptor
		push ebx ; guardar file descriptor
		mov eax, sys_write
		mov ecx, buffer
		mov edx, [cantCaracteres]
		int 80h
		
		jmp FinRegistraError
		
	
	errorArchivo:
		; Escribir justificacion del log.
		push eax ; guardar file descriptor
		mov ebx, eax
		mov eax, sys_write
		mov ecx, errorArchNomTxt
		mov edx, errorArchNomLen
		int 80h	

		; Escribir en el archivo de logs "Nombre del archivo:"
		pop ebx ; sacar file descriptor
		push ebx ; guardar file descriptor
		mov eax, sys_write
		mov ecx, archivoNombreTxt
		mov edx, archivoNombreLen
		int 80h
		
		mov ecx, dword[numArchivo]
		SeeEcx:
		cmp dword[numArchivo],1	
		je A1
		A2:
					
			; Leer cantidad de caracteres del nombre2
			mov ecx,0
			_sigPos:
				cmp byte[bufferNomArchivo2 + ecx],0
				je _gotCantidadCaracteres
				inc ecx
				jmp _sigPos
			
			_gotCantidadCaracteres:
				mov dword[cantCaracteres],ecx		
			
			 ;Escribir nombre del archivo invalido
			pop ebx ; sacar file descriptor
			push ebx ; guardar file descriptor
			mov eax, sys_write
			mov ecx, bufferNomArchivo2
			mov edx, [cantCaracteres]
			int 80h			

			; Guardar enter entre cada registro
			pop ebx
			push ebx
			mov eax, sys_write
			mov ecx, enterTxt
			mov edx, enterLen
			int 80h	

			jmp FinRegistraError
		A1:	
			; Leer cantidad de caracteres del nombre1
			mov ecx,0
			_sigPos2:
				cmp byte[bufferNomArchivo + ecx],0
				je _gotCantidadCaracteres2
				inc ecx
				jmp _sigPos2
			
			_gotCantidadCaracteres2:
				mov dword[cantCaracteres],ecx
				
			; Escribir nombre del archivo invalido
			pop ebx ; sacar file descriptor
			push ebx ; guardar file descriptor
			mov eax, sys_write
			mov ecx, bufferNomArchivo
			mov edx, [cantCaracteres]
			int 80h		

			; Guardar enter entre cada registro
			pop ebx
			push ebx
			mov eax, sys_write
			mov ecx, enterTxt
			mov edx, enterLen
			int 80h	
			
	FinRegistraError:
	
		; Guardar enter entre cada registro
		pop ebx
		push ebx
		mov eax, sys_write
		mov ecx, enterTxt
		mov edx, enterLen
		int 80h		
		
		;Cerramos el archivo
		pop ebx ; sacar file descriptor
		call CerrarArchivo	
		
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
	call RegistrarError
	
	; Muestra en pantalla texto de error de archivo
	mov     ecx, errorArchivoTexto
	mov		edx, errorArchivoLen
    call    DisplayText
    
    call LeerComando ; Simula la espera por el presionado de enter.
    
	jmp IngresarComando	

;-----------------------------------
; Subrutina para cerrar un archivo |
;-----------------------------------
CerrarArchivo:
	mov eax, sys_close
	int 80h 
	ret
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

;------------------------------------------------------
; Convierte de entero a ascii y imprime en consola    |
;------------------------------------------------------
Int_to_ascii:					;se mueve el resultado de la suma a numero3
	mov dword[resultado],0
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
		mov 	edx,resultado		
		mov 	cx,bx

	.siguente_digito:
		pop ax					;recibe los digitos de la fucion division para realizar la suma
		or al,30h				;se suma 48, numero para convertir de int a ascii
		mov [edx],byte al		;utiliza edx para modificar los valores 
		inc edx						
		loop .siguente_digito	
	
	.agrega_cambiodelinea:
	mov [edx],byte 0ah

	.imprime_numero:			;toma el resultado y utiliza el edx como valor para imprmir en pantalla
		push bx				
		mov	ecx,resultado
		xor	edx,edx
		pop	dx
		inc	dx
		inc	dx
	ret
	
