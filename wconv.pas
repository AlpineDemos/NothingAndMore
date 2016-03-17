var f,f2: text;
    w:word;
    b,b2:byte;
    S:string;
    CString:Array[0..256] of Byte;
    linelen:word;
    NoEmptyLine:Byte;
const
      MaxFont = 43;
      Characters: string[MaxFont] = (
    'abcdefghijklmnopqrstuvwxyz.:;,!?-12345679@ ');
      Points:Array[0..MaxFont-1, 0..3 ] of word = (
      ({a} 124, 91,137,110 ),
      ({b} 139, 91,153,110 ),
      ({c} 155, 91,167,110 ),
      ({d} 169, 91,182,110 ),
      ({e} 184, 91,196,110 ),
      ({f} 199, 91,210,110 ),
      ({g} 212, 91,224,110 ),
      ({h} 226, 91,240,110 ),
      ({i} 244, 91,249,110 ),
      ({j} 251, 91,263,110 ),
      ({k} 265, 91,279,110 ),
      ({l} 283, 91,294,110 ),
      ({m} 120,114,137,133 ),
      ({n} 140,114,153,133 ),
      ({o} 156,114,168,133 ),
      ({p} 171,114,184,133 ),
      ({q} 187,114,200,133 ),
      ({r} 203,114,214,133 ),
      ({s} 216,114,227,133 ),
      ({t} 229,114,242,133 ),
      ({u} 245,114,258,133 ),
      ({v} 262,114,275,133 ),
      ({w} 279,114,295,133 ),
      ({x} 125,137,138,156 ),
      ({y} 143,137,155,156 ),
      ({z} 159,137,171,156 ),
      ({.} 235,137,240,156 ),
      ({:} 242,137,247,156 ),
      ({;} 248,137,254,156 ),
      ({,} 256,137,262,156 ),
      ({!} 266,137,274,156 ),
      ({?} 276,137,291,156 ),
      ({-} 293,137,303,156 ),
      ({1} 120,163,131,182 ),
      ({2} 134,163,147,182 ),
      ({3} 149,163,163,182 ),
      ({4} 165,163,180,182 ),
      ({5} 182,163,196,182 ),
      ({6} 198,163,212,182 ),
      ({7} 214,163,229,182 ),
      ({9} 230,163,245,182 ),
      ({@}  31, 13,277, 68 ),
      ({ }   0,199, 08,199 )

);


Begin
  Assign(f2,'TXT.TXT'); ReSet(F2);
  Assign(f,'TXT.INC'); Rewrite(F);
  Write(f,' String db ');
  While not eof(f2) do begin
   Readln(F2,s); linelen:=0; NoEmptyLine:=0;
   For w:=1 to Length(s) do begin
     b2:=MaxFont-1;
     For b:=1 to MaxFont do if s[w]=Characters[b] then b2:=b-1;
     if b2<>MaxFont-1 then NoEmptyLine:=1;
     linelen:=linelen+(Points[b2,2]-Points[b2,0]);
     CString[w]:=b2;
   end;
   linelen:=(319-linelen) shr 4-1;
   if (S[1]<>'³')and(NoEmptyLine=1) then For W:=1 to LineLen do write(f,MaxFont-1,',');
   For W:=1 to Length(s) do begin write(f,CString[W],','); End;

   Writeln(F,'255'); Write(F,'        db ');
  End;
  writeln(f,'255');
  close(f);
End.