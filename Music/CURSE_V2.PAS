{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
uses crt, dos;

const delayc1 = 30;
      delayc2 = 20;
      delayw1 = 1;
      delayw2 = 100;
      pausech = #23;   
      ctrlch  = '■';

      rlc    : array [0..15] of byte = (0, 1, 2, 3, 4, 5, 20, 7, 56, 57, 58, 59, 60, 61, 62, 63);


type rgb = record r, g, b : byte end;

var vmem                     : array [1..25, 1..80] of record
                                                         ch: char;
                                                         cl: byte;
                                                       end absolute $B800:0;
    kbd, tmr                 : procedure;
    reg                      : registers;
    palsv                    : array [0..15] of rgb;
    fname                    : string[12];
    txt                      : file of char;
    sclock, ctrlbc           : longint;
    countbuf                 : word;
    bufc                     : array [0..255] of char;
    bufw                     : array [0..100] of word;
    ox, oy                   : real;
    mx, my                   : word;
    pcx, pcy, pwx, pwy       : byte;
    filled, esc, click       : boolean;
    top, ctrl, cbufc, qw, qr : byte;
    opt                      : array [0..7] of record
                                                 speed : byte;
                                                 work  : boolean;
                                                 title : string;
                                               end;
    mscind                   : word;
    melody                   : array [0..15, 0..63] of byte;
    title                    : string;
    runi                     : word;

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

procedure printstr(x, y : byte; s : string);
var i : byte;
begin
  for i := 1 to ord(s[0]) do vmem[y, x+i-1].ch := s[i];
end;

procedure printw(x, y : byte; w : word);
var i : byte;
begin
  i := 0;
  vmem[y, x].ch := '0';
  while w <> 0 do
  begin
    vmem[y, x-i].ch := chr(w mod 10 + 48);
    w := w div 10;
    inc(i);
  end;
end;

procedure setctrlcol;
var i : byte;
begin
  for i := 43 to 78 do vmem[15+ctrl, i].cl := vmem[15+ctrl, i].cl xor 1;
end;

procedure printspd(speed : byte);
begin
   printstr(50, 23, ' ');
   printw(51, 23, speed);
   printstr(53, 23, '(   %)');
   printw(56, 23, (speed-1)*100 div 35);
end;

procedure printinfo;
var i : byte;
begin
 with opt[ctrl] do
 begin
   for i := 1 to ord(title[0]) do vmem[22, 42+i].ch := title[i];
   if ctrl < 4 then printstr(43, 23, 'qtime:')
   else printstr(43, 23, 'speed:');
   printspd(speed);
   if work then printstr(60, 23, 'Enable ')
   else printstr(60, 23, 'Disable');
 end;
end;

procedure ctrlmv(x : byte);
begin
  setctrlcol;
  ctrl := x;
  setctrlcol;
  ctrlbc := 0;
  printinfo;
end;

procedure right;
begin
  with opt[ctrl] do
   if speed <> 36 then
   begin
     inc(speed);
     vmem[ctrl+15, 42+speed].ch := ctrlch;
     printspd(speed);
   end;
end;

procedure left;
var i : byte;
begin
  with opt[ctrl] do
   if speed <> 1 then
   begin
     dec(speed);
     vmem[ctrl+15, 43+speed].ch := #32;
     printspd(speed);
   end
end;

procedure pause(x : byte);
begin
  with opt[x] do
  if work then work := false else work := true;
  vmem[x+15, 79].cl := vmem[x+15, 79].cl xor $B;
  printinfo;
end;

procedure printscreen;
var f    : text;
    i, j : byte;
begin
  assign(f, 'printscr.txt');
  rewrite(f);
  for j := 1 to 25 do
  begin
    write(f, #13#10);
    for i := 1 to 80 do write(f, vmem[j, i].ch);
  end;
end;

{$F+}
procedure keys; interrupt;
var key : byte;
const grey : byte = 0;
begin
    key := Port[$60];
    case key of
      $01 : esc := true;
      $4D : right;
      $4B : left;
      $48 : if ctrl <> 0 then ctrlmv(ctrl-1);
      $50 : if ctrl <> 6 then ctrlmv(ctrl+1);
      $39 : pause(ctrl);
      $32 : if opt[7].work then
            begin opt[7].work := false; nosound end
            else opt[7].work := true;
      $1C : printscreen;
    end;
  inline($9C);
  kbd;
end;
{$F-}

procedure getpal(c : byte; var p : rgb);
begin
  port[$3C7] := rlc[c];
  p.r := port[$3C9];
  p.g := port[$3C9];
  p.b := port[$3C9];
end;

procedure setrgb(c, r, g, b : byte);
begin
  port[$3C8] := rlc[c];
  port[$3C9] := r;
  port[$3C9] := g;
  port[$3C9] := b;
end;

procedure setpal(c : byte; p : rgb);
begin setrgb(c, p.r, p.g, p.b) end;

procedure savepal; var i : byte;
begin for i := 0 to 15 do getpal(i, palsv[i]) end;

procedure loadpal; var i : byte;
begin for i := 0 to 15 do setpal(i, palsv[i]) end;

function parafade(x : longint; max, t: byte; rr : real) : byte;
begin
  parafade := trunc( ( t*t - (x mod (2*t) - t)*(x mod (2*t) - t)*rr ) * max /t/t );
end;

procedure fading;
var tmp : rgb;
begin
  with opt[5] do if work then begin
    getpal(2, tmp);
    tmp.r := parafade(sclock, tmp.r, 36 - speed + 1, 1);
    tmp.g := parafade(sclock, tmp.g, 36 - speed + 1, 1);
    tmp.b := parafade(sclock, tmp.b, 36 - speed + 1, 1);
    setpal(3, tmp);
  end;
  getpal(cbufc, tmp);
  tmp.r := parafade(sclock, tmp.r, 9, 0.5);
  tmp.g := parafade(sclock, tmp.g, 9, 0.5);
  tmp.b := parafade(sclock, tmp.b, 9, 0.5);
  setpal(5, tmp);
  getpal(14, tmp);
  tmp.r := parafade(ctrlbc, tmp.r, 12, 0.4);
  tmp.g := parafade(ctrlbc, tmp.g, 12, 1);
  tmp.b := parafade(ctrlbc, tmp.b, 12, 0);
  setpal(6, tmp);
end;

procedure mouse;
var btx, bty : integer;
    i, j     : byte;
begin
  reg.ax := $3;
  intr($33, reg);
  vmem[my div 8+1, mx div 8+1].cl := vmem[my div 8+1, mx div 8+1].cl xor $7F;
  mx := reg.cx;
  my := reg.dx;
  vmem[my div 8+1, mx div 8+1].cl := vmem[my div 8+1, mx div 8+1].cl xor $7F;
  if (reg.bx and 1 = 1) then
  begin
    btx := mx div 8 - 41;
    bty := my div 8 - 14;
    if bty in [0..6] then
    if btx = 37 then
      if not click then begin click := true; ctrlmv(bty); pause(bty) end else
    else
    if btx in [1..36] then with opt[bty] do
    begin
      if bty <> ctrl then ctrlmv(bty) else ;
      if speed <> btx then
      begin
        for i := speed to btx-1 do vmem[bty+15, i+43].ch := ctrlch;
        for i := btx to speed-1 do vmem[bty+15, i+43].ch := #32;
        printspd(speed);
        speed := btx;
      end else ;
    end else ;
  end else click := false;
end;

procedure moveobj;
var x, y   : byte;
    dx, dy : real;
begin
 if sclock mod (10 - (opt[4].speed+3) div 4) = 0 then begin
  dx := mx - ox;
  dy := my - oy;
  if dx*dx+dy*dy <> 0 then
  begin
    y := trunc(oy / 8) +1;
    x := trunc(ox / 8) +1;
    vmem[y, x].cl := vmem[y, x].cl xor 16;
    ox := ox + 8*dx / sqrt(dx*dx + dy*dy);
    oy := oy + 8*dy / sqrt(dx*dx + dy*dy);
    y := trunc(oy / 8) +1;
    x := trunc(ox / 8) +1;
    vmem[y, x].cl := vmem[y, x].cl xor 16;
  end;
 end;
end;

procedure runstr;
var l : byte absolute title;
    i : byte;
begin
  if sclock mod (10 - (opt[6].speed+3) div 4) = 0 then
  begin
    inc(runi);
    for i := 1 to l do vmem[01, 19 + i].ch := title[(i+runi) mod l+1];
  end;
end;


{$F+}
procedure timer; interrupt;
begin
  inc(sclock);
  inc(ctrlbc);
  fading;
  mouse;
  if opt[4].work then moveobj;
  if opt[6].work then runstr;
  if opt[7].work then music;
  inline($9C);
  tmr;
end;
{$F-}

procedure init;
var author : string;
    i, j   : byte;
    w      : word;
begin
  textmode(3);
  for w := 0 to 1999 do mem[$B800:w*2] := 32;
  savepal;
  mscind := 0;
  setrgb(2, 31, 15, 63);
  title  := 'Курсовая работа по Операционным Системам. ';
  author := 'Плетнев С.А. группа ЗП-71';

  vmem[01, 01].ch := '╔';
  vmem[25, 01].ch := '╚';
  vmem[01, 80].ch := '╗';
  vmem[25, 80].ch := '╝';
  vmem[01, 18].ch := '╗';
  vmem[02, 18].ch := '╚';
  vmem[01, 63].ch := '╔';
  vmem[02, 63].ch := '╝';
  for i := 2 to 17 do begin
    vmem[01, i].ch := '═';
    vmem[01, 81-i].ch := '═';
  end;
  for i := 0 to ord(title[0])+1 do vmem[02, 19+i].ch := '═';
  for i := 1 to ord(title[0]) do begin
    vmem[01, 19 + i].cl := 2 + top;
  end;
  for i := 2 to 51 do vmem[25, i].ch := '═';
  vmem[25, 79].ch := '═';
  for i := 1 to ord(author[0]) do begin
    vmem[25, 52 + i].ch := author[i];
    vmem[25, 52 + i].cl := 2 + (top + 1) mod 2;
  end;
  for i := 2 to 24 do begin
    vmem[i, 01].ch := '║';
    vmem[i, 80].ch := '║';
  end;
  vmem[02, 42].ch := '╤';
  for i := 3 to 24 do vmem[i, 42].ch := '│';
  vmem[25, 42].ch := '╧';
  for i := 43 to 79 do vmem[14, i].ch := '─';
  vmem[14, 42].ch := '├';
  vmem[14, 80].ch := '╢';
  for i := 0 to 6 do
  with opt[i] do
  begin
    speed := 9 + random(18);
    work := true;
    for j := 1 to speed do vmem[15+i, j+42].ch := ctrlch;
    vmem[i+15, 79].cl := 0;
    vmem[i+15, 79].ch := pausech;
  end;
  opt[0].title := 'Чтение текста из файла в буфер ';
  opt[1].title := 'Вывод текста из буфера на экран';
  opt[2].title := 'Генерация полных квадратов     ';
  opt[3].title := 'Вывод полных квадратов на экран ';
  opt[4].title := 'Передвигающийся за мышкой объект';
  opt[5].title := 'Мерцание заголовка (или подписи)';
  opt[6].title := 'Бегущая строка (заголовок)      ';
  printinfo;
  with reg do begin
    ax := 0;
    intr($33, reg);
    ah:=$1;
    cx:=$2000;
    intr($10, reg);
  end;
  ox := 0;
  oy := 0;
  vmem[1, 1].cl := vmem[1, 1].cl xor $6F;
  for i := 43 to 78 do vmem[15+ctrl, i].cl := 6;
  printstr(43, 24, #18' - move, '#29' - speed, Space - pause');
end;

procedure rtfm;
var c : char;
begin
  writeln('Параметров слишком мало или они не верны');
  writeln;
  writeln('Пожалуйста,  запустите программу с двумя параметрами:');
  writeln('первый: вверху/внизу - расположение мерцающей надписи');
  writeln('второй: имя  текстового  файла  для  вывода  на экран');
  writeln;
  writeln('Sample (Пример): ');
  writeln('C:\Temp>start curse.exe top curse.pas');
  writeln;
  writeln('Press any key to exit... ');
  writeln('Нажмите любую клавишу для выхода... ');
  c := readkey; if c = #0 then readkey;
end;

procedure colbuf(x : byte);
var i : byte;
begin
   for i := 4 to 15 do vmem[2, x*62+i].cl := vmem[2, x*62+i].cl xor 2;
end;

procedure print_fb(x, y, bc, max : word);
var s : string[12];
    i : byte;
begin
  s  := 'buffer:    %';
  bc := bc * 100 div max;
  for i := 1 to 2 do
  begin
    s[12-i] := chr(bc mod 10+48);
    bc := bc div 10;
  end;
  if bc = 1 then s[9] := '1';
  printstr(x, y, s);
end;

procedure fillbuff;
var eti : longint;
      i : byte;
begin
 with opt[0] do
 if work then
 begin
   cbufc := 4;
   colbuf(0);
   eti := sclock + speed;
   repeat
     if eof(txt) then seek(txt, 0);
     read(txt, bufc[qw]);
     inc(qw);
     inc(countbuf);
     print_fb(4, 2, countbuf, 256);
     if qw = qr then filled := true;
     delay(delayc1);
   until (filled) or (eti < sclock) or not work or esc;
   colbuf(0);
 end;
end;

procedure scroll(x, y, xl, yl : byte);
var i, j : byte;
begin
  dec(yl);dec(xl);
  for j := 0 to yl do
  for i := 0 to xl do
    vmem[j+y, i+x].ch := vmem[j+y+1, i+x].ch;
  for i := 0 to xl do
    vmem[y+yl+1, i+x].ch := #32;
end;

procedure printbc(c : char);
begin
  if c = #13 then else
  if c = #10 then pcx := 38
  else begin vmem[pcy+3, pcx+3].ch := c; inc(pcx) end;
  if pcx = 38 then
  begin
    pcx := 0;
    if pcy = 21 then scroll(3, 3, 38, 21)
    else inc(pcy);
  end;
end;

procedure readbuff;
var eti : longint;
    i   : byte;
begin
 with opt[1] do
 if work then
 begin
   cbufc := 1;
   colbuf(0);
   eti := sclock + speed;
   filled := false;
   repeat
     printbc(bufc[qr]);
     inc(qr);
     dec(countbuf);
     print_fb(4, 2, countbuf, 256);
     delay(delayc2);
   until (qw = qr) or (eti < sclock) or not work;
   colbuf(0);
 end;
end;

procedure generate;
var eti  : longint;
    tmp  : word;
    i, t : byte;
begin
 with opt[2] do
 if work then
 begin
   cbufc := 4;
   colbuf(1);
   eti := sclock + speed;
   repeat
     tmp := random(65535);
     t := round(sqrt(tmp));
     if tmp = t*t then begin inc(bufw[0]); bufw[bufw[0]] := tmp end;
     print_fb(66, 2, bufw[0], 100);
     delay(delayw1);
   until (bufw[0] = 100) or (eti < sclock) or not work or esc;
   colbuf(1);
 end;
end;

procedure printbw(w : word);
var i, j : byte;
    s    : string[5];
begin
  i := 5;
  s := '     ';
  repeat
    s[i] := chr(w mod 10 + 48);
    dec(i);
    w := w div 10;
  until w = 0;
  printstr(44+pwx*6, 3+pwy, s);
  inc(pwx);
  if pwx = 6 then
  begin
    pwx := 0;
    if pwy = 10 then scroll(44, 3, 35, 10)
    else inc(pwy);
  end;
end;

procedure pushbuff;
var eti : longint;
      i : byte;
begin
 with opt[3] do
 if work then
 begin
   cbufc := 1;
   colbuf(1);
   eti := sclock + speed;
   repeat
     printbw(bufw[bufw[0]]);
     dec(bufw[0]);
     print_fb(66, 2, bufw[0], 100);
     delay(delayw2);
   until (bufw[0] = 0) or (eti < sclock) or not work;
   colbuf(1);
  end;
end;

function exit : boolean;
var i : byte;
begin
  exit := true;
  if not esc then for i := 0 to 7 do if opt[i].work then exit := false;
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

procedure main;
var query   : byte;
    tmprgb  : rgb;
begin
  randomize;
  opt[7].work := loadmelody;
  {$I-}
  assign(txt, fname);
  reset(txt);
  {$I+}
  if (IOResult = 0) and not eof(txt) then
  begin
    init;
    getintvec($8,@tmr);
    setintvec($8,addr(timer));
    getintvec($9,@kbd);
    setintvec($9,addr(keys));
    repeat
      query := random(4);
      case query of
        0 : if not filled then fillbuff else readbuff;
        1 : if filled or (qw <> qr) then readbuff else fillbuff;
        2 : if bufw[0] = 100 then pushbuff else generate;
        3 : if bufw[0] = 000 then generate else pushbuff;
      end;
    until exit;
    nosound;
    setintvec($9,addr(kbd));
    setintvec($8,addr(tmr));
    getpal(1, tmprgb);
    setpal(5, tmprgb);
    opt[1].work := true;
    opt[3].work := true;
    if filled or (qw <> qr) then readbuff;
    if bufw[0] <> 0 then pushbuff;
    close(txt);
    loadpal;
  end else begin writeln('Error: file "', paramstr(2), '" not exist.'); rtfm end;
end;

begin

{fname := 'mario.txt';
main;{}

  if paramcount = 2 then
  begin
    fname := paramstr(2);
    if paramstr(1) = 'top' then begin top := 1; main end
    else if paramstr(1) = 'bottom' then begin top := 0; main end
         else rtfm;
  end else rtfm; {}

end.

