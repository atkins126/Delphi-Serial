unit Delphi.Serial;

interface

uses
  Delphi.Serial.RttiObserver;

type

  FieldAttribute    = class(TCustomAttribute);
  RequiredAttribute = class(FieldAttribute);

  FieldNameAttribute = class(FieldAttribute)
    private
      FValue: string;
    public
      constructor Create(const AValue: string);
      property Value: string read FValue;
  end;

  ISerializer = interface(IRttiObserver)
    function GetOption(const AName: string): Variant;
    procedure SetOption(const AName: string; AValue: Variant);
    property Option[const AName: string]: Variant read GetOption write SetOption; default;
  end;

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

{ FieldNameAttribute }

constructor FieldNameAttribute.Create(const AValue: string);
begin
  FValue := AValue;
end;

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
