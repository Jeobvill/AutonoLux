unit uCalcJesus;
{ FormCalcJesus - Dispersion de la ocupacion entre zonas y proyeccion de potencia.
  Instrucciones del coprocesador: FADD, FSUB, FMUL, FDIV, FSQRT y FSCALE.
  Entradas reales: personas por zona (mapa.txt) y potencia encendida (iluminacion.txt + config.txt). }

interface

uses
  Classes, uCalcBase;

type
  TfrmCalcJesus = class(TfrmCalcBase)
  protected
    procedure CargarDatos; override;
    procedure Calcular; override;
  public
    constructor Crear(AOwner: TComponent);
  end;

procedure MostrarCalcJesus;

implementation

uses
  SysUtils, Dialogs, uComun;

constructor TfrmCalcJesus.Crear(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Construir('Dispersi' + #243 + 'n de ocupaci' + #243 + 'n y proyecci' + #243 + 'n de potencia (FSQRT, FSCALE)',
    'Desviacion estandar de las personas entre las 6 zonas (que tan desigual esta repartida la gente) ' +
    'y potencia proyectada al multiplicar las lamparas por 2^n.',
    ['Personas zona 1', 'Personas zona 2', 'Personas zona 3', 'Personas zona 4',
     'Personas zona 5', 'Personas zona 6', 'Potencia encendida (W)', 'Factor de escala n (x 2^n)']);
  CargarDatos;
end;

procedure TfrmCalcJesus.CargarDatos;
var
  P: array[0..5] of Integer;
  Luz, Inten: array[0..5] of Integer;
  i: Integer;
  w: Double;
begin
  LeerPersonasMapa(P);
  LeerIluminacion(Luz, Inten);
  w := 0;
  for i := 0 to 5 do
  begin
    Poner(i, P[i]);
    if Luz[i] = 1 then
      w := w + LAMPARAS_ZONA * ConfigEntero(3) * Inten[i] / 100;
  end;
  Poner(6, w);
  FEdits[7].Text := '1';
end;

procedure TfrmCalcJesus.Calcular;
var
  p0, p1, p2, p3, p4, p5, seis, media, sigma, pot, n, proy: Double;
  i: Integer;
  V: array[0..7] of Double;
begin
  for i := 0 to 7 do
    if not Valor(i, V[i]) then
    begin
      ShowMessage('Favor de introducir numeros');
      Exit;
    end;
  p0 := V[0]; p1 := V[1]; p2 := V[2]; p3 := V[3]; p4 := V[4]; p5 := V[5];
  pot := V[6];
  n := V[7];
  seis := 6;
  asm
    // media = (p0 + ... + p5) / 6
    FLD  p0
    FADD p1
    FADD p2
    FADD p3
    FADD p4
    FADD p5          // ST0 = suma de personas
    FDIV seis        // ST0 = media
    FSTP media

    // sigma = raiz( suma((pi - media)^2) / 6 )
    FLDZ             // ST0 = 0 (acumulador)
    FLD  p0
    FSUB media
    FMUL ST(0), ST(0)
    FADDP ST(1), ST(0)
    FLD  p1
    FSUB media
    FMUL ST(0), ST(0)
    FADDP ST(1), ST(0)
    FLD  p2
    FSUB media
    FMUL ST(0), ST(0)
    FADDP ST(1), ST(0)
    FLD  p3
    FSUB media
    FMUL ST(0), ST(0)
    FADDP ST(1), ST(0)
    FLD  p4
    FSUB media
    FMUL ST(0), ST(0)
    FADDP ST(1), ST(0)
    FLD  p5
    FSUB media
    FMUL ST(0), ST(0)
    FADDP ST(1), ST(0)   // ST0 = suma de cuadrados
    FDIV seis            // ST0 = varianza
    FSQRT                // ST0 = desviacion estandar
    FSTP sigma

    // proyeccion = pot x 2^n   (FSCALE: ST0 = ST0 x 2^trunc(ST1))
    FLD  n               // ST0 = n
    FLD  pot             // ST0 = pot, ST1 = n
    FSCALE               // ST0 = pot x 2^n
    FSTP proy            // guarda y saca ST0
    FSTP ST(0)           // saca n: pila vacia
  end;
  Mostrar(Format('Media: %s personas   Desviacion (sigma): %s   Potencia proyectada: %s W (x %s)',
      [Num(media, 2), Num(sigma, 3), Num(proy, 1), Num(Exp(Ln(2) * Trunc(n)), 2)]),
    ['media = suma / 6',
     '  FLD p0 ... FADD p5   ST0 = suma',
     '  FDIV seis            ST0 = media',
     '  FSTP media           pila vacia',
     'sigma = raiz(suma((pi-media)^2)/6)',
     '  FLDZ                 ST0 = 0',
     '  FLD pi               ST0 = pi, ST1 = acum',
     '  FSUB media           ST0 = pi - media',
     '  FMUL ST(0),ST(0)    ST0 = (pi-media)^2',
     '  FADDP ST(1),ST(0)   ST0 = acum + cuadrado',
     '  (se repite para p0..p5)',
     '  FDIV seis            ST0 = varianza',
     '  FSQRT                ST0 = sigma',
     '  FSTP sigma           pila vacia',
     'proyeccion = pot x 2^n',
     '  FLD  n               ST0 = n',
     '  FLD  pot             ST0 = pot, ST1 = n',
     '  FSCALE               ST0 = pot x 2^n',
     '  FSTP proy            ST0 = n',
     '  FSTP ST(0)           pila vacia']);
end;

procedure MostrarCalcJesus;
var
  F: TfrmCalcJesus;
begin
  F := TfrmCalcJesus.Crear(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

end.
