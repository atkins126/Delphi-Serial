unit Delphi.Serial.Protobuf.Serializer;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial.Protobuf,
  Delphi.Serial.ProtobufUtils,
  System.Classes;

type

  TSerializer = class(TInterfacedObject)
    private
      FStream: TCustomMemoryStream;

    protected
      procedure Move(ACount, ADisplacement: Integer); inline;
      function Require(ACount: Integer): Pointer; inline;
      function Skip(ACount: Integer): Int64; inline;
      function Read(var AValue; ACount: Integer): Integer; inline;
      function Write(const AValue; ACount: Integer): Integer; inline;

      procedure Parse(var AValue: VarInt); overload; inline;
      procedure Parse(var AValue: SignedInt); overload; inline;
      procedure Parse(var AValue: FixedInt32); overload; inline;
      procedure Parse(var AValue: FixedInt64); overload; inline;

      procedure Pack(AValue: VarInt); overload; inline;
      procedure Pack(AValue: SignedInt); overload; inline;
      procedure Pack(AValue: FixedInt32); overload; inline;
      procedure Pack(AValue: FixedInt64); overload; inline;

    public
      constructor Create(Stream: TCustomMemoryStream);
  end;

  TWireType = (VarInt = 0, _64bit = 1, LengthPrefixed = 2, _32bit = 5);

  TWireTypeHelper = record helper for TWireType
    function CombineWith(AFieldTag: FieldTag): UInt32;
    function ExtractFrom(AValue: UInt32): FieldTag;
  end;

implementation

{ TWireTypeHelper }

function TWireTypeHelper.CombineWith(AFieldTag: FieldTag): UInt32;
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

procedure TSerializer.Move(ACount, ADisplacement: Integer);
var
  Start: PByte;
begin
  Start := Require(ACount + ADisplacement);
  System.Move(Start^, (Start + ADisplacement)^, ACount);
end;

function TSerializer.Require(ACount: Integer): Pointer;
var
  CurrentPos  : Int64;
  RequiredSize: Int64;
begin
  CurrentPos     := FStream.Position;
  RequiredSize   := CurrentPos + ACount;
  if FStream.Size < RequiredSize then
    FStream.Size := RequiredSize; // increase stream size to hold the required data
  Result         := PByte(FStream.Memory) + CurrentPos;
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

procedure TSerializer.Pack(AValue: SignedInt);
begin
  write(AValue, AValue.Count);
end;

procedure TSerializer.Pack(AValue: FixedInt32);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Pack(AValue: FixedInt64);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Parse(var AValue: VarInt);
begin
  AValue.Initialize(PByte(FStream.Memory) + FStream.Position, FStream.Size - FStream.Position);
  Skip(AValue.Count);
end;

procedure TSerializer.Parse(var AValue: SignedInt);
begin
  AValue.Initialize(PByte(FStream.Memory) + FStream.Position, FStream.Size - FStream.Position);
  Skip(AValue.Count);
end;

procedure TSerializer.Parse(var AValue: FixedInt32);
begin
  read(AValue, SizeOf(AValue));
end;

procedure TSerializer.Parse(var AValue: FixedInt64);
begin
  read(AValue, SizeOf(AValue));
end;

end.
