object frmIluminacion: TfrmIluminacion
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Control de iluminaci'#243'n'
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
    Caption = 'Control manual de iluminaci'#243'n (LEDs)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object sgLuces: TStringGrid
    Left = 30
    Top = 50
    Width = 724
    Height = 252
    Color = clWhite
    ColCount = 5
    DefaultColWidth = 100
    FixedCols = 0
    RowCount = 7
    DefaultRowHeight = 36
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    ColWidths = (
      80
      235
      119
      145
      145
    )
  end
  object lblModo: TLabel
    Left = 30
    Top = 320
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'Modo global: -'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblResumen: TLabel
    Left = 30
    Top = 352
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'Luces encendidas: 0/6'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblUltimo: TLabel
    Left = 30
    Top = 384
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'Ultimo cambio: -'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -14
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
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
