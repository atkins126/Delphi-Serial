unit Delphi.Serial.Protobuf;

interface

uses
  Delphi.Serial,
  System.Classes,
  System.SysUtils;

type

  FieldNumber = 1 .. $1FFFFFFF;
  SignedInt32 = type Int32;
  SignedInt64 = type Int64;
  FixedInt32  = type Int32;
  FixedInt64  = type Int64;
  FixedUInt32 = type UInt32;
  FixedUInt64 = type UInt64;

  ProtobufAttribute = class(TCustomAttribute)
    private
      FFieldNumber: FieldNumber;

    public
      constructor Create(AFieldNumber: FieldNumber);

      property FieldNumber: FieldNumber read FFieldNumber;
  end;

  EProtobufError = class(Exception);

  TProtobuf = class
    public
      class function CreateInputSerializer(Stream: TStream): ISerializer; static;
      class function CreateOutputSerializer(Stream: TStream): ISerializer; static;
  end;

implementation

uses
  Delphi.Serial.Protobuf.InputSerializer,
  Delphi.Serial.Protobuf.OutputSerializer;

{ ProtobufAttribute }

constructor ProtobufAttribute.Create(AFieldNumber: FieldNumber);
begin
  FFieldNumber := AFieldNumber;
end;

{ TProtobuf }

class function TProtobuf.CreateInputSerializer(Stream: TStream): ISerializer;
begin
  Result := TInputSerializer.Create(Stream);
end;

class function TProtobuf.CreateOutputSerializer(Stream: TStream): ISerializer;
begin
  Result := TOutputSerializer.Create(Stream);
end;

end.
