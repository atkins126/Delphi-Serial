unit Delphi.Serial.Interfaces;

{$IFDEF DEBUG}{$M+}{$ENDIF}


interface

uses
  System.Classes,
  System.Rtti;

type

  IRttiObserver = interface
    procedure Value(var AValue: Int8); overload;
    procedure Value(var AValue: Int16); overload;
    procedure Value(var AValue: Int32); overload;
    procedure Value(var AValue: Int64); overload;
    procedure Value(var AValue: UInt8); overload;
    procedure Value(var AValue: UInt16); overload;
    procedure Value(var AValue: UInt32); overload;
    procedure Value(var AValue: UInt64); overload;
    procedure Value(var AValue: Single); overload;
    procedure Value(var AValue: Double); overload;
    procedure Value(var AValue: Extended); overload;
    procedure Value(var AValue: Comp); overload;
    procedure Value(var AValue: Currency); overload;
    procedure Value(var AValue: ShortString); overload;
    procedure Value(var AValue: AnsiString); overload;
    procedure Value(var AValue: WideString); overload;
    procedure Value(var AValue: UnicodeString); overload;
    procedure Value(AValue: Pointer; AByteCount: Integer); overload;

    procedure BeginAll;
    procedure EndAll;
    procedure BeginRecord;
    procedure EndRecord;
    procedure BeginField(const AName: string);
    procedure EndField;
    procedure BeginStaticArray(ALength: Integer);
    procedure EndStaticArray;
    procedure BeginDynamicArray(var ALength: Integer);
    procedure EndDynamicArray;

    function SkipField: Boolean;
    function SkipEnumNames: Boolean;
    function SkipAttributes: Boolean;

    procedure DataType(AType: TRttiType);
    procedure EnumName(const AName: string);
    procedure Attribute(const AAttribute: TCustomAttribute);
  end;

  ISerializer = interface(IRttiObserver)
    procedure SetStream(AStream: TStream);
    procedure SetOption(const AName: string; AValue: Variant);

    property Stream: TStream write SetStream;
    property Option[const AName: string]: Variant write SetOption; default;
  end;

implementation

end.
