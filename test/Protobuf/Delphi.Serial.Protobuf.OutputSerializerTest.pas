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

      [Test]
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
  COptional: TOptional = (FFloat: 0.1);
  CRequired: TRequired = (FFloat: 0.1);
  CRepeated: TRepeated = (FFloat: [0.1]);
  CUnPacked: TUnPacked = (FFloat: [0.1]);
var
  Msg: TMessage;
begin
  Msg.FOptional := Msg.FOptional + [COptional];
  Msg.FRequired := Msg.FRequired + [CRequired];
  Msg.FRepeated := Msg.FRepeated + [CRepeated];
  Msg.FUnPacked := Msg.FUnPacked + [CUnPacked];
  FVisitor.Visit(Msg);
  Assert.AreEqual<Int64>(68, FStream.Position);
  FStream.Position := 0;
  FVisitor.Visit(Msg); // test reusing the serializer
  Assert.AreEqual<Int64>(68, FStream.Position);
  FStream.Position := 0;
//  FStream.SaveToFile('message.data');
end;

initialization

TDUnitX.RegisterTestFixture(TOutputSerializerTest);

end.
