uses crt, dos;

var input, output       : file;
    sr                  : searchrec;
    i                   : byte;
    phone               : array [0..5] of byte;
    name, addr          : string [50];

begin
  findfirst('newphone.txt', $3F, sr);
  if doserror <> 0 then halt;
  textmode(3);
  assign(input, sr.name);
  reset(input, 1);
  assign(output, 'newphone.vfc');
  rewrite(output, 1);
  repeat
    blockread(input, phone, 6);
    blockread(input, name, 1);
    i := 0;
    repeat
      inc(i);
      blockread(input, name[i], 1)
    until name[i] = #32;
    blockread(input, name[i + 1], 3);
    name[0] := chr (i + 2);
    i := 0;
    repeat
      inc(i);
      blockread(input, addr[i], 1)
    until (addr[i] = #10) or eof(input);
    addr[0] := chr (i - 2);
    blockwrite(output, phone, 6);
    blockwrite(output, name, ord(name[0]) + 1);
    blockwrite(output, addr, ord(addr[0]) + 1)
  until eof(input);
  close(input);
  close(output)
end.
