unit uAxelComun;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.jpeg;

const
  // ----------------------------------------------------------------------
  // Estructura de carpetas del proyecto AutonoLux (estructura 1):
  //   C:\AutonoLux\          -> archivos compartidos (raíz)
  //   C:\AutonoLux\Axel\     -> archivos propios de Axel
  //   C:\AutonoLux\Sergio\   (Sergio)  C:\AutonoLux\Daniel\   C:\AutonoLux\Jesus\
  // ----------------------------------------------------------------------
  RUTA_RAIZ = 'C:\AutonoLux\';
  RUTA_AXEL = 'C:\AutonoLux\Axel\';

  // Carpeta (dentro del proyecto de Axel) con los .exe ya compilados.
  RUTA_COMPILADOS = RUTA_AXEL + 'Compilados\';

  // Carpeta con los archivos de datos (.txt) del proyecto.
  RUTA_DATOS = RUTA_AXEL + 'datos\';

  // Carpeta donde emu8086 deja los .exe compilados (respaldo).
  RUTA_EMU = 'C:\emu8086\MyBuild\';

  // Archivos de datos (compartidos y propios), dentro de datos\.
  ARCH_USUARIOS   = RUTA_DATOS + 'usuarios.txt';
  ARCH_REPORTE    = RUTA_DATOS + 'reporte.txt';
  ARCH_BITACORA   = RUTA_DATOS + 'bitacora.txt';
  ARCH_ZONAS      = RUTA_DATOS + 'zonas.txt';
  ARCH_VISITANTES = RUTA_DATOS + 'visitantes.txt';
  ARCH_ACERCA     = RUTA_DATOS + 'acerca.txt';

  // Archivos propios de Axel (entradas/salidas del login; sin uso actual).
  ARCH_LOGIN_IN  = RUTA_AXEL + 'login_in.txt';
  ARCH_LOGIN_OUT = RUTA_AXEL + 'login_out.txt';

  // Logo del proyecto (JPEG). Se busca también junto al ejecutable.
  ARCH_LOGO = RUTA_RAIZ + 'Logo.jpeg';

/// Crea las carpetas C:\AutonoLux, C:\AutonoLux\Axel,
/// C:\AutonoLux\Axel\Compilados y C:\AutonoLux\Axel\datos si no existen.
procedure AsegurarCarpetas;

/// Carga el logo del proyecto en un TImage buscándolo en varias rutas.
procedure CargarLogo(img: TImage);

/// Aplica el tema visual de la aplicación (azul marino y amarillo).
procedure AplicarTema(F: TForm);

/// Valida USUARIO/CLAVE contra C:\AutonoLux\Axel\datos\usuarios.txt (sin ejecutar nada).
/// Devuelve 0 = correcto, 2 = usuario/clave incorrectos, 3 = bloqueado.
function ValidarCredenciales(const Usuario, Clave: string): Integer;

/// Carga (lee) el .exe compilado indicado SIN ejecutarlo. Busca en
/// Compilados, MyBuild o junto al ejecutable. Devuelve True si lo cargó.
function CargarEmu(const NombreExe: string): Boolean;

implementation

uses
  Vcl.Dialogs;

procedure AsegurarCarpetas;
begin
  if not DirectoryExists(RUTA_RAIZ) then
    ForceDirectories(RUTA_RAIZ);
  if not DirectoryExists(RUTA_AXEL) then
    ForceDirectories(RUTA_AXEL);
  if not DirectoryExists(RUTA_COMPILADOS) then
    ForceDirectories(RUTA_COMPILADOS);
  if not DirectoryExists(RUTA_DATOS) then
    ForceDirectories(RUTA_DATOS);
end;

procedure CargarLogo(img: TImage);
var
  Candidatos: array of string;
  i: Integer;
begin
  if img = nil then
    Exit;

  Candidatos := [
    ARCH_LOGO,
    ExtractFilePath(ParamStr(0)) + 'Logo.jpeg',
    ExtractFilePath(ParamStr(0)) + 'logo.jpeg',
    ExtractFilePath(ParamStr(0)) + 'Logo.bmp',
    ExtractFilePath(ParamStr(0)) + 'logo.bmp'
  ];

  for i := Low(Candidatos) to High(Candidatos) do
    if FileExists(Candidatos[i]) then
    begin
      try
        img.Picture.LoadFromFile(Candidatos[i]);
        Exit;
      except
        // No se pudo cargar; prueba la siguiente ruta.
      end;
    end;
end;

procedure AplicarTema(F: TForm);
var
  i: Integer;
begin
  if F = nil then
    Exit;

  // Fondo azul marino y texto base amarillo.
  F.Color      := clNavy;
  F.Font.Color := clYellow;

  for i := 0 to F.ComponentCount - 1 do
  begin
    if F.Components[i] is TLabel then
      TLabel(F.Components[i]).Font.Color := clYellow
    else if F.Components[i] is TEdit then
    begin
      TEdit(F.Components[i]).Color      := clNavy;
      TEdit(F.Components[i]).Font.Color := clYellow;
    end
    else if F.Components[i] is TMemo then
    begin
      TMemo(F.Components[i]).Color      := clNavy;
      TMemo(F.Components[i]).Font.Color := clYellow;
    end
    else if F.Components[i] is TButton then
      TButton(F.Components[i]).Font.Color := clNavy
    else if F.Components[i] is TBitBtn then
      TBitBtn(F.Components[i]).Font.Color := clNavy;
  end;
end;

function ValidarCredenciales(const Usuario, Clave: string): Integer;
var
  Lista: TStringList;
  i, n: Integer;
  Linea, U, C, E: string;
begin
  Result := 2; // por defecto: usuario o clave incorrectos

  if not FileExists(ARCH_USUARIOS) then
    Exit;

  Lista := TStringList.Create;
  try
    Lista.LoadFromFile(ARCH_USUARIOS);
    for i := 0 to Lista.Count - 1 do
    begin
      Linea := Trim(Lista[i]);
      if Linea = '' then
        Continue;

      // Formato de cada línea: USUARIO,CLAVE,ESTADO
      n := Pos(',', Linea);
      if n = 0 then
        Continue;
      U := Trim(Copy(Linea, 1, n - 1));
      Linea := Copy(Linea, n + 1, MaxInt);

      n := Pos(',', Linea);
      if n = 0 then
        Continue;
      C := Trim(Copy(Linea, 1, n - 1));
      E := Trim(Copy(Linea, n + 1, MaxInt));

      if SameText(U, Usuario) then
      begin
        if SameText(E, 'BLOQUEADO') then
        begin
          Result := 3; // acceso bloqueado
          Exit;
        end;
        if C = Clave then
        begin
          Result := 0; // acceso correcto
          Exit;
        end;
      end;
    end;
  finally
    Lista.Free;
  end;
end;

function BuscarEmu(const NombreExe: string): string;
var
  Candidatos: array of string;
  i: Integer;
begin
  Result := '';
  Candidatos := [
    RUTA_COMPILADOS + NombreExe,
    RUTA_COMPILADOS + NombreExe + '_',
    RUTA_EMU + NombreExe,
    RUTA_EMU + NombreExe + '_',
    ExtractFilePath(ParamStr(0)) + NombreExe,
    ExtractFilePath(ParamStr(0)) + NombreExe + '_'
  ];
  for i := Low(Candidatos) to High(Candidatos) do
    if FileExists(Candidatos[i]) then
      Exit(Candidatos[i]);
end;

function CargarEmu(const NombreExe: string): Boolean;
var
  Ruta: string;
  fs: TFileStream;
begin
  Result := False;

  Ruta := BuscarEmu(NombreExe);
  if Ruta = '' then
    Exit;

  // Lee el archivo en memoria (sin ejecutarlo).
  try
    fs := TFileStream.Create(Ruta, fmOpenRead or fmShareDenyNone);
    try
      Result := fs.Size > 0;
    finally
      fs.Free;
    end;
  except
    Result := False;
  end;
end;

end.
