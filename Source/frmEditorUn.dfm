object frmEditor: TfrmEditor
  Left = 379
  Top = 353
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'frmEditor'
  ClientHeight = 386
  ClientWidth = 470
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Bevel1: TBevel
    Left = 8
    Top = 337
    Width = 449
    Height = 2
    Shape = bsBottomLine
  end
  object lblEditThisListBox: TLabel
    Left = 8
    Top = 8
    Width = 93
    Height = 16
    Caption = 'Edit this list box:'
  end
  object lblStringToEdit: TLabel
    Left = 8
    Top = 280
    Width = 77
    Height = 16
    Caption = 'String for edit'
  end
  object lbxEditor: TListBox
    Left = 8
    Top = 32
    Width = 353
    Height = 241
    ItemHeight = 16
    TabOrder = 0
    OnClick = lbxEditorClick
  end
  object btnOK: TButton
    Left = 274
    Top = 346
    Width = 93
    Height = 31
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 371
    Top = 346
    Width = 92
    Height = 31
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 2
  end
  object btnAdd: TButton
    Left = 370
    Top = 34
    Width = 93
    Height = 31
    Caption = 'Add'
    TabOrder = 3
    OnClick = btnAddClick
  end
  object btnDelete: TButton
    Left = 370
    Top = 114
    Width = 93
    Height = 31
    Caption = 'Delete'
    TabOrder = 4
    OnClick = btnDeleteClick
  end
  object btnEdit: TButton
    Left = 370
    Top = 74
    Width = 93
    Height = 31
    Caption = 'Edit'
    TabOrder = 5
    OnClick = btnEditClick
  end
  object edtEditor: TEdit
    Left = 8
    Top = 304
    Width = 321
    Height = 24
    TabOrder = 6
  end
  object btnBrowse: TButton
    Left = 336
    Top = 302
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 7
    OnClick = btnBrowseClick
  end
  object dlgDirOpen: TDirectoryEdit
    Left = 384
    Top = 272
    Width = 57
    Height = 21
    DialogKind = dkWin32
    NumGlyphs = 1
    TabOrder = 8
    Text = 'dlgDirOpen'
    Visible = False
  end
  object dlgOpen: TOpenDialog
    DefaultExt = '*.*'
    Filter = '*.*|*.*'
    Left = 400
    Top = 232
  end
end
