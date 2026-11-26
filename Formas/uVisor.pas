unit uVisor;
{ Visor de archivos de texto: muestra los .txt de cada integrante (Sergio, Axel, Daniel, Jesus)
  que generan los programas de Emu8086 y que usan las pantallas de Delphi }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmVisor = class(TForm)
  private
    FIntegrante: TComboBox;
    FLista: TListBox;
    FTexto: TMemo;
    FRuta: TLabel;
    procedure CargarLista;
    procedure MostrarArchivo;
    procedure IntegranteChange(Sender: TObject);
    procedure ListaClick(Sender: TObject);
    procedure ActualizarClick(Sender: TObject);
  public
    constructor Crear(AOwner: TComponent);
  end;

procedure MostrarVisor;

implementation

uses uComun;

const
  COLOR_FONDO = 2761246;
  COLOR_TEXTO = 55039;

constructor TfrmVisor.Crear(AOwner: TComponent);
var
  L: TLabel;
  B: TButton;
begin
  inherited CreateNew(AOwner);
  Position := poScreenCenter;
  Color := COLOR_FONDO;
  Font.Name := 'Segoe UI';
  ClientWidth := 860;
  ClientHeight := 520;
  Caption := 'Visor de archivos de texto';

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.SetBounds(16, 14, 80, 20);
  L.Caption := 'Integrante:';
  L.Font.Color := COLOR_TEXTO;
  L.Font.Style := [fsBold];

  FIntegrante := TComboBox.Create(Self);
  FIntegrante.Parent := Self;
  FIntegrante.SetBounds(100, 10, 200, 24);
  FIntegrante.Style := csDropDownList;
  FIntegrante.Items.Add('Sergio');
  FIntegrante.Items.Add('Axel');
  FIntegrante.Items.Add('Daniel');
  FIntegrante.Items.Add('Jesus');
  FIntegrante.ItemIndex := 3;
  FIntegrante.OnChange := IntegranteChange;

  B := TButton.Create(Self);
  B.Parent := Self;
  B.SetBounds(316, 9, 100, 26);
  B.Caption := 'Actualizar';
  B.OnClick := ActualizarClick;

  FLista := TListBox.Create(Self);
  FLista.Parent := Self;
  FLista.SetBounds(16, 48, 220, 440);
  FLista.OnClick := ListaClick;

  FTexto := TMemo.Create(Self);
  FTexto.Parent := Self;
  FTexto.SetBounds(248, 48, 596, 440);
  FTexto.ReadOnly := True;
  FTexto.ScrollBars := ssBoth;
  FTexto.WordWrap := False;
  FTexto.Font.Name := 'Consolas';
  FTexto.Font.Size := 10;

  FRuta := TLabel.Create(Self);
  FRuta.Parent := Self;
  FRuta.SetBounds(16, 494, 828, 18);
  FRuta.Font.Color := COLOR_TEXTO;
  FRuta.Font.Size := 8;

  CargarLista;
end;

procedure TfrmVisor.CargarLista;
var
  SR: TSearchRec;
  Carpeta: string;
begin
  FLista.Items.Clear;
  FTexto.Lines.Clear;
  Carpeta := RaizDatos + FIntegrante.Text + '\';
  FRuta.Caption := Carpeta;
  if FindFirst(Carpeta + '*.txt', faAnyFile, SR) = 0 then
  begin
    repeat
      FLista.Items.Add(SR.Name);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if FLista.Items.Count > 0 then
  begin
    FLista.ItemIndex := 0;
    MostrarArchivo;
  end
  else
    FTexto.Lines.Text := 'No hay archivos .txt en esta carpeta todavia.' + #13#10 +
      'Ejecute los programas de Emu8086 de ' + FIntegrante.Text + ' para generarlos.';
end;

{ Los archivos de registros fijos (como mapa.txt) pueden no tener saltos de linea: se parten cada 78 columnas }
procedure TfrmVisor.MostrarArchivo;
var
  F: TFileStream;
  Bytes: TBytes;
  Texto: string;
  i: Integer;
begin
  if FLista.ItemIndex < 0 then Exit;
  FRuta.Caption := RaizDatos + FIntegrante.Text + '\' + FLista.Items[FLista.ItemIndex];
  FTexto.Lines.Clear;
  try
    F := TFileStream.Create(FRuta.Caption, fmOpenRead or fmShareDenyNone);
    try
      SetLength(Bytes, F.Size);
      if F.Size > 0 then F.ReadBuffer(Bytes[0], F.Size);
    finally
      F.Free;
    end;
    Texto := '';
    for i := 0 to High(Bytes) do
      if Bytes[i] >= 32 then Texto := Texto + Chr(Bytes[i])
      else if Bytes[i] = 10 then Texto := Texto + #13#10
      else if Bytes[i] = 9 then Texto := Texto + ' ';
    if (Pos(#10, Texto) = 0) and (Length(Texto) > 78) then
    begin
      i := 79;
      while i <= Length(Texto) do
      begin
        Insert(#13#10, Texto, i);
        Inc(i, 80);
      end;
    end;
    FTexto.Lines.Text := Texto;
  except
    FTexto.Lines.Text := 'No se pudo leer el archivo.';
  end;
end;

procedure TfrmVisor.IntegranteChange(Sender: TObject);
begin
  CargarLista;
end;

procedure TfrmVisor.ListaClick(Sender: TObject);
begin
  MostrarArchivo;
end;

procedure TfrmVisor.ActualizarClick(Sender: TObject);
var
  Sel: string;
begin
  Sel := '';
  if FLista.ItemIndex >= 0 then Sel := FLista.Items[FLista.ItemIndex];
  CargarLista;
  if Sel <> '' then
  begin
    FLista.ItemIndex := FLista.Items.IndexOf(Sel);
    MostrarArchivo;
  end;
end;

procedure MostrarVisor;
var
  F: TfrmVisor;
begin
  F := TfrmVisor.Crear(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

end.
