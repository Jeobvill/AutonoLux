unit uMapa;
{ Pantalla Mapa (Obed): lee mapa.txt escrito por Mapa.exe y colorea las 6 zonas }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmMapa = class(TForm)
    lblTitulo: TLabel;
    pnlZona1: TPanel;
    pnlZona2: TPanel;
    pnlZona3: TPanel;
    pnlZona4: TPanel;
    pnlZona5: TPanel;
    pnlZona6: TPanel;
    lblDetalle: TLabel;
    lblResumen: TLabel;
    lblDigito: TLabel;
    btnActualizar: TPanel;
    btnVerEmu: TPanel;
    btnVolver: TPanel;
    tmrRefresh: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure pnlZonaClick(Sender: TObject);
    procedure btnActualizarClick(Sender: TObject);
    procedure btnVerEmuClick(Sender: TObject);
    procedure btnVolverClick(Sender: TObject);
  private
    Zonas: array[0..5] of TPanel;
    Personas: array[0..5] of Integer;
    ZonaElegida: Integer;
    procedure LeerMapa;
    procedure PintarZonas;
    procedure MostrarDetalle;
  end;

var
  frmMapa: TfrmMapa;

implementation

{$R *.dfm}

uses uComun;

const
  NOMBRES: array[0..5] of string = ('Recepcion', 'Lectura Silenciosa',
    'Sala de Computo', 'Hemeroteca', 'Estantes A-F', 'Sala de Grupos');

procedure TfrmMapa.FormCreate(Sender: TObject);
begin
  Zonas[0] := pnlZona1;
  Zonas[1] := pnlZona2;
  Zonas[2] := pnlZona3;
  Zonas[3] := pnlZona4;
  Zonas[4] := pnlZona5;
  Zonas[5] := pnlZona6;
  ZonaElegida := -1;
end;

procedure TfrmMapa.FormShow(Sender: TObject);
begin
  tmrRefreshTimer(nil);
end;

procedure TfrmMapa.tmrRefreshTimer(Sender: TObject);
begin
  if (Sender <> nil) and not Visible then Exit;   { solo trabaja con la pantalla abierta }
  LeerMapa;
  PintarZonas;
  MostrarDetalle;
end;

{ Cada zona tiene [#] u [ ] y un numero de personas en su renglon de mapa.txt }
procedure TfrmMapa.LeerMapa;
begin
  LeerPersonasMapa(Personas);
end;

procedure TfrmMapa.PintarZonas;
var
  i, ocupadas, total: Integer;
begin
  ocupadas := 0;
  total := 0;
  for i := 0 to 5 do
  begin
    Zonas[i].Caption := IntToStr(i + 1) + ' ' + NOMBRES[i] + #13#10 +
      IntToStr(Personas[i]) + ' personas';
    if Personas[i] > 0 then
    begin
      Zonas[i].Color := clLime;
      Zonas[i].Font.Color := clBlack;
      Inc(ocupadas);
      Inc(total, Personas[i]);
    end
    else
    begin
      Zonas[i].Color := 10569485;
      Zonas[i].Font.Color := 55039;
    end;
  end;
  lblResumen.Caption := Format('Zonas ocupadas: %d/6    Personas: %d',
    [ocupadas, total]);
end;

procedure TfrmMapa.MostrarDetalle;
begin
  if ZonaElegida < 0 then
  begin
    lblDetalle.Caption := 'Detalle: seleccione una zona';
    lblDigito.Caption := 'Dot Matrix: -';
    Exit;
  end;
  if Personas[ZonaElegida] > 0 then
  begin
    lblDetalle.Caption := Format('Detalle: zona %d %s   personas: %d   luz: ON',
      [ZonaElegida + 1, NOMBRES[ZonaElegida], Personas[ZonaElegida]]);
    lblDigito.Caption := 'Dot Matrix: muestra el numero ' + IntToStr(ZonaElegida + 1);
  end
  else
  begin
    lblDetalle.Caption := Format('Detalle: zona %d %s   personas: 0   luz: OFF',
      [ZonaElegida + 1, NOMBRES[ZonaElegida]]);
    lblDigito.Caption := 'Dot Matrix: apagado para esta zona';
  end;
end;

procedure TfrmMapa.pnlZonaClick(Sender: TObject);
begin
  ZonaElegida := (Sender as TPanel).Tag;
  MostrarDetalle;
end;

procedure TfrmMapa.btnActualizarClick(Sender: TObject);
begin
  tmrRefreshTimer(nil);
end;

procedure TfrmMapa.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Mapa.exe');
end;

procedure TfrmMapa.btnVolverClick(Sender: TObject);
begin
  Close;
end;

end.
