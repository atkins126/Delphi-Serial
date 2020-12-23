unit Delphi.Serial.Protobuf.OutputSerializer;

interface

uses
  Delphi.Serial.Protobuf.Serializer,
  Delphi.Serial.RttiObserver,
  System.Classes,
  System.SysUtils,
  Delphi.Serial.Protobuf,
  System.Generics.Collections;

type

  TFieldContext = class
    FFieldName: string;
    FTypeName: string;
    FTypeKind: TTypeKind;
    FBeforePos: Int64;
    FStartPos: Int64;
    FFieldTag: FieldTag;
    FHasTag: Boolean;
    FIsArray: Boolean;
    FIsPacked: Boolean;
    constructor Create(const AName: string);
  end;

  TUTF8Encoding = class(System.SysUtils.TUTF8Encoding)
    protected
      function GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer; override;
  end;

  TOutputSerializer = class(TSerializer, IRttiObserver)
    private
      FFieldContexts: TStack<TFieldContext>;
      FUTF8Encoding : TUTF8Encoding;

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

    const
      CLengthPrefixReservedSize    = 2; // space reserved for a word-sized VarInt
      CPackedArrayElementTypeKinds = [tkInteger, tkFloat, tkEnumeration, tkInt64];

    public
      constructor Create(Stream: TCustomMemoryStream);
      destructor Destroy; override;
  end;

implementation

uses
  Delphi.Serial.ProtobufUtils;

{ TFieldContext }

constructor TFieldContext.Create(const AName: string);
begin
  FFieldName := AName;
end;

{ TUTF8Encoding }

function TUTF8Encoding.GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := inherited;
end;

{ TOutputSerializer }

constructor TOutputSerializer.Create(Stream: TCustomMemoryStream);
begin
  inherited;
  FFieldContexts := TObjectStack<TFieldContext>.Create;
  FUTF8Encoding  := TUTF8Encoding.Create;
end;

destructor TOutputSerializer.Destroy;
begin
  FFieldContexts.Free;
  FUTF8Encoding.Free;
  inherited;
end;

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin
  if AAttribute is ProtobufAttribute then
    begin
      if FFieldContexts.Count = 0 then
        raise EProtobufError.Create('Only fields can be marked with a Protobuf tag');
      with FFieldContexts.Peek do
        begin
          FFieldTag := (AAttribute as ProtobufAttribute).FieldTag;
          FHasTag   := True;
        end;
    end;
end;

procedure TOutputSerializer.BeginField(const AName: string);
begin
  FFieldContexts.Push(TFieldContext.Create(AName));
end;

procedure TOutputSerializer.BeginRecord;
begin
  if FFieldContexts.Count > 0 then
    BeginLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.BeginLengthPrefixedWithUnknownSize;
begin
  Assert(FFieldContexts.Count > 0);
  with FFieldContexts.Peek do
    begin
      FBeforePos := Skip(0);
      Pack(TWireType.LengthPrefixed, FFieldTag);
      FStartPos  := Skip(CLengthPrefixReservedSize);
    end;
end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('Static arrays are not supported in Protobuf');
end;

procedure TOutputSerializer.BeginDynamicArray(var ALength: Integer);
begin
  Assert(FFieldContexts.Count > 0);
  with FFieldContexts.Peek do
    begin
      if FIsArray then
        raise EProtobufError.Create('Arrays of arrays are not supported in Protobuf');
      FIsArray := True;
    end;
end;

procedure TOutputSerializer.EndField;
begin
  Assert(FFieldContexts.Count > 0);
  FFieldContexts.Pop;
end;

procedure TOutputSerializer.EndRecord;
begin
  if FFieldContexts.Count > 0 then
    EndLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.EndLengthPrefixedWithUnknownSize;
var
  WrittenCount: Integer;
begin
  Assert(FFieldContexts.Count > 0);
  with FFieldContexts.Peek do
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
  Assert(FFieldContexts.Count > 0);
  with FFieldContexts.Peek do
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
  Assert(FFieldContexts.Count > 0);
  Result := not FFieldContexts.Peek.FHasTag;
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
  if FFieldContexts.Count > 0 then
    with FFieldContexts.Peek do
      begin
        FTypeName := AName.ToUpper; // uppercase so we can easily test for equality
        FTypeKind := AKind;
        if FIsArray then            // we are dealing with the array element type
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
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('Int8 is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Int16);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('Int16 is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Int32);
begin
  Assert(FFieldContexts.Count > 0);
  if AValue = 0 then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'SINT32' then
        begin
          if not FIsArray then
            Pack(TWireType.VarInt, FFieldTag);
          Pack(SignedInt(AValue));
        end
      else if FTypeName = 'SFIXED32' then
        begin
          if not FIsArray then
            Pack(TWireType._32bit, FFieldTag);
          Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(TWireType.VarInt, FFieldTag);
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: Int64);
begin
  Assert(FFieldContexts.Count > 0);
  if AValue = 0 then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'SINT64' then
        begin
          if not FIsArray then
            Pack(TWireType.VarInt, FFieldTag);
          Pack(SignedInt(AValue));
        end
      else if FTypeName = 'SFIXED64' then
        begin
          if not FIsArray then
            Pack(TWireType._64bit, FFieldTag);
          Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(TWireType.VarInt, FFieldTag);
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: UInt8);
begin
  Assert(FFieldContexts.Count > 0);
  with FFieldContexts.Peek do
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
  Assert(FFieldContexts.Count > 0);
  with FFieldContexts.Peek do
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
  Assert(FFieldContexts.Count > 0);
  if AValue = 0 then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'FIXED32' then
        begin
          if not FIsArray then
            Pack(TWireType._32bit, FFieldTag);
          Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(TWireType.VarInt, FFieldTag);
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: UInt64);
begin
  Assert(FFieldContexts.Count > 0);
  if AValue = 0 then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'FIXED64' then
        begin
          if not FIsArray then
            Pack(TWireType._64bit, FFieldTag);
          Pack(FixedInt64(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(TWireType.VarInt, FFieldTag);
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: Single);
begin
  Assert(FFieldContexts.Count > 0);
  if AValue = 0 then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    if not FIsArray then
      Pack(TWireType._32bit, FFieldTag);
  Pack(FixedInt32(AValue));
end;

procedure TOutputSerializer.Value(var AValue: Double);
begin
  Assert(FFieldContexts.Count > 0);
  if AValue = 0 then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    if not FIsArray then
      Pack(TWireType._64bit, FFieldTag);
  Pack(FixedInt64(AValue));
end;

procedure TOutputSerializer.Value(var AValue: Extended);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('Extended is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Comp);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('Comp is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: Currency);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('Currency is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: ShortString);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('ShortString is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: AnsiString);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('AnsiString is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: WideString);
begin
  Assert(FFieldContexts.Count > 0);
  raise EProtobufError.Create('WideString is not supported in Protobuf');
end;

procedure TOutputSerializer.Value(var AValue: UnicodeString);
var
  Count: Integer;
  Start: PByte;
begin
  Assert(FFieldContexts.Count > 0);
  if AValue.IsEmpty then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    Pack(TWireType.LengthPrefixed, FFieldTag);
  Count := FUTF8Encoding.GetByteCount(AValue);
  Pack(VarInt(Count));
  Start := Require(Count);
  Count := FUTF8Encoding.GetBytes(PChar(AValue), AValue.Length, Start, Count);
  Skip(Count);
end;

procedure TOutputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin
  Assert(FFieldContexts.Count > 0);
  if AByteCount = 0 then
    Exit; // omit empty value from output
  with FFieldContexts.Peek do
    Pack(TWireType.LengthPrefixed, FFieldTag);
  Pack(VarInt(AByteCount));
  Write(AValue^, AByteCount);
end;

end.
