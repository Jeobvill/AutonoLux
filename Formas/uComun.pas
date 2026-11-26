unit uComun;
{ Utilidades compartidas por todas las pantallas Delphi.
  Los .txt los escribe emu8086 en su disco virtual (<emu8086>\vdrive\C\AutonoLux\<integrante>\) }

interface

uses Classes;

function RutaArchivo(const Nombre: string): string;
procedure CrearArbolCarpetas;
{ config.txt (Sergio): lineas "Opcion N: valor", igual que escribe Configuracion.asm.
  1 espera(min) 2 aforo 3 watts/lampara 4 tarifa 5 horario 6 sensibilidad }
function ConfigValor(N: Integer): string;
procedure ConfigGuardar(const Valores: array of string);
function ConfigDefecto(N: Integer): string;
function ConfigEntero(N: Integer): Integer;
function ConfigTarifa: Double;
{ Consumo real: se muestrea iluminacion.txt (lo escribe Iluminacion.asm) mientras Delphi esta abierto }
const
  LAMPARAS_ZONA = 4;
var
  SegEnc: array[0..5] of Double;    { segundos encendida cada zona }
  WhZona: array[0..5] of Double;    { Wh acumulados por zona }
  SegTotal: Double;                 { segundos muestreados (para el caso "sin automatizar") }
  PotenciaAhora: Double;            { W en este momento }
function LeerIluminacion(var Luz, Inten: array of Integer): Boolean;
procedure MuestrearConsumo(Segundos: Double);
procedure GuardarConsumo;
{ Mapa de calor real: persona-segundos por zona segun mapa.txt, por dia / semana / mes }
var
  CalorSeg: array[0..2, 0..5] of Double;
procedure MuestrearCalor(Segundos: Double);
procedure GuardarCalor;
const
  NOMBRES_ZONA: array[0..5] of string = ('Recepcion', 'Lectura Silenciosa',
    'Sala de Computo', 'Hemeroteca', 'Estantes A-F', 'Sala de Grupos');
var
  UsuarioActual: string;
{ Bitacora real: registra en eventos.txt cada cambio de luz u ocupacion de zona }
procedure RegistrarEventos;
procedure ResumenReal(L: TStrings);
procedure CargarCalor;
procedure CargarConsumo;
function NumeroTras(const Linea, Clave: string): Integer;
{ Video del proyecto y entrevista (FormVideo) }
const
  { Enlace de la entrevista en EVA (assign id=72807). Si el dominio no es el de su plataforma,
    pegue el enlace completo en Video\entrevista.txt y se usa ese. }
  URL_ENTREVISTA = 'https://eva.ittepic.edu.mx/mod/assign/view.php?id=72807';
function RutaTrailer: string;
function UrlEntrevista: string;
function AbrirArchivoOEnlace(const Destino: string): Boolean;
function BuscarEmu(const Exe: string): string;
function LanzarEmu(const Exe: string): Boolean;
procedure LeerPersonasMapa(var Personas: array of Integer);
function CargarLineas(const Nombre: string; L: TStringList): Boolean;
function Campo(const Linea: string; N: Integer): string;
function ExtraerEntero(const S: string; Def: Integer): Integer;

implementation

uses SysUtils, Windows, ShellAPI, Dialogs, StrUtils;

{ emu8086 guarda los archivos de los .asm en su disco virtual: lo que el .asm escribe en
  C:\AutonoLux\... queda realmente en <carpeta de emu8086>\vdrive\C\AutonoLux\...
  (igual que la ruta que usa el proyecto de Veliz: C:\emu8086\vdrive\C\...). }
function CarpetaEmu: string;
const
  RUTAS: array[0..3] of string = ('C:\LI\lemu8086\emu8086\', 'C:\emu8086\',
    'C:\Program Files (x86)\emu8086\', 'C:\Program Files\emu8086\');
var
  i: Integer;
begin
  Result := '';
  for i := 0 to High(RUTAS) do
    if DirectoryExists(RUTAS[i] + 'vdrive\C') then
    begin
      Result := RUTAS[i];
      Exit;
    end;
end;

{ Raiz AutonoLux donde estan los .txt: el disco virtual de emu8086; si no existe, C:\AutonoLux\ }
function RaizDatos: string;
begin
  if CarpetaEmu <> '' then
    Result := CarpetaEmu + 'vdrive\C\AutonoLux\'
  else
    Result := 'C:\AutonoLux\';
end;

{ Carpeta de cada archivo: la misma donde lo escribe su programa .asm }
function CarpetaDe(const Nombre: string): string;
begin
  if (SameText(Nombre, 'config.txt')) or (SameText(Nombre, 'consumo.txt')) or (SameText(Nombre, 'consumo_acum.txt')) then
    Result := 'Sergio'
  else if (SameText(Nombre, 'usuarios.txt')) or (SameText(Nombre, 'login_out.txt'))
    or (SameText(Nombre, 'reporte.txt')) or (SameText(Nombre, 'acerca.txt')) then
    Result := 'Axel'
  else if (SameText(Nombre, 'zonas.txt')) or (SameText(Nombre, 'bitacora.txt')) or (SameText(Nombre, 'eventos.txt'))
    or (SameText(Nombre, 'calor.txt')) or (SameText(Nombre, 'calor_acum.txt')) or (SameText(Nombre, 'temperatura.txt')) or (SameText(Nombre, 'robot_cmd.txt')) then
    Result := 'Daniel'
  else
    Result := 'Jesus';   { mapa.txt, iluminacion.txt, visitantes.txt }
end;

function RutaArchivo(const Nombre: string): string;
begin
  Result := RaizDatos + CarpetaDe(Nombre) + '\' + Nombre;
end;

{ Raiz y una carpeta por integrante, igual que CREAR_CARPETA en los .asm }
procedure CrearArbolCarpetas;
begin
  ForceDirectories(RaizDatos + 'Sergio');
  ForceDirectories(RaizDatos + 'Axel');
  ForceDirectories(RaizDatos + 'Daniel');
  ForceDirectories(RaizDatos + 'Jesus');
end;

function ConfigDefecto(N: Integer): string;
begin
  case N of
    1: Result := '5';
    2: Result := '60';
    3: Result := '18';
    4: Result := '2.50';
    5: Result := '08:00-18:00';
    6: Result := 'Media';
  else Result := '';
  end;
end;

function ConfigValor(N: Integer): string;
var
  L: TStringList;
  i, p: Integer;
  Pref: string;
begin
  Result := ConfigDefecto(N);
  L := TStringList.Create;
  try
    if CargarLineas('config.txt', L) then
    begin
      Pref := 'Opcion ' + IntToStr(N) + ':';
      for i := 0 to L.Count - 1 do
      begin
        p := Pos(Pref, L[i]);
        if (p = 1) and (Trim(Copy(L[i], Length(Pref) + 1, 40)) <> '') then
          Result := Trim(Copy(L[i], Length(Pref) + 1, 40));   { gana la ultima }
      end;
    end;
  finally
    L.Free;
  end;
end;

function ConfigEntero(N: Integer): Integer;
begin
  Result := StrToIntDef(ConfigValor(N), StrToIntDef(ConfigDefecto(N), 0));
end;

function ConfigTarifa: Double;
var
  T: string;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  T := StringReplace(ConfigValor(4), '$', '', [rfReplaceAll]);
  T := StringReplace(T, ',', '.', [rfReplaceAll]);
  Result := StrToFloatDef(Trim(T), 2.5, FS);
end;

procedure ConfigGuardar(const Valores: array of string);
var
  L: TStringList;
  i: Integer;
begin
  L := TStringList.Create;
  try
    for i := 0 to High(Valores) do
      L.Add('Opcion ' + IntToStr(i + 1) + ': ' + Valores[i]);
    L.SaveToFile(RutaArchivo('config.txt'));
  finally
    L.Free;
  end;
end;


{ Numero que sigue a Clave: "Evento ENTRA sala 012 entradas 015 salidas 003 pico 014" }
function NumeroTras(const Linea, Clave: string): Integer;
var
  p: Integer;
  S: string;
begin
  Result := 0;
  p := Pos(' ' + Clave + ' ', Linea);
  if p = 0 then Exit;
  S := Trim(Copy(Linea, p + Length(Clave) + 2, 6));
  p := Pos(' ', S);
  if p > 0 then S := Copy(S, 1, p - 1);
  Result := StrToIntDef(S, 0);
end;

{ iluminacion.txt: "Zona N modo X luz L int III%". False si el archivo no existe (nada emulado) }
function LeerIluminacion(var Luz, Inten: array of Integer): Boolean;
var
  L: TStringList;
  i, z: Integer;
  S: string;
begin
  for i := 0 to High(Luz) do begin Luz[i] := 0; Inten[i] := 0; end;
  L := TStringList.Create;
  try
    Result := CargarLineas('iluminacion.txt', L);
    if not Result then Exit;
    for i := 0 to L.Count - 1 do
    begin
      z := NumeroTras(L[i], 'Zona'); { "Zona 1 ..." empieza sin espacio previo }
      if z = 0 then z := StrToIntDef(Copy(Trim(L[i]), 6, 1), 0);
      if (z < 1) or (z > 6) then Continue;
      Luz[z - 1] := NumeroTras(L[i], 'luz');
      S := Copy(L[i], Pos(' int ', L[i]) + 5, 3);
      Inten[z - 1] := StrToIntDef(Trim(S), 0);
    end;
  finally
    L.Free;
  end;
end;

procedure MuestrearConsumo(Segundos: Double);
var
  Luz, Inten: array[0..5] of Integer;
  z: Integer;
  W: Double;
begin
  PotenciaAhora := 0;
  if not LeerIluminacion(Luz, Inten) then Exit;
  SegTotal := SegTotal + Segundos;
  for z := 0 to 5 do
    if Luz[z] = 1 then
    begin
      W := LAMPARAS_ZONA * ConfigEntero(3) * Inten[z] / 100;
      PotenciaAhora := PotenciaAhora + W;
      SegEnc[z] := SegEnc[z] + Segundos;
      WhZona[z] := WhZona[z] + W * Segundos / 3600;
    end;
end;

procedure GuardarConsumo;
var
  L: TStringList;
  z: Integer;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  L := TStringList.Create;
  try
    L.Add('Total;' + FloatToStr(SegTotal, FS));
    for z := 0 to 5 do
      L.Add(IntToStr(z + 1) + ';' + FloatToStr(SegEnc[z], FS) + ';' + FloatToStr(WhZona[z], FS));
    try L.SaveToFile(RutaArchivo('consumo_acum.txt')); except end;
  finally
    L.Free;
  end;
end;

procedure CargarConsumo;
var
  L: TStringList;
  z: Integer;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  L := TStringList.Create;
  try
    if not CargarLineas('consumo_acum.txt', L) then Exit;
    if L.Count > 0 then SegTotal := StrToFloatDef(Campo(L[0], 1), 0, FS);
    for z := 0 to 5 do
      if L.Count > z + 1 then
      begin
        SegEnc[z] := StrToFloatDef(Campo(L[z + 1], 1), 0, FS);
        WhZona[z] := StrToFloatDef(Campo(L[z + 1], 2), 0, FS);
      end;
  finally
    L.Free;
  end;
end;

function ClavePeriodo(P: Integer): string;
var
  A, M, D: Word;
begin
  DecodeDate(Date, A, M, D);
  case P of
    0: Result := FormatDateTime('yyyy-mm-dd', Date);
    1: Result := Format('%d-S%.2d', [A, (Trunc(Date) - Trunc(EncodeDate(A, 1, 1))) div 7 + 1]);
  else Result := Format('%d-%.2d', [A, M]);
  end;
end;

var
  ClaveCalor: array[0..2] of string;

procedure MuestrearCalor(Segundos: Double);
var
  Pers: array[0..5] of Integer;
  P, z: Integer;
begin
  for P := 0 to 2 do
    if ClaveCalor[P] <> ClavePeriodo(P) then   { cambio de dia/semana/mes: reinicia }
    begin
      ClaveCalor[P] := ClavePeriodo(P);
      for z := 0 to 5 do CalorSeg[P, z] := 0;
    end;
  LeerPersonasMapa(Pers);   { 0 si aun no existe mapa.txt }
  for P := 0 to 2 do
    for z := 0 to 5 do
      CalorSeg[P, z] := CalorSeg[P, z] + Pers[z] * Segundos;
end;

procedure GuardarCalor;
var
  L: TStringList;
  P, z: Integer;
  S: string;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  L := TStringList.Create;
  try
    for P := 0 to 2 do
    begin
      S := ClaveCalor[P];
      for z := 0 to 5 do S := S + ';' + FloatToStr(CalorSeg[P, z], FS);
      L.Add(S);
    end;
    try L.SaveToFile(RutaArchivo('calor_acum.txt')); except end;
  finally
    L.Free;
  end;
end;

procedure CargarCalor;
var
  L: TStringList;
  P, z: Integer;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  for P := 0 to 2 do ClaveCalor[P] := ClavePeriodo(P);
  L := TStringList.Create;
  try
    if not CargarLineas('calor_acum.txt', L) then Exit;
    for P := 0 to 2 do
      if (L.Count > P) and (Campo(L[P], 0) = ClavePeriodo(P)) then
        for z := 0 to 5 do
          CalorSeg[P, z] := StrToFloatDef(Campo(L[P], z + 1), 0, FS);
  finally
    L.Free;
  end;
end;

var
  PrevLuz, PrevOcup: array[0..5] of Integer;
  BaseEventos: Boolean = False;

procedure AgregarEvento(const Zona, Evento: string);
var
  L: TStringList;
  U: string;
begin
  U := UsuarioActual;
  if U = '' then U := 'sistema';
  L := TStringList.Create;
  try
    CargarLineas('eventos.txt', L);
    L.Add(FormatDateTime('hh:nn:ss', Now) + ';' + Zona + ';' + Evento + ';' + U);
    try L.SaveToFile(RutaArchivo('eventos.txt')); except end;
  finally
    L.Free;
  end;
end;

procedure RegistrarEventos;
var
  Luz, Inten: array[0..5] of Integer;
  Pers: array[0..5] of Integer;
  z, ocup: Integer;
begin
  if not LeerIluminacion(Luz, Inten) then Exit;
  LeerPersonasMapa(Pers);
  for z := 0 to 5 do
  begin
    if Pers[z] > 0 then ocup := 1 else ocup := 0;
    if BaseEventos then
    begin
      if Luz[z] <> PrevLuz[z] then
        if Luz[z] = 1 then AgregarEvento(NOMBRES_ZONA[z], 'Luz ON')
        else AgregarEvento(NOMBRES_ZONA[z], 'Luz OFF');
      if ocup <> PrevOcup[z] then
        if ocup = 1 then AgregarEvento(NOMBRES_ZONA[z], 'Zona ocupada (' + IntToStr(Pers[z]) + ')')
        else AgregarEvento(NOMBRES_ZONA[z], 'Zona libre');
    end;
    PrevLuz[z] := Luz[z];
    PrevOcup[z] := ocup;
  end;
  BaseEventos := True;
end;

{ Resumen del dia calculado con los datos reales (mapa, iluminacion, visitantes, config) }
procedure ResumenReal(L: TStrings);
var
  Luz, Inten: array[0..5] of Integer;
  Pers: array[0..5] of Integer;
  V: TStringList;
  z, enc, ocup, tot: Integer;
  kwh: Double;
begin
  LeerPersonasMapa(Pers);
  LeerIluminacion(Luz, Inten);
  enc := 0; ocup := 0; tot := 0; kwh := 0;
  for z := 0 to 5 do
  begin
    if Luz[z] = 1 then Inc(enc);
    if Pers[z] > 0 then Inc(ocup);
    Inc(tot, Pers[z]);
    kwh := kwh + WhZona[z] / 1000;
    L.Add(Format('Zona %d %-20s personas %2d  luz %s', [z + 1, NOMBRES_ZONA[z], Pers[z],
      IfThen(Luz[z] = 1, 'ON ', 'OFF')]));
  end;
  L.Add(Format('Zonas ocupadas: %d/6   Zonas con luz: %d/6   Personas en zonas: %d', [ocup, enc, tot]));
  V := TStringList.Create;
  try
    if CargarLineas('visitantes.txt', V) and (V.Count > 0) then
      L.Add(Format('Visitantes: dentro %d  entradas %d  salidas %d  pico %d  (aforo %d)',
        [NumeroTras(V[V.Count - 1], 'sala'), NumeroTras(V[V.Count - 1], 'entradas'),
         NumeroTras(V[V.Count - 1], 'salidas'), NumeroTras(V[V.Count - 1], 'pico'), ConfigEntero(2)]))
    else
      L.Add('Visitantes: sin datos (emule Contador)');
  finally
    V.Free;
  end;
  L.Add(Format('Consumo acumulado: %s kWh   costo $ %s', [FormatFloat('0.0000', kwh),
    FormatFloat('0.00', kwh * ConfigTarifa)]));
end;

{ Carpeta Video junto al programa, en la raiz del proyecto (..\Video, ..\..\Video) }
function CarpetaVideo: string;
const
  REL: array[0..3] of string = ('Video\', '..\Video\', '..\..\Video\', '');
var
  i: Integer;
  Base: string;
begin
  Base := ExtractFilePath(ParamStr(0));
  Result := Base + 'Video\';
  for i := 0 to High(REL) do
    if DirectoryExists(Base + REL[i]) and (REL[i] <> '') then
    begin
      Result := ExpandFileName(Base + REL[i]);
      Exit;
    end;
end;

{ Trailer: Video\Trailer.mp4 (o .avi, .wmv, .mov, .mkv). Vacio si todavia no esta el archivo }
function RutaTrailer: string;
const
  EXT: array[0..4] of string = ('.mp4', '.avi', '.wmv', '.mov', '.mkv');
var
  i: Integer;
begin
  for i := 0 to High(EXT) do
    if FileExists(CarpetaVideo + 'Trailer' + EXT[i]) then
    begin
      Result := CarpetaVideo + 'Trailer' + EXT[i];
      Exit;
    end;
  Result := '';
end;

{ Video\entrevista.txt (primera linea con http) sustituye al enlace de URL_ENTREVISTA }
function UrlEntrevista: string;
var
  L: TStringList;
begin
  Result := URL_ENTREVISTA;
  if not FileExists(CarpetaVideo + 'entrevista.txt') then Exit;
  L := TStringList.Create;
  try
    try
      L.LoadFromFile(CarpetaVideo + 'entrevista.txt');
      if (L.Count > 0) and (Pos('http', LowerCase(Trim(L[0]))) = 1) then
        Result := Trim(L[0]);
    except
    end;
  finally
    L.Free;
  end;
end;

function AbrirArchivoOEnlace(const Destino: string): Boolean;
begin
  Result := ShellExecute(0, 'open', PChar(Destino), nil, nil, SW_SHOWNORMAL) > 32;
end;

{ Un .exe de Emu8086 es un programa DOS de 16 bits: Windows moderno no lo ejecuta solo.
  Por eso Delphi busca el .asm del mismo nombre (junto al programa, en Emu8086, ..\Emu8086
  o ..\..\Emu8086) y lo abre en emu8086, donde se emula con sus devices. }
function BuscarEmu(const Exe: string): string;
var
  Base, NombreAsm: string;
begin
  Base := ExtractFilePath(ParamStr(0));
  NombreAsm := ChangeFileExt(Exe, '.asm');
  Result := Base + NombreAsm;
  if FileExists(Result) then Exit;
  Result := Base + 'Emu8086\' + NombreAsm;
  if FileExists(Result) then Exit;
  Result := Base + '..\Emu8086\' + NombreAsm;
  if FileExists(Result) then Exit;
  Result := Base + '..\..\Emu8086\' + NombreAsm;   { Delphi compila en Win32\Debug }
  if FileExists(Result) then Exit;
  Result := '';
end;

{ Programa emu8086.exe dentro de la carpeta de instalacion detectada }
function BuscarEmulador: string;
begin
  Result := '';
  if (CarpetaEmu <> '') and FileExists(CarpetaEmu + 'emu8086.exe') then
    Result := CarpetaEmu + 'emu8086.exe';
end;

{ Abre el .asm en emu8086 y, si AUTO_EMULAR, manda F5 (Emulate) para que compile y corra
  sin que el usuario toque nada. F5 es el atajo de "emulate" en emu8086. }
procedure AbrirYEmular(const Emu, Ruta: string);
const
  AUTO_EMULAR = True;
var
  Info: TShellExecuteInfo;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := SEE_MASK_NOCLOSEPROCESS;
  Info.lpVerb := 'open';
  Info.lpFile := PChar(Emu);
  Info.lpParameters := PChar('"' + Ruta + '"');
  Info.lpDirectory := PChar(ExtractFilePath(Emu));
  Info.nShow := SW_SHOWNORMAL;
  if not ShellExecuteEx(@Info) then Exit;
  if AUTO_EMULAR and (Info.hProcess <> 0) then
  begin
    WaitForInputIdle(Info.hProcess, 10000);   { espera a que emu8086 termine de abrir }
    Sleep(1500);                              { y de cargar el archivo }
    keybd_event(VK_F5, 0, 0, 0);
    keybd_event(VK_F5, 0, KEYEVENTF_KEYUP, 0);
  end;
  if Info.hProcess <> 0 then
    CloseHandle(Info.hProcess);
end;

{ True si se abrio el programa en emu8086; las pantallas Delphi solo llaman y Emu ejecuta }
function LanzarEmu(const Exe: string): Boolean;
var
  Ruta, Emu: string;
begin
  Ruta := BuscarEmu(Exe);
  Result := Ruta <> '';
  if not Result then
  begin
    ShowMessage('No se encontr' + #243 + ' ' + ChangeFileExt(Exe, '.asm') + ' en la carpeta Emu8086.');
    Exit;
  end;
  Emu := BuscarEmulador;
  if Emu <> '' then
    AbrirYEmular(Emu, Ruta)
  else   { emu8086 no esta en las rutas conocidas: lo abre Windows por asociacion }
    ShellExecute(0, 'open', PChar(Ruta), nil, PChar(ExtractFilePath(Ruta)), SW_SHOWNORMAL);
end;

{ Carga un .txt; quita lineas vacias al final. False si no existe o esta bloqueado }
function CargarLineas(const Nombre: string; L: TStringList): Boolean;
begin
  Result := False;
  L.Clear;
  if FileExists(RutaArchivo(Nombre)) then
  try
    L.LoadFromFile(RutaArchivo(Nombre));
    Result := True;
  except
    L.Clear;
    Result := False;
  end;
  while (L.Count > 0) and (Trim(L[L.Count - 1]) = '') do
    L.Delete(L.Count - 1);
end;

{ Personas por zona leidas de mapa.txt (el [#] o [ ] y el numero de cada caja) }
procedure LeerPersonasMapa(var Personas: array of Integer);
const
  RENGLON: array[0..5] of Integer = (11, 11, 11, 16, 16, 16);
  COLUMNA_PERSONAS: array[0..5] of Integer = (15, 39, 63, 15, 39, 63);
var
  L: TStringList;
  i: Integer;
begin
  for i := 0 to High(Personas) do
    Personas[i] := 0;
  L := TStringList.Create;
  try
    if CargarLineas('mapa.txt', L) then
      for i := 0 to 5 do
        if (i <= High(Personas)) and (RENGLON[i] < L.Count) then
          Personas[i] := StrToIntDef(
            Trim(Copy(L[RENGLON[i]], COLUMNA_PERSONAS[i], 3)), 0);
  finally
    L.Free;
  end;
end;

{ Campo N (base 0) de una linea separada por ';' }
function Campo(const Linea: string; N: Integer): string;
var
  i, ini, k: Integer;
begin
  Result := '';
  k := 0;
  ini := 1;
  for i := 1 to Length(Linea) + 1 do
    if (i > Length(Linea)) or (Linea[i] = ';') then
    begin
      if k = N then
      begin
        Result := Trim(Copy(Linea, ini, i - ini));
        Exit;
      end;
      Inc(k);
      ini := i + 1;
    end;
end;

{ Ultimo grupo de digitos de la cadena: "12:30;17" -> 17, "AforoMax=60" -> 60 }
function ExtraerEntero(const S: string; Def: Integer): Integer;
var
  i, fin: Integer;
begin
  Result := Def;
  i := Length(S);
  while (i > 0) and not (S[i] in ['0'..'9']) do Dec(i);
  if i = 0 then Exit;
  fin := i;
  while (i > 0) and (S[i] in ['0'..'9']) do Dec(i);
  Result := StrToIntDef(Copy(S, i + 1, fin - i), Def);
end;

end.
