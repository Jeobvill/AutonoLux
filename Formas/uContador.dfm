object frmContador: TfrmContador
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Contador de visitantes'
  ClientHeight = 513
  ClientWidth = 784
  Color = 2761246
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 55039
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 17
  object lblTitulo: TLabel
    Left = 30
    Top = 14
    Width = 724
    Height = 28
    AutoSize = False
    Caption = 'Contador de visitantes (Seven Segment y Push Buttons)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblSala: TLabel
    Left = 30
    Top = 60
    Width = 724
    Height = 40
    AutoSize = False
    Caption = 'EN SALA AHORA: 0 personas'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -28
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblAforo: TLabel
    Left = 30
    Top = 110
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'Aforo m'#225'ximo: 60 personas     Porcentaje: 0 %'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object shFondo: TShape
    Left = 30
    Top = 145
    Width = 724
    Height = 28
    Brush.Color = clWhite
  end
  object shBarra: TShape
    Left = 30
    Top = 145
    Width = 0
    Height = 28
    Brush.Color = clLime
  end
  object lblEntradas: TLabel
    Left = 30
    Top = 195
    Width = 360
    Height = 24
    AutoSize = False
    Caption = 'Entradas del d'#237'a: 0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblSalidas: TLabel
    Left = 394
    Top = 195
    Width = 360
    Height = 24
    AutoSize = False
    Caption = 'Salidas del d'#237'a: 0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblPico: TLabel
    Left = 30
    Top = 229
    Width = 360
    Height = 24
    AutoSize = False
    Caption = 'Pico del d'#237'a: 0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblLibres: TLabel
    Left = 394
    Top = 229
    Width = 360
    Height = 24
    AutoSize = False
    Caption = 'Lugares libres: 60'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblMensaje: TLabel
    Left = 30
    Top = 270
    Width = 724
    Height = 24
    AutoSize = False
    Caption = '-'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object mmEventos: TMemo
    Left = 30
    Top = 305
    Width = 724
    Height = 125
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnActualizar: TPanel
    Left = 30
    Top = 448
    Width = 230
    Height = 45
    Cursor = crHandPoint
    Caption = 'Actualizar'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 1
    OnClick = btnActualizarClick
  end
  object btnVerEmu: TPanel
    Left = 277
    Top = 448
    Width = 230
    Height = 45
    Cursor = crHandPoint
    Caption = 'Ver pantalla emu'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 2
    OnClick = btnVerEmuClick
  end
  object btnVolver: TPanel
    Left = 524
    Top = 448
    Width = 230
    Height = 45
    Cursor = crHandPoint
    Caption = 'Volver'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 3
    OnClick = btnVolverClick
  end
  object tmrRefresh: TTimer
    Interval = 500
    OnTimer = tmrRefreshTimer
    Left = 740
    Top = 8
  end
end
