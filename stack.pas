unit Stack;

{$mode objfpc}{$H+}

interface

function Pop: word;
procedure Push(v: word);

implementation

var WordStack: array of word;
  Current: word = 0;

procedure Init;
begin
  if Current>=length(WordStack) then
    setlength(WordStack, length(WordStack)+100);
end;

function Pop: word;
begin
  Pop := 0;
  if Current<>0 then
  begin
    dec(Current);
    Pop := WordStack[Current];
  end;
end;

procedure Push(v: word);
begin
  Init;
  WordStack[Current] := v;
  inc(Current);
end;

end.

