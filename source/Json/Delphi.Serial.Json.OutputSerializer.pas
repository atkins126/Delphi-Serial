unit Delphi.Serial.Json.OutputSerializer;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial,
  System.Json.Writers,
  System.Classes,
  System.Rtti;

type

  TFieldContext = record
    FFieldName: string;
    FEnumName: string;
    FIsRequired: Boolean;
    FIsRecord: Boolean;
    FIsBoolean: Boolean;
    FIsByte: Boolean;
    FIsArray: Boolean;
    FArrayLength: Integer;
    FValueStarted: Boolean;
  end;

  PFieldContext = ^TFieldContext;

  TOutputOption = (Indentation);

  TOutputOptionHelper = record helper for TOutputOption
    public
      class function From(const AName: string): TOutputOption; static;
  end;

  TJsonTextWriter = class(System.Json.Writers.TJsonTextWriter)
    public
      procedure WriteValue(AValue: Single); override; // override to adjust precision
  end;

  TOutputSerializer = class(TInterfacedObject, ISerializer)
    private const
      CInitialFieldRecursionCount = 16; // start with this number of field recursion levels

    private
      FJsonWriter    : TJsonTextWriter;
      FFieldContexts : TArray<TFieldContext>;
      FFieldRecursion: Integer;
      FFieldStarted  : Integer;

      function CurrentContext: PFieldContext; inline;
      procedure SetIndentation(AValue: Integer);
      procedure CheckStartValue;
      procedure CheckStartArray;
      procedure CheckEndArray;

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

      procedure SetStream(AStream: TStream);
      procedure SetOption(const AName: string; AValue: Variant);

    public
      constructor Create;
      destructor Destroy; override;
  end;

  EJsonError = class(ESerialError);

implementation

uses
  Delphi.Serial.Factory,
  System.Json.Types,
  System.SysUtils,
  System.TypInfo;

{ TOutputOptionHelper }

class function TOutputOptionHelper.From(const AName: string): TOutputOption;
var
  Option: TOutputOption;
begin
  for Option := Low(TOutputOption) to High(TOutputOption) do
    if GetEnumName(TypeInfo(TOutputOption), Ord(Option)) = AName then
      Exit(Option);
  raise EJsonError.CreateFmt('The serializer has no option with this name: %s', [AName]);
end;

{ TOutputSerializer }

constructor TOutputSerializer.Create;
begin
  SetLength(FFieldContexts, CInitialFieldRecursionCount);
end;

destructor TOutputSerializer.Destroy;
begin
  FJsonWriter.Free; // the underlying stream could be accessed here if we did not properly flush the writer
  inherited;
end;

function TOutputSerializer.CurrentContext: PFieldContext;
begin
  Assert(FFieldRecursion >= 0);
  Result := Addr(FFieldContexts[FFieldRecursion]);
end;

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin
  if AAttribute is FieldAttribute then
    begin
      if FFieldRecursion = 0 then
        raise EJsonError.CreateFmt('Only fields can be marked with this attribute: %s', [AAttribute.ClassName]);
      with CurrentContext^ do
        begin
          if AAttribute is NameAttribute then
            FFieldName  := (AAttribute as NameAttribute).Value
          else if AAttribute is RequiredAttribute then
            FIsRequired := True;
        end;
    end;
end;

procedure TOutputSerializer.BeginAll;
begin
  FJsonWriter.Rewind;
  FFieldRecursion := 0;
  FFieldStarted   := 0;
  CurrentContext^ := Default (TFieldContext);
end;

procedure TOutputSerializer.BeginDynamicArray(var ALength: Integer);
begin
  with CurrentContext^ do
    begin
      FIsArray     := True;
      FArrayLength := ALength;
    end;
end;

procedure TOutputSerializer.BeginField(const AName: string);
begin
  Inc(FFieldRecursion);
  if FFieldRecursion = Length(FFieldContexts) then
    SetLength(FFieldContexts, 2 * FFieldRecursion);
  CurrentContext^ := Default (TFieldContext);
end;

procedure TOutputSerializer.BeginRecord;
begin
  with CurrentContext^ do
    begin
      if FIsArray then
        begin
          CheckStartValue;
          FJsonWriter.WriteStartObject;
        end
      else
        FIsRecord := True;
    end;
end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin
  with CurrentContext^ do
    begin
      FIsArray     := True;
      FArrayLength := ALength;
    end;
end;

procedure TOutputSerializer.DataType(AType: TRttiType);
begin
  with CurrentContext^ do
    begin
      FIsBoolean := AType.Handle = TypeInfo(Boolean);
      FIsByte    := AType.Handle = TypeInfo(Byte);
      if FIsArray then
        CheckStartArray;
    end;
end;

procedure TOutputSerializer.CheckStartArray;
begin
  with CurrentContext^ do
    if (FArrayLength > 0) or FValueStarted or FIsRequired then
      begin
        CheckStartValue;
        if not FIsByte then
          FJsonWriter.WriteStartArray
        else if FArrayLength = 0 then
          FJsonWriter.WriteValue([]);
      end;
end;

procedure TOutputSerializer.EndAll;
begin
  FJsonWriter.Close;
end;

procedure TOutputSerializer.EndDynamicArray;
begin
  CheckEndArray;
end;

procedure TOutputSerializer.CheckEndArray;
begin
  with CurrentContext^ do
    if FIsByte then
      FIsByte := False // byte should be the innermost element type
    else if FValueStarted then
      FJsonWriter.WriteEndArray;
end;

procedure TOutputSerializer.EndField;
begin
  Assert(FFieldRecursion > 0);
  Dec(FFieldRecursion);
  if FFieldStarted > FFieldRecursion then
    FFieldStarted := FFieldRecursion;
end;

procedure TOutputSerializer.EndRecord;
begin
  if CurrentContext.FValueStarted then
    FJsonWriter.WriteEndObject;
end;

procedure TOutputSerializer.EndStaticArray;
begin
  CheckEndArray;
end;

procedure TOutputSerializer.CheckStartValue;
begin
  while FFieldStarted <= FFieldRecursion do
    begin
      with FFieldContexts[FFieldStarted] do
        if not FValueStarted then
          begin
            FValueStarted := True;
            if not FFieldName.IsEmpty then
              FJsonWriter.WritePropertyName(FFieldName);
            if FIsRecord then
              FJsonWriter.WriteStartObject;
          end;
      Inc(FFieldStarted);
    end;
end;

procedure TOutputSerializer.EnumName(const AName: string);
begin
  CurrentContext.FEnumName := AName;
end;

procedure TOutputSerializer.SetOption(const AName: string; AValue: Variant);
begin
  case TOutputOption.From(AName) of
    TOutputOption.Indentation:
      SetIndentation(AValue);
  end;
end;

procedure TOutputSerializer.SetIndentation(AValue: Integer);
begin
  if AValue >= 0 then
    begin
      FJsonWriter.Formatting  := TJsonFormatting.Indented;
      FJsonWriter.Indentation := AValue;
    end
  else
    FJsonWriter.Formatting := TJsonFormatting.None;
end;

procedure TOutputSerializer.SetStream(AStream: TStream);
begin
  FreeAndNil(FJsonWriter);
  FJsonWriter := TJsonTextWriter.Create(AStream);
end;

function TOutputSerializer.SkipAttributes: Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipEnumNames: Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipField: Boolean;
begin
  Result := CurrentContext.FFieldName.IsEmpty;
end;

procedure TOutputSerializer.Value(var AValue: Int8);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Int16);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Int32);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Int64);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt8);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        if FEnumName.IsEmpty then
          FJsonWriter.WriteValue(AValue)
        else if FIsBoolean then
          FJsonWriter.WriteValue(FEnumName.ToBoolean)
        else
          FJsonWriter.WriteValue(FEnumName);
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt16);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        if FEnumName.IsEmpty then
          FJsonWriter.WriteValue(AValue)
        else
          FJsonWriter.WriteValue(FEnumName);
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt32);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        if FEnumName.IsEmpty then
          FJsonWriter.WriteValue(AValue)
        else
          FJsonWriter.WriteValue(FEnumName);
      end;
end;

procedure TOutputSerializer.Value(var AValue: UInt64);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: ShortString);
begin
  with CurrentContext^ do
    if (AValue = '') and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(string(AValue));
end;

procedure TOutputSerializer.Value(var AValue: AnsiString);
begin
  with CurrentContext^ do
    if (AValue <> '') or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(string(AValue));
      end;
end;

procedure TOutputSerializer.Value(var AValue: WideString);
begin
  with CurrentContext^ do
    if (AValue <> '') or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: UnicodeString);
begin
  with CurrentContext^ do
    if (AValue <> '') or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(AValue: Pointer; AByteCount: Integer);
var
  Bytes: TBytes;
begin
  with CurrentContext^ do
    if (AByteCount <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        SetLength(Bytes, AByteCount);
        Move(AValue^, Bytes[0], AByteCount);
        FJsonWriter.WriteValue(Bytes);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Currency);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Single);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Double);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Extended);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

procedure TOutputSerializer.Value(var AValue: Comp);
begin
  with CurrentContext^ do
    if (AValue <> 0) or FIsArray or FIsRequired then
      begin
        CheckStartValue;
        FJsonWriter.WriteValue(AValue);
      end;
end;

{ TJsonTextWriter }

procedure TJsonTextWriter.WriteValue(AValue: Single);
var
  Str: string;
begin
  InternalWriteValue(TJsonToken.Float);

  if AValue.IsPositiveInfinity then
    Str := JsonPositiveInfinity
  else if AValue.IsNegativeInfinity then
    Str := JsonNegativeInfinity
  else if AValue.IsNan then
    Str := JsonNaN
  else
    Str := FloatToStrF(AValue, ffGeneral, 7, 0, FormatSettings);

  if (FloatFormatHandling = TJsonFloatFormatHandling.Symbol) or not (AValue.IsInfinity or AValue.IsNan) then
    // nothing
  else if FloatFormatHandling = TJsonFloatFormatHandling.DefaultValue then
    Str := '0.0'
  else
    Str := QuoteChar + Str + QuoteChar;
  Writer.Write(Str);
end;

initialization

TFactory.Instance.RegisterSerializer<TOutputSerializer>('Json_Output');

end.
