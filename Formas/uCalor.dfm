object frmCalor: TfrmCalor
  Left = 220
  Top = 140
  BorderStyle = bsSingle
  Caption = 'Mapa de calor'
  ClientHeight = 460
  ClientWidth = 624
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
    Width = 624
    Height = 460
    Align = alClient
    BevelOuter = bvNone
    Color = clDarkblue
    ParentBackground = False
    TabOrder = 0
    ExplicitLeft = -8
    ExplicitTop = -8
    ExplicitWidth = 560
    ExplicitHeight = 420
    object ggPresion: TGauge
      Left = 16
      Top = 284
      Width = 530
      Height = 28
      ForeColor = clRed
      Progress = 0
    end
    object lblMasConc: TLabel
      Left = 16
      Top = 326
      Width = 280
      Height = 19
      Caption = 'M'#225's concurrida: Lectura Silenciosa'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object sgCalor: TStringGrid
      Left = 16
      Top = 16
      Width = 530
      Height = 180
      ColCount = 4
      FixedCols = 0
      RowCount = 7
      TabOrder = 0
      OnDrawCell = sgCalorDrawCell
    end
    object rgPeriodo: TRadioGroup
      Left = 16
      Top = 212
      Width = 300
      Height = 52
      Caption = 'Periodo'
      Color = clHighlight
      Columns = 3
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'HOY'
        'SEMANA'
        'MES')
      ParentBackground = False
      ParentColor = False
      ParentFont = False
      TabOrder = 1
      StyleElements = [seClient, seBorder]
      OnClick = rgPeriodoClick
    end
    object btnVerEmu: TBitBtn
      Left = 16
      Top = 368
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
      Left = 160
      Top = 368
      Width = 130
      Height = 36
      Cancel = True
      Caption = 'Volver'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      StyleElements = [seClient, seBorder]
      OnClick = btnVolverClick
    end
  end
end
