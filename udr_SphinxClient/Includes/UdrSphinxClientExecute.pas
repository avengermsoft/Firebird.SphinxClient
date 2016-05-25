unit UdrSphinxClientExecute;

{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses System.SysUtils, Firebird, u_SphinxMySQL, Winapi.Windows, System.IniFiles;

type
  PSphinxClientExecuteInMessage = ^TSphinxClientExecuteInMessage;
  TSphinxClientExecuteInMessage = record
    StrLen: Word;
    Str: array [0..4*8000 - 1] of AnsiChar;
    StrNull: WordBool;
  end;

  PSphinxClientExecuteOutMessage = ^TSphinxClientExecuteOutMessage;
  TSphinxClientExecuteOutMessage = record
    ModuleID: Int64;
    ModuleIDNull: WordBool;
    RowIDLen: Word;
    RowID: array [0..128 - 1] of AnsiChar;
    RowIDNull: WordBool;
  end;

  TSphinxClientExecuteResultSet = class(IExternalResultSetImpl)
    procedure dispose(); override;
    function fetch(status: IStatus): Boolean; override;
  public
    FOutMessage: PSphinxClientExecuteOutMessage;
    // Sphinx
    FClient: TSphinxMySQLClientLibrary;
    FConnect: PMySQL;
    FResult: PMySQLResult;
  end;

  TSphinxClientExecuteProcedure = class(IExternalProcedureImpl)
    procedure dispose(); override;
    procedure getCharSet(status: IStatus; context: IExternalContext; name: PAnsiChar; nameSize: Cardinal); override;
    function open(status: IStatus; context: IExternalContext; inMsg: Pointer; outMsg: Pointer): IExternalResultSet; override;
  private
    FLibName: String;
    FServer: String;
    FPort: Cardinal;
    procedure ReadParams;
  end;

  TSphinxClientExecuteFactory = class(IUdrProcedureFactoryImpl)
    procedure dispose(); override;
    procedure setup(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata; inBuilder: IMetadataBuilder; outBuilder: IMetadataBuilder); override;
    function newItem(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata): IExternalProcedure; override;
  end;

implementation

{ TSphinxClientExecuteResultSet }

procedure TSphinxClientExecuteResultSet.dispose();
begin
  if Assigned(FResult) then
  begin
    FClient.mysql_free_result(FResult);
    FResult  := nil;
  end;
  if Assigned(FConnect) then
  begin
    FClient.mysql_close(FConnect);
    FConnect := nil;
  end;
  if Assigned(FClient) then
    FreeAndNil(FClient);
  destroy;
end;

function TSphinxClientExecuteResultSet.fetch(status: IStatus): Boolean;
var
  ARow: PMySQLRow;
  ARowL: PMySQLLengths;
begin
  Result               := False;
  try
    if Assigned(FClient) and Assigned(FConnect) and Assigned(FResult) then
    begin
      ARow             := FClient.mysql_fetch_row(FResult);
      ARowL            := FClient.mysql_fetch_lengths(FResult);
      Result           := Assigned(ARow) and Assigned(ARowL);
      if Result then
      begin
        with FOutMessage^ do
        begin
          ModuleIDNull := ARowL[0] = 0;
          ModuleID     := StrToInt64Def(String(ARow[0]^), 0);
          RowIDLen     := ARowL[1];
          RowIDNull    := RowIDLen = 0;
          if RowIDLen > 0 then
            Move(PAnsiChar(ARow[1])^, RowID[0], RowIDLen * SizeOf(AnsiChar));
        end;
      end;
    end;
  except
    on E: Exception do
      FbException.catchException(status, E);
  end;
end;

{ TSphinxClientExecuteProcedure }

procedure TSphinxClientExecuteProcedure.ReadParams;
var
  P: PChar;
  AModuleName: String;
begin
  GetMem(P, MAX_PATH);
  try
    SetString(AModuleName, P, GetModuleFileName(HInstance, P, MAX_PATH));
  finally
    FreeMem(P);
  end;
  AModuleName  := ChangeFileExt(AModuleName, '.ini');
  FLibName     := 'libmysql.dll';
  FServer      := '127.0.0.1';
  FPort        := 9306;
  if FileExists(AModuleName) then
  begin
    with TIniFile.Create(AModuleName) do
    try
      FLibName := Trim(ReadString('SphinxClient', 'Library', FLibName));
      FServer  := Trim(ReadString('SphinxClient', 'Server', FServer));
      FPort    := ReadInteger('SphinxClient', 'Port', FPort);
    finally
      Free;
    end;
  end;
end;

procedure TSphinxClientExecuteProcedure.dispose();
begin
  destroy;
end;

procedure TSphinxClientExecuteProcedure.getCharSet(status: IStatus; context: IExternalContext; name: PAnsiChar; nameSize: Cardinal);
begin
end;

function TSphinxClientExecuteProcedure.open(status: IStatus; context: IExternalContext; inMsg: Pointer; outMsg: Pointer): IExternalResultSet;
var
  AClient: TSphinxMySQLClientLibrary;
  AConnect: PMySQL;
  ATimeout: Cardinal;
  ASQLText: UTF8String;
  AResult: PMySQLResult;
  AFieldsCount: Integer;
  ARet: TSphinxClientExecuteResultSet;
begin
  ARet                      := nil;
  try
    ARet                    := TSphinxClientExecuteResultSet.create();
    with ARet do
    begin
      FOutMessage           := nil;
      FResult               := nil;
      FConnect              := nil;
      FClient               := nil;
    end;
    ReadParams;
    AClient                 := TSphinxMySQLClientLibrary.Create(FLibName);
    try
      // Init
      AConnect              := AClient.mysql_init(nil);
      ATimeout              := 5;
      AClient.mysql_options(AConnect, MYSQL_OPT_CONNECT_TIMEOUT, @ATimeout);
      // Connect
      if Assigned(AClient.mysql_real_connect(AConnect, PAnsiChar(AnsiString(FServer)), nil, nil, nil, FPort, nil, 0)) then
      try
        if AClient.mysql_set_character_set(AConnect, 'UTF8') <> 0 then
          raise Exception.Create(String(AClient.mysql_error(AConnect)));
        with PSphinxClientExecuteInMessage(inMsg)^ do
        begin
          if (not StrNull) and (StrLen > 0) then
            ASQLText        := Str
          else
            ASQLText        := '';
        end;
        // ExecSQL
        if AClient.mysql_real_query(AConnect, PAnsiChar(ASQLText), Length(ASQLText)) = 0 then
        begin
          AResult           := AClient.mysql_store_result(AConnect);
          if Assigned(AResult) then
          try
            AFieldsCount    := AClient.mysql_num_fields(AResult);
            if AFieldsCount = 2 then
            begin
              with ARet do
              begin
                FOutMessage := outMsg;
                FResult     := AResult;
                FConnect    := AConnect;
                FClient     := AClient;
                AResult     := nil;
                AConnect    := nil;
                AClient     := nil;
              end;
            end;
          finally
            if Assigned(AResult) then
              AClient.mysql_free_result(AResult);
          end
          else
            raise Exception.Create(String(AClient.mysql_error(AConnect)));
        end
        else
          raise Exception.Create(String(AClient.mysql_error(AConnect)));
      finally
        if Assigned(AConnect) then
          AClient.mysql_close(AConnect);
      end
      else
        raise Exception.Create(String(AClient.mysql_error(AConnect)));
    finally
      if Assigned(AClient) then
        FreeAndNil(AClient);
    end;
  except
    on E: Exception do
      FbException.catchException(status, E);
  end;
  Result                    := ARet;
end;

{ TSphinxClientExecuteFactory }

procedure TSphinxClientExecuteFactory.dispose();
begin
  destroy;
end;

procedure TSphinxClientExecuteFactory.setup(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata; inBuilder: IMetadataBuilder; outBuilder: IMetadataBuilder);
begin
end;

function TSphinxClientExecuteFactory.newItem(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata): IExternalProcedure;
begin
  Result := TSphinxClientExecuteProcedure.create;
end;

end.
