unit uCalcSergio;
{ FormCalcSergio - Ahorro energetico con el coprocesador: FADD, FSUB, FMUL, FDIV.
  Entradas reales: kWh por zona (Consumo), kWh sin automatizar y tarifa (Configuracion). }

interface

uses
  Classes, uCalcBase;

type
  TfrmCalcSergio = class(TfrmCalcBase)
  protected
    procedure CargarDatos; override;
    procedure Calcular; override;
  public
    constructor Crear(AOwner: TComponent);
  end;

procedure MostrarCalcSergio;

implementation

uses
  SysUtils, Dialogs, uComun;

constructor TfrmCalcSergio.Crear(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Construir('Ahorro energ' + #233 + 'tico (FADD, FSUB, FMUL, FDIV)',
    'Suma el consumo de las zonas, lo compara con tener todas las luces siempre encendidas ' +
    'y calcula el porcentaje y el dinero ahorrado.',
    ['Consumo zonas 1-3 (kWh)', 'Consumo zonas 4-6 (kWh)',
     'Sin automatizar (kWh)', 'Tarifa ($/kWh)']);
  CargarDatos;
end;

{ kWh medidos por uComun.MuestrearConsumo a partir de iluminacion.txt; la tarifa y los watts vienen de config.txt }
procedure TfrmCalcSergio.CargarDatos;
var
  sinAuto: Double;
begin
  Poner(0, (WhZona[0] + WhZona[1] + WhZona[2]) / 1000);
  Poner(1, (WhZona[3] + WhZona[4] + WhZona[5]) / 1000);
  sinAuto := 6 * LAMPARAS_ZONA * ConfigEntero(3) * (SegTotal / 3600) / 1000;
  Poner(2, sinAuto);
  Poner(3, ConfigTarifa);
end;

procedure TfrmCalcSergio.Calcular;
var
  c1, c2, sinAuto, tarifa, cien: Double;
  total, ahorro, pct, dinero: Double;
begin
  if not (Valor(0, c1) and Valor(1, c2) and Valor(2, sinAuto) and Valor(3, tarifa)) then
  begin
    ShowMessage('Favor de introducir numeros');
    Exit;
  end;
  if sinAuto <= 0 then
  begin
    ShowMessage('No hay consumo sin automatizar: emule Iluminacion con la aplicacion abierta.');
    Exit;
  end;
  cien := 100;
  asm
    FLD  c1          // ST0 = c1
    FADD c2          // ST0 = c1 + c2
    FSTP total       // total = consumo con automatizacion

    FLD  sinAuto         // ST0 = sin automatizar
    FSUB total       // ST0 = sinAuto - total
    FSTP ahorro      // ahorro en kWh

    FLD  ahorro      // ST0 = ahorro
    FMUL cien        // ST0 = ahorro x 100
    FDIV sinAuto         // ST0 = ahorro x 100 / sinAuto
    FSTP pct         // porcentaje de ahorro

    FLD  ahorro      // ST0 = ahorro
    FMUL tarifa      // ST0 = ahorro x tarifa
    FSTP dinero      // dinero ahorrado
  end;
  Mostrar(Format('Consumo total: %s kWh   Ahorro: %s kWh (%s %%)   Dinero ahorrado: $ %s',
      [Num(total), Num(ahorro), Num(pct, 2), Num(dinero, 2)]),
    ['total = c1 + c2',
     '  FLD  c1       ST0 = c1',
     '  FADD c2       ST0 = c1 + c2',
     '  FSTP total    pila vacia',
     'ahorro = sinAuto - total',
     '  FLD  sinAuto   ST0 = sinAuto',
     '  FSUB total    ST0 = sinAuto - total',
     '  FSTP ahorro   pila vacia',
     'pct = ahorro x 100 / sinAuto',
     '  FLD  ahorro   ST0 = ahorro',
     '  FMUL cien     ST0 = ahorro x 100',
     '  FDIV sinAuto   ST0 = ahorro x 100 / sinAuto',
     '  FSTP pct      pila vacia',
     'dinero = ahorro x tarifa',
     '  FLD  ahorro   ST0 = ahorro',
     '  FMUL tarifa   ST0 = ahorro x tarifa',
     '  FSTP dinero   pila vacia']);
end;

procedure MostrarCalcSergio;
var
  F: TfrmCalcSergio;
begin
  F := TfrmCalcSergio.Crear(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

end.
