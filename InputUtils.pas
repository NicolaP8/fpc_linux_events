{
  Linux Kernel input.h - some useful routines

  1.0    - 2019.04.24 - Nicola Perotto <nicola@nicolaperotto.it>
}
{$I+,R+,Q+}
{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}
Unit InputUtils;

Interface

Uses
  {$IFDEF FPC}CMem, BaseUnix,{$ENDIF} SysUtils, IOCtl, Input, Classes;

{$IFNDEF FPC}//Syntax Check in Delphi IDE
Type
  cInt = integer;
  TIOCtlRequest = cInt;
  QWord = Int64;
{$ENDIF}

Const
  //EventFileName = '/dev/input/event';
  EventFileName = '/dev/input/by-path/';

//Search for the first input event file containing the pattern, case-sensitive
Function EventFileSearch(Const Pattern:string):string;

//populate the stringlist with the complete path off all event files
Procedure EventFileList(Var List:TStringList);


Implementation


Function EventFileSearch(Const Pattern:string):string;
Var
  sr : TSearchRec;
  e : integer;
begin
  Result := '';
  e := FindFirst(EventFileName + '*', faAnyFile, sr);
  while (e = 0) do begin
    if (sr.Name <> '.') and (sr.Name <> '..') then begin
      if Pos(Pattern, sr.Name) > 0 then begin
        Result := EventFileName + sr.Name;
        Break;
      end;
    end;
    e := FindNext(sr);
  end;
  FindClose(sr);
end; //EventFileSearch

Procedure EventFileList(Var List:TStringList);
Var
  sr : TSearchRec;
  e : integer;
begin
  if not Assigned(List) then
    List := TStringList.Create
  else
    List.Clear;
  e := FindFirst(EventFileName + '*', faAnyFile, sr);
  while (e = 0) do begin
    if (sr.Name <> '.') and (sr.Name <> '..') then begin
      List.Add(EventFileName + sr.Name);
    end;
    e := FindNext(sr);
  end;
  FindClose(sr);
end; //EventFileList

end.
