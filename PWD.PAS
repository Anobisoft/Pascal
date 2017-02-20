Uses crt, dos;

const defaultcode : byte = $4D;

var f, fout             : file;
    i, r                : byte;
    pwd                 : string;
    block               : array [1..256] of byte;
    ch                  : char;
    sr                  : searchrec;
    result              : word;
    scr                 : array [0..3999] of byte absolute $B800:0;

procedure print(x, y, col : byte; s : string);
begin
  for i := 1 to ord(s[0]) do begin
    scr[x*2 + y*160 - 164 + i*2] := ord(s[i]);
    scr[x*2 + y*160 - 163 + i*2] := col
  end
end;

procedure frame(x, y, xl, yl: byte; title : string; col : byte);
var i, j, lg, xx : byte;
begin
  lg := ord(title[0]);
  xx := xl div 2 - lg div 2 - 1;
  for i := 1 to xl+2 do
   for j := 1 to yl+2 do scr[x*2 + y*160 - 323 + i*2 + j*160] := col;

 for i := 1 to lg do
 scr [x*2 + y*160 + i*2 - 160 + xx*2] := ord(title[i]);

  for i := 1 to xx do scr[x*2 + y*160 - 162 + i*2] := 205;
  for i := xx + lg + 3 to xl do scr[x*2 + y*160 - 162 + i*2] := 205;

  for i := 1 to xl do scr[x*2 + y*160 - 2 + i*2 + yl*160] := 205;

  for i := 1 to yl do scr[x*2 + y*160 - 162 + i*160] := 186;
  for i := 1 to yl do scr[x*2 + y*160 - 160 + i*160 + xl*2] := 186;

  scr[x*2 + y*160 - 162] := 201;
  scr[x*2 + y*160 + yl*160 - 2] := 200;
  scr[x*2 + y*160 + xl*2 - 160] := 187;
  scr[x*2 + y*160 + xl*2 + yl*160] := 188
end;

function readpwd(x, y, l, col: byte) : boolean;
begin
  readpwd := false;
  textmode(3);
  frame(x, y, l, 1, 'Enter password', col);
  gotoxy(x + 1, y + 1);
  repeat
    ch := readkey;
    if ch = #0 then ch := readkey else
    case ch of
      '0'..'9', 'a'..'z', 'A'..'Z' : if pwd[0] <> chr(l-1) then
                                     begin pwd := ch + pwd;
                                       print(wherex, wherey, col, '*');
                                       gotoxy(wherex + 1, wherey)
                                     end;
      #08 : if pwd[0] <> #0 then begin
              gotoxy(wherex - 1, wherey);
              print(wherex, wherey, col, ' ');
              delete(pwd, 1, 1)
            end;
      #27 : readpwd := true;
      #13 : if pwd[0] = #0 then readpwd := true
    end
  until (ch = #13) or (ch = #27);
end;



begin
  if paramcount <> 1 then begin write('Error!');halt end;
  if readpwd(1, 1, 78, 31) then halt;
  findfirst(paramstr(1), anyfile, sr);
  assign(f, sr.name);
  reset(f, 1);
  assign(fout, 'temp.tmp');
  rewrite(fout, 1);

  for i := 1 to ord(pwd[0]) do
   if i mod 2 = 0 then pwd[i] := chr( ord(pwd[i]) + defaultcode - i mod 3)
   else pwd[i] := chr( ord(pwd[i]) - defaultcode + i mod 3);

  repeat
    blockread(f, block, ord(pwd[0]), result);
    for i := 1 to result do begin
      block[i] := block[i] xor ord(pwd[i]) xor i;
      blockwrite(fout, block[i], 1)
    end
  until result < ord(pwd[0]);
  close(f);
  close(fout);
  erase(f);
  rename(fout, sr.name)
end.


206 Î

     205
201 ÉÍÍÍ» 187
186 º203º
    ÌÍËÍ¹ 185
204 ÌÍÎÍ¹ 185
200 ÈÍÊÍ¼ 188
     202
