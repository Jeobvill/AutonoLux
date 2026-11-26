object frmMonitor: TfrmMonitor
  Left = 200
  Top = 120
  BorderStyle = bsSingle
  Caption = 'Monitor de zonas en tiempo real'
  ClientHeight = 400
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object pnlPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 400
    Align = alClient
    BevelOuter = bvNone
    Color = clDarkblue
    ParentBackground = False
    TabOrder = 0
    object shSemaforo: TShape
      Left = 570
      Top = 16
      Width = 100
      Height = 100
      Brush.Color = clLime
      Shape = stCircle
    end
    object lblAforo: TLabel
      Left = 570
      Top = 128
      Width = 100
      Height = 19
      Caption = 'Aforo: 28 %'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblZonasOcup: TLabel
      Left = 16
      Top = 216
      Width = 120
      Height = 16
      Caption = 'Zonas ocupadas: 4/6'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblPersonas: TLabel
      Left = 16
      Top = 246
      Width = 130
      Height = 16
      Caption = 'Personas en zonas: 17'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblTemp: TLabel
      Left = 16
      Top = 276
      Width = 116
      Height = 16
      Caption = 'Temperatura: 32 '#176'C'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblEstadoTemp: TLabel
      Left = 230
      Top = 276
      Width = 54
      Height = 16
      Caption = 'NORMAL'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object sgZonas: TStringGrid
      Left = 16
      Top = 16
      Width = 520
      Height = 180
      ColCount = 6
      FixedCols = 0
      RowCount = 7
      TabOrder = 0
    end
    object btnMapa: TBitBtn
      Left = 16
      Top = 340
      Width = 170
      Height = 36
      Caption = 'Mapa biblioteca'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      StyleElements = [seClient, seBorder]
      OnClick = btnMapaClick
    end
    object btnVerEmu: TBitBtn
      Left = 200
      Top = 340
      Width = 130
      Height = 36
      Caption = 'Ver emu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      StyleElements = [seClient, seBorder]
      OnClick = btnVerEmuClick
    end
    object btnVolver: TBitBtn
      Left = 344
      Top = 340
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
      TabOrder = 3
      StyleElements = [seClient, seBorder]
      OnClick = btnVolverClick
    end
  end
  object tmrRefresh: TTimer
    Interval = 500
    OnTimer = tmrRefreshTimer
    Left = 620
    Top = 340
  end
end
