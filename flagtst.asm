IDEAL
P486
ASSUME  cs:code32,ds:code32

OVERFREQ = 90

o EQU OFFSET
b EQU BYTE PTR
w EQU WORD PTR
d EQU DWORD PTR

TM3INC = 1

SEGMENT code16  PARA PUBLIC USE16
ENDS

SEGMENT code32  PARA PUBLIC USE32
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; Code                                                                       ;
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
PUBLIC  _main

GLOBAL PSTexture:DWORD

MACRO FixMul XXX
imul xxx
shrd eax,edx,16
endm

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC SETPAL ; D:---  N: ESI = Palette
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
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

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 MACRO Wait4Key   ; Destroys: AL        Needs: ---
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  mov [v86r_ax], 00
  mov al,16h
  int 33h
  mov al,[v86r_al]
 ENDM


;;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; PROC GetKey     ; Destroys: AL        Needs: ---
;;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
;  mov [v86r_ax], 0100h
;  mov al,16h
;  int 33h
;  mov al,[v86r_al]
;  Ret
; ENDP

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC RANDOM  ;  D: EAX, EDX, BP    N: BX=Range  R: DX: RND-Num
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
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

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
PROC    SetPhongPal
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
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
        mov     ebp,eax         ;cos(Angle)э

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


;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC CopyClearScreen
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
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

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC  CopyScreen
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  push eax ecx
   mov edi,[Screen]
   mov esi,[Buf1]
   mov ecx,16000
   rep movsd
  pop ecx eax
  Ret
 ENDP
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC CREATETUNNELPAL
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 xor eax,eax ; Clear both Palettes!
 mov edi,[Pal1P]
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
 mov edi,[Pal1P]
 add edi,762
 mov eax,3f282828h
 stosd
 mov ax,3f3fh
 stosw
 Call SetPal
 Ret
 ENDP


 INCLUDE "FLAG.INC"
 INCLUDE "3DMain.INC"
 INCLUDE "3dpen.inc"
 INCLUDE "a3d_read.inc"
 INCLUDE "3dtransf.inc"
 INCLUDE "N_SKY.asm"
 INCLUDE "Help!.asm"

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 _MAIN: STI
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;

 mov eax,0A0000h
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

 mov [v86r_ax],13h
 mov al,10h
 int 33h

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

 xor    eax,eax
 mov    edi,O Flag
 mov    [GPObjects],O Flag
 mov    [GNrObjects],1
 Call InitFlag

 Call CreateSky

 mov edi,[PAL1P]
 Call CREATETUNNELPAL
 mov esi,[PAL1P]
 Call SetPal
 Call SetPhongPal

 mov edi,[Buf1]
 mov esi,[SkyBuf]
 mov ecx,16000
 rep movsd

 mov ecx,200
 @calcFlag:
  Call MoveFlag
  dec ecx
 jne @CalcFlag


@MainALP:
 mov edi,[Buf1]
 mov esi,[SkyBuf]
 mov ecx,16000
 rep movsd
        Call GetKey
        jnz @KeyPressed
        Call    MoveFlag
        call    MarkSeenObjects
        call    PrepareScene
        call    SortPolys
        call    DrawScene
        mov     esi,[GPPenBuffer]
        Call CopyScreen
        cmp [TM3SyncCount], 0C0h
 jb @MainALP

@KeyPressed:
 mov [v86r_ax],3h
 mov al,10h
 int 33h
 mov edx,[TM3SyncCount]
 HexPrint 8


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


;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; Initialised Data                                                                       ;
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 rnum     dd 0019d7dh
 rstandrd dd 8088405h
 Alpine     db 42,255
 present    db 15,17,4,18,4,13,19,18,255
 theirfirst db 19,7,4,8,17,41,5,8,17,18,19,255
 intro      db 38,36,10,1,32,8,13,19,17,14,255
 called     db 2,0,11,11,4,3,255
 SBOkay     db 'SB Found. $',0
 ErrorSB    db 'No SB Found! Try /nosound...$',0
 ErrorMEM   db 'Not enough MEM available...$',0
 hlp        db 'help! $', 0

 LoadName   db 'PHARAO.TM3',0
 TunnelName db 'Tunnel.dat',0

 EndScroll db 255,255,255,255,255,255,255,255,255
 INCLUDE 'txt.inc'
 Finish db 255
 INCLUDE 'SPHERE.INC'


 Logo   TObject {XoT=0*65536,YoT=0*65536,ZoT=10*65536}
 Flag   TObject {XoT=-30*65536,YoT=-30*65536,ZoT=150*65536}

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; Uninitialised Data            ;
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;

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