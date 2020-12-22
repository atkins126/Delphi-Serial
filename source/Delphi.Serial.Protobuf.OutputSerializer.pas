unit Delphi.Serial.Protobuf.OutputSerializer;

interface

uses
  Delphi.Serial.Protobuf.Serializer,
  Delphi.Serial.RttiObserver,
  System.Classes,
  Delphi.Serial.Protobuf,
  System.Generics.Collections;

type

  TFieldContext = class
    FFieldName: string;
    FTypeName: string;
    FTypeKind: TTypeKind;
    FStartPos: Int64;
    FFieldTag: FieldTag;
    FIsArray: Boolean;
    constructor Create(const AName: string);
    function GetTag(AWireType: TWireType): UInt32; inline;
  end;

  TOutputSerializer = class(TSerializer, IRttiObserver)
    private
      FFieldContexts: TStack<TFieldContext>;

      procedure BeginLengthPrefixedWithUnknownSize;
      procedure EndLengthPrefixedWithUnknownSize;

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

      function SkipEnumNames: Boolean;
      function SkipAttributes: Boolean;
      function SkipCaseBranch(ABranch: Integer): Boolean;
      function ByteArrayAsAWhole: Boolean;

      procedure TypeKind(AKind: TTypeKind);
      procedure TypeName(const AName: string);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

    const
      CLengthPrefixReservedSize = 1; // space reserved for a single-byte VarInt
      CPackedArrayTypeKinds     = [tkInteger, tkFloat, tkEnumeration, tkInt64];

    public
      constructor Create(Stream: TCustomMemoryStream);
      destructor Destroy; override;
  end;

implementation

uses
  Delphi.Serial.ProtobufUtils,
  System.SysUtils;

{ TFieldContext }

constructor TFieldContext.Create(const AName: string);
begin
  FFieldName := AName;
end;

function TFieldContext.GetTag(AWireType: TWireType): UInt32;
begin
  Result := AWireType.CombineWith(FFieldTag);
end;

{ TOutputSerializer }

constructor TOutputSerializer.Create(Stream: TCustomMemoryStream);
begin
  inherited;
  FFieldContexts := TStack<TFieldContext>.Create;
end;

destructor TOutputSerializer.Destroy;
var
  Context: TFieldContext;
begin
  for Context in FFieldContexts do
    Context.Free; // this should not happen if the serializer was used correctly
  FFieldContexts.Free;
  inherited;
end;

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin
  if AAttribute is ProtobufAttribute then
    FFieldContexts.Peek.FFieldTag := (AAttribute as ProtobufAttribute).FieldTag;
end;

procedure TOutputSerializer.BeginField(const AName: string);
begin
  FFieldContexts.Push(TFieldContext.Create(AName));
end;

procedure TOutputSerializer.BeginRecord;
begin
  BeginLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.BeginLengthPrefixedWithUnknownSize;
begin
  with FFieldContexts.Peek do
    begin
      Pack(VarInt(GetTag(TWireType.LengthPrefixed)));
      FStartPos := Skip(CLengthPrefixReservedSize);
    end;
end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin
  raise EProtobufError.Create('Static arrays are not supported in Protobuf');
end;

procedure TOutputSerializer.BeginDynamicArray(var ALength: Integer);
begin
  FFieldContexts.Peek.FIsArray := True;
end;

procedure TOutputSerializer.EndField;
begin
  FFieldContexts.Pop.Free;
end;

procedure TOutputSerializer.EndRecord;
begin
  EndLengthPrefixedWithUnknownSize;
end;

procedure TOutputSerializer.EndLengthPrefixedWithUnknownSize;
var
  WrittenCount: Integer;
  LengthPrefix: VarInt;
  PrefixDiff  : Integer;
begin
  WrittenCount := Skip(0) - FFieldContexts.Peek.FStartPos;
  LengthPrefix := VarInt(WrittenCount);
  PrefixDiff   := LengthPrefix.Count - CLengthPrefixReservedSize;
  Skip(- WrittenCount);
  if PrefixDiff <> 0 then
    Move(WrittenCount, PrefixDiff); // move memory by a few bytes to allow space for the length prefix
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
  with FFieldContexts.Peek do
    begin
      if FIsArray and (FTypeKind in CPackedArrayTypeKinds) then
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

function TOutputSerializer.SkipAttributes: Boolean;
begin
  Result := False;
end;

function TOutputSerializer.ByteArrayAsAWhole: Boolean;
begin
  Result := True;
end;

procedure TOutputSerializer.TypeKind(AKind: TTypeKind);
begin
  with FFieldContexts.Peek do
    begin
      FTypeKind := AKind;
      if FIsArray and (FTypeKind in CPackedArrayTypeKinds) then
        BeginLengthPrefixedWithUnknownSize; // pack the tag prefix once for the whole array
    end;
end;

procedure TOutputSerializer.TypeName(const AName: string);
begin
  FFieldContexts.Peek.FTypeName := AName.ToUpper; // uppercase so we can easily test for equality
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
    Exit;
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'SINT32' then
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType.VarInt)));
          Pack(SignedInt(AValue));
        end
      else if FTypeName = 'SFIXED32' then
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType._32bit)));
          Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType.VarInt)));
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: Int64);
begin
  if AValue = 0 then
    Exit;
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'SINT64' then
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType.VarInt)));
          Pack(SignedInt(AValue));
        end
      else if FTypeName = 'SFIXED64' then
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType._64bit)));
          Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType.VarInt)));
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: UInt8);
begin
  if FFieldContexts.Peek.FTypeKind <> tkEnumeration then
    raise EProtobufError.Create('UInt8 is not supported in Protobuf');
  if AValue = 0 then
    Exit;
  with FFieldContexts.Peek do
    if not FIsArray then
      Pack(VarInt(GetTag(TWireType.VarInt)));
  Pack(VarInt(AValue));
end;

procedure TOutputSerializer.Value(var AValue: UInt16);
begin
  if FFieldContexts.Peek.FTypeKind <> tkEnumeration then
    raise EProtobufError.Create('UInt16 is not supported in Protobuf');
  if AValue = 0 then
    Exit;
  with FFieldContexts.Peek do
    if not FIsArray then
      Pack(VarInt(GetTag(TWireType.VarInt)));
  Pack(VarInt(AValue));
end;

procedure TOutputSerializer.Value(var AValue: UInt32);
begin
  if AValue = 0 then
    Exit;
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'FIXED32' then
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType._32bit)));
          Pack(FixedInt32(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType.VarInt)));
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: UInt64);
begin
  if AValue = 0 then
    Exit;
  with FFieldContexts.Peek do
    begin
      if FTypeName = 'FIXED64' then
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType._64bit)));
          Pack(FixedInt64(AValue));
        end
      else
        begin
          if not FIsArray then
            Pack(VarInt(GetTag(TWireType.VarInt)));
          Pack(VarInt(AValue));
        end;
    end;
end;

procedure TOutputSerializer.Value(var AValue: Single);
begin
  if AValue = 0 then
    Exit;
  with FFieldContexts.Peek do
    if not FIsArray then
      Pack(VarInt(GetTag(TWireType._32bit)));
  Pack(FixedInt32(AValue));
end;

procedure TOutputSerializer.Value(var AValue: Double);
begin
  if AValue = 0 then
    Exit;
  with FFieldContexts.Peek do
    if not FIsArray then
      Pack(VarInt(GetTag(TWireType._64bit)));
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
  Bytes: TBytes;
begin
  if AValue.IsEmpty then
    Exit;
  with FFieldContexts.Peek do
    Pack(VarInt(GetTag(TWireType.LengthPrefixed)));
  Bytes := TEncoding.UTF8.GetBytes(AValue);
  Pack(VarInt(Length(Bytes)));
  Write(Bytes[0], Length(Bytes));
end;

procedure TOutputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin
  if AByteCount = 0 then
    Exit;
  with FFieldContexts.Peek do
    Pack(VarInt(GetTag(TWireType.LengthPrefixed)));
  Pack(VarInt(AByteCount));
  Write(AValue^, AByteCount);
end;

end.
