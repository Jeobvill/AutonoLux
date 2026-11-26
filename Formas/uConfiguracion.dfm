object frmConfiguracion: TfrmConfiguracion
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Configuraci'#243'n del sistema'
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
  object lblAyuda: TLabel
    Left = 30
    Top = 20
    Width = 724
    Height = 28
    AutoSize = False
    Caption = 'Seleccione una opci'#243'n y edite el valor'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblNuevo: TLabel
    Left = 30
    Top = 405
    Width = 120
    Height = 24
    AutoSize = False
    Caption = 'Nuevo valor:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lvOpciones: TListView
    Left = 30
    Top = 60
    Width = 724
    Height = 320
    Color = clWhite
    Columns = <
      item
        Caption = 'Opci'#243'n'
        Width = 500
      end
      item
        Caption = 'Valor actual'
        Width = 218
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
  end
  object edNuevoValor: TEdit
    Left = 160
    Top = 402
    Width = 360
    Height = 30
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    MaxLength = 20
    ParentFont = False
    TabOrder = 1
  end
  object btnGuardar: TPanel
    Left = 30
    Top = 448
    Width = 169
    Height = 45
    Cursor = crHandPoint
    Caption = 'Guardar'
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
  object btnCancelar: TPanel
    Left = 215
    Top = 448
    Width = 169
    Height = 45
    Cursor = crHandPoint
    Caption = 'Cancelar'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 3
  end
  object btnFabrica: TPanel
    Left = 400
    Top = 448
    Width = 169
    Height = 45
    Cursor = crHandPoint
    Caption = 'Restaurar f'#225'brica'
    Color = 10569485
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 55039
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 4
  end
  object btnVerEmu: TPanel
    Left = 585
    Top = 448
    Width = 169
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
    TabOrder = 5
  end
end
