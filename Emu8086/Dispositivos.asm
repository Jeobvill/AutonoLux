;*********************************************************
; Guardar como: Dispositivos.asm
; Procedimientos de los 3 devices que faltaban:
;   LCD (Axel: Login y Reporte), LED_Display y Stepper_motor (Sergio: Consumo y Configuracion).
; Solo procedimientos: se incluyen despues de Fin con  INCLUDE Dispositivos.asm
; Los datos estan en Dispositivos_Datos.asm.
; Estilo de Termometro02: mov dx,puerto / mov al,dato / out dx,al
; AVISO: los puertos son un SUPUESTO tomado de la documentacion de emu8086;
;        se confirman con PruebaDevices.asm.
;*********************************************************

;==================== LCD ASCII (2040h-206Fh) ====================

LimpiarLcd PROC
    MOV DX,2040h
    MOV CX,48
LcdLimpiarSiguiente:
    MOV AL,' '
    OUT DX,AL
    ADD DX,1
    SUB CX,1
    CMP CX,0
    JNE LcdLimpiarSiguiente
    RET
LimpiarLcd ENDP

EscribirLcd PROC
LcdSiguienteLetra:
    MOV AL,[SI]
    CMP AL,0
    JE LcdFinTexto
    OUT DX,AL
    ADD DX,1
    ADD SI,1
    JMP LcdSiguienteLetra
LcdFinTexto:
    RET
EscribirLcd ENDP

;==================== LED_Display ====================

MostrarEnLedDisplay PROC
    MOV DigitosLed,0
    MOV DigitosLed+1,0
    MOV DigitosLed+2,0
    MOV DigitosLed+3,0
LedMillares:
    CMP AX,1000
    JC LedCentenas
    SUB AX,1000
    ADD DigitosLed,1
    JMP LedMillares
LedCentenas:
    CMP AX,100
    JC LedDecenas
    SUB AX,100
    ADD DigitosLed+1,1
    JMP LedCentenas
LedDecenas:
    CMP AX,10
    JC LedUnidades
    SUB AX,10
    ADD DigitosLed+2,1
    JMP LedDecenas
LedUnidades:
    ADD DigitosLed+3,AL
    MOV DX,PuertoLedDisplay
    MOV SI,0
LedSiguienteDigito:
    MOV BL,DigitosLed[SI]
    MOV BH,0
    MOV AL,SegmentosLed[BX]
    OUT DX,AL
    ADD DX,1
    ADD SI,1
    CMP SI,4
    JNE LedSiguienteDigito
    RET
MostrarEnLedDisplay ENDP

;==================== Stepper_motor (puerto 7) ====================

GirarPersianas PROC
MotorSiguientePaso:
    CMP DireccionMotor,0
    JNE MotorHaciaAtras
    ADD PosicionPaso,1
    CMP PosicionPaso,4
    JNE MotorEscribirPaso
    MOV PosicionPaso,0
    JMP MotorEscribirPaso
MotorHaciaAtras:
    CMP PosicionPaso,0
    JNE MotorRestarPaso
    MOV PosicionPaso,4
MotorRestarPaso:
    SUB PosicionPaso,1
MotorEscribirPaso:
    MOV BL,PosicionPaso
    MOV BH,0
    MOV AL,SecuenciaMotor[BX]
    MOV DX,7
    OUT DX,AL
    CALL EsperarMotor
    SUB CX,1
    CMP CX,0
    JNE MotorSiguientePaso
    RET
GirarPersianas ENDP

EsperarMotor PROC
    MOV SI,RetardoMotor
MotorEsperarVuelta:
    SUB SI,1
    CMP SI,0
    JNE MotorEsperarVuelta
    RET
EsperarMotor ENDP
