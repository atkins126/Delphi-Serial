unit Delphi.Serial.Protobuf.Serializer;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial.Protobuf,
  Delphi.Serial.ProtobufUtils,
  System.Classes;

type

  TWireType = (VarInt = 0, _64bit = 1, LengthPrefixed = 2, _32bit = 5);

  TSerializer = class(TInterfacedObject)
    private
      FStream: TCustomMemoryStream;

    protected
      procedure Move(ACount, ADisplacement: Integer); inline;
      function Require(ACount: Integer): Pointer;
      function Skip(ACount: Integer): Int64; inline;
      function Read(var AValue; ACount: Integer): Integer; inline;
      function Write(const AValue; ACount: Integer): Integer; inline;

      procedure Parse(var AValue: VarInt); overload; inline;
      procedure Parse(var AValue: SignedInt); overload; inline;
      procedure Parse(var AValue: FixedInt32); overload; inline;
      procedure Parse(var AValue: FixedInt64); overload; inline;
      procedure Parse(var AWireType: TWireType; var AFieldTag: FieldTag); overload; inline;

      procedure Pack(AValue: VarInt); overload; inline;
      procedure Pack(AValue: SignedInt); overload; inline;
      procedure Pack(AValue: FixedInt32); overload; inline;
      procedure Pack(AValue: FixedInt64); overload; inline;
      procedure Pack(AWireType: TWireType; AFieldTag: FieldTag); overload; inline;

    public
      constructor Create(AStream: TCustomMemoryStream);
  end;

implementation

{ TSerializer }

constructor TSerializer.Create(AStream: TCustomMemoryStream);
begin
  FStream := AStream;
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

procedure TSerializer.Pack(AWireType: TWireType; AFieldTag: FieldTag);
var
  Target: UInt32;
begin
  Target := (AFieldTag shl 3) or Ord(AWireType);
  Pack(VarInt(Target));
end;

procedure TSerializer.Parse(var AWireType: TWireType; var AFieldTag: FieldTag);
var
  Source: VarInt;
begin
  Parse(Source);
  AWireType := TWireType(UInt32(Source) and 7);
  AFieldTag := UInt32(Source) shr 3;
end;

end.
