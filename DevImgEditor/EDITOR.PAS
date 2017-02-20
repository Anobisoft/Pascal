uses crt, dos, graph, drivers, manager;

const tools : array [0..4] of string[5] = ('Pixel', 'Line', 'Bar', 'Clear', 'Exit');

type timage = ^trec;
     trec = record
              nxt : timage;
              str : pointer
            end;

var i, j, x, y, currentcolor   : byte;
    grresult, gdrv, gmode      : integer;
    key                        : char;
    ms                         : tevent;
    firstcolor, secondcolor    : byte;
    width, height, widthx      : byte;
    image                      : timage;
    strseg, strofs             : word;
    driver                     : pointer;
    f                          : file;
    currenttool                : byte;
    firstXYok, mclick          : boolean;
    firstx, firsty             : byte;
    tt                         : longint absolute $40:$6C;

{помещает в переменные strseg и strofs сегмент и смещение (адрес) строки под номером указанном в параметре}
procedure getsegofs(y : byte);
var p : timage;
    i : byte;
begin
  p := image;
  for i := 1 to y do p := p^.nxt;
  strseg := seg(p^.str^);
  strofs := ofs(p^.str^)
end;

{высвобождает память от картинки}
procedure freeimage;
var p : timage;
begin
  while image <> nil do begin
    freemem(image^.str, widthx);
    p := image^.nxt;
    dispose(image);
    image := p
  end
end;

{выводит на экран интерфейс редактора}
procedure printinterface;
var i, j : byte;
    p    : timage;
begin
  setfillstyle(1, 8);
  bar(568, 418, 569+width, 419+height);
  if image <> nil then
  for j := 0 to height-1 do
  begin
    getsegofs(j);
    for i := 0 to widthx-1 do
    begin
      putpixel(i*16, j*8, 8);
      putpixel(i*2+569, j+419, mem[strseg:strofs+i] and $0F);
      setfillstyle(1, mem[strseg:strofs+i] and $0F);
      bar(i*16+1, j*8+1, i*16+7, j*8+7);
      if (width mod 2 = 0) or (i <> widthx-1) then
      begin
        putpixel(i*2+570, j+419, mem[strseg:strofs+i] and $F0 shr 4);
        setfillstyle(1, mem[strseg:strofs+i] and $F0 shr 4);
        bar(i*16+9, j*8+1, i*16+15, j*8+7);
        putpixel(i*16+8, j*8, 8)
      end
    end
  end;            
  setfillstyle(4, 8);
  bar(616, 0, 639, 23);
  setfillstyle(1, 0);
  bar(617, 1, 638, 22);
  for currentcolor := 1 to 15 do
  begin
    setfillstyle(1, currentcolor);
    bar(616, currentcolor*24, 639, currentcolor*24+23)
  end;
  setfillstyle(1, firstcolor);
  bar(574, 388, 597, 411);
  setfillstyle(1, secondcolor);
  bar(604, 388, 627, 411);
  setcolor(15);
  line(width*8, 0, width*8, height*8);
  line(0, height*8, width*8, height*8);
  line(0, 0, width*8, 0);
  line(0, 0, 0, height*8);
  outtextxy(568, 8, 'F1');
  outtextxy(568, 48, 'F2');
  outtextxy(568, 88, 'F3');
  outtextxy(568, 128, 'F4');
  outtextxy(568, 168, 'F5');
  setcolor(9);
  outtextxy(568, 56, 'Save');
  outtextxy(568, 16, 'Help');
  outtextxy(568, 96, 'Load');
  outtextxy(568, 136, 'New');
  outtextxy(568, 176, 'SaveAs');
  for i := 0 to 4 do outtextxy(568, 248+i*16, tools[i]);
  setcolor(15);
  outtextxy(568, 248+currenttool*16, tools[currenttool])
end;


procedure restoregraphmode;
begin
  setgraphmode(gmode);
  printinterface;
  showmouse
end;


procedure help;
begin
  restorecrtmode;
  writeln('Ach Image Editor version 1.4');
  writeln('Copyright Dec 2004 by Ach incorpse');
  writeln;
  writeln('Keys: F1: This Help, F2: Save image, F3: Load image, F4: New image, F5: Save as');
  writeln('      "BackSpace": Turn image');
  writeln('      "Delete" (Manager): Delete fail');
  writeln;
  writeln('What''s new in the latest version');
  writeln('version 1.1');
  writeln('  [+] Added mouse second button function: second color');
  writeln('version 1.2');
  writeln('  [!] Image format changed');
  writeln('  [*] Interface corrected');
  writeln('  [+] Menu items added: Help, Save, Load, New');
  writeln('version 1.3');
  writeln('  [!] Now Ach Image Editor doesn''t need for egavga.bgi');
  writeln('  [+] Added Save as...');
  writeln('version 1.4');
  writeln('  [!] Image format changed: added identification code');
  writeln('  [!] Some bugs fixed');
  writeln('  [+] Added manager for loading and deleting images');
  writeln('  [+] New function "BackSpace": turn image');
  writeln('Enjoy it :)');
  writeln;
  write('Press any key to continue...');
  key := readkey;
  if key = #0 then readkey else key := #255;
  restoregraphmode
end;


function cancelread(var ss : string) : boolean;
const s : string[12] = '';
var   key : char;
begin
  cancelread := false;
  s[0] := #0;
  repeat
    key := readkey;
    if key = #0 then key := readkey else
    case key of
      '0'..'9', 'a'..'z', 'A'..'Z' : if s[0] = chr(8) then else
                                     begin
                                       s := s + key;
                                       write(key)
                                     end;
      #08 : if s[0] = #0 then else begin
              gotoxy(wherex - 1, wherey);
              scr[wherex*2 + wherey*160-162] := 0;
              dec(s[0])
            end;
      #27 : cancelread := true;
      #13 : if s[0] = #0 then cancelread := true else ss := s;
    end
  until (key = #13) or (key = #27);
end;


procedure saveimage;
var p : timage;
begin
  if selected = '' then
  begin
    restorecrtmode;
    getdir(0, curdir);
    writeln('Current Directory: ', curdir);
    writeln('For changing current directory start manager (F3)');
    writeln;
    write('Enter file name (max 8 chars): ');
    if cancelread(selected) then selected := cancelled
    else selected := selected + '.ach';
    restoregraphmode
  end;
  if selected = cancelled then selected := ''
  else begin
    assign(f, selected);
    rewrite(f, 1);
    blockwrite(f, sign, 2);
    blockwrite(f, width, 1);
    blockwrite(f, height, 1);
    p := image;
    for j := 0 to height-1 do begin
      blockwrite(f, p^.str^, widthx);
      p := p^.nxt
    end
  end
end;


procedure loadimage;
var oldfname : string;
    p        : timage;
begin
  restorecrtmode;
  oldfname := selected;
  manage;
  if selected = cancelled then selected := oldfname
  else begin
    assign(f, selected);
    reset(f, 1);
    seek(f, 2);
    blockread(f, width, 1);
    blockread(f, height, 1);
    widthx := width div 2 + width mod 2;
    freeimage;
    if maxavail < widthx*height + height*sizeof(image) then
    begin
      closegraph;
      write('Not enough memory');
      halt
    end;
    for j := 0 to height-1 do begin
      p := image;
      new(image);
      image^.nxt := p;
      getmem(image^.str, widthx)
    end;
    p := image;
    for j := 0 to height-1 do begin
      blockread(f, p^.str^, widthx);
      p := p^.nxt
    end;
    close(f)
  end;
  restoregraphmode
end;


procedure newimage;
var i, j : byte;
    p    : timage;
    s    : string;
    code : integer;
begin
  restorecrtmode;
  repeat
    write('Enter image width  (max 70): ');
    readln(s);
    val(s, width, code)
  until (width < 71) and (width > 0);
  widthx := width div 2 + width mod 2;
  repeat
    write('Enter image height (max 60): ');
    readln(s);
    val(s, height, code)
  until (height < 61) and (height > 0);
  if maxavail < widthx*height + height*sizeof(image) then
  begin
    closegraph;
    write('Not enough memory');
    halt
  end;
  freeimage;
  for j := 1 to height do begin
    p := image;
    new(image);
    image^.nxt := p;
    getmem(image^.str, widthx);
    getsegofs(0);
    for i := 0 to widthx - 1 do mem[strseg:strofs+i] := 0
  end;
  selected := '';
  setgraphmode(gmode);
  printinterface;
  showmouse
end;


procedure turnimage;
var turned, p, q    : timage;
    s, o, sx, ox    : word;
begin
  turned := nil;
  widthx := height;
  height := width;
  width := widthx;
  widthx := width div 2 + width mod 2;
  for j := 0 to height-1 do begin
    p := turned;
    new(turned);
    turned^.nxt := p;
    getmem(turned^.str, widthx);
    s := seg(turned^.str^);
    o := ofs(turned^.str^);
    q := image;
    for i := 0 to widthx - 1 do
    begin
      sx := seg(q^.str^);
      ox := ofs(q^.str^);
      case j mod 2 of
        0 : mem[s:o+i] := mem[sx:ox+j div 2] and $0F;
        1 : mem[s:o+i] := mem[sx:ox+j div 2] shr 4
      end;
      q := q^.nxt;
      if q <> nil then
      begin
        sx := seg(q^.str^);
        ox := ofs(q^.str^);
        case j mod 2 of
          0 : inc(mem[s:o+i], mem[sx:ox+j div 2] and $0F shl 4);
          1 : inc(mem[s:o+i], mem[sx:ox+j div 2] and $F0)
        end;
        q := q^.nxt
      end
    end
  end;
  freeimage;
  image := turned;
  cleardevice;
  printinterface;
  showmouse
end;


procedure keyfunction;
begin
  key := readkey;
  if key = #0 then
  begin
    key := readkey;
    case key of
      #59 : help;
      #60 : if image <> nil then saveimage;
      #61 : loadimage;
      #62 : newimage;
      #63 : if image <> nil then begin selected := '';saveimage end
    end
  end else if key = #8 then turnimage {BackSpace}{#9 {Tab}
end;


procedure drawpixel(x, y : byte);
begin
  getsegofs(y);
  if x mod 2 = 0 then mem[strseg:strofs+x div 2] :=
                      mem[strseg:strofs+x div 2] and $F0 + currentcolor
  else mem[strseg:strofs+x div 2] :=
       mem[strseg:strofs+x div 2] and $0F + currentcolor shl 4;
  putpixel(x+569, y+419, currentcolor);
  setfillstyle(1, currentcolor);
  bar(x*8+1, y*8+1, x*8+7, y*8+7)
end;


procedure drawline;
var tg : real;
    i  : byte;
  procedure change;
  begin
    i := x;
    x := firstx;
    firstx := i;
    i := y;
    y := firsty;
    firsty := i
  end;
begin
  if abs(x - firstx) < abs(y - firsty) then
  begin
    if y < firsty then change;
    tg := (x - firstx)/(y - firsty);
    i := 0;
    repeat
      drawpixel(firstx + round(i * tg), firsty + round(i));
      inc(i)
    until i = y - firsty + 1
  end else
  begin
    if x < firstx then change;
    tg := (y - firsty)/(x - firstx);
    i := 0;
    repeat
      drawpixel(firstx + round(i), firsty + round(i * tg));
      inc(i)
    until i = x - firstx + 1
  end;
  setcolor(15);
  outtextxy(568, 264, 'Line');
  firstXYok := false
end;


procedure drawbar;
var i, j : byte;
begin
  if x < firstx then
  begin
    i := x;
    x := firstx;
    firstx := i
  end;
  if y < firsty then
  begin
    i := y;
    y := firsty;
    firsty := i
  end;
  for i := firstx to x do
  for j := firsty to y do drawpixel(i, j);
  setcolor(15);
  outtextxy(568, 280, 'Bar');
  firstXYok := false
end;


procedure clearimage;
var i, j : byte;
begin
  setfillstyle(1, 0);
  bar(1, 1, width*8-1, height*8-1);
  bar(569, 419, 568+width, 418+height);
  for j := 0 to height-1 do
  for i := 0 to widthx-1 do
  begin
    getsegofs(j);
    mem[strseg:strofs+i] := 0;
    putpixel(i*16, j*8, 8);
    putpixel(i*16+8, j*8, 8)
  end;
end;



procedure changetool(n : byte);
begin
  hidemouse;
  setcolor(9);
  outtextxy(568, 248+16*currenttool, tools[currenttool]);
  currenttool := n;
  setcolor(15);
  outtextxy(568, 248+16*currenttool, tools[currenttool]);
  showmouse
end;


procedure setfirstxy;
begin
  firstXYok := true;
  firstx := x;
  firsty := y;
  drawpixel(x, y);
  setcolor(12);
  outtextxy(568, 248 + currenttool*16, tools[currenttool])
end;


procedure mbuttonfunction;
begin
  hidemouse;
  if (x < width) and (y < height) then
  begin
    case ms.buttons of
      1 : currentcolor := firstcolor;
      2 : currentcolor := secondcolor;
      4 : currentcolor := 0
    end;
    case currenttool of
      0 : drawpixel(x, y);
      1 : if not firstXYok then setfirstxy
          else if not ((firstx = x) and (firsty = y)) then drawline;
      2 : if firstXYok then drawbar else setfirstxy
    end
  end else if (x > 76)and(y<49) then
      begin
        currentcolor := y div 3;
        setfillstyle(1, currentcolor);
        case ms.buttons of
          1 : begin
                firstcolor := currentcolor;
                bar(574, 388, 597, 411)
              end;
          2 : begin
                secondcolor := currentcolor;
                bar(604, 388, 627, 411)
              end
        end
      end else if x > 70 then
               case y of
                 01,02 : help;
                 06,07 : if image <> nil then saveimage;
                 11,12 : loadimage;
                 16,17 : newimage;
                 21,22 : if image <> nil then
                         begin
                           selected := '';
                           saveimage
                         end;
                 31 : if not firstXYok then changetool (0);
                 33 : if not firstXYok then changetool (1);
                 35 : if not firstXYok then changetool (2);
                 37 : if not firstXYok and (image <> nil) then clearimage;
                 39 : key := #27
               end;
  showmouse
end;


procedure vgadriver; external;
{$L egavga.obj}
begin
  if registerbgidriver(@vgadriver) < 0 then
    write('Error register driver: ' + grapherrormsg(graphresult))
  else begin
    gdrv := VGA;
    gmode := 2;
    initgraph(gdrv, gmode, '');
    grresult := graphresult;
    if grresult = 0 then
    begin
      printinterface;
      initevents;
      repeat
        getmouseevent(ms);
        x := ms.where.x;
        y := ms.where.y;
        if ms.buttons = 0 then mclick := true else mbuttonfunction;
        if keypressed then keyfunction
      until key = #27;
      closegraph
    end else write('Error initialization graphic: ' + grapherrormsg(grresult))
  end
end.