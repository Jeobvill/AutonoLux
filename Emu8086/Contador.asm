;*********************************************************
; VILLA CAMPOS JESUS OBED
; Guardar como: Contador.asm
; Pantalla: Contador de visitantes (Seven Segment y Push Buttons). Escribe visitantes.txt.
; Programa independiente: se compila a Contador.exe (emu8086).
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
    RutaVisitantes    DB "C:\AutonoLux\Jesus\visitantes.txt",0

; ---- Contador de visitantes (inician en cero)
PersonasEnSala    DB 0
EntradasDelDia    DB 0
SalidasDelDia     DB 0
PicoDelDia        DB 0
AforoMaximo       DB 60
Porcentaje        DB 0      ; porcentaje de aforo ocupado
CeldasBarra       DW 0      ; celdas '#' de la barra (1 celda = 3 personas)
MensajeContador   DB 0      ; 0 ninguno, 1 sala llena, 2 sala vacia, 3 hay gente en zonas, 4 reiniciado
TipoDeEvento      DB 'E'    ; 'I' inicio, 'E' entra, 'S' sale (para visitantes.txt)
BotonesLeidos     DB 0

; ---- Coherencia con el Mapa: no salen personas que estan ubicadas en una zona
RutaMapa          DB "C:\AutonoLux\Jesus\mapa.txt",0
BufferMapa        DB 1872 DUP(0)
OffsetsPersonas   DW 872,896,920,1262,1286,1310   ; columna de personas de cada zona en mapa.txt
ZonasContadas     DW 0

; ---- Variables de la resta del catedratico: restaR = restaN1 - restaN2
restaN1           DB 0
restaN2           DB 0
restaR            DB 0      ; lugares libres

; ---- Seven Segment: segmentos de los digitos 0 a 9
Segmentos         DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h,7Fh,6Fh

; ---- Textos cortos y mensajes (52 caracteres cada mensaje)
TextoNumero       DB "000"      ; resultado de ConvertirATexto
MensajeErrorArchivo DB "No se pudo abrir el archivo. Pulse una tecla.$"
TextoSalaLlena    DB "Aforo maximo alcanzado. No puede entrar nadie mas.  "
TextoSalaVacia    DB "La sala esta vacia. No puede salir nadie.           "
TextoZonasConGente DB "Hay personas en zonas del Mapa: liberelas para salir"
TextoReiniciado   DB "Contadores reiniciados.                             "

; ---- Pedazos del registro de visitantes.txt (58 bytes por evento)
TextoEvento       DB "Evento "
TextoInicio       DB "INICIO"
TextoEntra        DB "ENTRA "
TextoSale         DB "SALE  "
TextoSala         DB " sala "
TextoEntradas     DB " entradas "
TextoSalidas      DB " salidas "
TextoPico         DB " pico "
FinDeLinea        DB 13,10

; ---- Renglones comunes (banner AUTONOLUX) y propios de la pantalla
LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"
ContadorRen07     DB "| CONTADOR DE VISITANTES                                                   |"
ContadorRen08     DB "|--------------------------------------------------------------------------|"
ContadorRen09     DB "| EN SALA AHORA: ___ personas            Aforo maximo: 60 personas         |"
ContadorRen10     DB "| OCUPACION DEL AFORO: ___ %            LUGARES LIBRES: ___                |"
ContadorRen11     DB "| [                    ]                                                   |"
ContadorRen12     DB "|--------------------------------------------------------------------------|"
ContadorRen13     DB "| ENTRADAS DEL DIA: ___        SALIDAS DEL DIA: ___                        |"
ContadorRen14     DB "| PICO DEL DIA: ___ personas                                               |"
ContadorRen15     DB "|--------------------------------------------------------------------------|"
ContadorRen16     DB "|                                                                          |"
ContadorRen17     DB "|                                                                          |"
ContadorRen18     DB "|--------------------------------------------------------------------------|"
ContadorRen19     DB "| [+] Entra persona   [-] Sale persona   [B] Botones   [R] Reiniciar       |"
ContadorRen20     DB "|                                                                          |"
ContadorRen21     DB "| [ESC] Volver    Seven Segment: sala y entradas    Push Buttons: +1 / -1  |"
ContadorRen22     DB "|                                                                          |"

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaJesus
    CALL ControlContador
Fin:
    MOV AX,4C00H                ; termina con codigo 0
    INT 21H

;==================== CONTADOR DE VISITANTES ====================

; Teclas: + entra, - sale, B botones, R reinicia, ESC volver
ControlContador PROC
    CREAR_ARCHIVO RutaVisitantes,32
    MOV ID,AX
    JC ContadorErrorCrear
    JMP ContadorIniciar
ContadorErrorCrear:
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
ContadorIniciar:
    MOV MensajeContador,0
    MOV TipoDeEvento,'I'        ; primer registro: estado de arranque
    CALL RegistrarVisita
ContadorRedibujar:
    CALL DibujarContador
    CALL PintarDatosContador
    CALL EscribirSieteSegmentos
    RASTREO
    CMP AL,27                   ; ESC
    JNE ContadorOtraTecla
    CERRAR_ARCHIVO ID
    RET
ContadorOtraTecla:
    CMP AL,'+'
    JE ContadorEntra
    CMP AL,'='                  ; '+' sin Shift
    JE ContadorEntra
    CMP AL,'-'
    JE ContadorSale
    CMP AL,'B'
    JE ContadorBotones
    CMP AL,'R'
    JE ContadorReiniciar
    JMP ContadorRedibujar
ContadorEntra:
    CALL RegistrarEntrada
    JMP ContadorRedibujar
ContadorSale:
    CALL RegistrarSalida
    JMP ContadorRedibujar
ContadorBotones:
    CALL LeerBotones
    JMP ContadorRedibujar
ContadorReiniciar:
    CALL ReiniciarContador
    JMP ContadorRedibujar
ControlContador ENDP

; Dibuja la pantalla del contador (renglones fijos)
DibujarContador PROC
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR LineaMarco,76,0,0,0,0,1Bh
    IMPCAD_COLOR Logo1,76,1,0,0,0,1Eh
    IMPCAD_COLOR Logo2,76,2,0,0,0,1Eh
    IMPCAD_COLOR Logo3,76,3,0,0,0,1Eh
    IMPCAD_COLOR Logo4,76,4,0,0,0,1Eh
    IMPCAD_COLOR Logo5,76,5,0,0,0,1Eh
    IMPCAD_COLOR LineaMarco,76,6,0,0,0,1Bh
    IMPCAD_COLOR ContadorRen07,76,7,0,0,0,1Eh
    IMPCAD_COLOR ContadorRen08,76,8,0,0,0,17h
    IMPCAD_COLOR ContadorRen09,76,9,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen10,76,10,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen11,76,11,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen12,76,12,0,0,0,17h
    IMPCAD_COLOR ContadorRen13,76,13,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen14,76,14,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen15,76,15,0,0,0,17h
    IMPCAD_COLOR ContadorRen16,76,16,0,0,0,1Eh
    IMPCAD_COLOR ContadorRen17,76,17,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen18,76,18,0,0,0,17h
    IMPCAD_COLOR ContadorRen19,76,19,0,0,0,1Eh
    IMPCAD_COLOR ContadorRen20,76,20,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen21,76,21,0,0,0,1Fh
    IMPCAD_COLOR ContadorRen22,76,22,0,0,0,1Fh
    IMPCAD_COLOR LineaMarco,76,23,0,0,0,1Bh
    RET
DibujarContador ENDP

; Escribe sobre la pantalla: sala, porcentaje, lugares libres, barra,
; entradas, salidas, pico y mensaje
PintarDatosContador PROC
    CALL CalcularPorcentaje
    CALL CalcularLugaresLibres
    MOV AL,PersonasEnSala
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,9,17,0,0,1Eh
    MOV AL,Porcentaje
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,10,23,0,0,1Eh
    MOV AL,restaR
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,10,56,0,0,1Ah
    CMP CeldasBarra,0
    JE ContadorSinBarra
    CURSOR 11,3,0
    ESCRIBIR_CARCOLOR CeldasBarra,'#',1Ah
ContadorSinBarra:
    MOV AL,EntradasDelDia
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,13,20,0,0,1Fh
    MOV AL,SalidasDelDia
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,13,48,0,0,1Fh
    MOV AL,PicoDelDia
    CALL ConvertirATexto
    IMPCAD_COLOR TextoNumero,3,14,16,0,0,1Fh
    CALL PintarMensajeContador
    RET
PintarDatosContador ENDP

; Renglon 20 segun MensajeContador
PintarMensajeContador PROC
    CMP MensajeContador,1
    JE MensajeSalaLlena
    CMP MensajeContador,2
    JE MensajeSalaVacia
    CMP MensajeContador,3
    JE MensajeZonasConGente
    CMP MensajeContador,4
    JE MensajeReiniciado
    RET
MensajeZonasConGente:
    IMPCAD_COLOR TextoZonasConGente,52,20,3,0,0,1Ch
    RET
MensajeSalaLlena:
    IMPCAD_COLOR TextoSalaLlena,52,20,3,0,0,1Ch
    RET
MensajeSalaVacia:
    IMPCAD_COLOR TextoSalaVacia,52,20,3,0,0,1Ch
    RET
MensajeReiniciado:
    IMPCAD_COLOR TextoReiniciado,52,20,3,0,0,1Ah
    RET
PintarMensajeContador ENDP

; Porcentaje de aforo y celdas de la barra: cada grupo de 3 personas
; suma 5 % y 1 celda; si sobran 1 o 2 personas suman 2 o 3 %
CalcularPorcentaje PROC
    MOV AL,PersonasEnSala
    MOV CeldasBarra,0
    MOV Porcentaje,0
ContarGrupoDeTres:
    CMP AL,3
    JC SobranPersonas           ; quedan menos de 3
    SUB AL,3
    ADD CeldasBarra,1
    ADD Porcentaje,5
    JMP ContarGrupoDeTres
SobranPersonas:
    CMP AL,0
    JE FinPorcentaje
    ADD Porcentaje,2
    CMP AL,1
    JE FinPorcentaje
    ADD Porcentaje,1
FinPorcentaje:
    RET
CalcularPorcentaje ENDP

; Lugares libres = aforo maximo - personas en sala  (resta del catedratico)
CalcularLugaresLibres PROC
    MOV AL,AforoMaximo          ; se cargan los dos numeros
    MOV restaN1,AL
    MOV AL,PersonasEnSala
    MOV restaN2,AL
    ; ---- resta tal como la dio el catedratico ----
    mov al,restaN1
    mov bl,restaN2
    sub al,bl
    mov restaR,al
    ; ----------------------------------------------
    RET
CalcularLugaresLibres ENDP

; Entra una persona (tecla + o boton 0)
RegistrarEntrada PROC
    MOV MensajeContador,0
    MOV AL,PersonasEnSala
    CMP AL,AforoMaximo
    JNE EntradaConLugar
    MOV MensajeContador,1       ; sala llena
    RET
EntradaConLugar:
    ADD PersonasEnSala,1
    CMP EntradasDelDia,255
    JE EntradaRevisarPico
    ADD EntradasDelDia,1
EntradaRevisarPico:
    MOV AL,PicoDelDia
    CMP AL,PersonasEnSala
    JC EntradaNuevoPico         ; el pico es menor que la sala
    JMP EntradaGuardar          ; el pico ya es mayor o igual
EntradaNuevoPico:
    MOV AL,PersonasEnSala
    MOV PicoDelDia,AL
EntradaGuardar:
    MOV TipoDeEvento,'E'
    CALL RegistrarVisita
    RET
RegistrarEntrada ENDP

; Suma las personas de las 6 zonas de mapa.txt (Mapa.asm) en ZonasContadas
PersonasEnZonas PROC
    MOV ZonasContadas,0
    ABRIR_ARCHIVO RutaMapa,0
    JC FinPersonasEnZonas       ; sin mapa.txt no hay nadie en zonas
    LEER_ARCHIVO 1872,BufferMapa,ID
    CERRAR_ARCHIVO ID
    MOV BP,0
ZonaSiguienteLectura:
    MOV BX,BP
    ADD BX,BX
    MOV SI,OffsetsPersonas[BX]
    XOR AX,AX
    MOV CX,3
ZonaDigito:
    MOV BL,BufferMapa[SI]
    CMP BL,'0'
    JC ZonaSalta
    CMP BL,':'
    JNC ZonaSalta
    MOV DX,10
    MUL DX
    SUB BL,'0'
    MOV BH,0
    ADD AX,BX
ZonaSalta:
    ADD SI,1
    SUB CX,1
    CMP CX,0
    JNE ZonaDigito
    ADD ZonasContadas,AX
    ADD BP,1
    CMP BP,6
    JNE ZonaSiguienteLectura
FinPersonasEnZonas:
    RET
PersonasEnZonas ENDP

; Sale una persona (tecla - o boton 1)
RegistrarSalida PROC
    MOV MensajeContador,0
    CMP PersonasEnSala,0
    JNE SalidaConPersonas
    MOV MensajeContador,2       ; sala vacia
    RET
SalidaConPersonas:
    CALL PersonasEnZonas        ; la sala no puede quedar con menos gente que las zonas del Mapa
    MOV AL,PersonasEnSala
    MOV AH,0
    CMP AX,ZonasContadas
    JNC SalidaPermitida         ; sala > zonas: alguien esta sin ubicar
    JMP SalidaBloqueada
SalidaPermitida:
    CMP AX,ZonasContadas
    JNE SalidaLibre
SalidaBloqueada:
    MOV MensajeContador,3       ; sala = zonas: todos estan ubicados en el Mapa
    RET
SalidaLibre:
    SUB PersonasEnSala,1
    CMP SalidasDelDia,255
    JE SalidaGuardar
    ADD SalidasDelDia,1
SalidaGuardar:
    MOV TipoDeEvento,'S'
    CALL RegistrarVisita
    RET
RegistrarSalida ENDP

; Escribe en visitantes.txt: Evento ENTRA sala NNN entradas NNN salidas NNN pico NNN
; (INICIO es el primer registro de la sesion, con el estado de arranque)
RegistrarVisita PROC
    ESCRIBIR_ARCHIVO ID,7,TextoEvento
    CMP TipoDeEvento,'E'
    JE VisitaEsEntrada
    CMP TipoDeEvento,'S'
    JE VisitaEsSalida
    ESCRIBIR_ARCHIVO ID,6,TextoInicio
    JMP VisitaEscribirSala
VisitaEsEntrada:
    ESCRIBIR_ARCHIVO ID,6,TextoEntra
    JMP VisitaEscribirSala
VisitaEsSalida:
    ESCRIBIR_ARCHIVO ID,6,TextoSale
VisitaEscribirSala:
    ESCRIBIR_ARCHIVO ID,6,TextoSala
    MOV AL,PersonasEnSala
    CALL ConvertirATexto
    ESCRIBIR_ARCHIVO ID,3,TextoNumero
    ESCRIBIR_ARCHIVO ID,10,TextoEntradas
    MOV AL,EntradasDelDia
    CALL ConvertirATexto
    ESCRIBIR_ARCHIVO ID,3,TextoNumero
    ESCRIBIR_ARCHIVO ID,9,TextoSalidas
    MOV AL,SalidasDelDia
    CALL ConvertirATexto
    ESCRIBIR_ARCHIVO ID,3,TextoNumero
    ESCRIBIR_ARCHIVO ID,6,TextoPico
    MOV AL,PicoDelDia
    CALL ConvertirATexto
    ESCRIBIR_ARCHIVO ID,3,TextoNumero
    ESCRIBIR_ARCHIVO ID,2,FinDeLinea
    RET
RegistrarVisita ENDP

; Push Buttons (2080h): bit 0 = entra una persona, bit 1 = sale una persona
; Se quitan los bits 7 a 2 restando su peso (sin AND); queda 0, 1, 2 o 3
LeerBotones PROC
    MOV DX,2080h
    IN AL,DX
    CMP AL,128
    JC BotonSinBit7
    SUB AL,128
BotonSinBit7:
    CMP AL,64
    JC BotonSinBit6
    SUB AL,64
BotonSinBit6:
    CMP AL,32
    JC BotonSinBit5
    SUB AL,32
BotonSinBit5:
    CMP AL,16
    JC BotonSinBit4
    SUB AL,16
BotonSinBit4:
    CMP AL,8
    JC BotonSinBit3
    SUB AL,8
BotonSinBit3:
    CMP AL,4
    JC BotonSinBit2
    SUB AL,4
BotonSinBit2:
    MOV BotonesLeidos,AL
    CMP AL,1
    JE BotonEntra
    CMP AL,3
    JE BotonEntra
    JMP BotonRevisarSalida
BotonEntra:
    CALL RegistrarEntrada
BotonRevisarSalida:
    MOV AL,BotonesLeidos
    CMP AL,2
    JE BotonSale
    CMP AL,3
    JE BotonSale
    JMP FinLeerBotones
BotonSale:
    CALL RegistrarSalida
FinLeerBotones:
    RET
LeerBotones ENDP

; Pone en cero sala, entradas, salidas y pico
ReiniciarContador PROC
    MOV PersonasEnSala,0
    MOV EntradasDelDia,0
    MOV SalidasDelDia,0
    MOV PicoDelDia,0
    MOV MensajeContador,4
    RET
ReiniciarContador ENDP

; Seven Segment (2030h-2037h): sala (3 digitos), espacio, entradas (3), espacio
EscribirSieteSegmentos PROC
    MOV DX,2030h
    MOV AL,PersonasEnSala
    CALL ConvertirATexto
    CALL EscribirTresDigitos
    MOV AL,0                    ; posicion apagada
    OUT DX,AL
    ADD DX,1
    MOV AL,EntradasDelDia
    CALL ConvertirATexto
    CALL EscribirTresDigitos
    MOV AL,0
    OUT DX,AL
    RET
EscribirSieteSegmentos ENDP

; Escribe los 3 caracteres de TextoNumero en el Seven Segment (DX = puerto)
EscribirTresDigitos PROC
    MOV SI,0
SiguienteDigito:
    MOV AL,TextoNumero[SI]
    SUB AL,'0'                  ; caracter '0'-'9' pasa a numero 0-9
    MOV BL,AL
    MOV BH,0
    MOV AL,Segmentos[BX]        ; busca los segmentos del digito
    OUT DX,AL
    ADD DX,1
    ADD SI,1
    CMP SI,3
    JNE SiguienteDigito
    RET
EscribirTresDigitos ENDP


;==================== CONVERSION ====================

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
