;*********************************************************
; VILLA CAMPOS JESUS OBED
; Guardar como: Iluminacion.asm
; Pantalla: Control manual de iluminacion (LEDs). Escribe iluminacion.txt.
; Programa independiente: se compila a Iluminacion.exe (emu8086).
; Necesita Biblioteca.txt en la misma carpeta.
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?          ; handle de archivo (lo usa la biblioteca)
    RutaRaiz          DB "C:\AutonoLux",0
    RutaJesus         DB "C:\AutonoLux\Jesus",0
    RutaIluminacion   DB "C:\AutonoLux\Jesus\iluminacion.txt",0

; ---- Zonas (posicion 0 = zona 1 ... posicion 5 = zona 6). Inician vacias
OcupacionPorZona  DB 0,0,0,0,0,0          ; personas por zona (modo automatico)
LuzPorZona        DB 0,0,0,0,0,0          ; 1 = encendida
IntensidadPorZona DB 100,100,100,100,100,100
ModoGlobal        DB 'A'                  ; 'A' automatico, 'M' manual
ZonaSeleccionada  DB 9                    ; 0 a 5, 9 = ninguna
ZonaActual        DB 0
RenglonActual     DB 0
PesoDeZona        DB 1,2,4,8,16,32        ; bit de cada zona en los LEDs

; ---- Textos cortos que se escriben sobre la pantalla
TextoNumero       DB "000"      ; resultado de ConvertirATexto
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"
TextoZona         DB "1"
TextoFlecha       DB ">"
TextoLuzOn        DB "ON "
TextoLuzOff       DB "OFF"
TextoAuto         DB "AUTO"
TextoMan          DB "MAN "
TextoModoAutomatico DB "AUTOMATICO"
TextoModoManual   DB "MANUAL    "

; ---- Registro de iluminacion.txt (30 bytes por cambio)
RegistroIluminacion DB "Zona "
RegistroZona      DB "1"
                  DB " modo "
RegistroModo      DB "A"
                  DB " luz "
RegistroLuz       DB "1"
                  DB " int "
RegistroIntensidad DB "100"
                  DB "%",13,10

; ---- Renglones comunes (banner AUTONOLUX) y propios de la pantalla
LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"
IluminacionRen07  DB "| CONTROL MANUAL DE ILUMINACION     Modo global: __________                |"
IluminacionRen08  DB "|--------------------------------------------------------------------------|"
IluminacionRen09  DB "|    ZONA                      MODO      LUZ     INTENSIDAD                |"
IluminacionRen10  DB "|   1 Recepcion                   ____      ___      ___ %                 |"
IluminacionRen11  DB "|   2 Lectura Silenciosa          ____      ___      ___ %                 |"
IluminacionRen12  DB "|   3 Sala de Computo             ____      ___      ___ %                 |"
IluminacionRen13  DB "|   4 Hemeroteca                  ____      ___      ___ %                 |"
IluminacionRen14  DB "|   5 Estantes A-F                ____      ___      ___ %                 |"
IluminacionRen15  DB "|   6 Sala de Grupos              ____      ___      ___ %                 |"
IluminacionRen16  DB "|--------------------------------------------------------------------------|"
IluminacionRen17  DB "| Zona seleccionada: _    [1-6] elegir   [+] [-] intensidad   [T] luz      |"
IluminacionRen18  DB "|                                                                          |"
IluminacionRen19  DB "| AUTOMATICO: la luz sigue a la presencia. MANUAL: se controla con [T].    |"
IluminacionRen20  DB "|                                                                          |"
IluminacionRen21  DB "| [A] Automatico     [M] Manual     [ESC] Volver                           |"
IluminacionRen22  DB "| Cada cambio se guarda en iluminacion.txt      LEDs: luz por zona y modo  |"

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaJesus
    CALL ControlIluminacion
Fin:
    MOV AX,4C00H                ; termina con codigo 0
    INT 21H

;==================== CONTROL MANUAL DE ILUMINACION ====================

; Teclas: A automatico, M manual, 1-6 zona, + y - intensidad, T luz, ESC volver
ControlIluminacion PROC
    CREAR_ARCHIVO RutaIluminacion,32
    MOV ID,AX
    JC IluminacionErrorCrear
    JMP IluminacionRedibujar
IluminacionErrorCrear:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
IluminacionRedibujar:
    CMP ModoGlobal,'A'
    JNE IluminacionPintar
    CALL AplicarModoAutomatico
IluminacionPintar:
    CALL DibujarIluminacion
    CALL PintarFilasIluminacion
    CALL EscribirLeds
    RASTREO
    CMP AL,27                   ; ESC
    JNE IluminacionOtraTecla
    CERRAR_ARCHIVO ID
    RET
IluminacionOtraTecla:
    CMP AL,'A'
    JE IluminacionModoAutomatico
    CMP AL,'M'
    JE IluminacionModoManual
    CMP AL,'+'
    JE IluminacionSubir
    CMP AL,'='                  ; '+' sin Shift
    JE IluminacionSubir
    CMP AL,'-'
    JE IluminacionBajar
    CMP AL,'T'
    JE IluminacionAlternar
    CMP AL,'1'
    JC IluminacionRedibujar
    CMP AL,'7'
    JC IluminacionZonaValida
    JMP IluminacionRedibujar
IluminacionZonaValida:
    SUB AL,'1'
    MOV ZonaSeleccionada,AL
    JMP IluminacionRedibujar
IluminacionModoAutomatico:
    MOV ModoGlobal,'A'
    JMP IluminacionRedibujar
IluminacionModoManual:
    MOV ModoGlobal,'M'
    JMP IluminacionRedibujar
IluminacionSubir:
    CALL SubirIntensidad
    JMP IluminacionRedibujar
IluminacionBajar:
    CALL BajarIntensidad
    JMP IluminacionRedibujar
IluminacionAlternar:
    CALL AlternarLuz
    JMP IluminacionRedibujar
ControlIluminacion ENDP

; Dibuja la pantalla de iluminacion (renglones fijos)
DibujarIluminacion PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR LineaMarco,76,0,0,0,0,1Bh
    IMPCAD_COLOR Logo1,76,1,0,0,0,1Eh
    IMPCAD_COLOR Logo2,76,2,0,0,0,1Eh
    IMPCAD_COLOR Logo3,76,3,0,0,0,1Eh
    IMPCAD_COLOR Logo4,76,4,0,0,0,1Eh
    IMPCAD_COLOR Logo5,76,5,0,0,0,1Eh
    IMPCAD_COLOR LineaMarco,76,6,0,0,0,1Bh
    IMPCAD_COLOR IluminacionRen07,76,7,0,0,0,1Eh
    IMPCAD_COLOR IluminacionRen08,76,8,0,0,0,17h
    IMPCAD_COLOR IluminacionRen09,76,9,0,0,0,1Eh
    IMPCAD_COLOR IluminacionRen10,76,10,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen11,76,11,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen12,76,12,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen13,76,13,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen14,76,14,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen15,76,15,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen16,76,16,0,0,0,17h
    IMPCAD_COLOR IluminacionRen17,76,17,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen18,76,18,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen19,76,19,0,0,0,1Eh
    IMPCAD_COLOR IluminacionRen20,76,20,0,0,0,1Fh
    IMPCAD_COLOR IluminacionRen21,76,21,0,0,0,1Eh
    IMPCAD_COLOR IluminacionRen22,76,22,0,0,0,1Fh
    IMPCAD_COLOR LineaMarco,76,23,0,0,0,1Bh
    RET
DibujarIluminacion ENDP

; Escribe modo global, las 6 filas de zonas y la zona elegida
PintarFilasIluminacion PROC
    CMP ModoGlobal,'A'
    JNE PintarModoManual
    IMPCAD_COLOR TextoModoAutomatico,10,7,49,0,0,1Eh
    JMP PintarFilasDeZonas
PintarModoManual:
    IMPCAD_COLOR TextoModoManual,10,7,49,0,0,1Eh
PintarFilasDeZonas:
    MOV ZonaActual,0
IluminacionSiguienteFila:
    CALL PintarFilaDeZona
    ADD ZonaActual,1
    CMP ZonaActual,6
    JNE IluminacionSiguienteFila
    CMP ZonaSeleccionada,9
    JNE PintarZonaElegida
    RET
PintarZonaElegida:
    MOV AL,ZonaSeleccionada
    ADD AL,'1'
    MOV TextoZona,AL
    IMPCAD_COLOR TextoZona,1,17,21,0,0,1Eh
    RET
PintarFilasIluminacion ENDP

; Fila de la zona ZonaActual: modo, luz, intensidad y flecha (renglones 10 a 15)
PintarFilaDeZona PROC
    MOV AL,ZonaActual
    ADD AL,10
    MOV RenglonActual,AL
    CMP ModoGlobal,'A'
    JNE FilaModoManual
    IMPCAD_COLOR TextoAuto,4,RenglonActual,34,0,0,1Eh
    JMP FilaLuz
FilaModoManual:
    IMPCAD_COLOR TextoMan,4,RenglonActual,34,0,0,1Eh
FilaLuz:
    MOV BL,ZonaActual
    MOV BH,0
    CMP LuzPorZona[BX],0
    JE FilaLuzApagada
    IMPCAD_COLOR TextoLuzOn,3,RenglonActual,44,0,0,1Ah
    JMP FilaIntensidad
FilaLuzApagada:
    IMPCAD_COLOR TextoLuzOff,3,RenglonActual,44,0,0,1Ch
FilaIntensidad:
    MOV BL,ZonaActual
    MOV BH,0
    MOV AL,IntensidadPorZona[BX]
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,RenglonActual,53,0,0,1Fh
    MOV AL,ZonaActual
    CMP AL,ZonaSeleccionada
    JNE FilaSinFlecha
    IMPCAD_COLOR TextoFlecha,1,RenglonActual,2,0,0,1Eh
FilaSinFlecha:
    RET
PintarFilaDeZona ENDP

; Sube 10 la intensidad de la zona elegida (maximo 100)
SubirIntensidad PROC
    CMP ZonaSeleccionada,9
    JE FinSubirIntensidad
    MOV BL,ZonaSeleccionada
    MOV BH,0
    CMP IntensidadPorZona[BX],100
    JE FinSubirIntensidad
    ADD IntensidadPorZona[BX],10
    CALL RegistrarCambioIluminacion
FinSubirIntensidad:
    RET
SubirIntensidad ENDP

; Baja 10 la intensidad de la zona elegida (minimo 10)
BajarIntensidad PROC
    CMP ZonaSeleccionada,9
    JE FinBajarIntensidad
    MOV BL,ZonaSeleccionada
    MOV BH,0
    CMP IntensidadPorZona[BX],10
    JE FinBajarIntensidad
    SUB IntensidadPorZona[BX],10
    CALL RegistrarCambioIluminacion
FinBajarIntensidad:
    RET
BajarIntensidad ENDP

; Enciende o apaga la luz de la zona elegida, solo en modo manual
AlternarLuz PROC
    CMP ModoGlobal,'M'
    JNE FinAlternarLuz
    CMP ZonaSeleccionada,9
    JE FinAlternarLuz
    MOV BL,ZonaSeleccionada
    MOV BH,0
    CMP LuzPorZona[BX],0
    JE EncenderLuzDeZona
    MOV LuzPorZona[BX],0
    JMP GuardarLuzAlternada
EncenderLuzDeZona:
    MOV LuzPorZona[BX],1
GuardarLuzAlternada:
    CALL RegistrarCambioIluminacion
FinAlternarLuz:
    RET
AlternarLuz ENDP

; Escribe en iluminacion.txt: Zona N modo X luz L int III%
RegistrarCambioIluminacion PROC
    MOV AL,ZonaSeleccionada
    ADD AL,'1'
    MOV RegistroZona,AL
    MOV AL,ModoGlobal
    MOV RegistroModo,AL
    MOV BL,ZonaSeleccionada
    MOV BH,0
    MOV AL,LuzPorZona[BX]
    ADD AL,'0'
    MOV RegistroLuz,AL
    MOV AL,IntensidadPorZona[BX]
    CALL ConvertirATexto
    MOV AL,TextoNumero
    MOV RegistroIntensidad,AL
    MOV AL,TextoNumero+1
    MOV RegistroIntensidad+1,AL
    MOV AL,TextoNumero+2
    MOV RegistroIntensidad+2,AL
    ESCRIBIR_ARCHIVO ID,30,RegistroIluminacion
    RET
RegistrarCambioIluminacion ENDP


;==================== LEDS Y CONVERSION ====================

; Modo automatico: la luz de cada zona sigue a la presencia
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

; LEDs (2070h): bits 0-5 = luz de cada zona, bit 6 = modo manual
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

; Entrada: AL = numero de 0 a 255.  Salida: TextoNumero = 3 caracteres
; Resta 100, luego 10, y lo que queda son las unidades
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
    RET
ConvertirATexto ENDP

END Inicio
