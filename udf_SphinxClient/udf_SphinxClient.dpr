library udf_SphinxClient;

{$IFDEF FPC}
  {$MODE objfpc}
  {$H+}
{$ELSE}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

  {$R udf_SphinxClient.res}
{$ENDIF}

uses
  u_SphinxMySQL in '..\u_SphinxMySQL.pas',
  SphinxClient in 'Includes\SphinxClient.pas',
  functions_SphinxClient in 'Includes\functions_SphinxClient.pas';

begin
  IsMultiThread := True;

end.
