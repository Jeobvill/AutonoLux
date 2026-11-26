;*********************************************************
; ALTAMIRANO MURILLO AXEL GABRIEL
; Guardar como: Reporte.asm
; Pantalla: Reporte del dia (LCD e Impresora). Escribe reporte.txt.
; Programa independiente: se compila a Reporte.exe (emu8086).
; Necesita Biblioteca.txt, Dispositivos.asm y Dispositivos_Datos.asm en la misma carpeta.
; Los valores del resumen son datos de ejemplo (se cambian en TextoReporte y en los renglones).
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

; ---- Texto del reporte (420 bytes): se guarda en reporte.txt y se imprime
TextoReporte      DB "AUTONOLUX - REPORTE DEL DIA",13,10
                  DB "Fecha: 13/10/2026   Hora: 18:00",13,10
                  DB "RESUMEN: entradas 143, salidas 126, pico 38 personas a las 11:30",13,10
                  DB "Permanencia promedio: 47 min. Ocupacion: 4 de 6 zonas, 17 personas (28%)",13,10
                  DB "ZONAS: mas concurrida Lectura Silenciosa (38%), menos Estantes A-F (3%)",13,10
                  DB "ENERGIA: 2.726 kWh, costo $6.81, sin automatizacion 7.98 kWh",13,10
                  DB "AHORRO: 65.8% ($13.61)",13,10
                  DB "INCIDENCIAS: 4 cambios manuales de luz, 0 alertas",13,10
                  DB "NOTAS:",13,10

; ---- Renglones comunes (banner AUTONOLUX) y propios de la pantalla
LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"
ReporteRen07       DB "|  REPORTE DEL DIA              Fecha: 13/10/2026      Hora: 18:00         |"
ReporteRen08       DB "|--------------------------------------------------------------------------|"
ReporteRen09       DB "| RESUMEN GENERAL                                                          |"
ReporteRen10       DB "|   Entradas: 143    Salidas: 126    Pico: 38 personas a las 11:30         |"
ReporteRen11       DB "|   Permanencia promedio: 47 min     Ocupacion: 4/6 zonas, 17 pers. (28%)  |"
ReporteRen12       DB "| ZONAS Y ENERGIA                                                          |"
ReporteRen13       DB "|   Mas concurrida: Lectura Silenciosa 38%      Menos: Estantes A-F 3%     |"
ReporteRen14       DB "|   Consumo: 2.726 kWh   Costo: $6.81   Sin automatizacion: 7.98 kWh       |"
ReporteRen15       DB "|   AHORRO: 65.8% ($13.61) frente a luces siempre encendidas               |"
ReporteRen16       DB "| INCIDENCIAS                                                              |"
ReporteRen17       DB "|   Cambios manuales de luz: 4        Alertas: 0                           |"
ReporteRen18       DB "| NOTAS DEL OPERADOR  ([N] agrega, maximo 3)                               |"
ReporteRen19       DB "|   1.                                                                     |"
ReporteRen20       DB "|   2.                                                                     |"
ReporteRen21       DB "|   3.                                                                     |"
ReporteRen22       DB "|  [N] Nota   [G] Guardar   [I] Imprimir   [ESC] Volver                    |"

; ---- Datos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos_Datos.asm

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaAxel
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
    ESCRIBIR_ARCHIVO ID,420,TextoReporte
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
    MOV CX,420
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

; Procedimientos de los devices (LED_Display, Stepper_motor y LCD)
INCLUDE Dispositivos.asm

END Inicio
