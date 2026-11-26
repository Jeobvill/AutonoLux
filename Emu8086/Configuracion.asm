;*********************************************************
; DIAZ ROBLES SERGIO
; Guardar como: Configuracion.asm
; Pantalla: Configuracion del sistema. Escribe config.txt.
; Programa independiente: se compila a Configuracion.exe (emu8086).
; Necesita Biblioteca.txt, Dispositivos.asm y Dispositivos_Datos.asm en la misma carpeta.
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?
    RutaRaiz          DB "C:\AutonoLux",0
    RutaSergio        DB "C:\AutonoLux\Sergio",0
    RutaConfiguracion DB "C:\AutonoLux\Sergio\config.txt",0

CadenaCapturada   DB 15,0,17 DUP(0)
LongitudCapturada DW ?

RegistroOpcion    DB "Opcion "
NumeroOpcion      DB "?"
                  DB ": "
FinDeLinea        DB 13,10

TextoNuevoValor   DB "Nuevo valor: "
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"

ConfiguracionRen07  DB "| CONFIGURACION DEL SISTEMA                                                |"
ConfiguracionRen08  DB "|--------------------------------------------------------------------------|"
ConfiguracionRen09  DB "                                                                            "
ConfiguracionRen10  DB "|   [1] Tiempo de espera para apagar luz ..... 5 min                       |"
ConfiguracionRen11  DB "|   [2] Aforo maximo de la biblioteca ....... 60 personas                  |"
ConfiguracionRen12  DB "|   [3] Potencia por lampara ................ 18 W                         |"
ConfiguracionRen13  DB "|   [4] Tarifa electrica .................... $2.50 / kWh                  |"
ConfiguracionRen14  DB "|   [5] Horario de operacion ................ 08:00 - 18:00                |"
ConfiguracionRen15  DB "|   [6] Sensibilidad del sensor ............. Media                        |"
ConfiguracionRen16  DB "|   [7] Cambiar clave de acceso                                            |"
ConfiguracionRen17  DB "|   [8] Restaurar valores de fabrica                                       |"
ConfiguracionRen18  DB "                                                                            "
ConfiguracionRen19  DB "|   Opcion a modificar [1-8], [G] Guardar cambios, [ESC] Cancelar: _       |"
ConfiguracionRen20  DB "                                                                            "
ConfiguracionRen21  DB "|   * Los cambios se aplican al guardar.                                   |"
ConfiguracionRen22  DB "                                                                            "

INCLUDE Dispositivos_Datos.asm

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    CREAR_CARPETA RutaRaiz
    CREAR_CARPETA RutaSergio
    CALL ControlConfiguracion
Fin:
    MOV AX,4C00H
    INT 21H

;==================== CONFIGURACION DEL SISTEMA ====================

ControlConfiguracion PROC
    CREAR_ARCHIVO RutaConfiguracion,32
    MOV ID,AX
    JC ConfiguracionErrorCrear
    JMP ConfiguracionRedibujar
ConfiguracionErrorCrear:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
ConfiguracionRedibujar:
    CALL DibujarConfiguracion
    CURSOR 19,67,0
    RASTREO
    CMP AL,27
    JE ConfiguracionSalir
    CMP AL,'G'
    JE ConfiguracionSalir
    CMP AL,'1'
    JC ConfiguracionRedibujar
    CMP AL,'7'
    JC ConfiguracionCapturar
    JMP ConfiguracionRedibujar
ConfiguracionCapturar:
    CALL CapturarValor
    JMP ConfiguracionRedibujar
ConfiguracionSalir:
    CERRAR_ARCHIVO ID
    RET
ControlConfiguracion ENDP

CapturarValor PROC
    MOV NumeroOpcion,AL
    IMPCAD_COLOR TextoNuevoValor,13,22,3,0,0,1Eh
    CURSOR 22,16,0
    LECTURA_CADENA CadenaCapturada
    MOV AL,CadenaCapturada+1
    MOV AH,0
    MOV LongitudCapturada,AX
    ESCRIBIR_ARCHIVO ID,10,RegistroOpcion
    ESCRIBIR_ARCHIVO ID,LongitudCapturada,CadenaCapturada+2
    ESCRIBIR_ARCHIVO ID,2,FinDeLinea
    CMP NumeroOpcion,'2'
    JNE FinCapturarValor
    XOR AX,AX
    MOV SI,0
AforoSiguienteDigito:
    CMP SI,LongitudCapturada
    JE AforoListo
    MOV BL,CadenaCapturada+2[SI]
    SUB BL,'0'
    MOV DX,10
    MUL DX
    MOV BH,0
    ADD AX,BX
    ADD SI,1
    JMP AforoSiguienteDigito
AforoListo:
    CALL MostrarEnLedDisplay
FinCapturarValor:
    RET
CapturarValor ENDP

DibujarConfiguracion PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR LineaMarco,76,0,0,0,0,1Bh
    IMPCAD_COLOR Logo1,76,1,0,0,0,1Eh
    IMPCAD_COLOR Logo2,76,2,0,0,0,1Eh
    IMPCAD_COLOR Logo3,76,3,0,0,0,1Eh
    IMPCAD_COLOR Logo4,76,4,0,0,0,1Eh
    IMPCAD_COLOR Logo5,76,5,0,0,0,1Eh
    IMPCAD_COLOR LineaMarco,76,6,0,0,0,1Bh
    IMPCAD_COLOR ConfiguracionRen07,76,7,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen08,76,8,0,0,0,1Bh
    IMPCAD_COLOR ConfiguracionRen09,76,9,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen10,76,10,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen11,76,11,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen12,76,12,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen13,76,13,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen14,76,14,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen15,76,15,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen16,76,16,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen17,76,17,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen18,76,18,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen19,76,19,0,0,0,1Eh
    IMPCAD_COLOR ConfiguracionRen20,76,20,0,0,0,1Fh
    IMPCAD_COLOR ConfiguracionRen21,76,21,0,0,0,17h
    IMPCAD_COLOR ConfiguracionRen22,76,22,0,0,0,1Fh
    IMPCAD_COLOR LineaMarco,76,23,0,0,0,1Bh
    RET
DibujarConfiguracion ENDP

INCLUDE Dispositivos.asm

END Inicio
