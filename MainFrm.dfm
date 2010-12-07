object MainForm: TMainForm
  Left = 571
  Top = 339
  Width = 842
  Height = 446
  Caption = 'Run Keys Monitor - (Arash Partow 2006)'
  Color = clBtnFace
  Constraints.MinHeight = 446
  Constraints.MinWidth = 842
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  DesignSize = (
    834
    412)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 17
    Top = 48
    Width = 800
    Height = 9
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object Label1: TLabel
    Left = 19
    Top = 63
    Width = 111
    Height = 13
    Caption = 'Monitored registry keys:'
  end
  object Label2: TLabel
    Left = 16
    Top = 200
    Width = 55
    Height = 13
    Caption = 'Access log:'
  end
  object StartButton: TButton
    Left = 17
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = StartButtonClick
  end
  object CloseButton: TButton
    Left = 744
    Top = 376
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 1
    OnClick = CloseButtonClick
  end
  object RegistryKeyList: TListBox
    Left = 17
    Top = 81
    Width = 800
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 2
  end
  object AccessLog: TMemo
    Left = 17
    Top = 216
    Width = 800
    Height = 145
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
    WordWrap = False
  end
end
