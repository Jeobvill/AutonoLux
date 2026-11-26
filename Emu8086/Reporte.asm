;*********************************************************
; ALTAMIRANO MURILLO AXEL GABRIEL
; Guardar como: Reporte.asm
; Pantalla: Reporte del dia (LCD e Impresora). Escribe reporte.txt.
; Programa independiente: se compila a Reporte.exe (emu8086).
; Necesita Biblioteca.txt, Dispositivos.asm y Dispositivos_Datos.asm en la misma carpeta.
; Los valores del resumen se calculan al abrir: visitantes.txt, mapa.txt, iluminacion.txt, config.txt y la fecha/hora de DOS.
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?          ; handle de archivo (lo usa la biblioteca)
    RutaRaiz          DB "C:\AutonoLux",0
    RutaAxel          DB "C:\AutonoLux\Axel",0
    RutaReporte       DB "C:\AutonoLux\Axel\reporte.txt",0

; ---- Notas del operador (maximo 3). Inician vacias
NotasCapturadas   DB 0
LongitudTrabajo   DW 0
FinDeLinea        DB 13,10

; ---- Cada nota es un buffer de DOS: maximo, longitud y texto
Nota1             DB 61
Nota1Longitud     DB 0
Nota1Texto        DB 62 DUP(0)
Nota2             DB 61
Nota2Longitud     DB 0
Nota2Texto        DB 62 DUP(0)
Nota3             DB 61
Nota3Longitud     DB 0
Nota3Texto        DB 62 DUP(0)

; ---- Textos cortos y mensajes (74 caracteres cada mensaje)
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"
MensajeGuardado   DB "   Reporte guardado en reporte.txt. Presione una tecla para continuar.    "
MensajeImpreso    DB "   Reporte enviado a la impresora. Presione una tecla para continuar.     "
MensajeNotasLlenas DB "   Maximo 3 notas por reporte. Presione una tecla para continuar.         "

; ---- Texto del reporte (318 bytes, con los campos de datos reales): se guarda en reporte.txt y se imprime
TextoReporte     DB "AUTONOLUX - REPORTE DEL DIA",13,10
                  DB "Fecha: "
TFecha            DB "00/00/0000"
                  DB "   Hora: "
THora             DB "00:00",13,10
                  DB "VISITANTES: entradas "
TEnt              DB "000"
                  DB ", salidas "
TSal              DB "000"
                  DB ", pico "
TPico             DB "000"
                  DB ", en sala "
TSala             DB "000",13,10
                  DB "OCUPACION: "
TZOc              DB "0"
                  DB " de 6 zonas, "
TPers             DB "000"
                  DB " personas (aforo maximo "
TAforo            DB "000"
                  DB ")",13,10
                  DB "ILUMINACION: "
TZLuz             DB "0"
                  DB " zonas con luz, "
TLamp             DB "000"
                  DB " lamparas, "
TManual           DB "0"
                  DB " en modo manual",13,10
                  DB "ENERGIA: potencia "
TPot              DB "000"
                  DB " W, sin automatizacion "
TPotSin           DB "000"
                  DB " W",13,10
                  DB "AHORRO: "
TAhorro           DB "000"
                  DB " %",13,10
                  DB "NOTAS:",13,10

; ---- Renglones comunes (banner AUTONOLUX) y propios de la pantalla
LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"
ReporteRen07      DB "|  REPORTE DEL DIA              Fecha: "
RFecha            DB "00/00/0000"
                  DB "      Hora: "
RHora             DB "00:00"
                  DB "         |"
ReporteRen08       DB "|--------------------------------------------------------------------------|"
ReporteRen09       DB "| RESUMEN GENERAL                                                          |"
ReporteRen10      DB "|   Entradas: "
REnt              DB "000"
                  DB "    Salidas: "
RSal              DB "000"
                  DB "    Pico: "
RPico             DB "000"
                  DB " personas                    |"
ReporteRen11      DB "|   En sala ahora: "
RSala             DB "000"
                  DB "   Aforo maximo: "
RAforo            DB "000"
                  DB "   Zonas ocupadas: "
RZOc              DB "0"
                  DB "/6, "
RPers             DB "000"
                  DB " pers.|"
ReporteRen12       DB "| ZONAS Y ENERGIA                                                          |"
ReporteRen13      DB "|   Zonas con luz encendida: "
RZLuz             DB "0"
                  DB " de 6        Lamparas encendidas: "
RLamp             DB "000"
                  DB "        |"
ReporteRen14      DB "|   Potencia encendida: "
RPot              DB "000"
                  DB " W        Sin automatizacion: "
RPotSin           DB "000"
                  DB " W             |"
ReporteRen15      DB "|   AHORRO: "
RAhorro           DB "000"
                  DB " % frente a luces siempre encendidas                        |"
ReporteRen16       DB "| INCIDENCIAS                                                              |"
ReporteRen17      DB "|   Zonas en modo manual: "
RManual           DB "0"
                  DB "        Zonas en modo automatico: "
RAuto             DB "0"
                  DB "             |"
ReporteRen18       DB "| NOTAS DEL OPERADOR  ([N] agrega, maximo 3)                               |"
ReporteRen19       DB "|   1.                                                                     |"
ReporteRen20       DB "|   2.                                                                     |"
ReporteRen21       DB "|   3.                                                                     |"
ReporteRen22       DB "|  [N] Nota   [G] Guardar   [I] Imprimir   [ESC] Volver                    |"

; ---- Datos reales que alimentan el reporte (se leen de los archivos de los demas programas)
RutaMapa          DB "C:\AutonoLux\Jesus\mapa.txt",0
RutaIluminacion   DB "C:\AutonoLux\Jesus\iluminacion.txt",0
RutaVisitantes    DB "C:\AutonoLux\Jesus\visitantes.txt",0
RutaConfiguracion DB "C:\AutonoLux\Sergio\config.txt",0
BufferMapa        DB 1872 DUP(0)
BufferIlum        DB 180 DUP(0)
RegistroVis       DB 58 DUP(0)      ; ultimo registro de visitantes.txt (58 bytes)
BufferConfig      DB 256 DUP(0)
TextoNumero       DB "000"
VisSala           DW 0
VisEntradas       DW 0
VisSalidas        DW 0
VisPico           DW 0
AforoMaximo       DW 60              ; opcion 2 de config.txt
WattsLampara      DW 18              ; opcion 3 de config.txt
LamparasPorZona   DW 4
ZonasOcupadas     DW 0
PersonasZonas     DW 0
ZonasConLuz       DW 0
ZonasManual       DW 0
LamparasOn        DW 0
PotenciaOn        DW 0
PotenciaSinAuto   DW 0
AhorroPorcentaje  DW 0
OffsetsPersonas   DW 872,896,920,1262,1286,1310   ; columna de personas de cada zona en mapa.txt
PorcentajeZonas   DB 0,17,33,50,67,83,100

; ---- Datos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos_Datos.asm

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaAxel
    CALL LeerDatosReporte       ; numeros reales de los demas programas
    CALL ArmarReporte
    CALL ControlReporte
Fin:
    MOV AX,4C00H                ; termina con codigo 0
    INT 21H

;==================== REPORTE DEL DIA ====================

; Teclas: N nota, G guardar, I imprimir, ESC volver
ControlReporte PROC
    MOV NotasCapturadas,0
ReporteRedibujar:
    CALL DibujarReporte
    CALL PintarNotas
    CURSOR 22,60,0
    RASTREO
    CMP AL,27                   ; ESC
    JE ReporteSalir
    CMP AL,'N'
    JE ReporteNota
    CMP AL,'G'
    JE ReporteGuardar
    CMP AL,'I'
    JE ReporteImprimir
    JMP ReporteRedibujar
ReporteNota:
    CALL CapturarNota
    JMP ReporteRedibujar
ReporteGuardar:
    CALL GuardarReporte
    JMP ReporteRedibujar
ReporteImprimir:
    CALL ImprimirReporte
    JMP ReporteRedibujar
ReporteSalir:
    RET
ControlReporte ENDP

; Dibuja la pantalla del reporte (renglones fijos)
DibujarReporte PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR LineaMarco,76,0,0,0,0,1Bh
    IMPCAD_COLOR Logo1,76,1,0,0,0,1Eh
    IMPCAD_COLOR Logo2,76,2,0,0,0,1Eh
    IMPCAD_COLOR Logo3,76,3,0,0,0,1Eh
    IMPCAD_COLOR Logo4,76,4,0,0,0,1Eh
    IMPCAD_COLOR Logo5,76,5,0,0,0,1Eh
    IMPCAD_COLOR LineaMarco,76,6,0,0,0,1Bh
    IMPCAD_COLOR ReporteRen07,76,7,0,0,0,1Eh
    IMPCAD_COLOR ReporteRen08,76,8,0,0,0,17h
    IMPCAD_COLOR ReporteRen09,76,9,0,0,0,1Eh
    IMPCAD_COLOR ReporteRen10,76,10,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen11,76,11,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen12,76,12,0,0,0,1Eh
    IMPCAD_COLOR ReporteRen13,76,13,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen14,76,14,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen15,76,15,0,0,0,1Ah
    IMPCAD_COLOR ReporteRen16,76,16,0,0,0,1Eh
    IMPCAD_COLOR ReporteRen17,76,17,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen18,76,18,0,0,0,1Eh
    IMPCAD_COLOR ReporteRen19,76,19,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen20,76,20,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen21,76,21,0,0,0,1Fh
    IMPCAD_COLOR ReporteRen22,76,22,0,0,0,1Fh
    IMPCAD_COLOR LineaMarco,76,23,0,0,0,1Bh
    RET
DibujarReporte ENDP

;==================== NOTAS ====================

; Captura la nota que sigue (renglones 19, 20 y 21). Maximo 3
CapturarNota PROC
    MOV AL,NotasCapturadas
    CMP AL,3
    JE NotasLlenas
    CMP AL,0
    JE CapturarNota1
    CMP AL,1
    JE CapturarNota2
    CURSOR 21,7,0
    LECTURA_CADENA Nota3
    JMP NotaCapturada
CapturarNota1:
    CURSOR 19,7,0
    LECTURA_CADENA Nota1
    JMP NotaCapturada
CapturarNota2:
    CURSOR 20,7,0
    LECTURA_CADENA Nota2
NotaCapturada:
    ADD NotasCapturadas,1
    RET
NotasLlenas:
    IMPCAD_COLOR MensajeNotasLlenas,74,22,1,0,0,1Eh
    RASTREO
    RET
CapturarNota ENDP

; Dibuja las notas ya capturadas sobre la pantalla
PintarNotas PROC
    CMP NotasCapturadas,0
    JE FinPintarNotas
    CALL PintarNota1
    CMP NotasCapturadas,1
    JE FinPintarNotas
    CALL PintarNota2
    CMP NotasCapturadas,2
    JE FinPintarNotas
    CALL PintarNota3
FinPintarNotas:
    RET
PintarNotas ENDP


; Escribe las notas capturadas en reporte.txt
EscribirNotas PROC
    CMP NotasCapturadas,0
    JE FinEscribirNotas
    CALL EscribirNota1
    CMP NotasCapturadas,1
    JE FinEscribirNotas
    CALL EscribirNota2
    CMP NotasCapturadas,2
    JE FinEscribirNotas
    CALL EscribirNota3
FinEscribirNotas:
    RET
EscribirNotas ENDP


; Manda las notas capturadas a la impresora
ImprimirNotas PROC
    CMP NotasCapturadas,0
    JE FinImprimirNotas
    CALL ImprimirNota1
    CMP NotasCapturadas,1
    JE FinImprimirNotas
    CALL ImprimirNota2
    CMP NotasCapturadas,2
    JE FinImprimirNotas
    CALL ImprimirNota3
FinImprimirNotas:
    RET
ImprimirNotas ENDP


; Nota 1: renglon 19
PintarNota1 PROC
    MOV AL,Nota1Longitud
    MOV AH,0
    MOV LongitudTrabajo,AX
    IMPCAD_COLOR Nota1Texto,LongitudTrabajo,19,7,0,0,1Fh
    RET
PintarNota1 ENDP

EscribirNota1 PROC
    MOV AL,Nota1Longitud
    MOV AH,0
    MOV LongitudTrabajo,AX
    ESCRIBIR_ARCHIVO ID,LongitudTrabajo,Nota1Texto
    ESCRIBIR_ARCHIVO ID,2,FinDeLinea
    RET
EscribirNota1 ENDP

ImprimirNota1 PROC
    LEA SI,Nota1Texto
    MOV AL,Nota1Longitud
    MOV AH,0
    MOV CX,AX
    CALL EnviarAImpresora
    IMPRIMIR 13
    IMPRIMIR 10
    RET
ImprimirNota1 ENDP

; Nota 2: renglon 20
PintarNota2 PROC
    MOV AL,Nota2Longitud
    MOV AH,0
    MOV LongitudTrabajo,AX
    IMPCAD_COLOR Nota2Texto,LongitudTrabajo,20,7,0,0,1Fh
    RET
PintarNota2 ENDP

EscribirNota2 PROC
    MOV AL,Nota2Longitud
    MOV AH,0
    MOV LongitudTrabajo,AX
    ESCRIBIR_ARCHIVO ID,LongitudTrabajo,Nota2Texto
    ESCRIBIR_ARCHIVO ID,2,FinDeLinea
    RET
EscribirNota2 ENDP

ImprimirNota2 PROC
    LEA SI,Nota2Texto
    MOV AL,Nota2Longitud
    MOV AH,0
    MOV CX,AX
    CALL EnviarAImpresora
    IMPRIMIR 13
    IMPRIMIR 10
    RET
ImprimirNota2 ENDP

; Nota 3: renglon 21
PintarNota3 PROC
    MOV AL,Nota3Longitud
    MOV AH,0
    MOV LongitudTrabajo,AX
    IMPCAD_COLOR Nota3Texto,LongitudTrabajo,21,7,0,0,1Fh
    RET
PintarNota3 ENDP

EscribirNota3 PROC
    MOV AL,Nota3Longitud
    MOV AH,0
    MOV LongitudTrabajo,AX
    ESCRIBIR_ARCHIVO ID,LongitudTrabajo,Nota3Texto
    ESCRIBIR_ARCHIVO ID,2,FinDeLinea
    RET
EscribirNota3 ENDP

ImprimirNota3 PROC
    LEA SI,Nota3Texto
    MOV AL,Nota3Longitud
    MOV AH,0
    MOV CX,AX
    CALL EnviarAImpresora
    IMPRIMIR 13
    IMPRIMIR 10
    RET
ImprimirNota3 ENDP


;==================== GUARDAR E IMPRIMIR ====================

; Escribe reporte.txt: resumen + notas, y avisa en el LCD
GuardarReporte PROC
    CREAR_ARCHIVO RutaReporte,32
    MOV ID,AX
    JC ErrorAlGuardarReporte
    ESCRIBIR_ARCHIVO ID,318,TextoReporte
    CALL EscribirNotas
    CERRAR_ARCHIVO ID
    CALL MostrarLcdGuardado
    IMPCAD_COLOR MensajeGuardado,74,22,1,0,0,1Ah
    RASTREO
    RET
ErrorAlGuardarReporte:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
GuardarReporte ENDP

; Imprime resumen + notas y hace salto de pagina
ImprimirReporte PROC
    LEA SI,TextoReporte
    MOV CX,318
    CALL EnviarAImpresora
    CALL ImprimirNotas
    NEWPAGE
    IMPCAD_COLOR MensajeImpreso,74,22,1,0,0,1Ah
    RASTREO
    RET
ImprimirReporte ENDP

; Manda a la impresora CX caracteres desde [SI]
EnviarAImpresora PROC
    CMP CX,0
    JE FinEnviarAImpresora
EnviarSiguienteLetra:
    IMPRIMIR [SI]
    ADD SI,1
    SUB CX,1
    CMP CX,0
    JNE EnviarSiguienteLetra
FinEnviarAImpresora:
    RET
EnviarAImpresora ENDP

;==================== LCD ====================

; LCD: Reporte guardado
MostrarLcdGuardado PROC
    CALL LimpiarLcd
    MOV DX,2040h                ; linea 1
    LEA SI,LcdGuardado
    CALL EscribirLcd
    RET
MostrarLcdGuardado ENDP

;==================== DATOS REALES DEL REPORTE ====================

; Convierte los CX caracteres que empiezan en [DI] en un numero (AX); ignora espacios
ParseDigitos PROC
    XOR AX,AX
ParseSiguiente:
    CMP CX,0
    JE FinParse
    MOV BL,[DI]
    CMP BL,'0'
    JC ParseSalta               ; menor que '0'
    CMP BL,':'
    JNC ParseSalta              ; mayor que '9'
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

; Busca "Opcion N: " en BufferConfig.  Entrada: AL = digito.  Salida: SI = valor, CF=1 si no esta
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

; Numero que empieza en BufferConfig[SI]
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

; Lee los archivos reales y llena las variables del reporte
LeerDatosReporte PROC
    ; ---- config.txt: aforo (opcion 2) y watts por lampara (opcion 3)
    ABRIR_ARCHIVO RutaConfiguracion,0
    JC LeerVisitantes
    LEER_ARCHIVO 255,BufferConfig,ID
    CERRAR_ARCHIVO ID
    MOV AL,'2'
    CALL BuscarOpcion
    JC ConfigWatts
    CALL LeerNumeroConfig
    CMP AX,0
    JE ConfigWatts
    MOV AforoMaximo,AX
ConfigWatts:
    MOV AL,'3'
    CALL BuscarOpcion
    JC LeerVisitantes
    CALL LeerNumeroConfig
    CMP AX,0
    JE LeerVisitantes
    MOV WattsLampara,AX
LeerVisitantes:
    ; ---- visitantes.txt: se leen todos los registros de 58 bytes y queda el ultimo
    ABRIR_ARCHIVO RutaVisitantes,0
    JC LeerMapaReal
VisitantesOtro:
    LEER_ARCHIVO 58,RegistroVis,ID
    JC VisitantesFin
    CMP AX,58
    JE VisitantesOtro
VisitantesFin:
    CERRAR_ARCHIVO ID
    MOV CX,3
    LEA DI,RegistroVis+19       ; sala
    CALL ParseDigitos
    MOV VisSala,AX
    MOV CX,3
    LEA DI,RegistroVis+32       ; entradas
    CALL ParseDigitos
    MOV VisEntradas,AX
    MOV CX,3
    LEA DI,RegistroVis+44       ; salidas
    CALL ParseDigitos
    MOV VisSalidas,AX
    MOV CX,3
    LEA DI,RegistroVis+53       ; pico
    CALL ParseDigitos
    MOV VisPico,AX
LeerMapaReal:
    ; ---- mapa.txt: personas por zona
    ABRIR_ARCHIVO RutaMapa,0
    JC LeerIlumReal
    LEER_ARCHIVO 1872,BufferMapa,ID
    CERRAR_ARCHIVO ID
    MOV BP,0                    ; zona 0 a 5
MapaSiguienteZona:
    MOV BX,BP
    ADD BX,BX                   ; WORD: dos bytes por posicion
    MOV SI,OffsetsPersonas[BX]
    LEA DI,BufferMapa
    ADD DI,SI
    MOV CX,3
    CALL ParseDigitos
    CMP AX,0
    JE MapaZonaVacia
    ADD ZonasOcupadas,1
    ADD PersonasZonas,AX
MapaZonaVacia:
    ADD BP,1
    CMP BP,6
    JNE MapaSiguienteZona
LeerIlumReal:
    ; ---- iluminacion.txt: zonas con luz y en modo manual (registros de 30 bytes)
    ABRIR_ARCHIVO RutaIluminacion,0
    JC CalcularEnergia
    LEER_ARCHIVO 180,BufferIlum,ID
    CERRAR_ARCHIVO ID
    XOR SI,SI
IlumSiguiente:
    CMP BufferIlum[SI+18],'1'
    JNE IlumRevisaModo
    ADD ZonasConLuz,1
IlumRevisaModo:
    CMP BufferIlum[SI+12],'M'
    JNE IlumAvanza
    ADD ZonasManual,1
IlumAvanza:
    ADD SI,30
    CMP SI,180
    JC IlumSiguiente
CalcularEnergia:
    ; ---- MUL: lamparas encendidas y potencia (watts)
    MOV AX,ZonasConLuz
    MOV BX,LamparasPorZona
    MUL BX
    MOV LamparasOn,AX
    MOV BX,WattsLampara
    MUL BX
    MOV PotenciaOn,AX
    MOV AX,6
    MOV BX,LamparasPorZona
    MUL BX
    MOV BX,WattsLampara
    MUL BX
    MOV PotenciaSinAuto,AX
    ; ---- SUB: ahorro = 100 - porcentaje de zonas encendidas
    MOV BX,ZonasConLuz
    MOV AL,100
    SUB AL,PorcentajeZonas[BX]
    MOV AH,0
    MOV AhorroPorcentaje,AX
    RET
LeerDatosReporte ENDP

; Escribe en AX (0 a 999) 3 caracteres en [DI], sin ceros a la izquierda
PonerNum3 PROC
    PUSH AX
    PUSH DI
    MOV TextoNumero,'0'
    MOV TextoNumero+1,'0'
    MOV TextoNumero+2,'0'
Num3Cien:
    CMP AX,100
    JC Num3Diez
    SUB AX,100
    ADD TextoNumero,1
    JMP Num3Cien
Num3Diez:
    CMP AX,10
    JC Num3Unidades
    SUB AX,10
    ADD TextoNumero+1,1
    JMP Num3Diez
Num3Unidades:
    ADD TextoNumero+2,AL
    CMP TextoNumero,'0'
    JNE Num3Copiar
    MOV TextoNumero,' '
    CMP TextoNumero+1,'0'
    JNE Num3Copiar
    MOV TextoNumero+1,' '
Num3Copiar:
    MOV AL,TextoNumero
    MOV [DI],AL
    MOV AL,TextoNumero+1
    MOV [DI+1],AL
    MOV AL,TextoNumero+2
    MOV [DI+2],AL
    POP DI
    POP AX
    RET
PonerNum3 ENDP

; Escribe AL (0 a 9) como un caracter en [DI]
PonerNum1 PROC
    ADD AL,'0'
    MOV [DI],AL
    RET
PonerNum1 ENDP

; Escribe AL (0 a 99) como 2 digitos en [DI]
PonerNum2 PROC
    MOV AH,0
    AAM
    ADD AX,3030H
    MOV [DI],AH
    MOV [DI+1],AL
    RET
PonerNum2 ENDP

; Fecha y hora reales de DOS en "dd/mm/yyyy" (10 bytes) y "hh:mm" (5 bytes). DI = fecha, SI = hora
PonerFechaHora PROC
    PUSH SI
    PUSH DI
    MOV AH,2Ah
    INT 21H                     ; CX = anio, DH = mes, DL = dia
    POP DI
    PUSH CX
    PUSH DX
    MOV AL,DL
    CALL PonerNum2
    MOV BYTE PTR [DI+2],'/'
    POP DX
    ADD DI,3
    MOV AL,DH
    CALL PonerNum2
    MOV BYTE PTR [DI+2],'/'
    ADD DI,3
    POP CX
    MOV AX,CX
    SUB AX,2000
    MOV BYTE PTR [DI],'2'
    MOV BYTE PTR [DI+1],'0'
    ADD DI,2
    CALL PonerNum2
    MOV AH,2Ch
    INT 21H                     ; CH = hora, CL = minutos
    POP DI                      ; DI = hora (SI de entrada)
    PUSH CX
    MOV AL,CH
    CALL PonerNum2
    MOV BYTE PTR [DI+2],':'
    POP CX
    ADD DI,3
    MOV AL,CL
    CALL PonerNum2
    RET
PonerFechaHora ENDP

; Copia los numeros calculados a la pantalla (ReporteRen..) y al texto de reporte.txt
ArmarReporte PROC
    LEA DI,RFecha
    LEA SI,RHora
    CALL PonerFechaHora
    LEA DI,TFecha
    LEA SI,THora
    CALL PonerFechaHora
    MOV AX,VisEntradas
    LEA DI,REnt
    CALL PonerNum3
    LEA DI,TEnt
    CALL PonerNum3
    MOV AX,VisSalidas
    LEA DI,RSal
    CALL PonerNum3
    LEA DI,TSal
    CALL PonerNum3
    MOV AX,VisPico
    LEA DI,RPico
    CALL PonerNum3
    LEA DI,TPico
    CALL PonerNum3
    MOV AX,VisSala
    LEA DI,RSala
    CALL PonerNum3
    LEA DI,TSala
    CALL PonerNum3
    MOV AX,AforoMaximo
    LEA DI,RAforo
    CALL PonerNum3
    LEA DI,TAforo
    CALL PonerNum3
    MOV AX,ZonasOcupadas
    LEA DI,RZOc
    CALL PonerNum1
    LEA DI,TZOc
    CALL PonerNum1
    MOV AX,PersonasZonas
    LEA DI,RPers
    CALL PonerNum3
    LEA DI,TPers
    CALL PonerNum3
    MOV AX,ZonasConLuz
    LEA DI,RZLuz
    CALL PonerNum1
    LEA DI,TZLuz
    CALL PonerNum1
    MOV AX,LamparasOn
    LEA DI,RLamp
    CALL PonerNum3
    LEA DI,TLamp
    CALL PonerNum3
    MOV AX,ZonasManual
    LEA DI,RManual
    CALL PonerNum1
    LEA DI,TManual
    CALL PonerNum1
    MOV AX,6
    SUB AX,ZonasManual
    LEA DI,RAuto
    CALL PonerNum1
    MOV AX,PotenciaOn
    LEA DI,RPot
    CALL PonerNum3
    LEA DI,TPot
    CALL PonerNum3
    MOV AX,PotenciaSinAuto
    LEA DI,RPotSin
    CALL PonerNum3
    LEA DI,TPotSin
    CALL PonerNum3
    MOV AX,AhorroPorcentaje
    LEA DI,RAhorro
    CALL PonerNum3
    LEA DI,TAhorro
    CALL PonerNum3
    RET
ArmarReporte ENDP

; Procedimientos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos.asm

END Inicio
