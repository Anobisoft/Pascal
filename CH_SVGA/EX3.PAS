program EX3;
uses crt,ch_svga;

var
  i:word;
  p:pointer;
begin
  Ready;
  InitSVGA(g640x480x256);
  bar(1,1,80,90,5);
  circle(100,100,20,11);
  GetImage(80,80,120,120,p);
  GetCur(10,10,cur^,cur^);
  readkey;
  for i:=1 to 20 do
    PutImage(random(400)+40,random(400)+40,p);
  while not(keypressed)do
  begin
    MMove;
  end;
  CloseSVGA;
  Finish;
end.
