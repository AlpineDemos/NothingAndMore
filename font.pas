                                                                              {
  __________________________________________________________________________
 {                                                                          }
(* Font-Generator         by Syrius/Alpine                                  *)
 {__________________________________________________________________________}

uses crt;
Var F:File;
    t:Text;
    Pal:Array[0..768] of Byte;
    M,X,Y:Word;
    c:char;
    CCol,Count:Byte;
Const Name='IntroF';
      MaxFont = 43;
      Points:Array[1..MaxFont, 0..3 ] of word = (

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




Procedure Box(X1,Y1,X2,Y2:Word;cc:byte); Var I:Word;
Begin
 For I:=X1 To X2 do mem[$a000:y1*320+i]:=cc;
 For I:=X1 To X2 do mem[$a000:y2*320+i]:=cc;
 For I:=Y1 To Y2 do mem[$a000:i*320+x1]:=cc;
 For I:=Y1 To Y2 do mem[$a000:i*320+x2]:=cc;
End;

Begin
 asm mov ax,13h; int 10h; end;
 Assign(F,Name+'.GF3');Reset(f,1);
 BlockRead(F,Pal,768); BlockRead(F,Mem[$a000:0],64000); Close(f);

 Assign(T,Name+'.INC');ReWrite(T);
 Writeln(T,' ;'+Name+'.Gf3 Converted by Syrius / Alpine ');writeln(T);

 For M:=1 to Maxfont do begin
  Writeln(T,'LETTER',M,' dw ',319-Points[M,2]+Points[M,0]);
  Writeln(T,' db ',Points[M,3]-Points[M,1]+1);
  For Y:=Points[M,1] to Points[M,3] do begin
   CCol:=mem[$a000:Y*320+Points[M,0]]; Count:=1;
   Write(T,' db ');
   For X:=Points[M,0]+1 to Points[M,2] do begin
    If mem[$a000:Y*320+X]=CCol then Inc(Count) else begin
     if (count=1) and (CCol<>0) then Write(T,Byte(CCol+1),',')
                else Write(T,Byte(Count+1),',',Byte(CCol+1),',');
     Count:=1;CCol:=mem[$a000:Y*320+X];
    End;
   End;
   Writeln(T,Byte(Count+1),',',Byte(CCol+1),',',1);
  End;
 End;
 Write(T,'LetterOfs ');
 For Y:=1 To MaxFont do Writeln(T,' dd O Letter',Y);
 Close(T);

End.

