unit Delphi.Serial.RttiVisitorTest;

{$SCOPEDENUMS ON}

interface

uses
  DUnitX.TestFramework,
  Delphi.Mocks,
  Delphi.Serial.RttiObserver;

type

  AbcAttribute = class(TCustomAttribute);
  DefAttribute = class(TCustomAttribute);

  TMyRange     = 0 .. 255;
  TNoRtti      = (A = 1);
  TUInt8Enum   = (B = 0);
  TUInt16Enum  = (C, {$INCLUDE 'UInt16Enum.inc'});
  TUInt32Enum  = (D, {$INCLUDE 'UInt32Enum.inc'});
  TMyType      = type Integer;
  TSmallSet    = set of TUInt8Enum;
  TLargeSet    = set of TMyRange;

  TMyElement = record
    FBoolean: Boolean;
    FMyType: TMyType;
    FMyRange: TMyRange;
    FAnsiChar: AnsiChar;
    FWideChar: WideChar;
  end;

  TNoRttiArray       = array [0 .. 1, 0 .. 1] of TNoRtti;
  TUInt8EnumArray    = array [0 .. 1, 0 .. 1] of TUInt8Enum;
  TUInt16EnumArray   = array [0 .. 1, 0 .. 1] of TUInt16Enum;
  TUInt32EnumArray   = array [0 .. 1, 0 .. 1] of TUInt32Enum;
  TSmallSetArray     = array [0 .. 1, 0 .. 1] of TSmallSet;
  TLargeSetArray     = array [0 .. 1, 0 .. 1] of TLargeSet;
  Int8Array          = array [0 .. 1, 0 .. 1] of Int8;
  Int16Array         = array [0 .. 1, 0 .. 1] of Int16;
  Int32Array         = array [0 .. 1, 0 .. 1] of Int32;
  Int64Array         = array [0 .. 1, 0 .. 1] of Int64;
  UInt8Array         = array [0 .. 1, 0 .. 1] of UInt8;
  UInt16Array        = array [0 .. 1, 0 .. 1] of UInt16;
  UInt32Array        = array [0 .. 1, 0 .. 1] of UInt32;
  UInt64Array        = array [0 .. 1, 0 .. 1] of UInt64;
  SingleArray        = array [0 .. 1, 0 .. 1] of Single;
  DoubleArray        = array [0 .. 1, 0 .. 1] of Double;
  ExtendedArray      = array [0 .. 1, 0 .. 1] of Extended;
  CompArray          = array [0 .. 1, 0 .. 1] of Comp;
  CurrencyArray      = array [0 .. 1, 0 .. 1] of Currency;
  ShortStringArray   = array [0 .. 1, 0 .. 1] of ShortString;
  AnsiStringArray    = array [0 .. 1, 0 .. 1] of AnsiString;
  WideStringArray    = array [0 .. 1, 0 .. 1] of WideString;
  UnicodeStringArray = array [0 .. 1, 0 .. 1] of UnicodeString;
  TMyElementArray    = array [0 .. 1, 0 .. 1] of TMyElement;

  TMyInnerRec4 = record
    FArrayOfNoRtti: TArray<TArray<TNoRtti>>;
    FArrayOfUInt8Enum: TArray<TArray<TUInt8Enum>>;
    FArrayOfUInt16Enum: TArray<TArray<TUInt16Enum>>;
    FArrayOfUInt32Enum: TArray<TArray<TUInt32Enum>>;
    FArrayOfSmallSet: TArray<TArray<TSmallSet>>;
    FArrayOfLargeSet: TArray<TArray<TLargeSet>>;
    FArrayOfInt8: TArray<TArray<Int8>>;
    FArrayOfInt16: TArray<TArray<Int16>>;
    FArrayOfInt32: TArray<TArray<Int32>>;
    FArrayOfInt64: TArray<TArray<Int64>>;
    FArrayOfUInt8: TArray<TArray<UInt8>>;
    FArrayOfUInt16: TArray<TArray<UInt16>>;
    FArrayOfUInt32: TArray<TArray<UInt32>>;
    FArrayOfUInt64: TArray<TArray<UInt64>>;
    FArrayOfSingle: TArray<TArray<Single>>;
    FArrayOfDouble: TArray<TArray<Double>>;
    FArrayOfExtended: TArray<TArray<Extended>>;
    FArrayOfComp: TArray<TArray<Comp>>;
    FArrayOfCurrency: TArray<TArray<Currency>>;
    FArrayOfShortString: TArray<TArray<ShortString>>;
    FArrayOfAnsiString: TArray<TArray<AnsiString>>;
    FArrayOfWideString: TArray<TArray<WideString>>;
    FArrayOfUnicodeString: TArray<TArray<UnicodeString>>;
    FArrayOfInnerRec4: TArray<TArray<TMyElement>>;
    FArrayOfArrays: TArray<TArray<TArray<Boolean>>>;
  end;

  TMyInnerRec3 = record
    FArrayOfNoRtti: TNoRttiArray;
    FArrayOfUInt8Enum: TUInt8EnumArray;
    FArrayOfUInt16Enum: TUInt16EnumArray;
    FArrayOfUInt32Enum: TUInt32EnumArray;
    FArrayOfSmallSet: TSmallSetArray;
    FArrayOfLargeSet: TLargeSetArray;
    FArrayOfInt8: Int8Array;
    FArrayOfInt16: Int16Array;
    FArrayOfInt32: Int32Array;
    FArrayOfInt64: Int64Array;
    FArrayOfUInt8: UInt8Array;
    FArrayOfUInt16: UInt16Array;
    FArrayOfUInt32: UInt32Array;
    FArrayOfUInt64: UInt64Array;
    FArrayOfSingle: SingleArray;
    FArrayOfDouble: DoubleArray;
    FArrayOfExtended: ExtendedArray;
    FArrayOfComp: CompArray;
    FArrayOfCurrency: CurrencyArray;
    FArrayOfShortString: ShortStringArray;
    FArrayOfAnsiString: AnsiStringArray;
    FArrayOfWideString: WideStringArray;
    FArrayOfUnicodeString: UnicodeStringArray;
    FArrayOfInnerRec4: TMyElementArray;
  end;

  TMyInnerRec2 = record
    FArrayOfNoRtti: TArray<TNoRtti>;
    FArrayOfUInt8Enum: TArray<TUInt8Enum>;
    FArrayOfUInt16Enum: TArray<TUInt16Enum>;
    FArrayOfUInt32Enum: TArray<TUInt32Enum>;
    FArrayOSmallSet: TArray<TSmallSet>;
    FArrayOLargeSet: TArray<TLargeSet>;
    FArrayOfInt8: TArray<Int8>;
    FArrayOfInt16: TArray<Int16>;
    FArrayOfInt32: TArray<Int32>;
    FArrayOfInt64: TArray<Int64>;
    FArrayOfUInt8: TArray<UInt8>;
    FArrayOfUInt16: TArray<UInt16>;
    FArrayOfUInt32: TArray<UInt32>;
    FArrayOfUInt64: TArray<UInt64>;
    FArrayOfSingle: TArray<Single>;
    FArrayOfDouble: TArray<Double>;
    FArrayOfExtended: TArray<Extended>;
    FArrayOfComp: TArray<Comp>;
    FArrayOfCurrency: TArray<Currency>;
    FArrayOfShortString: TArray<ShortString>;
    FArrayOfAnsiString: TArray<AnsiString>;
    FArrayOfWideString: TArray<WideString>;
    FArrayOfUnicodeString: TArray<UnicodeString>;
    FArrayOfInnerRec4: TArray<TMyElement>;
  end;

  TMyInnerRec = record
    FNoRtti: TNoRtti;
    FUInt8Enum: TUInt8Enum;
    FUInt16Enum: TUInt16Enum;
    FUInt32Enum: TUInt32Enum;
    FSmallSet: TSmallSet;
    FLargeSet: TLargeSet;
    FInt8: Int8;
    FInt16: Int16;
    FInt32: Int32;
    FInt64: Int64;
    FUInt8: UInt8;
    FUInt16: UInt16;
    FUInt32: UInt32;
    FUInt64: UInt64;
    FSingle: Single;
    FDouble: Double;
    FExtended: Extended;
    FComp: Comp;
    FCurrency: Currency;
    FShortString: ShortString;
    FAnsiString: AnsiString;
    FWideString: WideString;
    FUnicodeString: UnicodeString;
    FInnerRec2: TMyInnerRec2;
    FInnerRec3: TMyInnerRec3;
    FInnerRec4: TMyInnerRec4;
  end;

  [Abc]
  TMyRecord = record
  [Def]
    FInnerRec: TMyInnerRec;
  end;

  TMyRecordHelper = record helper for TMyRecord
    public
      procedure Serialize(ASerializer: IRttiObserver); inline;
  end;

  [TestFixture]
  TRttiVisitorTest = class
    private
      FMyRecord  : TMyRecord;
      FSerializer: TMock<IRttiObserver>;
      FKeepEmpty : Boolean;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      procedure TestVisit;
  end;

implementation

uses
  Delphi.Serial.RttiVisitor,
  System.Rtti;

{ TMyRecordHelper }

procedure TMyRecordHelper.Serialize(ASerializer: IRttiObserver);
var
  Visitor: TRttiVisitor;
begin
  Visitor.Initialize(ASerializer);
  Visitor.Visit(Self);
end;

{ TRttiVisitorTest }

procedure TRttiVisitorTest.Setup;
begin
  FMyRecord := Default (TMyRecord);
  with FMyRecord.FInnerRec do
    begin
      FUInt8Enum  := TUInt8Enum(- 1);
      FUInt16Enum := TUInt16Enum(- 1);
      FUInt32Enum := TUInt32Enum(- 1);
    end;

  FSerializer := TMock<IRttiObserver>.Create;
  with FSerializer.Setup do
    begin
      WillReturnDefault('SkipBranch', False);
      WillReturn(False).When.SkipField;
      WillReturn(False).When.SkipEnumNames;
      WillReturn(False).When.SkipAttributes;
      WillExecute('BeginDynamicArray',
          function(const args: TArray<TValue>; const ReturnType: TRttiType): TValue
        begin
          if FKeepEmpty then
            FKeepEmpty := False
          else
            args[1] := 2;
        end);
      WillExecute('BeginField',
        function(const args: TArray<TValue>; const ReturnType: TRttiType): TValue
        begin
          if args[1].AsType<string> = 'FArrayOfArrays' then
            FKeepEmpty := True;
        end);
    end;

  FKeepEmpty := False;
end;

procedure TRttiVisitorTest.TearDown;
begin
  FSerializer.Free;
end;

procedure TRttiVisitorTest.TestVisit;
begin
  with FSerializer.Setup do
    begin
      Expect.Exactly(15).When.BeginRecord;
      Expect.Once.When.BeginField('FInnerRec');
      Expect.Once.When.BeginField('FNoRtti');
      Expect.Exactly(3).When.BeginField('FArrayOfNoRtti');
      Expect.Exactly(10).When.EnumName('False');
      Expect.Never.When.EnumName('A');
      Expect.Exactly(10).When.EnumName('B');
      Expect.Exactly(10).When.EnumName('C');
      Expect.Exactly(10).When.EnumName('D');
      Expect.Exactly(3).When.EnumName('[Unknown]');
      Expect.Exactly(26).When.DataType(It0.Matches<TRttiType>(
          function(AType: TRttiType): Boolean
        begin
          Result := AType is TRttiEnumerationType;
        end));
      Expect.Exactly(24).When.BeginStaticArray(4);
      Expect.Exactly('BeginDynamicArray', 99);
      Expect.Exactly('EndRecord', 15);
      Expect.Exactly('EndField', 150);
      Expect.Exactly('Attribute', 2);
      Expect.Exactly('Value', 286);
    end;
  FMyRecord.Serialize(FSerializer);
  FSerializer.VerifyAll;
end;

initialization

TDUnitX.RegisterTestFixture(TRttiVisitorTest);

end.
