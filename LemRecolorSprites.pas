unit LemRecolorSprites;

interface

uses
  Dialogs,
  Classes, SysUtils,
  LemNeoParser,
  LemNeoTheme,
  LemLemming, LemTypes, LemStrings, LemPalette,
  NeoLemmixCEResources,
  GR32, GR32_Blend;

var
  ClearPhysicsLemmingNormal: TColor32;
  ClearPhysicsLemmingAthlete: TColor32;
  ClearPhysicsLemmingNeutral: TColor32;
  ClearPhysicsLemmingZombie: TColor32;
  ClearPhysicsLemmingSelected: TColor32;

type
  TColorSwapType = (rcl_Selected,
                    rcl_Athlete,
                    rcl_Zombie,
                    rcl_Neutral);

  TColorSwap = record
    Condition: TColorSwapType;
    SrcColor: TColor32;
    DstColor: TColor32;
  end;

  // Remember - highlight needs to be hardcoded

  TColorSwapArray = array of TColorSwap;
  TSwapProgressArray = array[Low(TColorSwapType)..High(TColorSwapType)] of Boolean;

  TRecolorImage = class
    private
      fLemming: TLemming;
      fDrawAsSelected: Boolean;
      fClearPhysics: Boolean;
      fSwaps: TColorSwapArray;

      procedure SwapColors(F: TColor32; var B: TColor32);
      procedure RegisterSwap(aSec: TParserSection; const aIteration: Integer; aData: Pointer);
      procedure AddSwap(aType: TColorSwapType; aSrc, aDst: TColor32);
    public
      constructor Create;

      procedure LoadSwaps(aName: String);
      procedure ApplyPaletteSwapping(aColorDict: TColorDict; aShadeDict: TShadeDict; aTheme: TNeoTheme);
      procedure CombineLemmingPixels(F: TColor32; var B: TColor32; M: Cardinal);
      procedure CombineLemmingHighlight(F: TColor32; var B: TColor32; M: Cardinal);
      procedure LoadClearPhysicsShades;

      property Lemming: TLemming write fLemming;
      property DrawAsSelected: Boolean write fDrawAsSelected;
      property ClearPhysics: Boolean write fClearPhysics;

      class procedure CombineDefaultPixels(F: TColor32; var B: TColor32; M: Cardinal);
  end;

implementation

constructor TRecolorImage.Create;
begin
  inherited;

  // Until proper loading exists
  LoadSwaps(SFDefaultStyle);
  LoadClearPhysicsShades;
end;

procedure TRecolorImage.SwapColors(F: TColor32; var B: TColor32);
var
  i: Integer;
begin
  B := F;

  if fLemming = nil then Exit;
  if (F and $FF000000) = 0 then Exit;

  if fClearPhysics then
  begin
    if fLemming.HasPermanentSkills then
      B := ResolveColor(ClearPhysicsLemmingAthlete)
    else
      B := ResolveColor(ClearPhysicsLemmingNormal);

    if fLemming.LemIsNeutral then
      B := ResolveColor(ClearPhysicsLemmingNeutral);

    if fLemming.LemIsZombie then
      B := ResolveColor(ClearPhysicsLemmingZombie);

    if fDrawAsSelected then
      B := ResolveColor(ClearPhysicsLemmingSelected);
  end else
    for i := 0 to Length(fSwaps)-1 do
    begin
      case fSwaps[i].Condition of
        rcl_Selected: if not fDrawAsSelected then Continue;
        rcl_Zombie: if not fLemming.LemIsZombie then Continue;
        rcl_Athlete: if not fLemming.HasPermanentSkills then Continue;
        rcl_Neutral: if not fLemming.LemIsNeutral then Continue;
        else raise Exception.Create('TRecolorImage.SwapColors encountered an unknown condition' + #13 + IntToStr(Integer(fSwaps[i].Condition)));
      end;
      if (F and $FFFFFF) = fSwaps[i].SrcColor then B := fSwaps[i].DstColor;
    end;
end;

procedure TRecolorImage.CombineLemmingPixels(F: TColor32; var B: TColor32; M: Cardinal);
var
  A: TColor32;
  TempColor: TColor32;
begin
  A := (F and $FF000000);
  if A = 0 then Exit;
  SwapColors(F, TempColor);
  TempColor := (TempColor and $FFFFFF) or A;
  MergeMem(TempColor, B);
end;

procedure TRecolorImage.CombineLemmingHighlight(F: TColor32; var B: TColor32; M: Cardinal);
begin
  // photoflash
  if F <> 0 then B := clBlack32 else B := clWhite32;
end;

procedure TRecolorImage.RegisterSwap(aSec: TParserSection; const aIteration: Integer; aData: Pointer);
var
  Mode: ^TColorSwapType absolute aData;
begin
  AddSwap(Mode^, aSec.LineNumeric['from'], aSec.LineNumeric['to']);
end;

procedure TRecolorImage.LoadSwaps(aName: String);
var
  Parser: TParser;
  Mode: TColorSwapType;
begin
  SetLength(fSwaps, 0);
  Parser := TParser.Create;
  try
    if not FileExists(AppPath + SFStyles + aName + SFPiecesLemmings + 'scheme.nxmi') then
      aName := SFDefaultStyle;

    if FileExists(AppPath + SFStyles + aName + SFPiecesLemmings + 'scheme.nxmi') then
    begin
      Parser.LoadFromFile(AppPath + SFStyles + aName + SFPiecesLemmings + 'scheme.nxmi');

      if (Parser.MainSection.Section['state_recoloring'] <> nil) then
      begin
        Mode := rcl_Athlete;
        Parser.MainSection.Section['state_recoloring'].DoForEachSection('athlete', RegisterSwap, @Mode);

        Mode := rcl_Neutral;
        Parser.MainSection.Section['state_recoloring'].DoForEachSection('neutral', RegisterSwap, @Mode);

        Mode := rcl_Zombie;
        Parser.MainSection.Section['state_recoloring'].DoForEachSection('zombie', RegisterSwap, @Mode);

        Mode := rcl_Selected;
        Parser.MainSection.Section['state_recoloring'].DoForEachSection('selected', RegisterSwap, @Mode);
      end;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TRecolorImage.AddSwap(aType: TColorSwapType; aSrc, aDst: TColor32);
var
  i: Integer;
begin
  i := Length(fSwaps);
  SetLength(fSwaps, i+1);
  fSwaps[i].Condition := aType;
  fSwaps[i].SrcColor := aSrc;
  fSwaps[i].DstColor := aDst;
end;

procedure TRecolorImage.ApplyPaletteSwapping(aColorDict: TColorDict;
  aShadeDict: TShadeDict; aTheme: TNeoTheme);
var
  i, n: Integer;
  OrigSrc: TColor32;
  Pair: TColor32Pair;

  procedure MoveLastTo(aIndex: Integer);
  var
    TempSwap: TColorSwap;
    i: Integer;
  begin
    TempSwap := fSwaps[Length(fSwaps)-1];
    for i := Length(fSwaps)-1 downto aIndex+1 do
      fSwaps[i] := fSwaps[i-1];
    fSwaps[aIndex] := TempSwap;
  end;
begin
  i := 0;
  while i < Length(fSwaps) do
  begin
    OrigSrc := fSwaps[i].SrcColor;

    if aColorDict.ContainsKey(fSwaps[i].SrcColor) then
      if aTheme.DoesColorExist(aColorDict[fSwaps[i].SrcColor]) then
        fSwaps[i].SrcColor := aTheme.Colors[aColorDict[fSwaps[i].SrcColor]] and $FFFFFF;

    if aColorDict.ContainsKey(fSwaps[i].DstColor) then
      if aTheme.DoesColorExist(aColorDict[fSwaps[i].DstColor]) then
        fSwaps[i].DstColor := aTheme.Colors[aColorDict[fSwaps[i].DstColor]] and $FFFFFF;

    n := i;
    Inc(i);

    for Pair in aShadeDict do
      if (Pair.Value and $FFFFFF) = (OrigSrc and $FFFFFF) then
      begin
        AddSwap(fSwaps[n].Condition,
                ApplyColorShift(fSwaps[n].SrcColor, Pair.Value, Pair.Key),
                ApplyColorShift(fSwaps[n].DstColor, Pair.Value, Pair.Key));
        MoveLastTo(i);
        Inc(i);
      end;
  end;
end;

procedure TRecolorImage.LoadClearPhysicsShades;
var
  Nxmi: String;
  Parser: TParser;
  Sec: TParserSection;

  // Default colors, loaded if custom file doesn't exist
  procedure ResetColors;
  begin
    ClearPhysicsLemmingNormal := $FF7777FF;
    ClearPhysicsLemmingAthlete := $FF00FFFF;
    ClearPhysicsLemmingNeutral := $FFAA00FF;
    ClearPhysicsLemmingZombie := $FF777744;
    ClearPhysicsLemmingSelected := $FFFFFF77;
  end;

begin
  ResetColors;

  Parser := TParser.Create;
  try
    Nxmi := 'NLCEClearPhysicsColors.nxmi';

    if not FileExists(AppPath + SFSaveData + Nxmi) then
    begin
      with TStringList.Create do
      try
        Text := DEFAULT_CLEAR_PHYSICS_COLORS;
        SaveToFile(AppPath + SFSaveData + Nxmi);
      finally
        Free;
      end;
    end;

    Parser.LoadFromFile(AppPath + SFSaveData + Nxmi);

    Sec := Parser.MainSection.Section['lemmings'];
    if Sec = nil then Exit;

    ClearPhysicsLemmingNormal := ParseColor32(Sec, 'normal', $FF7777FF);
    ClearPhysicsLemmingAthlete := ParseColor32(Sec, 'athlete', $FF00FFFF);
    ClearPhysicsLemmingNeutral := ParseColor32(Sec, 'neutral', $FFAA00FF);
    ClearPhysicsLemmingZombie := ParseColor32(Sec, 'zombie', $FF777744);
    ClearPhysicsLemmingSelected := ParseColor32(Sec, 'selected', $FFFFFF77);
  finally
    Parser.Free;
  end;
end;

class procedure TRecolorImage.CombineDefaultPixels(F: TColor32; var B: TColor32; M: Cardinal);
begin
  if F <> 0 then B := F;
end;

end.
 