unit uComun;
{ Utilidades compartidas por todas las pantallas Delphi.
  Los .txt los escribe emu8086 en su disco virtual (<emu8086>\vdrive\C\AutonoLux\<integrante>\) }

interface

uses Classes;

function RutaArchivo(const Nombre: string): string;
procedure CrearArbolCarpetas;
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
    ShellExecute(0, 'open', PChar(Emu), PChar('"' + Ruta + '"'),
      PChar(ExtractFilePath(Emu)), SW_SHOWNORMAL)
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
