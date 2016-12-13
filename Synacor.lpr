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

procedure ExecuteCode;
var Instruction: integer;
begin
  Instruction := 0;
  while true do
  begin
    case Memory[Instruction] of
      0: exit; // Halt
      1: begin // Set <a> <b>
        if (Memory[succ(Instruction)]<32768) then
          Registers[Memory[succ(Instruction)]] := Memory[Instruction+2]
        else if (Memory[succ(Instruction)]<32776) then
          Registers[Memory[succ(Instruction)]] := Registers[Memory[Instruction+2]]
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 3);
      end;
      19: begin // out <ascii>
        if (Memory[succ(Instruction)]<32768) then
          write(chr(Memory[succ(Instruction)]))
        else if (Memory[succ(Instruction)]<32776) then
          write(chr(Registers[Memory[succ(Instruction)]]))
        else
          writeln('ERROR:  Invalid code @', Instruction);
        inc(Instruction, 2);
      end;
      21: inc(Instruction); // Noop
    end;
  end;
end;

begin
  LoadCode;
  ExecuteCode;
end.

