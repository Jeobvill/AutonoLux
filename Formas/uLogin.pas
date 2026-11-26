unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Imaging.jpeg;

type
  TfrmLogin = class(TForm)
    imgLogo: TImage;
    lblUsuario: TLabel;
    edUsuario: TEdit;
    lblClave: TLabel;
    edClave: TEdit;
    lblIntentos: TLabel;
    btnIngresar: TBitBtn;
    btnSalir: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnIngresarClick(Sender: TObject);
  private
    FIntentos: Integer;
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

uses
  uAxelComun;

{$R *.dfm}

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  FIntentos := 3;
  lblIntentos.Caption := 'Intentos restantes: 3';
  AplicarTema(Self);
  AsegurarCarpetas;
  CargarLogo(imgLogo);
end;

procedure TfrmLogin.btnIngresarClick(Sender: TObject);
var
  Usuario, Clave: string;
  Codigo: Integer;
begin
  Usuario := Trim(edUsuario.Text);
  Clave   := Trim(edClave.Text);

  // 1) Validar campos vacios.
  if (Usuario = '') or (Clave = '') then
  begin
    ShowMessage('Debe escribir un usuario y una clave.');
    edUsuario.SetFocus;
    Exit;
  end;

  // 2) Carga (sin ejecutar) el programa compilado de Login.
  CargarEmu('Login.exe');

  // 3) Valida las credenciales contra usuarios.txt.
  Codigo := ValidarCredenciales(Usuario, Clave);

  // 4) Evaluar el resultado.
  case Codigo of
    0:
      ModalResult := mrOk;          // Acceso correcto.
    2:
      begin
        Dec(FIntentos);
        lblIntentos.Caption := 'Intentos restantes: ' + IntToStr(FIntentos);
        if FIntentos <= 0 then
        begin
          ShowMessage('Usuario o clave incorrectos.' + sLineBreak +
            'Ha agotado los intentos permitidos.');
          Application.Terminate;
        end
        else
        begin
          ShowMessage('Usuario o clave incorrectos.');
          edClave.Clear;
          edClave.SetFocus;
        end;
      end;
    3:
      begin
        ShowMessage('Acceso bloqueado.');
        Application.Terminate;
      end;
  else
    ShowMessage('No se pudo validar el acceso (código ' +
      IntToStr(Codigo) + ').');
  end;
end;

end.
