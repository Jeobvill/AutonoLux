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
var
  TextoEquipo: string;
begin
  AplicarTema(Self);
  AsegurarCarpetas;
  CargarLogo(imgLogo);
  CargarEmu('Acerca.exe');  // carga (sin ejecutar) el programa compilado

  // Texto del equipo con correos institucionales. acerca.txt (Acerca.asm) solo se usa si ya los trae.
  TextoEquipo :=
    'AutonoLux - Deteccion y control de iluminacion' + sLineBreak +
    'Lenguajes de Interfaz - Instituto Tecnologico de Tepic, 2026' + sLineBreak + sLineBreak +
    'Integrantes:' + sLineBreak +
    '  Altamirano Murillo Axel Gabriel  (Login, Reporte, Acerca)' + sLineBreak +
    '    axgaaltamiranomu@ittepic.edu.mx' + sLineBreak +
    '  Veliz Partida Daniel  (Monitor, Calor, Bitacora)' + sLineBreak +
    '    davelizpa@ittepic.edu.mx' + sLineBreak +
    '  Diaz Robles Sergio  (Menu, Configuracion, Consumo)' + sLineBreak +
    '    sediazro@ittepic.edu.mx' + sLineBreak +
    '  Villa Campos Jesus Obed  (Mapa, Iluminacion, Contador)' + sLineBreak +
    '    jeobvillaca@ittepic.edu.mx';
  mmAcerca.Lines.Text := TextoEquipo;
  if FileExists(ARCH_ACERCA) then
    try
      mmAcerca.Lines.LoadFromFile(ARCH_ACERCA);
      if Pos('@', mmAcerca.Lines.Text) = 0 then   // archivo viejo sin correos: se deja el texto del equipo
        mmAcerca.Lines.Text := TextoEquipo;
    except
      mmAcerca.Lines.Text := TextoEquipo;
    end;
end;

end.
