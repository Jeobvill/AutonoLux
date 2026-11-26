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
    ID                DW ?
    RutaRaiz          DB "C:\AutonoLux",0
    RutaSergio        DB "C:\AutonoLux\Sergio",0
    RutaConsumo       DB "C:\AutonoLux\Sergio\consumo.txt",0
    RutaIluminacion   DB "C:\AutonoLux\Jesus\iluminacion.txt",0
    BufferIlum        DB 180 DUP(0)
FilasConsumo      DB "| 1 Recepcion            0          0 %          0 W        AUTO           |"
                  DB "| 2 Lectura Silenciosa   0          0 %          0 W        AUTO           |"
                  DB "| 3 Sala de Computo      0          0 %          0 W        AUTO           |"
                  DB "| 4 Hemeroteca           0          0 %          0 W        AUTO           |"
                  DB "| 5 Estantes A-F         0          0 %          0 W        AUTO           |"
                  DB "| 6 Sala de Grupos       0          0 %          0 W        AUTO           |"
RenCabecera       DB "| #  ZONA               LAMP.     INT.        POT. W        MODO           |"
RenTitulo         DB "| CONSUMO ENERGETICO (datos de iluminacion.txt y config.txLampara: 000 W   |"
RenTotal          DB "| TOTAL: lamparas encendidas  0 de  0  zonas con luz: 0 de 6               |"
RenSinAuto        DB "| Sin automatizacion (todas las luces ON):   0 W  Encendido ahora:    0 W  |"
TextoAuto4         DB "AUTO"
TextoMan4          DB "MAN "
LampsFila         DW 0
IntFila           DW 0
PotFila           DW 0
TotalPot          DW 0
ZonasEnc          DW 0

    RutaConfiguracion DB "C:\AutonoLux\Sergio\config.txt",0
    BufferConfig      DB 256 DUP(0)
    HoraAbre          DB 8
    HoraCierra        DB 18
    TextoPersAbiertas DB "PERSIANAS ABIERTAS: dentro del horario se aprovecha la luz natural    "
    TextoPersCerradas DB "PERSIANAS CERRADAS: fuera del horario de operacion                    "
    LamparasPorZona   DW 4
    WattsLampara      DW 18
    PorcentajeZonas   DB 0,17,33,50,67,83,100

mulN1             DW 0
mulN2             DW 0
mulR              DW 0

restaN1           DB 0
restaN2           DB 0
restaR            DB 0

TextoNumero       DB "000"
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

BufferConsumo     DB 1794 DUP(?)

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
                  DB "| POTENCIA TOTAL ENCEND. ___ W          AHORRO: ___ %                      |",13,10
                  DB "| Sin automatizacion (luces siempre ON): ___ kWh                           |",13,10
                  DB "| [ESC] Volver                                                             |",13,10
                  DB "+==========================================================================+",13,10

INCLUDE Dispositivos_Datos.asm

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    CREAR_CARPETA RutaRaiz
    CREAR_CARPETA RutaSergio
    CALL MostrarConsumo
Fin:
    MOV AX,4C00H
    INT 21H

;==================== CONSUMO ENERGETICO ====================

MostrarConsumo PROC
    ABRIR_ARCHIVO RutaConsumo,0
    JC ConsumoNoExiste
    JMP ConsumoAbierto
ConsumoNoExiste:
    CALL CrearConsumoInicial
    ABRIR_ARCHIVO RutaConsumo,0
    JC ErrorAlLeerConsumo
ConsumoAbierto:
    LEER_ARCHIVO 1794,BufferConsumo,ID
    JC ErrorAlLeerConsumo
    CERRAR_ARCHIVO ID
    CALL DibujarConsumo
    CALL LeerConfiguracion
    CALL LeerIluminacion
    CALL CalcularConsumo
    CALL PintarFilasConsumo
    CALL PintarResultadosConsumo
ConsumoEsperarTecla:
    RASTREO
    CMP AL,27
    JNE ConsumoEsperarTecla
    RET
ErrorAlLeerConsumo:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
MostrarConsumo ENDP

CrearConsumoInicial PROC
    CREAR_ARCHIVO RutaConsumo,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,1794,TextoConsumo
    CERRAR_ARCHIVO ID
    RET
CrearConsumoInicial ENDP

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

BuscarOpcion PROC
    MOV SI,0
BuscarSiguiente:
    CMP SI,240
    JNC OpcionNoEsta
    CMP BufferConfig[SI],'O'
    JNE AvanzarBusqueda
    CMP BufferConfig[SI+7],AL
    JNE AvanzarBusqueda
    ADD SI,10
    CLC
    RET
AvanzarBusqueda:
    ADD SI,1
    JMP BuscarSiguiente
OpcionNoEsta:
    STC
    RET
BuscarOpcion ENDP

LeerNumeroConfig PROC
    XOR AX,AX
NumeroSiguiente:
    MOV BL,BufferConfig[SI]
    CMP BL,'0'
    JC FinNumeroConfig
    CMP BL,':'
    JNC FinNumeroConfig
    MOV DX,10
    MUL DX
    SUB BL,'0'
    MOV BH,0
    ADD AX,BX
    ADD SI,1
    JMP NumeroSiguiente
FinNumeroConfig:
    RET
LeerNumeroConfig ENDP

LeerConfiguracion PROC
    ABRIR_ARCHIVO RutaConfiguracion,0
    JC FinLeerConfiguracion
    LEER_ARCHIVO 255,BufferConfig,ID
    CERRAR_ARCHIVO ID
    MOV AL,'3'
    CALL BuscarOpcion
    JC ConfigHorario
    CALL LeerNumeroConfig
    CMP AX,0
    JE ConfigHorario
    MOV WattsLampara,AX
ConfigHorario:
    MOV AL,'5'
    CALL BuscarOpcion
    JC FinLeerConfiguracion
    CALL LeerNumeroConfig
    MOV HoraAbre,AL
    ADD SI,1
    MOV AL,BufferConfig[SI+2]
    CMP AL,'-'
    JNE FinLeerConfiguracion
    ADD SI,3
    CALL LeerNumeroConfig
    MOV HoraCierra,AL
FinLeerConfiguracion:
    RET
LeerConfiguracion ENDP

ControlPersianas PROC
    MOV AH,2Ch
    INT 21H
    CMP CH,HoraAbre
    JC PersianasCerrar
    CMP CH,HoraCierra
    JNC PersianasCerrar
    MOV DireccionMotor,0
    MOV CX,24
    CALL GirarPersianas
    IMPCAD_COLOR TextoPersAbiertas,70,22,3,0,0,1Ah
    RET
PersianasCerrar:
    MOV DireccionMotor,1
    MOV CX,24
    CALL GirarPersianas
    IMPCAD_COLOR TextoPersCerradas,70,22,3,0,0,1Ch
    RET
ControlPersianas ENDP

ParseDigitos PROC
    XOR AX,AX
ParseSiguiente:
    CMP CX,0
    JE FinParse
    MOV BL,[DI]
    CMP BL,'0'
    JC ParseSalta
    CMP BL,':'
    JNC ParseSalta
    MOV DX,10
    MUL DX
    SUB BL,'0'
    MOV BH,0
    ADD AX,BX
ParseSalta:
    ADD DI,1
    SUB CX,1
    JMP ParseSiguiente
FinParse:
    RET
ParseDigitos ENDP

PonerNum PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP
    MOV BP,CX
    MOV SI,DI
    ADD DI,CX
    SUB DI,1
    MOV BX,10
NumSiguiente:
    XOR DX,DX
    DIV BX
    ADD DL,'0'
    MOV [DI],DL
    SUB DI,1
    SUB CX,1
    CMP CX,0
    JNE NumSiguiente
    MOV CX,BP
    SUB CX,1
NumBlanco:
    CMP BYTE PTR [SI],'0'
    JNE FinNum
    MOV BYTE PTR [SI],' '
    ADD SI,1
    SUB CX,1
    CMP CX,0
    JNE NumBlanco
FinNum:
    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PonerNum ENDP

PintarFilasConsumo PROC
    MOV TotalPot,0
    MOV BP,0
FilaConsumoSiguiente:
    MOV AX,30
    MUL BP
    MOV SI,AX
    MOV LampsFila,0
    MOV IntFila,0
    MOV PotFila,0
    CMP BufferIlum[SI+18],'1'
    JNE FilaConsumoApagada
    MOV AX,LamparasPorZona
    MOV LampsFila,AX
    LEA DI,BufferIlum
    ADD DI,SI
    ADD DI,24
    MOV CX,3
    CALL ParseDigitos
    MOV IntFila,AX
    MOV AX,LampsFila
    MUL WattsLampara
    MUL IntFila
    MOV BX,100
    DIV BX
    MOV PotFila,AX
    ADD TotalPot,AX
FilaConsumoApagada:
    MOV AX,76
    MUL BP
    LEA DI,FilasConsumo
    ADD DI,AX
    PUSH DI
    ADD DI,24
    MOV AX,LampsFila
    MOV CX,2
    CALL PonerNum
    POP DI
    PUSH DI
    ADD DI,34
    MOV AX,IntFila
    MOV CX,3
    CALL PonerNum
    POP DI
    PUSH DI
    ADD DI,46
    MOV AX,PotFila
    MOV CX,4
    CALL PonerNum
    POP DI
    ADD DI,60
    MOV AX,30
    MUL BP
    MOV SI,AX
    CMP BufferIlum[SI+12],'M'
    JE FilaConsumoManual
    LEA SI,TextoAuto4
    JMP FilaConsumoModo
FilaConsumoManual:
    LEA SI,TextoMan4
FilaConsumoModo:
    MOV CX,4
    CLD
    REP MOVSB
    ADD BP,1
    CMP BP,6
    JNE FilaConsumoSiguiente
    MOV AX,TotalPot
    MOV mulR,AX
    LEA DI,RenTitulo+67
    MOV AX,WattsLampara
    MOV CX,3
    CALL PonerNum
    LEA DI,RenTotal+29
    MOV AX,ZonasEnc
    MUL LamparasPorZona
    MOV CX,2
    CALL PonerNum
    LEA DI,RenTotal+35
    MOV AX,LamparasPorZona
    MOV BX,6
    MUL BX
    MOV CX,2
    CALL PonerNum
    LEA DI,RenTotal+54
    MOV AX,ZonasEnc
    MOV CX,1
    CALL PonerNum
    LEA DI,RenSinAuto+42
    MOV AX,LamparasPorZona
    MOV BX,6
    MUL BX
    MUL WattsLampara
    MOV CX,4
    CALL PonerNum
    LEA DI,RenSinAuto+67
    MOV AX,TotalPot
    MOV CX,4
    CALL PonerNum
    IMPCAD_COLOR RenTitulo,76,7,0,0,0,1Eh
    IMPCAD_COLOR RenCabecera,76,9,0,0,0,1Bh
    IMPCAD_COLOR FilasConsumo,76,11,0,0,0,1Fh
    IMPCAD_COLOR FilasConsumo+76,76,12,0,0,0,1Fh
    IMPCAD_COLOR FilasConsumo+152,76,13,0,0,0,1Fh
    IMPCAD_COLOR FilasConsumo+228,76,14,0,0,0,1Fh
    IMPCAD_COLOR FilasConsumo+304,76,15,0,0,0,1Fh
    IMPCAD_COLOR FilasConsumo+380,76,16,0,0,0,1Fh
    IMPCAD_COLOR RenTotal,76,18,0,0,0,1Eh
    IMPCAD_COLOR RenSinAuto,76,20,0,0,0,1Fh
    RET
PintarFilasConsumo ENDP

LeerIluminacion PROC
    MOV mulN1,0
    MOV AX,WattsLampara
    MOV mulN2,AX
    MOV restaN1,100
    MOV restaN2,0
    ABRIR_ARCHIVO RutaIluminacion,0
    JC FinLeerIlum
    LEER_ARCHIVO 180,BufferIlum,ID
    CERRAR_ARCHIVO ID
    XOR CX,CX
    XOR SI,SI
ContarZonas:
    CMP BufferIlum[SI+18],'1'
    JNE SiguienteZonaIlum
    INC CX
SiguienteZonaIlum:
    ADD SI,30
    CMP SI,180
    JC ContarZonas
    MOV ZonasEnc,CX
    MOV AX,LamparasPorZona
    MUL CX
    MOV mulN1,AX
    MOV BX,CX
    MOV AL,PorcentajeZonas[BX]
    MOV restaN2,AL
FinLeerIlum:
    RET
LeerIluminacion ENDP

CalcularConsumo PROC
    XOR AX,AX
    XOR BX,BX
    MOV AX,mulN1
    MOV BX,mulN2
    MUL BX
    MOV mulR,AX
    MOV AL,restaN1
    MOV BL,restaN2
    SUB AL,BL
    MOV restaR,AL
    RET
CalcularConsumo ENDP

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

ConvertirATexto PROC
    MOV TextoNumero,'0'
    MOV TextoNumero+1,'0'
    MOV TextoNumero+2,'0'
RestarCien:
    CMP AX,100
    JC RestarDiez
    SUB AX,100
    ADD TextoNumero,1
    JMP RestarCien
RestarDiez:
    CMP AX,10
    JC SumarUnidades
    SUB AX,10
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

INCLUDE Dispositivos.asm

END Inicio
