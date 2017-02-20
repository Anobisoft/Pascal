uses crt, dos;

const major : array [0..6] of byte = (0, 2, 4, 5, 7, 9, 11);
      minor : array [0..6] of byte = (0, 2, 3, 5, 7, 8, 10);

var kbd, tmr : procedure;


{$F+}
procedure timer; interrupt;
begin
  music;
  inline($9C);
  tmr;
end;
{$F-}

function note(x : byte): word;
begin
  note := round(220*exp( ln(2) / 12 * x))
end;


procedure music;
begin
  inc(mscind);
  if mscind = 1024 then mscind := 0;
  if melody[mscind div 64, mscind mod 64] = 0 then nosound
  else sound(note(melody[mscind div 64, mscind mod 64]));
end;

function loadmelody : boolean;
var f     : text;
    chtmp : char;
    tmpn  : byte;
    i     : word;
begin
  {$I-}
  assign(f, 'mario.txt');
  reset(f);
  for i := 1023 downto 0 do melody[i div 64, i mod 64] := 0;
  tmpn := 0;
  while not eof(f) do
  begin
    read(f, chtmp);
    if chtmp in ['0'..'9'] then tmpn := tmpn * 10 + ord(chtmp) - ord('0')
    else begin
           if (chtmp = #13) and not eof(f) then
             read(f, chtmp);
           if tmpn and 128 = 128 then
           begin
             melody[(i+2) div 64, (i+2) mod 64] := tmpn and 127;
             melody[(i+2) div 64, (i+3) mod 64] := tmpn and 127;
             melody[(i+3) div 64, (i+4) mod 64] := tmpn and 127;
             inc(i, 8);
             tmpn := 0;
           end else if tmpn = 0 then inc(i, 4)
                    else begin
                      melody[(i+0) div 64, (i+0) mod 64] := tmpn and 127;
                      melody[(i+1) div 64, (i+1) mod 64] := tmpn and 127;
                      melody[(i+2) div 64, (i+2) mod 64] := tmpn and 127;
                      inc(i, 4);
                      tmpn := 0;
                    end
         end;
  end;
  close(f);
  {$I+}
  if IOResult = 0 then loadmelody := true
  else loadmelody := false
end;

begin
  if loadmelody then
  begin
    getintvec($8,@tmr);
    setintvec($8,addr(timer));
    repeat until true;
    setintvec($8,addr(tmr));
    nosound;
  end;
end.