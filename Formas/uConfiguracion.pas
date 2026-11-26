unit uConfiguracion;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TfrmConfiguracion = class(TForm)
    lblAyuda: TLabel;
    lvOpciones: TListView;
    lblNuevo: TLabel;
    edNuevoValor: TEdit;
    btnGuardar: TPanel;
    btnCancelar: TPanel;
    btnFabrica: TPanel;
    btnVerEmu: TPanel;
  end;

var
  frmConfiguracion: TfrmConfiguracion;

implementation

{$R *.dfm}

end.
