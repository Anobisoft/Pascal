unit filework;

interface

procedure scanabon(letter : char);
procedure writecurabon;
procedure remakefile(s : string);
procedure seektoletter(letter : char);
function openfile(s : string) : integer;
var input, output : file;

implementation

uses dos, listwork;

var space         : char;
    linefeed      : array [0..1] of char;
    ralphabet     : array [128..159] of longint;
    i             : byte;
    inputreaded   : boolean;

procedure scanabon(letter : char);
var xlet : byte;
begin
  seektoletter(letter);
  repeat
    with curabon do
    begin
      blockread(input, phone, 6);
      blockread(input, name, 1);
      blockread(input, name[1], ord(name[0]));
      xlet := ord(name[1]);
      if (xlet in [128..159]) and (ralphabet[xlet] = -1) then
               ralphabet[xlet] := filepos(input) - ord(name[0]) - 7;
      blockread(input, addr, 1);
      blockread(input, addr[1], ord(addr[0]));
      if name[1] = letter then addnew
    end
  until eof(input)
end;

procedure writecurabon;
begin
  with curabon do
  begin
    blockwrite(output, phone, 6);
    blockwrite(output, space, 1);
    blockwrite(output, name[1], ord(name[0]));
    blockwrite(output, space, 1);
    blockwrite(output, addr[1], ord(addr[0]));
    blockwrite(output, linefeed, 2)
  end
end;

procedure remakefile(s : string);
begin
  assign(output, s);
  {$I-}
  rewrite(output, 1);
  if ioresult = 0 then else {error message};
  {$I+}
end;

function openfile(s : string) : integer;
var sr : searchrec;
    ec : integer;
begin
  findfirst(s, $3F, sr);
  ec := doserror;
  if ec = 0 then
  begin
    assign(input, sr.name);
  {$I-}
    reset(input, 1);
  {$I+}
    ec := ioresult;
    if ec = 0 then else {error message};
  end else {error message};
  openfile := ec;
end;

procedure seektoletter(letter : char);
begin
  if inputreaded then seek(input, ralphabet[ord(letter)]) else
  inputreaded := true
end;



begin
  for i := 128 to 159 do ralphabet[i] := $FFFFFFFF;
  inputreaded := false;
  space := #32;
  linefeed := #13#10;
end.
