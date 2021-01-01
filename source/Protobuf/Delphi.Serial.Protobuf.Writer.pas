unit Delphi.Serial.Protobuf.Writer;

interface

uses
  Delphi.Serial,
  Delphi.Serial.Protobuf.Types,
  System.Classes;

type

  TWriter = class
    private
      FStream: TCustomMemoryStream;

    public
      constructor Create(AStream: TCustomMemoryStream);

      procedure Move(ACount, ADisplacement: Integer); inline;
      procedure Truncate; inline;
      function Require(ACount: Integer): Pointer;
      function Skip(ACount: Integer): Int64; inline;
      function Write(const AValue; ACount: Integer): Integer; inline;

      procedure Pack(AValue: VarInt); overload; inline;
      procedure Pack(AValue: SignedInt); overload; inline;
      procedure Pack(AValue: FixedInt32); overload; inline;
      procedure Pack(AValue: FixedInt64); overload; inline;
      procedure Pack(AWireType: TWireType; AFieldTag: FieldTag); overload; inline;
  end;

implementation

{ TReader }

constructor TWriter.Create(AStream: TCustomMemoryStream);
begin
  FStream := AStream;
end;

procedure TWriter.Move(ACount, ADisplacement: Integer);
var
  Start: PByte;
begin
  Start := Require(ACount + ADisplacement);
  System.Move(Start^, (Start + ADisplacement)^, ACount);
end;

function TWriter.Require(ACount: Integer): Pointer;
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

function TWriter.Skip(ACount: Integer): Int64;
begin
  Result := FStream.Seek(ACount, TSeekOrigin.soCurrent);
end;

procedure TWriter.Truncate;
begin
  FStream.Size := FStream.Position;
end;

function TWriter.Write(const AValue; ACount: Integer): Integer;
begin
  Result := FStream.Write(AValue, ACount);
end;

procedure TWriter.Pack(AValue: VarInt);
begin
  write(AValue, AValue.Count);
end;

procedure TWriter.Pack(AValue: SignedInt);
begin
  write(AValue, AValue.Count);
end;

procedure TWriter.Pack(AValue: FixedInt32);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TWriter.Pack(AValue: FixedInt64);
begin
  write(AValue, SizeOf(AValue));
end;

procedure TWriter.Pack(AWireType: TWireType; AFieldTag: FieldTag);
var
  Target: UInt32;
begin
  Target := (AFieldTag shl 3) or Ord(AWireType);
  Pack(VarInt(Target));
end;

end.
