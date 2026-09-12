unit GameBaseSkillPanel;

// TODO - Hi-Res-Only Panel: CE-specific gfx are currently not upscaled in low res
// TODO - Hi-Res-Only Panel: We need to upscale the low-res lemming animation frames
// TODO - Hi-Res-Only Panel: Show hotkey labels on panel buttons
// TODO - Hi-Res-Only Panel: Add clickable talisman info button

interface

uses
  System.Types, System.StrUtils, Graphics,
  Classes, Controls, GR32, GR32_Image, GR32_Layers, GR32_Resamplers,
  GameWindowInterface,
  LemAnimationSet, LemMetaAnimation, LemNeoLevelPack,
  LemCore, LemLemming, LemGame, LemLevel,
  LemGadgets,
  NeoLemmixCEResources,
  SharedGlobals;

type
  TMinimapClickEvent = procedure(Sender: TObject; const P: TPoint) of object;

type
  TPanelButtonArray = array of TSkillPanelButton;

type
  TFontBitmapArray = array['0'..'9', 0..1] of TBitmap32;

  TBaseSkillPanel = class(TCustomControl)
  private
    fGame                 : TLemmingGame;

    // Refactor ====================
    fPanelButtons         : TBitmap32; // for storing panel buttons & button text
    fPanelIcons           : TBitmap32; // for storing all panel icons
    // ============================

    fShowUsedSkills       : Boolean;
    fRRIsPressed          : Boolean;

    fSetInitialZoom       : Boolean;

    fRectColor            : TColor32;
    fSelectDx             : Integer;
    fIsBlinkFrame         : Boolean;
    fOnMinimapClick       : TMinimapClickEvent; // event handler for minimap

    fCombineHueShift      : Single;

    function CheckFrameSkip: Integer; // Checks the duration since the last click on the panel.

    procedure LoadPanelIcons;
    procedure LoadSkillIcons;
    procedure LoadSkillFont;

    function GetLevel: TLevel;
    function GetZoom: Integer;
    procedure SetZoom(NewZoom: Integer);
    function GetMaxZoom: Integer;

    procedure CombineShift(F: TColor32; var B: TColor32; M: Cardinal);
    procedure SetShowUsedSkills(const Value: Boolean);
  protected
    fGameWindow           : IGameWindow;
    fButtonRects          : array[TSkillPanelButton] of TRect;

    fImage                : TImage32;  // panel image to be displayed
    fOriginal             : TBitmap32; // original panel image
    fMinimap              : TBitmap32; // full minimap image
    fMinimapImage         : TImage32;  // minimap to be displayed
    fMinimapTemp          : TBitmap32; // temp image, to create fMinimapImage from fMinimap

    fMinimapScrollFreeze  : Boolean;
    fLastClickFrameskip   : Cardinal;

    fSkillFont            : TFontBitmapArray;
    fSkillFontInvert      : TFontBitmapArray;
    fSkillOvercount       : array[100..MAXIMUM_SI] of TBitmap32;
    fSkillCountErase      : TBitmap32;
    fSkillCountEraseInvert: TBitmap32;
    fSkillLock            : TBitmap32;
    fSkillInfinite        : TBitmap32;
    fSkillSelected        : TBitmap32;
    fSkillIcons           : array[Low(TSkillPanelButton)..LAST_SKILL_BUTTON] of TBitmap32;

    fHighlitSkill         : TSkillPanelButton;
    fLastHighlitSkill     : TSkillPanelButton; // to avoid sounds when shouldn't be played

    fLastDrawnStr         : String;
    fNewDrawStr           : String;
    fButtonHint           : String;

    // Global stuff
    property Level: TLevel read GetLevel;
    property Game: TLemmingGame read fGame;

    function PanelWidth: Integer; virtual; abstract;
    function PanelHeight: Integer; virtual; abstract;

    // Helper functions for positioning
    function FirstButtonRect: TRect; virtual;
    function ButtonRect(Index: Integer): TRect;
    function HalfButtonRect(Index: Integer; IsUpper: Boolean): TRect;
    function MinimapRect: TRect; virtual; abstract;
    function MinimapWidth: Integer;
    function MinimapHeight: Integer;
    function ReplayIconRect: TRect; virtual; abstract;
    function HatchIconRect: TRect; virtual; abstract;
    function AliveIconRect: TRect; virtual; abstract;
    function ExitIconRect: TRect; virtual; abstract;
    function TimeIconRect: TRect; virtual; abstract;

    function FirstSkillButtonIndex: Integer; virtual;
    function LastSkillButtonIndex: Integer; virtual;

    // Drawing routines for the buttons and minimap
    procedure ReadBitmapFromStyle;
    function GetButtonList: TPanelButtonArray; virtual; abstract;
    procedure DrawBlankPanel(NumButtons: Integer);
    procedure AddButtonImage(ButtonName: string; Index: Integer);
    procedure ResizeMinimapRegion(MinimapRegion: TBitmap32); virtual; abstract;
    procedure SetButtonRects;
    procedure SetSkillIcons;
    procedure DrawHighlight(aButton: TSkillPanelButton); virtual;
    procedure DrawSkillCount(aButton: TSkillPanelButton; aNumber: Integer);
    procedure RemoveHighlight(aButton: TSkillPanelButton); virtual;

    // Drawing routines for the info string at the top
    function GetCursorInfoString: String;
    function GetHatchCountString: String;
    function GetLemsAliveString: String;
    function GetLemsSavedString: String;
    function GetTimeString: String;

    procedure DrawCursorInfo;
    procedure DrawPanelIcon(Index, X, Y: Integer);
    procedure DrawReplayIcon;
    procedure DrawHatchInfo;
    procedure DrawLemsAliveInfo;
    procedure DrawLemsSavedInfo;
    procedure DrawTimeInfo;

    function GetLemReplayTaskString(L: TLemming): String;
    function GetSkillString(L: TLemming): String;
    function GetPickupString(P: TGadget): String;

    // Event handlers for user interaction and related routines.
    function MousePos(X, Y: Integer): TPoint;
    function MousePosMinimap(X, Y: Integer): TPoint;
    procedure SetMinimapScrollFreeze(aValue: Boolean);

    procedure ImgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;
    procedure ImgMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;
    procedure ImgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;

    procedure MinimapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;
    procedure MinimapMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;
    procedure MinimapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;

    function GetSpawnIntervalValue(aSI: Integer): Integer; // Returns the SI or the equivalent RR, depending on user's settings

  public
    constructor Create(aOwner: TComponent); override;
    constructor CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow); virtual;
    destructor Destroy; override;

    procedure PrepareForGame;
    procedure ClearInfo;
    procedure RefreshInfo;
    procedure SetCursor(aCursor: TCursor);
    procedure SetOnMinimapClick(const Value: TMinimapClickEvent);
    procedure SetGame(const Value: TLemmingGame);

    procedure ResetMinimapPosition;

    property Image: TImage32 read fImage;

    procedure DrawButtonSelector(aButton: TSkillPanelButton; Highlight: Boolean);
    procedure DrawMinimapMessage(const GraphicName: string; out MessageImage: TBitmap32);
    procedure DrawMinimap; virtual;

    property Minimap: TBitmap32 read fMinimap;
    property MinimapScrollFreeze: Boolean read fMinimapScrollFreeze write SetMinimapScrollFreeze;

    property Zoom: Integer read GetZoom write SetZoom;
    property MaxZoom: Integer read GetMaxZoom;

    property FrameSkip: Integer read CheckFrameSkip;
    property SkillPanelSelectDx: Integer read fSelectDx write fSelectDx;
    property ShowUsedSkills: Boolean read fShowUsedSkills write SetShowUsedSkills;
    property RRIsPressed: Boolean read fRRIsPressed write fRRIsPressed;
    property ButtonHint: String read fButtonHint write fButtonHint;
    procedure GetButtonHints(aButton: TSkillPanelButton);
    function IsReplaying: Boolean;

    function CursorOverSkillButton(out Button: TSkillPanelButton): Boolean;
    function CursorOverPanelItem: Boolean;
    function CursorOverIcon(aIconRect: TRect): Boolean;
    function CursorOverMinimap: Boolean;
  end;

  procedure ModString(var aString: String; const aNew: String; const aStart: Integer);

const
  NUM_FONT_CHARS = 51;

const
  // WARNING: The order of the strings has to correspond to the one
  //          of TSkillPanelButton in LemCore.pas!
  // As skill icons are dealt with separately, we use a placeholder here
  BUTTON_TO_STRING: array[TSkillPanelButton] of string = (
    'empty_slot', 'empty_slot', 'empty_slot', 'empty_slot',
    'empty_slot', 'empty_slot', 'empty_slot', 'empty_slot',
    'empty_slot', 'empty_slot', 'empty_slot', 'empty_slot',
    'empty_slot', 'empty_slot', 'empty_slot', 'empty_slot',
    'empty_slot', 'empty_slot', 'empty_slot', 'empty_slot',
    'empty_slot', {Skills end here}

    'empty_slot', 'icon_rr_plus', 'icon_rr_minus', 'icon_pause',
    'icon_nuke', 'icon_ff', 'icon_restart', 'icon_frameskip',
    'icon_directional', 'icon_pv_replay',

    // These ones are placeholders - they're the bottom half of splits
    'icon_frameskip', 'icon_directional', 'icon_pv_replay'
    );


implementation

uses
  SysUtils, Math, Windows, UMisc, PngInterface,
  GameControl, GameSound,
  LemTypes, LemReplay, LemStrings, LemNeoTheme,
  LemmixHotkeys;

procedure ModString(var aString: String; const aNew: String; const aStart: Integer);
var
  i: Integer;
begin
  {  Classes, Controls, GR32, GR32_Image, GR32_Layers,}
  for i := 1 to Length(aNew) do
    aString[aStart + i - 1] := aNew[i];
end;


constructor TBaseSkillPanel.CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow);
begin
  Create(aOwner);
  fGameWindow := aGameWindow;
end;

procedure TBaseSkillPanel.GetButtonHints(aButton: TSkillPanelButton);
begin
  ButtonHint := '';

  if CursorOverMinimap then
                          ButtonHint := 'MINIMAP'
  else if CursorOverIcon(HatchIconRect) then
                          ButtonHint := 'TO SPAWN'
  else if CursorOverIcon(AliveIconRect) then
                          ButtonHint := 'AVAILABLE'
  else if CursorOverIcon(TimeIconRect)then
                          ButtonHint := 'TIMER'
  else if CursorOverIcon(ExitIconRect) then
  begin
    if (Game.LemmingsSaved < Level.Info.RescueCount) then
                   ButtonHint := 'TO SAVE'
    else
                   ButtonHint := 'SAVED';
  end else if CursorOverIcon(ReplayIconRect) then
  begin
    if Game.ReplayingNoRR[fGameWindow.GameSpeed = gspPause] then
                          ButtonHint := 'STOP REPLAY'
    else if GameParams.PlaybackModeActive then
                          ButtonHint := 'END PLAYBACK'
    else
                          ButtonHint := '';
  end else if CursorOverSkillButton(aButton) then
  begin
    case aButton of
      spbNone:            ButtonHint := '';
      spbSlower:          ButtonHint := 'SLOWER';
      spbFaster:          ButtonHint := 'FASTER';
      spbPause:           ButtonHint := 'PAUSE';
      spbFastForward:
//        if GameParams.TurboFF then
//                   ButtonHint := 'TURBO-FF'
//        else
                          ButtonHint := 'FAST-FORWARD';
      spbRestart:         ButtonHint := 'RESTART';
      spbNuke:            ButtonHint := 'NUKE';
      spbBackOneFrame:    ButtonHint := 'FRAMESTEP-';
      spbForwardOneFrame: ButtonHint := 'FRAMESTEP+';
      spbDirLeft:         ButtonHint := 'SELECT LEFT';
      spbDirRight:        ButtonHint := 'SELECT RIGHT';
      spbPhysicsView:     ButtonHint := 'PHYSICS VIEW';
      spbLoadReplay:      ButtonHint := 'LOAD-EDIT-SAVE';
      else                ButtonHint := Uppercase(SKILL_NAMES[aButton]);
    end;
  end;
end;

function TBaseSkillPanel.CursorOverIcon(aIconRect: TRect): Boolean;
var
  CursorPos: TPoint;
  P: TPoint;
begin
  Result := False;
  CursorPos := Mouse.CursorPos;
  P := Image.ControlToBitmap(Image.ScreenToClient(CursorPos));

  if PtInRect(aIconRect, P) then
  begin
    Result := True;
    Exit;
  end;
end;

function TBaseSkillPanel.CursorOverSkillButton(out Button: TSkillPanelButton): Boolean;
var
  CursorPos: TPoint;
  P: TPoint;
  i: TSkillPanelButton;
begin
  Result := False;
  Button := spbNone; // Initialize Button to a default value

  CursorPos := Mouse.CursorPos;
  P := Image.ControlToBitmap(Image.ScreenToClient(CursorPos));

  for i := Low(fButtonRects) to High(fButtonRects) do
  begin
    if PtInRect(fButtonRects[i], P) then
    begin
      Result := True;
      Button := TSkillPanelButton(i); // Assign the button value
      Exit;
    end;
  end;

  // If no button found, set Button to spbNone
  Button := spbNone;
end;

function TBaseSkillPanel.CursorOverMinimap: Boolean;
var
  CursorPos: TPoint;
  P: TPoint;
begin
  Result := False;
  CursorPos := Mouse.CursorPos;
  P := Image.ControlToBitmap(Image.ScreenToClient(CursorPos));

  if PtInRect(MinimapRect, P) then
  begin
    Result := True;
    Exit;
  end;
end;

function TBaseSkillPanel.CursorOverPanelItem: Boolean;
var
  aButton: TSkillPanelButton;
begin
  Result := False or CursorOverSkillButton(aButton)
                  or CursorOverIcon(ReplayIconRect)
                  or CursorOverIcon(HatchIconRect)
                  or CursorOverIcon(AliveIconRect)
                  or CursorOverIcon(ExitIconRect)
                  or CursorOverIcon(TimeIconRect)
                  or CursorOverMinimap;
end;

function TBaseSkillPanel.IsReplaying: Boolean;
begin
  Result := False or Game.ReplayingNoRR[fGameWindow.GameSpeed = gspPause];
end;

constructor TBaseSkillPanel.Create(aOwner: TComponent);
var
  c: Char;
  i: Integer;
  Button: TSkillPanelButton;
begin
  inherited Create(aOwner);

  // Some general settings for the panel
  Color := $000000;
  ParentBackground := False;

  fLastClickFrameskip := GetTickCount;

  // Initialize images
  fImage := TImage32.Create(Self);
  fImage.Parent := Self;
  fImage.RepaintMode := rmOptimizer;
  fImage.ScaleMode := smScale;

  fMinimapImage := TImage32.Create(Self);
  fMinimapImage.Parent := Self;
  fMinimapImage.RepaintMode := rmOptimizer;
  fMinimapImage.ScaleMode := smScale;
  fMinimapImage.BitmapAlign := baCustom;

  fPanelButtons := TBitmap32.Create;
  fPanelButtons.DrawMode := dmBlend;
  fPanelButtons.CombineMode := cmMerge;

  fPanelIcons := TBitmap32.Create;
  fPanelIcons.DrawMode := dmBlend;
  fPanelIcons.CombineMode := cmMerge;

  fMinimapTemp := TBitmap32.Create;
  fMinimap := TBitmap32.Create;

  fOriginal := TBitmap32.Create;

  // Initialize event handlers
  fImage.OnMouseDown := ImgMouseDown;
  fImage.OnMouseMove := ImgMouseMove;
  fImage.OnMouseUp := ImgMouseUp;

  fMinimapImage.OnMouseDown := MinimapMouseDown;
  fMinimapImage.OnMouseMove := MinimapMouseMove;
  fMinimapImage.OnMouseUp := MinimapMouseUp;

  for Button := Low(TSkillPanelButton) to LAST_SKILL_BUTTON do
  begin
    fSkillIcons[Button] := TBitmap32.Create;
    fSkillIcons[Button].DrawMode := dmBlend;
    fSkillIcons[Button].CombineMode := cmMerge;
  end;

  for c := '0' to '9' do
    for i := 0 to 1 do
    begin
      fSkillFont[c, i] := TBitmap32.Create;
      fSkillFont[c, i].DrawMode := dmBlend;
      fSkillFont[c, i].CombineMode := cmMerge;

      fSkillFontInvert[c, i] := TBitmap32.Create;
      fSkillFontInvert[c, i].DrawMode := dmBlend;
      fSkillFontInvert[c, i].CombineMode := cmMerge;
    end;

  fSkillInfinite := TBitmap32.Create;
  fSkillInfinite.DrawMode := dmBlend;
  fSkillInfinite.CombineMode := cmMerge;

  fSkillSelected := TBitmap32.Create;
  fSkillSelected.DrawMode := dmBlend;
  fSkillSelected.CombineMode := cmMerge;

  fSkillCountErase := TBitmap32.Create;
  fSkillCountErase.DrawMode := dmBlend;
  fSkillCountErase.CombineMode := cmMerge;

  fSkillCountEraseInvert := TBitmap32.Create;
  fSkillCountEraseInvert.DrawMode := dmBlend;
  fSkillCountEraseInvert.CombineMode := cmMerge;

  fSkillLock := TBitmap32.Create;
  fSkillLock.DrawMode := dmBlend;
  fSkillLock.CombineMode := cmMerge;

  fRectColor := $FFF0D0D0;
  fHighlitSkill := spbNone;
  fLastHighlitSkill := spbNone;

  for i := 100 to MAXIMUM_SI do                    
    fSkillOvercount[i] := TBitmap32.Create;

  fRRIsPressed := False;
end;

destructor TBaseSkillPanel.Destroy;
var
  c: Char;
  i: Integer;
  Button: TSkillPanelButton;
begin
  for c := '0' to '9' do
    for i := 0 to 1 do
    begin
      fSkillFont[c, i].Free;
      fSkillFontInvert[c, i].Free;
    end;

  for Button := Low(TSkillPanelButton) to LAST_SKILL_BUTTON do
    fSkillIcons[Button].Free;

  for i := 100 to MAXIMUM_SI do
    fSkillOvercount[i].Free;

  fSkillInfinite.Free;
  fSkillSelected.Free;
  fSkillCountErase.Free;
  fSkillCountEraseInvert.Free;
  fSkillLock.Free;

  fImage.Free;
  fOriginal.Free;
  fMinimapTemp.Free;
  fMinimap.Free;
  fMinimapImage.Free;
  fPanelButtons.Free;
  fPanelIcons.Free;
  inherited;
end;

{-----------------------------------------
    Positions of buttons, ...
-----------------------------------------}
function TBaseSkillPanel.FirstButtonRect: TRect;
begin
  Result := Rect(2, 32, 30, 76);
end;

function TBaseSkillPanel.ButtonRect(Index: Integer): TRect;
begin
  Result := FirstButtonRect;
  OffsetRect(Result, Index * 32, 0);
end;

function TBaseSkillPanel.HalfButtonRect(Index: Integer; IsUpper: Boolean): TRect;
begin
  Result := FirstButtonRect;
  OffsetRect(Result, Index * 32, 0);
  if IsUpper then
    Result.Bottom := (Result.Top + Result.Bottom) div 2 - 2
  else
    Result.Top := (Result.Top + Result.Bottom) div 2 + 2;
end;

function TBaseSkillPanel.FirstSkillButtonIndex: Integer;
begin
  Result := 2;
end;

function TBaseSkillPanel.LastSkillButtonIndex: Integer;
begin
  Result := (FirstSkillButtonIndex + MAX_SKILL_TYPES_PER_LEVEL) - 1;
end;

function TBaseSkillPanel.MinimapWidth: Integer;
begin
  Result := MinimapRect.Right - MinimapRect.Left;
end;

function TBaseSkillPanel.MinimapHeight: Integer;
begin
  Result := MinimapRect.Bottom - MinimapRect.Top;
end;


{-----------------------------------------------
  Draw the initial skill panel and the minimap
-----------------------------------------------}
procedure GetGraphic(aName: String; aDst: TBitmap32);
var
  MaskColor: TColor32;
  Name, SrcFile, SrcFileHr, SrcFileHrMask, EmbeddedName, PanelDir: String;
  Target: TNeoLevelGroup;
  UpscaleSettings: TUpscaleSettings;
begin
  // 1) Try override system first
  if GameParams.HighResolution then
  begin
    EmbeddedName := UpperCase(aName) + '_HR_PNG';
    PanelDir := SFGraphicsPanelHighRes;
  end else begin
    EmbeddedName := UpperCase(aName) + '_PNG';
    PanelDir := SFGraphicsPanel;
  end;

  Name := aName + '.png';

  if LoadGraphicWithOverrides(PanelDir, Name, EmbeddedName, aDst) then
  begin
    aDst.DrawMode := dmBlend;
    Exit;
  end;

  // 2) Fallback to legacy logic
  Target := GameParams.CurrentLevel.Group;

  SrcFile := Target.Path + Name;
  if GameParams.HighResolution then
  begin
    SrcFileHr := ChangeFileExt(SrcFile, '-hr.png');
    SrcFileHrMask := ChangeFileExt(SrcFile, '_mask-hr.png');
  end;

  while not (FileExists(SrcFile) or Target.IsBasePack or (Target.Parent = nil)) do
  begin
    Target := Target.Parent;
    SrcFile := Target.Path + Name;
    if GameParams.HighResolution then
    begin
      SrcFileHr := ChangeFileExt(SrcFile, '-hr.png');
      SrcFileHrMask := ChangeFileExt(SrcFile, '_mask-hr.png');
    end;
  end;

  if not FileExists(SrcFile) then
  begin
    SrcFile := AppPath + SFGraphicsPanel + Name;
    if GameParams.HighResolution then
    begin
      SrcFileHr := AppPath + SFGraphicsPanelHighRes + Name;
      SrcFileHrMask := AppPath + SFGraphicsPanelHighRes + ChangeFileExt(Name, '_mask.png');
    end;
  end;

  MaskColor := GameParams.Renderer.Theme.Colors[MASK_COLOR];

  if GameParams.HighResolution then
  begin
    if FileExists(SrcFileHr) then
    begin
      TPngInterface.LoadPngFile(SrcFileHr, aDst);
      TPngInterface.MaskImageFromFile(aDst, SrcFileHrMask, MaskColor);
    end else begin
      TPngInterface.LoadPngFile(SrcFile, aDst);
      TPngInterface.MaskImageFromFile(aDst, ChangeFileExt(SrcFile, '_mask.png'), MaskColor);

      UpscaleSettings.Mode := umPixelArt;
      UpscaleSettings.LeftSide := uebTransparent;
      UpscaleSettings.TopSide := uebTransparent;
      UpscaleSettings.RightSide := uebTransparent;
      UpscaleSettings.BottomSide := uebTransparent;

      Upscale(aDst, UpscaleSettings);
    end;
  end else begin
    TPngInterface.LoadPngFile(SrcFile, aDst);
    TPngInterface.MaskImageFromFile(aDst, ChangeFileExt(SrcFile, '_mask.png'), MaskColor);

    UpscaleSettings.Mode := umNearest;
    UpscaleSettings.LeftSide := uebTransparent;
    UpscaleSettings.TopSide := uebTransparent;
    UpscaleSettings.RightSide := uebTransparent;
    UpscaleSettings.BottomSide := uebTransparent;

    Upscale(aDst, UpscaleSettings);
  end;
end;

// Pave the area of NumButtons buttons with the blank panel
procedure TBaseSkillPanel.DrawBlankPanel(NumButtons: Integer);
var
  i: Integer;
  BlankPanel: TBitmap32;
  SrcRect, DstRect: TRect;
  SrcWidth: Integer;
begin
  BlankPanel := TBitmap32.Create;
  BlankPanel.DrawMode := dmBlend;
  BlankPanel.CombineMode := cmMerge;
  GetGraphic('skill_panels', BlankPanel);

  SrcRect := BlankPanel.BoundsRect;
  SrcWidth := SrcRect.Right - SrcRect.Left;
  DstRect := BlankPanel.BoundsRect;
  OffsetRect(DstRect, FirstButtonRect.Left, FirstButtonRect.Top);

  // Draw full panels
  for i := 1 to (NumButtons * 32 - 1) div SrcWidth do
  begin
    BlankPanel.DrawTo(fOriginal, DstRect, SrcRect);
    OffsetRect(DstRect, SrcWidth, 0);
  end;

  // Draw partial panel at the end
  DstRect.Right := ButtonRect(NumButtons - 1).Right + 2;
  DstRect.Bottom := ButtonRect(NumButtons - 1).Bottom + 2;
  SrcRect.Right := SrcRect.Left - DstRect.Left + DstRect.Right;
  SrcRect.Bottom := SrcRect.Top - DstRect.Top + DstRect.Bottom;
  BlankPanel.DrawTo(fOriginal, DstRect, SrcRect);

  BlankPanel.Free;
end;

procedure TBaseSkillPanel.AddButtonImage(ButtonName: string; Index: Integer);
begin
  if (Index >= FirstSkillButtonIndex) and (Index <= LastSkillButtonIndex) then Exit; // otherwise, "empty_slot.png" placeholder causes some graphical glitches
  GetGraphic(ButtonName, fPanelButtons);
  fPanelButtons.DrawTo(fOriginal, ButtonRect(Index).Left, ButtonRect(Index).Top);
end;

procedure TBaseSkillPanel.LoadPanelIcons;
var
  Width: Integer;

  procedure AddGraphic(const Name: String);
  var
    Bitmap: TBitmap32;
    Combined: TBitmap32;
  begin
    Bitmap := TBitmap32.Create;
    Bitmap.DrawMode := dmBlend;
    try
      GetGraphic(Name, Bitmap);

      Combined := TBitmap32.Create;
      try
        Width := fPanelIcons.Width;
        Combined.SetSize(Width + Bitmap.Width, Max(fPanelIcons.Height, Bitmap.Height));
        fPanelIcons.DrawTo(Combined, 0, 0);

        Bitmap.DrawTo(Combined, Width, 0);
        fPanelIcons.Assign(Combined);
      finally
        Combined.Free;
      end;
    finally
      Bitmap.Free;
    end;
  end;
begin
  fPanelIcons := TBitmap32.Create;

  AddGraphic('panel_icons');
  AddGraphic('panel_chars');
end;

procedure TBaseSkillPanel.LoadSkillIcons;
const
  PANEL_FALLBACK_BRICK_COLOR = $FF00B000;
var
  BrickColor: TColor32;
  Button: TSkillPanelButton;
  TempBmp: TBitmap32;
  x, y: Integer;

  procedure DrawAnimationFrame(dst: TBitmap32; aAnimationIndex: Integer; aFrame: Integer; footX, footY: Integer);
  var
    Ani: TBaseAnimationSet;
    Meta: TMetaLemmingAnimation;
    SrcRect: TRect;
    OldDrawMode: TDrawMode;
  begin
    Ani := GameParams.Renderer.LemmingAnimations;
    Meta := Ani.MetaLemmingAnimations[aAnimationIndex];

    SrcRect := Ani.LemmingAnimations[aAnimationIndex].BoundsRect;
    SrcRect.Bottom := SrcRect.Bottom div Meta.FrameCount;
    SrcRect.Offset(0, SrcRect.Height * aFrame);

    OldDrawMode := Ani.LemmingAnimations[aAnimationIndex].DrawMode;
    Ani.LemmingAnimations[aAnimationIndex].DrawMode := dmBlend;
    Ani.LemmingAnimations[aAnimationIndex].DrawTo(dst, footX * ResMod - Meta.FootX, footY * ResMod - Meta.FootY, SrcRect);
    Ani.LemmingAnimations[aAnimationIndex].DrawMode := OldDrawMode;
  end;

  procedure DrawAnimationFrameResized(dst: TBitmap32; aAnimationIndex: Integer; aFrame: Integer; dstRect: TRect);
  var
    Ani: TBaseAnimationSet;
    Meta: TMetaLemmingAnimation;
    SrcRect: TRect;
    OldDrawMode: TDrawMode;
  begin
    if GameParams.HighResolution then
    begin
      dstRect.Left := dstRect.Left * 2 + 1;
      dstRect.Top := dstRect.Top * 2;
      dstRect.Right := dstRect.Right * 2 + 1;
      dstRect.Bottom := dstRect.Bottom * 2;
    end;

    Ani := GameParams.Renderer.LemmingAnimations;
    Meta := Ani.MetaLemmingAnimations[aAnimationIndex];

    SrcRect := Ani.LemmingAnimations[aAnimationIndex].BoundsRect;
    SrcRect.Bottom := SrcRect.Bottom div Meta.FrameCount;
    SrcRect.Offset(0, SrcRect.Height * aFrame);

    OldDrawMode := Ani.LemmingAnimations[aAnimationIndex].DrawMode;
    Ani.LemmingAnimations[aAnimationIndex].DrawMode := dmBlend;
    Ani.LemmingAnimations[aAnimationIndex].DrawTo(dst, dstRect, SrcRect);
    Ani.LemmingAnimations[aAnimationIndex].DrawMode := OldDrawMode;
  end;

  procedure DrawBrick(dst: TBitmap32; X, Y: Integer; W: Integer = 2);
  var
    oX: Integer;
  begin
    for oX := 0 to W-1 do
      if GameParams.HighResolution then
      begin
        dst.PixelS[(X + oX) * ResMod, Y * ResMod] := BrickColor;
        dst.PixelS[(X + oX) * ResMod + 1, Y * ResMod] := BrickColor;
        dst.PixelS[(X + oX) * ResMod, Y * ResMod + 1] := BrickColor;
        dst.PixelS[(X + oX) * ResMod + 1, Y * ResMod + 1] := BrickColor;
      end else
        dst.PixelS[X + oX, Y] := BrickColor;
  end;

  procedure Outline(dst: TBitmap32; isRecursive: Boolean = False);
  var
    x, y: Integer;
    oX, oY: Integer;
    ThisAlpha, MaxAlpha: Byte;
    OutlineColor: TColor32;
  begin
    TempBmp.Assign(dst);
    dst.Clear(0);
    TempBmp.WrapMode := wmClamp;
    TempBmp.OuterColor := $00000000;

    if GameParams.Renderer.Theme.DoesColorExist('PANEL_OUTLINE') then
      OutlineColor := GameParams.Renderer.Theme.Colors['PANEL_OUTLINE'] and $FFFFFF
    else
      OutlineColor := $000000;

    for y := 0 to TempBmp.Height-1 do
      for x := 0 to TempBmp.Width-1 do
      begin
        MaxAlpha := 0;
        for oY := -1 to 1 do
          for oX := -1 to 1 do
          begin
            if Abs(oY) + Abs(oX) <> 1 then
              Continue;
            ThisAlpha := (TempBmp.PixelS[x + oX, y + oY] and $FF000000) shr 24;
            if ThisAlpha > MaxAlpha then
              MaxAlpha := ThisAlpha;
          end;
        dst[x, y] := (MaxAlpha shl 24) or OutlineColor;
      end;

    TempBmp.DrawTo(dst);

    if GameParams.HighResolution and not isRecursive then
      Outline(dst, True);
  end;
begin
  // Load the erasing icon and selection outline first
  GetGraphic('skill_count_erase', fSkillCountErase);
  GetGraphic('skill_selected', fSkillSelected);

  fSkillCountEraseInvert.Assign(fSkillCountErase);
  for y := 0 to fSkillCountEraseInvert.Height-1 do
    for x := 0 to fSkillCountEraseInvert.Width-1 do
      fSkillCountEraseInvert[x, y] := fSkillCountEraseInvert[x, y] xor $00FFFFFF; // don't invert alpha

  TempBmp := TBitmap32.Create; // freely useable as long as Outline isn't called while it's being used
  try
    // Some preparation
    TempBmp.DrawMode := dmBlend;
    TempBmp.CombineMode := cmMerge;

    BrickColor := GameParams.Renderer.Theme.Colors['MASK'];
    if (BrickColor and $00C0C0C0) = 0 then
      BrickColor := PANEL_FALLBACK_BRICK_COLOR; // Prevent too-dark colors being used, that won't contrast well with outline

    // Set image sizes
    for Button := Low(TSkillPanelButton) to LAST_SKILL_BUTTON do
      fSkillIcons[Button].SetSize(15 * ResMod, 23 * ResMod);

    //////////////////////////////////////////////////////////
    ///  This code is mostly copied to LemGadgetAnimation. ///
    //////////////////////////////////////////////////////////

    // Walker, Jumper, Shimmier, Slider, Climber, - all simple
    DrawAnimationFrame(fSkillIcons[spbWalker], WALKING, 1, 6, 21);
    DrawAnimationFrame(fSkillIcons[spbJumper], JUMPING, 0, 6, 20);
    DrawAnimationFrame(fSkillIcons[spbShimmier], SHIMMYING, 1, 7, 20);
    DrawAnimationFrame(fSkillIcons[spbSlider], SLIDING_RTL, 0, 5, 21);
    DrawAnimationFrame(fSkillIcons[spbClimber], CLIMBING, 3, 10, 22);

    // Swimmer - we need to draw the background water
    DrawAnimationFrame(fSkillIcons[spbSwimmer], SWIMMING, 2, 8, 19);
    Outline(fSkillIcons[spbSwimmer]);
    TempBmp.Assign(fSkillIcons[spbSwimmer]);
    fSkillIcons[spbSwimmer].Clear(0);
    fSkillIcons[spbSwimmer].FillRect(0, 17 * ResMod, 15 * ResMod, 23 * ResMod, $FF000000);
    fSkillIcons[spbSwimmer].FillRect(0, 18 * ResMod, 15 * ResMod, 23 * ResMod, $FF0000FF);
    TempBmp.DrawTo(fSkillIcons[spbSwimmer]);

    // Floater, Glider, Disarmer - all simple
    DrawAnimationFrame(fSkillIcons[spbFloater], UMBRELLA, 4, 7, 26);
    DrawAnimationFrame(fSkillIcons[spbGlider], GLIDING, 4, 7, 26);
    DrawAnimationFrame(fSkillIcons[spbDisarmer], FIXING, 6, 4, 21);

    // Bomber is drawn resized
    DrawAnimationFrameResized(fSkillIcons[spbBomber], EXPLOSION, 0, Rect(-2, 7, 15, 24));

    // Stoner is tricky - the goal is an outlined stoned lemming over a stoner explosion graphic
    DrawAnimationFrame(fSkillIcons[spbStoner], STONED, 0, 8, 21);
    Outline(fSkillIcons[spbStoner]);
    TempBmp.Assign(fSkillIcons[spbStoner]);
    fSkillIcons[spbStoner].Clear(0);
    DrawAnimationFrameResized(fSkillIcons[spbStoner], STONEEXPLOSION, 0, Rect(-2, 7, 15, 24));
    TempBmp.DrawTo(fSkillIcons[spbStoner], 0, 0);

    // Blocker is simple
    DrawAnimationFrame(fSkillIcons[spbBlocker], BLOCKING, 0, 7, 21);

    // Platformer, Builder and Stacker have bricks drawn to clarify the direction of building.
    // Platformer additionally has some extra black pixels drawn in to make the outline nicer.
    DrawAnimationFrame(fSkillIcons[spbPlatformer], PLATFORMING, 1, 7, 20);
    fSkillIcons[spbPlatformer].FillRect(2 * ResMod, 21 * ResMod, 12 * ResMod, 22 * ResMod, $FF000000);
    DrawBrick(fSkillIcons[spbPlatformer], 2, 21);
    DrawBrick(fSkillIcons[spbPlatformer], 5, 21);
    DrawBrick(fSkillIcons[spbPlatformer], 8, 21);
    DrawBrick(fSkillIcons[spbPlatformer], 11, 21);

    DrawAnimationFrame(fSkillIcons[spbBuilder], BRICKLAYING, 1, 7, 20);
    DrawBrick(fSkillIcons[spbBuilder], 4, 22);
    DrawBrick(fSkillIcons[spbBuilder], 6, 21);
    DrawBrick(fSkillIcons[spbBuilder], 8, 20);
    DrawBrick(fSkillIcons[spbBuilder], 10, 19);

    DrawAnimationFrame(fSkillIcons[spbStacker], STACKING, 0, 7, 21);
    DrawBrick(fSkillIcons[spbStacker], 10, 20);
    DrawBrick(fSkillIcons[spbStacker], 10, 19);
    DrawBrick(fSkillIcons[spbStacker], 10, 18);
    DrawBrick(fSkillIcons[spbStacker], 10, 17);

    // Laserer, Basher, Fencer, Miner are all simple - we do have to take care to avoid frames with destruction particles
    // For Digger, we just have to accept some particles.
    DrawAnimationFrame(fSkillIcons[spbLaserer], LASERING, 0, 8, 21);
    DrawAnimationFrame(fSkillIcons[spbBasher], BASHING, 0, 8, 21);
    DrawAnimationFrame(fSkillIcons[spbFencer], FENCING, 1, 7, 21);
    DrawAnimationFrame(fSkillIcons[spbMiner], MINING, 12, 4, 21);
    DrawAnimationFrame(fSkillIcons[spbDigger], DIGGING, 4, 7, 21);

    // And finally, outline everything. We generate the cloner after this, as it makes use of
    // the post-outlined Walker graphic.
    for Button := Low(TSkillPanelButton) to LAST_SKILL_BUTTON do
      if not (Button in [spbSwimmer, spbCloner]) then
        Outline(fSkillIcons[Button]);
        // Swimmer and Cloner are already outlined during their generation.

    // Cloner is drawn as two back-to-back walkers, individually outlined.
    DrawAnimationFrame(fSkillIcons[spbCloner], WALKING_RTL, 1, 6, 21);
    Outline(fSkillIcons[spbCloner]);
    TempBmp.Assign(fSkillIcons[spbWalker]);
    TempBmp.DrawTo(fSkillIcons[spbCloner], 2, 0); // We want it drawn 2px to the right of where it is in the walker icon
  finally
    TempBmp.Free;
  end;
end;

procedure TBaseSkillPanel.LoadSkillFont;
var
  c: Char;
  i: Integer;
  SrcRect: TRect;
  TempBmp: TBitmap32;
  x, y: Integer;

  procedure MakeOvercountImage(aCount: Integer);
  var
    CountStr: String;
  begin
    TempBmp.Clear(0);
    CountStr := LeadZeroStr(aCount, 3); // just in case
    fSkillFont[CountStr[1], 1].DrawTo(TempBmp,  0, 0, Rect(0, 0, 8, 16));
    fSkillFont[CountStr[2], 1].DrawTo(TempBmp,  8, 0, Rect(0, 0, 8, 16));
    fSkillFont[CountStr[3], 1].DrawTo(TempBmp, 16, 0, Rect(0, 0, 8, 16));
  end;

begin
  GetGraphic('skill_count_digits', fPanelButtons);
  SrcRect := Rect(0, 0, 8, 16);
  for c := '0' to '9' do
  begin
    for i := 0 to 1 do
    begin
      fSkillFont[c, i].SetSize(16, 16);
      fPanelButtons.DrawTo(fSkillFont[c, i], (4 - 4 * i) * 2, 0, SrcRect);

      fSkillFontInvert[c, i].Assign(fSkillFont[c, i]);
      for y := 0 to fSkillFontInvert[c, i].Height-1 do
        for x := 0 to fSkillFontInvert[c, i].Width-1 do
          fSkillFontInvert[c, i][x, y] := fSkillFontInvert[c,i][x,y] xor $00FFFFFF; // don't invert alpha
    end;

    OffsetRect(SrcRect, 8, 0);
  end;

  Inc(SrcRect.Right, 8);
  fSkillInfinite.SetSize(16, 16);
  fPanelButtons.DrawTo(fSkillInfinite, 0, 0, SrcRect);

  OffsetRect(SrcRect, 16, 0);
  fSkillLock.SetSize(16, 16);
  fPanelButtons.DrawTo(fSkillLock, 0, 0, SrcRect);

  TempBmp := TBitmap32.Create;
  TKernelResampler.Create(TempBmp);
  TKernelResampler(TempBmp.Resampler).Kernel := TCubicKernel.Create;
  try
    TempBMP.SetSize(24, 16);
    for i := 100 to MAXIMUM_SI do
    begin
      MakeOvercountImage(i);
      fSkillOvercount[i].SetSize(18, 16);
      TempBMP.DrawTo(fSkillOvercount[i], fSkillOvercount[i].BoundsRect, TempBMP.BoundsRect);
    end;
  finally
    TempBMP.Free;
  end;
end;


procedure TBaseSkillPanel.ReadBitmapFromStyle;
var
  ButtonList: TPanelButtonArray;
  MinimapRegion : TBitmap32;
  i: Integer;

  procedure SwapSIButtons;
  var
    SlowerIndex: Integer;
    FasterIndex: Integer;
    i: Integer;
  begin
    // We want to swap the order of + and - when displaying release rate
    if GameParams.UseSpawnInterval then Exit;

    SlowerIndex := -1;
    FasterIndex := -1;

    for i := 0 to Length(ButtonList)-1 do
      if ButtonList[i] = spbSlower then
        SlowerIndex := i
      else if ButtonList[i] = spbFaster then
        FasterIndex := i;

    if (SlowerIndex = -1) or (FasterIndex = -1) then Exit;

    ButtonList[SlowerIndex] := spbFaster;
    ButtonList[FasterIndex] := spbSlower;
  end;
begin
  fOriginal.SetSize(PanelWidth, PanelHeight);
  fOriginal.Clear($FF000000);

  // Get array of buttons to draw
  ButtonList := GetButtonList;
  CustomAssert(Assigned(ButtonList), 'SkillPanel: List of Buttons was nil');

  // Draw empty panel
  DrawBlankPanel(Length(ButtonList));


  // Draw single buttons icons
  SwapSIButtons;
  for i := 0 to Length(ButtonList) - 1 do
    AddButtonImage(BUTTON_TO_STRING[ButtonList[i]], i);

  // Draw minimap region
  MinimapRegion := TBitmap32.Create;
  GetGraphic('minimap_region', MinimapRegion);
  ResizeMinimapRegion(MinimapRegion);
  MinimapRegion.DrawTo(fOriginal, MinimapRect.Left - 6, MinimapRect.Top - 4);
  MinimapRegion.Free;

  // Copy the created bitmap
  fImage.Bitmap.Assign(fOriginal);

  // Load the remaining graphics for icons, ...
  LoadPanelIcons;
  LoadSkillIcons;
  LoadSkillFont;
end;

procedure TBaseSkillPanel.PrepareForGame;
begin
  // Sets game-dependant properties of the skill panel:
  // Size of the minimap, style, scaling factor, skills on the panel, ...
  fImage.BeginUpdate;
  try
    Minimap.SetSize(Level.Info.Width div 4, Level.Info.Height div 4);

    ReadBitmapFromStyle;
    SetButtonRects;
    SetSkillIcons;

  finally
    fImage.EndUpdate;
  end;
end;

procedure TBaseSkillPanel.SetShowUsedSkills(const Value: Boolean);
begin
  fShowUsedSkills := Value;
  RefreshInfo;
end;

procedure TBaseSkillPanel.SetSkillIcons;
var
  ButtonIndex: Integer;
  ButRect: TRect;
  Skill: TSkillPanelButton;
  EmptySlot: TBitmap32;
begin
  ButtonIndex := FirstSkillButtonIndex;
  for Skill := Low(TSkillPanelButton) to High(TSkillPanelButton) do
  begin
    if Skill in Level.Info.Skillset then
    begin
      ButRect := ButtonRect(ButtonIndex);
      Inc(ButtonIndex);

      fButtonRects[Skill] := ButRect;
      fSkillIcons[Skill].DrawTo(fImage.Bitmap, ButRect.Left, ButRect.Top);
      fSkillIcons[Skill].DrawTo(fOriginal, ButRect.Left, ButRect.Top);
    end;
  end;

  if ButtonIndex <= LastSkillButtonIndex then
  begin
    EmptySlot := TBitmap32.Create;
    try
      GetGraphic('empty_slot', EmptySlot);
      EmptySlot.DrawMode := dmBlend;
      EmptySlot.CombineMode := cmMerge;
      while ButtonIndex <= LastSkillButtonIndex do
      begin
        ButRect := ButtonRect(ButtonIndex);
        Inc(ButtonIndex);
        fImage.Bitmap.FillRectS(ButRect, $FF000000);
        fOriginal.FillRectS(ButRect, $FF000000);
        EmptySlot.DrawTo(fImage.Bitmap, ButRect.Left, ButRect.Top);
        EmptySlot.DrawTo(fOriginal, ButRect.Left, ButRect.Top);
      end;
    finally
      EmptySlot.Free;
    end;
  end;
end;

procedure TBaseSkillPanel.SetButtonRects;
var
  ButtonList: TPanelButtonArray;
  Button: TSkillPanelButton;
  i : Integer;
begin
  // Set all to never reached rectangles
  for Button := Low(TSkillPanelButton) to High(TSkillPanelButton) do
    fButtonRects[Button] := Rect(-1, -1, 0, 0);

  ButtonList := GetButtonList;
  CustomAssert(Assigned(ButtonList), 'SkillPanel: List of Buttons was nil');

  // Set only rectangles for non-skill buttons
  // The skill buttons are dealt with in SetSkillIcons
  for i := 0 to Length(ButtonList) - 1 do
  begin
    if ButtonList[i] in [spbDirLeft, spbDirRight] then
    begin
      fButtonRects[spbDirLeft] := HalfButtonRect(i, True);
      fButtonRects[spbDirRight] := HalfButtonRect(i, False);
    end else if ButtonList[i] in [spbBackOneFrame, spbForwardOneFrame] then
    begin
      fButtonRects[spbBackOneFrame] := HalfButtonRect(i, True);
      fButtonRects[spbForwardOneFrame] := HalfButtonRect(i, False);
    end else if ButtonList[i] in [spbPhysicsView, spbLoadReplay] then
    begin
      fButtonRects[spbPhysicsView] := HalfButtonRect(i, True);
      fButtonRects[spbLoadReplay] := HalfButtonRect(i, False);
    end else if ButtonList[i] > spbNone then
      fButtonRects[ButtonList[i]] := ButtonRect(i);
  end;
end;

procedure TBaseSkillPanel.DrawMinimapMessage(const GraphicName: string; out MessageImage: TBitmap32);
begin
  MessageImage := TBitmap32.Create;
  try
    try
      fMinimapTemp.SetSize(104 * ResMod, 34 * ResMod);
      fMinimapTemp.Clear(0);
      GetGraphic(GraphicName, MessageImage);
      fMinimapTemp.Draw(0, 0, MessageImage);
    except
      on E: Exception do
        Exit;
    end;
  finally
    MessageImage.Free;
  end;
end;

procedure TBaseSkillPanel.DrawMinimap;
var
  BaseOffsetHoriz, BaseOffsetVert: Double;
  OH, OV: Double;
  ViewRect: TRect;
  InnerViewRect: TRect;
  MinimapMessage: TBitmap32;
  ViewRectWidth, ViewRectHeight: Integer;
begin
  if Parent = nil then Exit;

  BaseOffsetHoriz := 0;
  BaseOffsetVert := 0;

  // Draw a message instead of the minimap in certain conditions
  if Game.StateIsUnplayable and not Game.ShouldWeExitBecauseOfOptions then
    DrawMinimapMessage('nolems_message', MinimapMessage)
  else begin
    // Add some space for when the view frame lies on the very edges
    fMinimapTemp.SetSize(fMinimap.Width + 4, fMinimap.Height + 4);
    fMinimapTemp.Clear(0);

    fMinimap.DrawTo(fMinimapTemp, 2, 2);

    BaseOffsetHoriz := fGameWindow.ScreenImage.OffsetHorz / fGameWindow.ScreenImage.Scale / (4 * ResMod);
    BaseOffsetVert := fGameWindow.ScreenImage.OffsetVert / fGameWindow.ScreenImage.Scale / (4 * ResMod);

    // Draw the view frame
    ViewRectWidth := fGameWindow.DisplayWidth div (4 * ResMod) + 2;
    ViewRectHeight := fGameWindow.DisplayHeight div (4 * ResMod) + 2;

    ViewRect := Rect(0, 0, ViewRectWidth, ViewRectHeight);
    OffsetRect(ViewRect, -Round(BaseOffsetHoriz), -Round(BaseOffsetVert));
    fMinimapTemp.FrameRectS(ViewRect, fRectColor);

    // Thicken the view frame by 1px
    InnerViewRect := Rect(ViewRect.Left + 1, ViewRect.Top + 1, ViewRect.Right - 1, ViewRect.Bottom - 1);
    fMinimapTemp.FrameRectS(InnerViewRect, $FFFFFFFF);
  end;

  fMinimapImage.Bitmap.Assign(fMinimapTemp);

  if not fMinimapScrollFreeze then
  begin
    if fMinimapTemp.Width < MinimapWidth then
      OH := (MinimapWidth - fMinimapTemp.Width) / 2
    else begin
      OH := BaseOffsetHoriz + (MinimapWidth - RectWidth(ViewRect)) / 2;
      OH := Min(Max(OH, MinimapWidth - fMinimapTemp.Width), 0);
    end;

    if fMinimapTemp.Height < MinimapHeight then
      OV := (MinimapHeight - fMinimapTemp.Height) / 2
    else begin
      OV := BaseOffsetVert + (MinimapHeight - RectHeight(ViewRect)) / 2;
      OV := Min(Max(OV, MinimapHeight - fMinimapTemp.Height), 0);
    end;

    fMinimapImage.OffsetHorz := OH * fMinimapImage.Scale;
    fMinimapImage.OffsetVert := OV * fMinimapImage.Scale;
  end;
end;

procedure TBaseSkillPanel.DrawButtonSelector(aButton: TSkillPanelButton; Highlight: Boolean);
begin
  if fGameWindow.IsHyperSpeed then Exit;
  if aButton = spbNone then Exit;
  if (aButton <= LAST_SKILL_BUTTON) then
  begin
    if (fHighlitSkill = aButton) and Highlight then Exit;
    if (fHighlitSkill = spbNone) and not Highlight then Exit;
  end;
  if fButtonRects[aButton].Left <= 0 then Exit;

  RemoveHighlight(aButton);
  if Highlight then
    DrawHighlight(aButton);
end;

procedure TBaseSkillPanel.DrawHighlight(aButton: TSkillPanelButton);
var
  BorderRect: TRect;
begin
  if aButton <= LAST_SKILL_BUTTON then // we don't want to memorize this for eg. fast forward
  begin
    BorderRect := fButtonRects[aButton];
    fHighlitSkill := aButton;
    if (fLastHighlitSkill <> spbNone) and (fLastHighlitSkill <> fHighlitSkill) then
      SoundManager.PlaySound(SFX_SKILLBUTTON);
  end else
    BorderRect := fButtonRects[aButton];

  Inc(BorderRect.Right, 2);
  Inc(BorderRect.Bottom, 4);

  DrawNineSlice(Image.Bitmap, BorderRect, fSkillSelected.BoundsRect, Rect(6, 6, 6, 6), fSkillSelected);
end;

procedure TBaseSkillPanel.RemoveHighlight(aButton: TSkillPanelButton);
var
  BorderRect, EraseRect: TRect;
begin
  if aButton <= LAST_SKILL_BUTTON then
  begin
    BorderRect := fButtonRects[fHighlitSkill];
    if fHighlitSkill <> spbNone then
      fLastHighlitSkill := fHighlitSkill;
    fHighlitSkill := spbNone;
  end else
    BorderRect := fButtonRects[aButton];

  Inc(BorderRect.Right, 2);
  Inc(BorderRect.Bottom, 4);

  fOriginal.DrawTo(Image.Bitmap, BorderRect, BorderRect);
  Exit;

  // top
  EraseRect := BorderRect;
  EraseRect.Bottom := EraseRect.Top + 2;
  fOriginal.DrawTo(Image.Bitmap, EraseRect, EraseRect);

  // left
  EraseRect := BorderRect;
  EraseRect.Right := EraseRect.Left + 2;
  fOriginal.DrawTo(Image.Bitmap, EraseRect, EraseRect);

  // right
  EraseRect := BorderRect;
  EraseRect.Left := EraseRect.Right - 2;
  fOriginal.DrawTo(Image.Bitmap, EraseRect, EraseRect);

  // bottom
  EraseRect := BorderRect;
  EraseRect.Top := EraseRect.Bottom - 2;
  fOriginal.DrawTo(Image.Bitmap, EraseRect, EraseRect);
end;



procedure TBaseSkillPanel.ResetMinimapPosition;
begin
  fMinimapImage.Left := MinimapRect.Left * Trunc(fMinimapImage.Scale) + Image.Left;
  fMinimapImage.Top := MinimapRect.Top * Trunc(fMinimapImage.Scale);
end;

procedure TBaseSkillPanel.DrawSkillCount(aButton: TSkillPanelButton; aNumber: Integer);
var
  ButtonLeft, ButtonTop: Integer;
  NumberStr: string;

  EraseBMP: TBitmap32;
  FontBMP: TFontBitmapArray;
  // Don't need variables for Infinite, Lock or Overcount as they're never used in inverted form

  IsRegularSkill: Boolean;
begin
  if fButtonRects[aButton].Left < 0 then Exit;
  if fGameWindow.IsHyperSpeed then Exit;

  IsRegularSkill := aButton <= LAST_SKILL_BUTTON;

  if IsRegularSkill and fShowUsedSkills then
  begin
    if aNumber > 99 then aNumber := 99;
    EraseBMP := fSkillCountEraseInvert;
    FontBMP := fSkillFontInvert;
  end else begin
    EraseBMP := fSkillCountErase;
    FontBMP := fSkillFont;
  end;

  ButtonLeft := fButtonRects[aButton].Left;
  ButtonTop := fButtonRects[aButton].Top;

  // Erase previous number
  EraseBMP.DrawTo(fImage.Bitmap, ButtonLeft, ButtonTop);
  if IsRegularSkill and (aNumber = 0) and not fShowUsedSkills then Exit;

  if (aButton = spbFaster) and (Level.Info.SpawnIntervalLocked or (Level.Info.SpawnInterval = MINIMUM_SI)) then
    fSkillLock.DrawTo(fImage.Bitmap, ButtonLeft + 6, ButtonTop + 2)
  else if (aNumber > 99) then
  begin
    if (aButton <= LAST_SKILL_BUTTON) then
      fSkillInfinite.DrawTo(fImage.Bitmap, ButtonLeft + 6, ButtonTop + 2)
    else
      fSkillOvercount[aNumber].DrawTo(fImage.Bitmap, ButtonLeft + 6, ButtonTop + 2);
  end else if aNumber < 10 then
  begin
    NumberStr := LeadZeroStr(aNumber, 2);
    FontBMP[NumberStr[2], 0].DrawTo(fImage.Bitmap, ButtonLeft + 2, ButtonTop + 2);
  end else begin
    NumberStr := LeadZeroStr(aNumber, 2);
    FontBMP[NumberStr[1], 1].DrawTo(fImage.Bitmap, ButtonLeft + 6, ButtonTop + 2);
    FontBMP[NumberStr[2], 0].DrawTo(fImage.Bitmap, ButtonLeft + 6, ButtonTop + 2);
  end;
end;

{-----------------------------------------
    Info string at top
-----------------------------------------}
procedure TBaseSkillPanel.CombineShift(F: TColor32; var B: TColor32; M: Cardinal);
var
  H, S, V: Single;
begin
  if AlphaComponent(F) = 0 then Exit;
  RGBToHSV(F, H, S, V);
  H := H + fCombineHueShift;
  B := HSVToRGB(H, S, V);
end;

procedure TBaseSkillPanel.DrawCursorInfo;
var
  Color: TColor32;
begin
  if not (CursorOverPanelItem or (Game.RenderInterface.SelectedLemming <> nil)) then
    Exit;

  if CursorOverPanelItem then
    Color := clCornflowerBlue32
  else if Game.SelectedLemFutureTaskCount > 0 then
    Color := clTeal32
  else
    Color := clLightGreen32;

  with fImage.Bitmap do
  begin
    Font.Name := 'Hobo Std';
    Font.Size := 8;
    RenderText(4, 6, GetCursorInfoString, Color, True);
  end;
end;

procedure TBaseSkillPanel.DrawPanelIcon(Index, X, Y: Integer);
begin
  fPanelIcons.DrawTo(fImage.Bitmap, X, Y, Rect(Index * 16, 0, (Index + 1) * 16, 32));
end;

procedure TBaseSkillPanel.DrawReplayIcon;
var
  Index: Integer;
//var
  //TickCount: Cardinal;
  //BlinkIcon: Boolean;
begin
  //TickCount := GetTickCount;
  //BlinkIcon := ((TickCount div 500) mod 2) = 0;

  if Game.StateIsUnplayable or
     (not GameParams.PlaybackModeActive and not IsReplaying) then
    Exit;

  if Game.ReplayInsert or (GameParams.PlaybackModeActive and not IsReplaying) then
    Index := 6
  else if not RRIsPressed then
    Index := 0
  else
    Exit;

  if GameParams.PlaybackModeActive and not IsReplaying then
  begin
    fPanelIcons.DrawMode := dmCustom;
    fPanelIcons.OnPixelCombine := CombineShift;
    fCombineHueShift := 1 / 10; // Hue shift to Purple R for Playback Mode
  end;

  DrawPanelIcon(Index, ReplayIconRect.Left, ReplayIconRect.Top);
end;

procedure TBaseSkillPanel.DrawHatchInfo;
begin
  DrawPanelIcon(1, HatchIconRect.Left, HatchIconRect.Top);

  with fImage.Bitmap do
  begin
    Font.Name := 'Hobo Std';
    Font.Size := 8;
    RenderText(HatchIconRect.Left + 20, 6, GetHatchCountString, clLightGreen32, True);
  end;
end;

procedure TBaseSkillPanel.DrawLemsAliveInfo;
var
  Color: TColor32;
  LemmingKinds: TLemmingKinds;
begin
  DrawPanelIcon(2, AliveIconRect.Left, AliveIconRect.Top);
  LemmingKinds := Game.ActiveLemmingTypes;

  if Game.LemmingsToSpawn + Game.LemmingsActive - Game.SpawnedDead < Level.Info.RescueCount - Game.LemmingsSaved then
    Color := clRed32
  else if (lkNeutral in LemmingKinds) and not (lkNormal in LemmingKinds) then
    Color := clTeal32
  else
    Color := clLightGreen32;

  with fImage.Bitmap do
  begin
    Font.Name := 'Hobo Std';
    Font.Size := 8;
    RenderText(AliveIconRect.Left + 20, 6, GetLemsAliveString, Color, True);
  end;
end;

procedure TBaseSkillPanel.DrawLemsSavedInfo;
var
  Color: TColor32;
  Icon: Integer;
begin
  if (Game.LemmingsSaved >= Level.Info.RescueCount) then
  begin
    Color := clTeal32;
    Icon := 8;
  end else begin
    Color := clLightGreen32;
    Icon := 3;
  end;

  DrawPanelIcon(Icon, ExitIconRect.Left, ExitIconRect.Top);

  with fImage.Bitmap do
  begin
    Font.Name := 'Hobo Std';
    Font.Size := 8;
    RenderText(ExitIconRect.Left + 20, 6, GetLemsSavedString, Color, True);
  end;
end;

procedure TBaseSkillPanel.DrawTimeInfo;
var
  Icon: Integer;
  Color: TColor32;

  function IsTimeRemainingPercent(aPercent: Integer): Boolean;
  begin
    Result := ((Level.Info.TimeLimit * 17) - Game.CurrentIteration <=
               (Level.Info.TimeLimit * 17 * aPercent) div 100);
  end;
begin
  if Level.Info.HasTimeLimit then
  begin
    Color := clYellow32;

    if Game.IsOutOfTime then
    begin
      Color := clRed32;
      Icon := 9;
    end else if IsTimeRemainingPercent(35) then
      Icon := 10
    else if IsTimeRemainingPercent(70) then
      Icon := 11
    else
      Icon := 12;
  end else begin
    Color := clLightGreen32;
    Icon := 4;
  end;

  DrawPanelIcon(Icon, TimeIconRect.Left, TimeIconRect.Top);

  with fImage.Bitmap do
  begin
    Font.Name := 'Hobo Std';
    Font.Size := 8;
    RenderText(TimeIconRect.Left + 20, 6, GetTimeString, Color, True);
  end;
end;

procedure TBaseSkillPanel.ClearInfo;
var
  PanelInfoEnd: Integer;
begin
  PanelInfoEnd := TimeIconRect.Right;
  fImage.Bitmap.FillRectS(0, 0, PanelInfoEnd, 32, $00000000);
end;

procedure TBaseSkillPanel.RefreshInfo;
var
  i : TSkillPanelButton;
begin
  fIsBlinkFrame := (GetTickCount mod 1000) > 499;

  Image.BeginUpdate;
  try
    for i := Low(fButtonRects) to High(fButtonRects) do
      GetButtonHints(i);

    // Text info string
    ClearInfo;
    DrawCursorInfo;
    DrawReplayIcon;
    DrawHatchInfo;
    DrawLemsAliveInfo;
    DrawLemsSavedInfo;
    DrawTimeInfo;
    fLastDrawnStr := fNewDrawStr;

    DrawSkillCount(spbSlower, GetSpawnIntervalValue(Level.Info.SpawnInterval));
    DrawSkillCount(spbFaster, GetSpawnIntervalValue(Game.CurrentSpawnInterval));

    // Highlight selected button
    if fHighlitSkill <> Game.RenderInterface.SelectedSkill then
    begin
      DrawButtonSelector(fHighlitSkill, False);
      DrawButtonSelector(Game.RenderInterface.SelectedSkill, True);
    end;

    // Skill numbers
    if Self.fShowUsedSkills then
    begin
      for i := Low(TSkillPanelButton) to LAST_SKILL_BUTTON do
        DrawSkillCount(i, Game.SkillsUsed[i]);
    end else begin
      for i := Low(TSkillPanelButton) to LAST_SKILL_BUTTON do
        DrawSkillCount(i, Game.SkillCount[i]);
    end;

    DrawButtonSelector(spbNuke, (Game.UserSetNuking or (Game.ReplayManager.Assignment[Game.CurrentIteration, 0] is TReplayNuke)));
  finally
    Image.EndUpdate;
  end;
end;

function TBaseSkillPanel.GetPickupString(P: TGadget): String;
begin
  Result := IntToStr(P.SkillCount) + ' ' + Uppercase(SKILL_NAMES[P.SkillType] + IfThen(P.SkillCount > 1, 'S', ''));
end;

function TBaseSkillPanel.GetLemReplayTaskString(L: TLemming): String;
var
  Tasks: Integer;
begin
  Tasks := Game.SelectedLemFutureTaskCount;
  Result := 'CUT ' + IntToStr(Tasks) + ' TASK' + IfThen(Tasks > 1, 'S', ' ');
end;

function TBaseSkillPanel.GetSkillString(L: TLemming): String;
var
  i: Integer;

  procedure DoInc(aText: String);
  begin
    Inc(i);
    case i of
      1: Result := aText;
      2: Result := SAthlete;
      3: Result := STriathlete;
      4: Result := SQuadathlete;
      5: Result := SQuintathlete
    end;
  end;
begin
  Result := '';
  if L = nil then Exit;

  Result := LemmingActionStrings[L.LemAction];

  if L.HasPermanentSkills and GameParams.Hotkeys.CheckForKey(lka_ShowAthleteInfo) then
  begin
    Result := '-------';
    if L.LemIsSlider then Result[1] := 'L';    
    if L.LemIsClimber then Result[2] := 'C';
    if L.LemIsSwimmer then Result[3] := 'S';
    if L.LemIsFloater then Result[4] := 'F';
    if L.LemIsGlider then Result[4] := 'G';
    if L.LemIsDisarmer then Result[5] := 'D';
    if L.LemIsZombie then Result[6] := 'Z';
    if L.LemIsNeutral then Result[7] := 'N';
  end
  else if not (L.LemAction in [baBuilding, baPlatforming, baStacking, baLasering, baBashing, baMining, baDigging, baBlocking]) then
  begin
    i := 0;
    if L.LemIsSlider then DoInc(SSlider);
    if L.LemIsClimber then DoInc(SClimber);
    if L.LemIsSwimmer then DoInc(SSwimmer);
    if L.LemIsFloater then DoInc(SFloater);
    if L.LemIsGlider then DoInc(SGlider);
    if L.LemIsDisarmer then DoInc(SDisarmer);
    if L.LemIsZombie then Result := SZombie;
    if L.LemIsNeutral then Result := SNeutral;
    if L.LemIsZombie and L.LemIsNeutral then Result := SNeutralZombie;
  end;
end;

function TBaseSkillPanel.GetCursorInfoString: String;
var
  S: String;
  SelectedLemming: TLemming;
  PickupInCursor: TGadget;
const
  LEN = 12;
begin
  SelectedLemming := Game.RenderInterface.SelectedLemming;
  PickupInCursor := Game.RenderInterface.PickupInCursor;

  S := '';

  if ((PickupInCursor <> nil) and (SelectedLemming = nil)) then
    S := Uppercase(GetPickupString(PickupInCursor))
  else if CursorOverPanelItem and GameParams.ShowButtonHints then
    S := ButtonHint + StringOfChar(' ', 13 - Length(ButtonHint))
  else begin
    if (Game.SelectedLemFutureTaskCount > 0) then
      S := Uppercase(GetLemReplayTaskString(SelectedLemming))
    else begin
      S := Uppercase(GetSkillString(SelectedLemming));

      if S = '' then
        S := StringOfChar(' ', LEN)
      else if (Game.GetCursorLemmingCount = 0) then
        S := PadR(S, LEN)
      else
        S := PadR(S + ' ' + IntToStr(Game.GetCursorLemmingCount), LEN);
    end;
  end;

  Result := S;
end;

function TBaseSkillPanel.GetHatchCountString: String;
var
  HatchLems: Integer;
begin
  HatchLems := Game.LemmingsToSpawn - Game.SpawnedDead;
  Assert(HatchLems >= 0, 'Negative number of lemmings in hatch displayed');

  if HatchLems >= 999 then
    Result := '999'
  else
    Result := IntToStr(HatchLems);
end;

function TBaseSkillPanel.GetLemsAliveString: String;
var
  LemNum: Integer;
begin
  LemNum := Game.LemmingsToSpawn + Game.LemmingsActive - Game.SpawnedDead;
  CustomAssert(LemNum >= 0, 'Negative number of alive lemmings displayed');

  if (LemNum >= 999) then
    Result := ' 999'
  else
    Result := IntToStr(LemNum);
end;

function TBaseSkillPanel.GetLemsSavedString: String;
var
  ToSave, Required, TotalSaved, ExtraSaved: Integer;
begin
  Required := Level.Info.RescueCount;
  TotalSaved := Game.LemmingsSaved;
  ToSave := Required - TotalSaved;
  ExtraSaved := TotalSaved - Required;

  if GameParams.CountDownFromSR then
  begin
    if CursorOverIcon(ExitIconRect) and (TotalSaved >= Required) then
      Result := IntToStr(TotalSaved)
    else if (ExtraSaved > 0) then
      Result := '+' + IntToStr(ExtraSaved)
    else
      Result := IntToStr(ToSave);
  end else begin
    if CursorOverIcon(ExitIconRect) and (TotalSaved < Required) then
      Result := IntToStr(ToSave)
    else
      Result := IntToStr(TotalSaved);
  end;

  if //(ExtraSaved <= -999) or
    (ToSave <= -999) or (TotalSaved <= -999) or (Required <= -999) then // Should never happen
      Result := '-999'
//  else if (ExtraSaved >= 999) then
//    S := '+999'
  else if (ToSave >= 999) or (TotalSaved >= 999) or (Required >= 999) then
    Result := ' 999';
end;

function TBaseSkillPanel.GetTimeString: String;
var
  Time : Integer;
  Prefix, Minutes, Seconds: String;
begin
  if Level.Info.HasTimeLimit then
  begin
    Time := Level.Info.TimeLimit - Game.CurrentIteration div 17;
    if Time < 0 then
      Time := 0 - Time;
  end else
    Time := Game.CurrentIteration div 17;

  if Game.IsOutOfTime and (Time <> 0) then
    Prefix := '-'
  else
    Prefix := ' ';

  Minutes := PadL(IntToStr(Time div 60), 2);
  Seconds := LeadZeroStr(Time mod 60, 2);

  Result := Prefix + Minutes + ':' + Seconds;
end;

{-----------------------------------------
    User interaction
-----------------------------------------}
function TBaseSkillPanel.MousePos(X, Y: Integer): TPoint;
begin
  Result := fImage.ControlToBitmap(Point(X, Y));
end;

function TBaseSkillPanel.MousePosMinimap(X, Y: Integer): TPoint;
begin
  Result := fMinimapImage.ControlToBitmap(Point(X, Y));
end;

procedure TBaseSkillPanel.ImgMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  aButton: TSkillPanelButton;
  i: TSkillPanelButton;
begin
  if GameParams.EdgeScroll then fGameWindow.ApplyMouseTrap;
  if fGameWindow.IsHyperSpeed then Exit;

  if CursorOverIcon(ReplayIconRect) then
  begin
    // Stop playback if the "P" icon is clicked (replay must have finished or been cancelled, so this needs to be called first)
    if GameParams.PlaybackModeActive and (Game.CurrentIteration > Game.ReplayManager.LastActionFrame) then
      GameParams.PlaybackModeActive := False;

    // Cancel replay if the "R" icon is clicked
    Game.RegainControl(True);
  end;

  // Get pressed button
  aButton := spbNone;
  for i := Low(TSkillPanelButton) to High(TSkillPanelButton) do
  begin
    if PtInRect(fButtonRects[i], MousePos(X, Y)) then
    begin
      aButton := i;
      Break;
    end;
  end;

  // Do some global stuff
  if aButton = spbNone then Exit;
  if (aButton = spbNuke) and not (ssDouble in Shift) then Exit;

  if Game.Replaying and not Level.Info.SpawnIntervalLocked then
  begin
    if    ((aButton = spbSlower) and (Game.CurrentSpawnInterval < Level.Info.SpawnInterval))
       or ((aButton = spbFaster) and (Game.CurrentSpawnInterval > MINIMUM_SI)) then
      Game.RegainControl;
  end;

  // Do button-specific actions
  case aButton of
    spbSlower:
      begin
        RRIsPressed := True; // Prevents replay icon being drawn when using RR buttons
        Game.SetSelectedSkill(i, True, (Button = mbRight));
      end;
    spbFaster:
      begin
        RRIsPressed := True; // Prevents replay icon being drawn when using RR buttons
        Game.SetSelectedSkill(i, True, (Button = mbRight));
      end;
    spbPause:
      begin
        if fGameWindow.GameSpeed = gspPause then
          fGameWindow.GameSpeed := gspNormal
        else
          fGameWindow.GameSpeed := gspPause;
      end;
    spbNuke:
      begin
        Game.RegainControl;

        if GameParams.Hotkeys.CheckForKey(lka_Highlight) or (Button = mbRight) then
        begin
          Game.SetSelectedSkill(i, True, True);
          fGameWindow.GotoSaveState(Game.CurrentIteration, 0, Game.CurrentIteration - 85);
        end else
          Game.SetSelectedSkill(i, True);
      end;
    spbFastForward:
      begin
        if fGameWindow.GameSpeed = gspFF then
          fGameWindow.GameSpeed := gspNormal
        else if fGameWindow.GameSpeed in [gspNormal, gspSlowMo, gspPause] then
          fGameWindow.GameSpeed := gspFF;
      end;
    spbRestart: begin
                  if not GameParams.ReplayAfterRestart then
                    Game.CancelReplayAfterSkip := True;

                  fGameWindow.GotoSaveState(0);
                  Game.Restarted := True;
                end;
    spbBackOneFrame:
      begin
        if not GameParams.ReplayAfterBackskip then
          Game.CancelReplayAfterSkip := True;

        if Button = mbLeft then
        begin
          fGameWindow.GotoSaveState(Game.CurrentIteration - 1);
          fLastClickFrameskip := GetTickCount;
        end else if Button = mbRight then
          fGameWindow.GotoSaveState(Game.CurrentIteration - 17)
        else if Button = mbMiddle then
          fGameWindow.GotoSaveState(Game.CurrentIteration - 85);
      end;
    spbForwardOneFrame:
      begin
        if Button = mbLeft then
        begin
          fGameWindow.SetForceUpdateOneFrame(True);
          fLastClickFrameskip := GetTickCount;
        end else if Button = mbRight then
          fGameWindow.SetHyperSpeedTarget(Game.CurrentIteration + 17)
        else if Button = mbMiddle then
          fGameWindow.SetHyperSpeedTarget(Game.CurrentIteration + 85);
      end;
    spbPhysicsView: fGameWindow.PhysicsViewActive := not fGameWindow.PhysicsViewActive;
    spbDirLeft:
      begin
        if fSelectDx = -1 then
        begin
          fSelectDx := 0;
          DrawButtonSelector(spbDirLeft, False);
        end else begin
          fSelectDx := -1;
          DrawButtonSelector(spbDirLeft, True);
          DrawButtonSelector(spbDirRight, False);
        end;
      end;
    spbDirRight:
      begin
        if fSelectDx = 1 then
        begin
          fSelectDx := 0;
          DrawButtonSelector(spbDirRight, False);
        end else begin
          fSelectDx := 1;
          DrawButtonSelector(spbDirLeft, False);
          DrawButtonSelector(spbDirRight, True);
        end;
      end;
    spbLoadReplay:
      begin
        case Button of
          mbLeft: fGameWindow.HandleLoadReplay;
          mbRight: fGameWindow.SaveReplay(True);
          mbMiddle: fGameWindow.ExecuteReplayEdit;
        end;
      end;
    spbNone: {nothing};
  else // usual skill buttons
    Game.SetSelectedSkill(i, True, GameParams.Hotkeys.CheckForKey(lka_Highlight));
  end;
end;

procedure TBaseSkillPanel.ImgMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if fGameWindow.DoSuspendCursor then Exit;

  Game.HitTestAutoFail := True;
  Game.HitTest;
  fGameWindow.SetCurrentCursor;

  MinimapScrollFreeze := False;
end;

procedure TBaseSkillPanel.ImgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  Game.SetSelectedSkill(spbSlower, False);
  Game.SetSelectedSkill(spbFaster, False);
  RRIsPressed := False;
end;

procedure TBaseSkillPanel.MinimapMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if GameParams.EdgeScroll then fGameWindow.ApplyMouseTrap;
  fMinimapScrollFreeze := True;

  if Assigned(fOnMinimapClick) then
    fOnMinimapClick(Self, MousePosMinimap(X, Y));
end;

procedure TBaseSkillPanel.MinimapMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  Pos: TPoint;
begin
  if fGameWindow.DoSuspendCursor then Exit;

  Game.HitTestAutoFail := True;
  Game.HitTest;
  fGameWindow.SetCurrentCursor;

  if not fMinimapScrollFreeze then Exit;
  if not (ssLeft in Shift) then Exit;

  Pos := MousePosMinimap(X, Y);
  if PtInRect(fMinimapImage.Bitmap.BoundsRect, Pos) and Assigned(fOnMinimapClick) then
    fOnMinimapClick(Self, Pos)
  else
    MinimapMouseUp(Sender, mbLeft, Shift, X, Y, Layer);
end;

procedure TBaseSkillPanel.MinimapMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  fMinimapScrollFreeze := False;
  DrawMinimap;
end;


function TBaseSkillPanel.CheckFrameSkip: Integer;
var
  P: TPoint;
begin
  Result := 0;
  if GetTickCount - fLastClickFrameskip < 250 then Exit;
  if GetKeyState(VK_LBUTTON) >= 0 then Exit;

  P := Image.ControlToBitmap(Image.ScreenToClient(Mouse.CursorPos));
  if PtInRect(fButtonRects[spbBackOneFrame], P) then
  begin
    Result := -1;
    fLastClickFrameskip := GetTickCount - 150;
  end
  else if PtInRect(fButtonRects[spbForwardOneFrame], P) then
  begin
    Result := 1;
    fLastClickFrameskip := GetTickCount - 150;
  end;
end;

{-----------------------------------------
    General stuff
-----------------------------------------}
function TBaseSkillPanel.GetLevel: TLevel;
begin
  Result := GameParams.Level;
end;

procedure TBaseSkillPanel.SetZoom(NewZoom: Integer);
begin
  if GameParams.HighResolution then
    NewZoom := NewZoom * 2;
  NewZoom := Max(Min(MaxZoom, NewZoom), 1);
  if (NewZoom = Trunc(fImage.Scale)) and fSetInitialZoom then Exit;

  Width := GameParams.MainForm.ClientWidth;    // for the whole skill panel
  Height := GameParams.MainForm.ClientHeight;  // for the whole skill panel

  fImage.Width := PanelWidth * NewZoom;
  fImage.Height := PanelHeight * NewZoom;
  fImage.Left := (Width - Image.Width) div 2;
  fImage.Scale := NewZoom;

  fMinimapImage.Width := MinimapWidth * NewZoom;
  fMinimapImage.Height := MinimapHeight * NewZoom;
  fMinimapImage.Left := MinimapRect.Left * NewZoom + Image.Left;
  fMinimapImage.Top := MinimapRect.Top * NewZoom;
  fMinimapImage.Scale := NewZoom;

  fSetInitialZoom := True;
end;

function TBaseSkillPanel.GetZoom: Integer;
begin
  Result := Trunc(fImage.Scale);
end;

function TBaseSkillPanel.GetMaxZoom: Integer;
begin
  Result := Max(Min(GameParams.MainForm.ClientWidth div PanelWidth, (GameParams.MainForm.ClientHeight - 160) div 40), 1);
end;

procedure TBaseSkillPanel.SetMinimapScrollFreeze(aValue: Boolean);
begin
  fMinimapScrollFreeze := aValue;
  if fMinimapScrollFreeze then DrawMinimap;
end;

procedure TBaseSkillPanel.SetGame(const Value: TLemmingGame);
begin
  fGame := Value;
end;

procedure TBaseSkillPanel.SetOnMinimapClick(const Value: TMinimapClickEvent);
begin
  fOnMinimapClick := Value;
end;

procedure TBaseSkillPanel.SetCursor(aCursor: TCursor);
begin
  Cursor := aCursor;
  fImage.Cursor := aCursor;
  fMinimapImage.Cursor := aCursor;
end;

function TBaseSkillPanel.GetSpawnIntervalValue(aSI: Integer): Integer;
begin
  if GameParams.UseSpawnInterval then
    Result := aSI
  else
    Result := SpawnIntervalToReleaseRate(aSI);
end;

end.
