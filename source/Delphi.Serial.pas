unit Delphi.Serial;

interface

uses
  Delphi.Serial.RttiObserver;

type

  FieldAttribute = class(TCustomAttribute);
  RequiredAttribute = class(FieldAttribute);

  ISerializer = IRttiObserver;

  TSerial = class
    public
      class procedure Serialize<T>(var AValue: T; ASerializer: ISerializer); static;
  end;

  { Template for record helpers for user-defined types

  TMyTypeHelper = record helper for TMyType
    public
      procedure Serialize(ASerializer: ISerializer); inline;
  end;}

implementation

uses
  Delphi.Serial.RttiVisitor;

{ TSerial }

class procedure TSerial.Serialize<T>(var AValue: T; ASerializer: ISerializer);
var
  Visitor: TRttiVisitor;
begin
  Visitor.Initialize(ASerializer);
  Visitor.Visit(AValue);
end;

{ TMyTypeHelper }

{procedure TMyTypeHelper.Serialize(ASerializer: ISerializer);
begin
  TSerial.Serialize(Self, ASerializer);
end;}

end.
