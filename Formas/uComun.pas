unit uComun;
{ Utilidades compartidas por todas las pantallas Delphi.
  Los .txt los escribe emu8086 en su disco virtual (<emu8086>\vdrive\C\AutonoLux\<integrante>\) }

interface

uses Classes;

function RutaArchivo(const Nombre: string): string;
procedure CrearArbolCarpetas;
procedure CrearDatosEjemplo;
function BuscarEmu(const Exe: string): string;
function LanzarEmu(const Exe: string): Boolean;
procedure LeerPersonasMapa(var Personas: array of Integer);
function CargarLineas(const Nombre: string; L: TStringList): Boolean;
function Campo(const Linea: string; N: Integer): string;
function ExtraerEntero(const S: string; Def: Integer): Integer;

implementation

uses SysUtils, Windows, ShellAPI, Dialogs;

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
  if (SameText(Nombre, 'config.txt')) or (SameText(Nombre, 'consumo.txt')) then
    Result := 'Sergio'
  else if (SameText(Nombre, 'usuarios.txt')) or (SameText(Nombre, 'login_out.txt'))
    or (SameText(Nombre, 'reporte.txt')) or (SameText(Nombre, 'acerca.txt')) then
    Result := 'Axel'
  else if (SameText(Nombre, 'zonas.txt')) or (SameText(Nombre, 'bitacora.txt'))
    or (SameText(Nombre, 'calor.txt')) or (SameText(Nombre, 'robot_cmd.txt')) then
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

{ Escribe un archivo de ejemplo solo si todavia no existe (nunca pisa datos reales) }
procedure EscribirSiNoExiste(const Nombre: string; const Lineas: array of string);
var
  L: TStringList;
  i: Integer;
begin
  if FileExists(RutaArchivo(Nombre)) then Exit;
  L := TStringList.Create;
  try
    for i := 0 to High(Lineas) do
      L.Add(Lineas[i]);
    try
      L.SaveToFile(RutaArchivo(Nombre));
    except
      { sin permiso de escritura: las pantallas quedan en blanco, sin error }
    end;
  finally
    L.Free;
  end;
end;

{ Datos de ejemplo para que las pantallas no salgan vacias antes de emular los .asm }
procedure CrearDatosEjemplo;
begin
  EscribirSiNoExiste('config.txt', ['AforoMax=60', 'Temperatura=28']);
  EscribirSiNoExiste('visitantes.txt', [
    'Evento INICIO sala 000 entradas 000 salidas 000 pico 000',
    'Evento ENTRA  sala 001 entradas 001 salidas 000 pico 001',
    'Evento ENTRA  sala 002 entradas 002 salidas 000 pico 002',
    'Evento ENTRA  sala 003 entradas 003 salidas 000 pico 003',
    'Evento SALE   sala 002 entradas 003 salidas 001 pico 003']);
  EscribirSiNoExiste('iluminacion.txt', [
    'Zona 1 modo A luz 1 int 100%',
    'Zona 2 modo M luz 1 int 080%',
    'Zona 3 modo M luz 0 int 000%']);
  EscribirSiNoExiste('zonas.txt', [
    'Recepcion;Ocupada;5;ON;12:30',
    'Lectura Silenciosa;Ocupada;3;ON;11:10',
    'Sala de Computo;Libre;0;OFF;-',
    'Hemeroteca;Ocupada;2;ON;09:45',
    'Estantes A-F;Libre;0;OFF;-',
    'Sala de Grupos;Ocupada;7;ON;13:05']);
  EscribirSiNoExiste('bitacora.txt', [
    '08:00;Recepcion;Luz ON;admin',
    '08:15;Lectura Silenciosa;Luz ON;admin',
    '09:45;Hemeroteca;Luz ON;admin',
    '11:10;Sala de Computo;Luz OFF;admin',
    '12:30;Recepcion;Zona ocupada;admin']);
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
