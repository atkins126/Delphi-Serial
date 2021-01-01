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
      FVisitor   : TVisitor;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      procedure TestSerializeAddressBook;

      [Test(False)]
      procedure TestSerializeMessage;
  end;

implementation

uses
  Delphi.Serial.Protobuf.OutputSerializer,
  Schema.Addressbook.Proto,
  Schema.Message.Proto;

{ TOutputSerializerTest }

procedure TOutputSerializerTest.Setup;
begin
  FStream                         := TMemoryStream.Create;
  FSerializer                     := TOutputSerializer.Create;
  FSerializer.Stream              := FStream;
  FSerializer['LimitMemoryUsage'] := True;
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
  Assert.AreEqual<Int64>(22, FStream.Position);
  FStream.Position := 0;
  FVisitor.Visit(Addressbook); // test reusing the serializer
  Assert.AreEqual<Int64>(22, FStream.Position);
  FStream.Position := 0;
//  FStream.SaveToFile('addressbook.data');
end;

procedure TOutputSerializerTest.TestSerializeMessage;
const
  CMessage: TMessageMessage = (FSelector: (FCase: MessageMessageOptional));
var
  Msg: TMessage;
begin
  Msg.FMessages := Msg.FMessages + [CMessage];
  FVisitor.Visit(Msg);
  Assert.AreEqual<Int64>(22, FStream.Position);
  FStream.Position := 0;
  FVisitor.Visit(Msg); // test reusing the serializer
  Assert.AreEqual<Int64>(22, FStream.Position);
  FStream.Position := 0;
//  FStream.SaveToFile('message.data');
end;

initialization

TDUnitX.RegisterTestFixture(TOutputSerializerTest);

end.
