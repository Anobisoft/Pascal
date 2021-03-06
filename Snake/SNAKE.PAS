uses crt, graph;
const fnames : array [1..5] of string[8] =
('wall', 'flower', 'cherry', 'mushroom', 'icecream');
var gd, gm : integer;
    pm     : byte;
    key_   : char;
    mm     : array [1..5] of pointer;
    body   : pointer;
    score  : word;
    win    : boolean;
    tt     : longint absolute $40:$6C;
    oldt   : longint;

function loader(s: string): pointer; {�㭪�� ����㧪� ���⨭�� �� 䠩��}
var
  sz: longint;
   f: file;
   b: pointer;
Begin
    assign(f,s); {�����砥� 䠩����� ��६����� ��� 䠩�� � ���⨭���}
    reset(f,1); {����⨥ 䠩�� ��� �⥭��}
    sz:=filesize(f); {ࠧ��� 䠩��}
    getmem(b, sz); {�뤥����� �����}
    blockread(f,b^,sz); {�⥭�� �ᥣ� 䠩��}
    close(f); {�����⨥ 䠩��}
    loader:=b; {��� ������ �� �㭪樨 ���� � ����� ���⨭��}
end;

procedure menu;  {��楤�� �롮� �㭪� ����}
const pmnames : array [0..2] of string = ('game', 'help', 'exit');
var i : byte;
begin
  cleardevice; {���⪠ ��࠭�}
  settextjustify(1, 1); {��ࠢ������� �� 業���}
  settextstyle(4, 0, 8);
  setcolor(12);
  outtextxy(320, 120, 'Menu');
  settextstyle(4, 0, 4);
  setcolor(15);
  for i := 0 to 2 do outtextxy(320, 200 + i*40, pmnames[i]); {�뢮� ��� �㭪⮢ �� ��࠭}
  repeat
    setcolor(10);
    outtextxy(320, 200 + pm*40, pmnames[pm]); {�뢮� �㭪� ���� ����祭���� ����஬ ������ 梥⮬ (����⪠)}
    key_ := readkey;
    if key_ = #0 then {�᫨ ������ ��५��}
    begin
      key_ := readkey; {�⥭�� ���� ��५��}
      setcolor(15);
      outtextxy(320, 200 + pm*40, pmnames[pm]);  {�뢮� �㭪� ���� ����祭���� ����஬ ���� 梥⮬ (��⨥ ����⪨)}
      case key_ of
        #72 : if pm <> 0 then dec(pm); {������ ����� - pm 㬥��蠥� �� 1}
        #80 : if pm <> 2 then inc(pm); {������ ���� - pm 㢥��稢��� �� 1}
      end;
    end else if key_ = #27 then {�᫨ "Escape"}
             begin
               pm := 2;
               key_ := #13; {��� ��室� �� 横��}
             end;
  until key_ = #13;
  cleardevice; {���⪠ ��࠭�}
end;

procedure game; {��楤�� ����}
type coord       = record x, y : byte end;
 var map         : array [0..23, 0..23] of byte;
     i, j        : byte;
     key         : char;
     snake       : array [0..1023] of coord;
     head        : record
                     lth : byte;
                     vecx, vecy : shortint;
                   end;
    s            : string;
    tempx, tempy : byte;

   procedure initmap; {���樠������ �����}
   var i, j : byte;
   begin
      for j := 0 to 23 do
       for i := 0 to 23 do map[i, j] := 0; {���㫥��� ���ᨢ�}
      for i := 0 to 23 do begin   {���⠭���� � �뢮� �⥭��}
        putimage(i*20, 0, mm[1]^, 0); {�뢮� ���孥�}
        putimage(0, i*20, mm[1]^, 0); {�뢮� �����}
        putimage(i*20, 460, mm[1]^, 0); {�뢮� ������}
        putimage(460, i*20, mm[1]^, 0); {�뢮� �ࠢ��}
        map[i,  0] := 1; {������}
        map[i, 23] := 1; {������}
        map[0,  i] := 1; {�����}
        map[23, i] := 1; {�ࠢ��}
      end;
      for i := 1 to 30 do        {��砩��� ���⠭���� � �뢮� �� ��࠭ �९���⢨� � ����ᮢ}
      begin
        repeat
          tempx := random(20) + 2; {��砩��� ���न��� �� x}
          tempy := random(20) + 2; {��砩��� ���न��� �� y}
        until map[tempx, tempy] = 0;
        map[tempx, tempy] := 1;  {�९���⢨� � ���ᨢ}
        putimage(tempx*20, tempy*20, mm[1]^, 0); {�뢮� �९���⢨�}
        repeat
          tempx := random(20) + 2; {��砩��� ���न��� �� x}
          tempy := random(20) + 2; {��砩��� ���न��� �� y}
        until map[tempx, tempy] = 0;
        map[tempx, tempy] := random(4)+2; {��砩�� ����� � ���ᨢ}
        putimage(tempx*20, tempy*20, mm[map[tempx, tempy]]^, 0); {�뢮� �����}
      end;
   end; {����� initmap}

   procedure initsnake;
   var i : byte;
   begin
     head.vecx := 1; {��ࢮ��砫쭮� ���ࠢ����� �� x}
     head.vecy := 0; {��ࢮ��砫쭮� ���ࠢ����� �� y}
     head.lth := 2; {��ࢮ��砫쭠� ����� ����}
     score := 0;
     for i := 0 to head.lth do  {��ࢮ��砫�� ���न���� }
     begin
       snake[i].x := 3-i;
       snake[i].y := 1;
       map[snake[i].x, snake[i].y] := 1; {��� �஢�ન �� �१���� � ᠬ� ᥡ�}
       putimage(snake[i].x*20, snake[i].y*20, body^, normalput); {�뢮�}
     end;
     oldt := tt;
   end; {����� initsnake}

   procedure snakehead; {������ ������ - ��������� ���ࠢ�����}
   begin
     key := readkey;
     if key = #0 then
     begin
       key := readkey;
       case key of
         #77 : if head.vecx = 0 then {��ࠢ�}
               begin
                 head.vecx := 1;
                 head.vecy := 0;
               end;
         #75 : if head.vecx = 0 then {�����}
               begin
                 head.vecx := -1;
                 head.vecy := 0;
               end;
         #80 : if head.vecy = 0 then {����}
               begin
                 head.vecx := 0;
                 head.vecy := 1;
               end;
         #72 : if head.vecy = 0 then {�����}
               begin
                 head.vecx := 0;
                 head.vecy := -1;
               end;
       end;
     end;
   end;

   procedure GameOver(message : string);
   begin
     cleardevice;
     settextjustify(1, 1);
     settextstyle(4, 0, 8);
     setcolor(4);
     outtextxy(320, 210, message);
     setcolor(4);
     settextstyle(0, 0, 2);
     outtextxy(320, 300, '��� �窨: '+s);
     setcolor(15);
     settextstyle(0, 0, 1);
     outtextxy(320, 460, '������ "Escape"');
     repeat key := readkey until key = #27;
   end;

   procedure movesnake; {��।������� ������}
   var i : byte;
   begin
     if map[snake[0].x+head.vecx, snake[0].y+head.vecy] = 1 then GameOver('Game over')
     else begin
            if map[snake[0].x+head.vecx, snake[0].y+head.vecy] = 0 then
            begin
              putimage(snake[head.lth].x*20, snake[head.lth].y*20, body^, xorput);
              map[snake[head.lth].x, snake[head.lth].y] := 0;
            end else inc(head.lth);
            for i := 1 to head.lth do
            snake[head.lth - i + 1] := snake[head.lth - i];
            inc(snake[0].x, head.vecx);
            inc(snake[0].y, head.vecy);
            if map[snake[0].x, snake[0].y] <> 0 then
            begin
              putimage(snake[0].x*20, snake[0].y*20, mm[map[snake[0].x, snake[0].y]]^, xorput);
              inc(score, 10);
              setcolor(0);
              outtextxy(500, 10, s);
              str(score, s);
              setcolor(10);
              outtextxy(500, 10, s);
              repeat
                tempx := random(20) + 2; {��砩��� ���न��� �� x}
                tempy := random(20) + 2; {��砩��� ���न��� �� y}
              until (map[tempx, tempy] = 0) and not
                    ((tempy = snake[0].y) and (tempx = snake[0].x));
              map[tempx, tempy] := random(4)+2; {��砩�� ����� � ���ᨢ}
              putimage(tempx*20, tempy*20, mm[map[tempx, tempy]]^, 0); {�뢮� �����}
            end;
            map[snake[0].x, snake[0].y] := 1;
            putimage(snake[0].x*20, snake[0].y*20, body^, 0);
          end;
   end;

begin
  initmap;
  initsnake;
  key := #0;
  settextstyle(0, 0, 2);
  settextjustify(0, 2);
  repeat
    if keypressed then snakehead; {�᫨ ����� ������}
    movesnake;
    repeat until tt >= oldt + 10;
    oldt := tt;

(*  win := true;
    for j := 0 to 23 do
    for i := 0 to 23 do if map[i, j] in [2..5] then win := false; {�஢�ઠ �� ����稥 ����ᮢ}
    if win then gameover('Congratulations!');  (*)
  until key = #27;
end;

procedure help; {��楤�� �뢮�� ����� �� ��࠭}
var f : text;
    s : string;
    i : byte;
begin
  assign(f, 'help.txt'); {�����砥� 䠩����� ��६����� ��� 䠩�� �����}
  setcolor(15);
  settextjustify(0, 0);
  settextstyle(0, 0, 1);
  {$I-}
  reset(f); {���뢠�� 䠩� ��� �⥭��}
  {$I-}
  if ioresult = 0 then {�᫨ �訡�� �� ����⨨ 䠩�� ���}
  begin
    i := 0;
    while not eof(f) do {���� �� ����� 䠩��}
    begin
      inc(i);
      readln(f, s); {�⥭�� ��ப� �� 䠩�� � ��६����� s}
      outtextxy(10, i*10, s); {�뢮� ��ப� s}
    end;
    close(f); {�����⨥ 䠩��}
  end else outtextxy(10, 10, '�訡��: ���� ����� �� ������.');
  outtextxy(10, 470, '������ "����" ("Enter")');
  repeat key_ := readkey until key_ = #13; {横� �⥭�� ������� ���� �� ����� "Enter"}
end;

procedure init;
var i : byte;
begin
  for i := 1 to 5 do mm[i] := loader(fnames[i]);
  body := loader('body');
  randomize;
  initgraph(gd, gm, '');
end;

begin
  init;
  repeat
    menu;
    case pm of {�롮� ����⢨� � ����ᨬ��� �� �㭪� ����}
      0 : game;
      1 : help;
      2 : key_ := #27; {��� ��室� �� 横��}
    end;
  until key_ = #27;
  closegraph;
end.