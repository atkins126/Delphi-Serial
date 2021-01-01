unit Delphi.Serial.Protobuf.Reader;

interface

uses
  Delphi.Serial,
  Delphi.Serial.Protobuf.Types,
  System.Classes;

type

  TReader = class
    private
      FStream: TCustomMemoryStream;

    public
      constructor Create(AStream: TCustomMemoryStream);

      function Skip(ACount: Integer): Int64; inline;
      function Read(var AValue; ACount: Integer): Integer; inline;

      procedure Parse(var AValue: VarInt); overload; inline;
      procedure Parse(var AValue: SignedInt); overload; inline;
      procedure Parse(var AValue: FixedInt32); overload; inline;
      procedure Parse(var AValue: FixedInt64); overload; inline;
      procedure Parse(var AWireType: TWireType; var AFieldTag: FieldTag); overload; inline;
  end;

implementation

{ TReader }

constructor TReader.Create(AStream: TCustomMemoryStream);
begin
  FStream := AStream;
end;

function TReader.Skip(ACount: Integer): Int64;
begin
  Result := FStream.Seek(ACount, TSeekOrigin.soCurrent);
end;

function TReader.Read(var AValue; ACount: Integer): Integer;
begin
  Result := FStream.Read(AValue, ACount);
end;

procedure TReader.Parse(var AValue: VarInt);
begin
  AValue.Initialize(PByte(FStream.Memory) + FStream.Position, FStream.Size - FStream.Position);
  Skip(AValue.Count);
end;

procedure TReader.Parse(var AValue: SignedInt);
begin
  AValue.Initialize(PByte(FStream.Memory) + FStream.Position, FStream.Size - FStream.Position);
  Skip(AValue.Count);
end;

procedure TReader.Parse(var AValue: FixedInt32);
begin
  read(AValue, SizeOf(AValue));
end;

procedure TReader.Parse(var AValue: FixedInt64);
begin
  read(AValue, SizeOf(AValue));
end;

procedure TReader.Parse(var AWireType: TWireType; var AFieldTag: FieldTag);
var
  Source: VarInt;
begin
  Parse(Source);
  AWireType := TWireType(UInt32(Source) and 7);
  AFieldTag := UInt32(Source) shr 3;
end;

end.
