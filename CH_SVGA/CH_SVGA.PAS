unit ch_svga;

interface
{****************************************************************************}
{Для модуля}
{****************************************************************************}
{Типы для SVGA модуля}
type TFont=array[0..255,0..15]of byte;
     PFont=^TFont;
type Bits=array[1..8]of byte;
{Типы для мышиного модуля}
type curarr=array[1..16,1..16]of byte;
type curmask=array[1..2,1..16]of word;
{Типы для моей мышки}
type cursor=record
             xh,yh:byte;
             cur:array[1..32,1..32]of byte;
            end;
type cursorarr=array[1..6]of cursor;
type Mouse=record
              x,y,wx,wy:integer;
              bs:byte;
              sost,wsost:byte;
             { p:pointer;}
            end;
type KeysArr=array[1..128]of boolean;
type TPalette=array[1..768]of byte;
type pcxheader=record
   manuf:byte;
   hard:byte;
   encod:byte;
   bitpx:byte;
   bx1:integer;
   y1:integer;
   x2:integer;
   y2:integer;
   hres:integer;
   vres:integer;
   clrma:array[1..48] of byte;
   vmode:byte;
   nplanes:byte;
   bplin:integer;
   palinfo:integer;
   shres:integer;
   svres:integer;
   xtra:array[1..54]of byte;
end;
{****************************************************************************}
{Константы графических и текстовых режимов}
const
      {Текстовые режимы}
      T40X25X1=$00;
      T40X25X16S=$01;
      T40X25X16=$02;
      T80X25X16=$03;
      {VGA}
      G640X480X2=$11;
      G640X480X16=$12;
      G320X200X256=$13;
      {SVGA}
      G640X400X256=$100;
      G640X480X256=$101;
      G800X600X16=$102;
      G800X600X256=$103;
      G1024X768X16=$104;
      G1024X768X256=$105;
      G1280X1024X16=$106;
      G1280X1024X256=$107;
      {Текстовые режимы высокого разрешения}
      T80X60t=$108;
      T132X25t=$109;
      T132X43t=$10A;
      T132X50t=$10B;
      T132X60t=$10C;
      {SVGA многоцветовые режимы}
      G320X200x32K=$10D;
      G320X200x64K=$10E;
      G320X200x16M=$10F;
      G640X480x32K=$110;
      G640X480x64K=$111;
      G640X480x16M=$112;
      G800X600X32K=$113;
      G800X600X64K=$114;
      G800X600X16M=$115;
      G1024X768X32K=$116;
      G1024X768X64K=$117;
      G1024X768X16M=$118;
      G1280X1024X32K=$119;
      G1280X1024X64K=$11A;
      G1280X1024X16M=$11B;
const
      StandGraph=G640X480X256;
      StandText=T80X25X16;
{****************************************************************************}
{Переменные графического модуля}
var WBank:integer;
    MaxX,MaxY,GrMode:word;
    MaxCol,MaxBank:byte;
    TextMode:boolean;
    CharXSize,CharYSize:byte;
{Переменные для моей мышки}
var cur,wcur,cn,cv,ci,cno,chd,cleft,cright,cup,cdown,cxsize,cysize:^cursor;
    cl,cs,czan:^cursorarr;
    mousedel:word;
    ms:Mouse;
    ictr:byte;
{Шрифт}
    Font:PFont;
    Key:^KeysArr;
    Oldint9:procedure;

procedure IGetKey;interrupt;
function KeyPush:boolean;{Аналог KeyPressed}
procedure WaitKey;{Аналог Readkey, но не возварщает номер клавиши}
procedure InitSVGA(ing:integer);{Процедура инициализации графического режима}
procedure CloseSVGA;{Процедура закрытия графического режима}
procedure putpixel(xpo,ypo:word;colorp:byte);{Путает пиксель на экран}
function getpixel(xpo,ypo:word):byte;{Гетает пиксель с экрана}
procedure bar(x1,y1,x2,y2:longint;colorp:byte);{Ресует Барчик}
procedure rectangle(x1,y1,x2,y2:word;colorp:byte);{Ресует прямоугольник}
function Sign(Number:integer):integer;{Возвращает знак числа}
Procedure Line_(x1,y1,x2,y2:integer;color:byte);{Рисует линию}
procedure Line(x1,y1,x2,y2:integer;col:byte);{Рисует линию}
procedure circle(xco,yco,rad:word;colorp:byte);{Рисует круг}
procedure SetPalette(colnom,rbr,gbr,bbr:byte);{Устанавливает палитру}
procedure GetPalette(colnom:byte;var rbr,gbr,bbr:byte);{Взять палитру}
procedure SavePalette(name:string);{Сохраняет палитру в файл}
procedure LoadPalette(name:string);{Читает палитру из файла}
procedure GetImage(x1,y1,x2,y2:word;var pt:pointer);{Гетает имедж}
procedure PutImagePP(xp,yp:word;pt:pointer;nviv,nvcol,curs:byte);{Путает имедж}
procedure PutImage(xp,yp:word;pt:pointer);{Путает имедж}
function ImageSize(x1,y1,x2,y2:word):word;{Возвращает размер имеджа области}
procedure ImageXYSize(pt:pointer;var xsize,ysize:word);{Возвращает размер области имеджа}
procedure SaveImage(name:string;x1,y1,x2,y2:word);{Сохраняет имедж в файл}
procedure LoadImage(name:string;var pt:pointer);{Читает имедж из файла}
procedure Octangle(x1,y1,x2,y2:word;colorp:byte);{Рисует восьмиугольник}
procedure ClearScreen(colorp:byte);{Очищает экран}
procedure BitsToByte(bbb:bits;var resul:byte);{Преобразует биты в байт}
procedure ByteToBits(resul:byte;var bbb:bits);{Преобразует байт в виты}
procedure LoadFont(name:string);{Загружает шрифт}
procedure OutChar(xco,yco,cnom:integer;col,fon,zat:byte);{Путает символ}
procedure OutStr(xc,yc:integer;st:string;ccol,cfon,czat:byte);{Путает строку}
procedure DOutStr(xc,yc:integer;st:string;ccol,cfon,czat:byte;del:word);{Путает строку с задержкой}
procedure TOutStr(x,y:integer;st:string;col,fon,meg:byte);{Путает строку в текстовом режиме}
procedure loadpcx(pname:string);{Загружает PCX}
procedure MouseTest(var onm,bc:byte);{Тест наличия мышки}
procedure ShowMouse;{Показать курсор}
procedure HideMouse;{Спрятать курсор}
function MouseX:integer;{Получить X координату}
function MouseY:integer;{Получить Y координату}
function MouseButtonStatus:byte;{Получить статус кнопок}
procedure MouseStatus(var xmouse,ymouse:integer;var mbs:byte);{Получить статус мышки}
procedure SetMouseCoords(nmx,nmy:integer);{Установить мышьку в точку X;Y}
procedure SetMouseMoveBar(xm1,ym1,xm2,ym2:integer);{Установить область перемещения мышьки}
procedure GetMouseStep(xco,yco:integer);{Возвращает шаг мышки}
procedure SetMouseStep(xco,yco:integer);{Устанавливает шаг мышки}
procedure MouseButtonPush(nb:integer;var tbs:byte;var pb,xm,ym:integer);{Нажали кнопку мыши}
procedure MouseButtonLet(nb:integer;var tbs:byte;var pb,xm,ym:integer);{Отпустили кнопку мыши}
procedure CurTrans(cur,mask:curarr;var ncur:curmask);{Конвертирует формат курсора}
procedure SetGraphCursor(xcp,ycp:integer;ncur:curmask);{Устанавливает графический курсор}
procedure loadcur(name:string;var curr:cursor);{Загружает курсор из файла}
procedure loadcurbase(cn1,cn2,cn3,cn4,cn5,cn6,cn7,cn8,cn9,cn10,cn11,
            cz1,cz2,cz3,cz4,cz5,cz6,cs1,cs2,cs3,cs4,cs5,cs6,cl1,cl2,cl3,cl4,cl5,cl6:string);
          {Загружает базу курсоров из файлов}
procedure PutCur(x,y:integer;curr:cursor);{Выводит курсор на экран}
procedure PPutCur(x,y:integer;curr:cursor);{Выводит курсор на экран}
procedure GetCur(x,y:integer;var curr1:cursor;curr2:cursor);{Читает курсор с экрана}
procedure MMove;{Отображает движение курсора}
procedure Ready;{Подготавливает модуль к работе}
procedure Finish;{Завершает работу модуля}
{****************************************************************************}

implementation

procedure IGetKey;
var pkey:byte;
begin
 pkey:=port[$60];
 if pkey<=$80 then key^[pkey]:=true else key^[pkey-$80]:=false;
 mem[$40:$1A]:=mem[$40:$1C];
 oldint9;
end;
{****************************************************************************}
function KeyPush:boolean;
var ikey:byte;
    flg:boolean;
begin
flg:=false;
for ikey:=1 to 128 do
  if key^[ikey]=true then flg:=true;
KeyPush:=flg;
end;
{****************************************************************************}
procedure WaitKey;
var ikey:byte;
    flg:boolean;
begin
flg:=false;
while flg=false do begin
for ikey:=1 to 128 do
  if key^[ikey]=true then flg:=true;
end;
end;
{****************************************************************************}
{----------------------------------------------------------------------------}
procedure ClearScreen(colorp:byte);
begin
asm
  mov dx,0
@rpt:
  mov ax,4f05h
  xor bx,bx
  int 10h
  mov ax,0A000h
  mov es,ax
  xor di,di
  mov al,colorp
  mov ah,colorp
  mov cx,$8000
  cld
  rep stosw
  cmp dx,word ptr maxbank
  je @eend
  inc dx
  jmp @rpt
@eend:
  mov ax,4f05h
  xor bx,bx
  mov dx,0
  mov wbank,0
  int 10h
end;

end;
{****************************************************************************}
procedure InitSVGA(ing:integer);
begin
if ing<$100 then
asm
  mov ah,0
  mov al,byte ptr ing
  int 10h
end;
if ing>=$100 then
asm
  mov ax,4f02h
  mov bx,ing
  int 10h
  mov ax,4f05h
  xor bx,bx
  int 10h
end;
grmode:=ing;
case grmode of
{TextMode}
  $000:begin maxx:=40;maxy:=25;maxcol:=1;TextMode:=true;MaxBank:=0;end;
  $001:begin maxx:=40;maxy:=25;maxcol:=16;TextMode:=true;MaxBank:=0;end;
  $002:begin maxx:=80;maxy:=25;maxcol:=16;TextMode:=true;MaxBank:=0;end;
  $003:begin maxx:=80;maxy:=25;maxcol:=16;TextMode:=true;MaxBank:=0;end;
{VGA}
  $011:begin maxx:=640;maxy:=480;maxcol:=2;TextMode:=false;MaxBank:=0;end;
  $012:begin maxx:=640;maxy:=480;maxcol:=16;TextMode:=false;MaxBank:=0;end;
  $013:begin maxx:=320;maxy:=200;maxcol:=255;TextMode:=false;MaxBank:=0;end;
{SVGA}
  $100:begin maxx:=640;maxy:=400;maxcol:=255;TextMode:=false;MaxBank:=3;end;
  $101:begin maxx:=640;maxy:=480;maxcol:=255;TextMode:=false;MaxBank:=4;end;
  $102:begin maxx:=800;maxy:=600;maxcol:=16;TextMode:=false;MaxBank:=3;end;
  $103:begin maxx:=800;maxy:=600;maxcol:=255;TextMode:=false;MaxBank:=7;end;
  $104:begin maxx:=1024;maxy:=768;maxcol:=16;TextMode:=false;MaxBank:=6;end;
  $105:begin maxx:=1024;maxy:=768;maxcol:=255;TextMode:=false;MaxBank:=16;end;
  $106:begin maxx:=1280;maxy:=1024;maxcol:=16;TextMode:=false;MaxBank:=10;end;
  $107:begin maxx:=1280;maxy:=1024;maxcol:=255;TextMode:=false;MaxBank:=20;end;
{TextMode}
  $008:begin maxx:=80;maxy:=60;maxcol:=16;TextMode:=true;MaxBank:=0;end;
  $009:begin maxx:=132;maxy:=25;maxcol:=16;TextMode:=true;MaxBank:=0;end;
  $00A:begin maxx:=132;maxy:=43;maxcol:=16;TextMode:=true;MaxBank:=0;end;
  $00B:begin maxx:=132;maxy:=50;maxcol:=16;TextMode:=true;MaxBank:=0;end;
  $00C:begin maxx:=132;maxy:=60;maxcol:=16;TextMode:=true;MaxBank:=0;end;
{SVGA}
  $10D:begin maxx:=320;maxy:=200;maxcol:=32{K};TextMode:=false;MaxBank:=0;end;
  $10E:begin maxx:=320;maxy:=200;maxcol:=64{K};TextMode:=false;MaxBank:=0;end;
  $10F:begin maxx:=320;maxy:=200;maxcol:=16{M};TextMode:=false;MaxBank:=0;end;
  $110:begin maxx:=640;maxy:=480;maxcol:=32{K};TextMode:=false;MaxBank:=0;end;
  $111:begin maxx:=640;maxy:=480;maxcol:=64{K};TextMode:=false;MaxBank:=0;end;
  $112:begin maxx:=640;maxy:=480;maxcol:=16{M};TextMode:=false;MaxBank:=0;end;
  $113:begin maxx:=800;maxy:=600;maxcol:=32{K};TextMode:=false;MaxBank:=0;end;
  $114:begin maxx:=800;maxy:=600;maxcol:=64{K};TextMode:=false;MaxBank:=0;end;
  $115:begin maxx:=800;maxy:=600;maxcol:=16{M};TextMode:=false;MaxBank:=0;end;
  $116:begin maxx:=1024;maxy:=768;maxcol:=32{K};TextMode:=false;MaxBank:=0;end;
  $117:begin maxx:=1024;maxy:=768;maxcol:=64{K};TextMode:=false;MaxBank:=0;end;
  $118:begin maxx:=1024;maxy:=768;maxcol:=16{M};TextMode:=false;MaxBank:=0;end;
  $119:begin maxx:=1280;maxy:=1024;maxcol:=32{K};TextMode:=false;MaxBank:=0;end;
  $11A:begin maxx:=1280;maxy:=1024;maxcol:=64{K};TextMode:=false;MaxBank:=0;end;
  $11B:begin maxx:=1280;maxy:=1024;maxcol:=16{M};TextMode:=false;MaxBank:=0;end;
end;
ClearScreen(0);
end;
{****************************************************************************}
procedure CloseSVGA;assembler;
asm
  mov ax,3
  int 10h
end;
{****************************************************************************}
procedure putpixel(xpo,ypo:word;colorp:byte);assembler;
asm
  mov ax,ypo
  mul maxx
  add ax,xpo
  adc dx,0
  mov di,ax
  cmp dx,wbank
  je @put
  mov wbank,dx
  mov ax,4f05h
  xor bx,bx  {xor dx,dx mov dl,bn}
  int 10h
@put:
  mov ax,0A000h
  mov es,ax
  mov al,colorp
  stosb
end;
{****************************************************************************}
function getpixel(xpo,ypo:word):byte;
var colorp:byte;
begin
asm
  mov ax,ypo
  mul maxx
  add ax,xpo
  adc dx,0
  mov di,ax
  cmp dx,wbank
  je @put
  mov wbank,dx
  mov ax,4f05h
  xor bx,bx
  int 10h
@put:
  mov ax,0A000h
  mov es,ax
  mov al,es:[di]
  mov colorp,al
end;
getpixel:=colorp;
end;
{****************************************************************************}
procedure bar(x1,y1,x2,y2:longint;colorp:byte);
var bank,i,j:integer;
begin
for j:=y1 to y2 do
  for i:=x1 to x2 do begin
    {PutPixel/}
    asm
      mov ax,j
      mul maxx
      add ax,i
      adc dx,0
      mov di,ax
      cmp dx,wbank
      je @put
      mov wbank,dx
      mov ax,4f05h
      xor bx,bx
      int 10h
    @put:
      mov ax,0A000h
      mov es,ax
      mov al,colorp
      stosb
    end;
    {/PutPixel}
  end;
end;
{****************************************************************************}
procedure rectangle(x1,y1,x2,y2:word;colorp:byte);
var bank,i:integer;
begin
for i:=x1 to x2 do begin
  {PutPixel/}
  asm
    mov ax,y1
    mul maxx
    add ax,i
    adc dx,0
    mov di,ax
    cmp dx,wbank
    je @put
    mov wbank,dx
    mov ax,4f05h
    xor bx,bx
    int 10h
  @put:
    mov ax,0A000h
    mov es,ax
    mov al,colorp
    stosb
  end;
  {/PutPixel}
end;
for i:=x1 to x2 do begin
  {PutPixel/}
  asm
    mov ax,y2
    mul maxx
    add ax,i
    adc dx,0
    mov di,ax
    cmp dx,wbank
    je @put
    mov wbank,dx
    mov ax,4f05h
    xor bx,bx
    int 10h
  @put:
    mov ax,0A000h
    mov es,ax
    mov al,colorp
    stosb
  end;
  {/PutPixel}
end;
for i:=y1 to y2 do begin
  {PutPixel/}
  asm
    mov ax,i
    mul maxx
    add ax,x1
    adc dx,0
    mov di,ax
    cmp dx,wbank
    je @put
    mov wbank,dx
    mov ax,4f05h
    xor bx,bx
    int 10h
  @put:
    mov ax,0A000h
    mov es,ax
    mov al,colorp
    stosb
  end;
  {/PutPixel}
end;
for i:=y1 to y2 do begin
  {PutPixel/}
  asm
    mov ax,i
    mul maxx
    add ax,x2
    adc dx,0
    mov di,ax
    cmp dx,wbank
    je @put
    mov wbank,dx
    mov ax,4f05h
    xor bx,bx
    int 10h
  @put:
    mov ax,0A000h
    mov es,ax
    mov al,colorp
    stosb
  end;
  {/PutPixel}
end;
end;
{****************************************************************************}
function Sign(Number : integer) : integer;
begin
     if Number < 0 then Sign := -1
     else if Number = 0 then Sign := 0
     else Sign := 1;
end;
{****************************************************************************}
Procedure Line_(x1,y1,x2,y2:integer;color:byte);
var
   x,y,s1,s2,dlx,dly,e,z,i:integer;
   change: boolean;
begin
   x := x1; y:=y1;
   dlx := Abs(x2-x1); dly := Abs(y2-y1);
   s1 := Sign(x2-x1); s2 := Sign(y2-y1);
   if dly > dlx then
   begin
        z  := dlx;
        dlx := dly;
        dly := z;
        change:=true;
   end
   else change:=false;
   e := 2 * dly - dlx;
   for i := 1 to dlx do
   begin
        {PutPIxel/}
        asm
          mov ax,y
          mul maxx
          add ax,x
          adc dx,0
          mov di,ax
          cmp dx,wbank
          je @put
          mov wbank,dx
          mov ax,4f05h
          xor bx,bx
          int 10h
        @put:
          mov ax,0A000h
          mov es,ax
          mov al,color
          stosb
        end;
        {/PutPixel}
while e >= 0 do
        begin
             if change then inc(x,s1)
             else inc(y,s2);
             dec(e,2 * dlx);
        end;
        if change then inc(y,s2)
        else inc(x,s1);
        inc(e,2 * dly);
   end;
   {PutPixel/}
   asm
     mov ax,y
     mul maxx
     add ax,x
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,color
     stosb
   end;
   {/PutPixel}
end;
{****************************************************************************}
procedure Line(x1,y1,x2,y2:integer;col:byte);
var x,y,s1,s2,dlx,dly,e: integer;
    change: boolean;
begin
   asm
       mov   ax,[x1]
       mov   [x],ax
       mov   ax,[y1]
       mov   [y],ax
       mov   ax,[x2]
       sub   ax,[x1]
       mov   si,ax
       jns   @1
       neg   ax
   @1:
       mov   [dlx],ax
       mov   ax,[y2]
       sub   ax,[y1]
       mov   di,ax
       jns   @2
       neg   ax
   @2:
       mov   [dly],ax
       cmp   si,0
       jl    @3
       cmp   si,0
       jg    @4
       mov   ax,0
       jmp   @5
   @3:
       mov   ax,-1
       jmp   @5
   @4:
       mov   ax,1
   @5:
       mov   [s1],ax
       cmp   di,0
       jl    @6
       cmp   di,0
       jg    @7
       mov   ax,0
       jmp   @8
   @6:
       mov   ax,-1
       jmp   @8
   @7:
       mov   ax,1
   @8:
       mov   [s2],ax
       mov   ax,[dly]
       cmp   ax,[dlx]
       jle   @9
       mov   ax,[dlx]
       mov   bx,[dly]
       xchg  ax,bx
       mov   [dlx],ax
       mov   [dly],bx
       mov [change],1
       jmp   @10
   @9:
       mov   [change],0
   @10:
       mov   ax,[dlx]
       mov   bx,[dly]
       shl  bx,1
       sub  bx,ax
       mov  [e],bx
       mov  ax,[dlx]
       mov  dx,ax
       shl  ax,1
       mov  bx,[dly]
       shl  bx,1
       mov  cx,1
   @11:
       cmp  cx,dx
       jg   @12
       push ax
       push bx
       push cx
       push dx
       mov ax,y
       mul maxx
       add ax,x
       adc dx,0
       mov di,ax
       cmp dx,wbank
       je @put
       mov ax,$4F05
       xor bx,bx
       int 10h
       mov wbank,dx
       @put:
       mov ax,$A000
       mov es,ax
       mov al,col
       stosb
       pop  dx
       pop  cx
       pop  bx
       pop  ax
   @13:
       cmp  [e],0
       jl   @14
       push ax
       cmp  [change],0
       je   @15
       mov  ax,[x]
       add  ax,[s1]
       mov  [x],ax
       jmp  @16
   @15:
       mov  ax,[y]
       add  ax,[s2]
       mov  [y],ax
   @16:
       pop  ax
       sub  [e],ax
       jmp  @13
   @14:
       push ax
       cmp  [change],0
       je   @17
       mov  ax,[y]
       add  ax,[s2]
       mov  [y],ax
       jmp  @18
   @17:
       mov  ax,[x]
       add  ax,[s1]
       mov  [x],ax
   @18:
       add  [e],bx
       inc  cx
       pop  ax
       jmp  @11
   @12:
       push ax
       push bx
       push cx
       push dx

       mov ax,y
       mul maxx
       add ax,x
       adc dx,0
       mov di,ax
       cmp dx,wbank
       je @put2
       mov ax,$4F05
       xor bx,bx
       int 10h
       mov wbank,dx
       @put2:
       mov ax,$A000
       mov es,ax
       mov al,col
       stosb

       pop  dx
       pop  cx
       pop  bx
       pop  ax
   end;

end;
{****************************************************************************}
procedure circle(xco,yco,rad:word;colorp:byte);
var i,j:word;
begin
for i:=0 to (rad shr 2*3) do begin
   j:=round(sqrt(rad*rad-i*i));
   asm
     mov ax,yco
     add ax,j
     mul maxx
     add ax,xco
     add ax,i
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
   asm
     mov ax,yco
     add ax,i
     mul maxx
     add ax,xco
     add ax,j
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
   asm
     mov ax,yco
     sub ax,j
     mul maxx
     add ax,xco
     sub ax,i
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
   asm
     mov ax,yco
     sub ax,i
     mul maxx
     add ax,xco
     sub ax,j
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
   asm
     mov ax,yco
     sub ax,j
     mul maxx
     add ax,xco
     add ax,i
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
   asm
     mov ax,yco
     sub ax,i
     mul maxx
     add ax,xco
     add ax,j
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
   asm
     mov ax,yco
     add ax,j
     mul maxx
     add ax,xco
     sub ax,i
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
   asm
     mov ax,yco
     add ax,i
     mul maxx
     add ax,xco
     sub ax,j
     adc dx,0
     mov di,ax
     cmp dx,wbank
     je @put
     mov wbank,dx
     mov ax,4f05h
     xor bx,bx
     int 10h
   @put:
     mov ax,0A000h
     mov es,ax
     mov al,colorp
     stosb
   end;
end;
end;
{****************************************************************************}
procedure SetPalette(colnom,rbr,gbr,bbr:byte);
begin
if (grmode=$100)or(grmode=$101)or(grmode=$103)or
  (grmode=$105)or(grmode=$013)then begin
port[$3C8]:=colnom;
port[$3C9]:=gbr;
port[$3C9]:=bbr;
port[$3C9]:=rbr;
end;
end;
{****************************************************************************}
procedure GetPalette(colnom:byte;var rbr,gbr,bbr:byte);
begin
if (grmode=$100)or(grmode=$101)or(grmode=$103)or
  (grmode=$105)or(grmode=$013)then begin
port[$3C7]:=colnom;
gbr:=port[$3C9];
bbr:=port[$3C9];
rbr:=port[$3C9];
end;
end;
{****************************************************************************}
procedure SavePalette(name:string);
var palpt:^TPalette;
    plf:file;
    ii:word;
    tr,tb,tg:byte;
begin
new(palpt);
for ii:=1 to 256 do begin
   GetPalette(ii,tr,tg,tb);
   palpt^[ii*3-3]:=tr;
   palpt^[ii*3-2]:=tg;
   palpt^[ii*3-1]:=tb;
end;
assign(plf,name);
rewrite(plf,1);
blockwrite(plf,palpt^,768);
close(plf);
dispose(palpt);
end;
{****************************************************************************}
procedure LoadPalette(name:string);
var palpt:^TPalette;
    ii:word;
    tr,tb,tg:byte;
    plf:file;
begin
new(palpt);
assign(plf,name);
reset(plf,1);
blockread(plf,palpt^,768);
close(plf);
for ii:=1 to 256 do begin
   tr:=palpt^[ii*3-3];
   tg:=palpt^[ii*3-2];
   tb:=palpt^[ii*3-1];
   SetPalette(ii,tr,tg,tb);
end;
dispose(palpt);
end;
{****************************************************************************}
procedure GetImage(x1,y1,x2,y2:word;var pt:pointer);
type PByte=^byte;
type PWord=^word;
var i,j:word;
    colorp:byte;
    pb:PByte;
    pw:PWord;
begin
getmem(pt,(x2-x1+1)*(y2-y1+1)+4);
pb:=pt;
pw:=pt;
pw^:=x2-x1;
pw:=Pword(longint(pw)+2);
pw^:=y2-y1;
{pw:=Pword(longint(pw)+2);}
pb:=PByte(longint(pb)+4);
{mem[sg:os]:=x2-x1+1;
mem[sg:os+1]:=y2-y1+1;}
for j:=y1 to y2 do
  for i:=x1 to x2 do begin
{    mem[sg:os+1+j*(x2-x1+1)-(x2-x1)+i-(x2-x1)]:=getpixel(x1+i-1,y1+j-1);}
    { pb^:=getpixel(i,j);}
    asm
      mov ax,j
{      add ax,j}
      mul maxx
      add ax,i
      adc dx,0
{      adc dx,0}
      mov di,ax
      cmp dx,wbank
      je @put
      mov wbank,dx
      mov ax,4f05h
      xor bx,bx
      int 10h
    @put:
      mov ax,0A000h
      mov es,ax
      mov al,es:[di]
      mov colorp,al
    end;
    pb^:=colorp;
    pb:=PByte(longint(pb)+1);
  end;
end;
{****************************************************************************}
procedure PutImagePP(xp,yp:word;pt:pointer;nviv,nvcol,curs:byte);
type PByte=^byte;
type PWord=^word;
var i,j,sg,os:word;
    xs,ys:longint;
    pb:PByte;
    pw:Pword;
begin
pb:=pt;
pw:=pt;
xs:=pw^+1;
pw:=Pword(longint(pw)+2);
ys:=pw^+1;
pb:=Pbyte(longint(pb)+4);
if curs=1 then
for j:=1 to ys do
  for i:=1 to xs do begin
    if (nviv=0)then putpixel(xp+i-1,yp+j-1,pb^) else if(pb^<>nvcol)then putpixel(xp+i-1,yp+j-1,pb^);
    pb:=PByte(longint(pb)+1);
  end;

if curs=2 then
for j:=1 to ys do
  for i:=1 to xs do begin
    if (nviv=0)then putpixel(xp+j-1,yp+xs-i-1,pb^) else if(pb^<>nvcol)then putpixel(xp+j-1,yp+xs-i-1,pb^);
    pb:=PByte(longint(pb)+1);
  end;

if curs=3 then
for j:=1 to ys do
  for i:=1 to xs do begin
    if (nviv=0)then putpixel(xp+xs-i-1,yp+ys-j-1,pb^) else if(pb^<>nvcol)then putpixel(xp+xs-i-1,yp+ys-j-1,pb^);
    pb:=PByte(longint(pb)+1);
  end;

if curs=4 then
for j:=1 to ys do
  for i:=1 to xs do begin
    if (nviv=0)then putpixel(xp+ys-j-1,yp+i-1,pb^) else if(pb^<>nvcol)then putpixel(xp+ys-j-1,yp+i-1,pb^);
    pb:=PByte(longint(pb)+1);
  end;

if curs=5 then
for j:=1 to ys do
  for i:=1 to xs do begin
    if (nviv=0)then putpixel(xp+i-1,yp+ys-j-1,pb^) else if(pb^<>nvcol)then putpixel(xp+i-1,yp+ys-j-1,pb^);
    pb:=PByte(longint(pb)+1);
  end;

if curs=6 then
for j:=1 to ys do
  for i:=1 to xs do begin
    if (nviv=0)then putpixel(xp+xs-i-1,yp+j-1,pb^) else if(pb^<>nvcol)then putpixel(xp+xs-i-1,yp+j-1,pb^);
    pb:=PByte(longint(pb)+1);
  end;

if curs=7 then
for j:=1 to ys do
  for i:=1 to xs do begin
    if (nviv=0)then putpixel(xp+j-1,yp+i-1,pb^) else if(pb^<>nvcol)then putpixel(xp+j-1,yp+i-1,pb^);
    pb:=PByte(longint(pb)+1);
  end;
end;
{****************************************************************************}
procedure PutImage(xp,yp:word;pt:pointer);
type PByte=^byte;
type PWord=^word;
var i,j:word;
    xs,ys:longint;
    pb:PByte;
    pw:Pword;
    color:byte;
begin
pb:=pt;
pw:=pt;
xs:=pw^+1;
pw:=Pword(longint(pw)+2);
ys:=pw^+1;
pb:=Pbyte(longint(pb)+4);
color:=0;
for j:=1 to ys do
  for i:=1 to xs do begin
     {putpixel(xp+i-1,yp+j-1,pb^);}
    {PutPixel/}
    color:=pb^;
    asm
      mov ax,yp
      add ax,j
      dec ax
      mul maxx
      add ax,xp
      adc dx,0
      add ax,i
      dec ax
      adc dx,0
      mov di,ax
      cmp dx,wbank
      je @put
      mov wbank,dx
      mov ax,4f05h
      xor bx,bx
      int 10h
    @put:
      mov ax,0A000h
      mov es,ax
      mov al,color
      stosb
    end;
    {/PutPixel}
    pb:=PByte(longint(pb)+1);
  end;
end;
{****************************************************************************}
function ImageSize(x1,y1,x2,y2:word):word;
begin
ImageSize:=(x2-x1+1)*(y2-y1+1)+4;
end;
{****************************************************************************}
procedure ImageXYSize(pt:pointer;var xsize,ysize:word);
type PByte=^byte;
type PWord=^word;
var i,j,sg,os:word;
    xs,ys:word;
    pb:PByte;
    pw:Pword;
begin
pb:=pt;
pw:=pt;
xsize:=pw^;
pw:=Pword(longint(pw)+2);
ysize:=pw^;
end;
{****************************************************************************}
procedure SaveImage(name:string;x1,y1,x2,y2:word);
var imgfile:file;
    xsize,ysize:word;
    pt:pointer;
begin
assign(imgfile,name);
xsize:=x2-x1+1;
ysize:=y2-y1+1;
getimage(x1,y1,x2,y2,pt);
rewrite(imgfile,1);
{blockwrite(imgfile,xsize,2);
blockwrite(imgfile,ysize,2);}
blockwrite(imgfile,pt^,xsize*ysize+4);
close(imgfile);
end;
{****************************************************************************}
procedure LoadImage(name:string;var pt:pointer);
var imgfile:file;
    xsize,ysize:word;
begin
new(pt);
assign(imgfile,name);
reset(imgfile,1);
{blockread(imgfile,xsize,2);
blockread(imgfile,ysize,2);}
getmem(pt,filesize(imgfile));
{getmem(pt,xsize*ysize+4);}
blockread(imgfile,pt^,filesize(imgfile));
close(imgfile);
end;
{****************************************************************************}
procedure Octangle(x1,y1,x2,y2:word;colorp:byte);
var prop:integer;
begin
if (x2-x1)<(y2-y1)then prop:=(x2-x1)div 4 else prop:=(y2-y1)div 4;
line(x1+prop,y1,x2-prop,y1,colorp);
line(x1+prop,y2,x2-prop,y2,colorp);
line(x1,y1+prop,x1,y2-prop,colorp);
line(x2,y1+prop,x2,y2-prop,colorp);
line(x1,y1+prop,x1+prop,y1,colorp);
line(x2-prop,y1,x2,y1+prop,colorp);
line(x1,y2-prop,x1+prop,y2,colorp);
line(x2-prop,y2,x2,y2-prop,colorp);
end;
{****************************************************************************}
procedure BitsToByte(bbb:bits;var resul:byte);
var iii:byte;
begin
 resul:=0;
 for iii:=0 to 7 do resul:=(resul shl 1 )+bbb[iii+1];
end;
{****************************************************************************}
procedure ByteToBits(resul:byte;var bbb:bits);
var iii:byte;
    raa:byte;
begin
 for iii:=0 to 7 do
  bbb[iii+1]:=(resul shr iii)and 1;
 for iii:=1 to 4 do begin
   raa:=bbb[iii];
   bbb[iii]:=bbb[9-iii];
   bbb[9-iii]:=raa;
 end;
end;
{****************************************************************************}
procedure LoadFont(name:string);
var f:file;
begin
if name<>'' then begin
assign(f,name);
reset(f,1);
seek(f,0);
blockread(f,CharXSize,1);
blockread(f,CharYSize,1);
blockread(f,Font^,sizeof(Font^));
close(f);
end;
end;
{****************************************************************************}
procedure OutChar(xco,yco,cnom:integer;col,fon,zat:byte);
var ii,jj:byte;
    bb:bits;
begin
for jj:=1 to 16 do begin
  ByteToBits(font^[cnom,jj-1],bb);
  for ii:=1 to 8 do
    if bb[ii]=1 then putpixel(xco+ii-1,yco+jj-1,col) else
      if zat=1 then putpixel(xco+ii-1,yco+jj-1,fon);
end;
end;
{****************************************************************************}
procedure OutStr(xc,yc:integer;st:string;ccol,cfon,czat:byte);
var iic,ii,jj:byte;
    bb:bits;
begin
for iic:=1 to length(st) do
for jj:=1 to 16 do begin
  ByteToBits(font^[ord(st[iic]),jj-1],bb);
  for ii:=1 to 8 do
    if bb[ii]=1 then putpixel(xc+iic*8-8+ii-1,yc+jj-1,ccol) else
      if czat=1 then putpixel(xc+iic*8-8+ii-1,yc+jj-1,cfon);
end;
end;
{****************************************************************************}
procedure DOutStr(xc,yc:integer;st:string;ccol,cfon,czat:byte;del:word);
var iic,ii,jj:byte;
    bb:bits;
begin
for iic:=1 to length(st) do begin
for jj:=1 to 16 do begin
  ByteToBits(font^[ord(st[iic]),jj-1],bb);
  for ii:=1 to 8 do
    if bb[ii]=1 then putpixel(xc+iic*8-8+ii-1,yc+jj-1,ccol) else
      if czat=1 then putpixel(xc+iic*8-8+ii-1,yc+jj-1,cfon);
end;
  for jj:=1 to del do
    for ii:=1 to del do
      ii:=ii;
end;
end;
{****************************************************************************}
procedure TOutStr(x,y:integer;st:string;col,fon,meg:byte);
var i:byte;
begin
if (TextMOde)and(grmode=$002)or(grmode=$003) then begin
col:=col mod 16;
fon:=fon mod 8;
if meg>1 then meg:=0;
for i:=1 to length(st) do begin
  mem[$B800:(y*maxx-maxx+x+i-2)*2+1]:=col+fon*16+meg*16*8;
  mem[$B800:(y*maxx-maxx+x+i-2)*2]:=ord(st[i]);
end;
end;
end;
{****************************************************************************}
procedure loadpcx(pname:string);
var f:file;
    col,aaa,bbb:byte;
    elem:^pcxheader;
    Driver, Mode,
    TestDriver,
    ErrCode: Integer;
    colors:^TPalette;
    ipos:longint;
  	ofss,segs:word;
begin
new(elem);
new(colors);
assign(f,pname);
reset(f,1);
blockread(f,elem^,128);
   for ipos:=1 to 768 do colors^[ipos]:=0;
   ofss:=ofs(Colors^);
   segs:=seg(Colors^);
  {Установка паллитры}
   asm
     mov ah,16
     mov al,18
     mov bx,0
     mov cx,256
     mov dx,segs
     mov es,dx
     mov dx,ofss
     int 10h
   end;
{****************************************************************************}
{Считывание рисунка}
  ipos:=0;
  seek(f,128);
  while  ipos div maxx <> maxy do begin
    blockread(f,col,1);
    if ((col shr 6)<>3) then begin
{       mem[$A000:i]:=col;}
       putpixel(ipos mod maxx,ipos div maxx,col);
       inc(ipos);
    end{if col<=192}
    else{if col>192}
    begin
      aaa:=col and $3F;
      blockread(f,col,1);
      for bbb:=1 to aaa do begin
  {      mem[$A000:i]:=col;}
        putpixel(ipos mod maxx,ipos div maxx,col);
        inc(ipos);
       end;{for b:=1 to a}
    end;{if col>192}
  end;{while  i div 320<>200}
{****************************************************************************}
  {Считывание паллитры}
   seek(f,filesize(f)-768);
   blockread(f,colors^,768);
   for ipos:=1 to 768 do colors^[ipos]:=colors^[ipos] shr 2;
   ofss:=ofs(Colors^);
   segs:=seg(Colors^);
  {Установка паллитры}
   asm
     mov ah,16
     mov al,18
     mov bx,0
     mov cx,256
     mov dx,segs
     mov es,dx
     mov dx,ofss
     int 10h
   end;
close(f);
end;
{****************************************************************************}
{Конец модуля}
{----------------------------------------------------------------------------}
{Мышь}
{****************************************************************************}
procedure MouseTest(var onm,bc:byte);
var onmm,bcc:integer;
begin
asm
  mov ax,0
  int 33h
  mov onmm,ax
  mov bcc,bx
end;
if onmm>0 then onmm:=1;
onm:=onmm;
bc:=bcc;
end;
{****************************************************************************}
procedure ShowMouse;assembler;
asm
  mov ax,1
  int 33h
end;
{****************************************************************************}
procedure HideMouse;assembler;
asm
  mov ax,2
  int 33h
end;
{****************************************************************************}
function MouseX:integer;
var res:integer;
begin
asm
  mov ax,3
  int 33h
  mov res,cx
end;
MouseX:=res;
end;
{****************************************************************************}
function MouseY:integer;
var res:integer;
begin
asm
  mov ax,3
  int 33h
  mov res,dx
end;
MouseY:=res;
end;
{****************************************************************************}
function MouseButtonStatus:byte;
var res:integer;
begin
asm
  mov ax,3
  int 33h
  mov res,bx
end;
MouseButtonStatus:=res;
end;
{****************************************************************************}
procedure MouseStatus(var xmouse,ymouse:integer;var mbs:byte);
var resx,resy,bbs:integer;
begin
asm
  mov ax,3
  int 33h
  mov resx,cx
  mov resy,dx
  mov bbs,bx
end;
xmouse:=resx;
ymouse:=resy;
mbs:=bbs;
end;
{****************************************************************************}
procedure SetMouseCoords(nmx,nmy:integer);assembler;
asm
  mov ax,4
  mov cx,nmx
  mov dx,nmy
  int 33h
end;
{****************************************************************************}
procedure SetMouseMoveBar(xm1,ym1,xm2,ym2:integer);assembler;
asm
  mov ax,7
  mov cx,xm1
  mov dx,xm2
  int 33h
  mov ax,8
  mov cx,ym1
  mov dx,ym2
  int 33h
end;
{****************************************************************************}
procedure GetMouseStep(xco,yco:integer);
var xcou,ycou:integer;
begin
asm
  mov ax,0Bh
  int 33h
  mov xcou,cx
  mov ycou,dx
end;
xco:=xcou;
yco:=ycou;
end;
{****************************************************************************}
procedure SetMouseStep(xco,yco:integer);assembler;
asm
  mov ax,0Fh
  mov cx,xco
  mov dx,yco
  int 33h
end;
{****************************************************************************}
procedure MouseButtonPush(nb:integer;var tbs:byte;var pb,xm,ym:integer);
var ttbs,bpp,xmo,ymo:integer;
begin
asm
  mov ax,5
  mov bx,nb
  int 33h
  mov ttbs,ax
  mov bpp,bx
  mov xmo,cx
  mov ymo,dx
end;
tbs:=ttbs;
pb:=bpp;
xm:=xmo;
ym:=ymo;
end;
{****************************************************************************}
procedure MouseButtonLet(nb:integer;var tbs:byte;var pb,xm,ym:integer);
var ttbs,bpp,xmo,ymo:integer;
begin
asm
  mov ax,6
  mov bx,nb
  int 33h
  mov ttbs,ax
  mov bpp,bx
  mov xmo,cx
  mov ymo,dx
end;
tbs:=ttbs;
pb:=bpp;
xm:=xmo;
ym:=ymo;
end;
{****************************************************************************}
procedure CurTrans(cur,mask:curarr;var ncur:curmask);
var i,j:byte;
    wres:longint;
    bres1,bres2:byte;
    bb:bits;
begin
  for j:=1 to 16 do begin
    wres:=0;
    for i:=1 to 8 do
      bb[i]:=cur[j,i];
    BitsToByte(bb,bres1);
    for i:=1 to 8 do
      bb[i]:=cur[j,i+8];
    BitsToByte(bb,bres2);
    wres:=bres1+bres2*$FF;
  end;
  for j:=1 to 16 do begin
    wres:=0;
    for i:=1 to 8 do
      bb[i]:=cur[j,i];
    BitsToByte(bb,bres1);
    for i:=1 to 8 do
      bb[i]:=cur[j,i+8];
    BitsToByte(bb,bres2);
    wres:=bres1+bres2*$FF;
  end;
end;
{****************************************************************************}
procedure SetGraphCursor(xcp,ycp:integer;ncur:curmask);
var segc,ofsc:word;
begin
segc:=seg(ncur);
ofsc:=ofs(ncur);
asm
  mov ax,9
  mov bx,xcp
  mov cx,ycp
  mov es,segc
  mov dx,ofsc
  int 33h
end;
end;
{****************************************************************************}
{
procedure SetMouseHideBar(x1,y1,x2,y2:integer);assembler;
asm
  mov ax, 16
  mov cx,x1
  mov dx,y1
  mov si,x2
  mov di,y2
  int 33h
end;
}
{****************************************************************************}
{Конец модуля мыши}
{----------------------------------------------------------------------------}
{Моя мышка}
{****************************************************************************}
procedure loadcur(name:string;var curr:cursor);
var f:file;
begin
assign(f,name);
reset(f,1);
blockread(f,curr,sizeof(curr));
close(f);
end;
{****************************************************************************}
procedure loadcurbase(cn1,cn2,cn3,cn4,cn5,cn6,cn7,cn8,cn9,cn10,cn11,
            cz1,cz2,cz3,cz4,cz5,cz6,cs1,cs2,cs3,cs4,cs5,cs6,cl1,cl2,cl3,cl4,cl5,cl6:string);
begin
loadcur(cn1,cn^);
loadcur(cn2,cv^);
loadcur(cn3,ci^);
loadcur(cn4,cno^);
loadcur(cn5,chd^);
loadcur(cn6,cleft^);
loadcur(cn7,cright^);
loadcur(cn8,cup^);
loadcur(cn9,cdown^);
loadcur(cn10,cxsize^);
loadcur(cn11,cysize^);

loadcur(cz1,czan^[1]);
loadcur(cz2,czan^[2]);
loadcur(cz3,czan^[3]);
loadcur(cz4,czan^[4]);
loadcur(cz5,czan^[5]);
loadcur(cz6,czan^[6]);

loadcur(cs1,cs^[1]);
loadcur(cs2,cs^[2]);
loadcur(cs3,cs^[3]);
loadcur(cs4,cs^[4]);
loadcur(cs5,cs^[5]);
loadcur(cs6,cs^[6]);

loadcur(cl1,cl^[1]);
loadcur(cl2,cl^[2]);
loadcur(cl3,cl^[3]);
loadcur(cl4,cl^[4]);
loadcur(cl5,cl^[5]);
loadcur(cl6,cl^[6]);
end;
{****************************************************************************}
procedure PutCur(x,y:integer;curr:cursor);
var ii,jj:byte;
begin
for jj:=1 to 32 do
  for ii:=1 to 32 do
    if curr.cur[jj,ii]<>0 then putpixel(x+ii,y+jj,curr.cur[jj,ii]);
end;
{****************************************************************************}
procedure PPutCur(x,y:integer;curr:cursor);
var ii,jj:byte;
begin
for jj:=1 to 32 do
  for ii:=1 to 32 do
    putpixel(x+ii,y+jj,curr.cur[jj,ii]);
end;
{****************************************************************************}
procedure GetCur(x,y:integer;var curr1:cursor;curr2:cursor);
var ii,jj:byte;
begin
curr1:=curr2;
for jj:=1 to 32 do
  for ii:=1 to 32 do
    curr1.cur[jj,ii]:=getpixel(x+ii,y+jj);
end;
{****************************************************************************}
procedure MMove;
begin
{putimage(ms.wx-cur.xh,ms.wy-cur.yh,ms.p^,CopyPut);}
PPutCur(ms.wx-wcur^.xh,ms.wy-wcur^.yh,wcur^);
MouseStatus(ms.x,ms.y,ms.bs);
{getimage(ms.x-cur.xh,ms.y-cur.yh,ms.x-cur.xh+32,ms.y-cur.yh+32,ms.p^);}
GetCur(ms.x-cur^.xh,ms.y-cur^.yh,wcur^,cur^);
case ms.sost of
  0:cur:=chd;
  1:cur:=cn;
  2:cur^:=czan^[ictr];
  3:cur^:=cs^[ictr];
  4:cur^:=cl^[ictr];
  5:cur:=cv;
  6:cur:=ci;
  7:cur:=cno;
  8:cur:=chd;
  9:cur:=cleft;
  10:cur:=cright;
  11:cur:=cup;
  12:cur:=cdown;
  13:cur:=cxsize;
  14:cur:=cysize;
end;
if ictr>=6 then ictr:=1 else inc(ictr);
if ms.sost<>ms.wsost then ictr:=1;
PutCur(ms.x-cur^.xh,ms.y-cur^.yh,cur^);
{delay(mousedel);}
ms.wx:=ms.x;ms.wy:=ms.y;
ms.wsost:=ms.sost;
end;
{****************************************************************************}
{Конец модуля моей мышки}
{----------------------------------------------------------------------------}
{Подготовка и конец работы}
{****************************************************************************}
procedure Ready;
begin
new(cur);
new(wcur);
new(cn);
new(cv);
new(ci);
new(cno);
new(chd);
new(cleft);
new(cright);
new(cup);
new(cdown);
new(cxsize);
new(cysize);
new(cl);
new(cs);
new(czan);
new(Font);
new(key);
ms.sost:=1;
mousedel:=100;
ms.x:=20;ms.y:=20;
SetMouseMoveBar(0,0,639,479);
SetMouseCoords(ms.x,ms.y);
GetCur(ms.x-cur^.xh,ms.y-cur^.yh,wcur^,cur^);
end;
{****************************************************************************}
procedure Finish;
begin
dispose(cur);
dispose(wcur);
dispose(cn);
dispose(cv);
dispose(ci);
dispose(cno);
dispose(chd);
dispose(cleft);
dispose(cright);
dispose(cup);
dispose(cdown);
dispose(cxsize);
dispose(cysize);
dispose(cl);
dispose(cs);
dispose(czan);
dispose(key);
dispose(Font);
end;
{****************************************************************************}
{Конец подготовки}
{----------------------------------------------------------------------------}

begin
end.
