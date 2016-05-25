library udf_SphinxClient;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R udf_SphinxClient.res}

uses
  u_SphinxMySQL in '..\u_SphinxMySQL.pas',
  SphinxClient in 'Includes\SphinxClient.pas',
  functions_SphinxClient in 'Includes\functions_SphinxClient.pas';

begin
  IsMultiThread := True;

end.
