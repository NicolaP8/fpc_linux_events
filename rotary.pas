{$I+,R+,Q+,H+}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}
{DEFINE DEBUG}
Unit Rotary;

Interface

Uses
  {$IFDEF FPC}CThreads, CMem, BaseUnix,{$ELSE}CompileInDelphi,{$ENDIF}
 {$IFDEF DEBUG}DebugMe,{$ENDIF}
  Classes, SysUtils, RtlConsts,
  Input, InputEventCodes;

Const
  MaxNumEvents = 8; //never got more than 2 event at time, this a hand moved knob 
    
Type
  TRotary = class(TThread)
  private
    ev : array[0..MaxNumEvents -1] of TInput_Event;
    EventFileName : string;
    EventHandle : integer;
    FPosition : integer;
    FStep : integer;
    FMin, FMax : integer;
    FCircular : Boolean;
    FSemaphore : Pointer;
    FChanged : Boolean;
    procedure SetCircular(const Value: Boolean);
    procedure SetMax(const Value: integer);
    procedure SetMin(const Value: integer);
    procedure SetStep(const Value: integer);
  protected
    procedure Execute; override;
    Procedure SetPosition(Const Value:Integer);
  public
    {$IFNDEF FPC}
    Finished:Boolean;
    Procedure Start;
    {$ENDIF}
    Constructor Create(CreateSuspended:boolean; Const EventName:string);
    Destructor Destroy; Override;
  published
    Property Position:Integer read FPosition write SetPosition;
    Property Min:integer read FMin write SetMin;
    Property Max:integer read FMax write SetMax;
    Property Step:integer read FStep write SetStep;
    Property Circular:Boolean read FCircular write SetCircular;
    Property Changed:Boolean read FChanged write FChanged;
  end;


Implementation


{$IFNDEF FPC} //delphi fast sintax check!
Procedure TRotary.Start; begin end;
{$ENDIF}

constructor TRotary.Create(CreateSuspended:boolean; Const EventName:string);
begin
  FreeOnTerminate := False;
  FPosition := 0;
  FMin := -100;
  FMax := 100;
  FStep := 1;
  FCircular := False;
  FChanged := False;
  FSemaphore := SemaphoreInit;
  SemaphorePost(FSemaphore);
  EventFileName := EventName;
  EventHandle := FpOpen(EventFileName, O_RDONLY);
  if EventHandle < 0 then
    raise EFOpenError.CreateFmt(SFOpenError, [EventFileName]);
  FpFcntl(EventHandle, F_SETFL, O_NONBLOCK);

  Inherited Create(CreateSuspended);
end; //Create

destructor TRotary.Destroy;
begin
  if not Terminated then writeln('Rotary not Terminated!');
  
  if EventHandle > 0 then
    FpClose(EventHandle);
  EventHandle := 0;
  if Assigned(FSemaphore) then SemaphoreDestroy(FSemaphore);
  {$IFDEF DEBUG}
  //DebugLn(TimeStamp + ' Rotary.Destroy');
  {$ENDIF}
  Inherited;
end; //Destroy

procedure TRotary.Execute;
Var
  np, p, i, r : integer;
begin
  if EventHandle <= 0 then Exit;

  while (not Terminated) do begin
    r := FpRead(EventHandle, ev, sizeof(TInput_Event) * MaxNumEvents);
    if (r <= 0) then Sleep(10);
    if Terminated then Break;

		for i := 0 to (r div Sizeof(TInput_Event) - 1) do begin
			if (ev[i].etype = EV_REL) and (ev[i].code = REL_X) then begin
        try
          SemaphoreWait(FSemaphore);
          p := FStep;
          if ev[i].value > 0 then begin
            np := FPosition + p;
            if np > FMax then begin
              if FCircular then
                np := FMin
              else
                np := FMax;
            end;
          end else if ev[i].value < 0 then begin
            np := FPosition - p;
            if np < FMin then begin
              if FCircular then
                np := FMax
              else
                np := FMin;
            end;
          end else
            np := FPosition; //in teoria non ci passa mai
          FPosition := np;
          FChanged := True;
        finally
          SemaphorePost(FSemaphore);
        end; //try
      end; //if
    end; //for

  end; //while
  SemaphoreDestroy(FSemaphore);
  FSemaphore := Nil;
end; //Execute

procedure TRotary.SetCircular(const Value: Boolean);
begin
  try
    SemaphoreWait(FSemaphore);
    FCircular := Value;
  finally
    SemaphorePost(FSemaphore);
  end;
end;

procedure TRotary.SetMax(const Value: integer);
begin
  try
    SemaphoreWait(FSemaphore);
    FMax := Value;
  finally
    SemaphorePost(FSemaphore);
  end;
end;

procedure TRotary.SetMin(const Value: integer);
begin
  try
    SemaphoreWait(FSemaphore);
    FMin := Value;
  finally
    SemaphorePost(FSemaphore);
  end;
end;

procedure TRotary.SetPosition(const Value: Integer);
begin
  try
    SemaphoreWait(FSemaphore);
    FPosition := Value;
  finally
    SemaphorePost(FSemaphore);
  end;
end;

procedure TRotary.SetStep(const Value: integer);
begin
  try
    SemaphoreWait(FSemaphore);
    FStep := Value;
  finally
    SemaphorePost(FSemaphore);
  end;
end;

end.