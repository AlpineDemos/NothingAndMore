 INCLUDE "N_SKY.ASM"
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC CALCANGLEDEPTH
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  mov edi, [Buf2]
  mov ebx, [Buf1]
  mov esi, O temp_int3
  mov ecx, 200
  @YLoop1:
    mov edx, 320
    @XLoop2:
       mov eax, ecx
       sub eax, 100
       mov [esi], ax
       fild [w esi]
       mov eax, edx
       sub eax, 160
       mov [esi], ax
       jnz @NoIncESI2
         inc [w esi]
       @NoIncESI2:
       fild [w esi]
       fpatan
       fst st(1)
       fcos
       fimul [RadDist]
       mov eax, edx
       sub eax, 160
       mov [esi], ax
       jnz @NoIncESI
         inc [w esi]
       @NoIncESI:
       fidiv [w esi]
       fistp [w edi]
       not [b edi]
       inc edi
       fmul [Pi128]
       fistp [w ebx]
       inc ebx
    dec edx
    jnz @XLoop2
  loop @YLoop1
  ret
 endp

temp_int3 dw 0
RadDist   dw 100*50
Pi128     dd 40.74366543

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC TunnelTimer
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
   Call TimerCopy
   xor eax,eax
   mov edx,[TunnelX]
   mov ebx,[TunnelVX]
   mov ah,[TunnelY]
   add edx,ebx
   cmp ebx,01D0h
   je @T_SUB
   cmp ebx,-1E0h
   je @T_ADD
   @TCALC:
   add ebx,10h
   mov [TunnelX],edx
   mov [TunnelVX],ebx
   inc ah
   mov [TunnelY],ah
   Cmp [EndTunnel],0
   jne @NoTunnelOut
    xor al,al
    add ah,24
    neg ah
    mov edi,eax
    add edi,[Buf2]
    mov ecx,64
    xor eax,eax
    rep stosd
   @NoTunnelOut:
   dec [Counter]
   jz @TunnelOut
   Ret
   @T_ADD:
    mov al,0C3h
    mov [b @TCALC+1],al
    jmp @TCALC
   @T_SUB:
    mov al,0EBh
    mov [b @TCALC+1],al
    jmp @TCALC
   @TunnelOut:
    inc [EndTunnel]
    jnz @No2Nd
    mov edi,[Buf2]
    mov eax,46464646h
    mov ecx,128
    rep stosd
    mov eax,4b4b4b4bh
    mov ecx,64
    rep stosd
    mov eax,4e4e4e4eh
    mov ecx,64
    rep stosd
    mov [Counter],300
    Ret
   @No2nd:
    mov [TimerCalled],O TimerCopy
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC TUNNEL
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;

  mov esi,[Buf2]
  mov edi,[Buf3]  ; Last Byte = Backgrnd
  add edi,3
  mov ecx,64000
  @InitTunnel4:
   movsb
   add edi,3
   dec ecx
  jne @InitTunnel4

  Call CALCANGLEDEPTH
  mov esi,[Buf1]
  mov edi,[Buf3]
  mov ecx,64000
  @InitTunnel1:
   movsb
   add edi,3
   dec ecx
  jne @InitTunnel1
  mov esi,[Buf2]
  mov edi,[Buf3]
  inc edi
  mov ecx,64000
  @InitTunnel2:
   movsb
   add edi,3
   dec ecx
  jne @InitTunnel2

  @WaitTunnel1:
   Call GetKey
   jnz @TKey
   cmp [TM3SyncCount],0C0h
  jb @WaitTunnel1

  xor al,al
  mov dx,3c8h
  out dx,al
  inc dx
  mov al,63
  mov ecx,768
  @F1:
  out dx,al
   dec ecx
  jne @F1

  xor eax,eax
  mov edi,[Buf1]
  mov ecx,16000
  rep stosd
  mov edi,[Buf1]
  add edi,100*320+160
  mov eax,78
  xor cl,cl
  @FCLoop:
   mov [B @CircleLoop+1],cl
   Call FilledCircle
   inc cl
   sub eax,2
  jne @FCLoop
  mov eax,18
  mov [B @CircleLoop+1],90
  Call FilledCircle
  mov edi, [Buf1]
  mov ecx,80*23
  mov eax,0F0F0F0Fh
  rep stosd

  mov esi,[Buf1]
  mov edi,[Buf3]
  add edi,2
  mov ecx,64000
  @InitTunnel3:
   movsb
   add edi,3
   dec ecx
  jne @InitTunnel3
  xor eax,eax
  mov edi,[Buf2]
  mov ecx,16384
  rep stosd
  mov edi,[Buf2]
  mov edx,8
  @InitTunnel5:
   mov eax,46464646h
   mov ecx,128
   rep stosd
   mov eax,4b4b4b4bh
   mov ecx,64
   rep stosd
   mov eax,4e4e4e4eh
   mov ecx,64
   rep stosd
   mov eax,50505050h
   mov ecx,192
   rep stosd
   mov eax,4e4e4e4eh
   mov ecx,64
   rep stosd
   mov eax,4b4b4b4bh
   mov ecx,64
   rep stosd
   mov eax,46464646h
   mov ecx,128
   rep stosd
   add edi,5376
   dec edx
  jne @InitTunnel5

  mov edi,[Buf2]
  mov edx,8*256
  @InitTunnel6:
   mov al,70
   cmp [edi],al
   ja @NoSet0
    mov [edi],al
   @NoSet0:
   mov al,75
   cmp [edi+1],al
   ja @NoSet1
    mov [edi+1],al
   @NoSet1:
   mov al,78
   cmp [edi+2],al
   ja @NoSet2
    mov [edi+2],al
   @NoSet2:
   mov al,80
   cmp [edi+3],al
   ja @NoSet3
    mov [edi+3],al
   @NoSet3:
   cmp [edi+4],al
   ja @NoSet4
    mov [edi+4],al
   @NoSet4:
   mov al,78
   cmp [edi+5],al
   ja @NoSet5
    mov [edi+5],al
   @NoSet5:
   mov al,75
   cmp [edi+6],al
   ja @NoSet6
    mov [edi+6],al
   @NoSet6:
   mov al,70
   cmp [edi+7],al
   ja @NoSet7
    mov [edi+7],al
   @NoSet7:
   add edi,32
   dec edx
  jne @InitTunnel6

  mov [PicReady],0
  xor eax,eax
  mov [TunnelX],eax
  mov [TunnelVX],eax
  mov [TunnelY],al
  mov [EndTunnel],-1

  mov [TimerCalled],O TunnelTimer
  mov [COUNTER],232+256*2

  mov esi,[Pal1P]
  Call SetPal

;殯굅같같같같같같같같같같같같같같같같같같같같같같같같같같같같� Main Tunnel  같
  mov eax,[Buf2]
  mov [Buf2P],eax
  xor eax,eax
  @MainTunnelLoop:
   xor ecx,ecx
   mov esi, [Buf3]
   mov edi, [Buf1]
   mov edx, [TunnelX]
   mov ah,  [TunnelY]
   mov ebp, 64000
   @PicLoop:
     mov cx,[esi]
     add cl,dh
     sub ch,ah
     dw 818Ah           ; mov al,[Buf2+ecx]
  Buf2P dd ?
     or al,al
     jz @BackGrnd
       sub al,[esi+2]
       js @BackGrnd
       stosb
       add esi,4
       dec ebp
       jne @PicLoop
       jmp @NXTunnel
     @BackGrnd:
     add esi,3
     lodsb
     sub al,[esi-2]
     js @ClearBackGrnd
     stosb
     dec ebp
   jne @PicLoop
   jmp @NxTunnel
   @ClearBackGrnd:
     xor al,al
     stosb
     dec ebp
   jne @PicLoop
   @NXTunnel:
   cmp [Counter],0
   je @WaitTunnel
   mov edi, [Buf1]
   add edi,2*320
   mov edx,O TNothing
   Call WriteStr
   CopyScreen
   Call GetKey
   jnz @TKey
  jmp  @MainTunnelLoop
  mov [TimerCalled],O DummyTimer
  @WaitTunnel:
   Call GetKey
   jnz @TKey
   cmp [TM3SyncCount],142h
  jb @WaitTunnel
  mov esi, [Buf1]
  mov edi, [SkyBuf]
  mov ecx,16000
  rep movsd
  clc
  Ret
  @TKey:
  mov [TimerCalled],O DummyTimer
  stc
  Ret
 ENDP
