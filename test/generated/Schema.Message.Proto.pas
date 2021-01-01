unit Schema.Message.Proto;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial;

type

  TEnum = (
    EnumValue0 = 0,
    _unused1 = 1,
    EnumValue2 = 2
  );

  TOptional = record
    [FieldTag(1), FieldName('float')] FFloat: float;
    [FieldTag(2), FieldName('bool')] FBool: bool;
    [FieldTag(3), FieldName('bytes')] FBytes: bytes;
    [FieldTag(4), FieldName('sint32')] FSint32: sint32;
    [FieldTag(5), FieldName('sint64')] FSint64: sint64;
    [FieldTag(6), FieldName('fixed32')] FFixed32: fixed32;
    [FieldTag(7), FieldName('fixed64')] FFixed64: fixed64;
    [FieldTag(8), FieldName('sfixed32')] FSfixed32: sfixed32;
    [FieldTag(9), FieldName('sfixed64')] FSfixed64: sfixed64;
    [FieldTag(10), FieldName('string')] FString: string;
    [FieldTag(11), FieldName('enum')] FEnum: TEnum;
  end;

  TRequired = record
    [FieldTag(1), Required, FieldName('float')] FFloat: float;
    [FieldTag(2), Required, FieldName('bool')] FBool: bool;
    [FieldTag(3), Required, FieldName('bytes')] FBytes: bytes;
    [FieldTag(4), Required, FieldName('sint32')] FSint32: sint32;
    [FieldTag(5), Required, FieldName('sint64')] FSint64: sint64;
    [FieldTag(6), Required, FieldName('fixed32')] FFixed32: fixed32;
    [FieldTag(7), Required, FieldName('fixed64')] FFixed64: fixed64;
    [FieldTag(8), Required, FieldName('sfixed32')] FSfixed32: sfixed32;
    [FieldTag(9), Required, FieldName('sfixed64')] FSfixed64: sfixed64;
    [FieldTag(10), Required, FieldName('string')] FString: string;
    [FieldTag(11), Required, FieldName('enum')] FEnum: TEnum;
  end;

  TRepeated = record
    [FieldTag(1), FieldName('float')] FFloat: TArray<float>;
    [FieldTag(2), FieldName('bool')] FBool: TArray<bool>;
    [FieldTag(3), FieldName('bytes')] FBytes: TArray<bytes>;
    [FieldTag(4), FieldName('sint32')] FSint32: TArray<sint32>;
    [FieldTag(5), FieldName('sint64')] FSint64: TArray<sint64>;
    [FieldTag(6), FieldName('fixed32')] FFixed32: TArray<fixed32>;
    [FieldTag(7), FieldName('fixed64')] FFixed64: TArray<fixed64>;
    [FieldTag(8), FieldName('sfixed32')] FSfixed32: TArray<sfixed32>;
    [FieldTag(9), FieldName('sfixed64')] FSfixed64: TArray<sfixed64>;
    [FieldTag(10), FieldName('string')] FString: TArray<string>;
    [FieldTag(11), FieldName('enum')] FEnum: TArray<TEnum>;
  end;

  TUnPacked = record
    [FieldTag(1), UnPacked, FieldName('float')] FFloat: TArray<float>;
    [FieldTag(2), UnPacked, FieldName('bool')] FBool: TArray<bool>;
    [FieldTag(4), UnPacked, FieldName('sint32')] FSint32: TArray<sint32>;
    [FieldTag(5), UnPacked, FieldName('sint64')] FSint64: TArray<sint64>;
    [FieldTag(6), UnPacked, FieldName('fixed32')] FFixed32: TArray<fixed32>;
    [FieldTag(7), UnPacked, FieldName('fixed64')] FFixed64: TArray<fixed64>;
    [FieldTag(8), UnPacked, FieldName('sfixed32')] FSfixed32: TArray<sfixed32>;
    [FieldTag(9), UnPacked, FieldName('sfixed64')] FSfixed64: TArray<sfixed64>;
    [FieldTag(11), UnPacked, FieldName('enum')] FEnum: TArray<TEnum>;
  end;

  TMessageMessage = record
    [Oneof] FSelector: record
      [Oneof] FCase: (
        MessageMessageOptional = 0,
        MessageMessageRequired = 1,
        MessageMessageRepeated = 2,
        MessageMessageUnpacked = 3
      );
      [FieldTag(1), FieldName('optional')] FOptional: TOptional;
      [FieldTag(2), FieldName('required')] FRequired: TRequired;
      [FieldTag(3), FieldName('repeated')] FRepeated: TRepeated;
      [FieldTag(4), FieldName('unpacked')] FUnpacked: TUnPacked;
    end;
  end;

  TMessage = record
    [FieldTag(1), FieldName('messages')] FMessages: TArray<TMessageMessage>;
  end;

implementation

end.
