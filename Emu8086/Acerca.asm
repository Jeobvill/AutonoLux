;*********************************************************
; ALTAMIRANO MURILLO AXEL GABRIEL
; Guardar como: Acerca.asm
; Pantalla: Acerca de AutonoLux. Lee acerca.txt (Delphi tambien lo carga en uAcerca).
; Programa independiente: se compila a Acerca.exe (emu8086).
; Necesita Biblioteca.txt en la misma carpeta.
; Teclas en MAYUSCULAS.
;*********************************************************
INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?        
    RutaRaiz          DB "C:\AutonoLux",0
    RutaAxel          DB "C:\AutonoLux\Axel",0
    RutaAcerca        DB "C:\AutonoLux\Axel\acerca.txt",0

MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"

BufferAcerca      DB 1872 DUP(?)

TextoAcerca       DB "+==========================================================================+",13,10
                  DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |",13,10
                  DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |",13,10
                  DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |",13,10
                  DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |",13,10
                  DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |",13,10
                  DB "+==========================================================================+",13,10
                  DB "| ACERCA DE                                                                |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "|  Sistema      : AutonoLux - Deteccion y control de iluminacion           |",13,10
                  DB "|  Version      : 2.0      Plataforma: emu8086 (ASM 8086) y Delphi         |",13,10
                  DB "|  Devices      : Printer, Thermometer, Robot, Traffic Lights, LCD,        |",13,10
                  DB "|                 Stepper motor, LED Display, Pressure Gauge, Switches,    |",13,10
                  DB "|                 LEDs, Seven Seg., Dot Matrix, Push Buttons               |",13,10
                  DB "|  Modulos      : Login, Menu, Monitor, Mapa, Iluminacion, Contador,       |",13,10
                  DB "|                 Mapa de calor, Consumo, Reporte, Config., Bitacora       |",13,10
                  DB "|--------------------------------------------------------------------------|",13,10
                  DB "|  Integrantes  : Altamirano Murillo Axel   axgaaltamiranomu@ittepic.edu.mx|",13,10
                  DB "|                 Diaz Robles Sergio        sediazro@ittepic.edu.mx        |",13,10
                  DB "|                 Veliz Partida Daniel      davelizpa@ittepic.edu.mx       |",13,10
                  DB "|                 Villa Campos Jesus Obed   jeobvillaca@ittepic.edu.mx     |",13,10
                  DB "|  Institucion  : Instituto Tecnologico de Tepic, 2026                     |",13,10
                  DB "| [ESC] Volver                                                             |",13,10
                  DB "+==========================================================================+",13,10

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    CREAR_CARPETA RutaRaiz
    CREAR_CARPETA RutaAxel
    CALL MostrarAcerca
Fin:
    MOV AX,4C00H
    INT 21H

;==================== ACERCA DE ====================

MostrarAcerca PROC
    ABRIR_ARCHIVO RutaAcerca,0
    JC AcercaNoExiste
    JMP AcercaAbierto
AcercaNoExiste:
    CALL CrearAcercaInicial
    ABRIR_ARCHIVO RutaAcerca,0
    JC ErrorAlLeerAcerca
AcercaAbierto:
    LEER_ARCHIVO 1872,BufferAcerca,ID
    JC ErrorAlLeerAcerca
    CERRAR_ARCHIVO ID
    CALL DibujarAcerca
AcercaEsperarTecla:
    RASTREO
    CMP AL,27
    JNE AcercaEsperarTecla
    RET
ErrorAlLeerAcerca:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
MostrarAcerca ENDP

CrearAcercaInicial PROC
    CREAR_ARCHIVO RutaAcerca,32
    MOV ID,AX
    JC FinCrearAcerca
    ESCRIBIR_ARCHIVO ID,1872,TextoAcerca
    CERRAR_ARCHIVO ID
FinCrearAcerca:
    RET
CrearAcercaInicial ENDP

DibujarAcerca PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR BufferAcerca,76,0,0,0,0,1Bh
    IMPCAD_COLOR BufferAcerca+78,76,1,0,0,0,1Eh
    IMPCAD_COLOR BufferAcerca+156,76,2,0,0,0,1Eh
    IMPCAD_COLOR BufferAcerca+234,76,3,0,0,0,1Eh
    IMPCAD_COLOR BufferAcerca+312,76,4,0,0,0,1Eh
    IMPCAD_COLOR BufferAcerca+390,76,5,0,0,0,1Eh
    IMPCAD_COLOR BufferAcerca+468,76,6,0,0,0,1Bh
    IMPCAD_COLOR BufferAcerca+546,76,7,0,0,0,1Eh
    IMPCAD_COLOR BufferAcerca+624,76,8,0,0,0,17h
    IMPCAD_COLOR BufferAcerca+702,76,9,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+780,76,10,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+858,76,11,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+936,76,12,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1014,76,13,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1092,76,14,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1170,76,15,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1248,76,16,0,0,0,17h
    IMPCAD_COLOR BufferAcerca+1326,76,17,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1404,76,18,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1482,76,19,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1560,76,20,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1638,76,21,0,0,0,1Fh
    IMPCAD_COLOR BufferAcerca+1716,76,22,0,0,0,1Eh
    IMPCAD_COLOR BufferAcerca+1794,76,23,0,0,0,1Bh
    RET
DibujarAcerca ENDP

END Inicio
