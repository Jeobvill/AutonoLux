unit uReporte;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg;

type
  TfrmReporte = class(TForm)
    imgLogo: TImage;
    mmReporte: TMemo;
    lblNota1: TLabel;
    edNota1: TEdit;
    lblNota2: TLabel;
    edNota2: TEdit;
    lblNota3: TLabel;
    edNota3: TEdit;
    btnAgregar: TBitBtn;
    btnCargar: TBitBtn;
    btnGuardar: TBitBtn;
    btnVolver: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure btnAgregarClick(Sender: TObject);
    procedure btnCargarClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
  private
    FNotasAgregadas: Integer;
    procedure AgregarFuente(const Titulo, Ruta: string);
    procedure CargarReporte;
  public
    { Public declarations }
  end;

var
  frmReporte: TfrmReporte;

implementation

uses
  uAxelComun;

{$R *.dfm}

procedure TfrmReporte.AgregarFuente(const Titulo, Ruta: string);
var
  tmp: TStringList;
begin
  mmReporte.Lines.Add('');
  mmReporte.Lines.Add('=== ' + Titulo + ' ===');
  if FileExists(Ruta) then
  begin
    tmp := TStringList.Create;
    try
      tmp.LoadFromFile(Ruta);
      mmReporte.Lines.AddStrings(tmp);
    finally
      tmp.Free;
    end;
  end
  else
    mmReporte.Lines.Add('(sin datos: ' + Ruta + ')');
end;

procedure TfrmReporte.CargarReporte;
begin
  // Carga (sin ejecutar) el programa compilado de Reporte.
  CargarEmu('Reporte.exe');

  // Lee las fuentes de datos.
  mmReporte.Clear;
  FNotasAgregadas := 0;
  edNota1.Clear;
  edNota2.Clear;
  edNota3.Clear;

  AgregarFuente('CABECERA (reporte.txt)', ARCH_REPORTE);
  AgregarFuente('INCIDENCIAS DEL DÍA (bitacora.txt)', ARCH_BITACORA);
  AgregarFuente('RESUMEN DE OCUPACIÓN (zonas.txt)', ARCH_ZONAS);
  AgregarFuente('ENTRADAS / SALIDAS / PICO (visitantes.txt)', ARCH_VISITANTES);
end;

procedure TfrmReporte.FormShow(Sender: TObject);
begin
  AplicarTema(Self);
  CargarLogo(imgLogo);
  CargarReporte;
end;

procedure TfrmReporte.btnAgregarClick(Sender: TObject);
var
  Nota: string;
  HayNota: Boolean;
begin
  if FNotasAgregadas >= 3 then
  begin
    ShowMessage('Máximo 3 notas por reporte');
    Exit;
  end;

  HayNota := (Trim(edNota1.Text) <> '') or
             (Trim(edNota2.Text) <> '') or
             (Trim(edNota3.Text) <> '');
  if not HayNota then
  begin
    ShowMessage('Escriba al menos una nota.');
    Exit;
  end;

  // La cabecera se agrega solo la primera vez, para no duplicarla.
  if FNotasAgregadas = 0 then
  begin
    mmReporte.Lines.Add('');
    mmReporte.Lines.Add('--- NOTAS DEL OPERADOR ---');
  end;

  Nota := Trim(edNota1.Text);
  if (Nota <> '') and (FNotasAgregadas < 3) then
  begin
    mmReporte.Lines.Add('Nota 1: ' + Nota);
    Inc(FNotasAgregadas);
  end;

  Nota := Trim(edNota2.Text);
  if (Nota <> '') and (FNotasAgregadas < 3) then
  begin
    mmReporte.Lines.Add('Nota 2: ' + Nota);
    Inc(FNotasAgregadas);
  end;

  Nota := Trim(edNota3.Text);
  if (Nota <> '') and (FNotasAgregadas < 3) then
  begin
    mmReporte.Lines.Add('Nota 3: ' + Nota);
    Inc(FNotasAgregadas);
  end;

  edNota1.Clear;
  edNota2.Clear;
  edNota3.Clear;
end;

procedure TfrmReporte.btnGuardarClick(Sender: TObject);
begin
  AsegurarCarpetas;
  try
    mmReporte.Lines.SaveToFile(ARCH_REPORTE);
    ShowMessage('Reporte guardado en ' + ARCH_REPORTE);
  except
    ShowMessage('No se pudo guardar el reporte.');
  end;
end;

procedure TfrmReporte.btnCargarClick(Sender: TObject);
begin
  // Recarga el reporte desde los archivos de datos.
  CargarReporte;
end;

end.
