unit uAcerca;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Imaging.jpeg;

type
  TfrmAcerca = class(TForm)
    imgLogo: TImage;
    mmAcerca: TMemo;
    btnVolver: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAcerca: TfrmAcerca;

implementation

uses
  uAxelComun;

{$R *.dfm}

procedure TfrmAcerca.FormCreate(Sender: TObject);
begin
  AplicarTema(Self);
  AsegurarCarpetas;
  CargarLogo(imgLogo);
  CargarEmu('Acerca.exe');  // carga (sin ejecutar) el programa compilado

  // Carga el texto descriptivo desde acerca.txt.
  if FileExists(ARCH_ACERCA) then
    mmAcerca.Lines.LoadFromFile(ARCH_ACERCA)
  else
    mmAcerca.Lines.Text :=
      'AutonoLux - Deteccion y control de iluminacion' + sLineBreak +
      'Lenguajes de Interfaz - Instituto Tecnologico de Tepic, 2026' + sLineBreak + sLineBreak +
      'Integrantes:' + sLineBreak +
      '  Altamirano Murillo Axel Gabriel' + sLineBreak +
      '  Veliz Partida Daniel' + sLineBreak +
      '  Diaz Robles Sergio' + sLineBreak +
      '  Villa Campos Jesus Obed';
end;

end.
