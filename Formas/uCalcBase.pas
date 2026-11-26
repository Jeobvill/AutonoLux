unit uCalcBase;
{ Base visual de los 4 formularios del coprocesador (FormCalcSergio/Daniel/Jesus/Axel).
  Cada formulario hijo define sus campos, de donde salen los datos reales y su bloque asm. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmCalcBase = class(TForm)
  protected
    FEdits: array of TEdit;
    FPila: TMemo;
    FResultado: TLabel;
    procedure Construir(const Titulo, Concepto: string; const Campos: array of string);
    function Valor(I: Integer; out V: Double): Boolean;
    procedure Poner(I: Integer; V: Double);
    procedure Mostrar(const Resultado: string; const Pila: array of string);
    procedure CargarDatos; virtual; abstract;
    procedure Calcular; virtual; abstract;
    procedure BtnCalcularClick(Sender: TObject);
    procedure BtnDatosClick(Sender: TObject);
    procedure BtnCerrarClick(Sender: TObject);
  end;

function Num(V: Double; Dec: Integer = 4): string;

implementation

const
  COLOR_FONDO = 2761246;
  COLOR_TEXTO = 55039;
  COLOR_BOTON = 10569485;

function Num(V: Double; Dec: Integer): string;
begin
  Result := FloatToStrF(V, ffFixed, 15, Dec);
end;

function Boton(Padre: TWinControl; const Texto: string; X, Y, W: Integer;
  Evento: TNotifyEvent): TPanel;
begin
  Result := TPanel.Create(Padre);
  Result.Parent := Padre;
  Result.SetBounds(X, Y, W, 40);
  Result.Caption := Texto;
  Result.Color := COLOR_BOTON;
  Result.ParentBackground := False;
  Result.Font.Color := COLOR_TEXTO;
  Result.Font.Size := 11;
  Result.Font.Style := [fsBold];
  Result.Cursor := crHandPoint;
  Result.OnClick := Evento;
end;

function Etiqueta(Padre: TWinControl; const Texto: string; X, Y, W, H: Integer;
  Tam: Integer; Negrita: Boolean): TLabel;
begin
  Result := TLabel.Create(Padre);
  Result.Parent := Padre;
  Result.AutoSize := False;
  Result.WordWrap := True;
  Result.SetBounds(X, Y, W, H);
  Result.Caption := Texto;
  Result.Font.Color := COLOR_TEXTO;
  Result.Font.Size := Tam;
  if Negrita then Result.Font.Style := [fsBold];
  Result.Transparent := True;
end;

procedure TfrmCalcBase.Construir(const Titulo, Concepto: string; const Campos: array of string);
var
  i, y: Integer;
  E: TEdit;
begin
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu, biMinimize];
  Position := poScreenCenter;
  Color := COLOR_FONDO;
  Font.Name := 'Segoe UI';
  Font.Color := COLOR_TEXTO;
  ClientWidth := 784;
  ClientHeight := 560;
  Caption := Titulo;

  Etiqueta(Self, Titulo, 30, 12, 724, 28, 15, True);
  Etiqueta(Self, Concepto, 30, 44, 724, 40, 10, False);

  SetLength(FEdits, Length(Campos));
  y := 100;
  for i := 0 to High(Campos) do
  begin
    Etiqueta(Self, Campos[i], 30, y, 215, 32, 10, False);
    E := TEdit.Create(Self);
    E.Parent := Self;
    E.SetBounds(250, y, 130, 28);
    E.Color := clWhite;
    E.Font.Color := clBlack;
    E.Font.Size := 11;
    FEdits[i] := E;
    Inc(y, 38);
  end;

  Etiqueta(Self, 'Pila del coprocesador (ST0 = tope)', 400, 100, 354, 20, 10, True);
  FPila := TMemo.Create(Self);
  FPila.Parent := Self;
  FPila.SetBounds(400, 124, 354, 290);
  FPila.ReadOnly := True;
  FPila.ScrollBars := ssVertical;
  FPila.Font.Name := 'Consolas';
  FPila.Font.Size := 9;
  FPila.Color := clWhite;
  FPila.Font.Color := clBlack;

  FResultado := Etiqueta(Self, 'Resultado: pulse "Cargar datos del sistema" y luego "Calcular".',
    30, 424, 724, 70, 11, True);

  Boton(Self, 'Cargar datos del sistema', 30, 504, 230, BtnDatosClick);
  Boton(Self, 'Calcular', 280, 504, 200, BtnCalcularClick);
  Boton(Self, 'Cerrar', 504, 504, 250, BtnCerrarClick);
end;

function TfrmCalcBase.Valor(I: Integer; out V: Double): Boolean;
var
  S: string;
begin
  S := Trim(FEdits[I].Text);
  S := StringReplace(S, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := TryStrToFloat(S, V);
end;

procedure TfrmCalcBase.Poner(I: Integer; V: Double);
begin
  FEdits[I].Text := Num(V, 4);
end;

procedure TfrmCalcBase.Mostrar(const Resultado: string; const Pila: array of string);
var
  i: Integer;
begin
  FResultado.Caption := Resultado;
  FPila.Lines.BeginUpdate;
  try
    FPila.Clear;
    for i := 0 to High(Pila) do
      FPila.Lines.Add(Pila[i]);
  finally
    FPila.Lines.EndUpdate;
  end;
end;

procedure TfrmCalcBase.BtnCalcularClick(Sender: TObject);
begin
  Calcular;
end;

procedure TfrmCalcBase.BtnDatosClick(Sender: TObject);
begin
  CargarDatos;
end;

procedure TfrmCalcBase.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
