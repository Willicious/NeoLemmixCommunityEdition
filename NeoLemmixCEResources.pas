unit NeoLemmixCEResources;

interface

uses
  Classes, SysUtils,
  GameControl,
  LemStrings,
  LemTypes,
  LemNeoParser;

function HasEmbeddedResource(const ResName: string): Boolean;
function LoadEmbeddedTextIfExists(const ResName: string; out Text: string): Boolean;
function LoadEmbeddedNxmiToParser(const ResName: string; Parser: TParser): Boolean;
function LoadNxmiWithOverrides(const FileName: string; const ResName: string; Parser: TParser): Boolean;

implementation

uses
  Windows;

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
    if PackPath <> '' then
    begin
      Parser.LoadFromFile(PackPath);
      Exit;
    end;
  end;

  // 2) CE-assets override
  if FileExists(AssetsCEPath + SFData + FileName) then
  begin
    Parser.LoadFromFile(AssetsCEPath + SFData + FileName);
    Exit;
  end;

  // 3) Embedded fallback
  if LoadEmbeddedNxmiToParser(ResName, Parser) then
    Exit;

  // 4) Legacy fallback
  if FileExists(AppPath + SFData + FileName) then
  begin
    Parser.LoadFromFile(AppPath + SFData + FileName);
    Exit;
  end;

  Result := False;
end;

end.
