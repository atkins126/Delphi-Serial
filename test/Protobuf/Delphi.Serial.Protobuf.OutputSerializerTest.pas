unit Delphi.Serial.Protobuf.OutputSerializerTest;

interface

uses
  DUnitX.TestFramework,
  Delphi.Serial,
  System.Classes;

type

  [TestFixture]
  TOutputSerializerTest = class
    private
      FStream    : TCustomMemoryStream;
      FSerializer: ISerializer;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      procedure TestSerializeAddressBook;
  end;

implementation

uses
  Delphi.Serial.Protobuf.OutputSerializer,
  Delphi.Serial.RttiVisitor,
  Schema.Addressbook.Proto;

type
  TAddressBookHelper = record helper for TAddressBook
    public
      procedure Serialize(ASerializer: ISerializer); inline;
  end;

{ TAddressBookHelper }

procedure TAddressBookHelper.Serialize(ASerializer: ISerializer);
var
  Visitor: TRttiVisitor;
begin
  Visitor.Initialize(ASerializer);
  Visitor.Visit(Self);
end;

{ TOutputSerializerTest }

procedure TOutputSerializerTest.Setup;
begin
  FStream                         := TMemoryStream.Create;
  FSerializer                     := TOutputSerializer.Create(FStream);
  FSerializer['LimitMemoryUsage'] := True;
end;

procedure TOutputSerializerTest.TearDown;
begin
  FStream.Free;
end;

procedure TOutputSerializerTest.TestSerializeAddressBook;
const
  CPerson: TPerson = (FName: 'abc'; FId: 1; FLastUpdated: (FSeconds: - 1));
var
  Addressbook: TAddressBook;
begin
  Addressbook.FPeople := Addressbook.FPeople + [CPerson];
  Addressbook.Serialize(FSerializer);
  Assert.AreEqual<Int64>(22, FStream.Position);
  FStream.Position := 0;
  Addressbook.Serialize(FSerializer); // test reusing the serializer
  Assert.AreEqual<Int64>(22, FStream.Position);
  FStream.Position := 0;
//  FStream.SaveToFile('addressbook.data');
end;

initialization

TDUnitX.RegisterTestFixture(TOutputSerializerTest);

end.