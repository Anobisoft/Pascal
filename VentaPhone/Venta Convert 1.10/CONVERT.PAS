uses crt, dos;

const framec = $71;
      titlec = $7F;

var f, fventa, fnew : text;

    ch              : char;
    s               : string;
    i               : byte;
    count           : longint;
    sr              : searchrec;

    lname, addr     : string;
    name, pname     : char;
    phone           : array [0..5] of char;

    scr             : array [0..1999] of word absolute $B800 : 0000;
    slength         : byte absolute s;
    llth, li, lp    : byte;
    wp              : real;

    tt              : longint;

procedure convert(var ss : string);
begin
  for i := 2 to ord(ss[0]) do
   if ss[i] in [#144..#159] then ss[i] := chr( ord(ss[i])+80 ) else {}
   if ss[i] in [#128..#143] then ss[i] := chr( ord(ss[i])+32 ) else {€}
   if ss[i] = #240 then ss[i] := #241 else {πρ}
   if ss[i] in [#0, #255] then ss[i] := #32
end;

procedure print(x, y : byte; ps : string; color : byte);
var i : byte;
    sl : byte absolute ps;
begin
  for i := 1 to sl do scr[x + y*80 + i - 82] := ord (ps[i]) + color shl 8;

end;



begin
findfirst('phone.txt', $3F, sr);
if doserror <> 0 then halt;
textmode(3);
for i := 1 to 78 do
begin
  scr[i + 80] := 205 + framec shl 8;
  scr[i+240] := 205 + framec shl 8;
  scr[i+160] := 176 + framec shl 8;
end;
print(36, 2, ' Progress ', titlec);
scr[80] := 201 + framec shl 8;
scr[240] := 200 + framec shl 8;
scr[160] := 186 + framec shl 8;
scr[159] := 187 + framec shl 8;
scr[319] := 188 + framec shl 8;
scr[239] := 186 + framec shl 8;
scr[161] := framec shl 8;
scr[238] := framec shl 8;
llth := 1;
assign(f, sr.name);
reset(f);
assign(fnew, 'newphone.txt');
rewrite(fnew);
assign(fventa, 'venta.txt');
rewrite(fventa);

repeat
  for i := 0 to 5 do read(f, phone[i]);
  lname := '';
  read(f, ch);
  inc(count, 7);
  repeat
    lname := lname + ch;
    read(f, ch);
    inc(count)
  until ch in [#0, #32, #255, #9];
  read(f, name);
  read(f, pname);
  inc(count, 2);
  repeat read(f, ch); inc(count) until not (ch in [#0, #32, #255, #9]);
  addr := ch;
  repeat
    read(f, ch);
    addr := addr + ch;
    inc(count);
    if ch in [#0, #32, #255, #9] then
    begin
      read(f, ch);
      inc(count);
      if ch in [#0, #32, #255, #9] then ch := #13
      else addr := addr + ch
    end
  until ch = #13;
  dec(addr[0]);
  convert(lname);
  convert(addr);
  repeat read(f, ch); inc(count) until (ch = #10) or eof(f);
  s := '"";"' + lname + '";"'
              + name + '";"'
              + pname + '";"";"";"";"'
              + phone + '";"'
              + phone + '";"'
              + addr  + '"';
  writeln(fventa, s);
  s := phone + ' ' + lname + ' ' + name + pname + ' ' + addr;
  writeln(fnew, s);

  print(1, 1, s, $0F);
  for i := slength to llth-1 do scr[i] := 0;
  llth := slength; {}

  wp := count/sr.size;
  i := round(wp*76);
  if (i = 0) or (i = li) then
  else begin
    scr[i+161] := 219 + framec shl 8;
    li := i
  end;
  i := round(wp*100);
  if i = lp then
  else begin
    str(i, s);
    print(38 - slength div 2, 4, ' ['+s+'%] ', titlec);
    lp := i
  end;
  str(tt, s);
  print(1, 6, 'Time: ' + s, titlec);
until eof(f);
close(fventa);
close(fnew);
close(f);

end.