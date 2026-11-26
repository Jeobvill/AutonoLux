unit uBitacora;
{ 5.9 - DANIEL - Bitacora de eventos }

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, StdCtrls, Buttons;

type
  TfrmBitacora = class(TForm)
    pnlPrincipal: TPanel;
    sgBitacora: TStringGrid;
    lblPagina: TLabel;
    cbFiltro: TComboBox;
    btnAgregar: TBitBtn;
    btnSig: TBitBtn;
    btnAnt: TBitBtn;
    btnFiltrar: TBitBtn;
    btnImprimir: TBitBtn;
    btnRonda: TBitBtn;
    btnVerEmu: TBitBtn;
    btnVolver: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnAgregarClick(Sender: TObject);
    procedure btnSigClick(Sender: TObject);
    procedure btnAntClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure btnRondaClick(Sender: TObject);
    procedure btnVerEmuClick(Sender: TObject);
    procedure btnVolverClick(Sender: TObject);
  private
    FTodos: TStringList;       { todas las lineas de bitacora.txt }
    FFiltrados: TStringList;   { las que pasan el filtro }
    FPagina: Integer;
    function TotalPaginas: Integer;
    procedure CargarBitacora;
    procedure AplicarFiltro;
    procedure MostrarPagina;
  end;

var
  frmBitacora: TfrmBitacora;

implementation

{$R *.dfm}

uses uComun, StrUtils;

const
  POR_PAGINA = 8;
  NUM_ZONAS = 6;

procedure TfrmBitacora.FormCreate(Sender: TObject);
const
  Titulos: array[0..3] of string = ('Hora', 'Zona', 'Evento', 'Usuario');
  Anchos: array[0..3] of Integer = (70, 90, 280, 100);
var
  c: Integer;
begin
  FTodos := TStringList.Create;
  FFiltrados := TStringList.Create;
  FPagina := 1;
  for c := 0 to 3 do
  begin
    sgBitacora.Cells[c, 0] := Titulos[c];
    sgBitacora.ColWidths[c] := Anchos[c];
  end;
end;

procedure TfrmBitacora.FormDestroy(Sender: TObject);
begin
  FTodos.Free;
  FFiltrados.Free;
end;

{ Al volver del emu (o al abrir) se recarga bitacora.txt }
procedure TfrmBitacora.FormActivate(Sender: TObject);
begin
  CargarBitacora;
  AplicarFiltro;
end;

function TfrmBitacora.TotalPaginas: Integer;
begin
  Result := (FFiltrados.Count + POR_PAGINA - 1) div POR_PAGINA;
  if Result < 1 then Result := 1;
end;

procedure TfrmBitacora.CargarBitacora;
begin
  CargarLineas('eventos.txt', FTodos);   { formato: Hora;Zona;Evento;Usuario (lo escribe uComun.RegistrarEventos) }
end;

procedure TfrmBitacora.AplicarFiltro;
var
  i: Integer;
begin
  FFiltrados.Clear;
  for i := 0 to FTodos.Count - 1 do
    if (cbFiltro.ItemIndex <= 0) or SameText(Campo(FTodos[i], 1), cbFiltro.Text) then
      FFiltrados.Add(FTodos[i]);
  if FPagina > TotalPaginas then FPagina := TotalPaginas;
  if FPagina < 1 then FPagina := 1;
  MostrarPagina;
end;

procedure TfrmBitacora.MostrarPagina;
var
  r, c, idx: Integer;
begin
  for r := 1 to POR_PAGINA do
  begin
    idx := (FPagina - 1) * POR_PAGINA + (r - 1);
    for c := 0 to 3 do
      if idx < FFiltrados.Count then
        sgBitacora.Cells[c, r] := Campo(FFiltrados[idx], c)
      else
        sgBitacora.Cells[c, r] := '';
  end;
  lblPagina.Caption := Format('P' + #225 + 'gina: %d/%d', [FPagina, TotalPaginas]);
  btnAnt.Enabled := FPagina > 1;
  btnSig.Enabled := FPagina < TotalPaginas;
end;

procedure TfrmBitacora.btnSigClick(Sender: TObject);
begin
  if FPagina < TotalPaginas then
  begin
    Inc(FPagina);
    MostrarPagina;
  end;
end;

procedure TfrmBitacora.btnAntClick(Sender: TObject);
begin
  if FPagina > 1 then
  begin
    Dec(FPagina);
    MostrarPagina;
  end;
end;

procedure TfrmBitacora.btnFiltrarClick(Sender: TObject);
begin
  FPagina := 1;
  CargarBitacora;
  AplicarFiltro;
end;

procedure TfrmBitacora.btnAgregarClick(Sender: TObject);
var
  Zona, Evento, Usuario: string;
begin
  Zona := 'Zona 1';
  Evento := '';
  Usuario := UsuarioActual;
  if not InputQuery('Agregar registro', 'Zona (Zona 1 ... Zona 6):', Zona) then Exit;
  if not InputQuery('Agregar registro', 'Evento:', Evento) then Exit;
  if not InputQuery('Agregar registro', 'Usuario:', Usuario) then Exit;

  CargarBitacora;
  FTodos.Add(FormatDateTime('hh:nn:ss', Now) + ';' + Zona + ';' + Evento + ';' + IfThen(Usuario = '', UsuarioActual, Usuario));
  FTodos.SaveToFile(RutaArchivo('eventos.txt'));
  AplicarFiltro;
end;

{ Escribe robot_cmd.txt y lanza Bitacora.exe; el .exe consume los comandos
  y los registra en bitacora.txt. Delphi no ejecuta el robot directamente. }
procedure TfrmBitacora.btnRondaClick(Sender: TObject);
var
  Cmd: TStringList;
  z: Integer;
begin
  Cmd := TStringList.Create;
  try
    for z := 1 to NUM_ZONAS do
    begin
      Cmd.Add('AVANZAR');
      Cmd.Add('LUZ_ON ' + IntToStr(z));
      Cmd.Add('LUZ_OFF ' + IntToStr(z));
    end;
    Cmd.SaveToFile(RutaArchivo('robot_cmd.txt'));
  finally
    Cmd.Free;
  end;
  LanzarEmu('Bitacora.exe');
end;

procedure TfrmBitacora.btnImprimirClick(Sender: TObject);
begin
  LanzarEmu('Bitacora.exe');
end;

procedure TfrmBitacora.btnVerEmuClick(Sender: TObject);
begin
  LanzarEmu('Bitacora.exe');
end;

procedure TfrmBitacora.btnVolverClick(Sender: TObject);
begin
  Close;
end;

end.
