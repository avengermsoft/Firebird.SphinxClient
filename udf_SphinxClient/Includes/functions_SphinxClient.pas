unit functions_SphinxClient;

{$INCLUDE udf_SphinxClient.inc}

interface

function ClientCreate: Integer; cdecl;
function ClientFree(const AClientID: PInteger): Integer; cdecl;
function ClientNext(const AClientID: PInteger): Integer; cdecl;
function ClientEOF(const AClientID: PInteger): Integer; cdecl;
function ClientExecSQL(const AClientID: PInteger; const AInput: PAnsiChar): Integer; cdecl;
procedure ClientGetCurrentValue(const AClientID, AFieldIndex: PInteger; AResultStr: PAnsiChar); cdecl;
procedure QuotedStr(const AInput: PAnsiChar; AResultStr: PAnsiChar); cdecl;

implementation

uses
  {$IFNDEF FPC}
  System.SysUtils, Winapi.Windows, System.IniFiles, System.AnsiStrings, SphinxClient
  {$ELSE}
  SysUtils, IniFiles, SphinxClient
  {$ENDIF};

var
  ClientManager: TSphinxClientManager = nil;

function ClientCreate: Integer; cdecl;
begin
  with ClientManager do
    Result := CreateClient;
end;

function ClientFree(const AClientID: PInteger): Integer; cdecl;
begin
  with ClientManager do
    if Assigned(Clients[AClientID^]) then
    begin
      FreeClient(AClientID^);
      Result := 1;
    end
    else
      Result := -1;
end;

function ClientNext(const AClientID: PInteger): Integer; cdecl;
begin
  with ClientManager do
    if Assigned(Clients[AClientID^]) and Clients[AClientID^].Next then
      Result := 1
    else
      Result := -1;
end;

function ClientEOF(const AClientID: PInteger): Integer; cdecl;
begin
  with ClientManager do
    if Assigned(Clients[AClientID^]) and not Clients[AClientID^].EOF then
      Result := 1
    else
      Result := -1;
end;

function ClientExecSQL(const AClientID: PInteger; const AInput: PAnsiChar): Integer; cdecl;
begin
  with ClientManager do
    if Assigned(Clients[AClientID^]) and Assigned(AInput) and Clients[AClientID^].ExecSQL(UTF8String(AInput)) then
      Result := 1
    else
      Result := -1;
end;

procedure ClientGetCurrentValue(const AClientID, AFieldIndex: PInteger; AResultStr: PAnsiChar); cdecl;
var
  ABuf: TBytes;
  ALen: Cardinal;
begin
  with ClientManager do
    if Assigned(Clients[AClientID^]) and not Clients[AClientID^].EOF then
      ABuf := Clients[AClientID^].GetCurrentValue(AFieldIndex^)
    else
      SetLength(ABuf, 0);
  ALen := Length(ABuf);
  if ALen > 0 then
    Move(ABuf[0], AResultStr^, ALen);
  AResultStr[ALen] := #0;
end;

procedure QuotedStr(const AInput: PAnsiChar; AResultStr: PAnsiChar); cdecl;
var
  AStr: UTF8String;
begin
  AStr := '';
  if Assigned(AInput) then
    AStr := {$IFNDEF FPC}UTF8Encode{$ENDIF}({$IFNDEF FPC}System.{$ENDIF}SysUtils.QuotedStr({$IFNDEF FPC}UTF8ToString{$ENDIF}(AInput)));
  {$IFNDEF FPC}System.AnsiStrings.{$ENDIF}StrLCopy(AResultStr, PAnsiChar(AStr), Length(AStr));
end;

procedure InitClientManager;
var
  {$IFDEF WINDOWS}
  P: PChar;
  {$ENDIF}
  AModuleName: String;
  ALibName: String;
  AServer: String;
  APort: Integer;
begin
  {$IFDEF WINDOWS}
  GetMem(P, MAX_PATH);
  try
    SetString(AModuleName, P, GetModuleFileName(HInstance, P, MAX_PATH));
  finally
    FreeMem(P);
  end;
  AModuleName   := ChangeFileExt(AModuleName, '.ini');
  {$ENDIF}
  {$IFDEF LINUX}
  AModuleName   := '/etc/firebird/udf_SphinxClient.conf';
  {$ENDIF}
  ALibName      := 'libmysql.dll';
  AServer       := '127.0.0.1';
  APort         := 9306;
  if FileExists(AModuleName) then
  begin
    with TIniFile.Create(AModuleName) do
    try
      ALibName  := Trim(ReadString('SphinxClient', 'Library', ALibName));
      AServer   := Trim(ReadString('SphinxClient', 'Server', AServer));
      APort     := ReadInteger('SphinxClient', 'Port', APort);
    finally
      Free;
    end;
  end;
  ClientManager := TSphinxClientManager.Create(ALibName, AServer, Cardinal(APort));
end;

initialization
  InitClientManager;

finalization
  if Assigned(ClientManager) then
    FreeAndNil(ClientManager);

end.
