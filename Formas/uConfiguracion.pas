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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvOpcionesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnFabricaClick(Sender: TObject);
    procedure btnVerEmuClick(Sender: TObject);
  private
    procedure Cargar;
  end;

var
  frmConfiguracion: TfrmConfiguracion;

implementation

{$R *.dfm}

uses uComun;

const
  TITULOS: array[1..6] of string = ('Tiempo de espera para apagar luz (min)',
    'Aforo maximo de la biblioteca (personas)', 'Potencia por lampara (W)',
    'Tarifa electrica ($/kWh)', 'Horario de operacion (HH:MM-HH:MM)',
    'Sensibilidad del sensor (Baja/Media/Alta)');

procedure TfrmConfiguracion.FormCreate(Sender: TObject);
begin
  lvOpciones.OnSelectItem := lvOpcionesSelectItem;
  btnGuardar.OnClick := btnGuardarClick;
  btnCancelar.OnClick := btnCancelarClick;
  btnFabrica.OnClick := btnFabricaClick;
  btnVerEmu.OnClick := btnVerEmuClick;
end;

procedure TfrmConfiguracion.FormShow(Sender: TObject);
begin
  Cargar;
end;

{ Lee config.txt (el mismo archivo que escribe Configuracion.asm) }
procedure TfrmConfiguracion.Cargar;
var
  i: Integer;
  It: TListItem;
begin
  lvOpciones.Items.BeginUpdate;
  try
    lvOpciones.Items.Clear;
    for i := 1 to 6 do
    begin
      It := lvOpciones.Items.Add;
      It.Caption := IntToStr(i) + '. ' + TITULOS[i];
      It.SubItems.Add(ConfigValor(i));
    end;
  finally
    lvOpciones.Items.EndUpdate;
  end;
  edNuevoValor.Text := '';
  lblAyuda.Caption := 'Seleccione una opci'#243'n y escriba el nuevo valor';
end;

procedure TfrmConfiguracion.lvOpcionesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and (Item <> nil) then
    edNuevoValor.Text := Item.SubItems[0];
end;

function Valido(N: Integer; const V: string): Boolean;
begin
  case N of
    1, 2, 3: Result := (StrToIntDef(V, 0) > 0) and (StrToIntDef(V, 0) < 1000);
    4: Result := (StrToFloatDef(StringReplace(V, '.', FormatSettings.DecimalSeparator, []), -1) > 0);
    5: Result := (Length(V) = 11) and (V[3] = ':') and (V[6] = '-') and (V[9] = ':');
    6: Result := SameText(V, 'Baja') or SameText(V, 'Media') or SameText(V, 'Alta');
  else Result := False;
  end;
end;

procedure TfrmConfiguracion.btnGuardarClick(Sender: TObject);
var
  i: Integer;
  V: array[0..5] of string;
begin
  if lvOpciones.Selected = nil then
  begin
    ShowMessage('Seleccione primero una opci'#243'n.');
    Exit;
  end;
  i := lvOpciones.Selected.Index + 1;
  if not Valido(i, Trim(edNuevoValor.Text)) then
  begin
    ShowMessage('Valor no v'#225'lido para: ' + TITULOS[i]);
    Exit;
  end;
  for i := 1 to 6 do V[i - 1] := ConfigValor(i);
  V[lvOpciones.Selected.Index] := Trim(edNuevoValor.Text);
  ConfigGuardar(V);
  Cargar;
  ShowMessage('Configuraci'#243'n guardada en config.txt');
end;

procedure TfrmConfiguracion.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConfiguracion.btnFabricaClick(Sender: TObject);
var
  i: Integer;
  V: array[0..5] of string;
begin
  if MessageDlg('Restaurar los valores de f'#225'brica?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  for i := 1 to 6 do V[i - 1] := ConfigDefecto(i);
  ConfigGuardar(V);
  Cargar;
end;

procedure TfrmConfiguracion.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Configuracion.exe');
end;

end.
