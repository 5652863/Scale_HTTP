object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Simple Scale HTTP Server'
  ClientHeight = 241
  ClientWidth = 338
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -22
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 27
  object Button1: TButton
    Left = 80
    Top = 64
    Width = 150
    Height = 50
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Caption = 'DirectTest'
    TabOrder = 0
    OnClick = Button1Click
  end
  object simpleServer: TclSimpleHttpServer
    ServerName = 'Clever Internet Suite HTTP service'
    Left = 208
    Top = 128
  end
end
