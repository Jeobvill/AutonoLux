unit uMonitor;
{ 5.7 - DANIEL - Monitor de zonas en tiempo real }

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, StdCtrls, Buttons;

type
  TfrmMonitor = class(TForm)
    pnlPrincipal: TPanel;
    sgZonas: TStringGrid;
    shSemaforo: TShape;
    lblZonasOcup: TLabel;
    lblPersonas: TLabel;
    lblAforo: TLabel;
    lblTemp: TLabel;
    lblEstadoTemp: TLabel;
    tmrRefresh: TTimer;
    btnMapa: TBitBtn;
    btnVerEmu: TBitBtn;
    btnVolver: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure btnMapaClick(Sender: TObject);
    procedure btnVerEmuClick(Sender: TObject);
    procedure btnVolverClick(Sender: TObject);
  private
    procedure ActualizarZonas;
    procedure ActualizarAforo;
  end;

var
  frmMonitor: TfrmMonitor;

implementation

{$R *.dfm}

uses uComun, uMapa;

const
  NUM_ZONAS = 6;
  AFORO_DEFAULT = 60;
  TEMP_ALERTA = 35;

procedure TfrmMonitor.FormCreate(Sender: TObject);
const
  Titulos: array[0..5] of string = ('#', 'Zona', 'Estado', 'Personas', 'Luz', 'Tiempo');
  Anchos: array[0..5] of Integer = (36, 120, 100, 90, 70, 90);
var
  c: Integer;
begin
  for c := 0 to 5 do
  begin
    sgZonas.Cells[c, 0] := Titulos[c];
    sgZonas.ColWidths[c] := Anchos[c];
  end;
end;

procedure TfrmMonitor.FormShow(Sender: TObject);
begin
  tmrRefreshTimer(nil);
end;

{ Cada 500 ms: zonas -> aforo/semaforo -> temperatura }
procedure TfrmMonitor.tmrRefreshTimer(Sender: TObject);
begin
  ActualizarZonas;
  ActualizarAforo;
end;

procedure TfrmMonitor.ActualizarZonas;
var
  L: TStringList;
  i, c, ocup, pers, p: Integer;
begin
  L := TStringList.Create;
  try
    CargarLineas('zonas.txt', L);   { formato: Zona;Estado;Personas;Luz;Tiempo }
    ocup := 0;
    pers := 0;
    for i := 1 to NUM_ZONAS do
    begin
      sgZonas.Cells[0, i] := IntToStr(i);
      for c := 1 to 5 do
        if i - 1 < L.Count then
          sgZonas.Cells[c, i] := Campo(L[i - 1], c - 1)
        else
          sgZonas.Cells[c, i] := '';
      p := StrToIntDef(sgZonas.Cells[3, i], 0);
      Inc(pers, p);
      if p > 0 then Inc(ocup);
    end;
    lblZonasOcup.Caption := Format('Zonas ocupadas: %d/%d', [ocup, NUM_ZONAS]);
    lblPersonas.Caption := Format('Personas en zonas: %d', [pers]);
  finally
    L.Free;
  end;
end;

procedure TfrmMonitor.ActualizarAforo;
var
  L: TStringList;
  vis, maxAforo, pct, temp: Integer;
begin
  L := TStringList.Create;
  try
    { config.txt: linea 1 = aforo maximo, linea 2 = temperatura (opcional) }
    maxAforo := AFORO_DEFAULT;
    temp := 25;
    if CargarLineas('config.txt', L) then
    begin
      if L.Count > 0 then maxAforo := ExtraerEntero(L[0], AFORO_DEFAULT);
      if L.Count > 1 then temp := ExtraerEntero(L[1], 25);
    end;
    if maxAforo <= 0 then maxAforo := AFORO_DEFAULT;

    { visitantes.txt: ultima linea = visitantes actuales (ej. 14:30;17) }
    vis := 0;
    if CargarLineas('visitantes.txt', L) and (L.Count > 0) then
      vis := ExtraerEntero(L[L.Count - 1], 0);

    pct := Round(100 * vis / maxAforo);
    lblAforo.Caption := Format('Aforo: %d %%', [pct]);

    if pct < 50 then
      shSemaforo.Brush.Color := clLime
    else if pct < 80 then
      shSemaforo.Brush.Color := clYellow
    else
      shSemaforo.Brush.Color := clRed;

    lblTemp.Caption := 'Temperatura: ' + IntToStr(temp) + ' ' + #176 + 'C';
    if temp >= TEMP_ALERTA then
    begin
      lblEstadoTemp.Caption := 'ALERTA';
      lblEstadoTemp.Font.Color := clRed;
    end
    else
    begin
      lblEstadoTemp.Caption := 'NORMAL';
      lblEstadoTemp.Font.Color := clGreen;
    end;
  finally
    L.Free;
  end;
end;

{ Reemplaza el CALL JO_Mapa del ASM: el mapa se abre desde Delphi }
procedure TfrmMonitor.btnMapaClick(Sender: TObject);
begin
  frmMapa.Show;
end;

procedure TfrmMonitor.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Monitor.exe');
end;

procedure TfrmMonitor.btnVolverClick(Sender: TObject);
begin
  Close;
end;

end.
