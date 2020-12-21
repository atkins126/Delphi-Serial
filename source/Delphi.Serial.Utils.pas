unit Delphi.Serial.Utils;

interface

type

  VarIntImpl = record
    private
      FBytes    : PByte;
      FMaxLength: Integer;
      FCount    : Integer;

    const
      CBitShift = 7;
      CBitLimit = 1 shl CBitShift;
      CBitMask  = CBitLimit - 1;

      procedure SetValue(AValue: UInt64);
      function GetValue: UInt64;
  end;

  VarInt = record
    public const
      CMaxLength = 10;

    private
      FBytes: array [0 .. CMaxLength - 1] of Byte;
      FImpl : VarIntImpl;
      FValue: UInt64;

    public
      property Count: Integer read FImpl.FCount;
      property Value: UInt64 read FValue;

      procedure Initialize(ABytes: PByte; ALength: Integer); overload; inline;
      procedure Initialize(AValue: UInt64); overload; inline;

      class operator Implicit(AValue: UInt64): VarInt; static; inline;
  end;

function ZigZag(AValue: Int32): UInt32; overload; inline;
function ZigZag(AValue: Int64): UInt64; overload; inline;
function ZigZag(AValue: UInt32): Int32; overload; inline;
function ZigZag(AValue: UInt64): Int64; overload; inline;

implementation

function ZigZag(AValue: Int32): UInt32;
begin
  Result := (AValue shl 1) xor - (AValue shr 31);
end;

function ZigZag(AValue: Int64): UInt64;
begin
  Result := (AValue shl 1) xor - (AValue shr 63);
end;

function ZigZag(AValue: UInt32): Int32;
begin
  Result := (AValue shr 1) xor - (AValue and 1);
end;

function ZigZag(AValue: UInt64): Int64;
begin
  Result := (AValue shr 1) xor - (AValue and 1);
end;

{ VarInt }

procedure VarInt.Initialize(ABytes: PByte; ALength: Integer);
begin
  FImpl.FBytes     := ABytes;
  FImpl.FMaxLength := ALength;
  FValue           := FImpl.GetValue;
end;

procedure VarInt.Initialize(AValue: UInt64);
begin
  FImpl.FBytes     := @FBytes[0];
  FImpl.FMaxLength := CMaxLength;
  FImpl.SetValue(AValue);
  FValue           := AValue;
end;

class operator VarInt.Implicit(AValue: UInt64): VarInt;
begin
  Result.Initialize(AValue);
end;

{ VarIntImpl }

function VarIntImpl.GetValue: UInt64;
var
  Shift: Byte;
begin
  Shift  := 0;
  FCount := 0;
  Result := FBytes[FCount] and CBitMask;
  while (FCount < FMaxLength) and (FBytes[FCount] >= CBitLimit) do
    begin
      Inc(FCount);
      Inc(Shift, CBitShift);
      Result := Result or (UInt64(FBytes[FCount] and CBitMask) shl Shift);
    end;
  Inc(FCount);
end;

procedure VarIntImpl.SetValue(AValue: UInt64);
begin
  FCount := 0;
  while (FCount < FMaxLength) and (AValue >= CBitLimit) do
    begin
      FBytes[FCount] := AValue or CBitLimit;
      AValue         := AValue shr CBitShift;
      Inc(FCount);
    end;
  Assert(AValue < CBitLimit);
  FBytes[FCount]     := AValue;
  Inc(FCount);
  FBytes[FCount - 1] := FBytes[FCount - 1] and CBitMask;
end;

end.
