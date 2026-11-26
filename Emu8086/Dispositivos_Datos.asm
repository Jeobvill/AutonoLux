;*********************************************************
; Guardar como: Dispositivos_Datos.asm
; Datos de los 3 devices que faltaban: LCD, LED_Display y Stepper_motor.
; Se incluye DENTRO de .DATA:   INCLUDE Dispositivos_Datos.asm
; Va junto con Dispositivos.asm (procedimientos).
; TODOS LOS PUERTOS ESTAN POR CONFIRMAR en emu8086 (ver PruebaDevices.asm).
;*********************************************************

PuertoLedDisplay  DW 199
DigitosLed        DB 0,0,0,0
SegmentosLed      DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h,7Fh,6Fh

SecuenciaMotor    DB 03h,06h,0Ch,09h
PosicionPaso      DB 0
DireccionMotor    DB 0
RetardoMotor      DW 3000

LcdTitulo         DB "AUTONOLUX        ",0
LcdBienvenida     DB "Bienvenido       ",0
LcdIntento        DB "Clave incorrecta ",0
LcdBloqueo        DB "Acceso bloqueado ",0
LcdGuardado       DB "Reporte guardado ",0
