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
    procedure FormCreate(Sender: TObject);
    procedure btnVolverClick(Sender: TObject);
    procedure btnRecalcularClick(Sender: TObject);
    procedure btnVerEmuClick(Sender: TObject);
  private
    Tmr: TTimer;
    procedure Refrescar;
    procedure TmrTick(Sender: TObject);
  end;

var
  frmConsumo: TfrmConsumo;

implementation

{$R *.dfm}

uses uComun;

const
  NOMBRES: array[0..5] of string = ('Recepcion', 'Lectura Silenciosa',
    'Sala de Computo', 'Hemeroteca', 'Estantes A-F', 'Sala de Grupos');

procedure TfrmConsumo.FormCreate(Sender: TObject);
begin
  sgConsumo.ColCount := 5;
  sgConsumo.RowCount := 8;
  sgConsumo.FixedRows := 1;
  sgConsumo.DefaultRowHeight := 30;
  sgConsumo.Height := 8 * 31 + 2;
  sgConsumo.Cells[0, 0] := 'Zona';
  sgConsumo.Cells[1, 0] := 'L'#225'mparas';
  sgConsumo.Cells[2, 0] := 'Horas enc.';
  sgConsumo.Cells[3, 0] := 'kWh';
  sgConsumo.Cells[4, 0] := 'Costo';
  btnRecalcular.OnClick := btnRecalcularClick;
  btnVerEmu.OnClick := btnVerEmuClick;
  btnVolver.OnClick := btnVolverClick;
  Tmr := TTimer.Create(Self);
  Tmr.Interval := 1000;
  Tmr.OnTimer := TmrTick;
  Refrescar;
end;

procedure TfrmConsumo.TmrTick(Sender: TObject);
begin
  if Visible then Refrescar;
end;

{ Todo sale de lo que Iluminacion.asm escribio en iluminacion.txt (muestreado por uPrincipal) y de
  config.txt (watts por lampara y tarifa). Si aun no se ha emulado nada, se muestra en ceros. }
procedure TfrmConsumo.Refrescar;
var
  z: Integer;
  kwh, kwhTot, costoTot, tarifa, kwhSin: Double;
  W: Integer;
begin
  W := ConfigEntero(3);
  tarifa := ConfigTarifa;
  kwhTot := 0;
  for z := 0 to 5 do
  begin
    kwh := WhZona[z] / 1000;
    kwhTot := kwhTot + kwh;
    sgConsumo.Cells[0, z + 1] := IntToStr(z + 1) + ' ' + NOMBRES[z];
    sgConsumo.Cells[1, z + 1] := IntToStr(LAMPARAS_ZONA);
    sgConsumo.Cells[2, z + 1] := FormatFloat('0.00', SegEnc[z] / 3600) + ' h';
    sgConsumo.Cells[3, z + 1] := FormatFloat('0.0000', kwh);
    sgConsumo.Cells[4, z + 1] := '$ ' + FormatFloat('0.00', kwh * tarifa);
  end;
  costoTot := kwhTot * tarifa;
  sgConsumo.Cells[0, 7] := 'TOTAL';
  sgConsumo.Cells[1, 7] := IntToStr(6 * LAMPARAS_ZONA);
  sgConsumo.Cells[2, 7] := '';
  sgConsumo.Cells[3, 7] := FormatFloat('0.0000', kwhTot);
  sgConsumo.Cells[4, 7] := '$ ' + FormatFloat('0.00', costoTot);

  lblTotal.Caption := Format('TOTAL: %s kWh   $ %s   (L'#225'mpara %d W, tarifa $%s/kWh)',
    [FormatFloat('0.0000', kwhTot), FormatFloat('0.00', costoTot), W, FormatFloat('0.00', tarifa)]);
  lblPotencia.Caption := Format('Potencia encendida ahora: %s W', [FormatFloat('0.0', PotenciaAhora)]);

  { sin automatizar = las 6 zonas encendidas todo el tiempo muestreado }
  kwhSin := 6 * LAMPARAS_ZONA * W * (SegTotal / 3600) / 1000;
  if kwhSin > 0 then
    lblAhorro.Caption := Format('AHORRO: %s %%   (sin automatizar: %s kWh)',
      [FormatFloat('0.0', 100 * (1 - kwhTot / kwhSin)), FormatFloat('0.0000', kwhSin)])
  else
    lblAhorro.Caption := 'AHORRO: sin datos (emule Iluminaci'#243'n para generar iluminacion.txt)';
end;

procedure TfrmConsumo.btnRecalcularClick(Sender: TObject);
begin
  Refrescar;
end;

procedure TfrmConsumo.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Consumo.exe');
end;

procedure TfrmConsumo.btnVolverClick(Sender: TObject);
begin
  Close;
end;

end.
