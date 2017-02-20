{unit interfc;{}

{interface


implementation{}
uses crt;


type

position = (LeftTop, CenterTop, RightTop)

progress = object
             length : byte;
             pos    :
           end;


const framec = $7100;
      titlec = $7F00;

var i               : word;
    count           : longint;
    scr             : array [0..1999] of word absolute $B800 : 0000;
    oldpercent      : byte;
    part            : real;


procedure print(x, y : byte; ps : string; color : word);
var i : byte;
    sl : byte absolute ps;
begin
  for i := 1 to sl do scr[x + y*80 + i - 1] := ord (ps[i]) + color;
end;

procedure printpercent(x, y : byte; part : real);
var i  : byte;
    s  : string;
    sl : byte absolute s;
begin
  i := trunc(part*100);
  if i = oldpercent then
  else begin
    str(i, s);
    print(x - sl, y, ' ['+s+'%] ', titlec);
    oldpercent := i
  end
end;


procedure initprogress(l : byte; title : string);
var ltitle : byte absolute title;
    x, y   : byte;
begin
  x := (80 - l) div 2;
  y := 10;
  for i := 1 to l do
  begin
    scr[i + 000 + x + y * 80] := 205 + framec;
    scr[i + 080 + x + y * 80] := framec;
    scr[i + 240 + x + y * 80] := 205 + framec;
    scr[i + 160 + x + y * 80] := 176 + framec;
  end;
  print((l - ltitle) div 2 + x + 1, y, title, titlec);
  scr[000 + x + y * 80] := 201 + framec;
  scr[240 + x + y * 80] := 200 + framec;
  scr[080 + x + y * 80] := 186 + framec;
  scr[160 + x + y * 80] := 186 + framec;

  scr[001 + x + y * 80 + l] := 187 + framec;
  scr[241 + x + y * 80 + l] := 188 + framec;
  scr[081 + x + y * 80 + l] := 186 + framec;
  scr[161 + x + y * 80 + l] := 186 + framec;
  scr[161 + x + y * 80] := framec;
  scr[160 + x + y * 80 + l] := framec;
end;

begin
  textmode(3);
  oldpercent := $FF;
  initprogress(60, ' loading file ');
  for i := 1 to 7841 do
  begin
    part := i/7841;
    printpercent(62, 13, part);
  end;
end.