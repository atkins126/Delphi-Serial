unit Delphi.Serial.Protobuf.Serializer;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial.Protobuf,
  Delphi.Serial.Utils,
  System.Classes;

type

  TSerializer = class(TInterfacedObject)
    private
      FStream: TCustomMemoryStream;

    protected
      procedure Move(ACount: Integer); inline;
      function Skip(ACount: Integer): Int64; inline;
      function Read(var AValue; ACount: Integer): Integer; inline;
      function Write(const AValue; ACount: Integer): Integer; inline;

      procedure Parse(var AValue: VarInt); overload; inline;
      procedure Parse(var AValue: Int32); overload; inline;
      procedure Parse(var AValue: Int64); overload; inline;
      procedure Parse(var AValue: UInt32); overload; inline;
      procedure Parse(var AValue: UInt64); overload; inline;
      procedure Parse(var AValue: SignedInt32); overload; inline;
      procedure Parse(var AValue: SignedInt64); overload; inline;
      procedure Parse(var AValue: FixedInt32); overload; inline;
      procedure Parse(var AValue: FixedInt64); overload; inline;
      procedure Parse(var AValue: FixedUInt32); overload; inline;
      procedure Parse(var AValue: FixedUInt64); overload; inline;

      procedure Pack(AValue: VarInt); overload; inline;
      procedure Pack(AValue: Int32); overload; inline;
      procedure Pack(AValue: Int64); overload; inline;
      procedure Pack(AValue: UInt32); overload; inline;
      procedure Pack(AValue: UInt64); overload; inline;
      procedure Pack(AValue: SignedInt32); overload; inline;
      procedure Pack(AValue: SignedInt64); overload; inline;
      procedure Pack(AValue: FixedInt32); overload; inline;
      procedure Pack(AValue: FixedInt64); overload; inline;
      procedure Pack(AValue: FixedUInt32); overload; inline;
      procedure Pack(AValue: FixedUInt64); overload; inline;

    public
      constructor Create(Stream: TCustomMemoryStream);
  end;

  TWireType = (VarInt = 0, _64bit = 1, LengthPrefixed = 2, _32bit = 5);

  TWireTypeHelper = record helper for TWireType
    function MergeWith(AFieldTag: FieldTag): UInt32;
    function ExtractFrom(AValue: UInt32): FieldTag;
  end;

implementation

uses
  System.Math;

{ TWireTypeHelper }

function TWireTypeHelper.MergeWith(AFieldTag: FieldTag): UInt32;
begin
  Result := (AFieldTag shl 3) or Ord(Self);
end;

function TWireTypeHelper.ExtractFrom(AValue: UInt32): FieldTag;
begin
  Self   := TWireType(AValue and 7);
  Result := AValue shr 3;
end;

{ TSerializer }

constructor TSerializer.Create(Stream: TCustomMemoryStream);
begin
  FStream := Stream;
end;

procedure TSerializer.Move(ACount: Integer);
var
  Start: PByte;
begin
  if ACount > 0 then
    FStream.Size := FStream.Size + ACount;
  Start          := PByte(FStream.Memory) + FStream.Position;
  System.Move(Start^, (Start + ACount)^, FStream.Size - FStream.Position);
end;

function TSerializer.Skip(ACount: Integer): Int64;
begin
  Result := FStream.Seek(ACount, TSeekOrigin.soCurrent);
end;

function TSerializer.Read(var AValue; ACount: Integer): Integer;
begin
  Result := FStream.Read(AValue, ACount);
end;

function TSerializer.Write(const AValue; ACount: Integer): Integer;
begin
  Result := FStream.Write(AValue, ACount);
end;

procedure TSerializer.Pack(AValue: VarInt);
begin
  write(AValue, AValue.Count);
end;

procedure TSerializer.Pack(AValue: Int32);
begin
  if AValue < 0 then
    Pack(Int64(AValue))
  else
    Pack(UInt32(AValue));
end;

procedure TSerializer.Pack(AValue: Int64);
begin
  Pack(UInt64(AValue));
end;

procedure TSerializer.Pack(AValue: UInt32);
begin
  Pack(VarInt(AValue));
end;

procedure TSerializer.Pack(AValue: UInt64);
begin
  Pack(VarInt(AValue));
end;

procedure TSerializer.Pack(AValue: FixedInt32);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Pack(AValue: FixedInt64);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Pack(AValue: FixedUInt32);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Pack(AValue: FixedUInt64);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Pack(AValue: SignedInt32);
begin
  Pack(ZigZag(AValue));
end;

procedure TSerializer.Pack(AValue: SignedInt64);
begin
  Pack(ZigZag(AValue));
end;

procedure TSerializer.Parse(var AValue: VarInt);
var
  MaxLength: Integer;
begin
  MaxLength := Min(VarInt.CMaxLength, FStream.Size - FStream.Position);
  AValue.Initialize(PByte(FStream.Memory) + FStream.Position, MaxLength);
  Skip(AValue.Count);
end;

procedure TSerializer.Parse(var AValue: Int32);
begin
  Parse(UInt32(AValue));
  if AValue < 0 then
    Skip(VarInt.CMaxLength div 2); // skip high bytes of encoded Int64
end;

procedure TSerializer.Parse(var AValue: Int64);
begin
  Parse(UInt64(AValue));
end;

procedure TSerializer.Parse(var AValue: UInt32);
var
  Source: VarInt;
begin
  Parse(Source);
  AValue := Source.Value;
end;

procedure TSerializer.Parse(var AValue: UInt64);
var
  Source: VarInt;
begin
  Parse(Source);
  AValue := Source.Value;
end;

procedure TSerializer.Parse(var AValue: SignedInt32);
var
  Value: UInt32;
begin
  Parse(Value);
  AValue := ZigZag(Value);
end;

procedure TSerializer.Parse(var AValue: SignedInt64);
var
  Value: UInt64;
begin
  Parse(Value);
  AValue := ZigZag(Value);
end;

procedure TSerializer.Parse(var AValue: FixedInt32);
begin
  read(AValue, SizeOf(AValue));
end;

procedure TSerializer.Parse(var AValue: FixedInt64);
begin
  read(AValue, SizeOf(AValue));
end;

procedure TSerializer.Parse(var AValue: FixedUInt32);
begin
  read(AValue, SizeOf(AValue));
end;

procedure TSerializer.Parse(var AValue: FixedUInt64);
begin
  read(AValue, SizeOf(AValue));
end;

end.
