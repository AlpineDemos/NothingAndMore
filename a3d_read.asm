IDEAL
P386
ASSUME  cs:code32,ds:code32

SEGMENT code32  PARA PUBLIC USE32
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
INCLUDE 'decl.inc'
INCLUDE 'a3d_read.inc'
INCLUDE '3dmain.inc'

;#############################################################################
PROC    MakeObject
;IN     esi=pointer to an A3D object, edi=pointer to a TObject structure
;IN     ax=number of the object
;OUT    CF=0 success, CF=1 failure
;reads an A3D object and converts it to the Alpine 3D Engine format
;#############################################################################
        pushad
        push    eax
        mov     [PObject],edi
        mov     al,[esi]
        mov     [Count],al

;allocate memory
        movzx   eax,[W esi+1]
;WriteDecWord   ax
        mov     [edi+TObject.NrVertices],ax
        imul    eax,TVertexLENGTH
        call    _gethimem
        jc      @@end
        mov     [PVertices],eax
        mov     [edi+TObject.PFirstVertex],eax

        movzx   eax,[W esi+3]
;WriteLnDecWord ax
        mov     [edi+TObject.NrPolys],ax
        imul    eax,TPolyLENGTH
        call    _gethimem
        jc      @@end
        mov     [PPolys],eax
        mov     [edi+TObject.PFirstPoly],eax
        add     esi,5

@@1:    mov     edi,O Coding
        mov     ecx,29
rep     movsb
;WriteLnString 'new chunk'
;WriteLnDecByte [Coding]
;WriteDecDWord [XFactor]
;WriteDecDWord [YFactor]
;WriteLnDecDWord [ZFactor]
;WriteDecDWord [XAddy]
;WriteDecDWord [YAddy]
;WriteLnDecDWord [ZAddy]
;WriteDecWord [NrVertices]
;WriteLnDecWord [NrPolys]
;WriteDecDWord [PVertices]
;WriteLnDecDWord [PPolys]

        mov     bp,[NrVertices]
        mov     edi,[PVertices]
        mov     ebx,edi
        cmp     [Coding],0
        jnz     @@WordCodingVertices

;vertex coordinates are coded as bytes
@@2a:   xor     eax,eax
        mov     ah,[esi]
        inc     esi
        FixMul  [XFactor]
        add     eax,[XAddy]
        mov     [edi+TVertex.Xv],eax
;WriteDecDWord eax

        xor     eax,eax
        mov     ah,[esi]
        inc     esi
        FixMul  [YFactor]
        add     eax,[YAddy]
        mov     [edi+TVertex.Yv],eax
;WriteDecDWord eax

        xor     eax,eax
        mov     ah,[esi]
        inc     esi
        FixMul  [ZFactor]
        add     eax,[ZAddy]
        mov     [edi+TVertex.Zv],eax
;WriteLnDecDWord eax

        mov     [edi+TVertex.Attr],1

        add     edi,TVertexLENGTH
        dec     bp
        jnz     @@2a
        jmp     @@Polys

;vertex coordinates are coded as words
@@WordCodingVertices:
@@2b:   xor     eax,eax
        mov     ax,[esi]
        add     esi,2
        FixMul  [XFactor]
        add     eax,[XAddy]
        mov     [edi+TVertex.Xv],eax
;WriteDecDWord eax

        xor     eax,eax
        mov     ax,[esi]
        add     esi,2
        FixMul  [YFactor]
        add     eax,[YAddy]
        mov     [edi+TVertex.Yv],eax
;WriteDecDWord eax

        xor     eax,eax
        mov     ax,[esi]
        add     esi,2
        FixMul  [ZFactor]
        add     eax,[ZAddy]
        mov     [edi+TVertex.Zv],eax
;WriteLnDecDWord eax

        mov     [edi+TVertex.Attr],1

        add     edi,TVertexLENGTH
        dec     bp
        jnz     @@2b

@@Polys:
        mov     [PVertices],edi
        mov     edi,[PPolys]
        mov     bp,[NrPolys]
        cmp     [NrVertices],256
        ja      @@WordCodingPolys

;polygon edges are coded as bytes
@@3a:   xor     eax,eax
        mov     al,[esi]
;WriteDecByte   al
        imul    eax,TVertexLENGTH
        add     eax,ebx
        inc     esi
        mov     [edi+TPoly.PE1],eax

        xor     eax,eax
        mov     al,[esi]
;WriteDecByte   al
        imul    eax,TVertexLENGTH
        add     eax,ebx
        inc     esi
        mov     [edi+TPoly.PE2],eax

        xor     eax,eax
        mov     al,[esi]
;WriteLnDecByte al
        imul    eax,TVertexLENGTH
        add     eax,ebx
        inc     esi
        mov     [edi+TPoly.PE3],eax

        mov     [edi+TPoly.Color],1
        mov     [edi+TPoly.Attr],1

        add     edi,TPolyLENGTH
        dec     bp
        jnz     @@3a
        jmp     @@NextChunk

;polygon edges are coded as words
@@WordCodingPolys:
@@3b:   xor     eax,eax
        mov     ax,[esi]
;WriteDecWord ax
        imul    eax,TVertexLENGTH
        add     eax,ebx
        add     esi,2
        mov     [edi+TPoly.PE1],eax

        xor     eax,eax
        mov     ax,[esi]
;WriteDecWord ax
        imul    eax,TVertexLENGTH
        add     eax,ebx
        add     esi,2
        mov     [edi+TPoly.PE2],eax

        xor     eax,eax
        mov     ax,[esi]
;WriteLnDecWord ax
        imul    eax,TVertexLENGTH
        add     eax,ebx
        add     esi,2
        mov     [edi+TPoly.PE3],eax

        mov     [edi+TPoly.Color],1
        mov     [edi+TPoly.Attr],1

        add     edi,TPolyLENGTH
        dec     bp
        jnz     @@3b

@@NextChunk:
        mov     [PPolys],edi
        dec     [Count]
        jnz     @@1

        pop     eax
        call    CalcPolyNormals
        call    CalcVertexNormals

        clc
@@end:  popad
        ret

Count   DB      ?
Coding  DB      ?
XFactor DD      ?
YFactor DD      ?
ZFactor DD      ?
XAddy   DD      ?
YAddy   DD      ?
ZAddy   DD      ?
NrVertices DW   ?
NrPolys DW      ?
PObject DD      ?
PVertices DD    ?
PPolys  DD      ?

ENDP

ENDS
END