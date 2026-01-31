object FLemmixHotkeys: TFLemmixHotkeys
  Left = 300
  Top = 125
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Hotkeys'
  ClientHeight = 553
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblSkill: TLabel
    Left = 345
    Top = 257
    Width = 24
    Height = 13
    Caption = 'Skill:'
    Visible = False
  end
  object lblDuration: TLabel
    Left = 322
    Top = 314
    Width = 114
    Height = 13
    Caption = 'Skip Amount (Frames):'
    Visible = False
  end
  object lblSkip: TLabel
    Left = 344
    Top = 372
    Width = 25
    Height = 13
    Caption = 'Skip:'
    Visible = False
  end
  object lblFindKey: TLabel
    Left = 325
    Top = 204
    Width = 61
    Height = 13
    Alignment = taCenter
    Caption = '<Find Key>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblSkillButton: TLabel
    Left = 368
    Top = 284
    Width = 63
    Height = 13
    Caption = 'Skill Button:'
    Visible = False
  end
  object lblNudgeAmount: TLabel
    Left = 322
    Top = 341
    Width = 119
    Height = 13
    Caption = 'Nudge Amount (Pixels):'
    Visible = False
  end
  object btnFindKey: TButton
    Left = 331
    Top = 137
    Width = 174
    Height = 40
    Caption = 'Find Key'
    TabOrder = 6
    OnClick = btnFindKeyClick
    OnKeyDown = btnFindKeyKeyDown
  end
  object lvHotkeys: TListView
    Left = -3
    Top = -2
    Width = 311
    Height = 547
    Columns = <
      item
        Caption = 'Key'
        MaxWidth = 140
        MinWidth = 140
        Width = 140
      end
      item
        AutoSize = True
        Caption = 'Function'
      end>
    ReadOnly = True
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = lvHotkeysClick
    OnSelectItem = lvHotkeysSelectItem
  end
  object cbFunctions: TComboBox
    Left = 318
    Top = 223
    Width = 197
    Height = 21
    Style = csDropDownList
    DropDownCount = 20
    Enabled = False
    TabOrder = 1
    OnChange = cbFunctionsChange
    Items.Strings = (
      'Nothing'
      'Select Skill'
      'Show Athlete Info'
      'Quit'
      'Max Release Rate'
      'Increase Release Rate'
      'Decrease Release Rate'
      'Min Release Rate'
      'Pause'
      'Nuke'
      'Nuke (Timer Bypass)'
      'Cancel Playback Mode'
      'Save State'
      'Load State'
      'Highlight Lemming'
      'Directional Select Left'
      'Directional Select Right'
      'Select Walking Lemming'
      'Cheat'
      'Time Skip'
      'Special Skip'
      'Fast Forward'
      'Slow Motion'
      'Save Image'
      'Load Replay'
      'Save Replay'
      'Cancel Replay'
      'Edit Replay'
      'Replay Insert Mode'
      'Toggle Music'
      'Toggle Sound'
      'Restart Level'
      'Previous Skill'
      'Next Skill'
      'Release Mouse'
      'Clear Physics Mode'
      'Toggle Shadows'
      'Projection Shadow'
      'Skill Projection Shadow'
      'Show Used Skill Counts'
      'Fall Distance Template'
      'Zoom In'
      'Zoom Out'
      'Cycle Zoom'
      'Hold-To-Scroll')
  end
  object btnSaveClose: TButton
    Left = 331
    Top = 469
    Width = 174
    Height = 40
    Caption = 'Save && Close'
    ModalResult = 1
    TabOrder = 2
    OnClick = btnSaveCloseClick
  end
  object cbSkill: TComboBox
    Left = 377
    Top = 254
    Width = 129
    Height = 21
    Style = csDropDownList
    DropDownCount = 18
    Enabled = False
    TabOrder = 3
    Visible = False
    OnChange = cbSkillChange
    Items.Strings = (
      'Walker'
      'Jumper'
      'Shimmier'
      'Slider'
      'Climber'
      'Swimmer'
      'Floater'
      'Glider'
      'Disarmer'
      'Bomber'
      'Stoner'
      'Blocker'
      'Platformer'
      'Builder'
      'Stacker'
      'Laserer'
      'Basher'
      'Fencer'
      'Miner'
      'Digger'
      'Cloner')
  end
  object cbShowUnassigned: TCheckBox
    Left = 347
    Top = 183
    Width = 145
    Height = 17
    Caption = 'Show Unassigned Keys'
    TabOrder = 4
    OnClick = cbShowUnassignedClick
  end
  object ebSkipDuration: TEdit
    Left = 442
    Top = 311
    Width = 73
    Height = 21
    Enabled = False
    TabOrder = 5
    Visible = False
    OnChange = ebSkipDurationChange
    OnClick = ebClick
  end
  object cbHardcodedNames: TCheckBox
    Left = 347
    Top = 434
    Width = 145
    Height = 17
    Caption = 'Use Hardcoded Names'
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 7
    Visible = False
    OnClick = cbHardcodedNamesClick
  end
  object cbHoldKey: TCheckBox
    Left = 382
    Top = 409
    Width = 97
    Height = 17
    Caption = 'Hold Key'
    TabOrder = 8
    Visible = False
    OnClick = cbHoldKeyClick
  end
  object cbSpecialSkip: TComboBox
    Left = 375
    Top = 369
    Width = 129
    Height = 21
    Style = csDropDownList
    DropDownCount = 10
    Enabled = False
    TabOrder = 9
    Visible = False
    OnChange = cbSpecialSkipChange
    Items.Strings = (
      'Previous Assignment'
      'Next Shrugger'
      'Highlit State Change')
  end
  object btnFunctionalLayout: TButton
    Left = 331
    Top = 39
    Width = 174
    Height = 30
    Caption = 'Set to Functional Layout'
    TabOrder = 10
    OnClick = btnFunctionalLayoutClick
  end
  object btnTraditionalLayout: TButton
    Left = 331
    Top = 70
    Width = 174
    Height = 30
    Caption = 'Set to Traditional Layout'
    TabOrder = 11
    OnClick = btnTraditionalLayoutClick
  end
  object btnAdvancedLayout: TButton
    Left = 331
    Top = 101
    Width = 174
    Height = 30
    Caption = 'Set to Advanced Layout'
    TabOrder = 13
    OnClick = btnAdvancedLayoutClick
  end
  object btnClearAllKeys: TButton
    Left = 331
    Top = 5
    Width = 174
    Height = 28
    Caption = 'Clear All Keys'
    TabOrder = 12
    OnClick = btnClearAllKeysClick
  end
  object btnCancel: TBitBtn
    Left = 418
    Top = 515
    Width = 87
    Height = 30
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 14
    OnClick = btnCancelClick
  end
  object btnReset: TBitBtn
    Left = 331
    Top = 515
    Width = 81
    Height = 30
    Hint = 'Restore previously saved layout'
    Caption = 'Restore'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 15
    OnClick = btnResetClick
  end
  object seSkillButton: TSpinEdit
    Left = 436
    Top = 281
    Width = 41
    Height = 22
    Enabled = False
    MaxValue = 14
    MinValue = 1
    TabOrder = 16
    Value = 1
    Visible = False
  end
  object ebNudgeAmount: TEdit
    Left = 447
    Top = 338
    Width = 68
    Height = 21
    Enabled = False
    TabOrder = 17
    Visible = False
    OnClick = ebClick
  end
end
