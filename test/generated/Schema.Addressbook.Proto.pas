unit Schema.Addressbook.Proto;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial;

type

  TPersonPhoneType = (
    &Mobile = 0,
    &Home = 1,
    &Work = 2
  );

  TPersonPhoneNumber = record
    [Tag(1), Name('number')] FNumber: string;
    [Tag(2), Name('type')] FType: TPersonPhoneType;
  end;

  TGoogleProtobufTimestamp = record
    [Tag(1), Name('seconds')] FSeconds: int64;
    [Tag(2), Name('nanos')] FNanos: int32;
  end;

  TPerson = record
    [Tag(1), Name('name')] FName: string;
    [Tag(2), Name('id')] FId: int32;
    [Tag(3), Name('email')] FEmail: string;
    [Tag(4), Name('phones')] FPhones: TArray<TPersonPhoneNumber>;
    [Tag(5), Name('lastUpdated')] FLastUpdated: TGoogleProtobufTimestamp;
  end;

  TAddressBook = record
    [Tag(1), Name('people')] FPeople: TArray<TPerson>;
  end;

implementation

end.
