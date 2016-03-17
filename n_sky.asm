;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC BLUR   ;  D: ALL    N: ESI=Source, EDI=Dest, ECX=Num of Bytes / 4
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  @BlurLoop:
   mov eax,[esi]
   add eax,[esi+1]
   add eax,[esi+320]
   add eax,[esi+321]
   and eax,0FCFCFCFCh
   shr eax,2
   stosd
   add esi,4
   dec ecx
  jne @BlurLoop
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC BLUR256  ;  D: ALL    N: ESI=Source, EDI=Dest, ECX=Num of Bytes / 4
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  @BlurLoop256:
   mov eax,[esi]
   add eax,[esi+1]
   add eax,[esi+256]
   add eax,[esi+257]
   and eax,0FCFCFCFCh
   shr eax,2
   stosd
   add esi,4
   dec ecx
  jne @BlurLoop256
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC FilledCircle  ;  D: ---  N: EDI = Position in Buffer, EAX=Radius
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pushad
   mov ebp, edi
   mov esi, eax
   shl esi, 1
   neg esi
   inc esi        ; ESI = Error
   mov edx,eax    ; EDX = Y
   xor ebx,ebx    ; EBX = X
   @CircleLoop:
     mov al,28h   ; Code-Manipulation!
     mov edi,ebx
     shl edi,6
     lea edi,[edi+edi*4] ; YM+X
     add edi,ebp         ; + YM*320 + XM
     sub edi,edx         ; - Y
     mov ecx,edx
     shl ecx,1
     inc ecx
     rep stosb

     mov edi,ebx
     shl edi,6
     lea edi,[edi+edi*4] ; YM-X
     neg edi
     add edi,ebp         ; + YM*320 + XM
     sub edi,edx         ; - Y
     mov ecx,edx
     shl ecx,1
     inc ecx
     rep stosb

     or esi,esi
     js @NoIncY
       mov edi,edx
       shl edi,6
       lea edi,[edi+edi*4] ; YM+Y
       add edi,ebp         ; + YM*320 + XM
       sub edi,ebx         ; - X
       mov ecx,ebx
       shl ecx,1
       inc ecx
       rep stosb

       mov edi,edx
       neg edi
       shl edi,6
       lea edi,[edi+edi*4] ; YM-Y
       add edi,ebp         ; + YM*320 + XM
       sub edi,ebx         ; - X
       mov ecx,ebx
       shl ecx,1
       inc ecx
       rep stosb

       dec edx
       mov eax,edx
       shl eax,2
       sub esi,eax
       add esi,4
     @NoIncY:
     mov eax,ebx
     shl eax,2
     add eax,2
     add esi,eax
     inc ebx
    cmp ebx,edx
   jbe @CircleLoop
  popad
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC FilledCircle256  ;  D: ---  N: EDI = Position in Buffer, EAX=Radius
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pushad
   mov ebp, edi
   mov esi, eax
   shl esi, 1
   neg esi
   inc esi        ; ESI = Error
   mov edx,eax    ; EDX = Y
   xor ebx,ebx    ; EBX = X
   @CircleLoop2:
     mov al,28h   ; Code-Manipulation!
     mov edi,ebx
     shl edi,8
     add edi,ebp         ; + YM*320 + XM
     sub edi,edx         ; - Y
     mov ecx,edx
     shl ecx,1
     inc ecx
     rep stosb

     mov edi,ebx
     shl edi,8
     neg edi
     add edi,ebp         ; + YM*320 + XM
     sub edi,edx         ; - Y
     mov ecx,edx
     shl ecx,1
     inc ecx
     rep stosb

     or esi,esi
     js @NoIncY2
       mov edi,edx
       shl edi,8
       add edi,ebp         ; + YM*320 + XM
       sub edi,ebx         ; - X
       mov ecx,ebx
       shl ecx,1
       inc ecx
       rep stosb

       mov edi,edx
       neg edi
       shl edi,8
       add edi,ebp         ; + YM*320 + XM
       sub edi,ebx         ; - X
       mov ecx,ebx
       shl ecx,1
       inc ecx
       rep stosb

       dec edx
       mov eax,edx
       shl eax,2
       sub esi,eax
       add esi,4
     @NoIncY2:
     mov eax,ebx
     shl eax,2
     add eax,2
     add esi,eax
     inc ebx
    cmp ebx,edx
   jbe @CircleLoop2
  popad
  Ret
 ENDP


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC NOISE      ;  D: ---
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pushad
  mov ecx,64000-5*320
  mov esi,[Buf1]
  @NoiseLoop:
   mov ebx,3
   Call Random
   xor edi,edi
   mov di,dx
   dec edi
   shl edi,6
   lea edi,[edi*4+edi]
   mov ebx,5
   Call Random
   and edx,0FFFFh
   add edi,edx
   add edi,esi
   movsb
   dec ecx
  jne @NoiseLoop
  popad
  Ret
 ENDP


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC NOISE256   ;  D: ---
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pushad
  mov ecx,65536-5*256
  mov esi,[Buf1]
  @NoiseLoop2:
   mov ebx,3
   Call Random
   xor edi,edi
   mov di,dx
   dec edi
   shl edi,8
   mov ebx,5
   Call Random
   and edx,0FFFFh
   add edi,edx
   add edi,esi
   movsb
   dec ecx
  jne @NoiseLoop2
  popad
  Ret
 ENDP


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC CREATESKY ; D:---  [SOURCE] = Buffer
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  mov edi,[Buf1]         ; SetBackGround
  xor edx,edx
  xor ecx,ecx
  @SetBackGround:
   mov cl,160
   mov al,dl
   shr al,3
   inc al
   mov ah,al
   rep stosw
   inc dl
   cmp dl,200
  jne @SetBackGround
  mov esi,[Buf1]         ; CircleLoop!
  xor edx,edx
  mov ecx, 420
  mov [B @CircleLoop+1],28h
  @SetCircles:
   mov bx, 190
   Call Random
   add dx,5
   xor edi,edi
   mov di,dx
   mov eax,200
   sub al,dl
   shr al,5
   inc al
   shl edi,6
   lea edi,[edi*4+edi]
   mov bx,320
   push eax
    Call Random
   pop eax
   and edx,0FFFFh
   add edi,edx
   add edi,esi
   Call FilledCircle
   dec ecx
  jne @SetCircles
  Call Noise
  Call Noise
  Call Noise
  Call Noise
  mov esi,[Buf1]
  mov edi,[Buf2]
  mov ecx,16000-80
  Call Blur
   mov ecx,80
  rep movsd
  mov esi,[Buf2]
  mov edi,[Buf1]
  mov ecx,16000-80
  Call Blur
  mov ecx,80
  rep movsd
  mov esi,[Buf1]
  mov edi,[Buf2]
  mov ecx,16000-80
  Call Blur
  mov ecx,80
  rep movsd
  mov esi,[Buf2]
  mov edi,[Buf1]
  mov ecx,16000-80
  Call Blur
  mov ecx,80
  rep movsd
  mov esi,[Buf1]
  mov edi,[SkyBuf]
  mov ecx,16000-80
  Call Blur
  mov ecx,80
  rep movsd
  Ret
 ENDP


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC CREATESKY256 ; D:---  [SOURCE] = Buffer
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  mov edi,[Buf1]         ; SetBackGround
  xor edx,edx
  xor ecx,ecx
  @SetBackGround2:
   mov cl,128
   mov al,dl
   shr al,4
   inc al
   mov ah,al
   rep stosw
   inc dl
  jnz @SetBackGround2
  mov esi,[Buf1]         ; CircleLoop!
  xor edx,edx
  mov ecx, 350
  mov [B @CircleLoop2+1],28h
  @SetCircles2:
   mov bx, 246
   Call Random
   add dx,5
   xor edi,edi
   mov di,dx
   mov eax,256
   sub ax,dx
   sar ax,5
   inc ax
   shl edi,8
   mov bx,256
   push eax
    Call Random
   pop eax
   and edx,0FFFFh
   add edi,edx
   add edi,esi
   Call FilledCircle256
   dec ecx
  jne @SetCircles2
  Call Noise256
  Call Noise256
  Call Noise256
  Call Noise256
  mov esi,[Buf1]
  mov edi,[Buf2]
  mov ecx,16384-64
  Call Blur256
  mov ecx,64
  rep movsd
  mov esi,[Buf2]
  mov edi,[Buf1]
  mov ecx,16384-64
  Call Blur256
  mov ecx,64
  rep movsd
  mov esi,[Buf1]
  mov edi,[Buf2]
  mov ecx,16384-64
  Call Blur256
  mov ecx,64
  rep movsd
  mov esi,[Buf2]
  mov edi,[Buf1]
  mov ecx,16384-64
  Call Blur256
  mov ecx,64
  rep movsd
  mov esi,[Buf1]
  mov edi,[Buf2]
  mov ecx,16384-64
  Call Blur256
  mov ecx,64
  rep movsd
  Ret
 ENDP

