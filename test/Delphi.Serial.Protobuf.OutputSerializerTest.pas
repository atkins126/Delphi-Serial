unit Delphi.Serial.Protobuf.OutputSerializerTest;

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

      procedure SaveToFile(const AFileName: string);

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

procedure TOutputSerializerTest.SaveToFile(const AFileName: string);
begin
  FStream.Size     := FStream.Position;
  FStream.Position := 0;
  FStream.SaveToFile(AFileName);
end;

procedure TOutputSerializerTest.Setup;
begin
  FStream     := TMemoryStream.Create;
  FSerializer := TOutputSerializer.Create(FStream);
end;

procedure TOutputSerializerTest.TearDown;
begin
  FStream.Free;
end;

procedure TOutputSerializerTest.TestSerializeAddressBook;
const
  CPerson: TPerson = (FName: 'abc');
var
  Addressbook: TAddressBook;
begin
  Addressbook.FPeople := Addressbook.FPeople + [CPerson];
  Addressbook.Serialize(FSerializer);
  Assert.AreEqual<Int64>(10, FStream.Position);
//  SaveToFile('addressbook.data');
end;

initialization

TDUnitX.RegisterTestFixture(TOutputSerializerTest);

end.
