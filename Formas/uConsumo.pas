unit uConsumo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids;

type
  TfrmConsumo = class(TForm)
    sgConsumo: TStringGrid;
    lblTotal: TLabel;
    lblPotencia: TLabel;
    lblAhorro: TLabel;
    btnRecalcular: TPanel;
    btnVerEmu: TPanel;
    btnVolver: TPanel;
    procedure btnVolverClick(Sender: TObject);
  end;

var
  frmConsumo: TfrmConsumo;

implementation

{$R *.dfm}

procedure TfrmConsumo.btnVolverClick(Sender: TObject);
begin
  close;
end;

end.
