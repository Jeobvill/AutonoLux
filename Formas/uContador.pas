unit uContador;
{ Pantalla Contador (Obed): lee visitantes.txt escrito por Contador.exe }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmContador = class(TForm)
    lblTitulo: TLabel;
    lblSala: TLabel;
    lblAforo: TLabel;
    shFondo: TShape;
    shBarra: TShape;
    lblEntradas: TLabel;
    lblSalidas: TLabel;
    lblPico: TLabel;
    lblLibres: TLabel;
    lblMensaje: TLabel;
    mmEventos: TMemo;
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
    procedure ActualizarContador;
  end;

var
  frmContador: TfrmContador;

implementation

{$R *.dfm}

uses uComun;

const
  AFORO_DEFAULT = 60;

{ Numero que sigue a Clave: "Evento ENTRA sala 012 entradas 015 salidas 003 pico 014" }
function NumeroDe(const Linea, Clave: string): Integer;
var
  p: Integer;
  S: string;
begin
  Result := 0;
  p := Pos(' ' + Clave + ' ', Linea);
  if p = 0 then Exit;
  S := Trim(Copy(Linea, p + Length(Clave) + 2, 6));
  p := Pos(' ', S);
  if p > 0 then
    S := Copy(S, 1, p - 1);
  Result := StrToIntDef(S, 0);
end;

procedure TfrmContador.FormShow(Sender: TObject);
begin
  tmrRefreshTimer(nil);
end;

procedure TfrmContador.tmrRefreshTimer(Sender: TObject);
begin
  ActualizarContador;
end;

procedure TfrmContador.ActualizarContador;
var
  L, C: TStringList;
  sala, entradas, salidas, pico, aforo, pct, libres, i: Integer;
begin
  sala := 0;
  entradas := 0;
  salidas := 0;
  pico := 0;
  aforo := AFORO_DEFAULT;
  L := TStringList.Create;
  C := TStringList.Create;
  try
    { config.txt: linea 1 = aforo maximo (el mismo que usa el Monitor) }
    if CargarLineas('config.txt', C) and (C.Count > 0) then
      aforo := ExtraerEntero(C[0], AFORO_DEFAULT);
    if aforo <= 0 then aforo := AFORO_DEFAULT;

    mmEventos.Lines.BeginUpdate;
    try
      mmEventos.Clear;
      if CargarLineas('visitantes.txt', L) then
      begin
        if L.Count > 0 then
        begin
          sala := NumeroDe(L[L.Count - 1], 'sala');
          entradas := NumeroDe(L[L.Count - 1], 'entradas');
          salidas := NumeroDe(L[L.Count - 1], 'salidas');
          pico := NumeroDe(L[L.Count - 1], 'pico');
        end;
        { ultimos eventos al principio }
        for i := L.Count - 1 downto 0 do
          mmEventos.Lines.Add(L[i]);
      end;
    finally
      mmEventos.Lines.EndUpdate;
    end;
  finally
    L.Free;
    C.Free;
  end;

  { Lugares libres = aforo - personas (la resta del catedratico) }
  libres := aforo - sala;
  if libres < 0 then libres := 0;
  pct := Round(100 * sala / aforo);
  if pct > 100 then pct := 100;

  lblSala.Caption := Format('EN SALA AHORA: %d personas', [sala]);
  lblAforo.Caption := Format('Aforo maximo: %d personas     Porcentaje: %d %%', [aforo, pct]);
  lblEntradas.Caption := 'Entradas del dia: ' + IntToStr(entradas);
  lblSalidas.Caption := 'Salidas del dia: ' + IntToStr(salidas);
  lblPico.Caption := 'Pico del dia: ' + IntToStr(pico);
  lblLibres.Caption := 'Lugares libres: ' + IntToStr(libres);

  shBarra.Width := shFondo.Width * pct div 100;
  if pct < 50 then
    shBarra.Brush.Color := clLime
  else if pct < 80 then
    shBarra.Brush.Color := clYellow
  else
    shBarra.Brush.Color := clRed;

  if sala >= aforo then
    lblMensaje.Caption := 'Aforo maximo alcanzado. No puede entrar nadie mas.'
  else if sala = 0 then
    lblMensaje.Caption := 'La sala esta vacia.'
  else
    lblMensaje.Caption := 'Conteo normal.';
end;

procedure TfrmContador.btnActualizarClick(Sender: TObject);
begin
  ActualizarContador;
end;

procedure TfrmContador.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Contador.exe');
end;

procedure TfrmContador.btnVolverClick(Sender: TObject);
begin
  Close;
end;

end.
