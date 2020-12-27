unit Delphi.Serial.Protobuf;

interface

uses
  Delphi.Serial,
  System.Classes,
  System.SysUtils;

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

  OneofAttribute    = class(FieldAttribute);
  UnPackedAttribute = class(FieldAttribute);

  FieldTagAttribute = class(FieldAttribute)
    private
      FValue: FieldTag;
    public
      constructor Create(AValue: FieldTag);
      property Value: FieldTag read FValue;
  end;

  EProtobufError = class(Exception);

  TProtobuf = class
    public
      class function CreateInputSerializer(Stream: TCustomMemoryStream): ISerializer; static;
      class function CreateOutputSerializer(Stream: TCustomMemoryStream): ISerializer; static;
  end;

implementation

uses
  Delphi.Serial.Protobuf.InputSerializer,
  Delphi.Serial.Protobuf.OutputSerializer;

{ FieldTagAttribute }

constructor FieldTagAttribute.Create(AValue: FieldTag);
begin
  FValue := AValue;
end;

{ TProtobuf }

class function TProtobuf.CreateInputSerializer(Stream: TCustomMemoryStream): ISerializer;
begin
  Result := TInputSerializer.Create(Stream);
end;

class function TProtobuf.CreateOutputSerializer(Stream: TCustomMemoryStream): ISerializer;
begin
  Result := TOutputSerializer.Create(Stream);
end;

end.
