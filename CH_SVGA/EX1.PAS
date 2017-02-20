program EX1;
uses crt,ch_svga;

var
  i:word;
begin
  InitSVGA(g640x480x256);
  ClearScreen(0);
  loadpcx('034.pcx');
  readkey;
  CloseSVGA;
end.
