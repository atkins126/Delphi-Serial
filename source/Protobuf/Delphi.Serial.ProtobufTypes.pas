unit Delphi.Serial.ProtobufTypes;

{$SCOPEDENUMS ON}

interface

type

  TWireType = (VarInt = 0, Fixed64 = 1, LengthPrefixed = 2, Fixed32 = 5);

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
    private const
      CMaxLength = 10;

    private
      FBytes: array [0 .. CMaxLength - 1] of Byte;
      FImpl : VarIntImpl;
      FValue: UInt64;

      procedure Initialize(AValue: UInt64); overload; inline;

    public
      property Count: Integer read FImpl.FCount;

      procedure Initialize(ABytes: PByte; ALength: Integer); overload; inline;

      class operator Explicit(AValue: Int32): VarInt; static; inline;
      class operator Explicit(AValue: Int64): VarInt; static; inline;
      class operator Explicit(AValue: UInt32): VarInt; static; inline;
      class operator Explicit(AValue: UInt64): VarInt; static; inline;
      class operator Explicit(AValue: VarInt): Int32; static; inline;
      class operator Explicit(AValue: VarInt): Int64; static; inline;
      class operator Explicit(AValue: VarInt): UInt32; static; inline;
      class operator Explicit(AValue: VarInt): UInt64; static; inline;
  end;

  SignedInt = record
    private
      FVarInt: VarInt;

      class function ZigZag(AValue: Int32): UInt32; overload; static; inline;
      class function ZigZag(AValue: Int64): UInt64; overload; static; inline;
      class function ZigZag(AValue: UInt32): Int32; overload; static; inline;
      class function ZigZag(AValue: UInt64): Int64; overload; static; inline;

    public
      property Count: Integer read FVarInt.FImpl.FCount;

      procedure Initialize(ABytes: PByte; ALength: Integer); inline;

      class operator Explicit(AValue: Int32): SignedInt; static; inline;
      class operator Explicit(AValue: Int64): SignedInt; static; inline;
      class operator Explicit(AValue: SignedInt): Int32; static; inline;
      class operator Explicit(AValue: SignedInt): Int64; static; inline;
  end;

  FixedInt32 = record
    private
      FValue: UInt32;

    public
      class operator Explicit(AValue: Int32): FixedInt32; static; inline;
      class operator Explicit(AValue: UInt32): FixedInt32; static; inline;
      class operator Explicit(AValue: Single): FixedInt32; static; inline;
      class operator Explicit(AValue: FixedInt32): Int32; static; inline;
      class operator Explicit(AValue: FixedInt32): UInt32; static; inline;
      class operator Explicit(AValue: FixedInt32): Single; static; inline;
  end;

  FixedInt64 = record
    private
      FValue: UInt64;

    public
      class operator Explicit(AValue: Int64): FixedInt64; static; inline;
      class operator Explicit(AValue: UInt64): FixedInt64; static; inline;
      class operator Explicit(AValue: Double): FixedInt64; static; inline;
      class operator Explicit(AValue: Comp): FixedInt64; static; inline;
      class operator Explicit(AValue: Currency): FixedInt64; static; inline;
      class operator Explicit(AValue: FixedInt64): Int64; static; inline;
      class operator Explicit(AValue: FixedInt64): UInt64; static; inline;
      class operator Explicit(AValue: FixedInt64): Double; static; inline;
      class operator Explicit(AValue: FixedInt64): Comp; static; inline;
      class operator Explicit(AValue: FixedInt64): Currency; static; inline;
  end;

implementation

uses
  System.Math;

{ VarInt }

procedure VarInt.Initialize(ABytes: PByte; ALength: Integer);
begin
  FImpl.FBytes     := ABytes;
  FImpl.FMaxLength := Min(ALength, CMaxLength);
  FValue           := FImpl.GetValue;
end;

procedure VarInt.Initialize(AValue: UInt64);
begin
  FImpl.FBytes     := @FBytes[0];
  FImpl.FMaxLength := CMaxLength;
  FImpl.SetValue(AValue);
  FValue           := AValue;
end;

class operator VarInt.Explicit(AValue: Int32): VarInt;
begin
  Result.Initialize(AValue);
end;

class operator VarInt.Explicit(AValue: Int64): VarInt;
begin
  Result.Initialize(AValue);
end;

class operator VarInt.Explicit(AValue: UInt64): VarInt;
begin
  Result.Initialize(AValue);
end;

class operator VarInt.Explicit(AValue: UInt32): VarInt;
begin
  Result.Initialize(AValue);
end;

class operator VarInt.Explicit(AValue: VarInt): Int32;
begin
  Result := AValue.FValue;
end;

class operator VarInt.Explicit(AValue: VarInt): Int64;
begin
  Result := AValue.FValue;
end;

class operator VarInt.Explicit(AValue: VarInt): UInt32;
begin
  Result := AValue.FValue;
end;

class operator VarInt.Explicit(AValue: VarInt): UInt64;
begin
  Result := AValue.FValue;
end;

{ SignedInt }

procedure SignedInt.Initialize(ABytes: PByte; ALength: Integer);
begin
  FVarInt.Initialize(ABytes, ALength);
end;

class operator SignedInt.Explicit(AValue: Int32): SignedInt;
begin
  Result.FVarInt.Initialize(ZigZag(AValue));
end;

class operator SignedInt.Explicit(AValue: Int64): SignedInt;
begin
  Result.FVarInt.Initialize(ZigZag(AValue));
end;

class operator SignedInt.Explicit(AValue: SignedInt): Int32;
begin
  Result := ZigZag(UInt32(AValue.FVarInt));
end;

class operator SignedInt.Explicit(AValue: SignedInt): Int64;
begin
  Result := ZigZag(UInt64(AValue.FVarInt));
end;

class function SignedInt.ZigZag(AValue: Int32): UInt32;
begin
  Result := (AValue shl 1) xor - (AValue shr 31);
end;

class function SignedInt.ZigZag(AValue: Int64): UInt64;
begin
  Result := (AValue shl 1) xor - (AValue shr 63);
end;

class function SignedInt.ZigZag(AValue: UInt32): Int32;
begin
  Result := (AValue shr 1) xor - (AValue and 1);
end;

class function SignedInt.ZigZag(AValue: UInt64): Int64;
begin
  Result := (AValue shr 1) xor - (AValue and 1);
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

{ FixedInt32 }

class operator FixedInt32.Explicit(AValue: Int32): FixedInt32;
begin
  Result.FValue := AValue;
end;

class operator FixedInt32.Explicit(AValue: UInt32): FixedInt32;
begin
  Result.FValue := AValue;
end;

class operator FixedInt32.Explicit(AValue: Single): FixedInt32;
begin
  Result.FValue := PUint32(Addr(AValue))^;
end;

class operator FixedInt32.Explicit(AValue: FixedInt32): UInt32;
begin
  Result := AValue.FValue;
end;

class operator FixedInt32.Explicit(AValue: FixedInt32): Int32;
begin
  Result := AValue.FValue;
end;

class operator FixedInt32.Explicit(AValue: FixedInt32): Single;
begin
  Result := PSingle(Addr(AValue.FValue))^;
end;

{ FixedInt64 }

class operator FixedInt64.Explicit(AValue: Int64): FixedInt64;
begin
  Result.FValue := AValue;
end;

class operator FixedInt64.Explicit(AValue: UInt64): FixedInt64;
begin
  Result.FValue := AValue;
end;

class operator FixedInt64.Explicit(AValue: Double): FixedInt64;
begin
  Result.FValue := PUint64(Addr(AValue))^;
end;

class operator FixedInt64.Explicit(AValue: Comp): FixedInt64;
begin
  Result.FValue := PUint64(Addr(AValue))^;
end;

class operator FixedInt64.Explicit(AValue: Currency): FixedInt64;
begin
  Result.FValue := PUint64(Addr(AValue))^;
end;

class operator FixedInt64.Explicit(AValue: FixedInt64): UInt64;
begin
  Result := AValue.FValue;
end;

class operator FixedInt64.Explicit(AValue: FixedInt64): Int64;
begin
  Result := AValue.FValue;
end;

class operator FixedInt64.Explicit(AValue: FixedInt64): Double;
begin
  Result := PDouble(Addr(AValue.FValue))^;
end;

class operator FixedInt64.Explicit(AValue: FixedInt64): Comp;
begin
  Result := PComp(Addr(AValue.FValue))^;
end;

class operator FixedInt64.Explicit(AValue: FixedInt64): Currency;
begin
  Result := PCurrency(Addr(AValue.FValue))^;
end;

end.
