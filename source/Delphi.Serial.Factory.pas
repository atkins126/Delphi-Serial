unit Delphi.Serial.Factory;

interface

uses
  Delphi.Serial,
  System.Generics.Collections;

type

  TFactory = class
    private type
      TSerializerCreator = reference to function: ISerializer;

    private
      FRegisteredSerializers: TDictionary<string, TSerializerCreator>;
      class var FInstance   : TFactory;

    public
      constructor Create;
      destructor Destroy; override;

      class property Instance: TFactory read FInstance;

      procedure RegisterSerializer<T: constructor, ISerializer>(const AName: string);
      function CreateSerializer(const AName: string): ISerializer;
  end;

implementation

{ TFactory }

constructor TFactory.Create;
begin
  FRegisteredSerializers := TDictionary<string, TSerializerCreator>.Create;
end;

destructor TFactory.Destroy;
begin
  FRegisteredSerializers.Free;
  inherited;
end;

procedure TFactory.RegisterSerializer<T>(const AName: string);
begin
  FRegisteredSerializers.AddOrSetValue(AName,
      function: ISerializer
    begin
      Result := T.Create;
    end);
end;

function TFactory.CreateSerializer(const AName: string): ISerializer;
var
  Creator: TSerializerCreator;
begin
  if FRegisteredSerializers.TryGetValue(AName, Creator) then
    Result := Creator
  else
    Result := nil;
end;

initialization

TFactory.FInstance := TFactory.Create;

finalization

TFactory.FInstance.Free;

end.
