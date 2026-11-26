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
    ID                DW ?          ; handle de archivo (lo usa la biblioteca)
    RutaRaiz          DB "C:\AutonoLux",0
    RutaDaniel        DB "C:\AutonoLux\Daniel",0
    RutaCalor         DB "C:\AutonoLux\Daniel\calor.txt",0

; ---- Periodo en pantalla y porcentaje de la zona mas concurrida de cada periodo
PeriodoActual     DB 'H'        ; 'H' hoy, 'S' semana, 'M' mes
PorcentajeHoy     DB 38
PorcentajeSemana  DB 35
PorcentajeMes     DB 33

; ---- Textos cortos que se escriben sobre la pantalla
TextoPeriodoHoy     DB "HOY   "
TextoPeriodoSemana  DB "SEMANA"
TextoPeriodoMes     DB "MES   "
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

; ---- Buffer donde se lee calor.txt: 24 registros de la pantalla (hoy),
;      6 del ranking de la semana y 6 del ranking del mes (36 de 78 bytes)
BufferCalor       DB 2808 DUP(?)

; ---- Texto base de calor.txt: se escribe solo si el archivo no existe
TextoCalor        DB "+==========================================================================+",13,10
                  DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |",13,10
                  DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |",13,10
                  DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |",13,10
                  DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |",13,10
                  DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |",13,10
                  DB "+==========================================================================+",13,10
                  DB "| MAPA DE CALOR (zonas mas ocupadas)        Periodo: ______                |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "| #  ZONA                  OCUP.   INTENSIDAD            TIEMPO            |",13,10
                  DB "| 1 Lectura Silenciosa   38 %   ###################   3h 48m               |",13,10
                  DB "| 2 Sala de Computo      26 %   #############         2h 36m               |",13,10
                  DB "| 3 Sala de Grupos       17 %   ########              1h 42m               |",13,10
                  DB "| 4 Recepcion            11 %   #####                 1h 06m               |",13,10
                  DB "| 5 Hemeroteca            5 %   ##                    0h 30m               |",13,10
                  DB "| 6 Estantes A-F          3 %   #                     0h 18m               |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "| Intensidad: cada # = 2 % de la ocupacion total del periodo               |",13,10
                  DB "| Zona mas concurrida: Lectura Silenciosa                                  |",13,10
                  DB "|                                                                          |",13,10
                  DB "| [H] Hoy      [S] Semana      [M] Mes      [ESC] Volver                   |",13,10
                  DB "|                                                                          |",13,10
                  DB "| Pressure Guage: % de la zona mas concurrida                              |",13,10
                  DB "+==========================================================================+",13,10
                  DB "| 1 Lectura Silenciosa   35 %   #################     23h 40m              |",13,10
                  DB "| 2 Sala de Computo      27 %   #############         18h 10m              |",13,10
                  DB "| 3 Sala de Grupos       18 %   #########             12h 05m              |",13,10
                  DB "| 4 Recepcion            10 %   #####                 6h 50m               |",13,10
                  DB "| 5 Hemeroteca            6 %   ###                   4h 15m               |",13,10
                  DB "| 6 Estantes A-F          4 %   ##                    2h 30m               |",13,10
                  DB "| 1 Lectura Silenciosa   33 %   ################      94h 20m              |",13,10
                  DB "| 2 Sala de Computo      28 %   ##############        78h 45m              |",13,10
                  DB "| 3 Sala de Grupos       19 %   #########             52h 10m              |",13,10
                  DB "| 4 Recepcion            10 %   #####                 27h 30m              |",13,10
                  DB "| 5 Hemeroteca            6 %   ###                   15h 55m              |",13,10
                  DB "| 6 Estantes A-F          4 %   ##                    10h 40m              |",13,10

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaDaniel
    CALL ControlCalor
Fin:
    MOV AX,4C00H                ; termina con codigo 0
    INT 21H

;==================== MAPA DE CALOR ====================

; Teclas: H hoy, S semana, M mes, ESC volver
ControlCalor PROC
    ABRIR_ARCHIVO RutaCalor,0
    JC CalorNoExiste
    JMP CalorAbierto
CalorNoExiste:
    CALL CrearCalorInicial      ; el archivo no existe: se crea con la pantalla base
    ABRIR_ARCHIVO RutaCalor,0
    JC ErrorAlLeerCalor
CalorAbierto:
    LEER_ARCHIVO 2808,BufferCalor,ID
    JC ErrorAlLeerCalor
    CERRAR_ARCHIVO ID
    MOV PeriodoActual,'H'
CalorRedibujar:
    CALL DibujarCalor
    CALL PintarPeriodo
CalorEsperarTecla:
    RASTREO
    CMP AL,27                   ; ESC
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

; Crea calor.txt con la pantalla base (solo cuando todavia no existe)
CrearCalorInicial PROC
    CREAR_ARCHIVO RutaCalor,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,2808,TextoCalor
    CERRAR_ARCHIVO ID
    RET
CrearCalorInicial ENDP

; Dibuja la pantalla de HOY con los renglones leidos de calor.txt (cada registro mide 78 bytes)
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

; Escribe el periodo, cambia el ranking si es semana o mes y mueve el Pressure Guage
PintarPeriodo PROC
    CMP PeriodoActual,'S'
    JE PintarPeriodoSemana
    CMP PeriodoActual,'M'
    JE PintarPeriodoMes
    IMPCAD_COLOR TextoPeriodoHoy,6,7,53,0,0,1Eh
    MOV AL,PorcentajeHoy        ; el ranking de hoy ya esta dibujado
    CALL EscribirPressureGuage
    RET
PintarPeriodoSemana:
    IMPCAD_COLOR TextoPeriodoSemana,6,7,53,0,0,1Eh
    CALL DibujarRankingSemana
    MOV AL,PorcentajeSemana
    CALL EscribirPressureGuage
    RET
PintarPeriodoMes:
    IMPCAD_COLOR TextoPeriodoMes,6,7,53,0,0,1Eh
    CALL DibujarRankingMes
    MOV AL,PorcentajeMes
    CALL EscribirPressureGuage
    RET
PintarPeriodo ENDP

; Renglones 10 a 15 con el ranking de la semana (registros 24 a 29 de calor.txt)
DibujarRankingSemana PROC
    IMPCAD_COLOR BufferCalor+1872,76,10,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+1950,76,11,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2028,76,12,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2106,76,13,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2184,76,14,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2262,76,15,0,0,0,1Fh
    RET
DibujarRankingSemana ENDP

; Renglones 10 a 15 con el ranking del mes (registros 30 a 35 de calor.txt)
DibujarRankingMes PROC
    IMPCAD_COLOR BufferCalor+2340,76,10,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2418,76,11,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2496,76,12,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2574,76,13,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2652,76,14,0,0,0,1Fh
    IMPCAD_COLOR BufferCalor+2730,76,15,0,0,0,1Fh
    RET
DibujarRankingMes ENDP


;==================== PRESSURE GUAGE (2088h) ====================

; Entrada: AL = porcentaje de la zona mas concurrida (el formato del device es un SUPUESTO)
EscribirPressureGuage PROC
    MOV DX,2088h
    OUT DX,AL
    RET
EscribirPressureGuage ENDP

END Inicio
