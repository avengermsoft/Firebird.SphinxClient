library udr_SphinxClient;

{$INCLUDE udr_SphinxClient.inc}
{$IFNDEF FPC}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

  {$R 'udr_SphinxClient.res' 'udr_SphinxClient.rc'}
{$ENDIF}

uses
  Firebird in 'Includes\Firebird.pas',
  u_SphinxMySQL in '..\u_SphinxMySQL.pas',
  UdrInit in 'Includes\UdrInit.pas',
  UdrSphinxClientExecute in 'Includes\UdrSphinxClientExecute.pas',
  UdrQuotedStr in 'Includes\UdrQuotedStr.pas';

exports firebird_udr_plugin;

//begin
  //IsMultiThread := True;

end.
