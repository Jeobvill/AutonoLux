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
    ID                DW ?
    RutaRaiz          DB "C:\AutonoLux",0
    RutaAxel          DB "C:\AutonoLux\Axel",0
    RutaUsuarios      DB "C:\AutonoLux\Axel\usuarios.txt",0
    RutaLoginSalida   DB "C:\AutonoLux\Axel\login_out.txt",0

IntentosRestantes DB 3
MostrarError      DB 0
LoginCorrecto     DB 0
CodigoSalida      DB 1
ErrorDeArchivo    DB 0
TextosIguales     DB 0
LongitudUsuario   DB 0
LongitudClave     DB 0

CapturaCantidad   DB 0
CapturaMaximo     DB 0
CapturaEco        DB 0
CapturaMayusculas DB 0
CapturaRenglon    DB 0
CapturaColumna    DB 0
CapturaCaracter   DB 0
CapturaTecla      DB 0
UsuarioCapturado  DB "     "
ClaveCapturada    DB "    "

UsuarioPorDefecto DB "ADMIN,1234"
BufferUsuarios    DB 10 DUP(?)

TextoResultadoAcceso   DB "OK,"
TextoResultadoEscape   DB "ESC"
TextoResultadoBloqueo  DB "BLOQUEADO"
FinDeLinea        DB 13,10

LcdBienvenidoA    DB "Bienvenido "
LcdNombreUsuario  DB "     ",0
LcdTextoIntento   DB "Intento "
LcdNumeroIntento  DB "2"
                  DB " de 3",0

TextoIntentos     DB "3"
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"
MensajeError      DB "   Usuario o clave incorrectos. Verifique e intente de nuevo.             "
MensajeBloqueo    DB "   Acceso bloqueado: 3 intentos fallidos. Presione una tecla para salir.  "
MensajeBienvenida DB "   Acceso concedido. Presione una tecla para continuar.                   "

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

INCLUDE Dispositivos_Datos.asm

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    CREAR_CARPETA RutaRaiz
    CREAR_CARPETA RutaAxel
    CALL ControlLogin
Fin:
    MOV AH,4Ch
    MOV AL,CodigoSalida
    INT 21H

;==================== ACCESO AL SISTEMA ====================

ControlLogin PROC
    CALL CrearUsuariosBase
    CMP ErrorDeArchivo,1
    JE LoginSinArchivo
    CALL MostrarLcdInicio
LoginPantalla:
    CALL DibujarLogin
    CALL PintarEstadoLogin
    CALL PedirUsuario
    CMP CapturaTecla,27
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
    MOV CodigoSalida,3
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

PintarEstadoLogin PROC
    MOV AL,IntentosRestantes
    ADD AL,'0'
    MOV TextoIntentos,AL
    IMPCAD_COLOR TextoIntentos,1,16,38,0,0,1Fh
    CMP MostrarError,1
    JNE FinPintarEstadoLogin
    IMPCAD_COLOR MensajeError,74,20,1,0,0,1Eh
FinPintarEstadoLogin:
    RET
PintarEstadoLogin ENDP

;==================== CAPTURA ====================

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

CapturarTexto PROC
    MOV CapturaCantidad,0
CapturarSiguiente:
    CURSOR CapturaRenglon,CapturaColumna,0
    RASTREO
    CMP AL,13
    JE CapturaTermina
    CMP AL,27
    JE CapturaTermina
    CMP AL,8
    JE CapturaBorrar
    CMP AL,32
    JC CapturarSiguiente
    MOV AH,CapturaCantidad
    CMP AH,CapturaMaximo
    JE CapturarSiguiente
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

AceptarCaracter PROC
    CMP CapturaMayusculas,1
    JNE AceptarGuardar
    CMP AL,'a'
    JC AceptarGuardar
    CMP AL,'{'
    JNC AceptarGuardar
    SUB AL,32
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
    ADD DI,6
    MOV CX,4
    CALL CompararTextos
    CMP TextosIguales,1
    JNE FinValidar
    MOV LoginCorrecto,1
FinValidar:
    RET
ValidarCredenciales ENDP

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

MostrarBienvenida PROC
    CALL CopiarUsuarioAlLcd
    CALL MostrarLcdBienvenida
    IMPCAD_COLOR MensajeBienvenida,74,20,1,0,0,1Ah
    RASTREO
    RET
MostrarBienvenida ENDP

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

MostrarLcdInicio PROC
    CALL LimpiarLcd
    MOV DX,2040h
    LEA SI,LcdTitulo
    CALL EscribirLcd
    RET
MostrarLcdInicio ENDP

MostrarLcdBienvenida PROC
    CALL LimpiarLcd
    MOV DX,2040h
    LEA SI,LcdBienvenidoA
    CALL EscribirLcd
    RET
MostrarLcdBienvenida ENDP

MostrarLcdIntento PROC
    MOV AL,4
    SUB AL,IntentosRestantes
    ADD AL,'0'
    MOV LcdNumeroIntento,AL
    CALL LimpiarLcd
    MOV DX,2040h
    LEA SI,LcdTextoIntento
    CALL EscribirLcd
    RET
MostrarLcdIntento ENDP

MostrarLcdBloqueo PROC
    CALL LimpiarLcd
    MOV DX,2040h
    LEA SI,LcdBloqueo
    CALL EscribirLcd
    RET
MostrarLcdBloqueo ENDP

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

INCLUDE Dispositivos.asm

END Inicio
