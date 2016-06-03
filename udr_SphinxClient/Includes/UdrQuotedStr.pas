unit UdrQuotedStr;

{$INCLUDE udr_SphinxClient.inc}

interface

uses
  {$IFNDEF FPC}
  System.SysUtils, Firebird
  {$ELSE}
  SysUtils, Firebird
  {$ENDIF};

type
  PQuotedStrInMessage = ^TQuotedStrInMessage;
  TQuotedStrInMessage = record
    StrLen: Word;
    Str: array [0..4*255 - 1] of AnsiChar;
    StrNull: WordBool;
  end;

  PQuotedStrOutMessage = ^TQuotedStrOutMessage;
  TQuotedStrOutMessage = record
    StrLen: Word;
    Str: array [0..4*255 - 1] of AnsiChar;
    StrNull: WordBool;
  end;

  TQuotedStrFunction = class(IExternalFunctionImpl)
    procedure dispose(); override;
    procedure getCharSet(status: IStatus; context: IExternalContext; name: PAnsiChar; nameSize: Cardinal); override;
    procedure execute(status: IStatus; context: IExternalContext; inMsg: Pointer; outMsg: Pointer); override;
  end;

  TQuotedStrFactory = class(IUdrFunctionFactoryImpl)
    procedure dispose(); override;
    procedure setup(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata; inBuilder: IMetadataBuilder; outBuilder: IMetadataBuilder); override;
    function newItem(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata): IExternalFunction; override;
  end;

implementation

{ TQuotedStrFunction }

procedure TQuotedStrFunction.dispose();
begin
  destroy;
end;

procedure TQuotedStrFunction.getCharSet(status: IStatus; context: IExternalContext; name: PAnsiChar; nameSize: Cardinal);
begin
end;

procedure TQuotedStrFunction.execute(status: IStatus; context: IExternalContext; inMsg: Pointer; outMsg: Pointer);
var
  AInMsg: PQuotedStrInMessage;
  AOutMsg: PQuotedStrOutMessage;
  AStr: UTF8String;
begin
  try
    AInMsg      := PQuotedStrInMessage(inMsg);
    AOutMsg     := PQuotedStrOutMessage(outMsg);
    if AInMsg.StrNull then
    begin
      with AOutMsg^ do
      begin
        StrLen  := 0;
        StrNull := StrLen = 0;
      end;
    end
    else
    begin
      {$IFNDEF FPC}
      AStr      := UTF8Encode(System.SysUtils.QuotedStr(UTF8ToString(AInMsg.Str)));
      {$ELSE}
      AStr      := SysUtils.QuotedStr(AInMsg.Str);
      {$ENDIF}
      with AOutMsg^ do
      begin
        StrLen  := Length(AStr);
        StrNull := StrLen = 0;
        if StrLen > 0 then
          Move(PAnsiChar(AStr)^, Str[0], StrLen * SizeOf(AnsiChar));
      end;
    end;
  except
    on E: Exception do
      FbException.catchException(status, E);
  end;
end;

{ TQuotedStrFactory }

procedure TQuotedStrFactory.dispose();
begin
  destroy;
end;

procedure TQuotedStrFactory.setup(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata; inBuilder: IMetadataBuilder; outBuilder: IMetadataBuilder);
begin
end;

function TQuotedStrFactory.newItem(status: IStatus; context: IExternalContext; metadata: IRoutineMetadata): IExternalFunction;
begin
  Result := TQuotedStrFunction.create;
end;

end.
