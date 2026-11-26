unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus, uConsumo, uConfiguracion, uIluminacion, uContador, uMonitor,
  uBitacora, uMapa, uCalor, uLogin, uReporte, uAcerca;

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
    procedure lblSesionDblClick(Sender: TObject);
    procedure miAcercaDeClick(Sender: TObject);
  private
    FUsuario: string;
    TicksGuardado: Integer;
    FMenusListos: Boolean;
    procedure AgregarMenus;
    procedure miCalcClick(Sender: TObject);
    procedure miVideoClick(Sender: TObject);
    procedure PedirLogin;
    procedure RevisarLogin;
    procedure HabilitarMenu(Activo: Boolean);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses uComun, uCalcSergio, uCalcDaniel, uCalcJesus, uCalcAxel, uVideo;

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

{ El acceso lo valida la pantalla Login contra usuarios.txt (el mismo que crea Login.asm) }
procedure TfrmPrincipal.PedirLogin;
begin
  FUsuario := '';
  lblSesion.Caption := 'Sesion: sin iniciar';
  HabilitarMenu(False);
  frmLogin.Preparar;
  if frmLogin.ShowModal = mrOk then
  begin
    FUsuario := frmLogin.Usuario;
    UsuarioActual := FUsuario;
    lblSesion.Caption := 'Sesion: ' + FUsuario;
    HabilitarMenu(True);
  end
  else
    Close;
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

{ Menu Calculos (formularios del coprocesador) y Ayuda > Trailer y entrevista }
procedure TfrmPrincipal.AgregarMenus;
const
  NOMBRES: array[0..3] of string = ('Ahorro energ' + #233 + 'tico (Sergio)', 'Margen t' + #233 + 'rmico (Daniel)',
    'Dispersi' + #243 + 'n y potencia (Jes' + #250 + 's)', 'Permanencia promedio (Axel)');
var
  Calc, Item: TMenuItem;
  i: Integer;
begin
  if FMenusListos then Exit;
  FMenusListos := True;
  Calc := TMenuItem.Create(mmPrincipal);
  Calc.Caption := 'C' + #225 + 'lculos';
  for i := 0 to 3 do
  begin
    Item := TMenuItem.Create(mmPrincipal);
    Item.Caption := NOMBRES[i];
    Item.Tag := i;
    Item.OnClick := miCalcClick;
    Calc.Add(Item);
  end;
  mmPrincipal.Items.Insert(miAyuda.MenuIndex, Calc);
  Item := TMenuItem.Create(mmPrincipal);
  Item.Caption := 'Trailer y entrevista';
  Item.OnClick := miVideoClick;
  miAyuda.Add(Item);
end;

procedure TfrmPrincipal.miCalcClick(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0: MostrarCalcSergio;
    1: MostrarCalcDaniel;
    2: MostrarCalcJesus;
    3: MostrarCalcAxel;
  end;
end;

procedure TfrmPrincipal.miVideoClick(Sender: TObject);
begin
  MostrarVideo;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  AgregarMenus;
  CrearArbolCarpetas;
  CargarConsumo;
  CargarCalor;
  PedirLogin;
end;

procedure TfrmPrincipal.tmrHoraTimer(Sender: TObject);
begin
  { cada segundo se muestrea iluminacion.txt para el consumo real; se guarda cada 10 s }
  MuestrearConsumo(tmrHora.Interval / 1000);
  MuestrearCalor(tmrHora.Interval / 1000);
  RegistrarEventos;
  Inc(TicksGuardado);
  if TicksGuardado >= 10 then
  begin
    TicksGuardado := 0;
    GuardarConsumo;
    GuardarCalor;
  end;
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
  frmReporte.ShowModal;
end;

procedure TfrmPrincipal.btn8Click(Sender: TObject);
begin
  frmBitacora.Show;
end;

procedure TfrmPrincipal.btn9Click(Sender: TObject);
begin
  frmAcerca.ShowModal;
end;

procedure TfrmPrincipal.btn0Click(Sender: TObject);
begin
  PedirLogin;                    { cerrar sesion = volver a pedir acceso }
end;

{ Doble clic en "Sesion": entra en modo DEMO si Login no se esta emulando }
procedure TfrmPrincipal.lblSesionDblClick(Sender: TObject);
begin
  if FUsuario <> '' then Exit;
  FUsuario := 'DEMO';
  lblSesion.Caption := 'Sesion: DEMO';
  HabilitarMenu(True);
end;

procedure TfrmPrincipal.miAcercaDeClick(Sender: TObject);
begin
  frmAcerca.ShowModal;
end;

procedure TfrmPrincipal.miSalirClick(Sender: TObject);
begin
  Close;
end;

end.
