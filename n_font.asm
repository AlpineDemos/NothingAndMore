;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; 栢賽� 栢賽� 賽賞� 栢  � 白 栢賽� 栢賽�
; 栢  � 栢  �    栢 栢賽� 栢 栢  � 栢
; 栢  � 栢  �    栢 栢  � 栢 栢  � 栢 賞
; 栢  � 栢複�    栢 栢  � 栢 栢  � 栢複� AND MORE       (C) 1997 by Alpine
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Font-Routines...
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC WRITEORSTR ; D: ALL N: EDI = StartOffset, EDX = Pointer to String
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  push ecx edi
   mov ebx,edi
   @OrWriteSTRLoop:
    xor eax,eax
    mov ebp,eax
    mov ecx,eax
    mov al, [edx]
    inc al
    jz @OrEndWriteSTR
    dec al
    shl eax,2
    mov esi,[LetterOfs+eax]
    mov bp,[esi]        ; Inc-Factor am Ende einer Zeile.
    mov ah,[esi+2]
    add esi,3

    @OrLetterLoop:
     lodsb
     dec al
     js @OrUnPacked
      jz @OrEndRow
      mov cl,al
      lodsb
      dec al
      jz @OrZeroCol
      @F2Loop:
       or [edi],al
       inc edi
       dec cl
      jne @F2Loop
      jmp @OrLetterLoop
     @OrUnPacked:
     or [edi],al
     inc edi
     jmp @OrLetterLoop
     @OrEndRow:
     add edi,ebp
     dec ah
    jne @OrLetterLoop
    neg ebp
    add ebp,320
    add ebx,ebp
    mov edi,ebx
    inc edx
   jmp @OrWriteSTRLoop
   @OrEndWriteSTR:
   inc edx
   pop edi ecx
  Ret
  @OrZeroCol:
    add edi,ecx
    jmp @OrLetterLoop
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC WRITESTR ; D: ALL N: EDI = StartOffset, EDX = Pointer to String
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  push ecx edi
   mov ebx,edi
   @WriteSTRLoop:
    xor eax,eax
    mov ebp,eax
    mov ecx,eax
    mov al, [edx]
    inc al
    jz @EndWriteSTR
    dec al
    shl eax,2
    mov esi,[LetterOfs+eax]
    mov bp,[esi]        ; Inc-Factor am Ende einer Zeile.
    mov ah,[esi+2]
    add esi,3

    @LetterLoop:
     lodsb
     dec al
     js @UnPacked
      jz @EndRow
      mov cl,al
      lodsb
      dec al
      jz @ZeroCol
      rep stosb
      jmp @LetterLoop
     @UnPacked:
     stosb
     jmp @LetterLoop
     @EndRow:
     add edi,ebp
     dec ah
    jne @LetterLoop
    neg ebp
    add ebp,320
    add ebx,ebp
    mov edi,ebx
    inc edx
   jmp @WriteSTRLoop
   @EndWriteSTR:
   inc edx
   pop edi ecx
  Ret
  @ZeroCol:
    add edi,ecx
    jmp @LetterLoop

 ENDP
