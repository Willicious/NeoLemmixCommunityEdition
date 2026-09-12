{$include lem_directives.inc}
unit GameSkillPanel;

interface

uses
  LemTypes,
  Classes, GR32,
  GameWindowInterface, GameBaseSkillPanel,
  SharedGlobals;

type
  TSkillPanelStandard = class(TBaseSkillPanel)
  protected
    function GetButtonList: TPanelButtonArray; override;

    function PanelWidth: Integer; override;
    function PanelHeight: Integer; override;

    procedure ResizeMinimapRegion(MinimapRegion: TBitmap32); override;
    function MinimapRect: TRect; override;

    function ReplayIconRect: TRect; override;
    function HatchIconRect: TRect; override;
    function AliveIconRect: TRect; override;
    function ExitIconRect: TRect; override;
    function TimeIconRect: TRect; override;

    procedure CreateNewInfoString; override;
    function DrawStringLength: Integer; override;
    function DrawStringTemplate: string; override;
    function TimeLimitStartIndex: Integer; override;
    function CursorInfoEndIndex: Integer; override;
    function SaveCountStartIndex: Integer; override;
    function LemmingCountStartIndex: Integer; override;
  public
    constructor CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow); override;
    destructor Destroy; override;
  end;

  TSkillPanelCompact = class(TBaseSkillPanel)
  protected
    function GetButtonList: TPanelButtonArray; override;

    function PanelWidth: Integer; override;
    function PanelHeight: Integer; override;

    procedure ResizeMinimapRegion(MinimapRegion: TBitmap32); override;
    function MinimapRect: TRect; override;

    function ReplayIconRect: TRect; override;
    function HatchIconRect: TRect; override;
    function AliveIconRect: TRect; override;
    function ExitIconRect: TRect; override;
    function TimeIconRect: TRect; override;

    procedure CreateNewInfoString; override;
    function DrawStringLength: Integer; override;
    function DrawStringTemplate: string; override;
    function SaveCountStartIndex: Integer; override;
    function TimeLimitStartIndex: Integer; override;
    function CursorInfoEndIndex: Integer; override;
    function LemmingCountStartIndex: Integer; override;
  public
    constructor CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow); override;
    destructor Destroy; override;
  end;

implementation

uses
  GameControl, LemCore;

{ TSkillPanelStandard }

constructor TSkillPanelStandard.CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow);
begin
  inherited;
end;

destructor TSkillPanelStandard.Destroy;
begin
  inherited;
end;

function TSkillPanelStandard.PanelWidth: Integer;
begin
  Result := 832;
end;

function TSkillPanelStandard.PanelHeight: Integer;
begin
  Result := 80;
end;

function TSkillPanelStandard.DrawStringLength: Integer;
begin
  Result := 38;
end;

function TSkillPanelStandard.DrawStringTemplate: string;
begin
  Result := '............' + '.' + ' ' + #92 + '_...' + ' ' + #93 + '_...' + ' '
                           + #94 + '_...' + ' ' + #95 +  '_.-..';
end;

function TSkillPanelStandard.CursorInfoEndIndex: Integer;
begin
  Result := 12;
end;

function TSkillPanelStandard.LemmingCountStartIndex: Integer;
begin
  Result := 21;
end;

function TSkillPanelStandard.SaveCountStartIndex: Integer;
begin
  Result := 27;
end;

function TSkillPanelStandard.TimeLimitStartIndex: Integer;
begin
  Result := 33;
end;

function TSkillPanelStandard.MinimapRect: TRect;
begin
  Result := Rect(616, 6, 824, 74);
end;

// Assigns a clickable rectangle to the replay "R" icon
function TSkillPanelStandard.ReplayIconRect: TRect;
begin
  Result := Rect(190, 0, 208, 32);
end;

// Assigns a non-clickable rectangle to the hatch count icon & digits
function TSkillPanelStandard.HatchIconRect: TRect;
begin
  Result := Rect(224, 4, 312, 32);
end;

// Assigns a non-clickable rectangle to the alive count icon & digits
function TSkillPanelStandard.AliveIconRect: TRect;
begin
  Result := Rect(320, 4, 408, 32);
end;

// Assigns a non-clickable rectangle to the exit count icon & digits
function TSkillPanelStandard.ExitIconRect: TRect;
begin
  Result := Rect(416, 4, 504, 32);
end;

// Assigns a non-clickable rectangle to the timer icon & digits
function TSkillPanelStandard.TimeIconRect: TRect;
begin
  Result := Rect(512, 4, 608, 32);
end;

procedure TSkillPanelStandard.CreateNewInfoString;
begin
  SetInfoCursor(1);
  SetInfoLemHatch(16);
  SetInfoLemAlive(22);
  SetExitIcon(27);
  SetInfoLemIn(28);
  SetTimeLimit(33);
  SetInfoTime(34, 37);
end;

function TSkillPanelStandard.GetButtonList: TPanelButtonArray;
var
  i : Integer;
begin
  SetLength(Result, 19);
  Result[0] := spbSlower;
  Result[1] := spbFaster;
  for i := 2 to (2 + MAX_SKILL_TYPES_PER_LEVEL -1) do
    Result[i] := Low(TSkillPanelButton); // placeholder for any skill
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL] := spbPause;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 1] := spbNuke;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 2] := spbFastForward;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 3] := spbRestart;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 4] := spbBackOneFrame; // and below: spbForwardOneFrame
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 5] := spbDirLeft; // and below: spbDirRight
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 6] := spbPhysicsView; // and below: spbLoadReplay
end;

procedure TSkillPanelStandard.ResizeMinimapRegion(MinimapRegion: TBitmap32);
var
  TempBmp: TBitmap32;
begin
  TempBmp := TBitmap32.Create;
  TempBmp.Assign(MinimapRegion);

  if (MinimapRegion.Width <> 222) or (MinimapRegion.Height <> 76) then
  begin
    MinimapRegion.SetSize(222, 78);
    MinimapRegion.Clear($FF000000);
    DrawNineSlice(MinimapRegion, MinimapRegion.BoundsRect, TempBmp.BoundsRect,
                  Rect(16, 16, 16, 16), TempBmp);
  end;

  TempBmp.Free;
end;


{ TSkillPanelCompact }

constructor TSkillPanelCompact.CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow);
begin
  inherited;
end;

destructor TSkillPanelCompact.Destroy;
begin
  inherited;
end;

function TSkillPanelCompact.PanelWidth: Integer;
begin
  Result := 640;
end;

function TSkillPanelCompact.PanelHeight: Integer;
begin
  Result := 80;
end;

function TSkillPanelCompact.DrawStringLength: Integer;
begin
  Result := 38;
end;

function TSkillPanelCompact.DrawStringTemplate: string;
begin
  Result := '............' + '.' + ' ' + #92 + '_...' + ' ' + #93 + '_...' + ' '
                           + #94 + '_...' + ' ' + #95 +  '_.-..';
end;

function TSkillPanelCompact.CursorInfoEndIndex: Integer;
begin
  Result := 12;
end;

function TSkillPanelCompact.LemmingCountStartIndex: Integer;
begin
  Result := 21;
end;

function TSkillPanelCompact.SaveCountStartIndex: Integer;
begin
  Result := 27;
end;

function TSkillPanelCompact.TimeLimitStartIndex: Integer;
begin
  Result := 33;
end;

function TSkillPanelCompact.MinimapRect: TRect;
begin
  Result := Rect(456, 36, 632, 76)
end;

// Assigns a clickable rectangle to the replay "R" icon
function TSkillPanelCompact.ReplayIconRect: TRect;
begin
  Result := Rect(190, 0, 208, 32);
end;

// Assigns a non-clickable rectangle to the hatch count icon & digits
function TSkillPanelCompact.HatchIconRect: TRect;
begin
  Result := Rect(224, 4, 312, 32);
end;

// Assigns a non-clickable rectangle to the alive count icon & digits
function TSkillPanelCompact.AliveIconRect: TRect;
begin
  Result := Rect(320, 4, 408, 32);
end;

// Assigns a non-clickable rectangle to the saved count icon & digits
function TSkillPanelCompact.ExitIconRect: TRect;
begin
  Result := Rect(416, 4, 504, 32);
end;

// Assigns a non-clickable rectangle to the timer icon & digits
function TSkillPanelCompact.TimeIconRect: TRect;
begin
  Result := Rect(512, 4, 608, 32);
end;

procedure TSkillPanelCompact.CreateNewInfoString;
begin
  SetInfoCursor(1);
  SetInfoLemHatch(16);
  SetInfoLemAlive(22);
  SetExitIcon(27);
  SetInfoLemIn(28);
  SetTimeLimit(33);
  SetInfoTime(34, 37);
end;

function TSkillPanelCompact.GetButtonList: TPanelButtonArray;
var
  i : Integer;
begin
  SetLength(Result, 14);
  Result[0] := spbSlower;
  Result[1] := spbFaster;
  for i := 2 to (2 + MAX_SKILL_TYPES_PER_LEVEL - 1) do
    Result[i] := Low(TSkillPanelButton); // placeholder for any skill
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL] := spbPause;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 1] := spbNuke;
end;

procedure TSkillPanelCompact.ResizeMinimapRegion(MinimapRegion: TBitmap32);
var
  TempBmp: TBitmap32;
begin
  TempBmp := TBitmap32.Create;
  TempBmp.Assign(MinimapRegion);

  if (MinimapRegion.Width <> 190) or (MinimapRegion.Height <> 48) then
  begin
    MinimapRegion.SetSize(190, 48);
    MinimapRegion.Clear($FF000000);
    DrawNineSlice(MinimapRegion, MinimapRegion.BoundsRect, TempBmp.BoundsRect,
                  Rect(16, 16, 16, 16), TempBmp);
  end;

  TempBmp.Free;
end;


end.

