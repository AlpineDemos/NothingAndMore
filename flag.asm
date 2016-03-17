;simulates a flag
IDEAL
P386
ASSUME  cs:code32,ds:code32

SEGMENT code32  PARA PUBLIC USE32
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
;INCLUDE 'decl.inc'
INCLUDE 'flag.inc'
INCLUDE '3dmain.inc'

o EQU OFFSET
b EQU BYTE PTR
w EQU WORD PTR
d EQU DWORD PTR


FLAGWIDTH = 60*65536
FLAGHEIGHT = 50*65536
XUNITS = 12
YUNITS = 10
SLOWDOWN = 65300
GRAVITY = 300
OPTIMALDISTANCE = FLAGWIDTH/XUNITS
ELASTICITY = 10000

MACRO FixMul XXX
imul xxx
shrd eax,edx,16
endm


;#############################################################################
PROC    InitFlag
;IN     edi=pointer to a TObject structure
;       eax=object number
;       ebx=pointer to the first texture
;       ecx=pointer to the second texture
;OUT    CF=0 success, CF=1 failure
;initialise the flag-object and allocate memory for it
;#############################################################################
        pushad
        mov     [ObjectNumber],eax
        mov     [P1stTexture],ebx
        mov     [P2ndTexture],ecx
        mov     [PObject],edi
;allocate memory
        mov     eax,(XUNITS+1)*(YUNITS+1)*16
        call    _gethimem
        jc      @@end
        mov     [PSpeed],eax
        push    edi
        mov     edi,eax
        mov     ecx,(XUNITS+1)*(YUNITS+1)*4
        xor     eax,eax
rep     stosd
        pop     edi

        mov     [edi+TObject.NrVertices],(XUNITS+1)*(YUNITS+1)
        mov     eax,(XUNITS+1)*(YUNITS+1)*TVertexLENGTH
        call    _gethimem
        jc      @@end
        mov     [PVertices],eax
        mov     [edi+TObject.PFirstVertex],eax
        mov     esi,eax

        mov     [edi+TObject.NrPolys],XUNITS*YUNITS*4
        mov     eax,XUNITS*YUNITS*4*TPolyLENGTH
        call    _gethimem
        jc      @@end
        mov     [PPolys],eax
        mov     [edi+TObject.PFirstPoly],eax

;calculate vertices
        xor     edx,edx
        mov     ebx,XUNITS
        mov     eax,FLAGWIDTH
        div     ebx
        mov     [XAddy],eax
        xor     edx,edx
        mov     eax,256*65536-100
        div     ebx
        rol     eax,16
        mov     [TexXAddy],eax
        xor     edx,edx
        mov     ebx,YUNITS
        mov     eax,FLAGHEIGHT
        div     ebx
        mov     [YAddy],eax
        xor     edx,edx
        mov     eax,256*65536-100
        div     ebx
        rol     eax,16
        mov     [TexYAddy],eax

        mov     cl,YUNITS+1
        xor     ebx,ebx
        xor     edx,edx
@@1a:   mov     ch,XUNITS+1
        xor     edi,edi
        xor     eax,eax
@@2a:   mov     [esi+TVertex.Xv],edi
        mov     [esi+TVertex.Yv],ebx
        mov     [esi+TVertex.Zv],0
        mov     [B esi+TVertex.Temp],al
        mov     [B 1+esi+TVertex.Temp],dl
        mov     [esi+TVertex.Attr],0
        add     edi,[XAddy]
        add     eax,[TexXAddy]
        adc     eax,0
        add     esi,TVertexLENGTH
        dec     ch
        jnz     @@2a
        add     ebx,[YAddy]
        add     edx,[TexYAddy]
        adc     edx,0
        dec     cl
        jnz     @@1a

;calculate polygons
        mov     esi,[PVertices]
        mov     edi,[PPolys]

        mov     cl,YUNITS
@@1b:   mov     ch,XUNITS
@@2b:
        mov     [edi+TPoly.PE3],esi
        mov     [edi+TPolyLENGTH+TPoly.PE1],esi
        mov     [edi+TPolyLENGTH*2+TPoly.PE1],esi
        mov     [edi+TPolyLENGTH*3+TPoly.PE3],esi
;       mov     eax,[esi+TVertex.Temp]

        add     esi,TVertexLENGTH
        mov     [edi+TPoly.PE2],esi
        mov     [edi+TPolyLENGTH*2+TPoly.PE2],esi

        add     esi,(XUNITS+1)*TVertexLENGTH
        mov     [edi+TPoly.PE1],esi
        mov     [edi+TPolyLENGTH+TPoly.PE3],esi
        mov     [edi+TPolyLENGTH*2+TPoly.PE3],esi
        mov     [edi+TPolyLENGTH*3+TPoly.PE1],esi

        sub     esi,TVertexLENGTH
        mov     [edi+TPolyLENGTH+TPoly.PE2],esi
        mov     [edi+TPolyLENGTH*3+TPoly.PE2],esi
        sub     esi,(XUNITS+1)*TVertexLENGTH

        mov     [edi+TPoly.Attr],0
        mov     [edi+TPolyLENGTH+TPoly.Attr],0
        mov     [edi+TPolyLENGTH*2+TPoly.Attr],0
        mov     [edi+TPolyLENGTH*3+TPoly.Attr],0

        mov     [edi+TPoly.Color],ch
        mov     [edi+TPolyLENGTH+TPoly.Color],ch
        mov     [edi+TPolyLENGTH*2+TPoly.Color],ch
        mov     [edi+TPolyLENGTH*3+TPoly.Color],ch

        add     edi,TPolyLENGTH*4
        add     esi,TVertexLENGTH
        dec     ch
        jnz     @@2b
        add     esi,TVertexLENGTH
        dec     cl
        jnz     @@1b

        mov     eax,[ObjectNumber]
        call    CalcPolyNormals
;       call    CalcVertexNormals

        clc
@@end:  popad
        ret

;#############################################################################
PROC    AddForce
;IN     ebx = nr of first vertex
;       ecx = nr of second vertex
;#############################################################################
        pushad
        imul    edi,ebx,16      ;!!!!!!!!!!!!!!!!!
        add     edi,[PSpeed]
        imul    ebx,TVertexLENGTH
        add     ebx,[PVertices]
        imul    ecx,TVertexLENGTH
        add     ecx,[PVertices]

        mov     eax,[ebx+TVertex.Xv]
        mov     [X],eax
        mov     eax,[ebx+TVertex.Yv]
        mov     [Y],eax
        mov     eax,[ebx+TVertex.Zv]
        mov     [Z],eax

        mov     eax,[ecx+TVertex.Xv]
        sub     [X],eax
        mov     eax,[X]
        FixMul  eax
        mov     ebp,eax
        mov     eax,[ecx+TVertex.Yv]
        sub     [Y],eax
        mov     eax,[Y]
        FixMul  eax
        add     ebp,eax
        mov     eax,[ecx+TVertex.Zv]
        sub     [Z],eax
        mov     eax,[Z]
        FixMul  eax
        add     eax,ebp
        call    SqrRoot
        mov     ebp,eax

        mov     eax,[X]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [X],eax
        mov     eax,[Y]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [Y],eax
        mov     eax,[Z]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [Z],eax

        mov     eax,OPTIMALDISTANCE
        sub     eax,ebp
        mov     ebx,ELASTICITY
        FixMul  ebx
        mov     ebp,eax

        mov     eax,[X]
        FixMul  ebp
        add     [edi],eax
        mov     eax,[Y]
        FixMul  ebp
        add     [edi+4],eax
        mov     eax,[Z]
        FixMul  ebp
        add     [edi+8],eax

        popad
        ret
ENDP

;#############################################################################
PROC    MoveFlag
;simulates wind and gravity and moves the vertices
;#############################################################################
        pushad

;slowdown and gravity
        mov     ebp,(XUNITS+1)*(YUNITS+1)
        mov     esi,[PSpeed]
        mov     ebx,SLOWDOWN
@@1:    mov     eax,[esi]
        FixMul  ebx
        mov     [esi],eax
        mov     eax,[esi+4]
        FixMul  ebx
        add     eax,GRAVITY
        mov     [esi+4],eax
        mov     eax,[esi+8]
        FixMul  ebx
        mov     [esi+8],eax
        add     esi,16
        dec     ebp
        jnz     @@1

;*******************
;compute elasticity
;*******************
;right
        mov     ebp,YUNITS-1
        mov     ebx,XUNITS*2+1
@@Right:
        mov     ecx,ebx
        dec     ecx
        call    AddForce
        mov     ecx,ebx
        sub     ecx,XUNITS+1
        call    AddForce
        mov     ecx,ebx
        add     ecx,XUNITS+1
        call    AddForce
        add     ebx,XUNITS+1
        dec     ebp
        jnz     @@Right

;left
        mov     ebp,YUNITS-1
        mov     ebx,XUNITS+1
@@Left:
        mov     ecx,ebx
        inc     ecx
        call    AddForce
        mov     ecx,ebx
        sub     ecx,XUNITS+1
        call    AddForce
        mov     ecx,ebx
        add     ecx,XUNITS+1
        call    AddForce
        add     ebx,XUNITS+1
        dec     ebp
        jnz     @@Left

;top
        mov     ebp,XUNITS-1
        mov     ebx,1
@@Top:
        mov     ecx,ebx
        add     ecx,XUNITS+1
        call    AddForce
        mov     ecx,ebx
        inc     ecx
        call    AddForce
        mov     ecx,ebx
        dec     ecx
        call    AddForce
        inc     ebx
        dec     ebp
        jnz     @@Top

;bottom
        mov     ebp,XUNITS-1
        mov     ebx,YUNITS*(XUNITS+1)+1
@@Bottom:
        mov     ecx,ebx
        sub     ecx,XUNITS+1
        call    AddForce
        mov     ecx,ebx
        inc     ecx
        call    AddForce
        mov     ecx,ebx
        dec     ecx
        call    AddForce
        inc     ebx
        dec     ebp
        jnz     @@Bottom

;right top edge
        mov     ebx,XUNITS+YUNITS*(XUNITS+1)
        mov     ecx,XUNITS+YUNITS*(XUNITS+1)-1
        call    AddForce
        mov     ecx,XUNITS+(YUNITS-1)*(XUNITS+1)
        call    AddForce

;right bottom edge
        mov     ebx,XUNITS
        mov     ecx,XUNITS-1
        call    AddForce
        mov     ecx,XUNITS*2+1
        call    AddForce

;middle
        mov     ebx,XUNITS+2
        mov     edx,YUNITS-1
@@Middle1:
        mov     ebp,XUNITS-1
@@Middle2:
        mov     ecx,ebx
        dec     ecx
        call    AddForce
        mov     ecx,ebx
        inc     ecx
        call    AddForce
        mov     ecx,ebx
        sub     ecx,XUNITS+1
        call    AddForce
        mov     ecx,ebx
        add     ecx,XUNITS+1
        call    AddForce
        inc     ebx
        dec     ebp
        jnz     @@Middle2
        add     ebx,2
        dec     edx
        jnz     @@Middle1

;********
;wind!!!
;********
        mov     eax,[Seed]
        mul     [Factor]
        mov     [Seed],eax
        cmp     ah,30
        ja      @@NoChange
        and     eax,0ffffh
        shr     eax,5
        add     eax,300
        mov     [WindStrength],eax
@@NoChange:

        mov     ecx,YUNITS+1
        mov     ebx,[PVertices]
        mov     esi,[PSpeed]
        add     esi,16
@@Wind1:
        mov     ebp,XUNITS
@@Wind2:
        mov     eax,[ebx+TVertex.Zv]
        sub     eax,[ebx+TVertexLENGTH+TVertex.Zv]
        jns     @@WindNS1
        neg     eax
@@WindNS1:
        mov     edi,eax

        mov     eax,[ebx+TVertex.Yv]
        sub     eax,[ebx+TVertexLENGTH+TVertex.Yv]
        jns     @@WindNS2
        neg     eax
@@WindNS2:
        add     eax,edi
        FixMul  [WindStrength] ;!!!!!!!!!!!!!!!!!
        add     [esi],eax

        add     ebx,TVertexLENGTH
        add     esi,16
        dec     ebp
        jnz     @@Wind2
        add     ebx,TVertexLENGTH
        add     esi,16
        dec     ecx
        jnz     @@Wind1


;**********************
;add speed to vertices
;**********************
        mov     ebp,(XUNITS+1)*(YUNITS)-1
        mov     esi,[PSpeed]
        mov     edi,[PVertices]
        add     esi,16
        add     edi,TVertexLENGTH
@@2a:   mov     eax,[esi]
        add     [edi+TVertex.Xv],eax
        mov     eax,[esi+4]
        add     [edi+TVertex.Yv],eax
        mov     eax,[esi+8]
        add     [edi+TVertex.Zv],eax
        add     esi,16
        add     edi,TVertexLENGTH
        dec     ebp
        jnz     @@2a
        add     esi,16
        add     edi,TVertexLENGTH
        mov     ebp,XUNITS
@@2b:   mov     eax,[esi]
        add     [edi+TVertex.Xv],eax
        mov     eax,[esi+4]
        add     [edi+TVertex.Yv],eax
        mov     eax,[esi+8]
        add     [edi+TVertex.Zv],eax
        add     esi,16
        add     edi,TVertexLENGTH
        dec     ebp
        jnz     @@2b

;       mov     eax,[ObjectNumber]
;       call    CalcPolyNormals

        popad
ret
ENDP

XAddy   DD      ?
YAddy   DD      ?
TexXAddy DD     ?
TexYAddy DD     ?
P1stTexture DD  ?
P2ndTexture DD  ?
PObject DD      ?
PVertices DD    ?
PPolys  DD      ?
PSpeed  DD      ?
ObjectNumber DD ?
WindStrength DD 500
Seed    DD      8088405h
Factor  DD      0019d7dh

X       DD      ?
Y       DD      ?
Z       DD      ?

ENDP

ENDS
END