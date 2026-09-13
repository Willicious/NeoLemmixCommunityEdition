{$include lem_directives.inc}
unit GameSkillPanel;

interface

uses
  LemTypes,
  Math, Classes, GR32,
  GameWindowInterface, GameBaseSkillPanel,
  SharedGlobals;

type
  TSkillPanel = class(TBaseSkillPanel)
  protected
    function CompactSkillPanel: Boolean;
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
  public
    constructor CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow); override;
    destructor Destroy; override;
  end;

implementation

uses
  GameControl, LemCore;

{ TSkillPanelStandard }

constructor TSkillPanel.CreateWithWindow(aOwner: TComponent; aGameWindow: IGameWindow);
begin
  inherited;
end;

destructor TSkillPanel.Destroy;
begin
  inherited;
end;

function TSkillPanel.CompactSkillPanel: Boolean;
begin
  Result := GameParams.CompactSkillPanel;
end;

function TSkillPanel.PanelWidth: Integer;
begin
  if CompactSkillPanel then
    Result := 640
  else
    Result := 832;
end;

function TSkillPanel.PanelHeight: Integer;
begin
  Result := 80;
end;

function TSkillPanel.MinimapRect: TRect;
begin
  if CompactSkillPanel then
    Result := Rect(456, 36, 632, 76)
  else
    Result := Rect(616, 6, 824, 74);
end;

function TSkillPanel.ReplayIconRect: TRect;
begin
  if CompactSkillPanel then
    Result := Rect(190, 0, 208, 32)
  else
    Result := Rect(190, 0, 208, 32);
end;

function TSkillPanel.HatchIconRect: TRect;
begin
  if CompactSkillPanel then
    Result := Rect(224, 0, 312, 32)
  else
    Result := Rect(224, 0, 312, 32);
end;

function TSkillPanel.AliveIconRect: TRect;
begin
  if CompactSkillPanel then
    Result := Rect(320, 0, 408, 32)
  else
    Result := Rect(320, 0, 408, 32);
end;

function TSkillPanel.ExitIconRect: TRect;
begin
  if CompactSkillPanel then
    Result := Rect(416, 0, 504, 32)
  else
    Result := Rect(416, 0, 504, 32);
end;

function TSkillPanel.TimeIconRect: TRect;
begin
  if CompactSkillPanel then
    Result := Rect(512, 0, 608, 32)
  else
    Result := Rect(512, 0, 608, 32);
end;

function TSkillPanel.GetButtonList: TPanelButtonArray;
var
  i : Integer;
begin
  SetLength(Result, IfThen(CompactSkillPanel, 14, 19));
  Result[0] := spbSlower;
  Result[1] := spbFaster;
  for i := 2 to (2 + MAX_SKILL_TYPES_PER_LEVEL -1) do
    Result[i] := Low(TSkillPanelButton); // placeholder for any skill
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL] := spbPause;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 1] := spbNuke;

  if CompactSkillPanel then
    Exit;

  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 2] := spbFastForward;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 3] := spbRestart;
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 4] := spbBackOneFrame; // and below: spbForwardOneFrame
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 5] := spbDirLeft; // and below: spbDirRight
  Result[2 + MAX_SKILL_TYPES_PER_LEVEL + 6] := spbPhysicsView; // and below: spbLoadReplay
end;

procedure TSkillPanel.ResizeMinimapRegion(MinimapRegion: TBitmap32);
var
  TempBmp: TBitmap32;
  AllocatedWidth, AllocatedHeight: Integer;
begin
  TempBmp := TBitmap32.Create;
  TempBmp.Assign(MinimapRegion);

  if CompactSkillPanel then
  begin
    AllocatedWidth := 190;
    AllocatedHeight := 48;
  end else begin
    Width := 222;
    AllocatedHeight := 76;
  end;

  if (MinimapRegion.Width <> AllocatedWidth) or (MinimapRegion.Height <> AllocatedHeight) then
  begin
    MinimapRegion.SetSize(AllocatedWidth, AllocatedHeight);
    MinimapRegion.Clear($FF000000);
    DrawNineSlice(MinimapRegion, MinimapRegion.BoundsRect, TempBmp.BoundsRect,
                  Rect(16, 16, 16, 16), TempBmp);
  end;

  TempBmp.Free;
end;

end.
