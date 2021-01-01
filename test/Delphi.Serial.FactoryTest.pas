unit Delphi.Serial.FactoryTest;

interface

uses
  DUnitX.TestFramework,
  Delphi.Serial.Factory;

type

  [TestFixture]
  TFactoryTest = class
    private
      FFactory: TFactory;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Empty name', '')]
      [TestCase('Non-empty name', 'abc')]
      procedure TestRegisterAndCreateSerializer(const AName: string);
  end;

implementation

uses
  Delphi.Serial,
  System.Rtti,
  System.Classes;

type
  TSerializer = class(TInterfacedObject, ISerializer)
    private
      procedure Value(var AValue: Int8); overload; virtual; abstract;
      procedure Value(var AValue: Int16); overload; virtual; abstract;
      procedure Value(var AValue: Int32); overload; virtual; abstract;
      procedure Value(var AValue: Int64); overload; virtual; abstract;
      procedure Value(var AValue: UInt8); overload; virtual; abstract;
      procedure Value(var AValue: UInt16); overload; virtual; abstract;
      procedure Value(var AValue: UInt32); overload; virtual; abstract;
      procedure Value(var AValue: UInt64); overload; virtual; abstract;
      procedure Value(var AValue: Single); overload; virtual; abstract;
      procedure Value(var AValue: Double); overload; virtual; abstract;
      procedure Value(var AValue: Extended); overload; virtual; abstract;
      procedure Value(var AValue: Comp); overload; virtual; abstract;
      procedure Value(var AValue: Currency); overload; virtual; abstract;
      procedure Value(var AValue: ShortString); overload; virtual; abstract;
      procedure Value(var AValue: AnsiString); overload; virtual; abstract;
      procedure Value(var AValue: WideString); overload; virtual; abstract;
      procedure Value(var AValue: UnicodeString); overload; virtual; abstract;
      procedure Value(AValue: Pointer; AByteCount: Integer); overload; virtual; abstract;
      procedure BeginAll; virtual; abstract;
      procedure EndAll; virtual; abstract;
      procedure BeginRecord; virtual; abstract;
      procedure EndRecord; virtual; abstract;
      procedure BeginField(const AName: string); virtual; abstract;
      procedure EndField; virtual; abstract;
      procedure BeginStaticArray(ALength: Integer); virtual; abstract;
      procedure EndStaticArray; virtual; abstract;
      procedure BeginDynamicArray(var ALength: Integer); virtual; abstract;
      procedure EndDynamicArray; virtual; abstract;
      function SkipField: Boolean; virtual; abstract;
      function SkipEnumNames: Boolean; virtual; abstract;
      function SkipAttributes: Boolean; virtual; abstract;
      procedure DataType(AType: TRttiType); virtual; abstract;
      procedure EnumName(const AName: string); virtual; abstract;
      procedure Attribute(const AAttribute: TCustomAttribute); virtual; abstract;
      procedure SetStream(AStream: TStream); virtual; abstract;
      procedure SetOption(const AName: string; AValue: Variant); virtual; abstract;
  end;

{ TFactoryTest }

procedure TFactoryTest.Setup;
begin
  FFactory := TFactory.Create;
end;

procedure TFactoryTest.TearDown;
begin
  FFactory.Free;
end;

procedure TFactoryTest.TestRegisterAndCreateSerializer(const AName: string);
var
  Serializer: ISerializer;
begin
  Assert.IsNull(FFactory.CreateSerializer(AName));
  FFactory.RegisterSerializer<TSerializer>(AName);
  Serializer := FFactory.CreateSerializer(AName);
  Assert.IsNotNull(Serializer);
  Assert.IsTrue(Serializer is TSerializer);
end;

initialization

TDUnitX.RegisterTestFixture(TFactoryTest);

end.
