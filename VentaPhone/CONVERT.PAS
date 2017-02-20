uses crt, dos, listwork, filework;

var letter              : char;
    i                   : byte;
    aboncount           : longint;


begin
  textmode(3);
  if openfile('newphone.vfc') = 0 then
  for letter := '€' to 'Ÿ' do
  if letter in ['‰', 'š', '›', 'œ'] then else
  begin
    write(letter);
    scanabon(letter);
    overlist;
    sort;
    remakefile('Phone_' + letter + '.txt');
    getfirst;
    while not eoflist do
    begin
      writecurabon;
      getnext
    end;
    close(output);
    freelist
  end;
  close(input)
end.
