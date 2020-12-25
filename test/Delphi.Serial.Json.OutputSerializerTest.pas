unit Delphi.Serial.Json.OutputSerializerTest;

interface

uses
  DUnitX.TestFramework,
  Delphi.Serial.RttiObserver,
  System.Classes;

type

  [TestFixture]
  TOutputSerializerTest = class
    private
      FStream    : TCustomMemoryStream;
      FSerializer: IRttiObserver;

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
  Delphi.Serial.Json.OutputSerializer,
  Delphi.Serial.RttiVisitor,
  Schema.Addressbook.Proto;

type
  TAddressBookHelper = record helper for TAddressBook
    public
      procedure Serialize(ASerializer: IRttiObserver); inline;
  end;

{ TAddressBookHelper }

procedure TAddressBookHelper.Serialize(ASerializer: IRttiObserver);
var
  Visitor: TRttiVisitor;
begin
  Visitor.Initialize(ASerializer);
  Visitor.Visit(Self);
end;

{ TOutputSerializerTest }

procedure TOutputSerializerTest.Setup;
begin
  FStream     := TMemoryStream.Create;
  FSerializer := TOutputSerializer.Create(FStream, 1);
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
  Assert.AreEqual<Int64>(110, FStream.Position);
  FStream.Position := 0;
  Addressbook.Serialize(FSerializer); // test reusing the serializer
  Assert.AreEqual<Int64>(110, FStream.Position);
  FStream.Position := 0;
//  FStream.SaveToFile('addressbook.json');
end;

initialization

TDUnitX.RegisterTestFixture(TOutputSerializerTest);

end.
