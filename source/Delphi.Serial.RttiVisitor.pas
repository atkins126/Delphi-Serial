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

    public
      procedure Initialize(AObserver: IRttiObserver);
      procedure Visit<T>(var AValue: T); overload;
      procedure Visit(AValue, ATypeInfo: Pointer); overload;
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
end;

procedure TRttiVisitor.Visit<T>(var AValue: T);
begin
  Visit(Addr(AValue), TypeInfo(T));
end;

procedure TRttiVisitor.Visit(AValue, ATypeInfo: Pointer);
begin
  FObserver.BeginAll;
  try
    VisitType(AValue, FContext.GetType(ATypeInfo));
  finally
    FObserver.EndAll;
  end;
end;

procedure TRttiVisitor.VisitType(AInstance: Pointer; AType: TRttiType; ACount: Integer);
var
  I: Integer;
begin
  if not Assigned(AType) then
    Exit;

  FObserver.DataType(AType);
  if ACount = 0 then
    begin
      Assert(not Assigned(AInstance));
      if AType is TRttiDynamicArrayType then
        Visit(nil, AType as TRttiDynamicArrayType);
      Exit;
    end;

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
  Attribute: TCustomAttribute;
  Field    : TRttiField;
begin
  FObserver.BeginRecord;
  if not FObserver.SkipAttributes then
    for Attribute in AType.GetAttributes do
      FObserver.Attribute(Attribute);
  for Field in AType.GetFields do
    Visit(AInstance, Field);
  FObserver.EndRecord;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AField: TRttiField);
var
  Attribute: TCustomAttribute;
begin
  FObserver.BeginField(AField.Name);
  if not FObserver.SkipAttributes then
    for Attribute in AField.GetAttributes do
      FObserver.Attribute(Attribute);
  if not FObserver.SkipField then
    VisitType(PByte(AInstance) + AField.Offset, AField.FieldType);
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
      if (ACount > 1) and (AType.Handle = TypeInfo(Byte)) then
        FObserver.Value(AInstance, ACount) // visit byte array as a memory block
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
  if FObserver.SkipEnumNames then
    Visit(AInstance, AType.UnderlyingType as TRttiOrdinalType, ACount)
  else
    Visit(AInstance, AType.UnderlyingType as TRttiOrdinalType, ACount, AType.Handle);
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiSetType; ACount: Integer);
var
  I: Integer;
begin
  for I := 0 to ACount - 1 do
    FObserver.Value(PByte(AInstance) + I * AType.TypeSize, ACount);
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
  FObserver.BeginStaticArray(Count);
  VisitType(AInstance, AType.ElementType, Count);
  FObserver.EndStaticArray;
end;

procedure TRttiVisitor.Visit(AInstance: Pointer; AType: TRttiDynamicArrayType);
var
  Count : Integer;
  Length: NativeInt;
begin
  if not Assigned(AInstance) then           // handle the case of visiting an array with zero sub-arrays
    begin
      Count := - 1;                         // indicate that there is no instance of this sub-array type
      FObserver.BeginDynamicArray(Count);
      VisitType(nil, AType.ElementType, 0); // keep recursing until the innermost element type is visited
      FObserver.EndDynamicArray;
      Exit;
    end;

  Count := DynArraySize(Pointer(AInstance^));
  FObserver.BeginDynamicArray(Count);
  Assert(Count >= 0); // protect against bad input
  if Count <> DynArraySize(Pointer(AInstance^)) then
    begin
      Length := Count;
      DynArraySetLength(Pointer(AInstance^), AType.Handle, 1, @Length);
    end;
  VisitType(Pointer(AInstance^), AType.ElementType, Count);
  FObserver.EndDynamicArray;
end;

end.
