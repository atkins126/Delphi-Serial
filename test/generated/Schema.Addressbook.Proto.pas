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
    [FieldTag(1)] FNumber: string;
    [FieldTag(2)] FType: TPhoneType;
  end;

  TTimestamp = record
    [FieldTag(1)] FSeconds: int64;
    [FieldTag(2)] FNanos: int32;
  end;

  TPerson = record
    [FieldTag(1)] FName: string;
    [FieldTag(2)] FId: int32;
    [FieldTag(3)] FEmail: string;
    [FieldTag(4)] FPhones: TArray<TPhoneNumber>;
    [FieldTag(5)] FLastUpdated: TTimestamp;
  end;

  TAddressBook = record
    [FieldTag(1)] FPeople: TArray<TPerson>;
  end;

implementation

end.
