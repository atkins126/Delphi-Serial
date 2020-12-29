unit Delphi.Serial.Json.InputSerializer;

interface

uses
  Delphi.Serial,
  System.Classes,
  System.Rtti;

type

  TInputSerializer = class(TInterfacedObject, ISerializer)
    private
      FStream: TStream;

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
      constructor Create(AStream: TStream);
      destructor Destroy; override;
  end;

implementation

uses
  Delphi.Serial.Json;

{ TInputSerializer }

constructor TInputSerializer.Create(AStream: TStream);
begin
  FStream := AStream;
end;

destructor TInputSerializer.Destroy;
begin

  inherited;
end;

procedure TInputSerializer.Attribute(const AAttribute: TCustomAttribute);
begin

end;

procedure TInputSerializer.BeginAll;
begin

end;

procedure TInputSerializer.BeginDynamicArray(var ALength: Integer);
begin

end;

procedure TInputSerializer.BeginField(const AName: string);
begin

end;

procedure TInputSerializer.BeginRecord;
begin

end;

procedure TInputSerializer.BeginStaticArray(ALength: Integer);
begin

end;

procedure TInputSerializer.DataType(AType: TRttiType);
begin

end;

procedure TInputSerializer.EndAll;
begin

end;

procedure TInputSerializer.EndDynamicArray;
begin

end;

procedure TInputSerializer.EndField;
begin

end;

procedure TInputSerializer.EndRecord;
begin

end;

procedure TInputSerializer.EndStaticArray;
begin

end;

procedure TInputSerializer.EnumName(const AName: string);
begin

end;

function TInputSerializer.GetOption(const AName: string): Variant;
begin
  raise EJsonError.CreateFmt('The serializer has no option with this name: %s', [AName]);
end;

procedure TInputSerializer.SetOption(const AName: string; AValue: Variant);
begin
  raise EJsonError.CreateFmt('The serializer has no option with this name: %s', [AName]);
end;

function TInputSerializer.SkipAttributes: Boolean;
begin
  Result := False;
end;

function TInputSerializer.SkipEnumNames: Boolean;
begin
  Result := False;
end;

function TInputSerializer.SkipField: Boolean;
begin
  Result := False;
end;

procedure TInputSerializer.Value(var AValue: Int64);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt8);
begin

end;

procedure TInputSerializer.Value(var AValue: UInt16);
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

procedure TInputSerializer.Value(var AValue: UInt32);
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

procedure TInputSerializer.Value(AValue: Pointer; AByteCount: Integer);
begin

end;

procedure TInputSerializer.Value(var AValue: Currency);
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

end.
