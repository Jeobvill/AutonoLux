unit uVideo;
{ FormVideo - Trailer del proyecto (archivo en la carpeta Video) y entrevista (enlace de EVA) }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmVideo = class(TForm)
  private
    FInfo: TLabel;
    procedure BtnTrailerClick(Sender: TObject);
    procedure BtnEntrevistaClick(Sender: TObject);
    procedure BtnCerrarClick(Sender: TObject);
  public
    constructor Crear(AOwner: TComponent);
  end;

procedure MostrarVideo;

implementation

uses uComun;

const
  COLOR_FONDO = 2761246;
  COLOR_TEXTO = 55039;
  COLOR_BOTON = 10569485;

function NuevoBoton(Padre: TWinControl; const Texto: string; Y: Integer;
  Evento: TNotifyEvent): TPanel;
begin
  Result := TPanel.Create(Padre);
  Result.Parent := Padre;
  Result.SetBounds(100, Y, 400, 50);
  Result.Caption := Texto;
  Result.Color := COLOR_BOTON;
  Result.ParentBackground := False;
  Result.Font.Color := COLOR_TEXTO;
  Result.Font.Size := 12;
  Result.Font.Style := [fsBold];
  Result.Cursor := crHandPoint;
  Result.OnClick := Evento;
end;

constructor TfrmVideo.Crear(AOwner: TComponent);
var
  T: TLabel;
begin
  inherited CreateNew(AOwner);
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu, biMinimize];
  Position := poScreenCenter;
  Color := COLOR_FONDO;
  Font.Name := 'Segoe UI';
  ClientWidth := 600;
  ClientHeight := 360;
  Caption := 'Trailer y entrevista';

  T := TLabel.Create(Self);
  T.Parent := Self;
  T.SetBounds(100, 20, 400, 30);
  T.Caption := 'AutonoLux - Video';
  T.Font.Color := COLOR_TEXTO;
  T.Font.Size := 16;
  T.Font.Style := [fsBold];

  NuevoBoton(Self, 'Trailer del proyecto', 70, BtnTrailerClick);
  NuevoBoton(Self, 'Entrevista (EVA)', 140, BtnEntrevistaClick);
  NuevoBoton(Self, 'Cerrar', 290, BtnCerrarClick);

  FInfo := TLabel.Create(Self);
  FInfo.Parent := Self;
  FInfo.AutoSize := False;
  FInfo.WordWrap := True;
  FInfo.SetBounds(100, 205, 400, 70);
  FInfo.Font.Color := COLOR_TEXTO;
  FInfo.Font.Size := 9;
  FInfo.Caption := 'El trailer se abre en linea (HeyGen).' + #13 +
    'La entrevista abre Video\Entrevista.mp4 si esta en esta computadora; si no, el enlace de EVA.';
end;

procedure TfrmVideo.BtnTrailerClick(Sender: TObject);
begin
  FInfo.Caption := 'Abriendo el trailer en el navegador...';
  if not AbrirArchivoOEnlace(URL_TRAILER) then
    FInfo.Caption := 'No se pudo abrir el enlace: ' + URL_TRAILER;
end;

{ Entrevista: archivo local si esta en la carpeta Video; si no, el enlace de EVA }
procedure TfrmVideo.BtnEntrevistaClick(Sender: TObject);
var
  R: string;
begin
  R := RutaEntrevista;
  if R <> '' then
  begin
    FInfo.Caption := 'Abriendo: ' + R;
    if not AbrirArchivoOEnlace(R) then
      FInfo.Caption := 'Windows no pudo abrir el video: ' + R;
    Exit;
  end;
  FInfo.Caption := 'No hay Video\Entrevista.mp4 en esta computadora; se abre el enlace de EVA: ' + UrlEntrevista;
  if not AbrirArchivoOEnlace(UrlEntrevista) then
    FInfo.Caption := 'No se pudo abrir el enlace: ' + UrlEntrevista;
end;

procedure TfrmVideo.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure MostrarVideo;
var
  F: TfrmVideo;
begin
  F := TfrmVideo.Crear(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

end.
