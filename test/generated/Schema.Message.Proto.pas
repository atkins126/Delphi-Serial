unit Schema.Message.Proto;

{$SCOPEDENUMS ON}

interface

uses
  Delphi.Serial;

type

  TEnum = (
    &Value0 = 0,
    _unused1 = 1,
    &Value2 = 2
  );

  TOptional = record
    [Tag(1), Name('double')] FDouble: double;
    [Tag(2), Name('float')] FFloat: float;
    [Tag(3), Name('int32')] FInt32: int32;
    [Tag(4), Name('int64')] FInt64: int64;
    [Tag(5), Name('uint32')] FUint32: uint32;
    [Tag(6), Name('uint64')] FUint64: uint64;
    [Tag(7), Name('sint32')] FSint32: sint32;
    [Tag(8), Name('sint64')] FSint64: sint64;
    [Tag(9), Name('fixed32')] FFixed32: fixed32;
    [Tag(10), Name('fixed64')] FFixed64: fixed64;
    [Tag(11), Name('sfixed32')] FSfixed32: sfixed32;
    [Tag(12), Name('sfixed64')] FSfixed64: sfixed64;
    [Tag(13), Name('bool')] FBool: bool;
    [Tag(14), Name('string')] FString: string;
    [Tag(15), Name('bytes')] FBytes: bytes;
    [Tag(16), Name('enum')] FEnum: TEnum;
  end;

  TDefault = record
    [Tag(1), Default(1.000000), Name('double')] FDouble: double;
    [Tag(2), Default(1.000000), Name('float')] FFloat: float;
    [Tag(3), Default(1), Name('int32')] FInt32: int32;
    [Tag(4), Default(1), Name('int64')] FInt64: int64;
    [Tag(5), Default(1), Name('uint32')] FUint32: uint32;
    [Tag(6), Default(1), Name('uint64')] FUint64: uint64;
    [Tag(7), Default(1), Name('sint32')] FSint32: sint32;
    [Tag(8), Default(1), Name('sint64')] FSint64: sint64;
    [Tag(9), Default(1), Name('fixed32')] FFixed32: fixed32;
    [Tag(10), Default(1), Name('fixed64')] FFixed64: fixed64;
    [Tag(11), Default(1), Name('sfixed32')] FSfixed32: sfixed32;
    [Tag(12), Default(1), Name('sfixed64')] FSfixed64: sfixed64;
    [Tag(13), Default(true), Name('bool')] FBool: bool;
    [Tag(14), Default('a'), Name('string')] FString: string;
    [Tag(15), Default(#171#14), Name('bytes')] FBytes: bytes;
    [Tag(16), Default(2), Name('enum')] FEnum: TEnum;
  end;

  TRequired = record
    [Tag(1), Required, Name('double')] FDouble: double;
    [Tag(2), Required, Name('float')] FFloat: float;
    [Tag(3), Required, Name('int32')] FInt32: int32;
    [Tag(4), Required, Name('int64')] FInt64: int64;
    [Tag(5), Required, Name('uint32')] FUint32: uint32;
    [Tag(6), Required, Name('uint64')] FUint64: uint64;
    [Tag(7), Required, Name('sint32')] FSint32: sint32;
    [Tag(8), Required, Name('sint64')] FSint64: sint64;
    [Tag(9), Required, Name('fixed32')] FFixed32: fixed32;
    [Tag(10), Required, Name('fixed64')] FFixed64: fixed64;
    [Tag(11), Required, Name('sfixed32')] FSfixed32: sfixed32;
    [Tag(12), Required, Name('sfixed64')] FSfixed64: sfixed64;
    [Tag(13), Required, Name('bool')] FBool: bool;
    [Tag(14), Required, Name('string')] FString: string;
    [Tag(15), Required, Name('bytes')] FBytes: bytes;
    [Tag(16), Required, Name('enum')] FEnum: TEnum;
  end;

  TRepeated = record
    [Tag(1), Name('double')] FDouble: TArray<double>;
    [Tag(2), Name('float')] FFloat: TArray<float>;
    [Tag(3), Name('int32')] FInt32: TArray<int32>;
    [Tag(4), Name('int64')] FInt64: TArray<int64>;
    [Tag(5), Name('uint32')] FUint32: TArray<uint32>;
    [Tag(6), Name('uint64')] FUint64: TArray<uint64>;
    [Tag(7), Name('sint32')] FSint32: TArray<sint32>;
    [Tag(8), Name('sint64')] FSint64: TArray<sint64>;
    [Tag(9), Name('fixed32')] FFixed32: TArray<fixed32>;
    [Tag(10), Name('fixed64')] FFixed64: TArray<fixed64>;
    [Tag(11), Name('sfixed32')] FSfixed32: TArray<sfixed32>;
    [Tag(12), Name('sfixed64')] FSfixed64: TArray<sfixed64>;
    [Tag(13), Name('bool')] FBool: TArray<bool>;
    [Tag(14), Name('string')] FString: TArray<string>;
    [Tag(15), Name('bytes')] FBytes: TArray<bytes>;
    [Tag(16), Name('enum')] FEnum: TArray<TEnum>;
  end;

  TUnPacked = record
    [Tag(1), UnPacked, Name('double')] FDouble: TArray<double>;
    [Tag(2), UnPacked, Name('float')] FFloat: TArray<float>;
    [Tag(3), UnPacked, Name('int32')] FInt32: TArray<int32>;
    [Tag(4), UnPacked, Name('int64')] FInt64: TArray<int64>;
    [Tag(5), UnPacked, Name('uint32')] FUint32: TArray<uint32>;
    [Tag(6), UnPacked, Name('uint64')] FUint64: TArray<uint64>;
    [Tag(7), UnPacked, Name('sint32')] FSint32: TArray<sint32>;
    [Tag(8), UnPacked, Name('sint64')] FSint64: TArray<sint64>;
    [Tag(9), UnPacked, Name('fixed32')] FFixed32: TArray<fixed32>;
    [Tag(10), UnPacked, Name('fixed64')] FFixed64: TArray<fixed64>;
    [Tag(11), UnPacked, Name('sfixed32')] FSfixed32: TArray<sfixed32>;
    [Tag(12), UnPacked, Name('sfixed64')] FSfixed64: TArray<sfixed64>;
    [Tag(13), UnPacked, Name('bool')] FBool: TArray<bool>;
    [Tag(16), UnPacked, Name('enum')] FEnum: TArray<TEnum>;
  end;

  TMessage = record
    [Tag(1), Name('optional')] FOptional: TArray<TOptional>;
    [Tag(2), Name('default')] FDefault: TArray<TDefault>;
    [Tag(3), Name('required')] FRequired: TArray<TRequired>;
    [Tag(4), Name('repeated')] FRepeated: TArray<TRepeated>;
    [Tag(5), Name('unpacked')] FUnpacked: TArray<TUnPacked>;
  end;

implementation

end.
