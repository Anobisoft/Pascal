unit listwork;

interface


var curabon : record
                name, addr : string[50];
                phone : array [0..5] of char;
              end;

procedure addnew;
procedure overlist;
procedure freelist;
procedure sort;
procedure getfirst;
procedure getnext;
function eoflist : boolean;

{|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=}

implementation

type Abon = ^r;
     r    = record
              name : pointer;
              addr : pointer;
              phone : array [0..5] of char;
              previous : abon;
              next : abon;
            end;


var first : abon;
    curpoint : abon;


procedure addnew;

var q : abon;
    i : integer;

  function fillpoint(sss : string) : pointer;
  var sg, offs : word;
      i        : byte;
      p        : pointer;
      ls       : byte absolute sss;
  begin
    getmem(p, ls + 1);
    sg := seg(p^);
    offs := ofs(p^);
    for i := 0 to ls do mem[sg : offs + i] := ord(sss[i]);
    fillpoint := p;
  end;

begin
  new(q);
  q^.name := fillpoint(curabon.name);
  q^.addr := fillpoint(curabon.addr);
  for i := 0 to 5 do q^.phone[i] := curabon.phone[i];
  q^.previous := q;
  q^.next := first;
  if first <> nil then first^.previous := q;
  first := q;
end;


procedure overlist;
begin
  first^.previous := nil
end;



function getstrpoint(p : pointer) : string;
var segm, offs, i : word;
    s : string[50];
begin
  segm := seg (p^);
  offs := ofs (p^);
  for i := 0 to mem[segm : offs] do s[i] := chr(mem[segm : offs + i]);
  getstrpoint := s;
end;


procedure insert_next(q, p : abon);
begin
  q^.next^.previous := q^.previous;
  q^.previous^.next := q^.next;
  q^.next := p^.next;
  q^.previous := p;
  p^.next := q;
  if q^.next <> nil then q^.next^.previous := q;
end;


procedure insert_previous(q, p : abon);
begin
  if q^.next <> nil then q^.next^.previous := q^.previous;
  if q^.previous <> nil then q^.previous^.next := q^.next;
  q^.previous := p^.previous;
  q^.next := p;
  p^.previous := q;
  if q^.previous <> nil then q^.previous^.next := q
end;


procedure move_onplace(q, x : abon);
var qname : string[50];
begin
  qname := getstrpoint(q^.name);
  while (x^.previous <> nil)
    and (qname > getstrpoint(x^.previous^.name)) do x := x^.previous;
  insert_previous(q, x);
end;


procedure progress_indicator;
begin

end;


procedure sort;
var x : abon;
    qname, xname, xnname : string[50];
begin
  qname := getstrpoint(first^.name);
  x := first^.next;
  while (x <> nil) and (getstrpoint(x^.name) > qname) do
  begin
    move_onplace(x, first);
    x := first^.next
  end;
  if x <> nil then
  while x^.next <> nil do
  begin
    xname := getstrpoint(x^.name);
    xnname := getstrpoint(x^.next^.name);
    if qname <= xnname then move_onplace(x^.next, first) else
    if xname < xnname then move_onplace(x^.next, x) else
    x := x^.next
  end;
  while first^.previous <> nil do first := first^.previous
end;


procedure getabon;
var i : byte;
begin
  if eoflist then
  else with curabon do begin
    name := getstrpoint(curpoint^.name);
    addr := getstrpoint(curpoint^.addr);
    for i := 0 to 5 do phone[i] := curpoint^.phone[i]
  end
end;


procedure getfirst;
begin
  curpoint := first;
  while curpoint^.next <> nil do curpoint := curpoint^.next;
  getabon
end;


procedure getnext;
begin
  curpoint := curpoint^.previous;
  getabon
end;


function eoflist : boolean;
begin
  if curpoint = nil then eoflist := true else eoflist := false;
end;


procedure freelist;

  procedure freestrpoint(p : pointer);
  var segm, offs : word;
  begin
    segm := seg(p^);
    offs := ofs(p^);
    freemem(p, mem[segm : offs] + 1);
  end;

begin
  while first <> nil do
  begin
    freestrpoint(first^.name);
    freestrpoint(first^.addr);
    if first^.next = nil then
    begin
      dispose(first);
      first := nil
    end else begin
          first := first^.next;
          dispose(first^.previous)
        end
  end
end;


end.