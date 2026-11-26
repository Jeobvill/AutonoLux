unit uCalcAxel;
{ FormCalcAxel - Permanencia promedio de los visitantes con FADD y FDIV.
  Entradas reales: persona-minutos acumulados en las zonas (mapa de calor) y entradas (visitantes.txt). }

interface

uses
  Classes, uCalcBase;

type
  TfrmCalcAxel = class(TfrmCalcBase)
  protected
    procedure CargarDatos; override;
    procedure Calcular; override;
  public
    constructor Crear(AOwner: TComponent);
  end;

procedure MostrarCalcAxel;

implementation

uses
  SysUtils, Dialogs, uComun;

constructor TfrmCalcAxel.Crear(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Construir('Permanencia promedio (FADD, FDIV)',
    'Tiempo promedio que pasa cada visitante en la biblioteca: persona-minutos de todas ' +
    'las zonas entre el numero de visitantes que entraron.',
    ['Persona-min zonas 1-3', 'Persona-min zonas 4-6', 'Visitantes (entradas)']);
  CargarDatos;
end;

procedure TfrmCalcAxel.CargarDatos;
var
  L: TStringList;
  ent: Integer;
begin
  { persona-segundos del dia que acumula uComun.MuestrearCalor a partir de mapa.txt }
  Poner(0, (CalorSeg[0, 0] + CalorSeg[0, 1] + CalorSeg[0, 2]) / 60);
  Poner(1, (CalorSeg[0, 3] + CalorSeg[0, 4] + CalorSeg[0, 5]) / 60);
  ent := 0;
  L := TStringList.Create;
  try
    if CargarLineas('visitantes.txt', L) and (L.Count > 0) then
      ent := NumeroTras(L[L.Count - 1], 'entradas');
  finally
    L.Free;
  end;
  FEdits[2].Text := IntToStr(ent);
end;

procedure TfrmCalcAxel.Calcular;
var
  t1, t2, visitantes, total, promedio: Double;
begin
  if not (Valor(0, t1) and Valor(1, t2) and Valor(2, visitantes)) then
  begin
    ShowMessage('Favor de introducir numeros');
    Exit;
  end;
  if visitantes <= 0 then
  begin
    ShowMessage('Aun no hay visitantes: registre entradas en el Contador.');
    Exit;
  end;
  asm
    FLD  t1          // ST0 = t1
    FADD t2          // ST0 = t1 + t2
    FSTP total       // persona-minutos totales

    FLD  total       // ST0 = total
    FDIV visitantes  // ST0 = total / visitantes
    FSTP promedio    // minutos por visitante
  end;
  Mostrar(Format('Persona-minutos: %s   Visitantes: %s   Permanencia promedio: %s min',
      [Num(total, 2), Num(visitantes, 0), Num(promedio, 2)]),
    ['total = t1 + t2',
     '  FLD  t1          ST0 = t1',
     '  FADD t2          ST0 = t1 + t2',
     '  FSTP total       pila vacia',
     'promedio = total / visitantes',
     '  FLD  total       ST0 = total',
     '  FDIV visitantes  ST0 = total / visitantes',
     '  FSTP promedio    pila vacia']);
end;

procedure MostrarCalcAxel;
var
  F: TfrmCalcAxel;
begin
  F := TfrmCalcAxel.Crear(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

end.
