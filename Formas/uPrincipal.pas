unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus, uConsumo, uConfiguracion, uIluminacion, uContador, uMonitor,
  uBitacora, uMapa, uCalor;

type
  TfrmPrincipal = class(TForm)
    imgLogo: TImage;
    lblTitulo: TLabel;
    lblSesion: TLabel;
    btn1: TPanel;
    btn2: TPanel;
    btn3: TPanel;
    btn4: TPanel;
    btn5: TPanel;
    btn6: TPanel;
    btn7: TPanel;
    btn8: TPanel;
    btn9: TPanel;
    btn0: TPanel;
    sbEstado: TStatusBar;
    tmrHora: TTimer;
    mmPrincipal: TMainMenu;
    miArchivo: TMenuItem;
    miSalir: TMenuItem;
    miAyuda: TMenuItem;
    miAcercaDe: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure tmrHoraTimer(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
    procedure btn0Click(Sender: TObject);
    procedure miSalirClick(Sender: TObject);
  private
    FUsuario: string;
    procedure PedirLogin;
    procedure RevisarLogin;
    procedure HabilitarMenu(Activo: Boolean);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses uComun;

procedure TfrmPrincipal.btn2Click(Sender: TObject);
begin
  frmIluminacion.Show;
end;

procedure TfrmPrincipal.btn3Click(Sender: TObject);
begin
  frmContador.Show;
end;

procedure TfrmPrincipal.btn5Click(Sender: TObject);
begin
    try
    frmConsumo.Show;
  except
    ShowMessage('No se pudo abrir Consumo');
    end;
end;

procedure TfrmPrincipal.btn7Click(Sender: TObject);
begin
    try
    frmConfiguracion.Show;
  except
    ShowMessage('No se pudo abrir Configuración');
    end;
end;

{ ---- Sesion: Delphi llama a Login.exe y Emu devuelve OK,USUARIO / ESC / BLOQUEADO ---- }

procedure TfrmPrincipal.HabilitarMenu(Activo: Boolean);
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if (Components[i] is TPanel) and (Copy(Components[i].Name, 1, 3) = 'btn') then
      TPanel(Components[i]).Enabled := Activo;
end;

procedure TfrmPrincipal.PedirLogin;
begin
  FUsuario := '';
  lblSesion.Caption := 'Sesion: esperando acceso...';
  HabilitarMenu(False);
  DeleteFile(RutaArchivo('login_out.txt'));   { evita leer un acceso viejo }
  if (BuscarEmu('Login.exe') = '') or not LanzarEmu('Login.exe') then
  begin
    { sin Login.exe compilado el sistema abre en modo demostracion }
    FUsuario := 'DEMO';
    lblSesion.Caption := 'Sesion: DEMO (sin Login.exe)';
    HabilitarMenu(True);
  end;
end;

{ Cada segundo: reloj y, mientras no hay sesion, lectura de login_out.txt }
procedure TfrmPrincipal.RevisarLogin;
var
  L: TStringList;
  R: string;
begin
  if FUsuario <> '' then Exit;
  L := TStringList.Create;
  try
    if not CargarLineas('login_out.txt', L) or (L.Count = 0) then Exit;
    R := Trim(L[0]);
  finally
    L.Free;
  end;
  if Copy(R, 1, 3) = 'OK,' then
  begin
    FUsuario := Trim(Copy(R, 4, 20));
    lblSesion.Caption := 'Sesion: ' + FUsuario;
    HabilitarMenu(True);
  end
  else if R = 'BLOQUEADO' then
  begin
    ShowMessage('Acceso bloqueado: 3 intentos fallidos.');
    Close;
  end
  else if R = 'ESC' then
    Close;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  CrearArbolCarpetas;
  PedirLogin;
end;

procedure TfrmPrincipal.tmrHoraTimer(Sender: TObject);
begin
  if sbEstado.Panels.Count > 1 then
  begin
    sbEstado.Panels[0].Text := DateToStr(Date);
    sbEstado.Panels[1].Text := TimeToStr(Time);
  end;
  RevisarLogin;
end;

{ ---- Menu: cada boton abre la pantalla Delphi o llama al .exe de Emu ---- }

procedure TfrmPrincipal.btn1Click(Sender: TObject);
begin
  frmMonitor.Show;
end;

procedure TfrmPrincipal.btn4Click(Sender: TObject);
begin
  frmCalor.Show;
end;

procedure TfrmPrincipal.btn6Click(Sender: TObject);
begin
  LanzarEmu('Reporte.exe');      { uReporte (Axel) todavia no existe }
end;

procedure TfrmPrincipal.btn8Click(Sender: TObject);
begin
  frmBitacora.Show;
end;

procedure TfrmPrincipal.btn9Click(Sender: TObject);
begin
  LanzarEmu('Acerca.exe');       { uAcerca (Axel) todavia no existe }
end;

procedure TfrmPrincipal.btn0Click(Sender: TObject);
begin
  PedirLogin;                    { cerrar sesion = volver a pedir acceso }
end;

procedure TfrmPrincipal.miSalirClick(Sender: TObject);
begin
  Close;
end;

end.
