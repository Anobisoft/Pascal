{  �������, �訢訬 ࠧ������� � ���� ���㫥� ����頥���...            }
{                                                         Cherny             }
{****************************************************************************}
procedure IGetKey;interrupt;
function KeyPush:boolean;{������ KeyPressed}
procedure WaitKey;{������ Readkey, �� �� ������頥� ����� ������}
procedure InitSVGA(ing:integer);{��楤�� ���樠����樨 ����᪮�� ०���}
procedure putpixel(xpo,ypo:word;colorp:byte);{��⠥� ���ᥫ� �� ��࠭}
function getpixel(xpo,ypo:word):byte;{��⠥� ���ᥫ� � ��࠭�}
procedure bar(x1,y1,x2,y2:longint;colorp:byte);{����� ���稪}
procedure rectangle(x1,y1,x2,y2:word;colorp:byte);{����� ��אַ㣮�쭨�}
function Sign(Number:integer):integer;{�����頥� ���� �᫠}
Procedure Line_(x1,y1,x2,y2:integer;color:byte);{����� �����}
procedure Line(x1,y1,x2,y2:integer;col:byte);{����� �����}
procedure circle(xco,yco,rad:word;colorp:byte);{����� ���}
procedure SetPalette(colnom,rbr,gbr,bbr:byte);{��⠭�������� �������}
procedure GetPalette(colnom:byte;var rbr,gbr,bbr:byte);{����� �������}
procedure SavePalette(name:string);{���࠭�� ������� � 䠩�}
procedure LoadPalette(name:string);{��⠥� ������� �� 䠩��}
procedure GetImage(x1,y1,x2,y2:word;var pt:pointer);{��⠥� �����}
procedure PutImagePP(xp,yp:word;pt:pointer;nviv,nvcol,curs:byte);{��⠥� �����}
procedure PutImage(xp,yp:word;pt:pointer);{��⠥� �����}
function ImageSize(x1,y1,x2,y2:word):word;{�����頥� ࠧ��� ������ ������}
procedure ImageXYSize(pt:pointer;var xsize,ysize:word);{�����頥� ࠧ��� ������ ������}
procedure SaveImage(name:string;x1,y1,x2,y2:word);{���࠭�� ����� � 䠩�}
procedure LoadImage(name:string;var pt:pointer);{��⠥� ����� �� 䠩��}
procedure Octangle(x1,y1,x2,y2:word;colorp:byte);{����� ���쬨㣮�쭨�}
procedure ClearScreen(colorp:byte);{��頥� ��࠭}
procedure BitsToByte(bbb:bits;var resul:byte);{�८�ࠧ�� ���� � ����}
procedure ByteToBits(resul:byte;var bbb:bits);{�८�ࠧ�� ���� � ����}
procedure LoadFont(name:string);{����㦠�� ����}
procedure OutChar(xco,yco,cnom:integer;col,fon,zat:byte);{��⠥� ᨬ���}
procedure OutStr(xc,yc:integer;st:string;ccol,cfon,czat:byte);{��⠥� ��ப�}
procedure DOutStr(xc,yc:integer;st:string;ccol,cfon,czat:byte;del:word);{��⠥� ��ப� � ����প��}
procedure TOutStr(x,y:integer;st:string;col,fon,meg:byte);{��⠥� ��ப� � ⥪�⮢�� ०���}
procedure loadpcx(pname:string);{����㦠�� PCX}
procedure MouseTest(var onm,bc:byte);{���� ������ ��誨}
procedure ShowMouse;{�������� �����}
procedure HideMouse;{������� �����}
function MouseX:integer;{������� X ���न����}
function MouseY:integer;{������� Y ���न����}
function MouseButtonStatus:byte;{������� ����� ������}
procedure MouseStatus(var xmouse,ymouse:integer;var mbs:byte);{������� ����� ��誨}
procedure SetMouseCoords(nmx,nmy:integer);{��⠭����� ���� � ��� X;Y}
procedure SetMouseMoveBar(xm1,ym1,xm2,ym2:integer);{��⠭����� ������� ��६�饭�� ��誨}
procedure GetMouseStep(xco,yco:integer);{�����頥� 蠣 ��誨}
procedure SetMouseStep(xco,yco:integer);{��⠭�������� 蠣 ��誨}
procedure MouseButtonPush(nb:integer;var tbs:byte;var pb,xm,ym:integer);{������ ������ ���}
procedure MouseButtonLet(nb:integer;var tbs:byte;var pb,xm,ym:integer);{����⨫� ������ ���}
procedure CurTrans(cur,mask:curarr;var ncur:curmask);{���������� �ଠ� �����}
procedure SetGraphCursor(xcp,ycp:integer;ncur:curmask);{��⠭�������� ����᪨� �����}
procedure loadcur(name:string;var curr:cursor);{����㦠�� ����� �� 䠩��}
procedure loadcurbase(cn1,cn2,cn3,cn4,cn5,cn6,cn7,cn8,cn9,cn10,cn11,
            cz1,cz2,cz3,cz4,cz5,cz6,cs1,cs2,cs3,cs4,cs5,cs6,cl1,cl2,cl3,cl4,cl5,cl6:string);
          {����㦠�� ���� ����஢ �� 䠩���}
procedure PutCur(x,y:integer;curr:cursor);{�뢮��� ����� �� ��࠭}
procedure PPutCur(x,y:integer;curr:cursor);{�뢮��� ����� �� ��࠭}
procedure GetCur(x,y:integer;var curr1:cursor;curr2:cursor);{��⠥� ����� � ��࠭�}
procedure MMove;{�⮡ࠦ��� �������� �����}
procedure Ready;{�����⠢������ ����� � ࠡ��}
procedure Finish;{�����蠥� ࠡ��� �����}
{****************************************************************************}
