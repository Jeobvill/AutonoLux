unit uComun;
{ Utilidades compartidas por uMonitor, uCalor y uBitacora }

interface

uses Classes;

function RutaArchivo(const Nombre: string): string;
procedure LanzarEmu(const Exe: string);
function CargarLineas(const Nombre: string; L: TStringList): Boolean;
function Campo(const Linea: string; N: Integer): string;
function ExtraerEntero(const S: string; Def: Integer): Integer;

implementation

uses SysUtils, Windows, ShellAPI, Dialogs;

{ Todos los .txt y .exe se buscan en la carpeta del programa Delphi }
function RutaArchivo(const Nombre: string): string;
begin
  Result := ExtractFilePath(ParamStr(0)) + Nombre;
end;

procedure LanzarEmu(const Exe: string);
var
  Ruta: string;
begin
  Ruta := RutaArchivo(Exe);
  if not FileExists(Ruta) then
  begin
    ShowMessage('No se encontr' + #243 + ' ' + Exe + ' en:' + #13#10 + ExtractFilePath(Ruta));
    Exit;
  end;
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
