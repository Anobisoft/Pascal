uses crt, dos;

var f        : file;
    b        : pointer;
    sz, i, l : longint;
    os, sg   : word;
    sr       : searchrec;
    name     : string;

begin
  randomize;
  writeln;
  sz := 1024;
  if sz > maxavail then begin writeln('Not enough memory.'); halt end;
  getmem(b, sz);
  sg := seg(b^);
  os := ofs(b^);
  findfirst('*.ach', $3F, sr);
  while doserror = 0 do findnext(sr);
  name := sr.name;
  if name = '' then name := 'FILE_'#64'.ach';
  if (name[0] = #10) and (ord(name[6]) in [64..89]) then inc(name[6])
  else begin writeln('Stop!'); halt end;
  assign(f, name);
  {$I-}
  rewrite(f, 1);
  {$I+}
  if ioresult <> 0 then begin writeln('Can''t create file "', name, '".'); halt end
  else writeln('Just created file "', name, '".');
  repeat
    i := 0;
    repeat
      mem[sg:os+i] := random(256);
      inc(i)
    until i = sz;
    blockwrite(f, b^, sz);
    inc(l);
  until l = $100000;
  close(f)
end.