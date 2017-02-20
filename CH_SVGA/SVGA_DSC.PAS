{  Несчастным, решившим разобраться с моим модулем посвящается...            }
{                                                         Cherny             }
{****************************************************************************}
procedure IGetKey;interrupt;
function KeyPush:boolean;{Аналог KeyPressed}
procedure WaitKey;{Аналог Readkey, но не возварщает номер клавиши}
procedure InitSVGA(ing:integer);{Процедура инициализации графического режима}
procedure putpixel(xpo,ypo:word;colorp:byte);{Путает пиксель на экран}
function getpixel(xpo,ypo:word):byte;{Гетает пиксель с экрана}
procedure bar(x1,y1,x2,y2:longint;colorp:byte);{Рисует Барчик}
procedure rectangle(x1,y1,x2,y2:word;colorp:byte);{Рисует прямоугольник}
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
procedure SetMouseCoords(nmx,nmy:integer);{Установить мышку в точку X;Y}
procedure SetMouseMoveBar(xm1,ym1,xm2,ym2:integer);{Установить область перемещения мышки}
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
