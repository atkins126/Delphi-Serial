unit Delphi.Serial.Protobuf;

interface

uses
  Delphi.Serial,
  System.Classes,
  System.SysUtils;

type

  FieldTag    = 1 .. $1FFFFFFF;
  SignedInt32 = type Int32;
  SignedInt64 = type Int64;
  FixedInt32  = type Int32;
  FixedInt64  = type Int64;
  FixedUInt32 = type UInt32;
  FixedUInt64 = type UInt64;

  ProtobufAttribute = class(TCustomAttribute)
    private
      FFieldTag: FieldTag;

    public
      constructor Create(AFieldTag: FieldTag);

      property FieldTag: FieldTag read FFieldTag;
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

{ ProtobufAttribute }

constructor ProtobufAttribute.Create(AFieldTag: FieldTag);
begin
  FFieldTag := AFieldTag;
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
