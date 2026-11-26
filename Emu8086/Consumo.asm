;*********************************************************
; DIAZ ROBLES SERGIO
; Guardar como: Consumo.asm
; Pantalla: Consumo energetico (LED_Display). Lee consumo.txt.
; Programa independiente: se compila a Consumo.exe (emu8086).
; Necesita Biblioteca.txt, Dispositivos.asm y Dispositivos_Datos.asm en la misma carpeta.
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?          ; handle de archivo (lo usa la biblioteca)
    RutaRaiz          DB "C:\AutonoLux",0
    RutaSergio        DB "C:\AutonoLux\Sergio",0
    RutaConsumo       DB "C:\AutonoLux\Sergio\consumo.txt",0

; ---- MUL del catedratico: potencia = lamparas x watts por lampara (palabras). Inician vacios
mulN1             DW 0          ; lamparas de la zona
mulN2             DW 0          ; watts por lampara
mulR              DW 0          ; potencia en watts

; ---- SUB del catedratico: ahorro (en porcentaje) = consumo sin automatizar - consumo con automatizacion (bytes). Inician vacios
restaN1           DB 0
restaN2           DB 0
restaR            DB 0          ; ahorro

; ---- Textos cortos que se escriben sobre la pantalla
TextoNumero       DB "000"      ; resultado de ConvertirATexto
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

; ---- Buffer donde se lee consumo.txt (23 registros de 78 bytes)
BufferConsumo     DB 1794 DUP(?)

; ---- Texto base de consumo.txt: se escribe solo si el archivo no existe
TextoConsumo       DB "+==========================================================================+",13,10
                  DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |",13,10
                  DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |",13,10
                  DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |",13,10
                  DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |",13,10
                  DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |",13,10
                  DB "+==========================================================================+",13,10
                  DB "| CONSUMO ENERGETICO (estimado)       Lampara: ___ W c/u | Tarifa: $___/kWh|",13,10
                  DB "+==========================================================================+",13,10
                  DB "| ZONA                LAMPARAS    HORAS ENC    CONSUMO(kWh)   COSTO        |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "| 1 Recepcion         ___         ___ h        ___            $ ___        |",13,10
                  DB "| 2 Lectura Silenc.   ___         ___ h        ___            $ ___        |",13,10
                  DB "| 3 Sala de Computo   ___         ___ h        ___            $ ___        |",13,10
                  DB "| 4 Hemeroteca        ___         ___ h        ___            $ ___        |",13,10
                  DB "| 5 Estantes A-F      ___         ___ h        ___            $ ___        |",13,10
                  DB "| 6 Sala de Grupos    ___         ___ h        ___            $ ___        |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "| TOTAL                                        ___ kWh        $ ___        |",13,10
                  DB "| POTENCIA ESTANTES A-F: ___ W          AHORRO: ___ %                      |",13,10
                  DB "| Sin automatizacion (luces siempre ON): ___ kWh                           |",13,10
                  DB "| [ESC] Volver                                                             |",13,10
                  DB "+==========================================================================+",13,10

; ---- Datos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos_Datos.asm

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaSergio
    CALL MostrarConsumo
Fin:
    MOV AX,4C00H                ; termina con codigo 0
    INT 21H

;==================== CONSUMO ENERGETICO ====================

; Tecla: ESC volver
MostrarConsumo PROC
    ABRIR_ARCHIVO RutaConsumo,0
    JC ConsumoNoExiste
    JMP ConsumoAbierto
ConsumoNoExiste:
    CALL CrearConsumoInicial    ; el archivo no existe: se crea con la pantalla base
    ABRIR_ARCHIVO RutaConsumo,0
    JC ErrorAlLeerConsumo
ConsumoAbierto:
    LEER_ARCHIVO 1794,BufferConsumo,ID
    JC ErrorAlLeerConsumo
    CERRAR_ARCHIVO ID
    CALL DibujarConsumo
    CALL CalcularConsumo
    CALL PintarResultadosConsumo
ConsumoEsperarTecla:
    RASTREO
    CMP AL,27                   ; ESC
    JNE ConsumoEsperarTecla
    RET
ErrorAlLeerConsumo:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
MostrarConsumo ENDP

; Crea consumo.txt con la pantalla base (solo cuando todavia no existe)
CrearConsumoInicial PROC
    CREAR_ARCHIVO RutaConsumo,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,1794,TextoConsumo
    CERRAR_ARCHIVO ID
    RET
CrearConsumoInicial ENDP

; Dibuja la pantalla con los renglones leidos de consumo.txt (cada registro mide 78 bytes)
DibujarConsumo PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR BufferConsumo,76,0,0,0,0,1Bh
    IMPCAD_COLOR BufferConsumo+78,76,1,0,0,0,1Eh
    IMPCAD_COLOR BufferConsumo+156,76,2,0,0,0,1Eh
    IMPCAD_COLOR BufferConsumo+234,76,3,0,0,0,1Eh
    IMPCAD_COLOR BufferConsumo+312,76,4,0,0,0,1Eh
    IMPCAD_COLOR BufferConsumo+390,76,5,0,0,0,1Eh
    IMPCAD_COLOR BufferConsumo+468,76,6,0,0,0,1Bh
    IMPCAD_COLOR BufferConsumo+546,76,7,0,0,0,1Eh
    IMPCAD_COLOR BufferConsumo+624,76,8,0,0,0,1Bh
    IMPCAD_COLOR BufferConsumo+702,76,9,0,0,0,1Bh
    IMPCAD_COLOR BufferConsumo+780,76,10,0,0,0,17h
    IMPCAD_COLOR BufferConsumo+858,76,11,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+936,76,12,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+1014,76,13,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+1092,76,14,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+1170,76,15,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+1248,76,16,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+1326,76,17,0,0,0,17h
    IMPCAD_COLOR BufferConsumo+1404,76,18,0,0,0,1Eh
    IMPCAD_COLOR BufferConsumo+1482,76,19,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+1560,76,20,0,0,0,1Ah
    IMPCAD_COLOR BufferConsumo+1638,76,21,0,0,0,1Fh
    IMPCAD_COLOR BufferConsumo+1716,76,22,0,0,0,1Bh
    RET
DibujarConsumo ENDP

; Calculos del catedratico (se copian tal como los dio)
CalcularConsumo PROC
    ; ---- MUL: potencia = lamparas x watts por lampara ----
    XOR AX,AX
    XOR BX,BX
    MOV AX,mulN1
    MOV BX,mulN2
    MUL BX
    MOV mulR,AX
    ; ---- SUB: ahorro ----
    MOV AL,restaN1
    MOV BL,restaN2
    SUB AL,BL
    MOV restaR,AL
    RET
CalcularConsumo ENDP

; Escribe la potencia y el ahorro sobre la pantalla y la potencia en el LED_Display
PintarResultadosConsumo PROC
    MOV AX,mulR
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,19,25,0,0,1Fh
    MOV AL,restaR
    MOV AH,0
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,19,48,0,0,1Fh
    MOV AX,mulR
    CALL MostrarEnLedDisplay
    RET
PintarResultadosConsumo ENDP

; Convierte AX (0 a 999) en 3 caracteres en TextoNumero restando 100 y 10
ConvertirATexto PROC
    MOV TextoNumero,'0'
    MOV TextoNumero+1,'0'
    MOV TextoNumero+2,'0'
RestarCien:
    CMP AX,100
    JC RestarDiez               ; AX menor que 100
    SUB AX,100
    ADD TextoNumero,1
    JMP RestarCien
RestarDiez:
    CMP AX,10
    JC SumarUnidades            ; AX menor que 10
    SUB AX,10
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

; Procedimientos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos.asm

END Inicio
