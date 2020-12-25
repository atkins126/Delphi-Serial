unit Delphi.Serial.Json.OutputSerializer;

interface

uses
  Delphi.Serial.RttiObserver,
  System.Json.Writers,
  System.Classes,
  System.Rtti;

type

  TFieldContext = record
    FFieldName: string;
    FIsRequired: Boolean;
    FIsRecord: Boolean;
    FIsArray: Boolean;
    FValueStarted: Boolean;
  end;

  PFieldContext = ^TFieldContext;

  TOutputSerializer = class(TInterfacedObject, IRttiObserver)
    private const
      CInitialFieldRecursionCount = 16; // start with this number of field recursion levels

    private
      FJsonWriter    : TJsonTextWriter;
      FFieldContexts : TArray<TFieldContext>;
      FFieldRecursion: Integer;
      FLastStarted   : Integer;

      function CurrentContext: PFieldContext; inline;
      procedure CheckStartValue;

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
      function SkipCaseBranch(ABranch: Integer): Boolean;

      procedure DataType(AType: TRttiType);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

    public
      constructor Create(AStream: TStream; AIndentation: Integer = - 1);
      destructor Destroy; override;
  end;

implementation

uses
  Delphi.Serial,
  Delphi.Serial.Json,
  System.Json.Types,
  System.SysUtils;

{ TOutputSerializer }

constructor TOutputSerializer.Create(AStream: TStream; AIndentation: Integer);
begin
  FJsonWriter := TJsonTextWriter.Create(AStream);
  if AIndentation >= 0 then
    begin
      FJsonWriter.Formatting  := TJsonFormatting.Indented;
      FJsonWriter.Indentation := AIndentation;
    end;
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
          if AAttribute is FieldNameAttribute then
            FFieldName  := (AAttribute as FieldNameAttribute).Value
          else if AAttribute is RequiredAttribute then
            FIsRequired := True;
        end;
    end;
end;

procedure TOutputSerializer.BeginAll;
begin
  FJsonWriter.Rewind;
end;

procedure TOutputSerializer.BeginDynamicArray(var ALength: Integer);
begin
  CurrentContext.FIsArray := True;
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
  CurrentContext.FIsRecord := True;
end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin
  CurrentContext.FIsArray := True;
end;

procedure TOutputSerializer.DataType(AType: TRttiType);
begin
  // ignore
end;

procedure TOutputSerializer.EndAll;
begin
  FJsonWriter.Flush;
end;

procedure TOutputSerializer.EndDynamicArray;
begin
  with CurrentContext^ do
    if FIsArray and FValueStarted then
      FJsonWriter.WriteEndArray;
end;

procedure TOutputSerializer.EndField;
begin
  Assert(FFieldRecursion > 0);
  Dec(FFieldRecursion);
  FLastStarted := FFieldRecursion;
end;

procedure TOutputSerializer.EndRecord;
begin
  with CurrentContext^ do
    if FIsRecord and FValueStarted then
      FJsonWriter.WriteEndObject;
end;

procedure TOutputSerializer.EndStaticArray;
begin
  with CurrentContext^ do
    if FIsArray and FValueStarted then
      FJsonWriter.WriteEndArray;
end;

procedure TOutputSerializer.CheckStartValue;
begin
  while FLastStarted <= FFieldRecursion do
    begin
      with FFieldContexts[FLastStarted] do
        if not FValueStarted then
          begin
            FValueStarted := True;
            if not FFieldName.IsEmpty then
              FJsonWriter.WritePropertyName(FFieldName);
            if FIsArray then
              FJsonWriter.WriteStartArray;
            if FIsRecord then
              FJsonWriter.WriteStartObject
          end;
      Inc(FLastStarted);
    end;
end;

procedure TOutputSerializer.EnumName(const AName: string);
begin
  CheckStartValue;
  FJsonWriter.WriteValue(AName);
end;

function TOutputSerializer.SkipAttributes: Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipCaseBranch(ABranch: Integer): Boolean;
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

procedure TOutputSerializer.Value(var AValue: Int64);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: UInt8);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: UInt16);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: Int8);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: Int16);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: Int32);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: UInt32);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
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
    if (AValue = '') and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(string(AValue));
end;

procedure TOutputSerializer.Value(var AValue: WideString);
begin
  with CurrentContext^ do
    if (AValue = '') and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: UnicodeString);
begin
  with CurrentContext^ do
    if (AValue = '') and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(AValue: Pointer; AByteCount: Integer);
var
  Bytes: TBytes;
begin
  with CurrentContext^ do
    if (AByteCount = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  SetLength(Bytes, AByteCount);
  Move(AValue^, Bytes[0], AByteCount);
  FJsonWriter.WriteValue(Bytes);
end;

procedure TOutputSerializer.Value(var AValue: Currency);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: UInt64);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: Single);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: Double);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: Extended);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

procedure TOutputSerializer.Value(var AValue: Comp);
begin
  with CurrentContext^ do
    if (AValue = 0) and (not FIsArray) and not FIsRequired then
      Exit;
  CheckStartValue;
  FJsonWriter.WriteValue(AValue);
end;

end.
