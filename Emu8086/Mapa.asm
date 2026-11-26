;*********************************************************
; VILLA CAMPOS JESUS OBED
; Guardar como: Mapa.asm
; Pantalla: Mapa de la biblioteca (Dot Matrix, Switches y LEDs). Lee y actualiza mapa.txt.
; Programa independiente: se compila a Mapa.exe (emu8086).
; Necesita Biblioteca.txt en la misma carpeta.
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?
    RutaRaiz          DB "C:\AutonoLux",0
    RutaJesus         DB "C:\AutonoLux\Jesus",0
    RutaMapa          DB "C:\AutonoLux\Jesus\mapa.txt",0

OcupacionPorZona  DB 0,0,0,0,0,0
LuzPorZona        DB 0,0,0,0,0,0
ModoGlobal        DB 'A'
ZonaSeleccionada  DB 9
ZonaActual        DB 0
SwitchesLeidos    DB 0
PesoDeZona        DB 1,2,4,8,16,32
RenglonDeZona     DB 11,11,11,16,16,16
ColumnaDeMarca    DB 8,32,56,8,32,56
ColumnaDePersonas DB 14,38,62,14,38,62
OffsetMarca       DW 866,890,914,1256,1280,1304
OffsetPersonas    DW 872,896,920,1262,1286,1310

FuenteDigitos     DB 00h,42h,7Fh,40h,00h
                  DB 42h,61h,51h,49h,46h
                  DB 21h,41h,45h,4Bh,31h
                  DB 18h,14h,12h,7Fh,10h
                  DB 27h,45h,45h,45h,39h
                  DB 3Ch,4Ah,49h,49h,30h

TextoNumero       DB "000"
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"
TextoZona         DB "1"
MarcaOcupada      DB "[#]"
MarcaLibre        DB "[ ]"
TextoLuzOn        DB "ON "
TextoLuzOff       DB "OFF"

RutaVisitantes    DB "C:\AutonoLux\Jesus\visitantes.txt",0
RegistroVis       DB 58 DUP(0)
SalaContador      DW 0
EnZonas           DW 0
SinUbicar         DW 0
Bloqueado         DB 0
TextoEstadoA      DB "En sala (Contador): "
MSala             DB "000"
TextoEstadoB      DB "   En zonas: "
MZonas            DB "0"
TextoEstadoC      DB "   Sin ubicar: "
MSin              DB "000"
TextoEstadoD      DB "               "

BufferMapa        DB 1872 DUP(?)

LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"

TextoMapa         DB "+==========================================================================+",13,10
                  DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |",13,10
                  DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |",13,10
                  DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |",13,10
                  DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |",13,10
                  DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |",13,10
                  DB "+==========================================================================+",13,10
                  DB "| MAPA DE LA BIBLIOTECA          [#] ocupada     [ ] libre                 |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "|   +------------------+    +------------------+    +------------------+   |",13,10
                  DB "|   | 1 Recepcion      |    | 2 Lectura Silenciosa|    | 3 Sala de Computo||",13,10
                  DB "|   |   [ ]   ___ pers.|    |   [ ]   ___ pers.|    |   [ ]   ___ pers.|   |",13,10
                  DB "|   +------------------+    +------------------+    +------------------+   |",13,10
                  DB "|                                                                          |",13,10
                  DB "|   +------------------+    +------------------+    +------------------+   |",13,10
                  DB "|   | 4 Hemeroteca     |    | 5 Estantes A-F   |    | 6 Sala de Grupos |   |",13,10
                  DB "|   |   [ ]   ___ pers.|    |   [ ]   ___ pers.|    |   [ ]   ___ pers.|   |",13,10
                  DB "|   +------------------+    +------------------+    +------------------+   |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "| Detalle: zona _   personas: ___   luz: ___                               |",13,10
                  DB "| [1-6] Detalle de zona     [S] Leer sensores     [ESC] Volver             |",13,10
                  DB "| Dot Matrix: numero de zona = ocupada   Switches: sensores   LEDs: luces  |",13,10
                  DB "|                                                                          |",13,10
                  DB "+==========================================================================+",13,10

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    CREAR_CARPETA RutaRaiz
    CREAR_CARPETA RutaJesus
    CALL MostrarMapa
Fin:
    MOV AX,4C00H
    INT 21H

;==================== MAPA DE LA BIBLIOTECA ====================

MostrarMapa PROC
    ABRIR_ARCHIVO RutaMapa,0
    JC MapaNoExiste
    JMP MapaAbierto
MapaNoExiste:
    CALL CrearMapaInicial
    ABRIR_ARCHIVO RutaMapa,0
    JC ErrorAlLeerMapa
MapaAbierto:
    LEER_ARCHIVO 1872,BufferMapa,ID
    JC ErrorAlLeerMapa
    CERRAR_ARCHIVO ID
    CALL DibujarMapa
MapaEsperarTecla:
    CALL ActualizarMapa
    RASTREO
    CMP AL,27
    JE MapaSalir
    CMP AL,'S'
    JE MapaLeerSensores
    CMP AL,'1'
    JC MapaEsperarTecla
    CMP AL,'7'
    JC MapaZonaValida
    JMP MapaEsperarTecla
MapaZonaValida:
    SUB AL,'1'
    MOV ZonaSeleccionada,AL
    JMP MapaEsperarTecla
MapaLeerSensores:
    CALL LeerSwitches
    CALL GuardarMapa
    JMP MapaEsperarTecla
MapaSalir:
    CALL GuardarMapa
    RET
ErrorAlLeerMapa:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
MostrarMapa ENDP

CrearMapaInicial PROC
    CREAR_ARCHIVO RutaMapa,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,1872,TextoMapa
    CERRAR_ARCHIVO ID
    RET
CrearMapaInicial ENDP

GuardarMapa PROC
    CREAR_ARCHIVO RutaMapa,32
    MOV ID,AX
    JC FinGuardarMapa
    ESCRIBIR_ARCHIVO ID,1872,BufferMapa
    CERRAR_ARCHIVO ID
FinGuardarMapa:
    RET
GuardarMapa ENDP

DibujarMapa PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR BufferMapa,76,0,0,0,0,1Bh
    IMPCAD_COLOR BufferMapa+78,76,1,0,0,0,1Eh
    IMPCAD_COLOR BufferMapa+156,76,2,0,0,0,1Eh
    IMPCAD_COLOR BufferMapa+234,76,3,0,0,0,1Eh
    IMPCAD_COLOR BufferMapa+312,76,4,0,0,0,1Eh
    IMPCAD_COLOR BufferMapa+390,76,5,0,0,0,1Eh
    IMPCAD_COLOR BufferMapa+468,76,6,0,0,0,1Bh
    IMPCAD_COLOR BufferMapa+546,76,7,0,0,0,1Eh
    IMPCAD_COLOR BufferMapa+624,76,8,0,0,0,17h
    IMPCAD_COLOR BufferMapa+702,76,9,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+780,76,10,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+858,76,11,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+936,76,12,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1014,76,13,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1092,76,14,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1170,76,15,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1248,76,16,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1326,76,17,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1404,76,18,0,0,0,17h
    IMPCAD_COLOR BufferMapa+1482,76,19,0,0,0,1Eh
    IMPCAD_COLOR BufferMapa+1560,76,20,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1638,76,21,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1716,76,22,0,0,0,1Fh
    IMPCAD_COLOR BufferMapa+1794,76,23,0,0,0,1Bh
    RET
DibujarMapa ENDP

ActualizarMapa PROC
    CALL LeerSalaContador
    CALL AjustarASala
    CMP ModoGlobal,'A'
    JNE MapaSinAutomatico
    CALL AplicarModoAutomatico
MapaSinAutomatico:
    CALL PintarZonasDelMapa
    CALL PintarDetalleDelMapa
    CALL PintarEstadoMapa
    CALL EscribirDotMatrix
    CALL EscribirLeds
    RET
ActualizarMapa ENDP

PintarZonasDelMapa PROC
    MOV ZonaActual,0
PintarSiguienteZona:
    CALL PintarUnaZona
    ADD ZonaActual,1
    CMP ZonaActual,6
    JNE PintarSiguienteZona
    RET
PintarZonasDelMapa ENDP

PintarUnaZona PROC
    MOV BL,ZonaActual
    MOV BH,0
    CMP OcupacionPorZona[BX],0
    JE PintarZonaLibre
    IMPCAD_COLOR MarcaOcupada,3,RenglonDeZona[BX],ColumnaDeMarca[BX],0,0,1Ah
    JMP PintarPersonasDeZona
PintarZonaLibre:
    IMPCAD_COLOR MarcaLibre,3,RenglonDeZona[BX],ColumnaDeMarca[BX],0,0,1Fh
PintarPersonasDeZona:
    MOV BL,ZonaActual
    MOV BH,0
    MOV AL,OcupacionPorZona[BX]
    CALL ConvertirATexto
    MOV BL,ZonaActual
    MOV BH,0
    IMPCAD_COLOR TextoNumero,3,RenglonDeZona[BX],ColumnaDePersonas[BX],0,0,1Fh
    CALL GuardarZonaEnBuffer
    RET
PintarUnaZona ENDP

GuardarZonaEnBuffer PROC
    MOV BL,ZonaActual
    MOV BH,0
    MOV SI,BX
    ADD SI,SI
    MOV DI,OffsetMarca[SI]
    MOV AL,' '
    CMP OcupacionPorZona[BX],0
    JE GuardarMarca
    MOV AL,'#'
GuardarMarca:
    MOV BufferMapa[DI+1],AL
    MOV DI,OffsetPersonas[SI]
    MOV AL,TextoNumero
    MOV BufferMapa[DI],AL
    MOV AL,TextoNumero+1
    MOV BufferMapa[DI+1],AL
    MOV AL,TextoNumero+2
    MOV BufferMapa[DI+2],AL
    RET
GuardarZonaEnBuffer ENDP

PintarDetalleDelMapa PROC
    CMP ZonaSeleccionada,9
    JNE MostrarDetalleDeZona
    RET
MostrarDetalleDeZona:
    MOV AL,ZonaSeleccionada
    ADD AL,'1'
    MOV TextoZona,AL
    IMPCAD_COLOR TextoZona,1,19,16,0,0,1Eh
    MOV BL,ZonaSeleccionada
    MOV BH,0
    MOV AL,OcupacionPorZona[BX]
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,19,30,0,0,1Eh
    MOV BL,ZonaSeleccionada
    MOV BH,0
    CMP LuzPorZona[BX],0
    JE DetalleLuzApagada
    IMPCAD_COLOR TextoLuzOn,3,19,41,0,0,1Ah
    RET
DetalleLuzApagada:
    IMPCAD_COLOR TextoLuzOff,3,19,41,0,0,1Ch
    RET
PintarDetalleDelMapa ENDP

;==================== DEVICES DEL MAPA ====================

AplicarModoAutomatico PROC
    MOV BX,0
AutomaticoSiguienteZona:
    MOV LuzPorZona[BX],0
    CMP OcupacionPorZona[BX],0
    JE AutomaticoZonaVacia
    MOV LuzPorZona[BX],1
AutomaticoZonaVacia:
    ADD BX,1
    CMP BX,6
    JNE AutomaticoSiguienteZona
    RET
AplicarModoAutomatico ENDP

LeerSwitches PROC
    MOV Bloqueado,0
    MOV DX,2084h
    IN AL,DX
    CMP AL,128
    JC SwitchSinBit7
    SUB AL,128
SwitchSinBit7:
    CMP AL,64
    JC SwitchSinBit6
    SUB AL,64
SwitchSinBit6:
    MOV SwitchesLeidos,AL
    MOV BX,5
SwitchSiguienteZona:
    MOV AL,SwitchesLeidos
    CMP AL,PesoDeZona[BX]
    JC SwitchApagado
    SUB AL,PesoDeZona[BX]
    MOV SwitchesLeidos,AL
    CMP OcupacionPorZona[BX],0
    JNE SwitchSiguiente
    CALL ContarEnZonas
    MOV AX,SalaContador
    CMP AX,EnZonas
    JC SwitchSinPersonas
    JE SwitchSinPersonas
    MOV OcupacionPorZona[BX],1
    JMP SwitchSiguiente
SwitchSinPersonas:
    MOV Bloqueado,1
    MOV OcupacionPorZona[BX],0
    JMP SwitchSiguiente
SwitchApagado:
    MOV OcupacionPorZona[BX],0
SwitchSiguiente:
    CMP BX,0
    JE FinLeerSwitches
    SUB BX,1
    JMP SwitchSiguienteZona
FinLeerSwitches:
    RET
LeerSwitches ENDP

EscribirDotMatrix PROC
    MOV DX,2000h
    MOV SI,0
    MOV BX,0
DotSiguienteModulo:
    MOV CX,5
DotSiguienteColumna:
    MOV AL,0
    CMP OcupacionPorZona[BX],0
    JE DotEscribirColumna
    MOV AL,FuenteDigitos[SI]
DotEscribirColumna:
    OUT DX,AL
    ADD DX,1
    ADD SI,1
    SUB CX,1
    CMP CX,0
    JNE DotSiguienteColumna
    ADD BX,1
    CMP BX,6
    JNE DotSiguienteModulo
    RET
EscribirDotMatrix ENDP

EscribirLeds PROC
    MOV AL,0
    MOV BX,0
LedsSiguienteZona:
    CMP LuzPorZona[BX],0
    JE LedsZonaApagada
    ADD AL,PesoDeZona[BX]
LedsZonaApagada:
    ADD BX,1
    CMP BX,6
    JNE LedsSiguienteZona
    CMP ModoGlobal,'M'
    JNE LedsEscribir
    ADD AL,64
LedsEscribir:
    MOV DX,2070h
    OUT DX,AL
    RET
EscribirLeds ENDP

;==================== CONVERSION ====================

;==================== COHERENCIA CON EL CONTADOR ====================

LeerSalaContador PROC
    MOV SalaContador,0
    ABRIR_ARCHIVO RutaVisitantes,0
    JC FinLeerSala
VisitanteOtro:
    LEER_ARCHIVO 58,RegistroVis,ID
    JC VisitanteFin
    CMP AX,58
    JE VisitanteOtro
VisitanteFin:
    CERRAR_ARCHIVO ID
    XOR AX,AX
    MOV SI,19
    MOV CX,3
SalaDigito:
    MOV BL,RegistroVis[SI]
    CMP BL,'0'
    JC SalaSalta
    CMP BL,':'
    JNC SalaSalta
    MOV DX,10
    MUL DX
    SUB BL,'0'
    MOV BH,0
    ADD AX,BX
SalaSalta:
    ADD SI,1
    SUB CX,1
    CMP CX,0
    JNE SalaDigito
    MOV SalaContador,AX
FinLeerSala:
    RET
LeerSalaContador ENDP

ContarEnZonas PROC
    MOV EnZonas,0
    MOV SI,0
ContarSiguiente:
    MOV AL,OcupacionPorZona[SI]
    MOV AH,0
    ADD EnZonas,AX
    ADD SI,1
    CMP SI,6
    JNE ContarSiguiente
    RET
ContarEnZonas ENDP

AjustarASala PROC
    MOV BX,5
AjustarSiguiente:
    CALL ContarEnZonas
    MOV AX,SalaContador
    CMP AX,EnZonas
    JNC AjustarListo
    MOV OcupacionPorZona[BX],0
    CMP BX,0
    JE AjustarListo
    SUB BX,1
    JMP AjustarSiguiente
AjustarListo:
    RET
AjustarASala ENDP

PintarEstadoMapa PROC
    CALL ContarEnZonas
    MOV AX,SalaContador
    SUB AX,EnZonas
    JNC SinUbicarOk
    MOV AX,0
SinUbicarOk:
    MOV SinUbicar,AX
    MOV AL,BYTE PTR SalaContador
    CALL ConvertirATexto
    MOV AL,TextoNumero
    MOV MSala,AL
    MOV AL,TextoNumero+1
    MOV MSala+1,AL
    MOV AL,TextoNumero+2
    MOV MSala+2,AL
    MOV AL,BYTE PTR EnZonas
    CALL ConvertirATexto
    MOV AL,TextoNumero+2
    MOV MZonas,AL
    MOV AL,BYTE PTR SinUbicar
    CALL ConvertirATexto
    MOV AL,TextoNumero
    MOV MSin,AL
    MOV AL,TextoNumero+1
    MOV MSin+1,AL
    MOV AL,TextoNumero+2
    MOV MSin+2,AL
    MOV BL,1Eh
    CMP Bloqueado,0
    JE EstadoColor
    MOV BL,1Ch
EstadoColor:
    IMPCAD_COLOR TextoEstadoA,70,22,3,0,0,BL
    RET
PintarEstadoMapa ENDP

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
    RET
ConvertirATexto ENDP

END Inicio
