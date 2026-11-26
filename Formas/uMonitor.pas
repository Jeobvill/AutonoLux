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
  Pers, Luz, Inten: array[0..5] of Integer;
  i, ocup, pers_t, sala: Integer;
  V: TStringList;
begin
  { Datos reales: mapa.txt (personas) e iluminacion.txt (luz), que escriben Mapa.asm e Iluminacion.asm }
  LeerPersonasMapa(Pers);
  LeerIluminacion(Luz, Inten);
  ocup := 0;
  pers_t := 0;
  for i := 1 to NUM_ZONAS do
  begin
    sgZonas.Cells[0, i] := IntToStr(i);
    sgZonas.Cells[1, i] := NOMBRES_ZONA[i - 1];
    if Pers[i - 1] > 0 then
      sgZonas.Cells[2, i] := 'Ocupada'
    else
      sgZonas.Cells[2, i] := 'Libre';
    sgZonas.Cells[3, i] := IntToStr(Pers[i - 1]);
    if Luz[i - 1] = 1 then
      sgZonas.Cells[4, i] := 'ON ' + IntToStr(Inten[i - 1]) + '%'
    else
      sgZonas.Cells[4, i] := 'OFF';
    if CalorSeg[0, i - 1] > 0 then
      sgZonas.Cells[5, i] := FormatFloat('0.00', CalorSeg[0, i - 1] / 3600) + ' h-p'
    else
      sgZonas.Cells[5, i] := '-';
    Inc(pers_t, Pers[i - 1]);
    if Pers[i - 1] > 0 then Inc(ocup);
  end;
  lblZonasOcup.Caption := Format('Zonas ocupadas: %d/%d', [ocup, NUM_ZONAS]);
  { coherencia con el Contador: las personas en zonas salen de las que estan en la sala }
  sala := 0;
  V := TStringList.Create;
  try
    if CargarLineas('visitantes.txt', V) and (V.Count > 0) then
      sala := NumeroTras(V[V.Count - 1], 'sala');
  finally
    V.Free;
  end;
  if pers_t > sala then
    lblPersonas.Caption := Format('En zonas: %d  |  En sala: %d  (ejecute Mapa para ajustar)', [pers_t, sala])
  else
    lblPersonas.Caption := Format('En sala: %d  |  En zonas: %d  |  Sin ubicar: %d', [sala, pers_t, sala - pers_t]);
end;

procedure TfrmMonitor.ActualizarAforo;
var
  L: TStringList;
  vis, maxAforo, pct, temp: Integer;
begin
  L := TStringList.Create;
  try
    maxAforo := ConfigEntero(2);   { Opcion 2 de config.txt }
    if maxAforo <= 0 then maxAforo := AFORO_DEFAULT;

    { visitantes.txt (Contador.asm): ultima linea, campo "sala" = personas dentro }
    vis := 0;
    if CargarLineas('visitantes.txt', L) and (L.Count > 0) then
      vis := NumeroTras(L[L.Count - 1], 'sala');

    { temperatura.txt solo existe si el Thermometer la escribio; si no, sin dato }
    temp := -1;
    if CargarLineas('temperatura.txt', L) and (L.Count > 0) then
      temp := ExtraerEntero(L[L.Count - 1], -1);

    pct := Round(100 * vis / maxAforo);
    lblAforo.Caption := Format('Aforo: %d %%', [pct]);

    if pct < 50 then
      shSemaforo.Brush.Color := clLime
    else if pct < 80 then
      shSemaforo.Brush.Color := clYellow
    else
      shSemaforo.Brush.Color := clRed;

    if temp < 0 then
    begin
      lblTemp.Caption := 'Temperatura: sin dato';
      lblEstadoTemp.Caption := '---';
      lblEstadoTemp.Font.Color := clGray;
    end
    else
    begin
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
