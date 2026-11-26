;*********************************************************
; VELIZ PARTIDA DANIEL
; Guardar como: Calor.asm
; Pantalla: Mapa de calor (Pressure Guage). Lee calor.txt.
; Programa independiente: se compila a Calor.exe (emu8086).
; Necesita Biblioteca.txt en la misma carpeta.
; El Pressure Guage es del Emulation Kit (Virtual Devices > Emulation Kit).
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?
    RutaRaiz          DB "C:\AutonoLux",0
    RutaDaniel        DB "C:\AutonoLux\Daniel",0
    RutaCalor         DB "C:\AutonoLux\Daniel\calor.txt",0

PeriodoActual     DB 'H'
RutaMapa          DB "C:\AutonoLux\Jesus\mapa.txt",0
RutaHistorial     DB "C:\AutonoLux\Daniel\calor_hist.txt",0
BufferMapa        DB 1872 DUP(0)
OffsetsPersonas   DW 872,896,920,1262,1286,1310
KeySem            DB 0
KeyMes            DB 0
Sem               DW 6 DUP(0)
Mes               DW 6 DUP(0)
HistLeido         DB 26 DUP(0)
Snap              DW 6 DUP(0)
TotalCalor        DW 0
ValorFila         DW 0
PctFila           DW 0
PctMax            DW 0
MaxVal            DW 0
IdxMax            DW 0
NombresZonas      DB "Recepcion           Lectura Silenciosa  Sala de Computo     Hemeroteca          Estantes A-F        Sala de Grupos      "
NombreSinDatos    DB "(sin datos de Mapa)  "
RowsCalor         DB "| 1 Recepcion            000 %                              0              |"
                  DB "| 2 Lectura Silenciosa   000 %                              0              |"
                  DB "| 3 Sala de Computo      000 %                              0              |"
                  DB "| 4 Hemeroteca           000 %                              0              |"
                  DB "| 5 Estantes A-F         000 %                              0              |"
                  DB "| 6 Sala de Grupos       000 %                              0              |"
RowHeader         DB "| #  ZONA                  OCUP.   INTENSIDAD            PERSONAS          |"
RowIntens         DB "| Intensidad: cada # = 5 % de las personas contadas en el periodo          |"
RowMas            DB "| Zona mas concurrida: Recepcion                                           |"

TextoPeriodoHoy     DB "HOY   "
TextoPeriodoSemana  DB "SEMANA"
TextoPeriodoMes     DB "MES   "
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

BufferCalor       DB 2808 DUP(?)

TextoCalor        DB "+==========================================================================+",13,10
                  DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |",13,10
                  DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |",13,10
                  DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |",13,10
                  DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |",13,10
                  DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |",13,10
                  DB "+==========================================================================+",13,10
                  DB "| MAPA DE CALOR (zonas mas ocupadas)        Periodo: ______                |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "| [H] Hoy      [S] Semana      [M] Mes      [ESC] Volver                   |",13,10
                  DB "|                                                                          |",13,10
                  DB "| Pressure Guage: % de la zona mas concurrida                              |",13,10
                  DB "+==========================================================================+",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    CREAR_CARPETA RutaRaiz
    CREAR_CARPETA RutaDaniel
    CALL ControlCalor
Fin:
    MOV AX,4C00H
    INT 21H

;==================== MAPA DE CALOR ====================

ControlCalor PROC
    ABRIR_ARCHIVO RutaCalor,0
    JC CalorNoExiste
    JMP CalorAbierto
CalorNoExiste:
    CALL CrearCalorInicial
    ABRIR_ARCHIVO RutaCalor,0
    JC ErrorAlLeerCalor
CalorAbierto:
    LEER_ARCHIVO 2808,BufferCalor,ID
    JC ErrorAlLeerCalor
    CERRAR_ARCHIVO ID
    CALL LeerMapaCalor
    CALL ActualizarHistorial
    MOV PeriodoActual,'H'
CalorRedibujar:
    CALL DibujarCalor
    CALL PintarPeriodo
CalorEsperarTecla:
    RASTREO
    CMP AL,27
    JE CalorSalir
    CMP AL,'H'
    JE CalorElegirHoy
    CMP AL,'S'
    JE CalorElegirSemana
    CMP AL,'M'
    JE CalorElegirMes
    JMP CalorEsperarTecla
CalorElegirHoy:
    MOV PeriodoActual,'H'
    JMP CalorRedibujar
CalorElegirSemana:
    MOV PeriodoActual,'S'
    JMP CalorRedibujar
CalorElegirMes:
    MOV PeriodoActual,'M'
    JMP CalorRedibujar
CalorSalir:
    RET
ErrorAlLeerCalor:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
ControlCalor ENDP

CrearCalorInicial PROC
    CREAR_ARCHIVO RutaCalor,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,2808,TextoCalor
    CERRAR_ARCHIVO ID
    RET
CrearCalorInicial ENDP

DibujarCalor PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR BufferCalor,76,0,0,0,0,1Bh
    IMPCAD_COLOR BufferCalor+78,76,1,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+156,76,2,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+234,76,3,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+312,76,4,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+390,76,5,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+468,76,6,0,0,0,1Bh
    IMPCAD_COLOR BufferCalor+546,76,7,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+624,76,8,0,0,0,17h
    IMPCAD_COLOR BufferCalor+702,76,9,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+780,76,10,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+858,76,11,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+936,76,12,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1014,76,13,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1092,76,14,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1170,76,15,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1248,76,16,0,0,0,17h
    IMPCAD_COLOR BufferCalor+1326,76,17,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1404,76,18,0,0,0,1Eh
    IMPCAD_COLOR BufferCalor+1482,76,19,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1560,76,20,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1638,76,21,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1716,76,22,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1794,76,23,0,0,0,1Bh
    RET
DibujarCalor ENDP

PintarPeriodo PROC
    CMP PeriodoActual,'S'
    JE PintarPeriodoSemana
    CMP PeriodoActual,'M'
    JE PintarPeriodoMes
    IMPCAD_COLOR TextoPeriodoHoy,6,7,53,0,0,1Eh
    LEA SI,Snap
    JMP PintarFilas
PintarPeriodoSemana:
    IMPCAD_COLOR TextoPeriodoSemana,6,7,53,0,0,1Eh
    LEA SI,Sem
    JMP PintarFilas
PintarPeriodoMes:
    IMPCAD_COLOR TextoPeriodoMes,6,7,53,0,0,1Eh
    LEA SI,Mes
PintarFilas:
    CALL LlenarFilas
    IMPCAD_COLOR RowHeader,76,9,0,0,0,1Eh
    IMPCAD_COLOR RowsCalor,76,10,0,0,0,1Fh
    IMPCAD_COLOR RowsCalor+76,76,11,0,0,0,1Fh
    IMPCAD_COLOR RowsCalor+152,76,12,0,0,0,1Fh
    IMPCAD_COLOR RowsCalor+228,76,13,0,0,0,1Fh
    IMPCAD_COLOR RowsCalor+304,76,14,0,0,0,1Fh
    IMPCAD_COLOR RowsCalor+380,76,15,0,0,0,1Fh
    IMPCAD_COLOR RowIntens,76,17,0,0,0,1Fh
    IMPCAD_COLOR RowMas,76,18,0,0,0,1Ah
    MOV AX,PctMax
    CALL EscribirPressureGuage
    RET
PintarPeriodo ENDP

;==================== DATOS REALES ====================

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

LeerMapaCalor PROC
    ABRIR_ARCHIVO RutaMapa,0
    JC FinLeerMapaCalor
    LEER_ARCHIVO 1872,BufferMapa,ID
    CERRAR_ARCHIVO ID
    MOV BP,0
MapaCalorZona:
    MOV BX,BP
    ADD BX,BX
    MOV SI,OffsetsPersonas[BX]
    LEA DI,BufferMapa
    ADD DI,SI
    MOV CX,3
    CALL ParseDigitos
    MOV BX,BP
    ADD BX,BX
    MOV Snap[BX],AX
    ADD BP,1
    CMP BP,6
    JNE MapaCalorZona
FinLeerMapaCalor:
    RET
LeerMapaCalor ENDP

ActualizarHistorial PROC
    MOV AH,2Ah
    INT 21H
    MOV AL,DL
    MOV AH,0
    MOV BL,7
    DIV BL
    MOV CL,AL
    MOV AL,DH
    MOV BL,10
    MUL BL
    ADD AL,CL
    MOV KeySem,AL
    MOV KeyMes,DH
    ABRIR_ARCHIVO RutaHistorial,0
    JC HistorialSumar
    LEER_ARCHIVO 26,HistLeido,ID
    CERRAR_ARCHIVO ID
    MOV AL,HistLeido
    CMP AL,KeySem
    JNE HistorialMes
    LEA SI,HistLeido+2
    LEA DI,Sem
    MOV CX,6
    CLD
    REP MOVSW
HistorialMes:
    MOV AL,HistLeido+1
    CMP AL,KeyMes
    JNE HistorialSumar
    LEA SI,HistLeido+14
    LEA DI,Mes
    MOV CX,6
    CLD
    REP MOVSW
HistorialSumar:
    MOV BX,0
HistorialSiguiente:
    MOV AX,Snap[BX]
    ADD Sem[BX],AX
    ADD Mes[BX],AX
    ADD BX,2
    CMP BX,12
    JNE HistorialSiguiente
    CREAR_ARCHIVO RutaHistorial,32
    MOV ID,AX
    JC FinHistorial
    ESCRIBIR_ARCHIVO ID,26,KeySem
    CERRAR_ARCHIVO ID
FinHistorial:
    RET
ActualizarHistorial ENDP

LlenarFilas PROC
    XOR AX,AX
    MOV BX,0
TotalSiguiente:
    ADD AX,[SI+BX]
    ADD BX,2
    CMP BX,12
    JNE TotalSiguiente
    MOV TotalCalor,AX
    MOV PctMax,0
    MOV MaxVal,0
    MOV IdxMax,0
    MOV BP,0
FilaSiguiente:
    MOV BX,BP
    ADD BX,BX
    MOV AX,[SI+BX]
    MOV ValorFila,AX
    MOV PctFila,0
    CMP TotalCalor,0
    JE PorcentajeListo
    MOV BX,100
    MUL BX
    MOV BX,TotalCalor
    DIV BX
    MOV PctFila,AX
PorcentajeListo:
    MOV AX,76
    MUL BP
    LEA DI,RowsCalor
    ADD DI,AX
    PUSH DI
    ADD DI,25
    MOV AX,PctFila
    MOV CX,3
    CALL PonerNum
    POP DI
    PUSH DI
    ADD DI,33
    MOV AX,PctFila
    MOV BL,5
    DIV BL
    MOV AH,0
    MOV DX,AX
    MOV CX,20
BarraSiguiente:
    CMP DX,0
    JE BarraVacio
    MOV BYTE PTR [DI],'#'
    SUB DX,1
    JMP BarraAvanza
BarraVacio:
    MOV BYTE PTR [DI],' '
BarraAvanza:
    ADD DI,1
    SUB CX,1
    CMP CX,0
    JNE BarraSiguiente
    POP DI
    ADD DI,56
    MOV AX,ValorFila
    MOV CX,5
    CALL PonerNum
    MOV AX,ValorFila
    CMP AX,MaxVal
    JC SinNuevoMaximo
    JE SinNuevoMaximo
    MOV MaxVal,AX
    MOV IdxMax,BP
    MOV AX,PctFila
    MOV PctMax,AX
SinNuevoMaximo:
    ADD BP,1
    CMP BP,6
    JNE FilaSiguiente
    CMP MaxVal,0
    JE CalorSinDatos
    LEA SI,NombresZonas
    MOV AX,20
    MUL IdxMax
    ADD SI,AX
    JMP CalorCopiarNombre
CalorSinDatos:
    LEA SI,NombreSinDatos
CalorCopiarNombre:
    LEA DI,RowMas+23
    MOV CX,20
    CLD
    REP MOVSB
    RET
LlenarFilas ENDP

;==================== PRESSURE GUAGE (2088h) ====================

EscribirPressureGuage PROC
    MOV DX,2088h
    OUT DX,AL
    RET
EscribirPressureGuage ENDP

END Inicio
