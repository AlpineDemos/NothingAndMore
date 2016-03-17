;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÛÛßßÜ ÛÛßßÜ ßßßÛÜ ÛÛ  Û ÛÜ ÛÛßßÜ ÛÛßßÜ
; ÛÛ  Û ÛÛ  Û    ÛÛ ÛÛßßÛ ÛÛ ÛÛ  Û ÛÛ
; ÛÛ  Û ÛÛ  Û    ÛÛ ÛÛ  Û ÛÛ ÛÛ  Û ÛÛ ßÛ
; ÛÛ  Û ÛÛÜÜÛ    ÛÛ ÛÛ  Û ÛÛ ÛÛ  Û ÛÛÜÜÛ AND MORE       (C) 1997 by Alpine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Flame-Routines...
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC SETPOINTS  ;  D: ---    N: BX=Range  R: AX: RND-Num
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov ecx, [MaxPoints]
  mov esi, [Points]
  xor ebx, ebx
  xor edx, edx
  @LoopPoints:
   mov dx, [esi]                 ; Points.VY
   mov ebx,edx                   ; Save!
   add dx, [esi+2]               ; + Points.Y
   mov [esi+2],dx
   shr edx, 8                    ; EAX ohne $66!
   inc edx
   mov edi, [YCoord+EDX*4]
   add edi, [esi+4]
   inc edi
   shr dl,1
   sub dl,36
   mov al,dl
   stosb
   mov ah,dl
   stosw
   add bx, 8
   mov [esi],bx
   js @NoPlus
    mov [w esi+2],0C500h
    mov bx,650
    Call Random
    neg dx
    mov [esi],dx
    mov bx, 316
    Call Random
    mov [esi+4],dx
    xor edx, edx
   @NoPlus:
   add esi,8
   dec ecx
  jne @LoopPoints
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC SETUPFIREPAL ; D:all  N: ---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 xor eax,eax       ; Clear both Palettes!
 mov edi,[Pal1P]
 mov ecx,384
 rep stosd

 mov edi, [Pal1P]    ; Set Palette
 mov ecx,24
 xor ebx,ebx
 @PalL1:
  mov [edi  ],bl
  mov [edi+1],ch
  mov [edi+2],ch
  add bl,2
  add edi,3
  dec ecx
 jne @PalL1
 ;----------------
 mov ecx,15
 xor eax,eax
 @PalL2:
  mov [edi],bl
  mov [edi+1],ah
  mov [edi+2],ch
  inc bl
  add eax,404
  add edi,3
  dec cl
 jne @PalL2
 ;----------------
 dec bl
 mov cl,25
 @PalL3:
  mov [edi],bl
  mov [edi+1],ah
  mov [edi+2],ch
  add eax,404
  add edi,3
  dec cl
 jne @PalL3
 mov esi, [Pal1P]
 mov edi, [Pal1P]
 add edi, 128*3
 mov ecx, 3*64
 rep movsb
 mov esi, [Pal1P]
 mov ecx, 3*64
 rep movsb
 Ret
 ENDP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC ProcessFire ; D:all  N: ---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  Call SetPoints
  mov esi,[Buf1]
  add esi,320*80
  mov edi,[Buf3]
  add edi,320*80
  mov ecx,80*119
  Call Blur
  mov esi,[Buf3]
  add esi,320*80
  mov edi,[Buf1]
  add edi,320*80
  mov ecx,80*119
  Call Blur                     ; Final Screen in BUF1
  MOV edi,[buf1]
  mov ebx, [AlpHeight]
  shr ebx, 16
  shl ebx, 2
  mov edi,[YCoord+EBX]
  add edi,30
  mov edx, O Alpine
  Call WriteOrStr
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC FireTimer1  ; D:all  N: ---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  Call TimerCopy
  Xor [FadeFlag],1
  jne @NoFade
  mov cl, 64
  mov edi,[Pal1P]
  add edi,128*3
  @Highlight1:
    mov al,[edi]
    cmp al,63
    je @NoH0
     inc al
    @NoH0:
    mov [edi],al
    mov al,[edi+1]
    cmp al,63
    je @NoH1
     inc al
    @NoH1:
    mov [edi+1],al
    mov al,[edi+2]
    cmp al,63
    je @NoH2
     inc al
    @NoH2:
    mov [edi+2],al
    add edi,3
    dec cl
  jne @HighLight1
  mov cl,64
  @Highlight2:
    mov al,[edi]
    cmp al,40
    je @NoI0
     ja @NoI0A
      inc al
      jmp @NoI0
     @NoI0A:
      dec al
      jmp @NoI0
    @NoI0:
    mov [edi],al
    mov al,[edi+1]
    cmp al,40
    je @NoI1
     ja @NoI1A
      inc al
      jmp @NoI1
     @NoI1A:
      dec al
      jmp @NoI1
    @NoI1:
    mov [edi+1],al
    mov al,[edi+2]
    cmp al,40
    je @NoI2
     inc al
    @NoI2:
    mov [edi+2],al
    add edi,3
    dec cl
  jne @HighLight2

  @NoFade:
  mov eax,[AlpInc]
  mov ebx,[AlpHeight]
  sub eax,200h
  jns @EAXM
   xor eax,eax
  @EAXM:
  mov [AlpInc],eax
  sub ebx,eax
  mov [AlpHeight],ebx
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC FIRE
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 mov edi,[buf3]
 xor eax,eax
 mov ecx,16000
 rep stosd
 Call SetupFirePal
 mov [AlpHeight], 910000h
 mov [AlpINC], 14000h
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Init Points °°°°
 xor cx, cx             ; Init Point-Data
 mov esi,[Points]
 xor ebx, ebx
 xor edx, edx
 @StartPoints:
  mov [w esi+2],0C500h
  mov bx,650
  Call Random
  neg dx
  mov [esi],dx
  mov bx, 316
  Call Random
  and edx,0FFFFh
  mov [esi+4],edx
  add esi,8
  inc cx
  cmp cx,7000
 jne @StartPoints

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Fade In + Inc Points °°°°
 mov [TimerCalled],O TimerCopy
 mov [COLCOUNT],70
 mov [MaxPoints],0
 @LoopitIn:
  add [MaxPoints],100
  Call FadeIn
  mov esi,[Pal2P]
  Call SetPAL
  Call ProcessFire
  Call CopyClearScreen
  Call GetKey
  jnz @KPressed
 dec [COLCOUNT]
 jnz @LoopItIn
 @Loopit0:
  Call ProcessFire
  Call CopyClearScreen
  Call GetKey
  jnz @KPressed
  cmp [TM3SyncCount],20h
 jbe @LoopIt0


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° MainLoop °°°°
 mov [TimerCalled], O FireTimer1
 @Loopit1:
  Call ProcessFire
  mov esi,[Pal1P]
  add esi,128*3
  mov dx,3c8h
  mov al,128
  out dx,al
  inc dx
  mov cx,384
  cli
  rep outsb
  sti
  Call CopyClearScreen
  Call GetKey
  jnz @KPressed
  cmp [TM3SyncCount],40h
 jbe @LoopIt1
 mov [TimerCalled],O TimerCopy
 mov edi,[Pal1P]
 mov esi,edi
 add edi,254*3
 mov ax,2828h
 stosw
 stosb
 mov ax,3f3fh
 stosw
 stosb
 Call SetPal
 @LoopIt2:
  Call ProcessFire
  mov edi,[Buf1]
  add edi,110*320+108
  mov edx,O Present
  Call WriteStr
  Call CopyClearScreen
  Call GetKey
  jnz @KPressed
  cmp [TM3SyncCount],50h
 jbe @LoopIt2

 @LoopIt3:
  Call ProcessFire
  mov edi,[Buf1]
  add edi,110*320+108
  mov edx,O Present
  Call WriteStr
  add edi,20*320-10
  Call WriteStr
  Call CopyClearScreen
  Call GetKey
  jnz @KPressed
  cmp [TM3SyncCount],60h
 jbe @LoopIt3

 @LoopIt4:
  Call ProcessFire
  mov edi,[Buf1]
  add edi,110*320+108
  mov edx,O Present
  Call WriteStr
  add edi,20*320-10
  Call WriteStr
  add edi,20*320-3
  Call WriteStr
  Call CopyClearScreen
  Call GetKey
  jnz @KPressed
  cmp [TM3SyncCount],70h
 jbe @LoopIt4

 @LoopIt5:
  Call ProcessFire
  mov edi,[Buf1]
  add edi,110*320+108
  mov edx,O Present
  Call WriteStr
  add edi,20*320-10
  Call WriteStr
  add edi,20*320-3
  Call WriteStr
  add edi,20*320+28
  Call WriteStr
  Call CopyClearScreen
  Call GetKey
  jnz @KPressed
  cmp [TM3SyncCount],81h
 jbe @LoopIt5

 mov [TimerCalled],O DummyTimer
 clc
 Ret

 @KPressed:
  stc
  Ret
 ENDP

