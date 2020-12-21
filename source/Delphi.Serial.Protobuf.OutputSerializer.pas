unit Delphi.Serial.Protobuf.OutputSerializer;

interface

uses
  Delphi.Serial.Protobuf.Serializer,
  Delphi.Serial.RttiObserver,
  System.Classes,
  Delphi.Serial.Protobuf,
  System.Generics.Collections;

type

  TRecordContext = class
    FTypeName: string;
    FCurrentFieldTag: FieldTag;
    FSavedStreamPos: Int64;
  end;

  TOutputSerializer = class(TSerializer, IRttiObserver)
    private
      FRecordContexts: TStack<TRecordContext>;

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

    public
      constructor Create(Stream: TCustomMemoryStream);
      destructor Destroy; override;
  end;

implementation

uses
  Delphi.Serial.Utils;

{ TOutputSerializer }

constructor TOutputSerializer.Create(Stream: TCustomMemoryStream);
begin
  inherited;
  FRecordContexts := TObjectStack<TRecordContext>.Create;
end;

destructor TOutputSerializer.Destroy;
begin
  FRecordContexts.Free;
  inherited;
end;

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin
  if AAttribute is ProtobufAttribute then
    FRecordContexts.Peek.FCurrentFieldTag := (AAttribute as ProtobufAttribute).FieldTag;
end;

procedure TOutputSerializer.BeginField(const AName: string);
begin

end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin

end;

procedure TOutputSerializer.BeginRecord(const AName: string);
var
  Context: TRecordContext;
begin
  Context                 := TRecordContext.Create;
  Context.FTypeName       := AName;
  Context.FSavedStreamPos := Skip(2); // reserve space for 2 single-byte VarInts (most likely case)
  FRecordContexts.Push(Context);
end;

procedure TOutputSerializer.BeginDynamicArray(var ALength: Integer);
begin

end;

function TOutputSerializer.ByteArrayAsAWhole: Boolean;
begin
  Result := True;
end;

procedure TOutputSerializer.EndField;
begin

end;

procedure TOutputSerializer.EndStaticArray;
begin

end;

procedure TOutputSerializer.EndRecord;
var
  Context     : TRecordContext;
  TagPrefix   : VarInt;
  LengthPrefix: VarInt;
  StreamPos   : Int64;
  Difference  : Integer;
begin
  Context      := FRecordContexts.Pop;
  StreamPos    := Skip(0);
  Skip(Context.FSavedStreamPos - StreamPos);
  TagPrefix    := TWireType.LengthPrefixed.MergeWith(Context.FCurrentFieldTag);
  LengthPrefix := StreamPos - Context.FSavedStreamPos;
  Difference   := TagPrefix.Count + LengthPrefix.Count - 2;
  if Difference <> 0 then
    Move(Difference); // move memory by a few bytes to allow space for the tag and length
  Skip(- 2);
  Pack(TagPrefix);
  Pack(LengthPrefix);
  Skip(StreamPos - Context.FSavedStreamPos);
end;

procedure TOutputSerializer.EndDynamicArray;
begin

end;

procedure TOutputSerializer.EnumName(const AName: string);
begin

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

end.
