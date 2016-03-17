;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC SETPAL ; D:---  N: ESI = Palette
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  push edx eax ecx
   mov dx,3c8h
   xor al,al
   out dx,al
   inc dx
   mov ecx,768
   rep outsb
  pop ecx eax edx
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC LilaPal
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 xor eax,eax
 mov edi,[Pal2P]
 mov esi,edi
 mov ecx,192
 rep stosd
 mov edi,esi
 add edi,3
 mov cl,28h
 xor bl,bl
 @LSkyPal:
  mov al,243
  mul bl
  mov [edi],ah
  mov al,205
  mul bl
  mov [edi+2],ah
  add edi,3
  inc bl
  dec cl
 jne @LSkyPal
 mov cl,64
 xor eax,eax
 @GreyPal:
  stosd
  dec edi
  add eax,01010101h
  dec cl
 jne @GreyPal
 mov edi,[Pal2P]
 add edi,762
 mov eax,3f282828h
 stosd
 mov ax,3f3fh
 stosw
 Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC BlueSkyPal    ;  D: ---  N: edi = Offset of Pal!
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pushad
  xor eax,eax       ; Clear both Palettes!
  mov esi,edi
  mov ecx,96
  rep stosd
  mov edi,esi
  add edi,3
  mov cx,3F28h
  mov ax,0F0Fh
  @SkyPal:
   add ax,0101h
   stosw
   mov [edi],ch
   inc edi
   dec cl
  jne @SkyPal
  popad
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC FadeOver
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pushad
  mov edx,256*3
  mov esi,[Pal2P]
  mov edi,[Pal1P]
  mov ecx,[Counter]
  @FadeOver:
   mov al,[edi]
   mov bl,al
   sub bl,[esi]
   je @CEqual
   cmp bl,cl
   jb @CEqual
    cmp al,[esi]
     jb @CInc
      dec al
      jmp @CEqual
     @CInc:
      inc al
   @CEqual:
   stosb
   inc esi
   dec edx
  jne @FadeOver
  dec ecx
  mov [Counter],ecx
  mov esi,[Pal1P]
  Call SetPal
  popad
  Ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC FADEIN  ; D:---  N: [COLCOUNT]: Counter
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pusha
  mov dx,256*3
  mov ch,[COLCOUNT]
  mov esi,[Pal1P]
  mov edi,[Pal2P]
  @FadeIn:
   lodsb
   cmp al,ch
   jb @CNoFadeIn
    mov bl,[edi]
    cmp bl,al
    je @CNoFadeIn
     inc bl
     mov [edi],bl
   @CNoFadeIn:
   inc edi
   dec dx
  jne @FadeIn
  popa
  ret
 ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 PROC FADEOUT ; D:---  N: ---
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
  pusha
  mov dx,256*3
  mov esi,[Pal1P]
  @FadeOut:
   lodsb
   dec al
   js @CNoFadeOut
     mov [esi-1],al
   @CNoFadeOut:
   dec dx
  jne @FadeOut
  popa
  ret
 ENDP
