unit Delphi.Serial.Protobuf.ReaderWriterTest;

interface

uses
  DUnitX.TestFramework,
  Delphi.Serial.Protobuf.Reader,
  Delphi.Serial.Protobuf.Writer,
  Delphi.Serial.Protobuf,
  System.Classes;

type

  TProtobufReader = Delphi.Serial.Protobuf.Reader.TReader;
  TProtobufWriter = Delphi.Serial.Protobuf.Writer.TWriter;

  [TestFixture]
  TReaderWriterTest = class
    private
      FStream: TCustomMemoryStream;
      FReader: TProtobufReader;
      FWriter: TProtobufWriter;

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

      [Test]
      [TestCase('First wire type and first field tag', '0,1')]
      [TestCase('First wire type and last field tag', '0,536870911')]
      [TestCase('Last wire type and first field tag', '5,1')]
      [TestCase('Last wire type and last field tag', '5,536870911')]
      procedure TestPackAndParseWireTypeAndFieldTag(AWireType: Integer; AFieldTag: FieldTag);
  end;

implementation

uses
  Delphi.Serial.Protobuf.Types;

{ TSerializerTest }

procedure TReaderWriterTest.Setup;
begin
  FStream := TMemoryStream.Create;
  FReader := TProtobufReader.Create(FStream);
  FWriter := TProtobufWriter.Create(FStream);
end;

procedure TReaderWriterTest.TearDown;
begin
  FReader.Free;
  FWriter.Free;
  FStream.Free;
end;

procedure TReaderWriterTest.TestSkipAndMove(ACount: Integer);
var
  StreamPos   : Int64;
  WrittenCount: Integer;
  Target      : VarInt;
begin
  FWriter.Pack(VarInt(0));
  StreamPos := FStream.Position;
  FWriter.Pack(VarInt(High(Integer)));
  FWriter.Pack(VarInt(1));
  WrittenCount := FStream.Position - StreamPos;
  FWriter.Skip(- WrittenCount);
  FWriter.Move(WrittenCount, ACount);
  FWriter.Skip(ACount);
  FReader.Parse(Target);
  Assert.AreEqual(High(Integer), UInt32(Target));
  FReader.Parse(Target);
  Assert.AreEqual(1, UInt32(Target));
end;

procedure TReaderWriterTest.TestPackAndParseSFixed32(AValue: SFixed32);
var
  Target: FixedInt32;
begin
  FWriter.Pack(FixedInt32(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual(AValue, SFixed32(Target));
end;

procedure TReaderWriterTest.TestPackAndParseSFixed64(AValue: SFixed64);
var
  Target: FixedInt64;
begin
  FWriter.Pack(FixedInt64(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual<SFixed64>(AValue, SFixed64(Target));
end;

procedure TReaderWriterTest.TestPackAndParseFixed32(AValue: Fixed32);
var
  Target: FixedInt32;
begin
  FWriter.Pack(FixedInt32(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual(AValue, Fixed32(Target));
end;

procedure TReaderWriterTest.TestPackAndParseFixed64(AValue: Fixed64);
var
  Target: FixedInt64;
begin
  FWriter.Pack(FixedInt64(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual<Fixed64>(AValue, Fixed64(Target));
end;

procedure TReaderWriterTest.TestPackAndParseInt32(AValue: Int32);
var
  Target: VarInt;
begin
  FWriter.Pack(VarInt(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual(AValue, Int32(Target));
end;

procedure TReaderWriterTest.TestPackAndParseInt64(AValue: Int64);
var
  Target: VarInt;
begin
  FWriter.Pack(VarInt(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual(AValue, Int64(Target));
end;

procedure TReaderWriterTest.TestPackAndParseSInt32(AValue: SInt32);
var
  Target: SignedInt;
begin
  FWriter.Pack(SignedInt(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual(AValue, SInt32(Target));
end;

procedure TReaderWriterTest.TestPackAndParseSInt64(AValue: SInt64);
var
  Target: SignedInt;
begin
  FWriter.Pack(SignedInt(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual<SInt64>(AValue, SInt64(Target));
end;

procedure TReaderWriterTest.TestPackAndParseUInt32(AValue: UInt32);
var
  Target: VarInt;
begin
  FWriter.Pack(VarInt(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual(AValue, UInt32(Target));
end;

procedure TReaderWriterTest.TestPackAndParseUInt64(AValue: UInt64);
var
  Target: VarInt;
begin
  FWriter.Pack(VarInt(AValue));
  FStream.Position := 0;
  FReader.Parse(Target);
  Assert.AreEqual(AValue, UInt64(Target));
end;

procedure TReaderWriterTest.TestPackAndParseWireTypeAndFieldTag(AWireType: Integer; AFieldTag: FieldTag);
var
  TargetWireType: TWireType;
  TargetFieldTag: FieldTag;
begin
  FWriter.Pack(TWireType(AWireType), AFieldTag);
  FStream.Position := 0;
  FReader.Parse(TargetWireType, TargetFieldTag);
  Assert.AreEqual(TWireType(AWireType), TargetWireType);
  Assert.AreEqual(AFieldTag, TargetFieldTag);
end;

initialization

TDUnitX.RegisterTestFixture(TReaderWriterTest);

end.
