;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC EndTimer
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  Call TimerCopy
  dec [FlipFlop]
  jnz @ENoNextLine
  mov [FlipFlop],2
  sub [StartPos],320
  jnz @ENoNextLine
   mov [StartPos],320*25
   mov edi,[StartLine]
   @OnceMore:
   cmp [b edi],255
   je @NoOnce
   inc edi
   jmp @OnceMore
   @NoOnce:
   inc edi
   mov [StartLine],edi
  @ENoNextLine:
  Ret
 ENDP


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC EndScroller
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  mov [FlipFlop],3
  mov [StartLine], O EndScroll
  mov [StartPos],320*25
  mov [TimerCalled],O EndTimer
  @EndScrollLoop:
   mov edi,[Buf0]
   add edi,[StartPos]
   mov edx,[StartLine]
   mov ecx,9
   @Lines:
    cmp edx,O Finish
    jae @NoMoreLines
    Call WriteStr
    add edi,25*320
    dec ecx
   jne @Lines
   @NoMoreLines:
   CopyScreen
   cmp [StartLine],O AlpOn
   jne @NoAlpineWhite
    cmp [StartPos],320*10
    jne @NoAlpineWhite
     mov edi,[Buf2]
     add edi,320*60+36
     mov edx,O Alpine
     Call WriteStr
     mov [Alp2+4],42
   @NoAlpineWhite:
   mov esi,[Buf2]
   mov edi,[Buf1]
   mov ecx,16000
   rep movsd
   Call GetKey
   jnz @EKey
  cmp [StartLine],O Alp2
  jne @EndScrollLoop
  clc
  Ret
  @EKey:
  stc
  Ret
 ENDP