;*********************************************************
; Guardar como: Dispositivos_Datos.asm
; Datos de los 3 devices que faltaban: LCD, LED_Display y Stepper_motor.
; Se incluye DENTRO de .DATA:   INCLUDE Dispositivos_Datos.asm
; Va junto con Dispositivos.asm (procedimientos).
; TODOS LOS PUERTOS ESTAN POR CONFIRMAR en emu8086 (ver PruebaDevices.asm).
;*********************************************************

; ---- LED_Display: 4 digitos de 7 segmentos
PuertoLedDisplay  DW 199                ; POR CONFIRMAR: puerto del primer digito
DigitosLed        DB 0,0,0,0            ; millares, centenas, decenas y unidades
SegmentosLed      DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h,7Fh,6Fh   ; digitos 0 a 9

; ---- Stepper_motor: persianas
SecuenciaMotor    DB 03h,06h,0Ch,09h    ; 4 pasos (0011, 0110, 1100, 1001)
PosicionPaso      DB 0                  ; paso actual de la secuencia (0 a 3)
DireccionMotor    DB 0                  ; 0 = abrir persianas, 1 = cerrar persianas
RetardoMotor      DW 3000               ; espera entre pasos (ajustar si va muy rapido)

; ---- LCD: mensajes (16 caracteres por linea, terminan en 0)
LcdTitulo         DB "AUTONOLUX        ",0
LcdBienvenida     DB "Bienvenido       ",0
LcdIntento        DB "Clave incorrecta ",0
LcdBloqueo        DB "Acceso bloqueado ",0
LcdGuardado       DB "Reporte guardado ",0
