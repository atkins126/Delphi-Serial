unit Delphi.Serial.Json;

interface

uses
  Delphi.Serial,
  System.Classes,
  System.SysUtils;

type

  EJsonError = class(Exception);

  TJson = class
    public
      class function CreateInputSerializer(Stream: TStream): ISerializer; static;
      class function CreateOutputSerializer(Stream: TStream): ISerializer; static;
  end;

implementation

uses
  Delphi.Serial.Json.InputSerializer,
  Delphi.Serial.Json.OutputSerializer;

{ TJson }

class function TJson.CreateInputSerializer(Stream: TStream): ISerializer;
begin
  Result := TInputSerializer.Create(Stream);
end;

class function TJson.CreateOutputSerializer(Stream: TStream): ISerializer;
begin
  Result := TOutputSerializer.Create(Stream);
end;

end.
