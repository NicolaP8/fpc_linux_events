{
  Linux Event Tester - for Rotary Encoder

  1.0    - 2019.04.24 - Nicola Perotto <nicola@nicolaperotto.it>

}
{$I+,R+,Q+}
{$DEFINE DEBUG}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}
Program Event;

uses
  {$IFDEF FPC}CThreads, CMem, BaseUnix, {$ENDIF} Classes, SysUtils, RtlConsts,
  IOCtl, Input, InputEventCodes, InputUtils
  {$IFDEF DEBUG}, DebugMe{$ENDIF}
  ;

{$IFNDEF FPC}//compilazione su Delphi
Const
  O_RDONLY = 0;

Type
  PSigActionRec = ^LongInt;
  TRTLCriticalSection = integer;
  cint = integer;
  TIOCtlRequest = integer;
// TIOCtlRequest = cInt;
  QWord = Int64;
  timeval     = record
                 tv_sec:LongWord;
                 tv_usec:LongWord;
                end;

Procedure InitCriticalSection(Var FCS); begin end;
Procedure DoneCriticalSection(Var FCS); begin end;
Procedure ClrScr; begin end;
Procedure GotoXY(Const X,Y:integer); begin end;
Function KeyPressed:Boolean; begin result := True; end;
Function ReadKey:char; begin Result := #0; end;
procedure DoIoCtlError(Ndx:Int64); begin end;
Function FpOpen(filename:string; flags:longword):integer; begin result := 0; end;
Function FpIOCtl(fHandle:integer; command:integer; data:pointer):integer; begin result := 0; end;
Procedure FpClose(handle:integer); begin end;
Function FpRead(fHandle:integer; Var data; size:integer):integer; begin result := 0; end;
{$ENDIF}

Const
  sIOCtlError = 'IOCtl failed. Request code %d.';
  MaxNumEvents = 64;

  EventNames : array[0..EV_MAX] of string = (
    'Sync',           // EV_SYN
    'Key',            // EV_KEY
	  'Relative',       // EV_REL
    'Absolute',       // EV_ABS
	  'Misc',           // EV_MSC
    'Software',       // EV_SW
    '',               // 06
    '',               // 07
    '',               // 08
    '',               // 09
    '',               // 0a
    '',               // 0b
    '',               // 0c
    '',               // 0d
    '',               // 0e
    '',               // 0f
    '',               // 10
  	'LED',            // EV_LED
    'Sound',          // EV_SND
    '',               // 13
    'Repeat',         // EV_REP
    'ForceFeedback',  // EV_FF
    'Power',          // EV_PWR
    'ForceFeedbackStatus',  // EV_FF_STATUS
    '',               // 18
    '',               // 19
    '',               // 1a
    '',               // 1b
    '',               // 1c
    '',               // 1d
    '',               // 1e
    ''                // EV_MAX
  );

  AbsNames : array[0..5] of string = ('Value', 'Min', 'Max', 'Fuzz', 'Flat', 'Resolution');

  RelativeNames : array[0..REL_MAX] of string = (
    'REL_X',
    'REL_Y',
    'REL_Z',
    'REL_RX',
    'REL_RY',
    'REL_RZ',
    'REL_HWHEEL',
    'REL_DIAL',
    'REL_WHEEL',
    'REL_MISC',
    'REL_RESERVED',
    'REL_WHEEL_HI_RES',
    'REL_HWHEEL_HI_RES',
    '',
    '',
    ''
  );

Var
  SigOA, SigNA : PSigActionRec;
  Terminated : Boolean;
  MyRotary : string; //event file name
  i, j, k, r, fHandle : integer;
	Version : integer;
	ID : TInput_ID;
	StringBuffer : string;
  Name : string;
  Active : LongWord;
  EBits : array[0..(InputEventCodes.KEY_CNT div 8)-1] of byte; //one bit each Key code
	EAbs : TInput_Absinfo;
  sl : TStringList;
  ev : array[0..MaxNumEvents -1] of TInput_Event;

function GetBit(Value: QWord; Index: Byte): Boolean;
begin
  Result := ((Value shr Index) and 1) = 1;
end;

{$IFDEF FPC}
procedure DoIoCtlError(Ndx:LongWord); //inline;
var //uses LongWord in place of TIOCtlRequest
  e: EOSError;
begin
  e := EOSError.CreateFmt(sIOCtlError, [Ndx]);
  e.ErrorCode := baseunix.errno;
  raise e;
end;
{$ENDIF}

Procedure DoSig(sig:cint); {$IFDEF FPC}Cdecl;{$ENDIF}
begin //Wait for SigTerm: kill pid
  Terminated := True;
  writeln('Got Signal!');
end; //DoSig

Procedure Init;
begin
  Terminated := False;
{$IFDEF FPC}
  New(SigNA);
  New(SigOA);
  SigNA^.sa_Handler := SigActionHandler(@DoSig);
  Fillchar(SigNA^.Sa_Mask, sizeof(SigNA^.sa_mask), #0);
  SigNA^.Sa_Flags := 0;
  SigNA^.Sa_Restorer := Nil;
  if fpSigAction(SigTerm, SigNA, SigOA) <> 0 then begin
    writeln('Signal Handler Error: ', fpgeterrno);
    Halt(1);
  end;
{$ENDIF}
end; //Init

begin
  Init;
  if ParamCount = 0 then begin
    sl := TStringList.Create;
    EventFileList(sl);
    for i := 0 to sl.Count -1 do
      writeln(sl[i]);
    FreeAndNil(sl);
    Exit;
  end;

  writeln('Linux Event System Test');
  MyRotary := EventFileSearch(ParamStr(1)); //or rotary@11 (11 = pin for A input in hex -> BCM 17)
  if MyRotary = '' then begin
    writeln('No Event Found.');
    Halt(1);
  end;

  writeln(MyRotary);

  fHandle := FpOpen(MyRotary, O_RDONLY);
  if fHandle < 0 then
    raise EFOpenError.CreateFmt(SFOpenError, [MyRotary]);

  if FpIOCtl(fHandle, Integer(EVIOCGVERSION), @Version) = -1 then
    DoIoCtlError(EVIOCGVERSION);

  writeln(Format('Input driver version is %d.%d.%d', [Version shr 16, (Version shr 8) and $ff, Version and $ff]));

  if FpIOCtl(fHandle, Integer(EVIOCGID), @ID) = -1 then
    DoIoCtlError(EVIOCGID);
  writeln(Format('Input device ID: bus $%2.2x vendor $%2.2x product $%2.2x version $%2.2x',
		[id.bustype, id.vendor, id.product, id.version]));

  SetLength(StringBuffer, EVIOCGNAME_size);
  if FpIOCtl(fHandle, Integer(EVIOCGNAME), PChar(StringBuffer)) = -1 then
    DoIoCtlError(EVIOCGNAME);
  Name := Copy(StringBuffer, 1, Pos(#0, StringBuffer)); //copies from a C string to a wonderful Pascal string!
	writeln('Input device name: ' + Name);

{
  writeln('EIOCTLDir ' + IntToStr(Low(EIOCTLDir)) + ' ' + IntToStr(High(EIOCTLDir)));
  writeln('EIOCTLType ' + IntToStr(Low(EIOCTLType)) + ' ' + IntToStr(High(EIOCTLType)));
  writeln('EIOCTLNumber ' + IntToStr(Low(EIOCTLNumber)) + ' ' + IntToStr(High(EIOCTLNumber)));
  writeln('EIOCTLSize ' + IntToStr(Low(EIOCTLSize)) + ' ' + IntToStr(High(EIOCTLSize)));
}
	r := FpIOCtl(fHandle, Compose_IOC(_IOC_READ, Ord('E'), $20 + 0, SizeOf(LongWord)), @Active);
  if r < 0 then
    DoIoCtlError(EVIOCGBIT);
	writeln('Supported events:');

	for i := 0 to EV_MAX do begin
		if GetBit(Active, i) then begin
			writeln(Format('  Event type %d (%s)', [i, EventNames[i]]));
      if i = 0 then continue; //EV_SYN no need to read further

      FillChar(EBits, SizeOf(EBits), #0);
			k := FpIOCtl(fHandle, Compose_IOC(_IOC_READ, Ord('E'), $20 + i, SizeOf(EBits)), @EBits);
      if k < 0 then
        DoIoCtlError(EVIOCGBIT);
        
//for j := 0 to k -1 do write(Format('%2.2x ', [EBits[j]])); writeln;

			for j := 0 to k * 8 -1 do begin //check only effective loaded bits
//writeln(Format('%d %d %d ', [j, j div 8, j and 7, GetBit(EBits[j div 8], j and 7)]));
        if GetBit(EBits[j div 8], j and 7) then begin
					case i of
          EV_KEY : begin
    					WriteLn(Format('    Event code %d $%4.4x (%d)', [j, j, j])); //the second it's the name... in the future!
            end;
          EV_ABS : begin
    					WriteLn(Format('    Event code %d $%4.4x (%d)', [j, j, j])); //the second it's the name... in the future!
              r := FpIOCtl(fHandle, Compose_IOC(_IOC_READ, Ord('E'), $40 + j, SizeOf(EAbs)), @EAbs);
              if r < 0 then
                DoIoCtlError(EVIOCGABS);
              writeln(Format('      %-10s %6d', [AbsNames[0], EAbs.Value]));
              writeln(Format('      %-10s %6d', [AbsNames[1], EAbs.minimum]));
              writeln(Format('      %-10s %6d', [AbsNames[2], EAbs.maximum]));
              if EAbs.fuzz <> 0 then
                writeln(Format('      %-10s %6d', [AbsNames[3], EAbs.fuzz]));
              if EAbs.flat <> 0 then
                writeln(Format('      %-10s %6d', [AbsNames[4], EAbs.flat]));
              if EAbs.resolution <> 0 then
                writeln(Format('      %-10s %6d', [AbsNames[5], EAbs.resolution]));
            end;
          EV_REL : begin //Rotary
    					WriteLn(Format('    Event code %d $%4.4x (%s)', [j, j, RelativeNames[j]]));
            end;
          else begin
    					WriteLn(Format('    Event code %d $%4.4x (%d)', [j, j, j])); //the second it's the name... in the future!
            end;
          end; //case
        end; //if
      end; //for j
    end; //if used
  end; //for i

  WriteLn;
	WriteLn('Testing ... (CTRL-C to exit)');

  Terminated := False;
	while (not Terminated) do begin
		r := FpRead(fHandle, ev, sizeof(TInput_Event) * MaxNumEvents);

		if (r < Sizeof(TInput_Event)) and not Terminated then begin
			writeln('Error reading events.');
      Break;
		end;

		for i := 0 to (r div Sizeof(TInput_Event) - 1) do
			if (ev[i].etype = EV_SYN) then begin
				writeln(Format('Event: time %d.%6d, -------------- %d ------------',
					[ev[i].time.tv_sec, ev[i].time.tv_usec, ev[i].code]));

			end else if ((ev[i].etype = EV_MSC) and ((ev[i].code = MSC_RAW) or (ev[i].code = MSC_SCAN))) then begin
				writeln(Format('Event: time %d.%6d, type %d (%s), code %d (%s), value %2x',
					[ev[i].time.tv_sec, ev[i].time.tv_usec, ev[i].etype, 'evname', ev[i].code, 'evtype', ev[i].value]));
			end else begin
				writeln(Format('Event: time %d.%6d, type %d (%s), code %d (%s), value %d',
					[ev[i].time.tv_sec, ev[i].time.tv_usec, ev[i].etype, 'evtype', ev[i].code, 'evname', ev[i].value]));
			end; //if
  end; //while

  FpClose(fHandle);
end.