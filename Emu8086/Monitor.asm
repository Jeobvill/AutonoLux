;*********************************************************
; VELIZ PARTIDA DANIEL
; Guardar como: Monitor.asm
; Pantalla: Monitor de zonas (Thermometer y Traffic_Lights). Lee zonas.txt y visitantes.txt.
; Si hay alerta de temperatura, la agrega a bitacora.txt.
; Programa independiente: se compila a Monitor.exe (emu8086).
; Necesita Biblioteca.txt en la misma carpeta.
; Teclas en MAYUSCULAS.
;*********************************************************
#start=thermometer.exe#
#start=Traffic_Lights.exe#

INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?
    RutaRaiz          DB "C:\AutonoLux",0
    RutaDaniel        DB "C:\AutonoLux\Daniel",0
    RutaZonas         DB "C:\AutonoLux\Daniel\zonas.txt",0
    RutaBitacora      DB "C:\AutonoLux\Daniel\bitacora.txt",0
    RutaVisitantes    DB "C:\AutonoLux\Jesus\visitantes.txt",0

PersonasEnSala    DB 0
Temperatura       DB 0
AlertaRegistrada  DB 0
TextoSala         DB "000"
BufferVisita      DB 58 DUP(?)

TextoNumero       DB "000"
TextoSemaforoVerde    DB "VERDE   "
TextoSemaforoAmarillo DB "AMARILLO"
TextoSemaforoRojo     DB "ROJO    "
TextoTermometroNormal DB "NORMAL "
TextoTermometroAlerta DB "ALERTA "
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

TextoRegistroAlerta DB "| 00:00  -- Termometro          Alerta: temperatura alta        AUTO       |",13,10

BufferBitacora    DB 1872 DUP(?)

BufferMonitor     DB 1872 DUP(?)

TextoMonitor      DB "+==========================================================================+",13,10
                  DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |",13,10
                  DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |",13,10
                  DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |",13,10
                  DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |",13,10
                  DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |",13,10
                  DB "+==========================================================================+",13,10
                  DB "| MONITOR DE ZONAS                          Actualiza con [R]              |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "| ZONA                    ESTADO      PERSONAS   LUZ    TIEMPO OCUPADA     |",13,10
                  DB "| 1 Recepcion           OCUPADA         3      ON     1h 12m               |",13,10
                  DB "| 2 Lectura Silenciosa  OCUPADA         8      ON     2h 05m               |",13,10
                  DB "| 3 Sala de Computo     LIBRE           0      OFF    --                   |",13,10
                  DB "| 4 Hemeroteca          OCUPADA         1      ON     0h 20m               |",13,10
                  DB "| 5 Estantes A-F        LIBRE           0      OFF    --                   |",13,10
                  DB "| 6 Sala de Grupos      OCUPADA         5      ON     0h 45m               |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "| Zonas ocupadas: 4 de 6        Personas en zonas: 17        Aforo: 28 %   |",13,10
                  DB "| En sala (contador): ___ / 60         Semaforo de entrada: ________       |",13,10
                  DB "| Temperatura ambiente: ___ C         Estado del termometro: _______       |",13,10
                  DB "|                                                                          |",13,10
                  DB "| [R] Refrescar      [ESC] Volver                                          |",13,10
                  DB "| Traffic_Lights: aforo en la entrada     Thermometer: temp. ambiente      |",13,10
                  DB "+==========================================================================+",13,10

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    CREAR_CARPETA RutaRaiz
    CREAR_CARPETA RutaDaniel
    CALL ControlMonitor
Fin:
    MOV AX,4C00H
    INT 21H

;==================== MONITOR DE ZONAS ====================

ControlMonitor PROC
    ABRIR_ARCHIVO RutaZonas,0
    JC MonitorNoExiste
    JMP MonitorAbierto
MonitorNoExiste:
    CALL CrearMonitorInicial
    ABRIR_ARCHIVO RutaZonas,0
    JC ErrorAlLeerMonitor
MonitorAbierto:
    LEER_ARCHIVO 1872,BufferMonitor,ID
    JC ErrorAlLeerMonitor
    CERRAR_ARCHIVO ID
    CALL EncenderTermometro
MonitorRefrescar:
    CALL DibujarMonitor
    CALL LeerPersonasEnSala
    CALL PintarDatosEnVivo
MonitorEsperarTecla:
    RASTREO
    CMP AL,27
    JE MonitorSalir
    CMP AL,'R'
    JE MonitorRefrescar
    JMP MonitorEsperarTecla
MonitorSalir:
    RET
ErrorAlLeerMonitor:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
ControlMonitor ENDP

CrearMonitorInicial PROC
    CREAR_ARCHIVO RutaZonas,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,1872,TextoMonitor
    CERRAR_ARCHIVO ID
    RET
CrearMonitorInicial ENDP

DibujarMonitor PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR BufferMonitor,76,0,0,0,0,1Bh
    IMPCAD_COLOR BufferMonitor+78,76,1,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+156,76,2,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+234,76,3,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+312,76,4,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+390,76,5,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+468,76,6,0,0,0,1Bh
    IMPCAD_COLOR BufferMonitor+546,76,7,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+624,76,8,0,0,0,17h
    IMPCAD_COLOR BufferMonitor+702,76,9,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+780,76,10,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+858,76,11,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+936,76,12,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1014,76,13,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1092,76,14,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1170,76,15,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1248,76,16,0,0,0,17h
    IMPCAD_COLOR BufferMonitor+1326,76,17,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1404,76,18,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1482,76,19,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1560,76,20,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1638,76,21,0,0,0,1Eh
    IMPCAD_COLOR BufferMonitor+1716,76,22,0,0,0,1Fh
    IMPCAD_COLOR BufferMonitor+1794,76,23,0,0,0,1Bh
    RET
DibujarMonitor ENDP

PintarDatosEnVivo PROC
    MOV AL,PersonasEnSala
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,18,22,0,0,1Fh
    CALL ActualizarSemaforo
    CALL LeerTermometro
    RET
PintarDatosEnVivo ENDP

;==================== PERSONAS EN SALA (visitantes.txt) ====================

LeerPersonasEnSala PROC
    MOV TextoSala,'0'
    MOV TextoSala+1,'0'
    MOV TextoSala+2,'0'
    ABRIR_ARCHIVO RutaVisitantes,0
    JC FinLeerPersonas
LeerSiguienteRegistroVisita:
    LEER_ARCHIVO 58,BufferVisita,ID
    JC TerminarLecturaVisitas
    CMP AX,58
    JC TerminarLecturaVisitas
    MOV AL,BufferVisita+19
    MOV TextoSala,AL
    MOV AL,BufferVisita+20
    MOV TextoSala+1,AL
    MOV AL,BufferVisita+21
    MOV TextoSala+2,AL
    JMP LeerSiguienteRegistroVisita
TerminarLecturaVisitas:
    CERRAR_ARCHIVO ID
FinLeerPersonas:
    CALL ConvertirSalaANumero
    RET
LeerPersonasEnSala ENDP

ConvertirSalaANumero PROC
    MOV PersonasEnSala,0
    MOV CL,TextoSala+1
    SUB CL,'0'
SumarDecenasDeSala:
    CMP CL,0
    JE SumarUnidadesDeSala
    ADD PersonasEnSala,10
    SUB CL,1
    JMP SumarDecenasDeSala
SumarUnidadesDeSala:
    MOV AL,TextoSala+2
    SUB AL,'0'
    ADD PersonasEnSala,AL
    RET
ConvertirSalaANumero ENDP

;==================== TRAFFIC_LIGHTS (puerto 4, palabra) ====================

ActualizarSemaforo PROC
    MOV AL,PersonasEnSala
    CMP AL,45
    JC SemaforoEnVerde
    CMP AL,60
    JC SemaforoEnAmarillo
    MOV DX,4
    MOV AX,0249h
    OUT DX,AX
    IMPCAD_COLOR TextoSemaforoRojo,8,18,60,0,0,1Ch
    RET
SemaforoEnAmarillo:
    MOV DX,4
    MOV AX,0492h
    OUT DX,AX
    IMPCAD_COLOR TextoSemaforoAmarillo,8,18,60,0,0,1Eh
    RET
SemaforoEnVerde:
    MOV DX,4
    MOV AX,0924h
    OUT DX,AX
    IMPCAD_COLOR TextoSemaforoVerde,8,18,60,0,0,1Ah
    RET
ActualizarSemaforo ENDP

;==================== THERMOMETER (puertos 127 y 125) ====================

EncenderTermometro PROC
    MOV DX,127
    MOV AL,1
    OUT DX,AL
    RET
EncenderTermometro ENDP

LeerTermometro PROC
    MOV DX,125
    IN AL,DX
    MOV Temperatura,AL
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,19,24,0,0,1Fh
    MOV AL,Temperatura
    CMP AL,35
    JC TemperaturaNormal
    IMPCAD_COLOR TextoTermometroAlerta,7,19,61,0,0,1Ch
    CMP AlertaRegistrada,1
    JE FinLeerTermometro
    MOV AlertaRegistrada,1
    CALL RegistrarAlertaEnBitacora
    RET
TemperaturaNormal:
    IMPCAD_COLOR TextoTermometroNormal,7,19,61,0,0,1Ah
    MOV AlertaRegistrada,0
FinLeerTermometro:
    RET
LeerTermometro ENDP

RegistrarAlertaEnBitacora PROC
    ABRIR_ARCHIVO RutaBitacora,2
    JC AlertaCrearBitacora
    LEER_ARCHIVO 1872,BufferBitacora,ID
    JC FinRegistrarAlerta
    CMP AX,1872
    JC AlertaEscribirRegistro
    CERRAR_ARCHIVO ID
    RET
AlertaCrearBitacora:
    CREAR_ARCHIVO RutaBitacora,32
    MOV ID,AX
    JC FinRegistrarAlerta
AlertaEscribirRegistro:
    MOV DI,OFFSET TextoRegistroAlerta+2
    CALL HoraEnTexto
    ESCRIBIR_ARCHIVO ID,78,TextoRegistroAlerta
    CERRAR_ARCHIVO ID
FinRegistrarAlerta:
    RET
RegistrarAlertaEnBitacora ENDP

HoraEnTexto PROC
    MOV AH,2Ch
    INT 21H
    PUSH CX
    MOV AL,CH
    AAM
    ADD AX,3030H
    MOV [DI],AH
    MOV [DI+1],AL
    MOV BYTE PTR [DI+2],':'
    POP CX
    MOV AL,CL
    AAM
    ADD AX,3030H
    MOV [DI+3],AH
    MOV [DI+4],AL
    RET
HoraEnTexto ENDP

;==================== CONVERSION ====================

ConvertirATexto PROC
    MOV TextoNumero,'0'
    MOV TextoNumero+1,'0'
    MOV TextoNumero+2,'0'
RestarCien:
    CMP AL,100
    JC RestarDiez
    SUB AL,100
    ADD TextoNumero,1
    JMP RestarCien
RestarDiez:
    CMP AL,10
    JC SumarUnidades
    SUB AL,10
    ADD TextoNumero+1,1
    JMP RestarDiez
SumarUnidades:
    ADD TextoNumero+2,AL
    CMP TextoNumero,'0'
    JNE FinConvertir
    MOV TextoNumero,' '
    CMP TextoNumero+1,'0'
    JNE FinConvertir
    MOV TextoNumero+1,' '
FinConvertir:
    RET
ConvertirATexto ENDP

END Inicio
