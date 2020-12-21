unit Delphi.Serial.Utils;

interface

type

  VarInt = record
    public const
      CMaxLength = 10;

    private
      FBytes: array [0 .. CMaxLength - 1] of Byte;
      FCount: Integer;

      constructor Create(AValue: UInt64);
      function Extract: UInt64;

    const
      CBitShift = 7;
      CBitLimit = 1 shl CBitShift;
      CBitMask  = CBitLimit - 1;

    public
      property Count: Integer read FCount;

      class operator Implicit(AValue: UInt32): VarInt; inline;
      class operator Implicit(AValue: UInt64): VarInt; inline;
      class operator Implicit(AValue: VarInt): UInt32; inline;
      class operator Implicit(AValue: VarInt): UInt64; inline;
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

constructor VarInt.Create(AValue: UInt64);
begin
  FCount := 0;
  while (FCount < CMaxLength) and (AValue >= CBitLimit) do
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

function VarInt.Extract: UInt64;
var
  Shift: Byte;
begin
  Shift  := 0;
  FCount := 0;
  Result := FBytes[FCount] and CBitMask;
  while (FCount < CMaxLength) and (FBytes[FCount] >= CBitLimit) do
    begin
      Inc(FCount);
      Inc(Shift, CBitShift);
      Result := Result or (UInt64(FBytes[FCount] and CBitMask) shl Shift);
    end;
  Inc(FCount);
end;

class operator VarInt.Implicit(AValue: UInt32): VarInt;
begin
  Result := VarInt.Create(AValue);
end;

class operator VarInt.Implicit(AValue: UInt64): VarInt;
begin
  Result := VarInt.Create(AValue);
end;

class operator VarInt.Implicit(AValue: VarInt): UInt32;
begin
  Result := AValue.Extract;
end;

class operator VarInt.Implicit(AValue: VarInt): UInt64;
begin
  Result := AValue.Extract;
end;

end.
