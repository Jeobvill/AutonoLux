unit uIluminacion;
{ Pantalla Iluminacion (Obed): lee iluminacion.txt escrito por Iluminacion.exe }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids;

type
  TfrmIluminacion = class(TForm)
    lblTitulo: TLabel;
    sgLuces: TStringGrid;
    lblModo: TLabel;
    lblResumen: TLabel;
    lblUltimo: TLabel;
    btnActualizar: TPanel;
    btnVerEmu: TPanel;
    btnVolver: TPanel;
    tmrRefresh: TTimer;
    procedure FormShow(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure btnActualizarClick(Sender: TObject);
    procedure btnVerEmuClick(Sender: TObject);
    procedure btnVolverClick(Sender: TObject);
  private
    procedure ActualizarLuces;
  end;

var
  frmIluminacion: TfrmIluminacion;

implementation

{$R *.dfm}

uses uComun;

const
  NOMBRES: array[0..5] of string = ('Recepcion', 'Lectura Silenciosa',
    'Sala de Computo', 'Hemeroteca', 'Estantes A-F', 'Sala de Grupos');
  TITULOS: array[0..4] of string = ('Zona', 'Nombre', 'Luz', 'Modo', 'Intensidad');

{ Palabra que sigue a Clave en una linea: "Zona 2 modo M luz 1 int 80%" }
function ValorDe(const Linea, Clave: string): string;
var
  p: Integer;
begin
  Result := '';
  p := Pos(Clave + ' ', Linea);
  if p = 0 then Exit;
  Result := Copy(Linea, p + Length(Clave) + 1, Length(Linea));
  p := Pos(' ', Result);
  if p > 0 then
    Result := Copy(Result, 1, p - 1);
end;

procedure TfrmIluminacion.FormShow(Sender: TObject);
var
  c, r: Integer;
begin
  for c := 0 to 4 do
    sgLuces.Cells[c, 0] := TITULOS[c];
  for r := 1 to 6 do
  begin
    sgLuces.Cells[0, r] := IntToStr(r);
    sgLuces.Cells[1, r] := NOMBRES[r - 1];
  end;
  tmrRefreshTimer(nil);
end;

procedure TfrmIluminacion.tmrRefreshTimer(Sender: TObject);
begin
  ActualizarLuces;
end;

{ Cada linea es un cambio; el ultimo cambio de cada zona es su estado actual }
procedure TfrmIluminacion.ActualizarLuces;
var
  L: TStringList;
  i, z, encendidas: Integer;
  modo: string;
begin
  for z := 1 to 6 do
  begin
    sgLuces.Cells[2, z] := 'OFF';
    sgLuces.Cells[3, z] := 'AUTO';
    sgLuces.Cells[4, z] := '100%';
  end;
  modo := 'A';
  lblUltimo.Caption := 'Ultimo cambio: -';
  L := TStringList.Create;
  try
    if CargarLineas('iluminacion.txt', L) then
    begin
      for i := 0 to L.Count - 1 do
      begin
        z := StrToIntDef(ValorDe(L[i], 'Zona'), 0);
        if (z < 1) or (z > 6) then Continue;
        modo := ValorDe(L[i], 'modo');
        if ValorDe(L[i], 'luz') = '1' then
          sgLuces.Cells[2, z] := 'ON'
        else
          sgLuces.Cells[2, z] := 'OFF';
        if modo = 'M' then
          sgLuces.Cells[3, z] := 'MANUAL'
        else
          sgLuces.Cells[3, z] := 'AUTO';
        sgLuces.Cells[4, z] := ValorDe(L[i], 'int');
      end;
      if L.Count > 0 then
        lblUltimo.Caption := 'Ultimo cambio: ' + Trim(L[L.Count - 1]);
    end;
  finally
    L.Free;
  end;
  encendidas := 0;
  for z := 1 to 6 do
    if sgLuces.Cells[2, z] = 'ON' then Inc(encendidas);
  if modo = 'M' then
    lblModo.Caption := 'Modo global: MANUAL'
  else
    lblModo.Caption := 'Modo global: AUTOMATICO';
  lblResumen.Caption := Format('Luces encendidas: %d/6', [encendidas]);
end;

procedure TfrmIluminacion.btnActualizarClick(Sender: TObject);
begin
  ActualizarLuces;
end;

procedure TfrmIluminacion.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Iluminacion.exe');
end;

procedure TfrmIluminacion.btnVolverClick(Sender: TObject);
begin
  Close;
end;

end.
