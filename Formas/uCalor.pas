unit uCalor;
{ 5.8 - DANIEL - Mapa de calor }

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, StdCtrls, Buttons, Gauges;

type
  TfrmCalor = class(TForm)
    pnlPrincipal: TPanel;
    sgCalor: TStringGrid;
    rgPeriodo: TRadioGroup;
    ggPresion: TGauge;
    lblMasConc: TLabel;
    btnVerEmu: TBitBtn;
    btnVolver: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rgPeriodoClick(Sender: TObject);
    procedure sgCalorDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnVerEmuClick(Sender: TObject);
    procedure btnVolverClick(Sender: TObject);
  private
    FPct: array[1..6] of Integer;
    procedure CargarPeriodo;
  end;

var
  frmCalor: TfrmCalor;

implementation

{$R *.dfm}

uses uComun;

const
  { Linea de inicio de cada periodo dentro de zonas.txt: HOY, SEMANA, MES }
  OFFSETS: array[0..2] of Integer = (0, 1872, 3744);

type
  TRegistro = record
    Zona: string;
    Personas: Integer;
    Tiempo: string;
    Pct: Integer;
  end;

procedure TfrmCalor.FormCreate(Sender: TObject);
const
  Titulos: array[0..3] of string = ('Zona', '%', 'Barra', 'Tiempo');
  Anchos: array[0..3] of Integer = (150, 60, 220, 80);
var
  c: Integer;
begin
  for c := 0 to 3 do
  begin
    sgCalor.Cells[c, 0] := Titulos[c];
    sgCalor.ColWidths[c] := Anchos[c];
  end;
end;

procedure TfrmCalor.FormShow(Sender: TObject);
begin
  CargarPeriodo;
end;

procedure TfrmCalor.rgPeriodoClick(Sender: TObject);
begin
  CargarPeriodo;
end;

{ Lee 6 lineas de zonas.txt desde el offset del periodo, calcula el % de cada
  zona (personas de la zona / personas totales), ordena de mayor a menor }
procedure TfrmCalor.CargarPeriodo;
var
  L: TStringList;
  Reg: array[0..5] of TRegistro;
  T: TRegistro;
  i, j, off, total: Integer;
begin
  L := TStringList.Create;
  try
    CargarLineas('zonas.txt', L);   { formato: Zona;Estado;Personas;Luz;Tiempo }
    off := OFFSETS[rgPeriodo.ItemIndex];
    total := 0;
    for i := 0 to 5 do
    begin
      if off + i < L.Count then
      begin
        Reg[i].Zona := Campo(L[off + i], 0);
        Reg[i].Personas := StrToIntDef(Campo(L[off + i], 2), 0);
        Reg[i].Tiempo := Campo(L[off + i], 4);
      end
      else
      begin
        Reg[i].Zona := 'Zona ' + IntToStr(i + 1);
        Reg[i].Personas := 0;
        Reg[i].Tiempo := '-';
      end;
      Inc(total, Reg[i].Personas);
    end;

    for i := 0 to 5 do
      if total > 0 then
        Reg[i].Pct := Round(100 * Reg[i].Personas / total)
      else
        Reg[i].Pct := 0;

    { ordenar descendente por porcentaje (burbuja) }
    for i := 0 to 4 do
      for j := 0 to 4 - i do
        if Reg[j].Pct < Reg[j + 1].Pct then
        begin
          T := Reg[j];
          Reg[j] := Reg[j + 1];
          Reg[j + 1] := T;
        end;

    for i := 0 to 5 do
    begin
      FPct[i + 1] := Reg[i].Pct;
      sgCalor.Cells[0, i + 1] := Reg[i].Zona;
      sgCalor.Cells[1, i + 1] := IntToStr(Reg[i].Pct) + ' %';
      sgCalor.Cells[2, i + 1] := '';        { la barra se dibuja en OnDrawCell }
      sgCalor.Cells[3, i + 1] := Reg[i].Tiempo;
    end;
    sgCalor.Invalidate;

    ggPresion.Progress := Reg[0].Pct;
    if total > 0 then
      lblMasConc.Caption := 'M' + #225 + 's concurrida: ' + Reg[0].Zona
    else
      lblMasConc.Caption := 'M' + #225 + 's concurrida: (sin datos)';
  finally
    L.Free;
  end;
end;

{ Dibuja la barra proporcional al % en la columna 2 }
procedure TfrmCalor.sgCalorDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  R: TRect;
  w: Integer;
begin
  if (ACol = 2) and (ARow >= 1) and (ARow <= 6) then
  begin
    w := (Rect.Right - Rect.Left - 4) * FPct[ARow] div 100;
    R.Left := Rect.Left + 2;
    R.Top := Rect.Top + 4;
    R.Right := Rect.Left + 2 + w;
    R.Bottom := Rect.Bottom - 4;
    if FPct[ARow] >= 40 then
      sgCalor.Canvas.Brush.Color := clRed
    else if FPct[ARow] >= 20 then
      sgCalor.Canvas.Brush.Color := $0000A5FF   { naranja }
    else
      sgCalor.Canvas.Brush.Color := clLime;
    sgCalor.Canvas.FillRect(R);
  end;
end;

procedure TfrmCalor.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Calor.exe');
end;

procedure TfrmCalor.btnVolverClick(Sender: TObject);
begin
  Close;
end;

end.
