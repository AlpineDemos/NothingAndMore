;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÛÛßßÜ ÛÛßßÜ ßßßÛÜ ÛÛ  Û ÛÜ ÛÛßßÜ ÛÛßßÜ
; ÛÛ  Û ÛÛ  Û    ÛÛ ÛÛßßÛ ÛÛ ÛÛ  Û ÛÛ
; ÛÛ  Û ÛÛ  Û    ÛÛ ÛÛ  Û ÛÛ ÛÛ  Û ÛÛ ßÛ
; ÛÛ  Û ÛÛÜÜÛ    ÛÛ ÛÛ  Û ÛÛ ÛÛ  Û ÛÛÜÜÛ AND MORE       (C) 1997 by Alpine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Font-Routines...
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC WRITEORSTR ; D: ALL N: EDI = StartOffset, EDX = Pointer to String
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
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

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC WRITESTR ; D: ALL N: EDI = StartOffset, EDX = Pointer to String
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
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
