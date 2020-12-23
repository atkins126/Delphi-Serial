unit Schema.Addressbook.Proto;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial.Protobuf;

type

  TPhoneType = (
    Mobile = 0,
    Home = 1,
    Work = 2
  );

  TPhoneNumber = record
    [Protobuf(1)] FNumber: string;
    [Protobuf(2)] FType: TPhoneType;
  end;

  TTimestamp = record
    [Protobuf(1)] FSeconds: int64;
    [Protobuf(2)] FNanos: int32;
  end;

  TPerson = record
    [Protobuf(1)] FName: string;
    [Protobuf(2)] FId: int32;
    [Protobuf(3)] FEmail: string;
    [Protobuf(4)] FPhones: TArray<TPhoneNumber>;
    [Protobuf(5)] FLastUpdated: TTimestamp;
  end;

  TAddressBook = record
    [Protobuf(1)] FPeople: TArray<TPerson>;
  end;

implementation

end.
