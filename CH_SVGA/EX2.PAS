program EX2;
uses crt,ch_svga;

var
  i:word;
begin
  InitSVGA(g640x480x256);
  bar(1,1,40,80,4);
  bar(1,1,50,60,15);
  readkey;
  LoadPCX('sw.pcx');
  readkey;
  CloseSVGA;
end.
