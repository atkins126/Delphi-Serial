unit Delphi.Serial.Protobuf.OutputSerializer;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial.Protobuf.Writer,
  Delphi.Serial.Protobuf,
  Delphi.Serial,
  System.Classes,
  System.SysUtils,
  System.Rtti;

type

  TFieldContext = record
    FFieldName: string;
    FBeforePos: Int64;
    FStartPos: Int64;
    FFieldTag: FieldTag;
    FArrayLength: Integer;
    FIsRequired: Boolean;
    FIsArray: Boolean;
    FIsUnPacked: Boolean;
    FIsPackedArray: Boolean;
    FIsBytes: Boolean;
    FIsSigned: Boolean;
    FIsFixed: Boolean;
    FIsOneof: Boolean;
    FOneofCase: Integer;
    FOneofFieldIndex: Integer;
    procedure Initialize(const AName: string);
  end;

  PFieldContext = ^TFieldContext;

  TUTF8Encoding = class(System.SysUtils.TUTF8Encoding)
    protected
      function GetByteCount(AChars: PChar; ACharCount: Integer): Integer; override;
      function GetBytes(AChars: PChar; ACharCount: Integer; ABytes: PByte; AByteCount: Integer): Integer; override;
  end;

  TOutputOption = (LimitMemoryUsage);

  TOutputOptionHelper = record helper for TOutputOption
    public
      class function From(const AName: string): TOutputOption; static;
  end;

  TProtobufWriter = Delphi.Serial.Protobuf.Writer.TWriter;

  TOutputSerializer = class(TInterfacedObject, ISerializer)
    private const
      CInitialFieldRecursionCount = 16; // start with this number of field recursion levels
      CLengthPrefixReservedSize   = 2;  // space reserved for a VarInt with unknown size
      CPackableElementTypeKinds   = [tkInteger, tkFloat, tkEnumeration, tkInt64];

    private
      FWriter                : TProtobufWriter;
      FFieldContexts         : TArray<TFieldContext>;
      FFieldRecursion        : Integer;
      FLimitMemoryUsage      : Boolean;
      class var FUTF8Encoding: TUTF8Encoding;

      function CurrentContext: PFieldContext; inline;
      function PreviousContext: PFieldContext; inline;
      procedure BeginLengthPrefixedWithUnknownSize;
      procedure EndLengthPrefixedWithUnknownSize;
      procedure PackLengthPrefix(WrittenCount: Integer);
      procedure InitializeTypeFlags(AType: TRttiType);
      procedure Utf8Value(AChars: PChar; ACharCount: Integer);

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

      procedure BeginAll;
      procedure EndAll;
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

      procedure DataType(AType: TRttiType);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

      function GetOption(const AName: string): Variant;
      procedure SetOption(const AName: string; AValue: Variant);

    public
      constructor Create(AStream: TCustomMemoryStream);
      destructor Destroy; override;
  end;

implementation

uses
  Delphi.Serial.Protobuf.Types,
  System.TypInfo;

{ TFieldContext }

procedure TFieldContext.Initialize(const AName: string);
begin
  Self       := Default (TFieldContext);
  FFieldName := AName;
end;

{ TUTF8Encoding }

function TUTF8Encoding.GetByteCount(AChars: PChar; ACharCount: Integer): Integer;
begin
  Result := inherited;
end;

function TUTF8Encoding.GetBytes(AChars: PChar; ACharCount: Integer; ABytes: PByte; AByteCount: Integer): Integer;
begin
  Result := inherited;
end;

{ TOutputOptionHelper }

class function TOutputOptionHelper.From(const AName: string): TOutputOption;
var
  Option: TOutputOption;
begin
  for Option := Low(TOutputOption) to High(TOutputOption) do
    if GetEnumName(TypeInfo(TOutputOption), Ord(Option)) = AName then
      Exit(Option);
  raise EProtobufError.CreateFmt('The serializer has no option with this name: %s', [AName]);
end;

{ TOutputSerializer }

constructor TOutputSerializer.Create(AStream: TCustomMemoryStream);
begin
  FWriter         := TProtobufWriter.Create(AStream);
  SetLength(FFieldContexts, CInitialFieldRecursionCount);
  FFieldRecursion := - 1;
end;

destructor TOutputSerializer.Destroy;
begin
  FWriter.Free;
  inherited;
end;

function TOutputSerializer.CurrentContext: PFieldContext;
begin
  Assert(FFieldRecursion >= 0);
  Result := Addr(FFieldContexts[FFieldRecursion]);
end;

function TOutputSerializer.PreviousContext: PFieldContext;
begin
  Assert(FFieldRecursion >= 1);
  Result := Addr(FFieldContexts[FFieldRecursion - 1]);
end;

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin
  if AAttribute is FieldAttribute then
    begin
      if FFieldRecursion < 0 then
        raise EProtobufError.CreateFmt('Only fields can be marked with this attribute: %s', [AAttribute.ClassName]);
      with CurrentContext^ do
        begin
          if AAttribute is FieldTagAttribute then
            FFieldTag   := (AAttribute as FieldTagAttribute).Value
          else if AAttribute is RequiredAttribute then
            FIsRequired := True
          else if AAttribute is UnPackedAttribute then
            FIsUnPacked := True
          else if AAttribute is OneofAttribute then
            FIsOneof    := True;
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
  if (FFieldRecursion >= 0) and not CurrentContext.FIsOneof then
    BeginLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.BeginLengthPrefixedWithUnknownSize;
begin
  with CurrentContext^ do
    begin
      FBeforePos := FWriter.Skip(0);
      FWriter.Pack(TWireType.LengthPrefixed, FFieldTag);
      FStartPos  := FWriter.Skip(CLengthPrefixReservedSize);
    end;
end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin
  with CurrentContext^ do
    begin
      if not FIsArray then
        begin
          FIsArray     := True;
          FArrayLength := ALength;
        end
      else if not FIsBytes then
        raise EProtobufError.Create('Arrays of arrays are not supported in Protobuf');
    end;
end;

procedure TOutputSerializer.BeginAll;
begin
  FFieldRecursion := - 1;
end;

procedure TOutputSerializer.BeginDynamicArray(var ALength: Integer);
begin
  with CurrentContext^ do
    begin
      if not FIsArray then
        begin
          FIsArray     := True;
          FArrayLength := ALength;
        end
      else if not FIsBytes then
        raise EProtobufError.Create('Arrays of arrays are not supported in Protobuf');
    end;
end;

procedure TOutputSerializer.EndField;
begin
  Assert(FFieldRecursion >= 0);
  Dec(FFieldRecursion);
end;

procedure TOutputSerializer.EndRecord;
begin
  if (FFieldRecursion >= 0) and not CurrentContext.FIsOneof then
    EndLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.EndLengthPrefixedWithUnknownSize;
var
  WrittenCount: Integer;
begin
  with CurrentContext^ do
    begin
      WrittenCount := FWriter.Skip(0) - FStartPos;
      Assert(WrittenCount >= 0);
      if WrittenCount > 0 then
        PackLengthPrefix(WrittenCount)
      else
        FWriter.Skip(FBeforePos - FStartPos); // omit empty value from output and discard the tag that had been packed
    end;
end;

procedure TOutputSerializer.PackLengthPrefix(WrittenCount: Integer);
var
  LengthPrefix: VarInt;
  PrefixDiff  : Integer;
begin
  LengthPrefix := VarInt(WrittenCount);
  PrefixDiff   := LengthPrefix.Count - CLengthPrefixReservedSize;
  FWriter.Skip(- WrittenCount);
  if PrefixDiff <> 0 then
    FWriter.Move(WrittenCount, PrefixDiff); // move memory by a few bytes to fit the length prefix
  FWriter.Skip(- CLengthPrefixReservedSize);
  FWriter.Pack(LengthPrefix);
  FWriter.Skip(WrittenCount);
end;

procedure TOutputSerializer.EndStaticArray;
begin
  if CurrentContext.FIsPackedArray then
    EndLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.EndAll;
begin
  FWriter.Truncate;
end;

procedure TOutputSerializer.EndDynamicArray;
begin
  if CurrentContext.FIsPackedArray then
    EndLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.EnumName(const AName: string);
begin
  Assert(False); // should not be called
end;

function TOutputSerializer.GetOption(const AName: string): Variant;
begin
  case TOutputOption.From(AName) of
    TOutputOption.LimitMemoryUsage:
      Result := FLimitMemoryUsage;
  end;
end;

function TOutputSerializer.SkipEnumNames: Boolean;
begin
  Result := True;
end;

function TOutputSerializer.SkipField: Boolean;
begin
  with CurrentContext^ do
    if FIsOneof then
      Result := False
    else if FFieldTag = 0 then
      Result := True
    else if FFieldRecursion <= 0 then
      Result := False
    else
      with PreviousContext^ do
        if FIsOneof then
          begin
            Result := FOneofCase <> FOneofFieldIndex;
            Inc(FOneofFieldIndex);
          end
        else
          Result := False
end;

procedure TOutputSerializer.SetOption(const AName: string; AValue: Variant);
begin
  case TOutputOption.From(AName) of
    TOutputOption.LimitMemoryUsage:
      FLimitMemoryUsage := AValue;
  end;
end;

function TOutputSerializer.SkipAttributes: Boolean;
begin
  Result := False;
end;

procedure TOutputSerializer.DataType(AType: TRttiType);
begin
  if FFieldRecursion >= 0 then
    begin
      InitializeTypeFlags(AType);
      if CurrentContext.FIsPackedArray then
        BeginLengthPrefixedWithUnknownSize; // pack the tag prefix once for the whole array
    end
  else if AType.TypeKind <> tkRecord then
    raise EProtobufError.Create('Only records can be serialized in Protobuf');
end;

procedure TOutputSerializer.InitializeTypeFlags(AType: TRttiType);
begin
  with CurrentContext^ do
    begin
      FIsSigned := (AType.Handle = TypeInfo(SInt32)) or (AType.Handle = TypeInfo(SInt64));
      FIsFixed  :=
        (AType.Handle = TypeInfo(Fixed32)) or (AType.Handle = TypeInfo(SFixed32)) or
        (AType.Handle = TypeInfo(Fixed64)) or (AType.Handle = TypeInfo(SFixed64));
      if FIsArray then
        begin
          FIsBytes       := AType.Handle = TypeInfo(TBytes);
          FIsPackedArray := (not FIsUnPacked) and (FArrayLength > 1) and (AType.TypeKind in CPackableElementTypeKinds);
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: Int8);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.VarInt, FFieldTag);
        FWriter.Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: Int16);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.VarInt, FFieldTag);
        FWriter.Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: Int32);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      if FIsSigned then
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.VarInt, FFieldTag);
          FWriter.Pack(SignedInt(AValue));
        end
      else if FIsFixed then
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.Fixed32, FFieldTag);
          FWriter.Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.VarInt, FFieldTag);
          FWriter.Pack(VarInt(AValue));
        end;
end;

procedure TOutputSerializer.Value(var AValue: Int64);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      if FIsSigned then
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.VarInt, FFieldTag);
          FWriter.Pack(SignedInt(AValue));
        end
      else if FIsFixed then
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.Fixed64, FFieldTag);
          FWriter.Pack(FixedInt64(AValue));
        end
      else
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.VarInt, FFieldTag);
          FWriter.Pack(VarInt(AValue));
        end;
end;

procedure TOutputSerializer.Value(var AValue: UInt8);
begin
  with CurrentContext^ do
    if FIsOneof then // this is the case field of a oneof record
      with PreviousContext^ do
        begin
          Assert(FIsOneof);    // check that the containing record is marked as oneof
          FOneofCase := AValue // use the context of the oneof record to keep the case value
        end
    else if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.VarInt, FFieldTag);
        FWriter.Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt16);
begin
  with CurrentContext^ do
    if FIsOneof then // this is the case field of a oneof record
      with PreviousContext^ do
        begin
          Assert(FIsOneof);    // check that the containing record is marked as oneof
          FOneofCase := AValue // use the context of the oneof record to keep the case value
        end
    else if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.VarInt, FFieldTag);
        FWriter.Pack(VarInt(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt32);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      if FIsFixed then
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.Fixed32, FFieldTag);
          FWriter.Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.VarInt, FFieldTag);
          FWriter.Pack(VarInt(AValue));
        end;
end;

procedure TOutputSerializer.Value(var AValue: UInt64);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      if FIsFixed then
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.Fixed64, FFieldTag);
          FWriter.Pack(FixedInt64(AValue));
        end
      else
        begin
          if not FIsPackedArray then
            FWriter.Pack(TWireType.VarInt, FFieldTag);
          FWriter.Pack(VarInt(AValue));
        end;
end;

procedure TOutputSerializer.Value(var AValue: Single);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.Fixed32, FFieldTag);
        FWriter.Pack(FixedInt32(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: Double);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.Fixed64, FFieldTag);
        FWriter.Pack(FixedInt64(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: Extended);
begin
  raise EProtobufError.Create('Extended is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Comp);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.Fixed64, FFieldTag);
        FWriter.Pack(FixedInt64(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: Currency);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        if not FIsPackedArray then
          FWriter.Pack(TWireType.Fixed64, FFieldTag);
        FWriter.Pack(FixedInt64(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: ShortString);
begin
  Value(PAnsiChar(AValue), Length(AValue));
end;

procedure TOutputSerializer.Value(var AValue: AnsiString);
begin
  Value(PAnsiChar(AValue), Length(AValue));
end;

procedure TOutputSerializer.Value(var AValue: WideString);
begin
  Utf8Value(PChar(AValue), Length(AValue));
end;

procedure TOutputSerializer.Value(var AValue: UnicodeString);
begin
  Utf8Value(PChar(AValue), Length(AValue));
end;

procedure TOutputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin
  with CurrentContext^ do
    if (AByteCount <> 0) or FIsArray or FIsRequired then
      begin
        FWriter.Pack(TWireType.LengthPrefixed, CurrentContext.FFieldTag);
        FWriter.Pack(VarInt(AByteCount));
        FWriter.Write(AValue^, AByteCount);
      end;
end;

procedure TOutputSerializer.Utf8Value(AChars: PChar; ACharCount: Integer);
var
  ByteCount: Integer;
  ByteStart: PByte;
begin
  with CurrentContext^ do
    if (ACharCount <> 0) or FIsArray or FIsRequired then
      begin
        if FLimitMemoryUsage then
          begin
            FWriter.Pack(TWireType.LengthPrefixed, CurrentContext.FFieldTag);
            ByteCount := FUTF8Encoding.GetByteCount(AChars, ACharCount);
            FWriter.Pack(VarInt(ByteCount));
          end
        else
          begin
            ByteCount := FUTF8Encoding.GetMaxByteCount(ACharCount);
            BeginLengthPrefixedWithUnknownSize;
          end;
        ByteStart := FWriter.Require(ByteCount);
        ByteCount := FUTF8Encoding.GetBytes(AChars, ACharCount, ByteStart, ByteCount);
        FWriter.Skip(ByteCount);
        if not FLimitMemoryUsage then
          EndLengthPrefixedWithUnknownSize;
      end;
end;

initialization

TOutputSerializer.FUTF8Encoding := TUTF8Encoding.Create;

finalization

TOutputSerializer.FUTF8Encoding.Free;

end.
