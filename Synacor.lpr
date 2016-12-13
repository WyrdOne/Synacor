program Synacor;

uses Stack;

var Memory: array[0..32767] of word;
  Registers: array[32768..32775] of word;

procedure LoadCode;
var F: file;
begin
  assign(F, 'challenge.bin');
  reset(F);
  fillchar(Memory, sizeof(Memory), 0);
  fillchar(Registers, sizeof(Registers), 0);
  blockread(F, Memory, filesize(F));
  close(F);
end;

function GetValue(Instruction: integer): word;
begin
  if (Memory[Instruction]<32768) then
    GetValue := Memory[Instruction]
  else if (Memory[Instruction]<32776) then
    GetValue := Registers[Memory[Instruction]]
  else
  begin
    writeln('ERROR:  Invalid code @', Instruction);
    GetValue := 65535;
  end;
end;

procedure SetValue(Instruction: integer; value: word);
begin
  if (Memory[Instruction]<32768) then
    Memory[Instruction] := value
  else if (Memory[Instruction]<32776) then
    Registers[Memory[Instruction]] := value
  else
    writeln('ERROR:  Invalid code @', Instruction);
end;

procedure ExecuteCode;
var Instruction: integer;
  C: char;
begin
  Instruction := 0;
  while true do
  begin
    case Memory[Instruction] of
      0: exit; // Halt
      1: begin // Set <a> <b>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
          Registers[Memory[succ(Instruction)]] := GetValue(Instruction+2)
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 3);
      end;
      2: begin // push <a>
        StackPush(GetValue(succ(Instruction)));
        inc(Instruction, 2);
      end;
      3: begin // pop <a>
        if StackEmpty then
          writeln('ERROR:  Stack Empty @', Instruction);
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
          Registers[Memory[succ(Instruction)]] := StackPop
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 2);
      end;
      4: begin // eq <a> <b> <c>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          if GetValue(Instruction+2)=GetValue(Instruction+3) then
            Registers[Memory[succ(Instruction)]] := 1
          else
            Registers[Memory[succ(Instruction)]] := 0;
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      5: begin // gt <a> <b> <c>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          if GetValue(Instruction+2)>GetValue(Instruction+3) then
            Registers[Memory[succ(Instruction)]] := 1
          else
            Registers[Memory[succ(Instruction)]] := 0;
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      6: begin // jmp <a>
        Instruction := GetValue(succ(Instruction));
      end;
      7: begin // jt <a> <b>
        if GetValue(succ(Instruction))<>0 then
          Instruction := GetValue(Instruction+2)
        else
          inc(Instruction, 3);
      end;
      8: begin // jf <a> <b>
        if GetValue(succ(Instruction))=0 then
          Instruction := GetValue(Instruction+2)
        else
          inc(Instruction, 3);
      end;
      9: begin // add <a> <b> <c>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          Registers[Memory[succ(Instruction)]] := (GetValue(Instruction+2)+GetValue(Instruction+3)) mod 32768;
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      10: begin // mult <a> <b> <c>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          Registers[Memory[succ(Instruction)]] := (GetValue(Instruction+2)*GetValue(Instruction+3)) mod 32768;
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      11: begin // mod <a> <b> <c>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          Registers[Memory[succ(Instruction)]] := GetValue(Instruction+2) mod GetValue(Instruction+3);
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      12: begin // and <a> <b> <c>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          Registers[Memory[succ(Instruction)]] := GetValue(Instruction+2) and GetValue(Instruction+3);
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      13: begin // mod <a> <b> <c>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          Registers[Memory[succ(Instruction)]] := GetValue(Instruction+2) or GetValue(Instruction+3);
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      14: begin // not <a> <b>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          Registers[Memory[succ(Instruction)]] := (not GetValue(Instruction+2)) and $7FFF;
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 3);
      end;
      15: begin // rmem <a> <b>
        if (Memory[succ(Instruction)]>32767) and
           (Memory[succ(Instruction)]<32776) then
        begin
          Registers[Memory[succ(Instruction)]] := Memory[GetValue(Instruction+2)];
        end
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 4);
      end;
      16: begin // wmem <a> <b>
        SetValue(succ(Instruction), GetValue(Instruction+2));
        inc(Instruction, 3);
      end;
      17: begin // call <a>
        StackPush(Instruction+2);
        Instruction := GetValue(succ(Instruction));
      end;
      18: begin // ret
        Instruction := StackPop;
      end;
      19: begin // out <ascii>
        write(chr(GetValue(succ(Instruction))));
        inc(Instruction, 2);
      end;
      20: begin // in <a>
        read(c);
      end;
      21: inc(Instruction); // Noop
    end;
  end;
end;

begin
  LoadCode;
  ExecuteCode;
end.

