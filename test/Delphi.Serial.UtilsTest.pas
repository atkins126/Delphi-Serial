unit Delphi.Serial.UtilsTest;

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
  TZigZagTest = class
    public
      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '2147483647')]
      [TestCase('Lowest value', '-2147483648')]
      procedure TestZigZag32(AValue: Int32);

      [Test]
      [TestCase('Zero', '0')]
      [TestCase('One', '1')]
      [TestCase('Minus one', '-1')]
      [TestCase('Highest value', '9223372036854775807')]
      [TestCase('Lowest value', '-9223372036854775808')]
      procedure TestZigZag64(AValue: Int64);
  end;

implementation

uses
  Delphi.Serial.Utils,
  System.SysUtils;

{ TVarIntTest }

procedure TVarIntTest.TestCreateAndExtract(AValue: UInt64);
var
  VarIntValue: VarInt;
begin
  VarIntValue := AValue;
  Assert.AreEqual<UInt64>(AValue, VarIntValue);
end;

procedure TVarIntTest.TestCreateAndExtractBig(const AValue: string);
var
  Value      : UInt64;
  VarIntValue: VarInt;
begin
  Value       := UInt64.Parse(AValue);
  VarIntValue := Value;
  Assert.AreEqual<UInt64>(Value, VarIntValue);
end;

{ TZigZagTest }

procedure TZigZagTest.TestZigZag32(AValue: Int32);
begin
  Assert.AreEqual(AValue, ZigZag(ZigZag(AValue)));
end;

procedure TZigZagTest.TestZigZag64(AValue: Int64);
begin
  Assert.AreEqual(AValue, ZigZag(ZigZag(AValue)));
end;

initialization

TDUnitX.RegisterTestFixture(TVarIntTest);
TDUnitX.RegisterTestFixture(TZigZagTest);

end.
