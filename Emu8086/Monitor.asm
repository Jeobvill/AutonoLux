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
    ID                DW ?          ; handle de archivo (lo usa la biblioteca)
    RutaRaiz          DB "C:\AutonoLux",0
    RutaDaniel        DB "C:\AutonoLux\Daniel",0
    RutaZonas         DB "C:\AutonoLux\Daniel\zonas.txt",0
    RutaBitacora      DB "C:\AutonoLux\Daniel\bitacora.txt",0
    RutaVisitantes    DB "C:\AutonoLux\Jesus\visitantes.txt",0

; ---- Datos en vivo
PersonasEnSala    DB 0          ; ultimo valor de sala escrito por el Contador
Temperatura       DB 0          ; grados leidos del Thermometer
AlertaRegistrada  DB 0          ; 1 = la alerta ya se mando a la bitacora
TextoSala         DB "000"      ; sala tal como viene en visitantes.txt
BufferVisita      DB 58 DUP(?)  ; un registro de visitantes.txt (58 bytes)

; ---- Textos cortos que se escriben sobre la pantalla
TextoNumero       DB "000"      ; resultado de ConvertirATexto
TextoSemaforoVerde    DB "VERDE   "
TextoSemaforoAmarillo DB "AMARILLO"
TextoSemaforoRojo     DB "ROJO    "
TextoTermometroNormal DB "NORMAL "
TextoTermometroAlerta DB "ALERTA "
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

; ---- Registro de alerta para bitacora.txt (78 bytes: 76 caracteres + CR LF)
TextoRegistroAlerta DB "| 00:00  -- Termometro          Alerta: temperatura alta        AUTO       |",13,10

; ---- Buffer donde se lee bitacora.txt (solo para llegar al final del archivo)
BufferBitacora    DB 1872 DUP(?)

; ---- Buffer donde se lee zonas.txt (24 registros de 78 bytes)
BufferMonitor     DB 1872 DUP(?)

; ---- Texto base de zonas.txt: se escribe solo si el archivo no existe
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
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaDaniel
    CALL ControlMonitor
Fin:
    MOV AX,4C00H                ; termina con codigo 0
    INT 21H

;==================== MONITOR DE ZONAS ====================

; Teclas: R refrescar, ESC volver
ControlMonitor PROC
    ABRIR_ARCHIVO RutaZonas,0
    JC MonitorNoExiste
    JMP MonitorAbierto
MonitorNoExiste:
    CALL CrearMonitorInicial    ; el archivo no existe: se crea con la pantalla base
    ABRIR_ARCHIVO RutaZonas,0
    JC ErrorAlLeerMonitor
MonitorAbierto:
    LEER_ARCHIVO 1872,BufferMonitor,ID
    JC ErrorAlLeerMonitor
    CERRAR_ARCHIVO ID
    CALL EncenderTermometro     ; se enciende una sola vez, como en Termometro02
MonitorRefrescar:
    CALL DibujarMonitor
    CALL LeerPersonasEnSala
    CALL PintarDatosEnVivo
MonitorEsperarTecla:
    RASTREO
    CMP AL,27                   ; ESC
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

; Crea zonas.txt con la pantalla base (solo cuando todavia no existe)
CrearMonitorInicial PROC
    CREAR_ARCHIVO RutaZonas,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,1872,TextoMonitor
    CERRAR_ARCHIVO ID
    RET
CrearMonitorInicial ENDP

; Dibuja la pantalla con los renglones leidos de zonas.txt (cada registro mide 78 bytes)
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

; Escribe sala, semaforo, temperatura y estado del termometro
PintarDatosEnVivo PROC
    MOV AL,PersonasEnSala
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,18,22,0,0,1Fh
    CALL ActualizarSemaforo
    CALL LeerTermometro
    RET
PintarDatosEnVivo ENDP


;==================== PERSONAS EN SALA (visitantes.txt) ====================

; El Contador escribe un registro de 58 bytes por evento. Se leen todos y
; se queda el ultimo; la sala son los 3 caracteres que empiezan en el byte 19
LeerPersonasEnSala PROC
    MOV TextoSala,'0'
    MOV TextoSala+1,'0'
    MOV TextoSala+2,'0'
    ABRIR_ARCHIVO RutaVisitantes,0
    JC FinLeerPersonas          ; todavia no se ha abierto el Contador: sala 0
LeerSiguienteRegistroVisita:
    LEER_ARCHIVO 58,BufferVisita,ID
    JC TerminarLecturaVisitas
    CMP AX,58
    JC TerminarLecturaVisitas   ; menos de 58 bytes: ya no hay mas registros
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

; TextoSala ("017") pasa a numero en PersonasEnSala (decenas x 10 + unidades;
; la sala nunca llega a 100 porque el aforo maximo es 60)
ConvertirSalaANumero PROC
    MOV PersonasEnSala,0
    MOV CL,TextoSala+1
    SUB CL,'0'                  ; CL = decenas
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

; Verde de 0 a 44 personas, amarillo de 45 a 59, rojo de 60 en adelante
ActualizarSemaforo PROC
    MOV AL,PersonasEnSala
    CMP AL,45
    JC SemaforoEnVerde          ; menos de 45
    CMP AL,60
    JC SemaforoEnAmarillo       ; de 45 a 59
    MOV DX,4
    MOV AX,0249h                ; los 4 semaforos en rojo
    OUT DX,AX
    IMPCAD_COLOR TextoSemaforoRojo,8,18,60,0,0,1Ch
    RET
SemaforoEnAmarillo:
    MOV DX,4
    MOV AX,0492h                ; los 4 semaforos en amarillo
    OUT DX,AX
    IMPCAD_COLOR TextoSemaforoAmarillo,8,18,60,0,0,1Eh
    RET
SemaforoEnVerde:
    MOV DX,4
    MOV AX,0924h                ; los 4 semaforos en verde
    OUT DX,AX
    IMPCAD_COLOR TextoSemaforoVerde,8,18,60,0,0,1Ah
    RET
ActualizarSemaforo ENDP


;==================== THERMOMETER (puertos 127 y 125) ====================

; Puerto 127: 1 enciende el termometro (confirmado en clase, Termometro02.asm)
EncenderTermometro PROC
    MOV DX,127
    MOV AL,1
    OUT DX,AL
    RET
EncenderTermometro ENDP

; Puerto 125: temperatura (POR CONFIRMAR). Desde 35 grados hay alerta
LeerTermometro PROC
    MOV DX,125
    IN AL,DX
    MOV Temperatura,AL
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,19,24,0,0,1Fh
    MOV AL,Temperatura
    CMP AL,35
    JC TemperaturaNormal        ; menos de 35
    IMPCAD_COLOR TextoTermometroAlerta,7,19,61,0,0,1Ch
    CMP AlertaRegistrada,1
    JE FinLeerTermometro        ; la alerta ya se registro
    MOV AlertaRegistrada,1
    CALL RegistrarAlertaEnBitacora
    RET
TemperaturaNormal:
    IMPCAD_COLOR TextoTermometroNormal,7,19,61,0,0,1Ah
    MOV AlertaRegistrada,0      ; si vuelve a subir, avisa otra vez
FinLeerTermometro:
    RET
LeerTermometro ENDP

; Agrega el registro de alerta al final de bitacora.txt.
; Al leer el archivo completo el puntero queda al final, y lo que se escribe despues se agrega
RegistrarAlertaEnBitacora PROC
    ABRIR_ARCHIVO RutaBitacora,2
    JC AlertaCrearBitacora
    LEER_ARCHIVO 1872,BufferBitacora,ID
    JC FinRegistrarAlerta
    CMP AX,1872
    JC AlertaEscribirRegistro   ; menos de 24 registros: hay lugar
    CERRAR_ARCHIVO ID           ; bitacora llena
    RET
AlertaCrearBitacora:
    CREAR_ARCHIVO RutaBitacora,32
    MOV ID,AX
    JC FinRegistrarAlerta
AlertaEscribirRegistro:
    MOV DI,OFFSET TextoRegistroAlerta+2   ; hora real de la alerta
    CALL HoraEnTexto
    ESCRIBIR_ARCHIVO ID,78,TextoRegistroAlerta
    CERRAR_ARCHIVO ID
FinRegistrarAlerta:
    RET
RegistrarAlertaEnBitacora ENDP

; Escribe la hora real de DOS (INT 21h/2Ch) como "HH:MM" en 5 bytes.  Entrada: DI = destino
HoraEnTexto PROC
    MOV AH,2Ch
    INT 21H                     ; CH = horas, CL = minutos
    PUSH CX
    MOV AL,CH
    AAM                         ; AH = decenas, AL = unidades
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

; Entrada: AL = numero de 0 a 255.  Salida: TextoNumero = 3 caracteres
; Resta 100, luego 10, y lo que queda son las unidades (sin ceros a la izquierda)
ConvertirATexto PROC
    MOV TextoNumero,'0'
    MOV TextoNumero+1,'0'
    MOV TextoNumero+2,'0'
RestarCien:
    CMP AL,100
    JC RestarDiez               ; AL menor que 100
    SUB AL,100
    ADD TextoNumero,1
    JMP RestarCien
RestarDiez:
    CMP AL,10
    JC SumarUnidades            ; AL menor que 10
    SUB AL,10
    ADD TextoNumero+1,1
    JMP RestarDiez
SumarUnidades:
    ADD TextoNumero+2,AL
    CMP TextoNumero,'0'
    JNE FinConvertir
    MOV TextoNumero,' '         ; sin cero a la izquierda
    CMP TextoNumero+1,'0'
    JNE FinConvertir
    MOV TextoNumero+1,' '
FinConvertir:
    RET
ConvertirATexto ENDP

END Inicio
