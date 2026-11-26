;*********************************************************
; ALTAMIRANO MURILLO AXEL GABRIEL
; Guardar como: Login.asm
; Pantalla: Acceso al sistema (LCD). Lee usuarios.txt y escribe login_out.txt.
; Programa independiente: se compila a Login.exe (emu8086).
; Necesita Biblioteca.txt, Dispositivos.asm y Dispositivos_Datos.asm en la misma carpeta.
; Codigo de salida: 0 entro, 1 salio con ESC, 3 acceso bloqueado.
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?          ; handle de archivo (lo usa la biblioteca)
    RutaRaiz          DB "C:\AutonoLux",0
    RutaAxel          DB "C:\AutonoLux\Axel",0
    RutaUsuarios      DB "C:\AutonoLux\Axel\usuarios.txt",0
    RutaLoginSalida   DB "C:\AutonoLux\Axel\login_out.txt",0

; ---- Estado del acceso
IntentosRestantes DB 3
MostrarError      DB 0          ; 1 = mostrar el aviso de clave incorrecta
LoginCorrecto     DB 0          ; 1 = usuario y clave coinciden
CodigoSalida      DB 1          ; 0 entro, 1 ESC, 3 bloqueado
ErrorDeArchivo    DB 0          ; 1 = no se pudo crear usuarios.txt
TextosIguales     DB 0          ; resultado de CompararTextos
LongitudUsuario   DB 0
LongitudClave     DB 0

; ---- Captura tecla por tecla (la clave se muestra con *)
CapturaCantidad   DB 0          ; caracteres capturados
CapturaMaximo     DB 0
CapturaEco        DB 0          ; caracter de eco (0 = el mismo que se teclea)
CapturaMayusculas DB 0          ; 1 = convertir minusculas a mayusculas
CapturaRenglon    DB 0
CapturaColumna    DB 0
CapturaCaracter   DB 0
CapturaTecla      DB 0          ; tecla con la que termino: 13 ENTER, 27 ESC
UsuarioCapturado  DB "     "
ClaveCapturada    DB "    "

; ---- usuarios.txt ("USUARIO,CLAVE") y su lectura
UsuarioPorDefecto DB "ADMIN,1234"
BufferUsuarios    DB 10 DUP(?)

; ---- login_out.txt: OK,USUARIO / ESC / BLOQUEADO
TextoResultadoAcceso   DB "OK,"
TextoResultadoEscape   DB "ESC"
TextoResultadoBloqueo  DB "BLOQUEADO"
FinDeLinea        DB 13,10

; ---- LCD (16 caracteres por linea, terminan en 0)
LcdBienvenidoA    DB "Bienvenido "
LcdNombreUsuario  DB "     ",0
LcdTextoIntento   DB "Intento "
LcdNumeroIntento  DB "2"
                  DB " de 3",0

; ---- Textos cortos y mensajes (74 caracteres cada mensaje)
TextoIntentos     DB "3"
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"
MensajeError      DB "   Usuario o clave incorrectos. Verifique e intente de nuevo.             "
MensajeBloqueo    DB "   Acceso bloqueado: 3 intentos fallidos. Presione una tecla para salir.  "
MensajeBienvenida DB "   Acceso concedido. Presione una tecla para continuar.                   "

; ---- Renglones comunes (banner AUTONOLUX) y propios de la pantalla
LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"
LoginRen07         DB "|   ACCESO AL SISTEMA        Deteccion y control de iluminacion            |"
LoginRen08         DB "|--------------------------------------------------------------------------|"
LoginRen09         DB "|                                                                          |"
LoginRen10         DB "|                     Acceso solo personal autorizado                      |"
LoginRen11         DB "|                                                                          |"
LoginRen12         DB "|                 Usuario : _____                                          |"
LoginRen13         DB "|                                                                          |"
LoginRen14         DB "|                 Clave   : ____                                           |"
LoginRen15         DB "|                                                                          |"
LoginRen16         DB "|                 Intentos restantes: 3                                    |"
LoginRen17         DB "|                                                                          |"
LoginRen18         DB "|              [ENTER] INGRESAR              [ESC] SALIR                   |"
LoginRen19         DB "|                                                                          |"
LoginRen20         DB "|                                                                          |"
LoginRen21         DB "|--------------------------------------------------------------------------|"
LoginRen22         DB "|  Instituto Tecnologico de Tepic                Lenguajes de Interfaz 2026|"

; ---- Datos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos_Datos.asm

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaAxel
    CALL ControlLogin
Fin:
    MOV AH,4Ch                  ; termina con el codigo de salida
    MOV AL,CodigoSalida
    INT 21H

;==================== ACCESO AL SISTEMA ====================

; Tres intentos. ENTER acepta cada campo, ESC sale
ControlLogin PROC
    CALL CrearUsuariosBase
    CMP ErrorDeArchivo,1
    JE LoginSinArchivo
    CALL MostrarLcdInicio
LoginPantalla:
    CALL DibujarLogin
    CALL PintarEstadoLogin
    CALL PedirUsuario
    CMP CapturaTecla,27         ; ESC
    JE LoginEscape
    CALL PedirClave
    CMP CapturaTecla,27
    JE LoginEscape
    CALL ValidarCredenciales
    CMP LoginCorrecto,1
    JE LoginAcepta
    CALL RegistrarIntentoFallido
    CMP IntentosRestantes,0
    JNE LoginPantalla
    MOV CodigoSalida,3          ; tercer intento fallido
    JMP LoginGuardarResultado
LoginAcepta:
    MOV CodigoSalida,0
    CALL MostrarBienvenida
    JMP LoginGuardarResultado
LoginEscape:
    MOV CodigoSalida,1
LoginGuardarResultado:
    CALL EscribirResultadoLogin
LoginSinArchivo:
    RET
ControlLogin ENDP

; Si usuarios.txt no existe lo crea con el usuario por defecto
CrearUsuariosBase PROC
    MOV ErrorDeArchivo,0
    ABRIR_ARCHIVO RutaUsuarios,0
    JC UsuariosNoExiste
    CERRAR_ARCHIVO ID
    RET
UsuariosNoExiste:
    CREAR_ARCHIVO RutaUsuarios,32
    MOV ID,AX
    JC ErrorAlCrearUsuarios
    ESCRIBIR_ARCHIVO ID,10,UsuarioPorDefecto
    CERRAR_ARCHIVO ID
    RET
ErrorAlCrearUsuarios:
    MOV ErrorDeArchivo,1
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
CrearUsuariosBase ENDP

; Dibuja la pantalla de acceso (renglones fijos)
DibujarLogin PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR LineaMarco,76,0,0,0,0,1Bh
    IMPCAD_COLOR Logo1,76,1,0,0,0,1Eh
    IMPCAD_COLOR Logo2,76,2,0,0,0,1Eh
    IMPCAD_COLOR Logo3,76,3,0,0,0,1Eh
    IMPCAD_COLOR Logo4,76,4,0,0,0,1Eh
    IMPCAD_COLOR Logo5,76,5,0,0,0,1Eh
    IMPCAD_COLOR LineaMarco,76,6,0,0,0,1Bh
    IMPCAD_COLOR LoginRen07,76,7,0,0,0,1Fh
    IMPCAD_COLOR LoginRen08,76,8,0,0,0,17h
    IMPCAD_COLOR LoginRen09,76,9,0,0,0,1Fh
    IMPCAD_COLOR LoginRen10,76,10,0,0,0,1Eh
    IMPCAD_COLOR LoginRen11,76,11,0,0,0,1Fh
    IMPCAD_COLOR LoginRen12,76,12,0,0,0,1Fh
    IMPCAD_COLOR LoginRen13,76,13,0,0,0,1Fh
    IMPCAD_COLOR LoginRen14,76,14,0,0,0,1Fh
    IMPCAD_COLOR LoginRen15,76,15,0,0,0,1Fh
    IMPCAD_COLOR LoginRen16,76,16,0,0,0,1Fh
    IMPCAD_COLOR LoginRen17,76,17,0,0,0,1Fh
    IMPCAD_COLOR LoginRen18,76,18,0,0,0,1Bh
    IMPCAD_COLOR LoginRen19,76,19,0,0,0,1Fh
    IMPCAD_COLOR LoginRen20,76,20,0,0,0,1Fh
    IMPCAD_COLOR LoginRen21,76,21,0,0,0,17h
    IMPCAD_COLOR LoginRen22,76,22,0,0,0,1Fh
    IMPCAD_COLOR LineaMarco,76,23,0,0,0,1Bh
    RET
DibujarLogin ENDP

; Escribe los intentos que quedan y, si hace falta, el aviso de error
PintarEstadoLogin PROC
    MOV AL,IntentosRestantes
    ADD AL,'0'                  ; numero pasa a caracter
    MOV TextoIntentos,AL
    IMPCAD_COLOR TextoIntentos,1,16,38,0,0,1Fh
    CMP MostrarError,1
    JNE FinPintarEstadoLogin
    IMPCAD_COLOR MensajeError,74,20,1,0,0,1Eh
FinPintarEstadoLogin:
    RET
PintarEstadoLogin ENDP

;==================== CAPTURA ====================

; Usuario: 5 letras o numeros, se pasan a mayusculas
PedirUsuario PROC
    LEA SI,UsuarioCapturado
    MOV CapturaMaximo,5
    MOV CapturaEco,0
    MOV CapturaMayusculas,1
    MOV CapturaRenglon,12
    MOV CapturaColumna,28
    CALL CapturarTexto
    MOV AL,CapturaCantidad
    MOV LongitudUsuario,AL
    RET
PedirUsuario ENDP

; Clave: 4 caracteres, se muestran como *
PedirClave PROC
    LEA SI,ClaveCapturada
    MOV CapturaMaximo,4
    MOV CapturaEco,'*'
    MOV CapturaMayusculas,0
    MOV CapturaRenglon,14
    MOV CapturaColumna,28
    CALL CapturarTexto
    MOV AL,CapturaCantidad
    MOV LongitudClave,AL
    RET
PedirClave ENDP

; Captura tecla por tecla en [SI] hasta ENTER o ESC (RETROCESO borra)
CapturarTexto PROC
    MOV CapturaCantidad,0
CapturarSiguiente:
    CURSOR CapturaRenglon,CapturaColumna,0
    RASTREO
    CMP AL,13                   ; ENTER
    JE CapturaTermina
    CMP AL,27                   ; ESC
    JE CapturaTermina
    CMP AL,8                    ; RETROCESO
    JE CapturaBorrar
    CMP AL,32
    JC CapturarSiguiente        ; teclas de control: se ignoran
    MOV AH,CapturaCantidad
    CMP AH,CapturaMaximo
    JE CapturarSiguiente        ; ya esta lleno
    CALL AceptarCaracter
    JMP CapturarSiguiente
CapturaBorrar:
    CMP CapturaCantidad,0
    JE CapturarSiguiente
    CALL BorrarCaracter
    JMP CapturarSiguiente
CapturaTermina:
    MOV CapturaTecla,AL
    RET
CapturarTexto ENDP

; Guarda el caracter de AL en [SI] y lo pinta (o pinta el eco)
AceptarCaracter PROC
    CMP CapturaMayusculas,1
    JNE AceptarGuardar
    CMP AL,'a'
    JC AceptarGuardar           ; menor que 'a'
    CMP AL,'{'
    JNC AceptarGuardar          ; '{' o mayor
    SUB AL,32                   ; minuscula pasa a mayuscula
AceptarGuardar:
    MOV [SI],AL
    ADD SI,1
    CMP CapturaEco,0
    JE AceptarPintar
    MOV AL,CapturaEco
AceptarPintar:
    MOV CapturaCaracter,AL
    CURSOR CapturaRenglon,CapturaColumna,0
    ESCRIBIR_CARCOLOR 1,CapturaCaracter,1Fh
    ADD CapturaColumna,1
    ADD CapturaCantidad,1
    RET
AceptarCaracter ENDP

; Quita el ultimo caracter capturado y vuelve a pintar el guion bajo
BorrarCaracter PROC
    SUB SI,1
    SUB CapturaCantidad,1
    SUB CapturaColumna,1
    MOV CapturaCaracter,'_'
    CURSOR CapturaRenglon,CapturaColumna,0
    ESCRIBIR_CARCOLOR 1,CapturaCaracter,1Fh
    RET
BorrarCaracter ENDP

;==================== VALIDACION ====================

; Lee usuarios.txt ("ADMIN,1234") y compara usuario y clave capturados
ValidarCredenciales PROC
    MOV LoginCorrecto,0
    CMP LongitudUsuario,5
    JNE FinValidar
    CMP LongitudClave,4
    JNE FinValidar
    ABRIR_ARCHIVO RutaUsuarios,0
    JC FinValidar
    LEER_ARCHIVO 10,BufferUsuarios,ID
    CERRAR_ARCHIVO ID
    LEA SI,UsuarioCapturado
    LEA DI,BufferUsuarios
    MOV CX,5
    CALL CompararTextos
    CMP TextosIguales,1
    JNE FinValidar
    LEA SI,ClaveCapturada
    LEA DI,BufferUsuarios
    ADD DI,6                    ; la clave empieza despues de la coma
    MOV CX,4
    CALL CompararTextos
    CMP TextosIguales,1
    JNE FinValidar
    MOV LoginCorrecto,1
FinValidar:
    RET
ValidarCredenciales ENDP

; Compara CX bytes de [SI] contra [DI]. Salida: TextosIguales = 1 si son iguales
CompararTextos PROC
    MOV TextosIguales,1
CompararSiguiente:
    MOV AL,[SI]
    CMP AL,[DI]
    JE CompararLetraIgual
    MOV TextosIguales,0
CompararLetraIgual:
    ADD SI,1
    ADD DI,1
    SUB CX,1
    CMP CX,0
    JNE CompararSiguiente
    RET
CompararTextos ENDP

; Resta un intento. Con 0 intentos muestra el bloqueo, si no el intento siguiente
RegistrarIntentoFallido PROC
    SUB IntentosRestantes,1
    MOV MostrarError,1
    CMP IntentosRestantes,0
    JNE QuedanIntentos
    CALL MostrarLcdBloqueo
    IMPCAD_COLOR MensajeBloqueo,74,20,1,0,0,1Eh
    RASTREO
    RET
QuedanIntentos:
    CALL MostrarLcdIntento
    RET
RegistrarIntentoFallido ENDP

; Acceso concedido: LCD con el nombre y mensaje en pantalla
MostrarBienvenida PROC
    CALL CopiarUsuarioAlLcd
    CALL MostrarLcdBienvenida
    IMPCAD_COLOR MensajeBienvenida,74,20,1,0,0,1Ah
    RASTREO
    RET
MostrarBienvenida ENDP

; Escribe en login_out.txt el resultado: OK,USUARIO / ESC / BLOQUEADO
EscribirResultadoLogin PROC
    CREAR_ARCHIVO RutaLoginSalida,32
    MOV ID,AX
    JC ErrorResultadoLogin
    CMP CodigoSalida,0
    JE ResultadoAcceso
    CMP CodigoSalida,1
    JE ResultadoEscape
    ESCRIBIR_ARCHIVO ID,9,TextoResultadoBloqueo
    JMP ResultadoFin
ResultadoAcceso:
    ESCRIBIR_ARCHIVO ID,3,TextoResultadoAcceso
    ESCRIBIR_ARCHIVO ID,5,UsuarioCapturado
    JMP ResultadoFin
ResultadoEscape:
    ESCRIBIR_ARCHIVO ID,3,TextoResultadoEscape
ResultadoFin:
    ESCRIBIR_ARCHIVO ID,2,FinDeLinea
    CERRAR_ARCHIVO ID
    RET
ErrorResultadoLogin:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
EscribirResultadoLogin ENDP

;==================== LCD (mensajes al operador) ====================

; LCD al arrancar: AUTONOLUX
MostrarLcdInicio PROC
    CALL LimpiarLcd
    MOV DX,2040h                ; linea 1
    LEA SI,LcdTitulo
    CALL EscribirLcd
    RET
MostrarLcdInicio ENDP

; LCD: Bienvenido USUARIO
MostrarLcdBienvenida PROC
    CALL LimpiarLcd
    MOV DX,2040h
    LEA SI,LcdBienvenidoA
    CALL EscribirLcd
    RET
MostrarLcdBienvenida ENDP

; LCD: Intento N de 3  (N = numero del intento que sigue: 2 o 3)
MostrarLcdIntento PROC
    MOV AL,4
    SUB AL,IntentosRestantes    ; quedan 2 -> intento 2, queda 1 -> intento 3
    ADD AL,'0'
    MOV LcdNumeroIntento,AL
    CALL LimpiarLcd
    MOV DX,2040h
    LEA SI,LcdTextoIntento
    CALL EscribirLcd
    RET
MostrarLcdIntento ENDP

; LCD: Acceso bloqueado
MostrarLcdBloqueo PROC
    CALL LimpiarLcd
    MOV DX,2040h
    LEA SI,LcdBloqueo
    CALL EscribirLcd
    RET
MostrarLcdBloqueo ENDP

; Copia las 5 letras del usuario al texto de bienvenida del LCD
CopiarUsuarioAlLcd PROC
    MOV SI,0
CopiarLetraUsuario:
    MOV AL,UsuarioCapturado[SI]
    MOV LcdNombreUsuario[SI],AL
    ADD SI,1
    CMP SI,5
    JNE CopiarLetraUsuario
    RET
CopiarUsuarioAlLcd ENDP

; Procedimientos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos.asm

END Inicio
