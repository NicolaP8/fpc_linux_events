{
  Rotary Encoder Tester

  1.0    - 2019.04.27 - Nicola Perotto <nicola@nicolaperotto.it>

}
{$I+,R+,Q+}
{$MODE DELPHI}
Program RotaryTest;

Uses
  CThreads, CMem, Classes, SysUtils, Rotary, InputUtils, Crt;

Var
  MyRotaryName : string;
  MyRotary : TRotary;

  bStopNow : Boolean;
  cc : char;

begin
  writeln('Rotary Encoder Test');
  MyRotaryName := EventFileSearch('rotary'); //or rotary@11 (11 = pin for A input in hex -> BCM 17)
  if (MyRotaryName = '') then begin
    writeln('not found.');
    Halt(1);
  end;
  MyRotary := TRotary.Create(True, MyRotaryName);
  writeln('Press ESC to terminate');
  writeln('Press "a" to change step size');

  MyRotary.Position := 0;
  MyRotary.Min := -1000;
  MyRotary.Max := 1000;
  MyRotary.Step := 1;
  MyRotary.Circular := False;
  MyRotary.Start;

  bStopNow := False;
  while (not bStopNow) do begin
    if MyRotary.Changed then begin
      writeln(Format('%6d (%3d)', [MyRotary.Position, MyRotary.Step]));
      MyRotary.Changed := False;
    end;

    if KeyPressed then begin
      cc := ReadKey;
      if cc = #27 then bStopNow := True; //to terminate the test
      if cc = 'a' then begin
        if MyRotary.Step = 1 then
          MyRotary.Step := 10
        else
          MyRotary.Step := 1;
      end;
    end;
    if bStopNow then Break; //from Signal Handler or keypress
    Sleep(5);
  end; //while

  MyRotary.Terminate;
  MyRotary.WaitFor;
  FreeAndNil(MyRotary);
end.
