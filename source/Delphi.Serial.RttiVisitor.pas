unit Delphi.Serial.RttiVisitor;

interface

uses
  Delphi.Serial.RttiObserver,
  System.Rtti;

type

  TRttiVisitor = record
    private
      FObserver: IRttiObserver;
      FContext : TRttiContext;
      FByteType: TRttiType;

      procedure VisitType(AInstance: Pointer; AType: TRttiType; ACount: Integer = 1);
      procedure Visit(AInstance: Pointer; AType: TRttiRecordType); overload;
      procedure Visit(AInstance: Pointer; AField: TRttiField); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiStringType; ACount: Integer); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiOrdinalType; ACount: Integer); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiFloatType; ACount: Integer); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiInt64Type; ACount: Integer); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiEnumerationType; ACount: Integer); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiSetType; ACount: Integer); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiArrayType); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiDynamicArrayType); overload;
      procedure Visit(AInstance: Pointer; AType: TRttiOrdinalType; ACount: Integer; AEnumTypeInfo: Pointer); overload;

      class function GetEnumName(AType: TRttiOrdinalType; AEnumTypeInfo: Pointer; Value: Integer): string; static;
      class function GetCaseOffset(AType: TRttiRecordType): Integer; static;

    public
      procedure Initialize(AObserver: IRttiObserver);
      procedure Visit<T>(var AValue: T); overload;
  end;

implementation

uses
  System.TypInfo;

{$POINTERMATH ON}

{ TRttiVisitor }

procedure TRttiVisitor.Initialize(AObserver: IRttiObserver);
begin
  FObserver := AObserver;
  FContext  := TRttiContext.Create;
  FByteType := FContext.GetType(TypeInfo(Byte));
end;

procedure TRttiVisitor.Visit<T>(var AValue: T);
begin
  VisitType(Addr(AValue), FContext.GetType(TypeInfo(T)));
end;

procedure TRttiVisitor.VisitType(AInstance: Pointer; AType: TRttiType; ACount: Integer);
var
  I: Integer;
begin
  if not Assigned(AType) then
    Exit;

  FObserver.TypeName(AType.Name);
  FObserver.TypeKind(AType.TypeKind);

  if AType is TRttiStringType then
    Visit(AInstance, AType as TRttiStringType, ACount)
  else if AType is TRttiInt64Type then
    Visit(AInstance, AType as TRttiInt64Type, ACount)
  else if AType is TRttiFloatType then
    Visit(AInstance, AType as TRttiFloatType, ACount)
  else if AType is TRttiEnumerationType then
    Visit(AInstance, AType as TRttiEnumerationType, ACount)
  else if AType is TRttiSetType then
    Visit(AInstance, AType as TRttiSetType, ACount)
  else if AType is TRttiOrdinalType then
    Visit(AInstance, AType as TRttiOrdinalType, ACount)
  else if AType is TRttiArrayType then
    for I := 0 to ACount - 1 do
      Visit(PByte(AInstance) + I * AType.TypeSize, AType as TRttiArrayType)
  else if AType is TRttiDynamicArrayType then
    for I := 0 to ACount - 1 do
      Visit(PByte(AInstance) + I * AType.TypeSize, AType as TRttiDynamicArrayType)
  else if AType is TRttiRecordType then
    for I := 0 to ACount - 1 do
      Visit(PByte(AInstance) + I * AType.TypeSize, AType as TRttiRecordType);
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiRecordType);
var
  Attribute : TCustomAttribute;
  Field     : TRttiField;
  CaseOffset: Integer;
  CaseBranch: Integer;
  SkipBranch: Boolean;
begin
  FObserver.BeginRecord(AType.Name);
  if not FObserver.SkipRecordAttributes then
    for Attribute in AType.GetAttributes do
      FObserver.Attribute(Attribute);

  CaseOffset := GetCaseOffset(AType);
  CaseBranch := 0;
  SkipBranch := False;
  for Field in AType.GetFields do
    begin
      if Field.Offset = CaseOffset then
        begin
          SkipBranch := FObserver.SkipBranch(CaseBranch);
          Inc(CaseBranch);
        end;
      if not SkipBranch then
        Visit(AInstance, Field);
    end;
  FObserver.EndRecord;
end;

class function TRttiVisitor.GetCaseOffset(AType: TRttiRecordType): Integer;
var
  Field     : TRttiField;
  LastOffset: Integer;
begin
  Result     := - 1;
  LastOffset := - 1;
  for Field in AType.GetFields do
    begin
      if Field.Offset <= LastOffset then
        Exit(Field.Offset);
      LastOffset := Field.Offset;
    end;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AField: TRttiField);
var
  Attribute: TCustomAttribute;
begin
  FObserver.BeginField(AField.Name);
  if not FObserver.SkipFieldAttributes then
    for Attribute in AField.GetAttributes do
      FObserver.Attribute(Attribute);
  VisitType(PByte(AInstance) + AField.Offset, AField.FieldType, 1);
  FObserver.EndField;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiStringType; ACount: Integer);
var
  I: Integer;
begin
  case AType.StringKind of
    skShortString:
      for I := 0 to ACount - 1 do
        FObserver.Value(PShortString(AInstance)[I]);
    skAnsiString:
      for I := 0 to ACount - 1 do
        FObserver.Value(PAnsiString(AInstance)[I]);
    skWideString:
      for I := 0 to ACount - 1 do
        FObserver.Value(PWideString(AInstance)[I]);
    skUnicodeString:
      for I := 0 to ACount - 1 do
        FObserver.Value(PUnicodeString(AInstance)[I]);
  end;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiFloatType; ACount: Integer);
var
  I: Integer;
begin
  case AType.FloatType of
    ftSingle:
      for I := 0 to ACount - 1 do
        FObserver.Value(PSingle(AInstance)[I]);
    ftDouble:
      for I := 0 to ACount - 1 do
        FObserver.Value(PDouble(AInstance)[I]);
    ftExtended:
      for I := 0 to ACount - 1 do
        FObserver.Value(PExtended(AInstance)[I]);
    ftComp:
      for I := 0 to ACount - 1 do
        FObserver.Value(PComp(AInstance)[I]);
    ftCurr:
      for I := 0 to ACount - 1 do
        FObserver.Value(PCurrency(AInstance)[I]);
  end;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiInt64Type; ACount: Integer);
var
  I: Integer;
begin
  if AType.MinValue < 0 then
    for I := 0 to ACount - 1 do
      FObserver.Value(PInt64(AInstance)[I])
  else
    for I := 0 to ACount - 1 do
      FObserver.Value(PUInt64(AInstance)[I]);
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiOrdinalType; ACount: Integer);
var
  I: Integer;
begin
  case AType.OrdType of
    otSByte:
      for I := 0 to ACount - 1 do
        FObserver.Value(PShortint(AInstance)[I]);
    otUByte:
      if (ACount > 1) and FObserver.ByteArrayAsAWhole then
        FObserver.Value(AInstance, ACount)
      else
        for I := 0 to ACount - 1 do
          FObserver.Value(PByte(AInstance)[I]);
    otSWord:
      for I := 0 to ACount - 1 do
        FObserver.Value(PSmallint(AInstance)[I]);
    otUWord:
      for I := 0 to ACount - 1 do
        FObserver.Value(PWord(AInstance)[I]);
    otSLong:
      for I := 0 to ACount - 1 do
        FObserver.Value(PInteger(AInstance)[I]);
    otULong:
      for I := 0 to ACount - 1 do
        FObserver.Value(PCardinal(AInstance)[I]);
  end;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiEnumerationType; ACount: Integer);
begin
  Assert(AType.UnderlyingType is TRttiOrdinalType);
  if not FObserver.SkipEnumNames then
    Visit(AInstance, AType.UnderlyingType as TRttiOrdinalType, ACount, AType.Handle);
  Visit(AInstance, AType.UnderlyingType as TRttiOrdinalType, ACount);
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiSetType; ACount: Integer);
var
  I: Integer;
begin
  for I := 0 to ACount - 1 do
    begin
      FObserver.BeginFixedArray(AType.TypeSize);
      VisitType(PByte(AInstance) + I * AType.TypeSize, FByteType, AType.TypeSize);
      FObserver.EndFixedArray;
    end;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiOrdinalType; ACount: Integer; AEnumTypeInfo: Pointer);
var
  I: Integer;
begin
  case AType.OrdType of
    otSByte, otUByte:
      for I := 0 to ACount - 1 do
        FObserver.EnumName(GetEnumName(AType, AEnumTypeInfo, PByte(AInstance)[I]));
    otSWord, otUWord:
      for I := 0 to ACount - 1 do
        FObserver.EnumName(GetEnumName(AType, AEnumTypeInfo, PWord(AInstance)[I]));
    otSLong, otULong:
      for I := 0 to ACount - 1 do
        FObserver.EnumName(GetEnumName(AType, AEnumTypeInfo, PInteger(AInstance)[I]));
  end;
end;

class function TRttiVisitor.GetEnumName(AType: TRttiOrdinalType; AEnumTypeInfo: Pointer; Value: Integer): string;
const
  CUnknownName = '[Unknown]';
begin
  if (Value >= AType.MinValue) and (Value <= AType.MaxValue) then
    Result := System.TypInfo.GetEnumName(AEnumTypeInfo, Value)
  else
    Result := CUnknownName;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiArrayType);
var
  Count: Integer;
begin
  Count := AType.TotalElementCount;
  FObserver.BeginFixedArray(Count);
  VisitType(AInstance, AType.ElementType, Count);
  FObserver.EndFixedArray;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiDynamicArrayType);
var
  Count : Integer;
  Length: NativeInt;
begin
  Count := DynArraySize(Pointer(AInstance^));
  FObserver.BeginVariableArray(Count);
  if Count <> DynArraySize(Pointer(AInstance^)) then
    begin
      Length := Count;
      DynArraySetLength(Pointer(AInstance^), AType.Handle, 1, @Length);
    end;
  VisitType(Pointer(AInstance^), AType.ElementType, Count);
  FObserver.EndVariableArray;
end;

end.
