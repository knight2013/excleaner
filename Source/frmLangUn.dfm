object frmLang: TfrmLang
  Left = 352
  Top = 347
  BorderStyle = bsDialog
  Caption = 'frmLang'
  ClientHeight = 372
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 120
  TextHeight = 16
  object Bevel1: TBevel
    Left = 8
    Top = 321
    Width = 441
    Height = 2
    Shape = bsBottomLine
  end
  object btnOK: TButton
    Left = 258
    Top = 333
    Width = 93
    Height = 31
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 357
    Top = 333
    Width = 92
    Height = 31
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 1
  end
  object listLang: TListBox
    Left = 8
    Top = 8
    Width = 433
    Height = 305
    ItemHeight = 16
    TabOrder = 2
    OnDblClick = listLangDblClick
  end
end
