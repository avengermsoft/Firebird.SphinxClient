unit SphinxClient;

interface

uses System.SysUtils, System.Classes, u_SphinxMySQL;

type
  TSphinxClient = class(TObject)
  private
    FOccupied: Boolean;
    FServer: String;
    FPort: Cardinal;
    FClient: TSphinxMySQLClientLibrary;
    FConnect: PMySQL;
    FResult: PMySQLResult;
    FFieldsCount: Integer;
    FRow: PMySQLRow;
    FRowLengths: PMySQLLengths;
    FConnected: Boolean;
  protected
    procedure   FreeResult;
  public
    constructor Create(const ALibName, AServer: String; APort: Cardinal = 0);
    destructor  Destroy; override;
    procedure   Connect;
    procedure   Disconnect;
    function    ExecSQL(const ASQLText: UTF8String): Boolean;
    function    Next: Boolean;
    function    EOF: Boolean;
    function    GetCurrentValue(const AFieldIndex: Integer): TBytes;
  end;

  TSphinxClientManager = class(TObject)
  private
    FClients: TThreadList;
    FLibName: String;
    FServer: String;
    FPort: Cardinal;
  protected
    function    GetClient(Index: Integer): TSphinxClient;
  public
    constructor Create(const ALibName, AServer: String; APort: Cardinal = 0);
    destructor  Destroy; override;
    function    CreateClient: Integer;
    procedure   FreeClient(const Index: Integer);
    property    Clients[Index: Integer]: TSphinxClient read GetClient;
  end;

implementation

(*
################################################################################
### TSphinxClient
*)
constructor TSphinxClient.Create(const ALibName, AServer: String; APort: Cardinal);
begin
  inherited Create;
  FOccupied    := True;
  FServer      := AServer;
  FPort        := APort;
  FClient      := TSphinxMySQLClientLibrary.Create(ALibName);
  FConnect     := nil;
  FResult      := nil;
  FFieldsCount := 0;
  FRow         := nil;
  FRowLengths  := nil;
  FConnected   := False;
end;

destructor TSphinxClient.Destroy;
begin
  Disconnect;
  FreeAndNil(FClient);
  inherited Destroy;
end;

procedure TSphinxClient.FreeResult;
begin
  if Assigned(FResult) then
  begin
    FClient.mysql_free_result(FResult);
    FResult      := nil;
    FFieldsCount := 0;
  end;
end;

procedure TSphinxClient.Connect;
var
  ATimeout: Cardinal;
begin
  FConnect   := FClient.mysql_init(nil);
  ATimeout   := 5;
  FClient.mysql_options(FConnect, MYSQL_OPT_CONNECT_TIMEOUT, @ATimeout);
  FConnected := Assigned(FClient.mysql_real_connect(FConnect, PAnsiChar(AnsiString(FServer)), nil, nil, nil, FPort, nil, 0));
  if FConnected then
    FClient.mysql_set_character_set(FConnect, 'UTF8');
end;

procedure TSphinxClient.Disconnect;
begin
  FConnected := False;
  FreeResult;
  if Assigned(FConnect) then
  begin
    FClient.mysql_close(FConnect);
    FConnect := nil;
  end;
end;

function TSphinxClient.ExecSQL(const ASQLText: UTF8String): Boolean;
var
  AErrorCode: Integer;
begin
  FreeResult;
  AErrorCode := -1;
  if FConnected then
  begin
    AErrorCode := FClient.mysql_real_query(FConnect, PAnsiChar(ASQLText), Length(ASQLText));
    if AErrorCode <> 0 then
    begin
      // Reconnect
      Disconnect;
      Connect;
    end;
  end
  else
    Connect;
  if AErrorCode <> 0 then
    AErrorCode := FClient.mysql_real_query(FConnect, PAnsiChar(ASQLText), Length(ASQLText));
  if AErrorCode = 0 then
  begin
    FResult := FClient.mysql_store_result(FConnect);
    if Assigned(FResult) then
    begin
      FFieldsCount := FClient.mysql_num_fields(FResult);
      Next;
    end;
  end;
  Result := AErrorCode = 0;
end;

function TSphinxClient.Next: Boolean;
begin
  if FConnected and Assigned(FResult) then
  begin
    FRow        := FClient.mysql_fetch_row(FResult);
    FRowLengths := FClient.mysql_fetch_lengths(FResult);
  end
  else
  begin
    FRow        := nil;
    FRowLengths := nil;
  end;
  Result        := not EOF;
end;

function TSphinxClient.EOF: Boolean;
begin
  EOF := not(FConnected and Assigned(FRow) and Assigned(FRowLengths));
end;

function TSphinxClient.GetCurrentValue(const AFieldIndex: Integer): TBytes;
var
  ALen: Cardinal;
begin
  if (not EOF) and (AFieldIndex > -1) and (AFieldIndex < FFieldsCount) then
  begin
    ALen := FRowLengths[AFieldIndex];
    SetLength(Result, ALen);
    if ALen > 0 then
      Move(FRow[AFieldIndex]^, Result[0], ALen);
  end
  else
    SetLength(Result, 0);
end;
(*
### TSphinxClient
################################################################################
*)

(*
################################################################################
### TSphinxClientManager
*)
constructor TSphinxClientManager.Create(const ALibName, AServer: String; APort: Cardinal);
begin
  inherited Create;
  FClients := TThreadList.Create;
  FLibName := ALibName;
  FServer  := AServer;
  FPort    := APort;
end;

destructor TSphinxClientManager.Destroy;
var
  i: Integer;
  AClients: TList;
  AClient: TSphinxClient;
begin
  AClients := FClients.LockList;
  try
    for i := AClients.Count - 1 downto 0 do
    begin
      AClient := TSphinxClient(AClients[i]);
      if Assigned(AClient) then
      begin
        FreeAndNil(AClient);
        AClients[i] := nil;
      end;
    end;
  finally
    FClients.UnlockList;
  end;
  FreeAndNil(FClients);
  inherited Destroy;
end;

function TSphinxClientManager.CreateClient: Integer;
var
  i: Integer;
  AClients: TList;
  AClient: TSphinxClient;
begin
  AClients := FClients.LockList;
  try
    for i := AClients.Count - 1 downto 0 do
    begin
      AClient := TSphinxClient(AClients[i]);
      if Assigned(AClient) and not AClient.FOccupied then
      begin
        Result            := i;
        AClient.FOccupied := True;
        Exit;
      end;
    end;
    // Else?
    Result := AClients.Add( TSphinxClient.Create(FLibName, FServer, FPort) );
  finally
    FClients.UnlockList;
  end;
end;

procedure TSphinxClientManager.FreeClient(const Index: Integer);
var
  AClients: TList;
  AClient: TSphinxClient;
begin
  AClients := FClients.LockList;
  try
    if (Index > -1) and (Index < AClients.Count) then
    begin
      AClient := TSphinxClient(AClients[Index]);
      if Assigned(AClient) then
      begin
        AClient.FOccupied := False;
        AClient.Disconnect;
      end;
    end;
  finally
    FClients.UnlockList;
  end;
end;

function TSphinxClientManager.GetClient(Index: Integer): TSphinxClient;
var
  AClients: TList;
begin
  Result   := nil;
  AClients := FClients.LockList;
  try
    if (Index > -1) and (Index < AClients.Count) then
      Result := TSphinxClient(AClients[Index]);
  finally
    FClients.UnlockList;
  end;
end;
(*
### TSphinxClientManager
################################################################################
*)

end.

