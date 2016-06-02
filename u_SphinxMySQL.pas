unit u_SphinxMySQL;

{$IFDEF FPC}
  {$MODE Delphi}
  {$H+}
{$ENDIF}

{$ALIGN ON}
{$MINENUMSIZE 4}

{$IFDEF MSWINDOWS}
  {$IFNDEF WINDOWS}
    {$DEFINE WINDOWS}
  {$ENDIF WINDOWS}
{$ENDIF MSWINDOWS}

interface

uses
  {$IFNDEF FPC}
  System.SysUtils, Winapi.Windows
  {$ELSE}
  SysUtils, dl
  {$ENDIF};

type
  PMySQL                    = Pointer;
  PMySQLResult              = Pointer;
  PMySQLRow                 = ^TMySQLRow; // return data as array of strings
  TMySQLRow                 = array [0..MaxInt div SizeOf(PAnsiChar) - 1] of PAnsiChar;
  PMySQLLengths             = ^TMySQLLengths;
  TMySQLLengths             = array [0..MaxInt div SizeOf(Cardinal) - 1] of Cardinal;
  TMySQLOption              = (
    MYSQL_OPT_CONNECT_TIMEOUT, MYSQL_OPT_COMPRESS, MYSQL_OPT_NAMED_PIPE,
    MYSQL_INIT_COMMAND, MYSQL_READ_DEFAULT_FILE, MYSQL_READ_DEFAULT_GROUP,
    MYSQL_SET_CHARSET_DIR, MYSQL_SET_CHARSET_NAME, MYSQL_OPT_LOCAL_INFILE,
    MYSQL_OPT_PROTOCOL, MYSQL_SHARED_MEMORY_BASE_NAME, MYSQL_OPT_READ_TIMEOUT,
    MYSQL_OPT_WRITE_TIMEOUT, MYSQL_OPT_USE_RESULT,
    MYSQL_OPT_USE_REMOTE_CONNECTION, MYSQL_OPT_USE_EMBEDDED_CONNECTION,
    MYSQL_OPT_GUESS_CONNECTION, MYSQL_SET_CLIENT_IP, MYSQL_SECURE_AUTH,
    MYSQL_REPORT_DATA_TRUNCATION, MYSQL_OPT_RECONNECT,
    MYSQL_OPT_SSL_VERIFY_SERVER_CERT, MYSQL_PLUGIN_DIR, MYSQL_DEFAULT_AUTH,
    MYSQL_OPT_BIND,
    MYSQL_OPT_SSL_KEY, MYSQL_OPT_SSL_CERT,
    MYSQL_OPT_SSL_CA, MYSQL_OPT_SSL_CAPATH, MYSQL_OPT_SSL_CIPHER,
    MYSQL_OPT_SSL_CRL, MYSQL_OPT_SSL_CRLPATH,
    MYSQL_OPT_CONNECT_ATTR_RESET, MYSQL_OPT_CONNECT_ATTR_ADD,
    MYSQL_OPT_CONNECT_ATTR_DELETE,
    MYSQL_SERVER_PUBLIC_KEY,
    MYSQL_ENABLE_CLEARTEXT_PLUGIN,
    MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS,
    MYSQL_OPT_SSL_ENFORCE
  );
  Tmysql_init               = function (_mysql: PMySQL): PMySQL; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_real_connect       = function (_mysql: PMySQL; host, user, passwd, db: PAnsiChar; port: Cardinal; unix_socket: PAnsiChar; clientflag: Cardinal): PMySQL; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_close              = procedure(_mysql: PMySQL); {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_options            = function (_mysql: PMySQL; option: TMySQLOption; arg: Pointer): Integer; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_set_character_set  = function (_mysql: PMySQL; csname: PAnsiChar): Integer; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_character_set_name = function (_mysql: PMySQL): PAnsiChar; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_query              = function (_mysql: PMySQL; q: PAnsiChar): Integer; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_real_query         = function (_mysql: PMySQL; q: PAnsiChar; length: Cardinal): Integer; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_store_result       = function (_mysql: PMySQL): PMySQLResult; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_num_fields         = function (_res: PMySQLResult): Cardinal; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_num_rows           = function (_res: PMySQLResult): UInt64; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_fetch_row          = function (_res: PMySQLResult): PMySQLRow; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_fetch_lengths      = function (_res: PMySQLResult): PMySQLLengths; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_free_result        = procedure(_res: PMySQLResult); {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_errno              = function (_mysql: PMySQL): Cardinal; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_error              = function (_mysql: PMySQL): PAnsiChar; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_get_server_info    = function (_mysql: PMySQL): PAnsiChar; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}
  Tmysql_get_server_version = function (_mysql: PMySQL): Cardinal; {$IFDEF WINDOWS}stdcall;{$ENDIF}{$IFDEF LINUX}cdecl;{$ENDIF}

  ESphinxMySQLClientLibrary = Exception;
  TSphinxMySQLClientLibrary = class
  private
    FLibraryHandle: {$IFDEF WINDOWS}THandle;{$ENDIF}{$IFDEF LINUX}Pointer;{$ENDIF}
    FLibraryName: String;
  private
    Fmysql_init              : Tmysql_init;
    Fmysql_real_connect      : Tmysql_real_connect;
    Fmysql_close             : Tmysql_close;
    Fmysql_options           : Tmysql_options;
    Fmysql_set_character_set : Tmysql_set_character_set;
    Fmysql_character_set_name: Tmysql_character_set_name;
    Fmysql_query             : Tmysql_query;
    Fmysql_real_query        : Tmysql_real_query;
    Fmysql_store_result      : Tmysql_store_result;
    Fmysql_num_fields        : Tmysql_num_fields;
    Fmysql_num_rows          : Tmysql_num_rows;
    Fmysql_fetch_row         : Tmysql_fetch_row;
    Fmysql_fetch_lengths     : Tmysql_fetch_lengths;
    Fmysql_free_result       : Tmysql_free_result;
    Fmysql_errno             : Tmysql_errno;
    Fmysql_error             : Tmysql_error;
    Fmysql_get_server_info   : Tmysql_get_server_info;
    Fmysql_get_server_version: Tmysql_get_server_version;
  public
    function  mysql_init(_mysql: PMySQL): PMySQL;
    function  mysql_real_connect(_mysql: PMySQL; host, user, passwd, db: PAnsiChar; port: Cardinal; unix_socket: PAnsiChar; clientflag: Cardinal): PMySQL;
    procedure mysql_close(_mysql: PMySQL);
    function  mysql_options(_mysql: PMySQL; option: TMySQLOption; arg: Pointer): Integer;
    function  mysql_set_character_set(_mysql: PMySQL; csname: PAnsiChar): Integer;
    function  mysql_character_set_name(_mysql: PMySQL): PAnsiChar;
    function  mysql_query(_mysql: PMySQL; q: PAnsiChar): Integer;
    function  mysql_real_query(_mysql: PMySQL; q: PAnsiChar; length: Cardinal): Integer;
    function  mysql_store_result(_mysql: PMySQL): PMySQLResult;
    function  mysql_num_fields(_res: PMySQLResult): Cardinal;
    function  mysql_num_rows(_res: PMySQLResult): UInt64;
    function  mysql_fetch_row(_res: PMySQLResult): PMySQLRow;
    function  mysql_fetch_lengths(_res: PMySQLResult): PMySQLLengths;
    procedure mysql_free_result(_res: PMySQLResult);
    function  mysql_errno(_mysql: PMySQL): Cardinal;
    function  mysql_error(_mysql: PMySQL): PAnsiChar;
    function  mysql_get_server_info(_mysql: PMySQL): PAnsiChar;
    function  mysql_get_server_version(_mysql: PMySQL): Cardinal;
  public
    constructor Create(const ALibraryName: String);
    destructor Destroy; override;
    procedure LoadLibrary;
    procedure FreeLibrary;
    function  LibraryLoaded: Boolean;
    property LibraryName: String read FLibraryName;
  end;

implementation

resourcestring
  SCantFindAPIProc = 'Can''t find procedure %s in %s';

{ TSphinxMySQLClientLibrary }

constructor TSphinxMySQLClientLibrary.Create(const ALibraryName: String);
begin
  inherited Create;
  FLibraryName := ALibraryName;
  LoadLibrary;
end;

destructor TSphinxMySQLClientLibrary.Destroy;
begin
  FreeLibrary;
  inherited Destroy;
end;

function TSphinxMySQLClientLibrary.mysql_init(_mysql: PMySQL): PMySQL;
begin
  if Assigned(Fmysql_init) then
    Result := Fmysql_init(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_init', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_real_connect(_mysql: PMySQL; host, user, passwd, db: PAnsiChar; port: Cardinal; unix_socket: PAnsiChar; clientflag: Cardinal): PMySQL;
begin
  if Assigned(Fmysql_real_connect) then
    Result := Fmysql_real_connect(_mysql, host, user, passwd, db, port, unix_socket, clientflag)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_real_connect', FLibraryName]));
end;

procedure TSphinxMySQLClientLibrary.mysql_close(_mysql: PMySQL);
begin
  if Assigned(Fmysql_close) then
    Fmysql_close(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_close', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_options(_mysql: PMySQL; option: TMySQLOption; arg: Pointer): Integer;
begin
  if Assigned(Fmysql_options) then
    Result := Fmysql_options(_mysql, option, arg)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_options', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_set_character_set(_mysql: PMySQL; csname: PAnsiChar): Integer;
begin
  if Assigned(Fmysql_set_character_set) then
    Result := Fmysql_set_character_set(_mysql, csname)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_set_character_set', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_character_set_name(_mysql: PMySQL): PAnsiChar;
begin
  if Assigned(Fmysql_character_set_name) then
    Result := Fmysql_character_set_name(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_character_set_name', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_query(_mysql: PMySQL; q: PAnsiChar): Integer;
begin
  if Assigned(Fmysql_query) then
    Result := Fmysql_query(_mysql, q)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_query', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_real_query(_mysql: PMySQL; q: PAnsiChar; length: Cardinal): Integer;
begin
  if Assigned(Fmysql_real_query) then
    Result := Fmysql_real_query(_mysql, q, length)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_real_query', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_store_result(_mysql: PMySQL): PMySQLResult;
begin
  if Assigned(Fmysql_store_result) then
    Result := Fmysql_store_result(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_store_result', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_num_fields(_res: PMySQLResult): Cardinal;
begin
  if Assigned(Fmysql_num_fields) then
    Result := Fmysql_num_fields(_res)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_num_fields', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_num_rows(_res: PMySQLResult): UInt64;
begin
  if Assigned(Fmysql_num_rows) then
    Result := Fmysql_num_rows(_res)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_num_rows', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_fetch_row(_res: PMySQLResult): PMySQLRow;
begin
  if Assigned(Fmysql_fetch_row) then
    Result := Fmysql_fetch_row(_res)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_fetch_row', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_fetch_lengths(_res: PMySQLResult): PMySQLLengths;
begin
  if Assigned(Fmysql_fetch_lengths) then
    Result := Fmysql_fetch_lengths(_res)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_fetch_lengths', FLibraryName]));
end;

procedure TSphinxMySQLClientLibrary.mysql_free_result(_res: PMySQLResult);
begin
  if Assigned(Fmysql_free_result) then
    Fmysql_free_result(_res)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_free_result', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_errno(_mysql: PMySQL): Cardinal;
begin
  if Assigned(Fmysql_errno) then
    Result := Fmysql_errno(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_errno', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_error(_mysql: PMySQL): PAnsiChar;
begin
  if Assigned(Fmysql_error) then
    Result := Fmysql_error(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_error', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_get_server_info(_mysql: PMySQL): PAnsiChar;
begin
  if Assigned(Fmysql_get_server_info) then
    Result := Fmysql_get_server_info(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_get_server_info', FLibraryName]));
end;

function TSphinxMySQLClientLibrary.mysql_get_server_version(_mysql: PMySQL): Cardinal;
begin
  if Assigned(Fmysql_get_server_version) then
    Result := Fmysql_get_server_version(_mysql)
  else
    raise ESphinxMySQLClientLibrary.Create(Format(SCantFindAPIProc, ['mysql_get_server_version', FLibraryName]));
end;

procedure TSphinxMySQLClientLibrary.LoadLibrary;

  {$IFDEF WINDOWS}
  function GetProcAddr(const AProcName: String): Pointer;
  begin
    Result := Winapi.Windows.GetProcAddress(FLibraryHandle, PChar(AProcName));
    if not Assigned(Result) then
      RaiseLastOSError;
  end;
  {$ENDIF}
  {$IFDEF LINUX}
  function GetProcAddr(const AProcName: String): Pointer;
  begin
    Result := dlsym(FLibraryHandle, PChar(AProcName));
  end;
  {$ENDIF}

begin
  {$IFDEF WINDOWS}
  FLibraryHandle := Winapi.Windows.LoadLibrary(PChar(FLibraryName));
  if (FLibraryHandle > HINSTANCE_ERROR) then
  {$ENDIF}
  {$IFDEF LINUX}
  FLibraryHandle := dlopen(PChar(FLibraryName), RTLD_LAZY);
  if Assigned(FLibraryHandle) then
  {$ENDIF}
  begin
    Fmysql_init               := GetProcAddr('mysql_init');
    Fmysql_real_connect       := GetProcAddr('mysql_real_connect');
    Fmysql_close              := GetProcAddr('mysql_close');
    Fmysql_options            := GetProcAddr('mysql_options');
    Fmysql_set_character_set  := GetProcAddr('mysql_set_character_set');
    Fmysql_character_set_name := GetProcAddr('mysql_character_set_name');
    Fmysql_query              := GetProcAddr('mysql_query');
    Fmysql_real_query         := GetProcAddr('mysql_real_query');
    Fmysql_store_result       := GetProcAddr('mysql_store_result');
    Fmysql_num_fields         := GetProcAddr('mysql_num_fields');
    Fmysql_num_rows           := GetProcAddr('mysql_num_rows');
    Fmysql_fetch_row          := GetProcAddr('mysql_fetch_row');
    Fmysql_fetch_lengths      := GetProcAddr('mysql_fetch_lengths');
    Fmysql_free_result        := GetProcAddr('mysql_free_result');
    Fmysql_errno              := GetProcAddr('mysql_errno');
    Fmysql_error              := GetProcAddr('mysql_error');
    Fmysql_get_server_info    := GetProcAddr('mysql_get_server_info');
    Fmysql_get_server_version := GetProcAddr('mysql_get_server_version');
  end
  else
    RaiseLastOSError;
end;

procedure TSphinxMySQLClientLibrary.FreeLibrary;
begin
  {$IFDEF WINDOWS}
  if (FLibraryHandle > HINSTANCE_ERROR) then
  begin
    Winapi.Windows.FreeLibrary(FLibraryHandle);
    FLibraryHandle := HINSTANCE_ERROR;
  end;
  {$ENDIF}
  {$IFDEF LINUX}
  if Assigned(FLibraryHandle) then
  begin
     dlclose(FLibraryHandle);
     FLibraryHandle := nil;
  end;
  {$ENDIF}
end;

function TSphinxMySQLClientLibrary.LibraryLoaded: Boolean;
begin
  {$IFDEF WINDOWS}
  Result := FLibraryHandle > HINSTANCE_ERROR;
  {$ENDIF}
  {$IFDEF LINUX}
  Result := Assigned(FLibraryHandle);
  {$ENDIF}
end;

end.
