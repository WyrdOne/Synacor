unit Stack;

{$mode objfpc}{$H+}

interface

function StackEmpty: boolean;
function StackPop: word;
procedure StackPush(v: word);

implementation

var WordStack: array of word;
  Current: word = 0;

procedure Init;
begin
  if Current>=length(WordStack) then
    setlength(WordStack, length(WordStack)+100);
end;

function StackEmpty: boolean;
begin
  StackEmpty := Current=0;
end;

function StackPop: word;
begin
  StackPop := 0;
  if Current<>0 then
  begin
    dec(Current);
    StackPop := WordStack[Current];
  end;
end;

procedure StackPush(v: word);
begin
  Init;
  WordStack[Current] := v;
  inc(Current);
end;

end.

