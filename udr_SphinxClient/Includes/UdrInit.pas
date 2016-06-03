unit UdrInit;

{$INCLUDE udr_SphinxClient.inc}

interface

uses Firebird;

function firebird_udr_plugin(status: IStatus; theirUnloadFlagLocal: BooleanPtr; udrPlugin: IUdrPlugin): BooleanPtr; cdecl;

implementation

uses UdrSphinxClientExecute, UdrQuotedStr;

var
  AUnloadFlag: Boolean;
  theirUnloadFlag: BooleanPtr;

function firebird_udr_plugin(status: IStatus; theirUnloadFlagLocal: BooleanPtr; udrPlugin: IUdrPlugin): BooleanPtr; cdecl;
begin
  udrPlugin.registerProcedure(status, 'Execute',   TSphinxClientExecuteFactory.create());
  udrPlugin.registerFunction(status,  'QuotedStr', TQuotedStrFactory.create());
  theirUnloadFlag := theirUnloadFlagLocal;
  Result := @AUnloadFlag;
end;

initialization
  AUnloadFlag := False;

finalization
  if ((theirUnloadFlag <> nil) and not AUnloadFlag) then
    theirUnloadFlag^ := True;

end.
