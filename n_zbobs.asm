;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC SetZBob  ; D:All, N: EBX = X, EDI = Y
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  SPHEREX = 46
  SPHEREY = 38
  pushad
  mov esi,O Sphere
  mov ebp, SPHEREY-1      ; JNS!
  or edi,edi
  jns @NoClipU
   neg edi
   sub ebp,edi
   js @EndZB
   mov eax,SPHEREX
   mul edi
   add esi,eax
   xor edi,edi
  @NoClipU:
  cmp edi, 200-SPHEREY
  jbe @NoClipD
   mov eax, edi
   sub eax,200-SPHEREY
   sub ebp,eax
   js @EndZB
  @NoClipD:
  shl edi,2
  mov edi,[YCOORD+edi]    ; Y-Coord Ready.
  add edi,ebx
  mov edx,320-SPHEREX
  mov ecx,SPHEREX-1       ; JNS
  or ebx,ebx
  jns @NoClipL
   neg ebx
   add edi,ebx   ; X=0!
   add esi,ebx
   sub ecx,ebx
   js  @EndZB
   add edx,ebx
   jmp @NoClipX
  @NoClipL:
  cmp ebx,320-SPHEREX
  jbe @NoClipR
   sub ebx,320-SPHEREX
   sub ecx,ebx
   js @EndZB
   add edx,ebx
   jmp @NoClipX
  @NoClipR:
   xor ebx,ebx
  @NoClipX:
  @ZBYLoop:
   mov ch,cl     ; CH = XWIDTH
   @ZBXLoop:
    lodsb
    mov ah,[edi]
    cmp al,ah
    jb @NoStore
     mov [edi],al
    @NoStore:
    inc edi
    dec ch
   jns @ZBXLoop
   add edi,edx
   add esi,ebx
   dec ebp
  jns @ZBYLoop
  @EndZB:
  popad
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC RotateBobs  ;D:all  N:--
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
   mov ebp,[GPSinTable]
   mov eax,[NextStep]
   mov [Nxt1],eax
   mov eax,[NextStep2]
   mov [Nxt2],eax
   xor eax,eax
   mov [NextStep] ,eax
   mov [NextStep2],eax
   mov esi,O Angles
   @Rotate:
    mov ecx,[esi]
    add ecx,[Nxt1]
    and ecx,16383
    mov [esi],ecx
    mov ebx,[ebp+ecx]
    mov eax,[R1]
    imul ebx
    sar eax,16
    mov edi,eax
    push edi
    mov ecx,[esi+4]
    add ecx,[Nxt2]
    and ecx,16383
    mov [esi+4],ecx
    mov ebx,[ebp+ecx]
    mov eax,[R21]
    imul ebx
    sar eax,16
    push eax
    add edi,eax
    add edi,100-19

    add ecx,4096
    and ecx,16383
    mov ebx,[ebp+ecx]
    mov eax,[R22]
    imul ebx
    sar eax,16
    mov ebx,eax
    push ebx
    mov ecx,[esi]
    add ecx,4096
    and ecx,16383
    mov ecx,[ebp+ecx]
    mov eax,[R1]
    imul ecx
    sar eax,16
    push eax
    add ebx,eax         ;DAN
    add ebx,160-23

    Call SetZBob
    pop eax
    pop ebx
    sub ebx,eax
    add ebx,160-23
    pop edi
    pop eax
    sub edi,eax
    add edi,100-19
    Call SetZBob
    add esi,8
    cmp esi,O Angles+8*8
   jne @Rotate
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ControlXPlode ;D:all  N:--
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  mov esi, [GPSinTable]
  mov ebp, [Buf3]
  mov ecx, [MaxPoints]
  @EBobLoop:
    mov eax,[ebp]
    mov ebx,[esi+eax]
    shl ebx,2
    add ebx,[ebp+4]
    add eax,4096
    and eax,16383
    mov edi,[esi+eax]
    shl edi,2
    add edi,[ebp+8]

    mov [ebp+4],ebx
    mov [ebp+8],edi
    sar ebx,16
    sar edi,16
    Call SetZBob
    add ebp,16
    dec ecx
  jne @EBobLoop
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ZBobTimer1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  Call Timercopy
  add [NextStep],-4*64
  add [NextStep2],4*16
  add [d R21f],2200h
  add [d R22f],3200h
  dec [Counter]
  jz @ZT2
  Ret
  @ZT2:
  mov [TimerCalled], O ZBobTimer2
  mov [Counter],1024
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ZBobTimer2
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  Call Timercopy
  add [NextStep],-4*64
  add [NextStep2],4*16
  add [d r1f],05C0h
  dec [Counter]
  jz @ZT3
  Ret
  @ZT3:
  mov [TimerCalled], O ZBobTimer3
  mov [Counter],256
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ZBobTimer3
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  Call Timercopy
  add [NextStep],-4*64
  add [NextStep2],4*16
  add [d R21f],2200h
  add [d R22f],3200h
  dec [Counter]
  jz @ZT4
  Ret
  @ZT4:
  mov [TimerCalled], O ZBobTimer4
  mov [Counter],454
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ZBobTimer4
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  Call Timercopy
  add [NextStep],-4*64
  add [NextStep2],4*16
  dec [Counter]
  jz @ZT5
  Ret
  @ZT5:
  mov [TimerCalled], O ZBobTimer5
  mov [Counter],256
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ZBobTimer5
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  Call Timercopy
  add [NextStep],-4*64
  add [NextStep2],4*16
  cmp [r1],0
  je @NoLR1
   sub [d r1f],1700h
  @NoLR1:
  sub [d R21f],4400h
  sub [d R22f],6400h
  dec [Counter]
  jz @ZT6
  Ret
  @ZT6:
  mov [TimerCalled], O ZBobTimer6
  mov [Counter],600
  mov [EndTunnel],1
  mov [MaxPoints],2
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ZBobTimer6
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  Call Timercopy
  xor [FlipFlop],1
  jz @NoIncPoints
  cmp [MaxPoints],100
  je @NoIncPoints
   inc [MaxPoints]
  @NoIncPoints:
  dec [Counter]
  jz @ZT7
  Ret
  @ZT7:
  mov [TimerCalled], O TimerCopy
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC ZBobs
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 mov dx,3c8h
 xor al,al
 out dx,al
 inc dx
 mov cl,64
 @GreyL:
  out dx,al
  out dx,al
  out dx,al
  inc al
 dec cl
 jne @GreyL

 mov esi,O GPal
 mov dx,3c8h
 mov al,64
 out dx,al
 inc dx
 mov ecx,138
 rep outsb

 mov dx,3c8h
 mov al,254
 out dx,al
 inc dx
 mov al,40
 out dx,al
 out dx,al
 out dx,al
 mov al,63
 out dx,al
 out dx,al
 out dx,al

 mov dx,3c8h
 mov al,128
 out dx,al
 inc dx
 mov al,63
 out dx,al
 out dx,al
 out dx,al
 mov dx,3c8h
 mov al,192
 out dx,al
 inc dx
 mov al,40
 out dx,al
 out dx,al
 out dx,al

 mov edi,O Angles
 mov ecx,8
 xor eax,eax
 xor ebx,ebx
 @CalcPositions:
  mov [edi]  , ebx   ; Bob 1
  mov [edi+4], eax
  add eax,2048
  and eax,16383
  add ebx,4096
  and ebx,16383
  add edi,8
  dec ecx
 jne @CalcPositions

 mov edi,[Buf2]
 mov ecx,16000
 xor eax,eax
 rep stosd
 add edi,320*60+36 - 64000
 mov edx,O Alpine
 Call WriteStr

 mov esi,[Buf2]
 mov edi,esi
 mov ecx,64000
 mov dl,9h
 @SetAlp:
  lodsb
  test al,192
  jz  @NoA1
    mov [b esi-1],dl
  @NoA1:
  dec ecx
 jne @SetAlp

 mov ecx,8FA00h         ; Texture
 @MakeBackGround:
  mov bx,64000
  Call Random
  and edx,0FFFFh
  inc [b edi+edx]
  dec ecx
 jne @MakeBackGround

 xor eax,eax
 mov [R1], eax
 mov [R21],eax
 mov [R22],eax
 mov [NextStep],eax
 mov [NextStep2],eax
 mov esi,[Buf2]
 mov edi,[Buf1]
 mov ecx,16000
 rep movsd
 mov ebx,160-23
 mov edi,100-19
 Call SetZBob
 mov esi,[Buf2]
 mov edi,[Buf1]
 mov ecx,16000
 rep movsd

 @WaitZ:
  Call GetKey
  jnz @ZKey
  cmp [TM3SyncCount],180h
 jbe @WaitZ

 mov [Counter],256
 mov [TimerCalled],O ZBobTimer1
 mov [EndTunnel],0
 @MainZBobLoop:
   Call RotateBobs
   Copyscreen
   mov esi,[Buf2]
   mov edi,[Buf1]
   mov ecx,16000
   rep movsd
   Call GetKey
   jnz @ZKey
   cmp [EndTunnel],0
 je @MainZBobLoop

 mov edi,[Buf3]
 mov ecx, 100
 @CalcBobExplosion:
  mov bx,4096
  Call Random
  and edx,0FFFFh
  shl edx,2
  mov [d edi],   edx
  mov [d edi+4], 0890000h
  mov [d edi+8], 0510000h
  add edi,16
  dec ecx
 jne @CalcBobExplosion

 @ExplodeLoop:
  Call ControlXPlode
  CopyScreen
  mov esi,[Buf2]
  mov edi,[Buf1]
  mov ecx,16000
  rep movsd
  Call GetKey
  jnz @ZKey
  cmp [Counter],0
 jne @ExplodeLoop

 clc
 Ret
 @ZKey:
 stc
 Ret
 ENDP
