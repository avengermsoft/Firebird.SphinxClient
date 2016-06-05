library udf_SphinxClient;

{$INCLUDE udf_SphinxClient.inc}
{$IFNDEF FPC}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

  {$R 'udf_SphinxClient.res' 'udf_SphinxClient.rc'}
{$ENDIF}

uses
  u_SphinxMySQL in '..\u_SphinxMySQL.pas',
  SphinxClient in 'Includes\SphinxClient.pas',
  functions_SphinxClient in 'Includes\functions_SphinxClient.pas';

exports
  ClientCreate,
  ClientFree,
  ClientNext,
  ClientEOF,
  ClientExecSQL,
  ClientGetCurrentValue,
  QuotedStr;

{$IFNDEF FPC} // Bug FPC TThreadList.LockList and IsMultiThread
begin
  IsMultiThread := True;
{$ENDIF}

end.
