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
      procedure TestPackAndParseSignedInt32(AValue: SignedInt32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '9223372036854775807')]
      [TestCase('Lowest value', '-9223372036854775808')]
      procedure TestPackAndParseSignedInt64(AValue: SignedInt64);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '2147483647')]
      [TestCase('Lowest value', '-2147483648')]
      procedure TestPackAndParseFixedInt32(AValue: FixedInt32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '9223372036854775807')]
      [TestCase('Lowest value', '-9223372036854775808')]
      procedure TestPackAndParseFixedInt64(AValue: FixedInt64);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '2147483647')]
      procedure TestPackAndParseFixedUInt32(AValue: FixedUInt32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '9223372036854775807')]
      procedure TestPackAndParseFixedUInt64(AValue: FixedUInt64);
  end;

implementation

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

procedure TSerializerTest.TestPackAndParseFixedInt32(AValue: FixedInt32);
var
  Target: FixedInt32;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseFixedInt64(AValue: FixedInt64);
var
  Target: FixedInt64;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseFixedUInt32(AValue: FixedUInt32);
var
  Target: FixedUInt32;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseFixedUInt64(AValue: FixedUInt64);
var
  Target: FixedUInt64;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseInt32(AValue: Int32);
var
  Target: Int32;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseInt64(AValue: Int64);
var
  Target: Int64;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseSignedInt32(AValue: SignedInt32);
var
  Target: SignedInt32;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseSignedInt64(AValue: SignedInt64);
var
  Target: SignedInt64;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseUInt32(AValue: UInt32);
var
  Target: UInt32;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

procedure TSerializerTest.TestPackAndParseUInt64(AValue: UInt64);
var
  Target: UInt64;
begin
  FSerializer.Pack(AValue);
  FStream.Position := 0;
  FSerializer.Parse(Target);
  Assert.AreEqual(AValue, Target);
end;

initialization

TDUnitX.RegisterTestFixture(TSerializerTest);

end.
