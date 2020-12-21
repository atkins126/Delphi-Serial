unit Delphi.Serial.Protobuf.SerializerTest;

interface

uses
  DUnitX.TestFramework,
  Delphi.Serial.Protobuf.Serializer,
  Delphi.Serial.Protobuf,
  System.Classes;

type

  TSerializer = class(Delphi.Serial.Protobuf.Serializer.TSerializer);

  [TestFixture]
  TSerializerTest = class
    private
      FStream    : TCustomMemoryStream;
      FSerializer: TSerializer;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      procedure TestSkipAndMove(ACount: Integer);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '2147483647')]
      [TestCase('Lowest value', '-2147483648')]
      procedure TestPackAndParseInt32(AValue: Int32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '9223372036854775807')]
      [TestCase('Lowest value', '-9223372036854775808')]
      procedure TestPackAndParseInt64(AValue: Int64);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '2147483647')]
      procedure TestPackAndParseUInt32(AValue: UInt32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '9223372036854775807')]
      procedure TestPackAndParseUInt64(AValue: UInt64);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '2147483647')]
      [TestCase('Lowest value', '-2147483648')]
      procedure TestPackAndParseSInt32(AValue: SInt32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '9223372036854775807')]
      [TestCase('Lowest value', '-9223372036854775808')]
      procedure TestPackAndParseSInt64(AValue: SInt64);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '2147483647')]
      [TestCase('Lowest value', '-2147483648')]
      procedure TestPackAndParseSFixed32(AValue: SFixed32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '9223372036854775807')]
      [TestCase('Lowest value', '-9223372036854775808')]
      procedure TestPackAndParseSFixed64(AValue: SFixed64);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '2147483647')]
      procedure TestPackAndParseFixed32(AValue: Fixed32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '9223372036854775807')]
      procedure TestPackAndParseFixed64(AValue: Fixed64);
  end;

  [TestFixture]
  TWireTypeTest = class
    public
      [Test]
      [TestCase('First wire type and first field tag', '0,1,8')]
      [TestCase('First wire type and last field tag', '0,536870911,4294967288')]
      [TestCase('Last wire type and first field tag', '5,1,13')]
      [TestCase('Last wire type and last field tag', '5,536870911,4294967293')]
      procedure TestCombineAndExtract(AWireType: Integer; AFieldTag: FieldTag; AExpectedValue: UInt32);
  end;

implementation

uses
  Delphi.Serial.ProtobufUtils;

{ TSerializerTest }

procedure TSerializerTest.Setup;
begin
  FStream     := TMemoryStream.Create;
  FSerializer := TSerializer.Create(FStream);
end;

procedure TSerializerTest.TearDown;
begin
  FSerializer.Free;
  FStream.Free;
end;

procedure TSerializerTest.TestSkipAndMove(ACount: Integer);
var
  Pos   : Int64;
  Target: VarInt;
begin
  FSerializer.Pack(VarInt(0));
  Pos := FStream.Position;
  FSerializer.Pack(VarInt(High(Integer)));
  FSerializer.Pack(VarInt(1));
  FSerializer.Skip(Pos - FStream.Position);
  FSerializer.Move(ACount);
  FSerializer.Skip(ACount);
  FSerializer.Parse(Target);
  Assert.AreEqual(High(Integer), UInt32(Target));
  FSerializer.Parse(Target);
  Assert.AreEqual(1, UInt32(Target));
end;

procedure TSerializerTest.TestPackAndParseSFixed32(AValue: SFixed32);
var
  Target: FixedInt32;
begin
  FSerializer.Pack(FixedInt32(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, SFixed32(Target));
end;

procedure TSerializerTest.TestPackAndParseSFixed64(AValue: SFixed64);
var
  Target: FixedInt64;
begin
  FSerializer.Pack(FixedInt64(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual<SFixed64>(AValue, SFixed64(Target));
end;

procedure TSerializerTest.TestPackAndParseFixed32(AValue: Fixed32);
var
  Target: FixedInt32;
begin
  FSerializer.Pack(FixedInt32(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Fixed32(Target));
end;

procedure TSerializerTest.TestPackAndParseFixed64(AValue: Fixed64);
var
  Target: FixedInt64;
begin
  FSerializer.Pack(FixedInt64(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual<Fixed64>(AValue, Fixed64(Target));
end;

procedure TSerializerTest.TestPackAndParseInt32(AValue: Int32);
var
  Target: VarInt;
begin
  FSerializer.Pack(VarInt(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Int32(Target));
end;

procedure TSerializerTest.TestPackAndParseInt64(AValue: Int64);
var
  Target: VarInt;
begin
  FSerializer.Pack(VarInt(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Int64(Target));
end;

procedure TSerializerTest.TestPackAndParseSInt32(AValue: SInt32);
var
  Target: SignedInt;
begin
  FSerializer.Pack(SignedInt(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, SInt32(Target));
end;

procedure TSerializerTest.TestPackAndParseSInt64(AValue: SInt64);
var
  Target: SignedInt;
begin
  FSerializer.Pack(SignedInt(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual<SInt64>(AValue, SInt64(Target));
end;

procedure TSerializerTest.TestPackAndParseUInt32(AValue: UInt32);
var
  Target: VarInt;
begin
  FSerializer.Pack(VarInt(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, UInt32(Target));
end;

procedure TSerializerTest.TestPackAndParseUInt64(AValue: UInt64);
var
  Target: VarInt;
begin
  FSerializer.Pack(VarInt(AValue));
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, UInt64(Target));
end;

{ TWireTypeTest }

procedure TWireTypeTest.TestCombineAndExtract(AWireType: Integer; AFieldTag: FieldTag; AExpectedValue: UInt32);
var
  WireType: TWireType;
begin
  Assert.AreEqual(AExpectedValue, TWireType(AWireType).CombineWith(AFieldTag));
  Assert.AreEqual(AFieldTag, WireType.ExtractFrom(AExpectedValue));
  Assert.AreEqual(TWireType(AWireType), WireType);
end;

initialization

TDUnitX.RegisterTestFixture(TSerializerTest);

end.
