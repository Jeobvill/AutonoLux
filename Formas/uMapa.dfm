object frmMapa: TfrmMapa
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Mapa de la biblioteca'
  ClientHeight = 513
  ClientWidth = 784
  Color = 2761246
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 55039
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 17
  object lblTitulo: TLabel
    Left = 30
    Top = 14
    Width = 724
    Height = 28
    AutoSize = False
    Caption = 'Mapa de la biblioteca (Dot Matrix, Switches y LEDs)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object pnlZona1: TPanel
    Left = 30
    Top = 60
    Width = 230
    Height = 115
    Cursor = crHandPoint
    Caption = '1 Recepcion'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 0
    Tag = 0
    OnClick = pnlZonaClick
  end
  object pnlZona2: TPanel
    Left = 277
    Top = 60
    Width = 230
    Height = 115
    Cursor = crHandPoint
    Caption = '2 Lectura Silenciosa'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 1
    Tag = 1
    OnClick = pnlZonaClick
  end
  object pnlZona3: TPanel
    Left = 524
    Top = 60
    Width = 230
    Height = 115
    Cursor = crHandPoint
    Caption = '3 Sala de Computo'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 2
    Tag = 2
    OnClick = pnlZonaClick
  end
  object pnlZona4: TPanel
    Left = 30
    Top = 190
    Width = 230
    Height = 115
    Cursor = crHandPoint
    Caption = '4 Hemeroteca'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 3
    Tag = 3
    OnClick = pnlZonaClick
  end
  object pnlZona5: TPanel
    Left = 277
    Top = 190
    Width = 230
    Height = 115
    Cursor = crHandPoint
    Caption = '5 Estantes A-F'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 4
    Tag = 4
    OnClick = pnlZonaClick
  end
  object pnlZona6: TPanel
    Left = 524
    Top = 190
    Width = 230
    Height = 115
    Cursor = crHandPoint
    Caption = '6 Sala de Grupos'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ParentBackground = False
    TabOrder = 5
    Tag = 5
    OnClick = pnlZonaClick
  end
  object lblDetalle: TLabel
    Left = 30
    Top = 330
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'Detalle: seleccione una zona'
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
    Top = 362
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'Zonas ocupadas: 0/6    Personas: 0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblDigito: TLabel
    Left = 30
    Top = 394
    Width = 724
    Height = 24
    AutoSize = False
    Caption = 'Dot Matrix: -'
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
    TabOrder = 6
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
    TabOrder = 7
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
    TabOrder = 8
    OnClick = btnVolverClick
  end
  object tmrRefresh: TTimer
    Interval = 500
    OnTimer = tmrRefreshTimer
    Left = 740
    Top = 8
  end
end
