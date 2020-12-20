unit Delphi.Serial.RttiObserver;

{$IFDEF DEBUG}{$M+}{$ENDIF}

interface

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

    procedure BeginRecord(const AName: string);
    procedure EndRecord;
    procedure BeginField(const AName: string);
    procedure EndField;
    procedure BeginFixedArray(ALength: Integer);
    procedure EndFixedArray;
    procedure BeginVariableArray(var ALength: Integer);
    procedure EndVariableArray;

    function SkipEnumNames: Boolean;
    function SkipRecordAttributes: Boolean;
    function SkipFieldAttributes: Boolean;
    function SkipBranch(ABranch: Integer): Boolean;
    function ByteArrayAsAWhole: Boolean;

    procedure TypeKind(AKind: TTypeKind);
    procedure TypeName(const AName: string);
    procedure EnumName(const AName: string);
    procedure Attribute(const AAttribute: TCustomAttribute);
  end;

implementation

end.
