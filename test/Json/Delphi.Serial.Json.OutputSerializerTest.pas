unit Delphi.Serial.Json.OutputSerializerTest;

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
      FVisitor   : TVisitor;

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
  Schema.Addressbook.Proto;

{ TOutputSerializerTest }

procedure TOutputSerializerTest.Setup;
begin
  FStream                       := TMemoryStream.Create;
  FSerializer                   := TOutputSerializer.Create;
  FSerializer.Stream            := FStream;
  FSerializer['Indentation']    := 1;
  FSerializer['UpperCaseEnums'] := True;
  FVisitor.Initialize(FSerializer);
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
  FVisitor.Visit(Addressbook);
  Assert.AreEqual<Int64>(110, FStream.Position);
  FStream.Position := 0;
  FVisitor.Visit(Addressbook); // test reusing the serializer
  Assert.AreEqual<Int64>(110, FStream.Position);
  FStream.Position := 0;
//  FStream.SaveToFile('addressbook.json');
end;

initialization

TDUnitX.RegisterTestFixture(TOutputSerializerTest);

end.
