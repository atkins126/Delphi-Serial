unit Delphi.Serial;

interface

uses
  System.Classes,
  System.SysUtils,
  Delphi.Serial.RttiObserver,
  Delphi.Serial.RttiVisitor;

type

  FieldTag          = 1 .. $1FFFFFFF;
  Float             = Single;
  Bool              = Boolean;
  Bytes             = TBytes;
  SInt32            = type Int32;
  SInt64            = type Int64;
  Fixed32           = type UInt32;
  Fixed64           = type UInt64;
  SFixed32          = type Int32;
  SFixed64          = type Int64;

  ESerialError      = class(Exception);

  SerialAttribute   = class(TCustomAttribute);
  RecordAttribute   = class(SerialAttribute);
  FieldAttribute    = class(SerialAttribute);
  RequiredAttribute = class(FieldAttribute);
  OneofAttribute    = class(FieldAttribute);
  UnPackedAttribute = class(FieldAttribute);

  NameAttribute = class(FieldAttribute)
    private
      FValue: string;
    public
      constructor Create(const AValue: string);
      property Value: string read FValue;
  end;

  TagAttribute = class(FieldAttribute)
    private
      FValue: FieldTag;
    public
      constructor Create(AValue: FieldTag);
      property Value: FieldTag read FValue;
  end;

  DefaultAttribute = class(FieldAttribute)
    private
      FValue: Variant;
    public
      constructor Create(AValue: Int64); overload;
      constructor Create(AValue: UInt64); overload;
      constructor Create(AValue: Boolean); overload;
      constructor Create(AValue: Extended); overload;
      constructor Create(const AValue: string); overload;
      property Value: Variant read FValue;
  end;

  ISerializer = interface(IRttiObserver)
    procedure SetStream(AStream: TStream);
    procedure SetOption(const AName: string; AValue: Variant);

    property Stream: TStream write SetStream;
    property Option[const AName: string]: Variant write SetOption; default;
  end;

  TVisitor = TRttiVisitor;

function CreateSerializer(const AName: string): ISerializer;

implementation

uses
  Delphi.Serial.Factory;

{ NameAttribute }

constructor NameAttribute.Create(const AValue: string);
begin
  FValue := AValue;
end;

{ TagAttribute }

constructor TagAttribute.Create(AValue: FieldTag);
begin
  FValue := AValue;
end;

{ DefaultAttribute }

constructor DefaultAttribute.Create(AValue: Int64);
begin
  FValue := AValue;
end;

constructor DefaultAttribute.Create(AValue: UInt64);
begin
  FValue := AValue;
end;

constructor DefaultAttribute.Create(AValue: Boolean);
begin
  FValue := AValue;
end;

constructor DefaultAttribute.Create(AValue: Extended);
begin
  FValue := AValue;
end;

constructor DefaultAttribute.Create(const AValue: string);
begin
  FValue := AValue;
end;

function CreateSerializer(const AName: string): ISerializer;
begin
  Result := TFactory.Instance.CreateSerializer(AName);
end;

end.
