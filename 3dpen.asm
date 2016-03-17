;the draw-routines of the ALPINE 3D-Engine
;written in spring and summer 1997 by Ziron

IDEAL
P386
ASSUME  cs:code32,ds:code32

SEGMENT code32  PARA PUBLIC USE32
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
INCLUDE 'decl.inc'
INCLUDE '3dmain.inc'
INCLUDE '3dpen.inc'

ALIGN   16
;###########################################################################
PROC    DrawSolidPoly
;IN     esi=pointer to poly structure
;IMPORTANT: The edges must always be in reversed clock wise order!
;Draws a polygon filled with an constant color.
;###########################################################################
        pushad

        mov     al,[esi+TPoly.Color]
        mov     [PolyColor],al

        mov     edi,[esi+TPoly.PE1]
        movsx   eax,[W edi+TVertex.Xs]
        movsx   ebx,[W edi+TVertex.Ys]

        mov     edi,[esi+TPoly.PE2]
        movsx   ecx,[W edi+TVertex.Xs]
        movsx   edx,[W edi+TVertex.Ys]

        mov     edi,[esi+TPoly.PE3]
        movsx   ebp,[W edi+TVertex.Xs]
        movsx   edi,[W edi+TVertex.Ys]

;WriteLnString 'New...'
;WriteDecDWord eax
;WriteLnDecDWord ebx
;WriteDecDWord ecx
;WriteLnDecDWord edx
;WriteDecDWord ebp
;WriteLnDecDWord edi

;************************************************
;check if all edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@YCheck
        cmp     eax,ebp
        je      @@end
@@YCheck:
        cmp     ebx,edx
        jne     @@XYCheckOK
        cmp     ebx,edi
        je      @@end
@@XYCheckOK:

;************************************************
;check if two edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@Check2&3
        cmp     ebx,edx
        je      @@end
@@Check2&3:
        cmp     ecx,ebp
        jne     @@Check3&1
        cmp     edx,edi
        je      @@end
@@Check3&1:
        cmp     ebp,eax
        jne     @@CheckOK
        cmp     edi,ebx
        je      @@end
@@CheckOK:

;***********************************
;check if all edges are on one side
;***********************************
        cmp     ebx,0
        jg      @@CheckLeft
        cmp     edx,0
        jg      @@CheckLeft
        cmp     edi,0
        jng     @@end
@@CheckLeft:
        test    eax,eax
        jns     @@CheckDown
        test    ecx,ecx
        jns     @@CheckDown
        test    ebp,ebp
        js      @@end
@@CheckDown:
        mov     esi,[GPenBufferHeight]
        cmp     ebx,esi
        jl      @@CheckRight
        cmp     edx,esi
        jl      @@CheckRight
        cmp     edi,esi
        jnl     @@end
@@CheckRight:
        mov     esi,[GPenBufferWidth]
        cmp     eax,esi
        jl      @@SideTestOK
        cmp     ecx,esi
        jl      @@SideTestOK
        cmp     ebp,esi
        jnl     @@end
@@SideTestOK:

;**********************
;find the highest edge
;**********************
        cmp     edx,ebx
        jle     @@E2higherE1
        cmp     ebx,edi
        jg      @@E3highest
;#1 is the highest and leftmost edge
        mov     [X1],eax
        mov     [Y1],ebx
        mov     [X2],ecx
        mov     [Y2],edx
        mov     [X3],ebp
        mov     [Y3],edi
        jmp     @@HighestEdgeFound
@@E2higherE1:
        cmp     edi,edx
        jle     @@E3highest
;#2 is the highest and leftmost edge
        mov     [X1],ecx
        mov     [Y1],edx
        mov     [X2],ebp
        mov     [Y2],edi
        mov     [X3],eax
        mov     [Y3],ebx
        jmp     @@HighestEdgeFound
@@E3highest:
;#3 is the highest and leftmost edge
        mov     [X1],ebp
        mov     [Y1],edi
        mov     [X2],eax
        mov     [Y2],ebx
        mov     [X3],ecx
        mov     [Y3],edx
@@HighestEdgeFound:

;*******************
;compute left lines
;*******************
        mov     edi,[GPPenLineBuffer]
        mov     ecx,[X1]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y2]
        test    ebx,ebx
        js      @@NextLine1
        jz      @@NextLine1
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom1
        sub     esi,ebp
@@NoClippingAtBottom1:
        sub     ebx,edx         ;height
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx
        add     esi,ebx         ;counter
        mov     [PolyHeight],si
        test    ebp,ebp
        jns     @@Go1
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go1:
        rol     eax,16
ALIGN   16
@@NewRow1:
        mov     [edi],cx
        add     edi,2
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow1
@@NextLine1:

;compute bottom line if neccessary
        mov     edx,[Y2]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine2
        mov     ebx,[Y3]
        cmp     ebx,edx
        jle     @@NextLine2    ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom2
        sub     esi,ebp
@@NoClippingAtBottom2:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X2]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        add     [PolyHeight],si
        sal     eax,16
        cdq
        idiv    ebx
        test    ebp,ebp
        jns     @@Go2
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go2:
        rol     eax,16
ALIGN   16
@@NewRow2:
        mov     [edi],cx
        add     edi,2
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow2
@@NextLine2:

;********************
;compute right lines
;********************
        mov     edi,[GPPenLineBuffer]
        add     edi,2048
        mov     ecx,[X1]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y3]
        test    ebx,ebx
        js      @@NextLine3
        jz      @@NextLine3
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom3
        sub     esi,ebp
@@NoClippingAtBottom3:
        sub     ebx,edx         ;height
        je      @@NextLine3     ;no necessity to compute horizontal lines
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx
        add     esi,ebx         ;counter
        test    ebp,ebp
        jns     @@Go3
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go3:
        rol     eax,16
ALIGN   16
@@NewRow3:
        mov     [edi],cx
        add     edi,2
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow3
@@NextLine3:

;compute bottom line if neccessary
        mov     edx,[Y3]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine4
        mov     ebx,[Y2]
        cmp     ebx,edx
        jle     @@NextLine4     ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom4
        sub     esi,ebp
@@NoClippingAtBottom4:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X3]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        sal     eax,16
        cdq
        idiv    ebx
        test    ebp,ebp
        jns     @@Go4
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go4:
        rol     eax,16
ALIGN   16
@@NewRow4:
        mov     [edi],cx
        add     edi,2
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow4
@@NextLine4:

;************************
;and finally... fill it!
;************************
        mov     esi,[Y1]
        test    esi,esi
        jns     @@NotSigned
        xor     esi,esi
@@NotSigned:
        imul    esi,[GPenBufferWidth]
        add     esi,[GPPenBuffer]
        mov     ebx,[GPPenLineBuffer]
        mov     al,[PolyColor]
        xor     ecx,ecx
@@NextLine:
        movsx   edi,[W ebx]
        test    edi,edi
        jns     @@DontClear1
        xor     edi,edi
@@DontClear1:
        movsx   ecx,[W ebx+2048]
        cmp     ecx,[GPenBufferWidth]
        jl      @@DontClear2
        mov     ecx,[GPenBufferWidth]
@@DontClear2:
        sub     ecx,edi
;neg ecx
        jle     @@NoLine
;       cmp     ecx,8
;       jb      @@NextPixel2

@@NextPixel2:
        mov     [B esi+edi],al
        inc     edi
        dec     ecx
        jnz     @@NextPixel2
@@NoLine:
        add     esi,[GPenBufferWidth]
        add     ebx,2
        dec     [PolyHeight]
        jnz     @@NextLine

@@end:  popad
        ret
ENDP

ALIGN   16
;###########################################################################
PROC    DrawGouroudPoly
;IN     esi=pointer to poly structure
;IMPORTANT: The edges must always be in reversed clock wise order!
;Draws a gouroud-shaded polygon.
;###########################################################################
        pushad

        mov     edi,[esi+TPoly.PE1]
        xor     eax,eax
        mov     al,[edi+TVertex.Light]
        mov     [Light1],eax
        movsx   eax,[W edi+TVertex.Xs]
        movsx   ebx,[W edi+TVertex.Ys]

        mov     edi,[esi+TPoly.PE2]
        xor     ecx,ecx
        mov     cl,[edi+TVertex.Light]
        mov     [Light2],ecx
        movsx   ecx,[W edi+TVertex.Xs]
        movsx   edx,[W edi+TVertex.Ys]

        mov     edi,[esi+TPoly.PE3]
        movzx   ebp,[B edi+TVertex.Light]
        mov     [Light3],ebp
        movsx   ebp,[W edi+TVertex.Xs]
        movsx   edi,[W edi+TVertex.Ys]

;************************************************
;check if all edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@YCheck
        cmp     eax,ebp
        je      @@end
@@YCheck:
        cmp     ebx,edx
        jne     @@XYCheckOK
        cmp     ebx,edi
        je      @@end
@@XYCheckOK:

;************************************************
;check if two edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@Check2&3
        cmp     ebx,edx
        je      @@end
@@Check2&3:
        cmp     ecx,ebp
        jne     @@Check3&1
        cmp     edx,edi
        je      @@end
@@Check3&1:
        cmp     ebp,eax
        jne     @@CheckOK
        cmp     edi,ebx
        je      @@end
@@CheckOK:

;***********************************
;check if all edges are on one side
;***********************************
        cmp     ebx,0
        jg      @@CheckLeft
        cmp     edx,0
        jg      @@CheckLeft
        cmp     edi,0
        jng     @@end
@@CheckLeft:
        test    eax,eax
        jns     @@CheckDown
        test    ecx,ecx
        jns     @@CheckDown
        test    ebp,ebp
        js      @@end
@@CheckDown:
        mov     esi,[GPenBufferHeight]
        cmp     ebx,esi
        jl      @@CheckRight
        cmp     edx,esi
        jl      @@CheckRight
        cmp     edi,esi
        jnl     @@end
@@CheckRight:
        mov     esi,[GPenBufferWidth]
        cmp     eax,esi
        jl      @@SideTestOK
        cmp     ecx,esi
        jl      @@SideTestOK
        cmp     ebp,esi
        jnl     @@end
@@SideTestOK:

;**********************
;find the highest edge
;**********************
        cmp     edx,ebx
        jle     @@E2higherE1
        cmp     ebx,edi
        jg      @@E3highest
;#1 is the highest and leftmost edge
        mov     [X1],eax
        mov     [Y1],ebx
        mov     [X2],ecx
        mov     [Y2],edx
        mov     [X3],ebp
        mov     [Y3],edi
        mov     eax,[Light1]
        mov     ebx,[Light2]
        mov     ecx,[Light3]
        jmp     @@HighestEdgeFound
@@E2higherE1:
        cmp     edi,edx
        jle     @@E3highest
;#2 is the highest and leftmost edge
        mov     [X1],ecx
        mov     [Y1],edx
        mov     [X2],ebp
        mov     [Y2],edi
        mov     [X3],eax
        mov     [Y3],ebx
        mov     eax,[Light2]
        mov     ebx,[Light3]
        mov     ecx,[Light1]
        jmp     @@HighestEdgeFound
@@E3highest:
;#3 is the highest and leftmost edge
        mov     [X1],ebp
        mov     [Y1],edi
        mov     [X2],eax
        mov     [Y2],ebx
        mov     [X3],ecx
        mov     [Y3],edx
        mov     eax,[Light3]
        mov     ebx,[Light1]
        mov     ecx,[Light2]
@@HighestEdgeFound:
        mov     [Light1],eax
        mov     [Light2],ebx
        mov     [Light3],ecx

;***********************
;compute Gouroud X-Addy
;***********************
        sub     ebx,eax         ;bz
        sub     ecx,eax         ;az

        mov     eax,[Y2]
        sub     eax,[Y1]        ;by
        mov     esi,eax
        imul    ecx             ;*az
        mov     ebp,eax

        mov     eax,[Y3]
        sub     eax,[Y1]        ;ay
        mov     edi,eax
        imul    ebx             ;*bz
        sub     ebp,eax

        mov     eax,[X1]
        mov     ebx,[X2]
        sub     ebx,eax         ;bx
        mov     ecx,[X3]
        sub     ecx,eax         ;ax

        mov     eax,ecx
        imul    esi,eax         ;ax*by
        mov     eax,ebx
        imul    edi             ;bx*ay
        sub     esi,eax
        jz      @@end           ;all points lie in one line!

;this part helps avoiding bright pixels at the right side of polygons
        mov     eax,1
        test    esi,esi
        jns     @@Positive
        neg     eax
@@Positive:
        add     esi,eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    esi
        rol     eax,16
        mov     [GouroudAddy],eax

;*******************
;compute left lines
;*******************
        mov     edi,[GPPenLineBuffer]
        mov     ecx,[X1]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y2]
        test    ebx,ebx
        js      @@NextLine1
        jz      @@NextLine1
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom1
        sub     esi,ebp
@@NoClippingAtBottom1:
        sub     ebx,edx         ;height
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx

        mov     edi,eax         ;save eax
        mov     eax,[Light2]
        sub     eax,[Light1]
        sal     eax,16
        cdq
        idiv    ebx
        xchg    eax,edi
        mov     edx,[Light1]

        add     esi,ebx         ;counter
        mov     [PolyHeight],si
        test    ebp,ebp
        jns     @@Go1
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si
        mov     ebx,eax         ;save eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0

        mov     eax,edi
        imul    eax,ebp
        rol     eax,16
        add     edx,eax
        adc     edx,0

        mov     eax,ebx
@@Go1:
        rol     eax,16
        mov     ebx,edi
        rol     ebx,16
        mov     edi,[GPPenLineBuffer]

ALIGN   16
@@NewRow1:
        mov     [edi],cx
        mov     [edi+8192],edx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        add     edx,ebx
        adc     edx,0
        dec     esi
        jnz     @@NewRow1
@@NextLine1:

;compute bottom line if neccessary
        mov     edx,[Y2]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine2
        mov     ebx,[Y3]
        cmp     ebx,edx
        jle     @@NextLine2    ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom2
        sub     esi,ebp
@@NoClippingAtBottom2:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X2]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        add     [PolyHeight],si
        sal     eax,16
        cdq
        idiv    ebx

        push    edi
        mov     edi,eax         ;save eax
        mov     eax,[Light3]
        sub     eax,[Light2]
        sal     eax,16
        cdq
        idiv    ebx
        xchg    eax,edi
        mov     edx,[Light2]

        test    ebp,ebp
        jns     @@Go2
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0

        mov     eax,edi
        imul    eax,ebp
        rol     eax,16
        add     edx,eax
        adc     edx,0

        mov     eax,ebx
@@Go2:
        rol     eax,16
        mov     ebx,edi
        rol     ebx,16
        pop     edi

ALIGN   16
@@NewRow2:
        mov     [edi],cx
        mov     [edi+8192],edx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        add     edx,ebx
        adc     edx,0
        dec     esi
        jnz     @@NewRow2
@@NextLine2:

;********************
;compute right lines
;********************
        mov     edi,[GPPenLineBuffer]
        add     edi,4096
        mov     ecx,[X1]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y3]
        test    ebx,ebx
        js      @@NextLine3
        jz      @@NextLine3
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom3
        sub     esi,ebp
@@NoClippingAtBottom3:
        sub     ebx,edx         ;height
        je      @@NextLine3     ;no necessity to compute horizontal lines
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx
        add     esi,ebx         ;counter
        test    ebp,ebp
        jns     @@Go3
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go3:
        rol     eax,16
ALIGN   16
@@NewRow3:
        mov     [edi],cx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow3
@@NextLine3:

;compute bottom line if neccessary
        mov     edx,[Y3]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine4
        mov     ebx,[Y2]
        cmp     ebx,edx
        jle     @@NextLine4     ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom4
        sub     esi,ebp
@@NoClippingAtBottom4:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X3]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        sal     eax,16
        cdq
        idiv    ebx
        test    ebp,ebp
        jns     @@Go4
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go4:
        rol     eax,16
ALIGN   16
@@NewRow4:
        mov     [edi],cx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow4
@@NextLine4:

;************************
;and finally... fill it!
;************************
        mov     ebp,[GouroudAddy]
        mov     esi,[Y1]
        test    esi,esi
        jns     @@NotSigned
        xor     esi,esi
@@NotSigned:
        imul    esi,[GPenBufferWidth]
        add     esi,[GPPenBuffer]
        mov     ebx,[GPPenLineBuffer]
        xor     ecx,ecx
@@NextLine:
        mov     eax,[ebx+8192]
        movsx   edi,[W ebx]
        test    edi,edi
        jns     @@DontClear1
        neg     edi
        mov     ecx,eax
        mov     eax,ebp
        rol     eax,16
        imul    edi
        rol     eax,16
        add     eax,ecx
        adc     eax,0
        xor     edi,edi
@@DontClear1:
        movsx   ecx,[W ebx+4096]
        cmp     ecx,[GPenBufferWidth]
        jl      @@DontClear2
        mov     ecx,[GPenBufferWidth]
@@DontClear2:
        sub     ecx,edi
        jle     @@NoLine
@@NextPixel:
        mov     [B esi+edi],al
        add     eax,ebp
        adc     eax,0
        inc     edi
        dec     ecx
        jnz     @@NextPixel
@@NoLine:
        add     esi,[GPenBufferWidth]
        add     ebx,4
        dec     [PolyHeight]
        jnz     @@NextLine

@@end:  popad
        ret
ENDP

ALIGN   16
;###########################################################################
PROC    DrawTexturedPoly
;IN     esi=pointer to poly structure
;IMPORTANT: The edges must always be in reversed clock wise order!
;Draws a texture mapped polygon.
;###########################################################################
        pushad

        mov     eax,[esi+TPoly.PTexture]
        mov     [@@PTexture],eax

;       mov     [TextureU1],255
;       mov     [TextureV1],0
;       mov     eax,250-200
;       mov     ebx,20+100
;       mov     [TextureU2],0
;       mov     [TextureV2],255
;       mov     ecx,100-200
;       mov     edx,170+100
;       mov     [TextureU3],255
;       mov     [TextureV3],255
;       mov     ebp,250-200
;       mov     edi,180+100

        movsx   eax,[esi+TPoly.U1]
        movsx   ebx,[esi+TPoly.U2]
        movsx   ecx,[esi+TPoly.U3]
        movsx   edx,[esi+TPoly.V1]
        movsx   ebp,[esi+TPoly.V2]
        movsx   edi,[esi+TPoly.V3]
        mov     [TextureU1],eax
        mov     [TextureU2],ebx
        mov     [TextureU3],ecx
        mov     [TextureV1],edx
        mov     [TextureV2],ebp
        mov     [TextureV3],edi

        mov     edi,[esi+TPoly.PE1]
        movsx   eax,[W edi+TVertex.Xs]
        movsx   ebx,[W edi+TVertex.Ys]
        mov     edi,[esi+TPoly.PE2]
        movsx   ecx,[W edi+TVertex.Xs]
        movsx   edx,[W edi+TVertex.Ys]
        mov     edi,[esi+TPoly.PE3]
        movsx   ebp,[W edi+TVertex.Xs]
        movsx   edi,[W edi+TVertex.Ys]

;************************************************
;check if all edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@YCheck
        cmp     eax,ebp
        je      @@end
@@YCheck:
        cmp     ebx,edx
        jne     @@XYCheckOK
        cmp     ebx,edi
        je      @@end
@@XYCheckOK:

;************************************************
;check if two edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@Check2&3
        cmp     ebx,edx
        je      @@end
@@Check2&3:
        cmp     ecx,ebp
        jne     @@Check3&1
        cmp     edx,edi
        je      @@end
@@Check3&1:
        cmp     ebp,eax
        jne     @@CheckOK
        cmp     edi,ebx
        je      @@end
@@CheckOK:

;***********************************
;check if all edges are on one side
;***********************************
        cmp     ebx,0
        jg      @@CheckLeft
        cmp     edx,0
        jg      @@CheckLeft
        cmp     edi,0
        jng     @@end
@@CheckLeft:
        test    eax,eax
        jns     @@CheckDown
        test    ecx,ecx
        jns     @@CheckDown
        test    ebp,ebp
        js      @@end
@@CheckDown:
        mov     esi,[GPenBufferHeight]
        cmp     ebx,esi
        jl      @@CheckRight
        cmp     edx,esi
        jl      @@CheckRight
        cmp     edi,esi
        jnl     @@end
@@CheckRight:
        mov     esi,[GPenBufferWidth]
        cmp     eax,esi
        jl      @@SideTestOK
        cmp     ecx,esi
        jl      @@SideTestOK
        cmp     ebp,esi
        jnl     @@end
@@SideTestOK:

;**********************
;find the highest edge
;**********************
        cmp     edx,ebx
        jle     @@E2higherE1
        cmp     ebx,edi
        jg      @@E3highest
;#1 is the highest and leftmost edge
        mov     [X1],eax
        mov     [Y1],ebx
        mov     [X2],ecx
        mov     [Y2],edx
        mov     [X3],ebp
        mov     [Y3],edi
        mov     eax,[TextureU1]
        mov     ebx,[TextureU2]
        mov     ecx,[TextureU3]
        mov     edx,[TextureV1]
        mov     ebp,[TextureV2]
        mov     edi,[TextureV3]
        jmp     @@HighestEdgeFound
@@E2higherE1:
        cmp     edi,edx
        jle     @@E3highest
;#2 is the highest and leftmost edge
        mov     [X1],ecx
        mov     [Y1],edx
        mov     [X2],ebp
        mov     [Y2],edi
        mov     [X3],eax
        mov     [Y3],ebx
        mov     eax,[TextureU2]
        mov     ebx,[TextureU3]
        mov     ecx,[TextureU1]
        mov     edx,[TextureV2]
        mov     ebp,[TextureV3]
        mov     edi,[TextureV1]
        jmp     @@HighestEdgeFound
@@E3highest:
;#3 is the highest and leftmost edge
        mov     [X1],ebp
        mov     [Y1],edi
        mov     [X2],eax
        mov     [Y2],ebx
        mov     [X3],ecx
        mov     [Y3],edx
        mov     eax,[TextureU3]
        mov     ebx,[TextureU1]
        mov     ecx,[TextureU2]
        mov     edx,[TextureV3]
        mov     ebp,[TextureV1]
        mov     edi,[TextureV2]
@@HighestEdgeFound:
        mov     [TextureU1],eax
        mov     [TextureU2],ebx
        mov     [TextureU3],ecx
        mov     [TextureV1],edx
        mov     [TextureV2],ebp
        mov     [TextureV3],edi

;************************
;compute texture X-Addys
;************************
;calculate dividend for U
        sub     ebx,eax         ;bz
        sub     ecx,eax         ;az

        mov     eax,[Y2]
        sub     eax,[Y1]        ;by
        mov     esi,eax
        imul    ecx             ;*az
        mov     ebp,eax

        mov     eax,[Y3]
        sub     eax,[Y1]        ;ay
        mov     edi,eax
        imul    ebx             ;*bz
        sub     ebp,eax

;calculate divisor for U and V
        mov     eax,[X1]
        mov     ebx,[X2]
        sub     ebx,eax         ;bx
        mov     ecx,[X3]
        sub     ecx,eax         ;ax

        mov     eax,ecx
        imul    esi,eax         ;ax*by
        mov     eax,ebx
        imul    edi             ;bx*ay
        sub     esi,eax
        jz      @@end           ;all points lie in one line!

;calculate dividend for V
        mov     eax,[TextureV1]
        mov     ebx,[TextureV2]
        mov     ecx,[TextureV3]
        sub     ebx,eax         ;bz
        sub     ecx,eax         ;az

        mov     eax,[Y2]
        sub     eax,[Y1]        ;by
        imul    ecx             ;*az
        mov     edi,eax

        mov     eax,[Y3]
        sub     eax,[Y1]        ;ay
        imul    ebx             ;*bz
        sub     edi,eax

;calculate texture addy for U and V
        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    esi
        mov     [@@Factor3a],eax
        rol     eax,16
        mov     [@@TextureUAddy],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    esi
        mov     [@@Factor3b],eax
        rol     eax,16
        mov     [@@TextureVAddy],eax

;*******************
;compute left lines
;*******************
        mov     edi,[GPPenLineBuffer]
        mov     ecx,[X1]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y2]
        test    ebx,ebx
        js      @@NextLine1
        jz      @@NextLine1
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom1
        sub     esi,ebp
@@NoClippingAtBottom1:
        sub     ebx,edx         ;height
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor1a],eax
        rol     eax,16
        mov     [@@Argument1a],eax

        mov     eax,[TextureU2]
        sub     eax,[TextureU1]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor1b],eax
        rol     eax,16
        mov     [@@Argument1b],eax
        mov     edi,[TextureU1]

        mov     eax,[TextureV2]
        sub     eax,[TextureV1]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor1c],eax
        rol     eax,16
        mov     [@@Argument1c],eax
        mov     edx,[TextureV1]

        add     esi,ebx         ;counter
        mov     ebx,edi
        mov     [PolyHeight],si
        test    ebp,ebp
        jns     @@Go1
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si

        DB      69h,0c5h        ;imul eax,ebp,@@Factor1a
@@Factor1a DD     ?
        rol     eax,16
        add     ecx,eax
        adc     ecx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor1b
@@Factor1b DD     ?
        rol     eax,16
        add     ebx,eax
        adc     ebx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor1c
@@Factor1c DD     ?
        rol     eax,16
        add     edx,eax
        adc     edx,0

@@Go1:  mov     edi,[GPPenLineBuffer]

ALIGN   16
@@NewRow1:
        mov     [edi],cx
        mov     [edi+12288],ebx
        mov     [edi+16384],edx
        add     edi,4
        db      81h,0c1h        ;add ecx,@@Argument1a
@@Argument1a DD   ?
        adc     ecx,0

        db      81h,0c3h        ;add ebx,@@Argument1b
@@Argument1b DD   ?
        adc     ebx,0

        db      81h,0c2h        ;add edx,@@Argument1c
@@Argument1c DD   ?
        adc     edx,0

        dec     esi
        jnz     @@NewRow1
@@NextLine1:

;compute bottom line if neccessary
        mov     edx,[Y2]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine2
        mov     ebx,[Y3]
        cmp     ebx,edx
        jle     @@NextLine2    ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom2
        sub     esi,ebp
@@NoClippingAtBottom2:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X2]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        add     [PolyHeight],si
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor2a],eax
        rol     eax,16
        mov     [@@Argument2a],eax

        push    edi
        mov     eax,[TextureU3]
        sub     eax,[TextureU2]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor2b],eax
        rol     eax,16
        mov     [@@Argument2b],eax
        mov     edi,[TextureU2]

        mov     eax,[TextureV3]
        sub     eax,[TextureV2]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor2c],eax
        rol     eax,16
        mov     [@@Argument2c],eax
        mov     edx,[TextureV2]

        mov     ebx,edi
        test    ebp,ebp
        jns     @@Go2
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si

        DB      69h,0c5h        ;imul eax,ebp,@@Factor2a
@@Factor2a DD     ?
        rol     eax,16
        add     ecx,eax
        adc     ecx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor2b
@@Factor2b DD     ?
        rol     eax,16
        add     ebx,eax
        adc     ebx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor2c
@@Factor2c DD     ?
        rol     eax,16
        add     edx,eax
        adc     edx,0

@@Go2:  pop     edi

ALIGN   16
@@NewRow2:
        mov     [edi],cx
        mov     [edi+12288],ebx
        mov     [edi+16384],edx
        add     edi,4
        db      81h,0c1h        ;add ecx,@@Argument2a
@@Argument2a DD   ?
        adc     ecx,0

        db      81h,0c3h        ;add ebx,@@Argument2b
@@Argument2b DD   ?
        adc     ebx,0

        db      81h,0c2h        ;add edx,@@Argument2c
@@Argument2c DD   ?
        adc     edx,0

        dec     esi
        jnz     @@NewRow2
@@NextLine2:

;********************
;compute right lines
;********************
        mov     edi,[GPPenLineBuffer]
        add     edi,4096
        mov     ecx,[X1]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y3]
        test    ebx,ebx
        js      @@NextLine3
        jz      @@NextLine3
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom3
        sub     esi,ebp
@@NoClippingAtBottom3:
        sub     ebx,edx         ;height
        je      @@NextLine3     ;no necessity to compute horizontal lines
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx
        add     esi,ebx         ;counter
        test    ebp,ebp
        jns     @@Go3
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go3:
        rol     eax,16
ALIGN   16
@@NewRow3:
        mov     [edi],cx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow3
@@NextLine3:
;compute bottom line if neccessary
        mov     edx,[Y3]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine4
        mov     ebx,[Y2]
        cmp     ebx,edx
        jle     @@NextLine4     ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom4
        sub     esi,ebp
@@NoClippingAtBottom4:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X3]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        sal     eax,16
        cdq
        idiv    ebx
        test    ebp,ebp
        jns     @@Go4
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go4:
        rol     eax,16
ALIGN   16
@@NewRow4:
        mov     [edi],cx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow4
@@NextLine4:

;************************
;and finally... fill it!
;************************
        mov     esi,[Y1]
        test    esi,esi
        jns     @@NotSigned
        xor     esi,esi
@@NotSigned:
        imul    esi,[GPenBufferWidth]
        add     esi,[GPPenBuffer]
        mov     [@@PBuffer],esi
        mov     esi,[GPPenLineBuffer]
@@NextLine:
        mov     eax,[esi+12288]
        mov     edx,[esi+16384]
        movsx   edi,[W esi]
        test    edi,edi
        jns     @@DontClear1
        neg     edi

        mov     ecx,eax
        DB      69h,0c7h        ;imul eax,edi,@@Factor3a
@@Factor3a DD     ?
        rol     eax,16
        add     eax,ecx
        adc     eax,0

        mov     ecx,edx
        DB      69h,0d7h        ;imul edx,edi,@@Factor3a
@@Factor3b DD     ?
        rol     edx,16
        add     edx,ecx
        adc     edx,0

        xor     edi,edi
@@DontClear1:
        xor     ecx,ecx
        movsx   ebp,[W esi+4096]
        cmp     ebp,[GPenBufferWidth]
        jl      @@DontClear2
        mov     ebp,[GPenBufferWidth]
@@DontClear2:
        sub     ebp,edi
        jle     @@NoLine
@@NextPixel:

        mov     cl,al
        mov     ch,dl

        DB      8ah,99h         ;mov bl,[ecx+@@PTexture]
@@PTexture DD     ?

        DB      88h,9fh         ;mov [edi+@@PBuffer],bl
@@PBuffer DD      ?

        DB      05h             ;add eax,@@TextureUAddy
@@TextureUAddy DD ?
        adc     eax,0

        DB      81h,0c2h        ;add edx,@@TextureVAddy
@@TextureVAddy DD ?
        adc     edx,0

        inc     edi
        dec     ebp
        jnz     @@NextPixel
@@NoLine:
        mov     eax,[GPenBufferWidth]
        add     [@@PBuffer],eax
        add     esi,4
        dec     [PolyHeight]
        jnz     @@NextLine

@@end:  popad
        ret
ENDP

ALIGN   16
;###########################################################################
PROC    DrawEnvMappedPoly
;IN     esi=pointer to poly structure
;IMPORTANT: The edges must always be in reversed clock wise order!
;Draws an environment mapped mapped polygon.
;###########################################################################
        pushad

        mov     eax,[esi+TPoly.PEnvMap]
        mov     [@@PEnvMap],eax

;       mov     [TextureU1],255
;       mov     [TextureV1],0
;       mov     eax,250-200
;       mov     ebx,20+100
;       mov     [TextureU2],0
;       mov     [TextureV2],255
;       mov     ecx,100-200
;       mov     edx,170+100
;       mov     [TextureU3],255
;       mov     [TextureV3],255
;       mov     ebp,250-200
;       mov     edi,180+100

        mov     edi,[esi+TPoly.PE1]
        movzx   ebp,[edi+TVertex.Xe]
        mov     [TextureU1],ebp
        movzx   ebp,[edi+TVertex.Ye]
        mov     [TextureV1],ebp
        movsx   eax,[W edi+TVertex.Xs]
        movsx   ebx,[W edi+TVertex.Ys]

        mov     edi,[esi+TPoly.PE2]
        movzx   ebp,[edi+TVertex.Xe]
        mov     [TextureU2],ebp
        movzx   ebp,[edi+TVertex.Ye]
        mov     [TextureV2],ebp
        movsx   ecx,[W edi+TVertex.Xs]
        movsx   edx,[W edi+TVertex.Ys]

        mov     edi,[esi+TPoly.PE3]
        movzx   ebp,[edi+TVertex.Xe]
        mov     [TextureU3],ebp
        movzx   ebp,[edi+TVertex.Ye]
        mov     [TextureV3],ebp
        movsx   ebp,[W edi+TVertex.Xs]
        movsx   edi,[W edi+TVertex.Ys]

;************************************************
;check if all edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@YCheck
        cmp     eax,ebp
        je      @@end
@@YCheck:
        cmp     ebx,edx
        jne     @@XYCheckOK
        cmp     ebx,edi
        je      @@end
@@XYCheckOK:

;************************************************
;check if two edges have the same X/Y coordinate
;************************************************
        cmp     eax,ecx
        jne     @@Check2&3
        cmp     ebx,edx
        je      @@end
@@Check2&3:
        cmp     ecx,ebp
        jne     @@Check3&1
        cmp     edx,edi
        je      @@end
@@Check3&1:
        cmp     ebp,eax
        jne     @@CheckOK
        cmp     edi,ebx
        je      @@end
@@CheckOK:

;***********************************
;check if all edges are on one side
;***********************************
        cmp     ebx,0
        jg      @@CheckLeft
        cmp     edx,0
        jg      @@CheckLeft
        cmp     edi,0
        jng     @@end
@@CheckLeft:
        test    eax,eax
        jns     @@CheckDown
        test    ecx,ecx
        jns     @@CheckDown
        test    ebp,ebp
        js      @@end
@@CheckDown:
        mov     esi,[GPenBufferHeight]
        cmp     ebx,esi
        jl      @@CheckRight
        cmp     edx,esi
        jl      @@CheckRight
        cmp     edi,esi
        jnl     @@end
@@CheckRight:
        mov     esi,[GPenBufferWidth]
        cmp     eax,esi
        jl      @@SideTestOK
        cmp     ecx,esi
        jl      @@SideTestOK
        cmp     ebp,esi
        jnl     @@end
@@SideTestOK:

;**********************
;find the highest edge
;**********************
        cmp     edx,ebx
        jle     @@E2higherE1
        cmp     ebx,edi
        jg      @@E3highest
;#1 is the highest and leftmost edge
        mov     [X1],eax
        mov     [Y1],ebx
        mov     [X2],ecx
        mov     [Y2],edx
        mov     [X3],ebp
        mov     [Y3],edi
        mov     eax,[TextureU1]
        mov     ebx,[TextureU2]
        mov     ecx,[TextureU3]
        mov     edx,[TextureV1]
        mov     ebp,[TextureV2]
        mov     edi,[TextureV3]
        jmp     @@HighestEdgeFound
@@E2higherE1:
        cmp     edi,edx
        jle     @@E3highest
;#2 is the highest and leftmost edge
        mov     [X1],ecx
        mov     [Y1],edx
        mov     [X2],ebp
        mov     [Y2],edi
        mov     [X3],eax
        mov     [Y3],ebx
        mov     eax,[TextureU2]
        mov     ebx,[TextureU3]
        mov     ecx,[TextureU1]
        mov     edx,[TextureV2]
        mov     ebp,[TextureV3]
        mov     edi,[TextureV1]
        jmp     @@HighestEdgeFound
@@E3highest:
;#3 is the highest and leftmost edge
        mov     [X1],ebp
        mov     [Y1],edi
        mov     [X2],eax
        mov     [Y2],ebx
        mov     [X3],ecx
        mov     [Y3],edx
        mov     eax,[TextureU3]
        mov     ebx,[TextureU1]
        mov     ecx,[TextureU2]
        mov     edx,[TextureV3]
        mov     ebp,[TextureV1]
        mov     edi,[TextureV2]
@@HighestEdgeFound:
        mov     [TextureU1],eax
        mov     [TextureU2],ebx
        mov     [TextureU3],ecx
        mov     [TextureV1],edx
        mov     [TextureV2],ebp
        mov     [TextureV3],edi

;************************
;compute texture X-Addys
;************************
;calculate dividend for U
        sub     ebx,eax         ;bz
        sub     ecx,eax         ;az

        mov     eax,[Y2]
        sub     eax,[Y1]        ;by
        mov     esi,eax
        imul    ecx             ;*az
        mov     ebp,eax

        mov     eax,[Y3]
        sub     eax,[Y1]        ;ay
        mov     edi,eax
        imul    ebx             ;*bz
        sub     ebp,eax

;calculate divisor for U and V
        mov     eax,[X1]
        mov     ebx,[X2]
        sub     ebx,eax         ;bx
        mov     ecx,[X3]
        sub     ecx,eax         ;ax

        mov     eax,ecx
        imul    esi,eax         ;ax*by
        mov     eax,ebx
        imul    edi             ;bx*ay
        sub     esi,eax
        jz      @@end           ;all points lie in one line!

;calculate dividend for V
        mov     eax,[TextureV1]
        mov     ebx,[TextureV2]
        mov     ecx,[TextureV3]
        sub     ebx,eax         ;bz
        sub     ecx,eax         ;az

        mov     eax,[Y2]
        sub     eax,[Y1]        ;by
        imul    ecx             ;*az
        mov     edi,eax

        mov     eax,[Y3]
        sub     eax,[Y1]        ;ay
        imul    ebx             ;*bz
        sub     edi,eax

;calculate texture addy for U and V
        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    esi
        mov     [@@Factor3a],eax
        rol     eax,16
        mov     [@@TextureUAddy],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    esi
        mov     [@@Factor3b],eax
        rol     eax,16
        mov     [@@TextureVAddy],eax

;*******************
;compute left lines
;*******************
        mov     edi,[GPPenLineBuffer]
        mov     ecx,[X1]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y2]
        test    ebx,ebx
        js      @@NextLine1
        jz      @@NextLine1
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom1
        sub     esi,ebp
@@NoClippingAtBottom1:
        sub     ebx,edx         ;height
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor1a],eax
        rol     eax,16
        mov     [@@Argument1a],eax

        mov     eax,[TextureU2]
        sub     eax,[TextureU1]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor1b],eax
        rol     eax,16
        mov     [@@Argument1b],eax
        mov     edi,[TextureU1]

        mov     eax,[TextureV2]
        sub     eax,[TextureV1]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor1c],eax
        rol     eax,16
        mov     [@@Argument1c],eax
        mov     edx,[TextureV1]

        add     esi,ebx         ;counter
        mov     ebx,edi
        mov     [PolyHeight],si
        test    ebp,ebp
        jns     @@Go1
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si

        DB      69h,0c5h        ;imul eax,ebp,@@Factor1a
@@Factor1a DD     ?
        rol     eax,16
        add     ecx,eax
        adc     ecx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor1b
@@Factor1b DD     ?
        rol     eax,16
        add     ebx,eax
        adc     ebx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor1c
@@Factor1c DD     ?
        rol     eax,16
        add     edx,eax
        adc     edx,0

@@Go1:  mov     edi,[GPPenLineBuffer]

ALIGN   16
@@NewRow1:
        mov     [edi],cx
        mov     [edi+12288],ebx
        mov     [edi+16384],edx
        add     edi,4
        db      81h,0c1h        ;add ecx,@@Argument1a
@@Argument1a DD   ?
        adc     ecx,0

        db      81h,0c3h        ;add ebx,@@Argument1b
@@Argument1b DD   ?
        adc     ebx,0

        db      81h,0c2h        ;add edx,@@Argument1c
@@Argument1c DD   ?
        adc     edx,0

        dec     esi
        jnz     @@NewRow1
@@NextLine1:

;compute bottom line if neccessary
        mov     edx,[Y2]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine2
        mov     ebx,[Y3]
        cmp     ebx,edx
        jle     @@NextLine2    ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom2
        sub     esi,ebp
@@NoClippingAtBottom2:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X2]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        add     [PolyHeight],si
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor2a],eax
        rol     eax,16
        mov     [@@Argument2a],eax

        push    edi
        mov     eax,[TextureU3]
        sub     eax,[TextureU2]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor2b],eax
        rol     eax,16
        mov     [@@Argument2b],eax
        mov     edi,[TextureU2]

        mov     eax,[TextureV3]
        sub     eax,[TextureV2]
        sal     eax,16
        cdq
        idiv    ebx
        mov     [@@Factor2c],eax
        rol     eax,16
        mov     [@@Argument2c],eax
        mov     edx,[TextureV2]

        mov     ebx,edi
        test    ebp,ebp
        jns     @@Go2
        neg     ebp
        sub     esi,ebp
        mov     [PolyHeight],si

        DB      69h,0c5h        ;imul eax,ebp,@@Factor2a
@@Factor2a DD     ?
        rol     eax,16
        add     ecx,eax
        adc     ecx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor2b
@@Factor2b DD     ?
        rol     eax,16
        add     ebx,eax
        adc     ebx,0

        DB      69h,0c5h        ;imul eax,ebp,@@Factor2c
@@Factor2c DD     ?
        rol     eax,16
        add     edx,eax
        adc     edx,0

@@Go2:  pop     edi

ALIGN   16
@@NewRow2:
        mov     [edi],cx
        mov     [edi+12288],ebx
        mov     [edi+16384],edx
        add     edi,4
        db      81h,0c1h        ;add ecx,@@Argument2a
@@Argument2a DD   ?
        adc     ecx,0

        db      81h,0c3h        ;add ebx,@@Argument2b
@@Argument2b DD   ?
        adc     ebx,0

        db      81h,0c2h        ;add edx,@@Argument2c
@@Argument2c DD   ?
        adc     edx,0

        dec     esi
        jnz     @@NewRow2
@@NextLine2:

;********************
;compute right lines
;********************
        mov     edi,[GPPenLineBuffer]
        add     edi,4096
        mov     ecx,[X1]
        mov     eax,[X3]
        sub     eax,ecx         ;width
        mov     edx,[Y1]
        mov     ebx,[Y3]
        test    ebx,ebx
        js      @@NextLine3
        jz      @@NextLine3
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom3
        sub     esi,ebp
@@NoClippingAtBottom3:
        sub     ebx,edx         ;height
        je      @@NextLine3     ;no necessity to compute horizontal lines
        mov     ebp,edx
        sal     eax,16
        cdq
        idiv    ebx
        add     esi,ebx         ;counter
        test    ebp,ebp
        jns     @@Go3
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go3:
        rol     eax,16
ALIGN   16
@@NewRow3:
        mov     [edi],cx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow3
@@NextLine3:
;compute bottom line if neccessary
        mov     edx,[Y3]
        cmp     edx,[GPenBufferHeight]
        jnl     @@NextLine4
        mov     ebx,[Y2]
        cmp     ebx,edx
        jle     @@NextLine4     ;no necessity to compute horizontal lines
        xor     esi,esi
        mov     ebp,ebx
        sub     ebp,[GPenBufferHeight]
        jl      @@NoClippingAtBottom4
        sub     esi,ebp
@@NoClippingAtBottom4:
        sub     ebx,edx
        mov     ebp,edx
        mov     ecx,[X3]
        mov     eax,[X2]
        sub     eax,ecx         ;width
        add     esi,ebx         ;counter
        sal     eax,16
        cdq
        idiv    ebx
        test    ebp,ebp
        jns     @@Go4
        neg     ebp
        sub     esi,ebp
        mov     ebx,eax
        imul    eax,ebp
        rol     eax,16
        add     ecx,eax
        adc     ecx,0
        mov     eax,ebx
@@Go4:
        rol     eax,16
ALIGN   16
@@NewRow4:
        mov     [edi],cx
        add     edi,4
        add     ecx,eax
        adc     ecx,0
        dec     esi
        jnz     @@NewRow4
@@NextLine4:

;************************
;and finally... fill it!
;************************
        mov     esi,[Y1]
        test    esi,esi
        jns     @@NotSigned
        xor     esi,esi
@@NotSigned:
        imul    esi,[GPenBufferWidth]
        add     esi,[GPPenBuffer]
        mov     [@@PBuffer],esi
        mov     esi,[GPPenLineBuffer]
@@NextLine:
        mov     eax,[esi+12288]
        mov     edx,[esi+16384]
        movsx   edi,[W esi]
        test    edi,edi
        jns     @@DontClear1
        neg     edi

        mov     ecx,eax
        DB      69h,0c7h        ;imul eax,edi,@@Factor3a
@@Factor3a DD     ?
        rol     eax,16
        add     eax,ecx
        adc     eax,0

        mov     ecx,edx
        DB      69h,0d7h        ;imul edx,edi,@@Factor3a
@@Factor3b DD     ?
        rol     edx,16
        add     edx,ecx
        adc     edx,0

        xor     edi,edi
@@DontClear1:
        xor     ecx,ecx
        movsx   ebp,[W esi+4096]
        cmp     ebp,[GPenBufferWidth]
        jl      @@DontClear2
        mov     ebp,[GPenBufferWidth]
@@DontClear2:
        sub     ebp,edi
        jle     @@NoLine
@@NextPixel:

        mov     cl,al
        mov     ch,dl

        DB      8ah,99h         ;mov bl,[ecx+@@PEnvMap]
@@PEnvMap DD    ?

        DB      88h,9fh         ;mov [edi+@@PBuffer],bl
@@PBuffer DD    ?

        DB      05h             ;add eax,@@TextureUAddy
@@TextureUAddy DD ?
        adc     eax,0

        DB      81h,0c2h        ;add edx,@@TextureVAddy
@@TextureVAddy DD ?
        adc     edx,0

        inc     edi
        dec     ebp
        jnz     @@NextPixel
@@NoLine:
        mov     eax,[GPenBufferWidth]
        add     [@@PBuffer],eax
        add     esi,4
        dec     [PolyHeight]
        jnz     @@NextLine

@@end:  popad
        ret
ENDP


ALIGN 4
X1      DD      ?
Y1      DD      ?
X2      DD      ?
Y2      DD      ?
X3      DD      ?
Y3      DD      ?

Light1  DD      ?       ;used for Gouroud Shading
Light2  DD      ?
Light3  DD      ?
GouroudAddy DD  ?
TextureU1 DD    ?       ;used for Texture Mapping
TextureV1 DD    ?
TextureU2 DD    ?
TextureV2 DD    ?
TextureU3 DD    ?
TextureV3 DD    ?

GPPenBuffer     DD      ?       ;pointer to the draw buffer
GPenBufferWidth DD      ?       ;width of the draw buffer
GPenBufferHeight DD     ?       ;height of the draw buffer
GPPenLineBuffer DD      ?       ;pointer to some 20k of free memory
PolyHeight      DW      ?
PolyColor       DB      ?

ENDS
END