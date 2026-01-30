unit NeoLemmixCEResources;

interface

uses
  Classes, SysUtils, Dialogs,
  LemStrings, LemTypes, LemNeoParser,
  PngInterface,
  GR32,
  SharedGlobals;

function HasEmbeddedResource(const ResName: string): Boolean;
function LoadEmbeddedTextIfExists(const ResName: string; out Text: string): Boolean;
function LoadEmbeddedNxmiToParser(const ResName: string; Parser: TParser): Boolean;
function LoadNxmiWithOverrides(const FileName: string; const ResName: string; Parser: TParser): Boolean;
function LoadEmbeddedResourceToStream(const ResName: string; aStream: TStream): Boolean;
function LoadGraphicWithOverrides(const aFolder, aFileName, aEmbeddedName: String; aDst: TBitmap32; BypassLevelPack: Boolean = False): Boolean;
function LoadEmbeddedSleeperSpriteToBitmap32(const ResName: string; aDst: TBitmap32): Boolean;
function LoadEmbeddedSleeperSprite(aDst: TBitmap32; HighRes: Boolean): Boolean;
function LoadEmbeddedGraphic(const aEmbeddedName: string; aDst: TBitmap32): Boolean;

implementation

uses
  Windows, GameControl;

function HasEmbeddedResource(const ResName: string): Boolean;
begin
  Result :=
    FindResource(HInstance, PChar(ResName), RT_RCDATA) <> 0;
end;

function LoadEmbeddedText(const ResName: string): string;
var
  RS: TResourceStream;
  SS: TStringStream;
begin
  RS := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  try
    SS := TStringStream.Create('', TEncoding.UTF8);
    try
      SS.CopyFrom(RS, RS.Size);
      Result := SS.DataString;
    finally
      SS.Free;
    end;
  finally
    RS.Free;
  end;
end;

function LoadEmbeddedTextIfExists(const ResName: string; out Text: string): Boolean;
var
  RS: TResourceStream;
  SS: TStringStream;
begin
  Result := False;
  Text := '';

  if FindResource(HInstance, PChar(ResName), RT_RCDATA) = 0 then
    Exit;

  RS := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  try
    SS := TStringStream.Create('', TEncoding.UTF8);
    try
      SS.CopyFrom(RS, RS.Size);
      Text := SS.DataString;
      Result := True;
    finally
      SS.Free;
    end;
  finally
    RS.Free;
  end;
end;

function LoadEmbeddedNxmiToParser(const ResName: string; Parser: TParser): Boolean;
var
  Text: string;
  SL: TStringList;
begin
  Result := False;

  if not LoadEmbeddedTextIfExists(ResName, Text) then
    Exit;

  SL := TStringList.Create;
  try
    SL.Text := Text;
    Parser.LoadFromStrings(SL);
    Result := True;
  finally
    SL.Free;
  end;
end;

function LoadNxmiWithOverrides(const FileName: string; const ResName: string; Parser: TParser): Boolean;
var
  PackPath: string;
begin
  Result := True;

  // 1) Level pack override
  if (GameParams.CurrentLevel <> nil)
    and (GameParams.CurrentLevel.Group <> nil) then
  begin
    PackPath := GameParams.CurrentLevel.Group.FindFile(FileName);

    if PackPath = '' then
      PackPath := GameParams.CurrentLevel.Group.FindFile(SFCEPrefix + FileName);

    if PackPath <> '' then
    begin
      Parser.LoadFromFile(PackPath);
      Exit;
    end;
  end;

  // 2) File system fallback
  if FileExists(AppPath + SFData + SFCEPrefix + FileName) then
  begin
    Parser.LoadFromFile(AppPath + SFData + SFCEPrefix + FileName);
    Exit;
  end;

  // 3) Embedded fallback
  if LoadEmbeddedNxmiToParser(ResName, Parser) then
    Exit;

  Result := False;
end;

function LoadEmbeddedResourceToStream(const ResName: string; aStream: TStream): Boolean;
var
  ResStream: TResourceStream;
begin
  try
    ResStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
    try
      aStream.CopyFrom(ResStream, ResStream.Size);
      aStream.Position := 0;
      Result := True;
    finally
      ResStream.Free;
    end;
  except
    Result := False;
  end;
end;

function LoadGraphicWithOverrides(const aFolder, aFileName, aEmbeddedName: String; aDst: TBitmap32; BypassLevelPack: Boolean = False): Boolean;
var
  FilePath, PackPath: String;
  Stream: TMemoryStream;
begin
  Result := False;

  // 1) Level pack override
  if (GameParams.CurrentLevel <> nil) and (GameParams.CurrentLevel.Group <> nil)
  and not BypassLevelPack then
  begin
    PackPath := GameParams.CurrentLevel.Group.FindFile(aFileName);

    if PackPath = '' then
      PackPath := GameParams.CurrentLevel.Group.FindFile(SFCEPrefix + aFileName);

    if PackPath <> '' then
    begin
      TPngInterface.LoadPngFile(PackPath, aDst);
      Result := True;
      Exit;
    end;
  end;

  // 2) File system fallback
  FilePath := AppPath + aFolder + SFCEPrefix + aFileName;
  if FileExists(FilePath) then
  begin
    TPngInterface.LoadPngFile(FilePath, aDst);
    Result := True;
  end;

  // 3) Embedded fallback
  Stream := TMemoryStream.Create;
  try
    if LoadEmbeddedResourceToStream(aEmbeddedName, Stream) then
    begin
      Stream.Position := 0;
      TPngInterface.LoadPngStream(Stream, aDst);
      Result := True;
      Exit;
    end;
  finally
    Stream.Free;
  end;
end;

function LoadEmbeddedSleeperSpriteToBitmap32(const ResName: string; aDst: TBitmap32): Boolean;
var
  ResStream: TResourceStream;
begin
  Result := False;
  if aDst = nil then Exit;

  try
    ResStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
    try
      aDst.LoadFromStream(ResStream);
      aDst.DrawMode := dmBlend;
      Result := True;
    finally
      ResStream.Free;
    end;
  except
    Result := False;
  end;
end;

function LoadEmbeddedSleeperSprite(aDst: TBitmap32; HighRes: Boolean): Boolean;
var
  ResName: string;
begin
  if HighRes then
    ResName := 'SLEEPER_HR_PNG'
  else
    ResName := 'SLEEPER_PNG';

  Result := LoadEmbeddedSleeperSpriteToBitmap32(ResName, aDst);
end;

function LoadEmbeddedGraphic(const aEmbeddedName: string; aDst: TBitmap32): Boolean;
var
  Stream: TMemoryStream;
begin
  Result := False;

  Stream := TMemoryStream.Create;
  try
    if not LoadEmbeddedResourceToStream(aEmbeddedName, Stream) then
      Exit;

    Stream.Position := 0;
    TPngInterface.LoadPngStream(Stream, aDst);
    Result := True;
  finally
    Stream.Free;
  end;
end;

end.
