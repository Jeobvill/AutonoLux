unit uCalcDaniel;
{ FormCalcDaniel - Margen termico con el coprocesador: FSUB, FCHS, FABS.
  Entradas: temperatura (temperatura.txt si existe) y umbral de alerta del Monitor. }

interface

uses
  Classes, uCalcBase;

type
  TfrmCalcDaniel = class(TfrmCalcBase)
  protected
    procedure CargarDatos; override;
    procedure Calcular; override;
  public
    constructor Crear(AOwner: TComponent);
  end;

procedure MostrarCalcDaniel;

implementation

uses
  SysUtils, Dialogs, uComun;

const
  UMBRAL_ALERTA = 35;   { el mismo que usa Monitor }

constructor TfrmCalcDaniel.Crear(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Construir('Margen t' + #233 + 'rmico (FSUB, FCHS, FABS)',
    'Distancia entre la temperatura de la biblioteca y el umbral de alerta. ' +
    'Un margen negativo significa que se paso del umbral.',
    ['Temperatura (' + #176 + 'C)', 'Umbral de alerta (' + #176 + 'C)']);
  CargarDatos;
end;

procedure TfrmCalcDaniel.CargarDatos;
var
  L: TStringList;
begin
  FEdits[1].Text := IntToStr(UMBRAL_ALERTA);
  FEdits[0].Text := '';
  L := TStringList.Create;
  try
    { temperatura.txt solo existe si el Thermometer la escribio; si no, la captura el usuario }
    if CargarLineas('temperatura.txt', L) and (L.Count > 0) then
      FEdits[0].Text := IntToStr(ExtraerEntero(L[L.Count - 1], 0));
  finally
    L.Free;
  end;
end;

procedure TfrmCalcDaniel.Calcular;
var
  temp, umbral, margen, exceso, distancia: Double;
  estado: string;
begin
  if not (Valor(0, temp) and Valor(1, umbral)) then
  begin
    ShowMessage('Favor de introducir numeros (capture la temperatura del Thermometer)');
    Exit;
  end;
  asm
    FLD  umbral      // ST0 = umbral
    FSUB temp        // ST0 = umbral - temp
    FSTP margen      // margen (negativo = sobre el umbral)

    FLD  margen      // ST0 = margen
    FCHS             // ST0 = -margen
    FSTP exceso      // exceso sobre el umbral

    FLD  margen      // ST0 = margen
    FABS             // ST0 = |margen|
    FSTP distancia   // distancia al umbral
  end;
  if margen < 0 then estado := 'ALERTA' else estado := 'NORMAL';
  Mostrar(Format('Margen: %s ' + #176 + 'C   Exceso: %s ' + #176 + 'C   Distancia: %s ' + #176 + 'C   Estado: %s',
      [Num(margen, 2), Num(exceso, 2), Num(distancia, 2), estado]),
    ['margen = umbral - temp',
     '  FLD  umbral     ST0 = umbral',
     '  FSUB temp       ST0 = umbral - temp',
     '  FSTP margen     pila vacia',
     'exceso = -margen',
     '  FLD  margen     ST0 = margen',
     '  FCHS            ST0 = -margen',
     '  FSTP exceso     pila vacia',
     'distancia = |margen|',
     '  FLD  margen     ST0 = margen',
     '  FABS            ST0 = |margen|',
     '  FSTP distancia  pila vacia']);
end;

procedure MostrarCalcDaniel;
var
  F: TfrmCalcDaniel;
begin
  F := TfrmCalcDaniel.Crear(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

end.
