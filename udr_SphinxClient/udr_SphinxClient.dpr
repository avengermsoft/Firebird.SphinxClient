library udr_SphinxClient;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R udr_SphinxClient.res}

uses
  Firebird in 'Includes\Firebird.pas',
  UdrInit in 'Includes\UdrInit.pas',
  u_SphinxMySQL in '..\u_SphinxMySQL.pas',
  UdrSphinxClientExecute in 'Includes\UdrSphinxClientExecute.pas',
  UdrQuotedStr in 'Includes\UdrQuotedStr.pas';

exports firebird_udr_plugin;

//begin
  //IsMultiThread := True;

end.
