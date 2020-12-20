unit Delphi.Serial.Protobuf;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial.RttiObserver,
  System.Classes;

type

  FieldNumber = 1 .. 536870911;
  SignedInt32 = type Int32;
  SignedInt64 = type Int64;
  FixedUInt32 = type UInt32;
  FixedUInt64 = type UInt64;

  ProtobufAttribute = class(TCustomAttribute)
    private
      FFieldNumber: FieldNumber;

    public
      constructor Create(AFieldNumber: FieldNumber);

      property FieldNumber: FieldNumber read FFieldNumber;
  end;

  TSerializer = class(TInterfacedObject)
    protected
      FStream: TStream;

      procedure Parse(var AValue: Int32); overload; inline;
      procedure Parse(var AValue: Int64); overload; inline;
      procedure Parse(var AValue: UInt32); overload; inline;
      procedure Parse(var AValue: UInt64); overload; inline;
      procedure Parse(var AValue: SignedInt32); overload; inline;
      procedure Parse(var AValue: SignedInt64); overload; inline;
      procedure Parse(var AValue: FixedUInt32); overload; inline;
      procedure Parse(var AValue: FixedUInt64); overload; inline;

      procedure Pack(AValue: Int32); overload; inline;
      procedure Pack(AValue: Int64); overload; inline;
      procedure Pack(AValue: UInt32); overload; inline;
      procedure Pack(AValue: UInt64); overload; inline;
      procedure Pack(AValue: SignedInt32); overload; inline;
      procedure Pack(AValue: SignedInt64); overload; inline;
      procedure Pack(AValue: FixedUInt32); overload; inline;
      procedure Pack(AValue: FixedUInt64); overload; inline;

    public
      property Stream: TStream read FStream write FStream;
  end;

  TInputSerializer = class(TSerializer, IRttiObserver)
    private
      procedure Value(var AValue: Int8); overload;
      procedure Value(var AValue: Int16); overload;
      procedure Value(var AValue: Int32); overload;
      procedure Value(var AValue: Int64); overload;
      procedure Value(var AValue: UInt8); overload;
      procedure Value(var AValue: UInt16); overload;
      procedure Value(var AValue: UInt32); overload;
      procedure Value(var AValue: UInt64); overload;
      procedure Value(var AValue: Single); overload;
      procedure Value(var AValue: Double); overload;
      procedure Value(var AValue: Extended); overload;
      procedure Value(var AValue: Comp); overload;
      procedure Value(var AValue: Currency); overload;
      procedure Value(var AValue: ShortString); overload;
      procedure Value(var AValue: AnsiString); overload;
      procedure Value(var AValue: WideString); overload;
      procedure Value(var AValue: UnicodeString); overload;
      procedure Value(AValue: Pointer; AByteCount: Integer); overload;

      procedure BeginRecord(const AName: string);
      procedure EndRecord;
      procedure BeginField(const AName: string);
      procedure EndField;
      procedure BeginFixedArray(ALength: Integer);
      procedure EndFixedArray;
      procedure BeginVariableArray(var ALength: Integer);
      procedure EndVariableArray;

      function SkipEnumNames: Boolean;
      function SkipRecordAttributes: Boolean;
      function SkipFieldAttributes: Boolean;
      function SkipBranch(ABranch: Integer): Boolean;
      function ByteArrayAsAWhole: Boolean;

      procedure TypeKind(AKind: TTypeKind);
      procedure TypeName(const AName: string);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

    public
      constructor Create;
      destructor Destroy; override;
  end;

  TOutputSerializer = class(TSerializer, IRttiObserver)
    private
      procedure Value(var AValue: Int8); overload;
      procedure Value(var AValue: Int16); overload;
      procedure Value(var AValue: Int32); overload;
      procedure Value(var AValue: Int64); overload;
      procedure Value(var AValue: UInt8); overload;
      procedure Value(var AValue: UInt16); overload;
      procedure Value(var AValue: UInt32); overload;
      procedure Value(var AValue: UInt64); overload;
      procedure Value(var AValue: Single); overload;
      procedure Value(var AValue: Double); overload;
      procedure Value(var AValue: Extended); overload;
      procedure Value(var AValue: Comp); overload;
      procedure Value(var AValue: Currency); overload;
      procedure Value(var AValue: ShortString); overload;
      procedure Value(var AValue: AnsiString); overload;
      procedure Value(var AValue: WideString); overload;
      procedure Value(var AValue: UnicodeString); overload;
      procedure Value(AValue: Pointer; AByteCount: Integer); overload;

      procedure BeginRecord(const AName: string);
      procedure EndRecord;
      procedure BeginField(const AName: string);
      procedure EndField;
      procedure BeginFixedArray(ALength: Integer);
      procedure EndFixedArray;
      procedure BeginVariableArray(var ALength: Integer);
      procedure EndVariableArray;

      function SkipEnumNames: Boolean;
      function SkipRecordAttributes: Boolean;
      function SkipFieldAttributes: Boolean;
      function SkipBranch(ABranch: Integer): Boolean;
      function ByteArrayAsAWhole: Boolean;

      procedure TypeKind(AKind: TTypeKind);
      procedure TypeName(const AName: string);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

type

  ESerializationError = class(Exception);

  TWireType           = (VarInt = 0, _64bit = 1, LengthPrefixed = 2, _32bit = 5);

  VarInt32 = record
    const
      CMaxLength = 5;

    public
      FBytes: array [0 .. CMaxLength - 1] of Byte;
      FCount: Integer;

    private
      class function BuiltinBsr(AValue: UInt32): Integer; static;

    public
      constructor Create(AValue: UInt32);
      function Extract: UInt32;
  end;

  VarInt64 = record
    const
      CMaxLength = 10;

    public
      FBytes: array [0 .. CMaxLength - 1] of Byte;
      FCount: Integer;

    private
      class function BuiltinBsr(AValue: UInt64): Integer; static;

    public
      constructor Create(AValue: UInt64);
      function Extract: UInt64;
  end;
      
  TIntegerUtils = class
    public
      class function ZigZag(AValue: Int32): UInt32; overload; static; inline;
      class function ZigZag(AValue: Int64): UInt64; overload; static; inline;
      class function ZigZag(AValue: UInt32): Int32; overload; static; inline;
      class function ZigZag(AValue: UInt64): Int64; overload; static; inline;
  end;

{ ProtobufAttribute }

constructor ProtobufAttribute.Create(AFieldNumber: FieldNumber);
begin
  FFieldNumber := AFieldNumber;
end;

{ TSerializer }

procedure TSerializer.Pack(AValue: Int32);
begin
  if AValue < 0 then
    Pack(Int64(AValue))
  else
    Pack(PUInt32(Addr(AValue))^);
end;

procedure TSerializer.Pack(AValue: Int64);
begin
  Pack(PUInt64(Addr(AValue))^);
end;

procedure TSerializer.Pack(AValue: UInt32);
var
  Target: VarInt32;
begin
  Target := VarInt32.Create(AValue);
  FStream.Write(Target, Target.FCount);
end;

procedure TSerializer.Pack(AValue: UInt64);
var
  Target: VarInt64;
begin
  Target := VarInt64.Create(AValue);
  FStream.Write(Target, Target.FCount);
end;

procedure TSerializer.Pack(AValue: FixedUInt32);
begin
  FStream.Write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Pack(AValue: FixedUInt64);
begin
  FStream.Write(AValue, SizeOf(AValue));
end;

procedure TSerializer.Pack(AValue: SignedInt32);
begin
  Pack(TIntegerUtils.ZigZag(AValue));
end;

procedure TSerializer.Pack(AValue: SignedInt64);
begin
  Pack(TIntegerUtils.ZigZag(AValue));
end;

procedure TSerializer.Parse(var AValue: Int32);
begin
  Parse(PUInt32(Addr(AValue))^);
  if AValue < 0 then
    FStream.Seek(VarInt32.CMaxLength, TSeekOrigin.soCurrent); // skip high bytes of encoded Int64
end;

procedure TSerializer.Parse(var AValue: Int64);
begin
  Parse(PUInt64(Addr(AValue))^);
end;

procedure TSerializer.Parse(var AValue: UInt32);
var
  Source: VarInt32;
begin
  FStream.Read(Source, Source.CMaxLength);
  AValue := Source.Extract;
  FStream.Seek(Source.FCount - Source.CMaxLength, TSeekOrigin.soCurrent);
end;

procedure TSerializer.Parse(var AValue: UInt64);
var
  Source: VarInt64;
begin
  FStream.Read(Source, Source.CMaxLength);
  AValue := Source.Extract;
  FStream.Seek(Source.FCount - Source.CMaxLength, TSeekOrigin.soCurrent);
end;

procedure TSerializer.Parse(var AValue: FixedUInt32);
begin
  FStream.Read(AValue, SizeOf(AValue));
end;

procedure TSerializer.Parse(var AValue: FixedUInt64);
begin
  FStream.Read(AValue, SizeOf(AValue));
end;

procedure TSerializer.Parse(var AValue: SignedInt32);
var
  Value: UInt32;
begin
  Parse(Value);
  AValue := TIntegerUtils.ZigZag(Value);
end;

procedure TSerializer.Parse(var AValue: SignedInt64);
var
  Value: UInt64;
begin
  Parse(Value);
  AValue := TIntegerUtils.ZigZag(Value);
end;

{ TInputSerializer }

procedure TInputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin

end;

procedure TInputSerializer.BeginField(const AName: string);
begin

end;

procedure TInputSerializer.BeginFixedArray(ALength: Integer);
begin

end;

procedure TInputSerializer.BeginRecord(const AName: string);
begin

end;

procedure TInputSerializer.BeginVariableArray(var ALength: Integer);
begin

end;

function TInputSerializer.ByteArrayAsAWhole: Boolean;
begin
  Result := True;
end;

constructor TInputSerializer.Create;
begin

end;

destructor TInputSerializer.Destroy;
begin

  inherited;
end;

procedure TInputSerializer.EndField;
begin

end;

procedure TInputSerializer.EndFixedArray;
begin

end;

procedure TInputSerializer.EndRecord;
begin

end;

procedure TInputSerializer.EndVariableArray;
begin

end;

procedure TInputSerializer.EnumName(const AName: string);
begin

end;

function TInputSerializer.SkipBranch(ABranch: Integer): Boolean;
begin
  Result := False;
end;

function TInputSerializer.SkipEnumNames: Boolean;
begin
  Result := True;
end;

function TInputSerializer.SkipFieldAttributes: Boolean;
begin
  Result := False;
end;

function TInputSerializer.SkipRecordAttributes: Boolean;
begin
  Result := True;
end;

procedure TInputSerializer.TypeKind(AKind: TTypeKind);
begin

end;

procedure TInputSerializer.TypeName(const AName: string);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt8);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt16);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt32);
begin

end;

procedure TInputSerializer.Value(var AValue: Int64);
begin

end;

procedure TInputSerializer.Value(var AValue: Int8);
begin

end;

procedure TInputSerializer.Value(var AValue: Int16);
begin

end;

procedure TInputSerializer.Value(var AValue: Int32);
begin

end;

procedure TInputSerializer.Value(var AValue: Currency);
begin

end;

procedure TInputSerializer.Value(var AValue: ShortString);
begin

end;

procedure TInputSerializer.Value(var AValue: AnsiString);
begin

end;

procedure TInputSerializer.Value(var AValue: WideString);
begin

end;

procedure TInputSerializer.Value(var AValue: UnicodeString);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt64);
begin

end;

procedure TInputSerializer.Value(var AValue: Single);
begin

end;

procedure TInputSerializer.Value(var AValue: Double);
begin

end;

procedure TInputSerializer.Value(var AValue: Extended);
begin

end;

procedure TInputSerializer.Value(var AValue: Comp);
begin

end;

procedure TInputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin

end;

{ TOutputSerializer }

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin

end;

procedure TOutputSerializer.BeginField(const AName: string);
begin

end;

procedure TOutputSerializer.BeginFixedArray(ALength: Integer);
begin

end;

procedure TOutputSerializer.BeginRecord(const AName: string);
begin

end;

procedure TOutputSerializer.BeginVariableArray(var ALength: Integer);
begin

end;

function TOutputSerializer.ByteArrayAsAWhole: Boolean;
begin
  Result := True;
end;

constructor TOutputSerializer.Create;
begin

end;

destructor TOutputSerializer.Destroy;
begin

  inherited;
end;

procedure TOutputSerializer.EndField;
begin

end;

procedure TOutputSerializer.EndFixedArray;
begin

end;

procedure TOutputSerializer.EndRecord;
begin

end;

procedure TOutputSerializer.EndVariableArray;
begin

end;

procedure TOutputSerializer.EnumName(const AName: string);
begin

end;

function TOutputSerializer.SkipBranch(ABranch: Integer): Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipEnumNames: Boolean;
begin
  Result := True;
end;

function TOutputSerializer.SkipFieldAttributes: Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipRecordAttributes: Boolean;
begin
  Result := True;
end;

procedure TOutputSerializer.TypeKind(AKind: TTypeKind);
begin

end;

procedure TOutputSerializer.TypeName(const AName: string);
begin

end;

procedure TOutputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin

end;

procedure TOutputSerializer.Value(var AValue: UInt8);
begin

end;

procedure TOutputSerializer.Value(var AValue: UInt16);
begin

end;

procedure TOutputSerializer.Value(var AValue: UInt32);
begin

end;

procedure TOutputSerializer.Value(var AValue: Int64);
begin

end;

procedure TOutputSerializer.Value(var AValue: Int8);
begin

end;

procedure TOutputSerializer.Value(var AValue: Int16);
begin

end;

procedure TOutputSerializer.Value(var AValue: Int32);
begin

end;

procedure TOutputSerializer.Value(var AValue: Currency);
begin

end;

procedure TOutputSerializer.Value(var AValue: ShortString);
begin

end;

procedure TOutputSerializer.Value(var AValue: AnsiString);
begin

end;

procedure TOutputSerializer.Value(var AValue: WideString);
begin

end;

procedure TOutputSerializer.Value(var AValue: UnicodeString);
begin

end;

procedure TOutputSerializer.Value(var AValue: UInt64);
begin

end;

procedure TOutputSerializer.Value(var AValue: Single);
begin

end;

procedure TOutputSerializer.Value(var AValue: Double);
begin

end;

procedure TOutputSerializer.Value(var AValue: Extended);
begin

end;

procedure TOutputSerializer.Value(var AValue: Comp);
begin

end;
    
{ VarInt32 }

class function VarInt32.BuiltinBsr(AValue: UInt32): Integer;
asm
{$IFDEF CPUX64}
  BSR     EAX,ECX
{$ELSE}
  BSR     EAX,EAX
{$ENDIF}
end;

constructor VarInt32.Create(AValue: UInt32);
label
  Count1, Count2, Count3, Count4, Count5;
begin
  FCount := BuiltinBsr(AValue) div 8 + 1;
  if FCount = 1 then
    goto Count1
  else if FCount = 2 then
    goto Count2
  else if FCount = 3 then
    goto Count3
  else if FCount = 4 then
    goto Count4;

Count5:
  FBytes[4] := (AValue shr 28) or $80;
Count4:
  FBytes[3] := (AValue shr 21) or $80;
Count3:
  FBytes[2] := (AValue shr 14) or $80;
Count2:
  FBytes[1] := (AValue shr 7) or $80;
Count1:
  FBytes[0] := AValue or $80;
end;

function VarInt32.Extract: UInt32;
var
  Shift: Byte;
begin
  Shift  := 0;
  FCount := 0;
  Result := FBytes[FCount] and $7F;
  while (FCount < CMaxLength) and (FBytes[FCount] >= $80) do
    begin
      Inc(Shift, 7);
      Inc(FCount);
      Result := Result or (UInt32(FBytes[FCount] and $7F) shl Shift);
    end;
  Inc(FCount);
end;

{ VarInt64 }

class function VarInt64.BuiltinBsr(AValue: UInt64): Integer;
asm
{$IFDEF CPUX64}
  BSR     RAX,RCX
{$ELSE}
  BSR     RAX,RAX
{$ENDIF}
end;

constructor VarInt64.Create(AValue: UInt64);
label
  Count1, Count2, Count3, Count4, Count5, Count6, Count7, Count8, Count9;
begin
  FCount := BuiltinBsr(AValue) div 8 + 1;
  if FCount = 1 then
    goto Count1
  else if FCount = 2 then
    goto Count2
  else if FCount = 3 then
    goto Count3
  else if FCount = 4 then
    goto Count4
  else if FCount = 5 then
    goto Count5
  else if FCount = 6 then
    goto Count6
  else if FCount = 7 then
    goto Count7
  else if FCount = 8 then
    goto Count8
  else if FCount = 9 then
    goto Count9;

  FBytes[9]          := (AValue shr 63) or $80;
Count9:
  FBytes[8]          := (AValue shr 56) or $80;
Count8:
  FBytes[7]          := (AValue shr 49) or $80;
Count7:
  FBytes[6]          := (AValue shr 42) or $80;
Count6:
  FBytes[5]          := (AValue shr 35) or $80;
Count5:
  FBytes[4]          := (AValue shr 28) or $80;
Count4:
  FBytes[3]          := (AValue shr 21) or $80;
Count3:
  FBytes[2]          := (AValue shr 14) or $80;
Count2:
  FBytes[1]          := (AValue shr 7) or $80;
Count1:
  FBytes[0]          := AValue or $80;

  FBytes[FCount - 1] := FBytes[FCount - 1] and $7F;
end;

function VarInt64.Extract: UInt64;
var
  Shift: Byte;
begin
  Shift  := 0;
  FCount := 0;
  Result := FBytes[FCount] and $7F;
  while (FCount < CMaxLength) and (FBytes[FCount] >= $80) do
    begin
      Inc(Shift, 7);
      Inc(FCount);
      Result := Result or (UInt64(FBytes[FCount] and $7F) shl Shift);
    end;
  Inc(FCount);
end;

{ TIntegerUtils }

class function TIntegerUtils.ZigZag(AValue: Int32): UInt32;
begin
  Result := (UInt32(AValue) shl 1) xor UInt32(AValue shr 31);
end;

class function TIntegerUtils.ZigZag(AValue: Int64): UInt64;
begin
  Result := (UInt64(AValue) shl 1) xor UInt64(AValue shr 63);
end;

class function TIntegerUtils.ZigZag(AValue: UInt32): Int32;
begin
  Result := Int32(AValue shr 1) xor - Int32(AValue and 1);
end;

class function TIntegerUtils.ZigZag(AValue: UInt64): Int64;
begin
  Result := Int64(AValue shr 1) xor - Int64(AValue and 1);
end;

end.
