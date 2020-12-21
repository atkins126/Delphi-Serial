unit Delphi.Serial.Protobuf.OutputSerializer;

interface

uses
  Delphi.Serial.Protobuf.Serializer,
  Delphi.Serial.RttiObserver,
  System.Classes;

type

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
      constructor Create(Stream: TStream);
      destructor Destroy; override;
  end;

implementation

{ TOutputSerializer }

constructor TOutputSerializer.Create;
begin
  inherited;

end;

destructor TOutputSerializer.Destroy;
begin

  inherited;
end;

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin

end;

procedure TOutputSerializer.BeginField(const AName: string);
begin

end;

procedure TOutputSerializer.BeginStaticArray(ALength: Integer);
begin

end;

procedure TOutputSerializer.BeginRecord(const AName: string);
begin

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
begin

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
