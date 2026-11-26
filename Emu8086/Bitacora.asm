;*********************************************************
; VELIZ PARTIDA DANIEL
; Guardar como: Bitacora.asm
; Pantalla: Bitacora de eventos (Printer y Robot). Lee y escribe bitacora.txt.
; Programa independiente: se compila a Bitacora.exe (emu8086).
; Necesita Biblioteca.txt en la misma carpeta.
; Teclas en MAYUSCULAS.
;*********************************************************
#start=robot.exe#

INCLUDE Biblioteca.txt

.MODEL SMALL
.STACK 100H

.DATA
    ID                DW ?          ; handle de archivo (lo usa la biblioteca)
    RutaRaiz          DB "C:\AutonoLux",0
    RutaDaniel        DB "C:\AutonoLux\Daniel",0
    RutaBitacora      DB "C:\AutonoLux\Daniel\bitacora.txt",0

; ---- Registros en memoria (hasta 24 registros de 78 bytes)
BytesLeidos            DW 0     ; bytes que devolvio la lectura del archivo
BytesEnMemoria         DW 0     ; registros completos x 78
RegistrosEnMemoria     DB 0
RegistrosVisibles      DB 0     ; los que cumplen el filtro de zona
RegistrosContados      DB 0     ; al pintar: cuantos visibles ya se revisaron
PrimerRegistroDePagina DB 0
LimiteDePagina         DB 0     ; primer registro de la pagina + 8
PaginaActual           DB 0     ; empieza en 0
TotalPaginas           DB 1
FiltroDeZona           DB '0'   ; '0' = todas, '1' a '6' = una zona
CumpleFiltro           DB 0     ; resultado de RegistroCumpleFiltro
RenglonActual          DB 0
ErrorDeArchivo         DB 0     ; 1 = no se pudo leer bitacora.txt

; ---- Evento nuevo
ComandoRobot           DB 0
TipoDeEvento           DB 'M'   ; 'M' manual (lo escribe el operador), 'R' ronda del Robot
ZonaDelEvento          DB '1'
LongitudEvento         DW 0
RellenoEvento          DW 0     ; espacios que faltan para llegar a 30
CapturaEvento          DB 31,0,32 DUP(0)    ; buffer de DOS: maximo, longitud y texto

; ---- Pedazos del registro de bitacora.txt (78 bytes por evento)
TextoInicioDeRegistro  DB "| "
TextoHora              DB "00:00"           ; se rellena con la hora real (HoraEnTexto)
TextoAntesDeZona       DB "  Z"
TextoEspacio           DB " "
TextoDosEspacios       DB "  "
TextoRellenoEvento     DB "                              "     ; 30 espacios
TextoUsuarioAdmin      DB "ADMIN"
TextoUsuarioRobot      DB "ROBOT"
TextoFinDeRegistro     DB "      |",13,10
TextoEventoRonda       DB "Visita de ronda verificada"
NombreZona1            DB "Recepcion         "
NombreZona2            DB "Lectura Silenciosa"
NombreZona3            DB "Sala de Computo   "
NombreZona4            DB "Hemeroteca        "
NombreZona5            DB "Estantes A-F      "
NombreZona6            DB "Sala de Grupos    "

; ---- Textos cortos y mensajes
TextoPagina            DB "1"
TextoTotalPaginas      DB "1"
TextoPedirZona         DB "Zona [1-6]: "
TextoPedirEvento       DB "Evento: "
TextoPedirFiltro       DB "Filtrar zona [0=todas, 1-6]: "
MensajeBitacoraLlena   DB "Bitacora llena (24 registros). Presione una tecla."
MensajeRondaSinLugar   DB "No caben 6 registros mas para la ronda. Presione una tecla."
MensajeRondaTerminada  DB "Ronda terminada: 6 zonas verificadas. Presione una tecla."
MensajeRondaCancelada  DB "Ronda detenida con ESC. Presione una tecla."
MensajeRondaEnCurso    DB "Robot en ronda... ESC para detenerlo"
MensajeImpresa         DB "Bitacora enviada a la impresora. Presione una tecla."
MensajeErrorArchivo    DB "No se pudo abrir el archivo. Pulse una tecla.$"

; ---- Buffer donde se lee bitacora.txt
BufferBitacora         DB 1872 DUP(?)

; ---- Renglones comunes (banner AUTONOLUX) y propios de la pantalla
LineaMarco        DB "+==========================================================================+"
Logo1             DB "|             _   _   _ _____ ___  _   _  ___  _    _   ___  __            |"
Logo2             DB "|               / \ | | | |_   _/ _ \| \ | |/ _ \| |  | | | \ \/ /         |"
Logo3             DB "|              / _ \| | | | | || | | |  \| | | | | |  | | | |\  /          |"
Logo4             DB "|             / ___ \ |_| | | || |_| | |\  | |_| | |__| |_| |/  \          |"
Logo5             DB "|            /_/   \_\___/  |_| \___/|_| \_|\___/|_____\___//_/\_\         |"
BitacoraRen07     DB "| BITACORA DE EVENTOS       Pagina: _/_       Filtro de zona: _ (0 = todas)|"
BitacoraRen08     DB "|--------------------------------------------------------------------------|"
BitacoraRen09     DB "| HORA   ZONA                  EVENTO                          USUARIO     |"
BitacoraRenVacio  DB "|                                                                          |"
BitacoraRen18     DB "|--------------------------------------------------------------------------|"
BitacoraRen19     DB "| [A] Agregar  [S] Siguiente  [P] Anterior  [F] Filtrar  [I] Imprimir      |"
BitacoraRen20     DB "| [R] Ronda del Robot  [ESC] Volver                                        |"

; ---- Texto base de bitacora.txt: vacia (sin eventos inventados). Se escribe solo si el archivo no existe
TextoBitacora     DB "|   (sin eventos registrados todavia)                                      |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10
                  DB "|                                                                          |",13,10

.CODE
Inicio:
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX                   ; ES = DS, necesario para IMPCAD_COLOR
    CREAR_CARPETA RutaRaiz      ; si ya existe, DOS da error y se ignora
    CREAR_CARPETA RutaDaniel
    CALL ControlBitacora
Fin:
    MOV AX,4C00H                ; termina con codigo 0
    INT 21H

;==================== BITACORA DE EVENTOS ====================

; Teclas: A agregar, S siguiente, P anterior, F filtrar, I imprimir, R ronda, ESC volver
ControlBitacora PROC
    MOV ErrorDeArchivo,0
    CALL CargarBitacora
    CMP ErrorDeArchivo,1
    JE BitacoraSalir
BitacoraRedibujar:
    CALL DibujarBitacora
    RASTREO
    CMP AL,27                   ; ESC
    JE BitacoraSalir
    CMP AL,'A'
    JE BitacoraTeclaAgregar
    CMP AL,'S'
    JE BitacoraTeclaSiguiente
    CMP AL,'P'
    JE BitacoraTeclaAnterior
    CMP AL,'F'
    JE BitacoraTeclaFiltrar
    CMP AL,'I'
    JE BitacoraTeclaImprimir
    CMP AL,'R'
    JE BitacoraTeclaRonda
    JMP BitacoraRedibujar
BitacoraTeclaAgregar:
    CALL PedirEventoNuevo
    JMP BitacoraRedibujar
BitacoraTeclaSiguiente:
    CALL IrPaginaSiguiente
    JMP BitacoraRedibujar
BitacoraTeclaAnterior:
    CALL IrPaginaAnterior
    JMP BitacoraRedibujar
BitacoraTeclaFiltrar:
    CALL PedirFiltro
    JMP BitacoraRedibujar
BitacoraTeclaImprimir:
    CALL ImprimirBitacora
    JMP BitacoraRedibujar
BitacoraTeclaRonda:
    CALL RondaDelRobot
    JMP BitacoraRedibujar
BitacoraSalir:
    RET
ControlBitacora ENDP


;==================== ARCHIVO ====================

; Lee bitacora.txt al buffer y cuenta los registros. Si no existe, lo crea con los de ejemplo
CargarBitacora PROC
    ABRIR_ARCHIVO RutaBitacora,0
    JC BitacoraNoExiste
    JMP BitacoraAbierta
BitacoraNoExiste:
    CALL CrearBitacoraInicial
    ABRIR_ARCHIVO RutaBitacora,0
    JC ErrorAlLeerBitacora
BitacoraAbierta:
    LEER_ARCHIVO 1872,BufferBitacora,ID
    JC ErrorAlLeerBitacora
    MOV BytesLeidos,AX
    CERRAR_ARCHIVO ID
    CALL ContarRegistros
    RET
ErrorAlLeerBitacora:
    MOV ErrorDeArchivo,1
    CURSOR 22,3,0
    IMP_SINCOLOR MensajeErrorArchivo
    RASTREO
    RET
CargarBitacora ENDP

; Crea bitacora.txt con 8 eventos de ejemplo (solo cuando todavia no existe)
CrearBitacoraInicial PROC
    CREAR_ARCHIVO RutaBitacora,32
    MOV ID,AX
    ESCRIBIR_ARCHIVO ID,624,TextoBitacora
    CERRAR_ARCHIVO ID
    RET
CrearBitacoraInicial ENDP

; Cada 78 bytes leidos es un registro
ContarRegistros PROC
    MOV RegistrosEnMemoria,0
    MOV BytesEnMemoria,0
    MOV AX,BytesLeidos
ContarSiguienteRegistro:
    CMP AX,78
    JC FinContarRegistros       ; quedan menos de 78 bytes
    SUB AX,78
    ADD RegistrosEnMemoria,1
    ADD BytesEnMemoria,78
    JMP ContarSiguienteRegistro
FinContarRegistros:
    RET
ContarRegistros ENDP

; Agrega un registro al final de bitacora.txt.
; Al leer el archivo completo el puntero queda al final, y lo que se escribe despues se agrega.
; Entrada: TipoDeEvento, ZonaDelEvento y, si es 'M', LongitudEvento y CapturaEvento
AgregarEventoABitacora PROC
    ABRIR_ARCHIVO RutaBitacora,2
    JC FinAgregarEvento
    LEER_ARCHIVO 1872,BufferBitacora,ID
    JC FinAgregarEvento
    CMP AX,1872
    JC AgregarHayLugar          ; menos de 24 registros
    CERRAR_ARCHIVO ID           ; bitacora llena
    RET
AgregarHayLugar:
    MOV DI,OFFSET TextoHora      ; hora real del sistema
    CALL HoraEnTexto
    ESCRIBIR_ARCHIVO ID,2,TextoInicioDeRegistro
    ESCRIBIR_ARCHIVO ID,5,TextoHora
    ESCRIBIR_ARCHIVO ID,3,TextoAntesDeZona
    ESCRIBIR_ARCHIVO ID,1,ZonaDelEvento
    ESCRIBIR_ARCHIVO ID,1,TextoEspacio
    CALL EscribirNombreDeZona
    ESCRIBIR_ARCHIVO ID,2,TextoDosEspacios
    CMP TipoDeEvento,'R'
    JE AgregarEventoDeRonda
    ESCRIBIR_ARCHIVO ID,LongitudEvento,CapturaEvento+2
    JMP AgregarRellenarEvento
AgregarEventoDeRonda:
    MOV LongitudEvento,26
    ESCRIBIR_ARCHIVO ID,26,TextoEventoRonda
AgregarRellenarEvento:
    MOV AX,30                   ; el evento ocupa 30 posiciones
    SUB AX,LongitudEvento
    MOV RellenoEvento,AX
    CMP RellenoEvento,0
    JE AgregarEscribirUsuario   ; escribir 0 bytes borraria el archivo
    ESCRIBIR_ARCHIVO ID,RellenoEvento,TextoRellenoEvento
AgregarEscribirUsuario:
    ESCRIBIR_ARCHIVO ID,2,TextoDosEspacios
    CMP TipoDeEvento,'R'
    JE AgregarUsuarioRobot
    ESCRIBIR_ARCHIVO ID,5,TextoUsuarioAdmin
    JMP AgregarTerminarRegistro
AgregarUsuarioRobot:
    ESCRIBIR_ARCHIVO ID,5,TextoUsuarioRobot
AgregarTerminarRegistro:
    ESCRIBIR_ARCHIVO ID,9,TextoFinDeRegistro
    CERRAR_ARCHIVO ID
FinAgregarEvento:
    RET
AgregarEventoABitacora ENDP

; Escribe la hora real de DOS (INT 21h/2Ch) como "HH:MM" en 5 bytes.  Entrada: DI = destino
HoraEnTexto PROC
    MOV AH,2Ch
    INT 21H                     ; CH = horas, CL = minutos
    PUSH CX
    MOV AL,CH
    AAM                         ; AH = decenas, AL = unidades
    ADD AX,3030H
    MOV [DI],AH
    MOV [DI+1],AL
    MOV BYTE PTR [DI+2],':'
    POP CX
    MOV AL,CL
    AAM
    ADD AX,3030H
    MOV [DI+3],AH
    MOV [DI+4],AL
    RET
HoraEnTexto ENDP



; Escribe los 18 caracteres del nombre de la zona ZonaDelEvento
EscribirNombreDeZona PROC
    CMP ZonaDelEvento,'1'
    JNE NombreNoEsZona1
    ESCRIBIR_ARCHIVO ID,18,NombreZona1
    RET
NombreNoEsZona1:
    CMP ZonaDelEvento,'2'
    JNE NombreNoEsZona2
    ESCRIBIR_ARCHIVO ID,18,NombreZona2
    RET
NombreNoEsZona2:
    CMP ZonaDelEvento,'3'
    JNE NombreNoEsZona3
    ESCRIBIR_ARCHIVO ID,18,NombreZona3
    RET
NombreNoEsZona3:
    CMP ZonaDelEvento,'4'
    JNE NombreNoEsZona4
    ESCRIBIR_ARCHIVO ID,18,NombreZona4
    RET
NombreNoEsZona4:
    CMP ZonaDelEvento,'5'
    JNE NombreNoEsZona5
    ESCRIBIR_ARCHIVO ID,18,NombreZona5
    RET
NombreNoEsZona5:
    ESCRIBIR_ARCHIVO ID,18,NombreZona6
    RET
EscribirNombreDeZona ENDP


;==================== FILTRO Y PAGINAS ====================

; Entrada: SI = inicio del registro en BufferBitacora.  Salida: CumpleFiltro (1 o 0)
; La zona de cada registro es el caracter del byte 10 (la X de "ZX")
RegistroCumpleFiltro PROC
    MOV AL,FiltroDeZona
    CMP AL,'0'
    JE RegistroSiCumple         ; sin filtro: entran todos
    MOV AL,BufferBitacora[SI+10]
    CMP AL,FiltroDeZona
    JE RegistroSiCumple
    MOV CumpleFiltro,0
    RET
RegistroSiCumple:
    MOV CumpleFiltro,1
    RET
RegistroCumpleFiltro ENDP

; Cuenta los registros que cumplen el filtro
CalcularRegistrosVisibles PROC
    MOV RegistrosVisibles,0
    MOV SI,0
VisiblesSiguienteRegistro:
    CMP SI,BytesEnMemoria
    JE FinCalcularVisibles
    CALL RegistroCumpleFiltro
    CMP CumpleFiltro,1
    JNE VisiblesAvanzar
    ADD RegistrosVisibles,1
VisiblesAvanzar:
    ADD SI,78
    JMP VisiblesSiguienteRegistro
FinCalcularVisibles:
    RET
CalcularRegistrosVisibles ENDP

; Paginas de 8 registros: cada vez que quedan registros se suma una pagina y se restan 8
CalcularPaginas PROC
    MOV AL,RegistrosVisibles
    MOV TotalPaginas,0
PaginasSiguiente:
    CMP AL,0
    JE FinCalcularPaginas
    ADD TotalPaginas,1
    CMP AL,8
    JC FinCalcularPaginas       ; quedaban menos de 8
    SUB AL,8
    JMP PaginasSiguiente
FinCalcularPaginas:
    CMP TotalPaginas,0
    JNE PaginasListas
    MOV TotalPaginas,1          ; sin registros se muestra la pagina 1 de 1
PaginasListas:
    RET
CalcularPaginas ENDP

; Primer registro de la pagina actual = PaginaActual x 8 (sumando 8 por pagina)
CalcularPrimerRegistro PROC
    MOV PrimerRegistroDePagina,0
    MOV CL,PaginaActual
PrimerSumarOcho:
    CMP CL,0
    JE FinCalcularPrimero
    ADD PrimerRegistroDePagina,8
    SUB CL,1
    JMP PrimerSumarOcho
FinCalcularPrimero:
    MOV AL,PrimerRegistroDePagina
    ADD AL,8
    MOV LimiteDePagina,AL
    RET
CalcularPrimerRegistro ENDP

IrPaginaSiguiente PROC
    MOV AL,PaginaActual
    ADD AL,1
    CMP AL,TotalPaginas
    JE FinPaginaSiguiente       ; ya es la ultima pagina
    ADD PaginaActual,1
FinPaginaSiguiente:
    RET
IrPaginaSiguiente ENDP

IrPaginaAnterior PROC
    CMP PaginaActual,0
    JE FinPaginaAnterior        ; ya es la primera pagina
    SUB PaginaActual,1
FinPaginaAnterior:
    RET
IrPaginaAnterior ENDP


;==================== DIBUJO ====================

; Dibuja el marco, la pagina y los registros de la pagina actual
DibujarBitacora PROC
    CALL CalcularRegistrosVisibles
    CALL CalcularPaginas
    SCROLL_ARRIBA 0,0,0,24,79,1Fh
    IMPCAD_COLOR LineaMarco,76,0,0,0,0,1Bh
    IMPCAD_COLOR Logo1,76,1,0,0,0,1Eh
    IMPCAD_COLOR Logo2,76,2,0,0,0,1Eh
    IMPCAD_COLOR Logo3,76,3,0,0,0,1Eh
    IMPCAD_COLOR Logo4,76,4,0,0,0,1Eh
    IMPCAD_COLOR Logo5,76,5,0,0,0,1Eh
    IMPCAD_COLOR LineaMarco,76,6,0,0,0,1Bh
    IMPCAD_COLOR BitacoraRen07,76,7,0,0,0,1Eh
    IMPCAD_COLOR BitacoraRen08,76,8,0,0,0,17h
    IMPCAD_COLOR BitacoraRen09,76,9,0,0,0,1Eh
    MOV RenglonActual,10        ; renglones 10 a 17: lugar de los 8 registros
DibujarRenglonVacio:
    IMPCAD_COLOR BitacoraRenVacio,76,RenglonActual,0,0,0,1Fh
    ADD RenglonActual,1
    CMP RenglonActual,18
    JNE DibujarRenglonVacio
    IMPCAD_COLOR BitacoraRen18,76,18,0,0,0,17h
    IMPCAD_COLOR BitacoraRen19,76,19,0,0,0,1Fh
    IMPCAD_COLOR BitacoraRen20,76,20,0,0,0,1Fh
    IMPCAD_COLOR BitacoraRenVacio,76,21,0,0,0,1Fh
    IMPCAD_COLOR BitacoraRenVacio,76,22,0,0,0,1Fh
    IMPCAD_COLOR LineaMarco,76,23,0,0,0,1Bh
    MOV AL,PaginaActual
    ADD AL,'1'                  ; la pagina 0 se muestra como 1
    MOV TextoPagina,AL
    MOV AL,TotalPaginas
    ADD AL,'0'
    MOV TextoTotalPaginas,AL
    IMPCAD_COLOR TextoPagina,1,7,36,0,0,1Fh
    IMPCAD_COLOR TextoTotalPaginas,1,7,38,0,0,1Fh
    IMPCAD_COLOR FiltroDeZona,1,7,62,0,0,1Fh
    CALL PintarRegistrosDePagina
    RET
DibujarBitacora ENDP

; Revisa los registros en orden; los que cumplen el filtro se cuentan, y los que caen
; dentro de la pagina actual se pintan en los renglones 10 a 17
PintarRegistrosDePagina PROC
    CALL CalcularPrimerRegistro
    MOV RegistrosContados,0
    MOV RenglonActual,10
    MOV SI,0
PintarRevisarRegistro:
    CMP SI,BytesEnMemoria
    JE FinPintarRegistros
    CALL RegistroCumpleFiltro
    CMP CumpleFiltro,1
    JNE PintarAvanzarRegistro
    MOV AL,RegistrosContados
    CMP AL,PrimerRegistroDePagina
    JC PintarContarRegistro     ; todavia no llega a la pagina
    CMP AL,LimiteDePagina
    JE FinPintarRegistros       ; ya se pintaron los 8 de la pagina
    IMPCAD_COLOR BufferBitacora[SI],76,RenglonActual,0,0,0,1Fh
    ADD RenglonActual,1
PintarContarRegistro:
    ADD RegistrosContados,1
PintarAvanzarRegistro:
    ADD SI,78
    JMP PintarRevisarRegistro
FinPintarRegistros:
    RET
PintarRegistrosDePagina ENDP


;==================== FORMULARIOS ====================

; Tecla A: pide zona y evento, agrega el registro y vuelve a leer el archivo
PedirEventoNuevo PROC
    CMP RegistrosEnMemoria,24
    JNE EventoHayLugar
    IMPCAD_COLOR MensajeBitacoraLlena,50,21,3,0,0,1Ch
    RASTREO
    RET
EventoHayLugar:
    IMPCAD_COLOR TextoPedirZona,12,21,3,0,0,1Eh
    CURSOR 21,15,0
    RASTREO
    CMP AL,'1'
    JC EventoCancelado          ; menor que '1'
    CMP AL,'7'
    JC EventoZonaValida         ; '1' a '6'
EventoCancelado:
    RET
EventoZonaValida:
    MOV ZonaDelEvento,AL
    IMPCAD_COLOR ZonaDelEvento,1,21,15,0,0,1Eh
    IMPCAD_COLOR TextoPedirEvento,8,22,3,0,0,1Eh
    CURSOR 22,11,0
    LECTURA_CADENA CapturaEvento
    MOV AL,CapturaEvento+1      ; cuantos caracteres se escribieron
    CMP AL,0
    JE EventoCancelado
    MOV AH,0
    MOV LongitudEvento,AX
    MOV TipoDeEvento,'M'
    CALL AgregarEventoABitacora
    CALL CargarBitacora
    RET
PedirEventoNuevo ENDP

; Tecla F: pide la zona a mostrar (0 = todas)
PedirFiltro PROC
    IMPCAD_COLOR TextoPedirFiltro,29,21,3,0,0,1Eh
    CURSOR 21,32,0
    RASTREO
    CMP AL,'0'
    JC FiltroCancelado          ; menor que '0'
    CMP AL,'7'
    JC FiltroValido             ; '0' a '6'
FiltroCancelado:
    RET
FiltroValido:
    MOV FiltroDeZona,AL
    MOV PaginaActual,0
    RET
PedirFiltro ENDP


;==================== PRINTER ====================

; Tecla I: manda a la impresora los registros que cumplen el filtro y hace salto de pagina
ImprimirBitacora PROC
    MOV SI,0
ImprimirSiguienteRegistro:
    CMP SI,BytesEnMemoria
    JE ImprimirTerminar
    CALL RegistroCumpleFiltro
    CMP CumpleFiltro,1
    JE ImprimirEsteRegistro
    ADD SI,78
    JMP ImprimirSiguienteRegistro
ImprimirEsteRegistro:
    MOV CX,78                   ; un registro mide 78 bytes (incluye CR LF)
ImprimirSiguienteLetra:
    IMPRIMIR BufferBitacora[SI]
    ADD SI,1
    SUB CX,1
    CMP CX,0
    JNE ImprimirSiguienteLetra
    JMP ImprimirSiguienteRegistro
ImprimirTerminar:
    NEWPAGE
    IMPCAD_COLOR MensajeImpresa,52,21,3,0,0,1Ah
    RASTREO
    RET
ImprimirBitacora ENDP


;==================== ROBOT (puertos 9 y 11) ====================

; Tecla R: el Robot recorre las 6 zonas. En cada una avanza, enciende la lampara,
; se registra la visita y apaga la lampara. Necesita lugar para 6 registros
RondaDelRobot PROC
    CMP RegistrosEnMemoria,19
    JC RondaHayLugar            ; hay 18 registros o menos
    IMPCAD_COLOR MensajeRondaSinLugar,59,21,3,0,0,1Ch
    RASTREO
    RET
RondaHayLugar:
    MOV TipoDeEvento,'R'
    MOV ZonaDelEvento,'1'
    IMPCAD_COLOR MensajeRondaEnCurso,36,21,3,0,0,1Eh
RondaSiguienteZona:
    MOV AH,1                    ; INT 16h/1: hay tecla en el buffer?
    INT 16H
    JZ RondaSinTecla
    MOV AH,0
    INT 16H
    CMP AL,27                   ; ESC detiene al Robot
    JE RondaCancelada
RondaSinTecla:
    MOV AL,4                    ; 4 = examinar lo que hay enfrente
    CALL EnviarComandoRobot
    MOV DX,10
    IN AL,DX                    ; puerto 10: 255 = pared
    CMP AL,255
    JNE RondaAvanzar
    MOV AL,3                    ; 3 = girar a la derecha para no chocar
    CALL EnviarComandoRobot
RondaAvanzar:
    MOV AL,1                    ; 1 = avanzar
    CALL EnviarComandoRobot
    MOV AL,5                    ; 5 = encender la lampara
    CALL EnviarComandoRobot
    CALL AgregarEventoABitacora
    MOV AL,6                    ; 6 = apagar la lampara
    CALL EnviarComandoRobot
    ADD ZonaDelEvento,1
    CMP ZonaDelEvento,'7'
    JNE RondaSiguienteZona
    MOV TipoDeEvento,'M'
    CALL CargarBitacora
    IMPCAD_COLOR MensajeRondaTerminada,57,21,3,0,0,1Ah
    RASTREO
    RET
RondaCancelada:
    MOV AL,6                    ; 6 = apagar la lampara antes de parar
    CALL EnviarComandoRobot
    MOV TipoDeEvento,'M'
    CALL CargarBitacora
    IMPCAD_COLOR MensajeRondaCancelada,43,21,3,0,0,1Ch
    RASTREO
    RET
RondaDelRobot ENDP

; Entrada: AL = comando. Puerto 9 = comando, puerto 10 = dato, puerto 11 = estado
; (bit 0 dato nuevo, bit 1 ocupado, bit 2 el ultimo comando fallo).
; Si se manda un comando con el Robot ocupado lo rechaza ("busy!"), por eso se espera antes y despues.
EnviarComandoRobot PROC
    MOV ComandoRobot,AL
    CALL EsperarRobotLibre
    MOV AL,ComandoRobot
    MOV DX,9
    OUT DX,AL
    CALL EsperarUnMomento
    CALL EsperarRobotLibre
    RET
EnviarComandoRobot ENDP

; Espera hasta que el bit 1 (ocupado) del puerto 11 sea 0
EsperarRobotLibre PROC
    PUSH SI
    MOV SI,60000                ; limite: nunca se queda esperando para siempre
RobotLeerEstado:
    MOV DX,11
    IN AL,DX
    CMP AL,4
    JC RobotSinBit2
    SUB AL,4                    ; se quita el bit 2 (comando fallido)
RobotSinBit2:
    CMP AL,2
    JC RobotLibre               ; bit 1 apagado: ya no esta ocupado
    SUB SI,1
    CMP SI,0
    JNE RobotLeerEstado         ; 2 o 3: bit 1 encendido, sigue ocupado
RobotLibre:
    POP SI
    RET
EsperarRobotLibre ENDP

; Pausa corta para que el Robot alcance a empezar el comando
EsperarUnMomento PROC
    MOV CX,300
EsperarVuelta:
    SUB CX,1
    CMP CX,0
    JNE EsperarVuelta
    RET
EsperarUnMomento ENDP

END Inicio
