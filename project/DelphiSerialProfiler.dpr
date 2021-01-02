program DelphiSerialProfiler;

uses
  Vcl.Forms,
  Delphi.Serial.Profiler.FormProfiler in '..\profiler\Delphi.Serial.Profiler.FormProfiler.pas' {FormProfiler};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormProfiler, FormProfiler);
  Application.Run;

end.
