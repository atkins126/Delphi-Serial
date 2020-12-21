unit Delphi.Serial.ProtobufUtilsTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TVarIntTest = class
    public
      [Test]
      [TestCase('First with 1 byte', '0')]
      [TestCase('Last with 1 byte', '127')]
      [TestCase('First with 2 bytes', '128')]
      [TestCase('Last with 2 bytes', '16383')]
      [TestCase('First with 3 bytes', '16384')]
      [TestCase('Last with 3 bytes', '2097151')]
      [TestCase('First with 4 bytes', '2097152')]
      [TestCase('Last with 4 bytes', '268435455')]
      [TestCase('First with 5 bytes', '268435456')]
      [TestCase('Last with 5 bytes', '34359738367')]
      [TestCase('First with 6 bytes', '34359738368')]
      [TestCase('Last with 6 bytes', '4398046511103')]
      [TestCase('First with 7 bytes', '4398046511104')]
      [TestCase('Last with 7 bytes', '562949953421311')]
      [TestCase('First with 8 bytes', '562949953421312')]
      [TestCase('Last with 8 bytes', '72057594037927935')]
      [TestCase('First with 9 bytes', '72057594037927936')]
      [TestCase('Last with 9 bytes', '9223372036854775807')]
      procedure TestCreateAndExtract(AValue: UInt64);

      [Test]
      [TestCase('First with 10 bytes', '9223372036854775808')]
      [TestCase('Last with 10 bytes', '18446744073709551615')]
      procedure TestCreateAndExtractBig(const AValue: string);
  end;

  [TestFixture]
  TSignedIntTest = class
    public
      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '2147483647')]
      [TestCase('Lowest value', '-2147483648')]
      procedure TestCreateAndExtract32(AValue: Int32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '9223372036854775807')]
      [TestCase('Lowest value', '-9223372036854775808')]
      procedure TestCreateAndExtract64(AValue: Int64);
  end;

  [TestFixture]
  TFixedInt32Test = class
    public
      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '4294967295')]
      procedure TestCreateAndExtract(AValue: UInt32);
  end;

  [TestFixture]
  TFixedInt64Test = class
    public
      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Highest value', '18446744073709551615')]
      procedure TestCreateAndExtract(const AValue: string);
  end;

implementation

uses
  Delphi.Serial.ProtobufUtils,
  System.SysUtils;

{ TVarIntTest }

procedure TVarIntTest.TestCreateAndExtract(AValue: UInt64);
begin
  Assert.AreEqual(AValue, UInt64(VarInt(AValue)));
end;

procedure TVarIntTest.TestCreateAndExtractBig(const AValue: string);
var
  Value: UInt64;
begin
  Value := UInt64.Parse(AValue);
  Assert.AreEqual(Value, UInt64(VarInt(Value)));
end;

{ TSignedIntTest }

procedure TSignedIntTest.TestCreateAndExtract32(AValue: Int32);
begin
  Assert.AreEqual(AValue, Int32(SignedInt(AValue)));
end;

procedure TSignedIntTest.TestCreateAndExtract64(AValue: Int64);
begin
  Assert.AreEqual(AValue, Int64(SignedInt(AValue)));
end;

{ TFixedInt32Test }

procedure TFixedInt32Test.TestCreateAndExtract(AValue: UInt32);
begin
  Assert.AreEqual(AValue, UInt32(FixedInt32(AValue)));
end;

{ TFixedInt64Test }

procedure TFixedInt64Test.TestCreateAndExtract(const AValue: string);
var
  Value: UInt64;
begin
  Value := UInt64.Parse(AValue);
  Assert.AreEqual(Value, UInt64(FixedInt64(Value)));
end;

initialization

TDUnitX.RegisterTestFixture(TVarIntTest);
TDUnitX.RegisterTestFixture(TSignedIntTest);

end.
