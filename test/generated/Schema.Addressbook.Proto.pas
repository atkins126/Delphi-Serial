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
    [FieldTag(1), FieldName('number')] FNumber: string;
    [FieldTag(2), FieldName('type')] FType: TPersonPhoneType;
  end;

  TGoogleProtobufTimestamp = record
    [FieldTag(1), FieldName('seconds')] FSeconds: int64;
    [FieldTag(2), FieldName('nanos')] FNanos: int32;
  end;

  TPerson = record
    [FieldTag(1), FieldName('name')] FName: string;
    [FieldTag(2), FieldName('id')] FId: int32;
    [FieldTag(3), FieldName('email')] FEmail: string;
    [FieldTag(4), FieldName('phones')] FPhones: TArray<TPersonPhoneNumber>;
    [FieldTag(5), FieldName('lastUpdated')] FLastUpdated: TGoogleProtobufTimestamp;
  end;

  TAddressBook = record
    [FieldTag(1), FieldName('people')] FPeople: TArray<TPerson>;
  end;

implementation

end.
