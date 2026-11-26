unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus, uConsumo, uConfiguracion, uIluminacion, uContador;

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
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn7Click(Sender: TObject);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

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

end.
