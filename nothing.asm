;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; ÜÜÄÄÜ ÜÜÄÄÜ ÄÄÄÜÜ ÜÜ  Ü ÄÄ ÜÜÄÄÜ ÜÜÄÄÜ                                     ;
; ÛÛ  Û ÛÛ  Û    ÛÛ ÛÛÄÄÛ ÛÛ ÛÛ  Û ÛÛ ÄÜ                                     ;
; ÛÛ  Û ÛÛ  Û    ÛÛ ÛÛ  Û ÛÛ ÛÛ  Û ÛÛ  Û                                     ;
; ÛÛ  Û ÛÛÜÜÛ    ÛÛ ÛÛ  Û ÛÛ ÛÛ  Û ÛÛÜÜÛ AND MORE       (C) 1997 by Alpine   ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Mainprog...                                                                ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

IDEAL
P486
ASSUME  cs:code32,ds:code32

o EQU OFFSET
b EQU BYTE PTR
w EQU WORD PTR
d EQU DWORD PTR

TM3INC = 1

SEGMENT code16  PARA PUBLIC USE16
ENDS

SEGMENT code32  PARA PUBLIC USE32
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Code                                                                       ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
PUBLIC  _main

GLOBAL PSTexture:DWORD

MACRO FixMul XXX
imul xxx
shrd eax,edx,16
endm

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO Wait4Key   ; Destroys: AL        Needs: ---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [v86r_ax], 00
  mov al,16h
  int 33h
  mov al,[v86r_al]
 ENDM


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC GetKey     ; Destroys: AL        Needs: ---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [v86r_ax], 0100h
  mov al,16h
  int 33h
  mov al,[v86r_al]
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC TimerFade  ;  D: EAX, EDX, BP    N: BX=Range  R: DX: RND-Num
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  Call TimerCopy
  Call FadeOut
  mov esi,[Pal1P]
  Call SetPal
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC RANDOM  ;  D: EAX, EDX, BP    N: BX=Range  R: DX: RND-Num
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov eax,[rnum]
  mul [rstandrd]
  inc eax
  mov [rnum],eax
  mul bx
  shr eax,16
  mov bp,dx
  mul bx
  add ax,bp
  adc dx,0
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC SetPhongPal
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
        pushad
        mov     dx,3c8h
        mov     al,128
        out     dx,al
        inc     dx

        xor     edi,edi         ;cos(Angle)

        mov     esi,128
@@1:    mov     eax,edi
        FixMul  eax
        FixMul  eax
        FixMul  eax
        FixMul  eax
        FixMul  eax
        mov     ebp,eax         ;cos(Angle)ı

;red
        mov     ecx,48          ;diffuse light color
        imul    ecx,edi
        mov     eax,63          ;highlight color
        imul    eax,ebp
        add     eax,ecx
        shr     eax,16
        add     eax,4           ;ambient light color
        cmp     eax,63
        jbe     @@RedOK
        mov     eax,63
@@RedOK:
        mov     dx,3c9h
        out     dx,al

;green
        mov     ecx,40          ;diffuse light color
        imul    ecx,edi
        mov     eax,63          ;highlight color
        imul    eax,ebp
        add     eax,ecx
        shr     eax,16
        add     eax,4           ;ambient light color
        cmp     eax,63
        jbe     @@GreenOK
        mov     eax,63
@@GreenOK:
        mov     dx,3c9h
        out     dx,al

;blue
        mov     ecx,0          ;diffuse light color
        imul    ecx,edi
        mov     eax,53          ;highlight color
        imul    eax,ebp
        add     eax,ecx
        shr     eax,16
        add     eax,0          ;ambient light color
        cmp     eax,63
        jbe     @@BlueOK
        mov     eax,63
@@BlueOK:
        mov     dx,3c9h
        out     dx,al

        add     edi,257*2
        dec     esi
        jnz     @@1
        popad
        ret
ENDP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO CopyScreen
 local @WaitLoop
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [PicReady],1
  @WaitLoop:
   cmp [PicReady],0
  jne @WaitLoop
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO CopyScreen2
 local @WaitLoop
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
   mov edi,[Screen]
   mov esi,[Buf1]
   mov ecx,16000
   rep movsd
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC CopyClearScreen
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [PicReady],1
  @WaitLoop:
   cmp [PicReady],0
  jne @WaitLoop
  mov edi,[Buf1]
  xor eax,eax
  mov ecx,16000
  rep stosd
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC TimerCopy
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  push eax ecx
  cmp [PicReady],1
  jne @NoCopyScreen
   mov edi,[Screen]
   mov esi,[Buf1]
   mov ecx,16000
   rep movsd
   mov [PicReady],0
  @NoCopyScreen:
  pop ecx eax
  Ret
 ENDP


 INCLUDE "TM3_MIX.ASM"
 INCLUDE "TM3_TIME.ASM"
 INCLUDE "N_PAL.ASM"
 INCLUDE "N_FONT.ASM"
 INCLUDE "N_FLAME.ASM"
 INCLUDE "N_TUNNEL.ASM"
 INCLUDE "N_ZBOBS.ASM"
 INCLUDE "N_ENDSCR.ASM"
 INCLUDE "3DMain.INC"
 INCLUDE "3dpen.inc"
 INCLUDE "a3d_read.inc"
 INCLUDE "3dtransf.inc"
 INCLUDE "Logo.inc"
 INCLUDE "N_3D.asm"

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 _MAIN: STI
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

 Call SBDetect

 jnc @SBDetected
  mov eax, o NoSound
  add eax, [_Code32a]
  shld ebx,eax,28
  and eax, 0Fh
  mov [v86r_ds], bx
  mov [v86r_dx], ax
  mov [v86r_ah], 09
  mov al, 21h
  int 33h
  jmp @SBNext
 @SBDetected:
 Call SBWriteInfo
 @SBNext:
 Call LoadTM3
 or al,al
 jne @ErrorMEM

 mov eax,0A0000h          ; Set up palettes, allocate mem for buffers.
 sub eax,[_Code32a]
 mov [Screen],eax
 mov eax,768*2
 Call _GetMEM
 jc @ErrorMem
 mov [PAL1P],eax
 add eax,768
 mov [PAL2P],eax
 mov eax,60000
 call _GetMem
 jc @ErrorMEM
 mov [POINTS],eax
 mov eax,2*50*320+65536+65536
 call _Getmem
 jc @ErrorMEM
 mov [BUF0],eax
 add eax,25*320
 mov [BUF1],eax
 mov edi,eax
 mov esi,eax
 add eax,65536+75*320
 mov [BUF2],eax
 mov eax,256000
 Call _GetMem
 jc @ErrorMEM
 mov [BUF3],eax
 xor eax,eax
 mov ecx,40384
 rep stosd
 mov eax,esi
 mov edi,O YCoord  ; Set up Y-Mul-Look-up-Table...
 mov cl,200
 @FR1:
  stosd
  add eax,320
  dec cl
 jne @FR1
 mov eax,64000
 call _GetMem
 jc @ErrorMEM
 mov [SkyBuf],eax

 mov    [GPenBufferWidth],320
 mov    [GPenBufferHeight],200
 mov    [GXMiddle],160
 mov    [GYMiddle],100
 push   [Buf1]
 pop    [GPPenBuffer]
 mov    [GXEyeDist],256
 mov    [GYEyeDist],212

 Call CalcSinus
 jc @ErrorMem
 call CalcArcusSinus
 jc @ErrorMem
 call   Init3DEngine

 mov    [GPObjects],O Logo
 mov    [GNrObjects],1
 mov    esi,O LogoObject
 mov    edi,O Logo
 xor    eax,eax
 call   MakeObject
 jc     @errormem

 Call CreateSky

 mov [Stereo], 1
 mov [LoopIt], 0
 mov [SamplingRate], 21739

 Call PlayTM3
 Call SetTimerHandler
 mov ebx, 75
 Call NewTimerFreq

 xor    eax,eax
 mov    ebx,113
 mov    ecx,0
 mov    edx,0
 call   RotateObjectInObjectSpace

 mov [v86r_ax],13h
 mov al,10h
 int 33h

; precalcs finished.

 Call Fire                                      ; first effect
 jc @KeyPressed

 mov dx,3c8h
 xor al,al
 out dx,al
 inc dx
 mov al,63
 mov ecx,768
 @r:
  out dx,al
  dec ecx
 jne @r

 xor eax,eax
 mov edi,[Screen]
 mov ecx,16000
 rep stosd

 mov edi,[PAL1P]
 Call BlueSkyPal
 mov esi,[PAL1P]
 Call SetPal
 Call SetPhongPal

 mov [TimerCalled],O Timer3D
 @MainALP:
 mov edi,[Buf1]
 mov esi,[SkyBuf]
 mov ecx,16000
 rep movsd
        Call GetKey
        jnz @KeyPressed
        call    MarkSeenObjects
        call    PrepareScene
        call    SortPolys
        call    DrawScene
        mov     esi,[GPPenBuffer]
        CopyScreen
        cmp [TM3SyncCount], 0B6h
  jb @MainALP
 mov edi,[Screen]
 mov esi,[SkyBuf]
 mov ecx,16000
 rep movsd

 Call LilaPal
 mov [Counter],64
 mov [TimerCalled],O FadeOver
 @Loop1:
  cmp [Counter],2
 ja @Loop1

 mov [TimerCalled],O TimerCopy

 Call Tunnel
 jc @KeyPressed
 Call SetPhongPal
 xor    eax,eax
 mov    ebx,0
 mov    ecx,4096*65536
 mov    edx,0
 call   RotateObjectInObjectSpace
 xor    eax,eax
 xor    ebx,ebx
 xor    ecx,ecx
 mov    edx,65536*250
 call   TranslateObjectInWorldSpace

 mov [TimerCalled],O Timer3D_2
 @MainALP2:
 mov edi,[Buf1]
 mov esi,[SkyBuf]
 mov ecx,16000
 rep movsd
        Call GetKey
        jnz @KeyPressed
        call    MarkSeenObjects
        call    PrepareScene
        call    SortPolys
        call    DrawScene
        mov     esi,[GPPenBuffer]
        CopyScreen
        cmp [TM3SyncCount], 0170h
 jb @MainALP2
 mov edi,[Screen]
 mov esi,[SkyBuf]
 mov ecx,16000
 rep movsd

 mov [TimerCalled],O TimerFade
 @Q2:
  Call GetKey
  jnz @KeyPressed
  cmp [TM3SyncCount],176h
 jbe @Q2
 mov [TimerCalled],O TimerCopy

 mov edi,[Screen]
 xor eax,eax
 mov ecx,16000
 rep stosd

 Call ZBobs
 jc @KeyPressed


@EndSC:
 Call EndScroller
  @TT1:
   Call GetKey
   jnz @KeyPressed
   cmp [IRQ_Finished],1
  jne @TT1
  Call ResetTimer
  mov [v86r_ax],3h
  mov al,10h
  int 33h
  jmp _exit

 @KeyPressed:

 Call ResetTimer
 Call StopTM3

 mov [v86r_ax],3h
 mov al,10h
 int 33h

 jmp _exit

 @ErrorMem:
  mov eax, o ErrorMEM
  add eax, [_Code32a]
  shld ebx,eax,28
  and eax, 0Fh
  mov [v86r_ds], bx
  mov [v86r_dx], ax
  mov [v86r_ah], 09
  mov al, 21h
  int 33h
  jmp _exit


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Initialised Data                                                                       ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 INCLUDE 'TM3_CONST.ASM'
 rnum     dd 0019d7dh
 rstandrd dd 8088405h
 TNothing   db 42,42,42,13,14,19,7,8,13,6,42,19,14,42,18,0,24,42,17,4,0,11,11,24,26,26,26,255
 Alpine     db 41,255
 present    db 15,17,4,18,4,13,19,18,255
 theirfirst db 19,7,4,8,17,42,5,8,17,18,19,255
 intro      db 38,36,10,1,32,8,13,19,17,14,255
 called     db 2,0,11,11,4,3,255
 NoSound    db 'No SB Found! Switching to nosound...$',0
 ErrorMEM   db 'Not enough MEM available...$',0

 INCLUDE 'INTROF.INC'
 INCLUDE 'PHARAO.INC'
 EndScroll db 255,255,255,255,255,255,255,255,255
 INCLUDE 'txt.inc'
         db 255
         db 255
         db 255
 AlpOn   db 255
         db 42,42,42,42,42,42,2,14,15,24,17,8,6,7,19,42,33,40,40,39,42,1,24,255
         db 255
 Alp2    db 42,42,42,42,41,255
         db 255
         db 255
         db 255
         db 255
         db 255
         db 255
         db 42,42,42,42,42,42,42,42,42,42,42,42,42,19,7,4,42,4,13,3,255
 Finish  db 255
 INCLUDE 'SPHERE.INC'


 Logo   TObject {XoT=0*65536,YoT=0*65536,ZoT=10*65536}

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Uninitialised Data            ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

 PicReady  db ?
 MaxPoints dd ?
 PicHeight dd ?
 AlpHeight dd ?
 AlpInc    dd ?
 FadeFlag  db ?
 COLCOUNT db ?
 Points dd ? ;+0=w VY, +2=w PY, +4=d PX
 YCoord dd 200 dup (?)
 Pal1P  dd ?
 Pal2P  dd ?
 Buf0   dd ?
 Buf1   dd ?
 buf2   dd ?
 Buf3   dd ?
 screen dd ?
 PSTexture dd ?
 INCLUDE 'TM3_VARS.ASM'
 BLENDout  db ?
 COUNTER   dd ?
 FlipFlop  db ?

 TunnelY   db ?
 TunnelX   dd ?
 TunnelVx  dd ?
 EndTunnel db ?

 r1f dw ?
 r1 dd ?
 r21f dw ?
 r21 dd ?
 r22f dw ?
 r22 dd ?
 NextStep  dd ?
 Nxt1      dd ?
 NextStep2 dd ?
 Nxt2      dd ?
 skybuf    dd ?
 Angles dd 2*8 dup (?)  ; 8 Bobs * 8 bytes pro Bob.

 StartLine dd ?
 StartPos  dd ?


ENDS

END