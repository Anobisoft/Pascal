unit manager;
interface
 const sign : word = $AC41;
       cancelled = '$cancelled$';
 var   scr              : array [0..3999] of byte absolute $B800:0000;
       curdir, selected : string;

 procedure manage;
 procedure print(x, y: byte; s : string);

implementation

uses crt, dos;

type tlist = ^listrec;
     listrec = record
                 prv, nxt : tlist;
                 name     : pointer;
                 attr     : byte;
               end;

var signl, listl            : word;
    first, p                : tlist;
    sr                      : searchrec;

 procedure print(x, y: byte; s : string);
 var i : byte;
 begin
   for i := 1 to ord(s[0]) do scr[x*2+y*160+i*2-2] := ord(s[i])
 end;

 procedure printframe;
 var i, j : word;
 begin
   for i := 0 to 1919 do scr[i*2+1] := 31;
   for i := 1 to 78 do scr[i*2+3680] := 205;
   for i := 1 to 14 do scr[i*2] := 205;
   scr[156] := 205;
   for i := 1 to 22 do begin
     scr[i*160] := 186;
     scr[i*160+30] := 186;
     scr[i*160+158] := 186
   end;
   scr[0] := 201;
   scr[30] := 203;
   scr[158] := 187;
   scr[3680] := 200;
   scr[3710] := 202;
   scr[3838] := 188
 end;

 procedure addlist;
 var s, o : word;
     i    : byte;
 begin
   p := first;
   new(first);
   first^.prv := p;
   first^.nxt := nil;
   p^.nxt := first;
   getmem(first^.name, ord(sr.name[0]) + 1);
   s := seg(first^.name^);
   o := ofs(first^.name^);
   for i := 0 to ord(sr.name[0]) do mem[s:o+i] := ord(sr.name[i]);
   first^.attr := sr.attr
 end;

 procedure freelist;
 var s, o : word;
 begin
   while first^.prv <> nil do first := first^.prv;
   while first <> nil do
   begin
     p := first^.nxt;
     s := seg(first^.name^);
     o := ofs(first^.name^);
     freemem(first^.name, mem[s:o]);
     dispose(first);
     first := p
   end
 end;

 procedure menu;
 var y, yy, i, j : byte;
     key         : char;
     name        : string;
     f           : file;

   function strp(p : pointer) : string;
   var st   : string;
       s, o : word;
       i : byte;
   begin
     s := seg(p^);
     o := ofs(p^);
     for i := 0 to mem[s:o] do st[i] := chr(mem[s:o+i]);
     strp := st
   end;{function strp}

   procedure printlist;
   var i, j : byte;

     procedure printimageinfo(x, y: byte; p : pointer);
     var i : byte;
         f : file;
         sizex, sizey : byte;
     begin
       assign(f, strp(p));
       reset(f, 1);
       blockread(f, signl, 2);
       if signl = sign then begin
         blockread(f, sizex, 1);
         blockread(f, sizey, 1);
         print(x, y, 'Image');
         scr[x*2+y*160 + 14] := sizex div 10 mod 10 + 48;
         scr[x*2+y*160 + 16] := sizex mod 10 + 48;
         scr[x*2+y*160 + 18] := 120;
         scr[x*2+y*160 + 20] := sizey div 10 mod 10 + 48;
         scr[x*2+y*160 + 22] := sizey mod 10 + 48
       end else print(x, y, 'Unsupported');
       close(f)
     end; {procedure printimageinfo}

     procedure printp(x, y: byte; p : pointer);
     var s, o : word;
         i    : byte;
     begin
       s := seg(p^);
       o := ofs(p^);
       for i := 1 to mem[s:o] do scr[x*2+y*160+i*2-2] := mem[s:o+i];
       for i := mem[s:o] + 1 to 12 do scr[x*2+y*160+i*2-2] := 0
     end; {procedure printp}

   begin {procedure printlist}
     for j := 1 to 22 do begin
       for i := 2 to 13 do scr[i*2 + j*160] := 0;
       for i := 17 to 29 do scr[i*2 + j*160] := 0
     end;
     p := first;
     i := 0;
     while not ((p = nil) or (i = 22)) do begin
       inc(i);
       printp(2, i, p^.name);
       if p^.attr = 8 then print(17, i, 'Volume ID') else
       if p^.attr and 16 = 16 then print(17, i, 'SubDirectory')
       else printimageinfo(17, i, p^.name);
       p := p^.nxt
     end
   end; {procedure printlist}

   procedure deletefail;
   var i : byte;
       s : string;
       f : file;
   begin
     p := first;
     for i := 2 to y do p := p^.nxt;
     if p^.attr and 16 = 16 then
     else begin
       p^.nxt^.prv := p^.prv;
       p^.prv^.nxt := p^.nxt;
       s := strp(p^.name);
       freemem(p^.name, ord(s[0]));
       dispose(p);
       dec(listl);
       assign(f, s);
       erase(f);
       y := 1;
       printlist
     end
   end; {procedure deletefail}

 begin {procedure menu}
   printlist;
   for i := 16 to 75 - ord(curdir[0]) do scr[i*2] := 205;
   print(76 - ord(curdir[0]), 0, ' ' + curdir + ' ');
   y := 1;
   yy := 0;
   for i := 1 to 78 do scr[i*2+y*160+1] := 120;
   repeat
     key := readkey;
     if key = #0 then
     begin
       key := readkey;
       for i := 1 to 78 do scr[i*2+y*160+1] := 31;
       case key of
         #80 : if y = 22 then
               if yy + 22 = listl then
               else begin
                      inc(yy);
                      first := first^.nxt;
                      printlist
                    end else if y+yy = listl then else inc(y);
         #72 : if y = 1 then
               if yy = 0 then
               else begin
                      dec(yy);
                      first := first^.prv;
                      printlist
                    end else dec(y);
         #83 : begin
                 write('You want to delete this fail. Are you sure? (y/another)');
                 key := readkey;
                 if key = #0 then readkey else
                 if key = 'y' then deletefail;
                 for i := 0 to 79 do scr[i*2+3840] := 0;
                 gotoxy(1, 25)
               end
       end;
       for i := 1 to 78 do scr[i*2+y*160+1] := 120
     end else
           case key of
             #13 : begin
                     p := first;
                     for i := 2 to y do p := p^.nxt;
                     if p^.attr and 16 = 16 then
                     begin
                       chdir(strp(p^.name));
                       freelist
                     end
                     else begin
                       selected := strp(p^.name);
                       assign(f, selected);
                       reset(f, 1);
                       blockread(f, signl, 2);
                       close(f);
                       if signl = sign then freelist else key := #255
                     end
                   end;
             #27 : selected := cancelled;
           end
   until (key = #13) or (key = #27);
   for i := 1 to 78 do scr[i*2+y*160+1] := 31
 end; {procedure menu}

procedure manage;

begin
  gotoxy(1, 25);
  printframe;
  first := nil;
  selected := '';
  repeat
    getdir(0, curdir);
    listl := 0;
    findfirst('*.*', $3F, sr);
    while doserror = 0 do begin
      if (sr.attr and 16 = 16) and (sr.name <> '.') then
      begin
        addlist;
        inc(listl)
      end;
      findnext(sr)
    end;
    findfirst('*.ach', $3F, sr);
    while doserror = 0 do begin
      addlist;
      inc(listl);
      findnext(sr)
    end;
    while first^.prv <> nil do first := first^.prv;
    menu
  until selected <> ''
end;



begin
end.


function DosErrorMsg : string;
begin
 case doserror of
   02: doserrormsg := 'File not found.';
   03: doserrormsg := 'Path not found.';
   05: doserrormsg := 'Access denied.';
   06: doserrormsg := 'Invalid handle.';
   08: doserrormsg := 'Not enough memory.';
   10: doserrormsg := 'Invalid environment.';
   11: doserrormsg := 'Invalid format.';
   18: doserrormsg := 'No more files.'
 end
end;



 1 Read only
 2 Hidden
 4 System
32 Archive (normal)