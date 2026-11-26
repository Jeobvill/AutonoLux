object frmBitacora: TfrmBitacora
  Left = 240
  Top = 100
  BorderStyle = bsSingle
  Caption = 'Bit'#225'cora de eventos'
  ClientHeight = 430
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 16
  object pnlPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 430
    Align = alClient
    BevelOuter = bvNone
    Color = clDarkblue
    ParentBackground = False
    TabOrder = 0
    object lblPagina: TLabel
      Left = 16
      Top = 296
      Width = 66
      Height = 16
      Caption = 'P'#225'gina: 1/3'
    end
    object sgBitacora: TStringGrid
      Left = 16
      Top = 56
      Width = 570
      Height = 225
      ColCount = 4
      FixedCols = 0
      RowCount = 9
      TabOrder = 0
    end
    object cbFiltro: TComboBox
      Left = 16
      Top = 16
      Width = 150
      Height = 24
      Style = csDropDownList
      Color = clHighlight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 1
      Text = 'Todas'
      StyleElements = [seBorder]
      Items.Strings = (
        'Todas'
        'Zona 1'
        'Zona 2'
        'Zona 3'
        'Zona 4'
        'Zona 5'
        'Zona 6')
    end
    object btnFiltrar: TBitBtn
      Left = 180
      Top = 12
      Width = 110
      Height = 30
      Caption = 'Filtrar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      StyleElements = [seClient, seBorder]
      OnClick = btnFiltrarClick
    end
    object btnAnt: TBitBtn
      Left = 16
      Top = 326
      Width = 130
      Height = 36
      Caption = 'Anterior'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      StyleElements = [seClient, seBorder]
      OnClick = btnAntClick
    end
    object btnSig: TBitBtn
      Left = 158
      Top = 326
      Width = 130
      Height = 36
      Caption = 'Siguiente'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      StyleElements = [seClient, seBorder]
      OnClick = btnSigClick
    end
    object btnAgregar: TBitBtn
      Left = 300
      Top = 326
      Width = 130
      Height = 36
      Caption = 'Agregar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      StyleElements = [seClient, seBorder]
      OnClick = btnAgregarClick
    end
    object btnRonda: TBitBtn
      Left = 16
      Top = 376
      Width = 130
      Height = 36
      Caption = 'Ronda Robot'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      StyleElements = [seClient, seBorder]
      OnClick = btnRondaClick
    end
    object btnImprimir: TBitBtn
      Left = 158
      Top = 376
      Width = 130
      Height = 36
      Caption = 'Imprimir'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      StyleElements = [seClient, seBorder]
      OnClick = btnImprimirClick
    end
    object btnVerEmu: TBitBtn
      Left = 300
      Top = 376
      Width = 130
      Height = 36
      Caption = 'Ver emu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 8
      StyleElements = [seClient, seBorder]
      OnClick = btnVerEmuClick
    end
    object btnVolver: TBitBtn
      Left = 442
      Top = 376
      Width = 130
      Height = 36
      Cancel = True
      Caption = 'Volver'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
      StyleElements = [seClient, seBorder]
      OnClick = btnVolverClick
    end
  end
end
