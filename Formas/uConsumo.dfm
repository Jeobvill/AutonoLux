object frmConsumo: TfrmConsumo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Consumo energ'#233'tico'
  ClientHeight = 513
  ClientWidth = 784
  Color = 2761246
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 55039
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 17
  object lblTotal: TLabel
    Left = 30
    Top = 305
    Width = 724
    Height = 28
    AutoSize = False
    Caption = 'TOTAL:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblPotencia: TLabel
    Left = 30
    Top = 348
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
  object lblAhorro: TLabel
    Left = 30
    Top = 386
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'AHORRO:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object sgConsumo: TStringGrid
    Left = 30
    Top = 25
    Width = 724
    Height = 252
    Color = clWhite
    DefaultColWidth = 100
    FixedCols = 0
    RowCount = 6
    DefaultRowHeight = 40
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
      235
      120
      120
      120
      120)
  end
  object btnRecalcular: TPanel
    Left = 30
    Top = 448
    Width = 230
    Height = 45
    Cursor = crHandPoint
    Caption = 'Recalcular'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
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
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
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
    ParentBackground = False
    ParentFont = False
    TabOrder = 3
    OnClick = btnVolverClick
  end
end
