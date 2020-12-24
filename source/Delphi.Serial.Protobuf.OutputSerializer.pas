unit Delphi.Serial.Protobuf.OutputSerializer;

interface

uses
  Delphi.Serial.Protobuf.Serializer,
  Delphi.Serial.RttiObserver,
  Delphi.Serial.Protobuf,
  System.Classes,
  System.SysUtils;

type

  TFieldContext = record
    FFieldName: string;
    FTypeName: string;
    FTypeKind: TTypeKind;
    FBeforePos: Int64;
    FStartPos: Int64;
    FFieldTag: FieldTag;
    FHasTag: Boolean;
    FIsArray: Boolean;
    FIsPacked: Boolean;
    FIsSigned: Boolean;
    FIsFixed: Boolean;
    procedure Initialize(const AName: string);
  end;

  PFieldContext = ^TFieldContext;

  TUTF8Encoding = class(System.SysUtils.TUTF8Encoding)
    protected
      function GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer; override;
  end;

  TOutputSerializer = class(TSerializer, IRttiObserver)
    private const
      CInitialFieldRecursionCount  = 16; // start with this number of field recursion levels
      CLengthPrefixReservedSize    = 2;  // space reserved for a VarInt with unknown size
      CPackedArrayElementTypeKinds = [tkInteger, tkFloat, tkEnumeration, tkInt64];

    private
      FFieldContexts         : TArray<TFieldContext>;
      FFieldRecursion        : Integer;
      class var FUTF8Encoding: TUTF8Encoding;

      function CurrentContext: PFieldContext; inline;
      procedure BeginLengthPrefixedWithUnknownSize;
      procedure EndLengthPrefixedWithUnknownSize;
      procedure PackLengthPrefix(WrittenCount: Integer);

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

      procedure BeginRecord;
      procedure EndRecord;
      procedure BeginField(const AName: string);
      procedure EndField;
      procedure BeginStaticArray(ALength: Integer);
      procedure EndStaticArray;
      procedure BeginDynamicArray(var ALength: Integer);
      procedure EndDynamicArray;

      function SkipField: Boolean;
      function SkipEnumNames: Boolean;
      function SkipAttributes: Boolean;
      function SkipCaseBranch(ABranch: Integer): Boolean;
      function ByteArrayAsAWhole: Boolean;

      procedure DataType(const AName: string; AKind: TTypeKind);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

    public
      constructor Create(AStream: TCustomMemoryStream);
  end;

implementation

uses
  Delphi.Serial.ProtobufTypes;

{ TFieldContext }

procedure TFieldContext.Initialize(const AName: string);
begin
  Self       := Default (TFieldContext);
  FFieldName := AName;
end;

{ TUTF8Encoding }

function TUTF8Encoding.GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := inherited;
end;

{ TOutputSerializer }

constructor TOutputSerializer.Create(AStream: TCustomMemoryStream);
begin
  inherited Create(AStream);
  SetLength(FFieldContexts, CInitialFieldRecursionCount);
  FFieldRecursion := - 1;
end;

function TOutputSerializer.CurrentContext: PFieldContext;
begin
  Assert(FFieldRecursion >= 0);
  Result := Addr(FFieldContexts[FFieldRecursion]);
end;

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin
  if AAttribute is ProtobufAttribute then
    begin
      if FFieldRecursion < 0 then
        raise EProtobufError.Create('Only fields can be marked with a Protobuf tag');
      with CurrentContext^ do
        begin
          FFieldTag := (AAttribute as ProtobufAttribute).FieldTag;
          FHasTag   := True;
        end;
    end;
end;

procedure TOutputSerializer.BeginField(const AName: string);
begin
  Inc(FFieldRecursion);
  if FFieldRecursion = Length(FFieldContexts) then
    SetLength(FFieldContexts, 2 * FFieldRecursion);
  CurrentContext.Initialize(AName);
end;

procedure TOutputSerializer.BeginRecord;
begin
  if FFieldRecursion >= 0 then
    BeginLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.BeginLengthPrefixedWithUnknownSize;
begin
  with CurrentContext^ do
    begin
      FBeforePos := Skip(0);
      Pack(TWireType.LengthPrefixed, FFieldTag);
      FStartPos  := Skip(CLengthPrefixReservedSize);
    end;
end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin
  raise EProtobufError.Create('Static arrays are not supported in Protobuf');
end;

procedure TOutputSerializer.BeginDynamicArray(var ALength: Integer);
begin
  with CurrentContext^ do
    begin
      if FIsArray then
        raise EProtobufError.Create('Arrays of arrays are not supported in Protobuf');
      FIsArray := True;
    end;
end;

procedure TOutputSerializer.EndField;
begin
  Assert(FFieldRecursion >= 0);
  Dec(FFieldRecursion);
end;

procedure TOutputSerializer.EndRecord;
begin
  if FFieldRecursion >= 0 then
    EndLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.EndLengthPrefixedWithUnknownSize;
var
  WrittenCount: Integer;
begin
  with CurrentContext^ do
    begin
      WrittenCount := Skip(0) - FStartPos;
      Assert(WrittenCount >= 0);
      if WrittenCount > 0 then
        PackLengthPrefix(WrittenCount)
      else
        Skip(FBeforePos - FStartPos); // omit empty value from output and discard the tag that had been packed
    end;
end;

procedure TOutputSerializer.PackLengthPrefix(WrittenCount: Integer);
var
  LengthPrefix: VarInt;
  PrefixDiff  : Integer;
begin
  LengthPrefix := VarInt(WrittenCount);
  PrefixDiff   := LengthPrefix.Count - CLengthPrefixReservedSize;
  Skip(- WrittenCount);
  if PrefixDiff <> 0 then
    Move(WrittenCount, PrefixDiff); // move memory by a few bytes to fit the length prefix
  Skip(- CLengthPrefixReservedSize);
  Pack(LengthPrefix);
  Skip(WrittenCount);
end;

procedure TOutputSerializer.EndStaticArray;
begin
  Assert(False); // should not be called
end;

procedure TOutputSerializer.EndDynamicArray;
begin
  with CurrentContext^ do
    begin
      Assert(FIsArray);
      if FIsPacked then
        EndLengthPrefixedWithUnknownSize;
      FIsArray := False;
    end;
end;

procedure TOutputSerializer.EnumName(const AName: string);
begin
  Assert(False); // should not be called
end;

function TOutputSerializer.SkipCaseBranch(ABranch: Integer): Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipEnumNames: Boolean;
begin
  Result := True;
end;

function TOutputSerializer.SkipField: Boolean;
begin
  Result := not CurrentContext.FHasTag;
end;

function TOutputSerializer.SkipAttributes: Boolean;
begin
  Result := False;
end;

function TOutputSerializer.ByteArrayAsAWhole: Boolean;
begin
  Result := True;
end;

procedure TOutputSerializer.DataType(const AName: string; AKind: TTypeKind);
begin
  if FFieldRecursion >= 0 then
    with CurrentContext^ do
      begin
        FTypeName := AName.ToUpper; // uppercase so we can easily test for equality
        FIsSigned := FTypeName.StartsWith('SINT');
        FIsFixed  := FTypeName.StartsWith('FIXED') or FTypeName.StartsWith('SFIXED');
        FTypeKind := AKind;
        if FIsArray then // we are dealing with the array element type
          begin
            FIsPacked := AKind in CPackedArrayElementTypeKinds;
            if FIsPacked then
              BeginLengthPrefixedWithUnknownSize; // pack the tag prefix once for the whole array
          end;
      end
  else if AKind <> tkRecord then
    raise EProtobufError.Create('Only records can be serialized in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Int8);
begin
  raise EProtobufError.Create('Int8 is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Int16);
begin
  raise EProtobufError.Create('Int16 is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Int32);
begin
  if AValue = 0 then
    Exit; // omit empty value from output
  with CurrentContext^ do
    if FIsSigned then
      begin
        if not FIsArray then
          Pack(TWireType.VarInt, FFieldTag);
        Pack(SignedInt(AValue));
      end
    else if FIsFixed then
      begin
        if not FIsArray then
          Pack(TWireType.Fixed32, FFieldTag);
        Pack(FixedInt32(AValue));
      end
    else
      begin
        if not FIsArray then
          Pack(TWireType.VarInt, FFieldTag);
        Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: Int64);
begin
  if AValue = 0 then
    Exit; // omit empty value from output
  with CurrentContext^ do
    if FIsSigned then
      begin
        if not FIsArray then
          Pack(TWireType.VarInt, FFieldTag);
        Pack(SignedInt(AValue));
      end
    else if FIsFixed then
      begin
        if not FIsArray then
          Pack(TWireType.Fixed64, FFieldTag);
        Pack(FixedInt64(AValue));
      end
    else
      begin
        if not FIsArray then
          Pack(TWireType.VarInt, FFieldTag);
        Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt8);
begin
  with CurrentContext^ do
    begin
      if (not FIsArray) and (FTypeKind <> tkEnumeration) then
        raise EProtobufError.Create('UInt8 is not supported in Protobuf');
      if AValue = 0 then
        Exit; // omit empty value from output
      if not FIsArray then
        Pack(TWireType.VarInt, FFieldTag);
    end;
  Pack(VarInt(AValue));
end;

procedure TOutputSerializer.Value(var AValue: UInt16);
begin
  with CurrentContext^ do
    begin
      if FTypeKind <> tkEnumeration then
        raise EProtobufError.Create('UInt16 is not supported in Protobuf');
      if AValue = 0 then
        Exit; // omit empty value from output
      if not FIsArray then
        Pack(TWireType.VarInt, FFieldTag);
    end;
  Pack(VarInt(AValue));
end;

procedure TOutputSerializer.Value(var AValue: UInt32);
begin
  if AValue = 0 then
    Exit; // omit empty value from output
  with CurrentContext^ do
    if FIsFixed then
      begin
        if not FIsArray then
          Pack(TWireType.Fixed32, FFieldTag);
        Pack(FixedInt32(AValue));
      end
    else
      begin
        if not FIsArray then
          Pack(TWireType.VarInt, FFieldTag);
        Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt64);
begin
  if AValue = 0 then
    Exit; // omit empty value from output
  with CurrentContext^ do
    if FIsFixed then
      begin
        if not FIsArray then
          Pack(TWireType.Fixed64, FFieldTag);
        Pack(FixedInt64(AValue));
      end
    else
      begin
        if not FIsArray then
          Pack(TWireType.VarInt, FFieldTag);
        Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: Single);
begin
  if AValue = 0 then
    Exit; // omit empty value from output
  with CurrentContext^ do
    if not FIsArray then
      Pack(TWireType.Fixed32, FFieldTag);
  Pack(FixedInt32(AValue));
end;

procedure TOutputSerializer.Value(var AValue: Double);
begin
  if AValue = 0 then
    Exit; // omit empty value from output
  with CurrentContext^ do
    if not FIsArray then
      Pack(TWireType.Fixed64, FFieldTag);
  Pack(FixedInt64(AValue));
end;

procedure TOutputSerializer.Value(var AValue: Extended);
begin
  raise EProtobufError.Create('Extended is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Comp);
begin
  raise EProtobufError.Create('Comp is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Currency);
begin
  raise EProtobufError.Create('Currency is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: ShortString);
begin
  raise EProtobufError.Create('ShortString is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: AnsiString);
begin
  raise EProtobufError.Create('AnsiString is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: WideString);
begin
  raise EProtobufError.Create('WideString is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: UnicodeString);
var
  Count: Integer;
  Start: PByte;
begin
  if AValue.IsEmpty then
    Exit; // omit empty value from output
  Pack(TWireType.LengthPrefixed, CurrentContext.FFieldTag);
  Count := FUTF8Encoding.GetByteCount(AValue);
  Pack(VarInt(Count));
  Start := Require(Count);
  Count := FUTF8Encoding.GetBytes(PChar(AValue), AValue.Length, Start, Count);
  Skip(Count);
end;

procedure TOutputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin
  if AByteCount = 0 then
    Exit; // omit empty value from output
  Pack(TWireType.LengthPrefixed, CurrentContext.FFieldTag);
  Pack(VarInt(AByteCount));
  Write(AValue^, AByteCount);
end;

initialization

TOutputSerializer.FUTF8Encoding := TUTF8Encoding.Create;

finalization

TOutputSerializer.FUTF8Encoding.Free;

end.
