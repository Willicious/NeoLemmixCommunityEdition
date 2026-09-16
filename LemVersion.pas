unit LemVersion;

// Contains constants and functions relating to version numbers.

interface

uses
  UMisc, Classes, SysUtils, SharedGlobals;

const
  MAJOR_VERSION = 1;
  MINOR_VERSION = 2;
  HOTFIX_VERSION = 0;
  RC_VERSION = 0;

  STYLE_VERSION = '12.11/'; // For server usage - a new style version should only be used when backwards compatibility breaks.
                            // Make sure to include the trailing backslash.

  function COMMIT_ID: String;

function MakeVersionString(Major, Minor, Hotfix, RC: Integer): String;
function MakeVersionID(Major, Minor, Hotfix, RC: Integer): Int64;
function CurrentVersionString: String;
function CurrentVersionID: Int64;

implementation

uses
  LemVersionCommitID;

function COMMIT_ID: String;
begin
  Result := LemVersionCommitID.COMMIT_ID;
end;

function CurrentVersionString: String;
begin
  Result := MakeVersionString(MAJOR_VERSION, MINOR_VERSION, HOTFIX_VERSION, RC_VERSION);
end;

function CurrentVersionID: Int64;
begin
  Result := MakeVersionID(MAJOR_VERSION, MINOR_VERSION, HOTFIX_VERSION, RC_VERSION);
end;

function MakeVersionString(Major, Minor, Hotfix, RC: Integer): String;
  function NumberToLetters(aValue: Integer): String;
  var
    n: Integer;
  begin
    Result := '';
    repeat
      n := aValue mod 26;
      Result := Char(n + 64) + Result;
      aValue := aValue div 26;
    until aValue = 0;
  end;
begin
  Result := IntToStr(Major);
  Result := Result + '.' + IntToStr(Minor);

  if Hotfix > 0 then
    Result := Result + '.' + IntToStr(Hotfix);

  {$ifdef rc}
  Result := Result + '-RC' + IntToStr(RC);
  {$endif}
end;

function MakeVersionID(Major, Minor, Hotfix, RC: Integer): Int64;
begin
  Result := Major;
  Result := (Result * 1000) + Minor;
  Result := (Result * 1000) + Hotfix;
  Result := (Result * 1000) {$ifndef rc}+ RC{$endif};
end;

end.