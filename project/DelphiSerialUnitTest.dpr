program DelphiSerialUnitTest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  FastMM4,
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  Delphi.Serial.RttiVisitorTest in '..\test\Delphi.Serial.RttiVisitorTest.pas',
  Delphi.Serial.ProtobufTest in '..\test\Delphi.Serial.ProtobufTest.pas',
  Delphi.Serial.JsonTest in '..\test\Delphi.Serial.JsonTest.pas',
  Delphi.Serial.BsonTest in '..\test\Delphi.Serial.BsonTest.pas',
  Delphi.Serial.XmlTest in '..\test\Delphi.Serial.XmlTest.pas',
  Delphi.Serial.YamlTest in '..\test\Delphi.Serial.YamlTest.pas',
  Delphi.Serial.TomlTest in '..\test\Delphi.Serial.TomlTest.pas',
  Delphi.Serial.AvroTest in '..\test\Delphi.Serial.AvroTest.pas',
  Delphi.Serial.MessagePackTest in '..\test\Delphi.Serial.MessagePackTest.pas',
  Delphi.Serial.ThriftTest in '..\test\Delphi.Serial.ThriftTest.pas',
  Delphi.Serial.SbeTest in '..\test\Delphi.Serial.SbeTest.pas',
  Delphi.Serial.CborTest in '..\test\Delphi.Serial.CborTest.pas',
  Delphi.Serial.ProtobufTypesTest in '..\test\Delphi.Serial.ProtobufTypesTest.pas',
  Delphi.Serial.Protobuf.SerializerTest in '..\test\Delphi.Serial.Protobuf.SerializerTest.pas',
  Delphi.Serial.Protobuf.OutputSerializerTest in '..\test\Delphi.Serial.Protobuf.OutputSerializerTest.pas',
  Schema.Addressbook.Proto in '..\test\generated\Schema.Addressbook.Proto.pas',
  Delphi.Serial.Json.OutputSerializerTest in '..\test\Delphi.Serial.Json.OutputSerializerTest.pas';

{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
