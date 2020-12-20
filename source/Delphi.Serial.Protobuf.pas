unit Delphi.Serial.Protobuf;

interface

uses
  Delphi.Serial.RttiObserver,
  System.Classes;

type

  FixedInt32  = type Int32;
  FixedInt64  = type Int64;
  FixedUInt32 = type UInt32;
  FixedUInt64 = type UInt64;

  TSerializer = class(TInterfacedObject)
    protected
      FStream: TStream;

    public
      property Stream: TStream read FStream write FStream;
  end;

  TInputSerializer = class(TSerializer, IRttiObserver)
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
      procedure BeginFixedArray(ALength: Integer);
      procedure EndFixedArray;
      procedure BeginVariableArray(var ALength: Integer);
      procedure EndVariableArray;

      function SkipEnumNames: Boolean;
      function SkipRecordAttributes: Boolean;
      function SkipFieldAttributes: Boolean;
      function SkipBranch(ABranch: Integer): Boolean;
      function ByteArrayAsAWhole: Boolean;

      procedure TypeKind(AKind: TTypeKind);
      procedure TypeName(const AName: string);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

    public
      constructor Create;
      destructor Destroy; override;
  end;

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
      procedure BeginFixedArray(ALength: Integer);
      procedure EndFixedArray;
      procedure BeginVariableArray(var ALength: Integer);
      procedure EndVariableArray;

      function SkipEnumNames: Boolean;
      function SkipRecordAttributes: Boolean;
      function SkipFieldAttributes: Boolean;
      function SkipBranch(ABranch: Integer): Boolean;
      function ByteArrayAsAWhole: Boolean;

      procedure TypeKind(AKind: TTypeKind);
      procedure TypeName(const AName: string);
      procedure EnumName(const AName: string);
      procedure Attribute(const AAttribute: TCustomAttribute);

    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TInputSerializer }

procedure TInputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin

end;

procedure TInputSerializer.BeginField(const AName: string);
begin

end;

procedure TInputSerializer.BeginFixedArray(ALength: Integer);
begin

end;

procedure TInputSerializer.BeginRecord(const AName: string);
begin

end;

procedure TInputSerializer.BeginVariableArray(var ALength: Integer);
begin

end;

function TInputSerializer.ByteArrayAsAWhole: Boolean;
begin
  Result := True;
end;

constructor TInputSerializer.Create;
begin

end;

destructor TInputSerializer.Destroy;
begin

  inherited;
end;

procedure TInputSerializer.EndField;
begin

end;

procedure TInputSerializer.EndFixedArray;
begin

end;

procedure TInputSerializer.EndRecord;
begin

end;

procedure TInputSerializer.EndVariableArray;
begin

end;

procedure TInputSerializer.EnumName(const AName: string);
begin

end;

function TInputSerializer.SkipBranch(ABranch: Integer): Boolean;
begin
  Result := False;
end;

function TInputSerializer.SkipEnumNames: Boolean;
begin
  Result := True;
end;

function TInputSerializer.SkipFieldAttributes: Boolean;
begin
  Result := False;
end;

function TInputSerializer.SkipRecordAttributes: Boolean;
begin
  Result := True;
end;

procedure TInputSerializer.TypeKind(AKind: TTypeKind);
begin

end;

procedure TInputSerializer.TypeName(const AName: string);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt8);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt16);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt32);
begin

end;

procedure TInputSerializer.Value(var AValue: Int64);
begin

end;

procedure TInputSerializer.Value(var AValue: Int8);
begin

end;

procedure TInputSerializer.Value(var AValue: Int16);
begin

end;

procedure TInputSerializer.Value(var AValue: Int32);
begin

end;

procedure TInputSerializer.Value(var AValue: Currency);
begin

end;

procedure TInputSerializer.Value(var AValue: ShortString);
begin

end;

procedure TInputSerializer.Value(var AValue: AnsiString);
begin

end;

procedure TInputSerializer.Value(var AValue: WideString);
begin

end;

procedure TInputSerializer.Value(var AValue: UnicodeString);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt64);
begin

end;

procedure TInputSerializer.Value(var AValue: Single);
begin

end;

procedure TInputSerializer.Value(var AValue: Double);
begin

end;

procedure TInputSerializer.Value(var AValue: Extended);
begin

end;

procedure TInputSerializer.Value(var AValue: Comp);
begin

end;

procedure TInputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin

end;

{ TOutputSerializer }

procedure TOutputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin

end;

procedure TOutputSerializer.BeginField(const AName: string);
begin

end;

procedure TOutputSerializer.BeginFixedArray(ALength: Integer);
begin

end;

procedure TOutputSerializer.BeginRecord(const AName: string);
begin

end;

procedure TOutputSerializer.BeginVariableArray(var ALength: Integer);
begin

end;

function TOutputSerializer.ByteArrayAsAWhole: Boolean;
begin
  Result := True;
end;

constructor TOutputSerializer.Create;
begin

end;

destructor TOutputSerializer.Destroy;
begin

  inherited;
end;

procedure TOutputSerializer.EndField;
begin

end;

procedure TOutputSerializer.EndFixedArray;
begin

end;

procedure TOutputSerializer.EndRecord;
begin

end;

procedure TOutputSerializer.EndVariableArray;
begin

end;

procedure TOutputSerializer.EnumName(const AName: string);
begin

end;

function TOutputSerializer.SkipBranch(ABranch: Integer): Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipEnumNames: Boolean;
begin
  Result := True;
end;

function TOutputSerializer.SkipFieldAttributes: Boolean;
begin
  Result := False;
end;

function TOutputSerializer.SkipRecordAttributes: Boolean;
begin
  Result := True;
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
