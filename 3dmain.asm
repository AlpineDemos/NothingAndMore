;the main module of the ALPINE 3D-Engine
;written in spring and summer 1997 by Ziron

IDEAL
P386
ASSUME  cs:code32,ds:code32

MAXPOLYS        EQU     1024    ;maximum number of polys supported by the engine
EXACTNESS       EQU     2       ;exactness factor for the square root function
                                ;lower=more exact, higher=less exact

SEGMENT code32  PARA PUBLIC USE32
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
INCLUDE 'decl.inc'
INCLUDE '3dmain.inc'
INCLUDE '3dpen.inc'

;############################################################################
PROC    Init3DEngine
;OUT    CF=0 success, CF=1 failure
;Allocates memory and does other neccessary stuff.
;############################################################################
        mov     eax,20480
        call    _getmem
        jc      @@error
        mov     [GPPenLineBuffer],eax
        mov     eax,MAXPOLYS*8
        call    _getmem
        jc      @@error
        mov     [PSortMainBuffer],eax
        mov     eax,MAXPOLYS*8*16
        call    _getmem
        jc      @@error
        mov     [PSortHelpBuffers],eax
        clc                     ;yeah, success!
@@error: ret
ENDP

;############################################################################
PROC    CalcSinus
;OUT    CF=0 success, CF=1 failure
;Allocates memory and calculates the 4096-item sinus table.
;The address of the table is stored in [GPSinTable].
;############################################################################
        mov     eax,16384
        call    _getmem
        jc      @@error
        mov     [GPSinTable],eax
        mov     edi,eax
        mov     bp,2047
        xor     ebx,ebx         ;sinus
        mov     ecx,1647099     ;a=2*PI/size
        mov     [D edi],0
        add     edi,4
@@1:    mov     eax,2527        ;b=(2*PI/size)ý
        imul    ebx             ;b*sinus
        add     eax,2 shl 29
        adc     edx,0
        shrd    eax,edx,30
        sub     ecx,eax         ;a=a-b*sinus
        add     ebx,ecx         ;sinus=sinus+a
        mov     eax,ebx
        add     eax,8192
        sar     eax,14
        mov     [edi],eax
        neg     eax
        mov     [edi+8192],eax
        add     edi,4
        dec     bp
        jnz     @@1
        mov     [D edi],0
        clc
@@error: ret
ENDP

;############################################################################
PROC    CalcArcusSinus
;OUT    CF=0 success, CF=1 failure
;ATTENTION! When calling this procedure, the sinus table has to be calculated
;already!
;Allocates memory and calculates the 1024(+128)-item arucs sinus table as
;needed for environment mapping and modificates env mapping code.
;The address of the table is stored in [PArcSinTable].
;The real table begins at [OFFSET PArcSinTable+64]!
;############################################################################
        mov     eax,1024+128
        call    _getmem
        jc      @@error
        mov     [PArcSinTable],eax
        mov     [PArcSinModify1],eax    ;selfmodificating code
        mov     [PArcSinModify2],eax
        mov     edi,eax
        xor     eax,eax
        mov     ecx,256+16
rep     stosd           ;fill the first 256 bytes and the array with zeroes
        mov     eax,-1
        mov     ecx,16
rep     stosd           ;fill the last 256 bytes with 0ffh
;calculate ArcSin from the sinus table
        mov     edi,[PArcSinTable]
        add     edi,64
        mov     esi,[GPSinTable]
        add     esi,4096
        mov     ebp,2048
        xor     ebx,ebx
@@1:    mov     eax,[esi]
        neg     eax
        add     eax,65536
        shr     eax,7
        mov     [edi+eax],bh
        add     esi,4
        add     ebx,32
        dec     ebp
        jnz     @@1
        clc
@@error: ret
ENDP

;############################################################################
PROC    SqrRoot
;IN     eax=16.16 fixed-point number
;OUT    eax=16.16 fixed-point number
;calculates the square root of a number
;############################################################################
        test    eax,eax
        jz      @@zero
        push    ebx
        push    edx
        push    esi
        push    edi
        mov     esi,eax
        xor     edi,edi
        shld    edi,esi,16      ;upper 16 bits to edi
        shl     esi,16
        ALIGN   16
@@1:    mov     ebx,eax
        mov     eax,esi
        mov     edx,edi
        div     ebx
        add     eax,ebx
        shr     eax,1
        mov     edx,eax
        shr     ebx,EXACTNESS
        shr     edx,EXACTNESS
        cmp     ebx,edx         ;check if the result is exact enough already
        jne     @@1             ;if not, jump

        pop     edi
        pop     esi
        pop     edx
        pop     ebx
@@zero: ret
ENDP

;############################################################################
PROC    CalcPolyNormals
;IN     eax=object number
;calculates the polygon-normals of an object
;############################################################################
        pushad
        shl     eax,5
        add     eax,[GPObjects]         ;addres of object
        mov     bp,[eax+TObject.NrPolys]
        mov     esi,[eax+TObject.PFirstPoly]
@@1:;copy vertices 2 and 3 into temp-vars
        mov     ebx,O Temp0
        mov     edi,[esi+TPoly.PE2]
        mov     eax,[edi+TVertex.Xv]
        mov     [ebx],eax
        mov     eax,[edi+TVertex.Yv]
        mov     [ebx+4],eax
        mov     eax,[edi+TVertex.Zv]
        mov     [ebx+8],eax
        mov     edi,[esi+TPoly.PE3]
        mov     eax,[edi+TVertex.Xv]
        mov     [ebx+12],eax
        mov     eax,[edi+TVertex.Yv]
        mov     [ebx+16],eax
        mov     eax,[edi+TVertex.Zv]
        mov     [ebx+20],eax
;copy vertex 1 into regs
        mov     edi,[esi+TPoly.PE1]
        mov     eax,[edi+TVertex.Xv]
        mov     ebx,[edi+TVertex.Yv]
        mov     edx,[edi+TVertex.Zv]
;calculate the vectors 1->2 and 1->3 and save them into temp-vars
        mov     ecx,O Temp0
        sub     [ecx],eax
        sub     [ecx+4],ebx
        sub     [ecx+8],edx

        sub     [ecx+12],eax
        sub     [ecx+16],ebx
        sub     [ecx+20],edx

;WriteDecWord bp
;WriteDecDWord [Temp0]
;WriteDecDWord [Temp1]
;WriteDecDWord [Temp2]
;WriteDecDWord [Temp3]
;WriteDecDWord [Temp4]
;WriteLnDecDWord [Temp5]
;caluclate the cross-product of the two vectors and the length of
;the resulting normal vector
        mov     eax,[ecx+4]     ;load u2
        FixMul  <[D ecx+20]>    ;multiplicate with u3
        mov     ebx,eax         ;save result
        mov     eax,[ecx+8]     ;load u3
        FixMul  <[D ecx+16]>    ;multiplicate with u2
        sub     ebx,eax         ;ok!
        mov     [esi+TPoly.Xn],ebx      ;save result
        mov     eax,ebx
        FixMul  ebx
        mov     [ecx+24],eax    ;aý

        mov     eax,[ecx+8]     ;load u3
        FixMul  <[D ecx+12]>    ;multiplicate with v1
        mov     ebx,eax         ;save result
        mov     eax,[ecx]       ;load u1
        FixMul  <[D ecx+20]>    ;multiplicate with v3
        sub     ebx,eax         ;ok!
        mov     [esi+TPoly.Yn],ebx      ;save result
        mov     eax,ebx
        FixMul  ebx
        add     [ecx+24],eax    ;+bý

        mov     eax,[ecx]       ;load u1
        FixMul  <[D ecx+16]>    ;multiplicate with v2
        mov     ebx,eax         ;save result
        mov     eax,[ecx+4]     ;load u2
        FixMul  <[D ecx+12]>    ;multiplicate with v1
        sub     ebx,eax         ;ok!
        mov     [esi+TPoly.Zn],ebx      ;save result
        mov     eax,ebx
        FixMul  ebx
        add     eax,[ecx+24]    ;+cý
;WriteDecDWord eax
        call    SqrRoot         ;dý=SqrRoot(aý+bý+cý)
        mov     ebx,eax

;change normal vector into an unit vector
        mov     eax,[esi+TPoly.Xn]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TPoly.Xn],eax
;WriteDecDWord  eax

        mov     eax,[esi+TPoly.Yn]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TPoly.Yn],eax
;WriteDecDWord  eax

        mov     eax,[esi+TPoly.Zn]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TPoly.Zn],eax
;WriteLnDecDWord        eax

;calculate D ( Ax+By+Cz-D=0 ==> D=Ax+By+Cz )
        mov     ecx,[esi+TPoly.PE1]
        mov     eax,[esi+TPoly.Xn]
        FixMul  [ecx+TVertex.Xv]
        mov     ebx,eax         ;Ax
        mov     eax,[esi+TPoly.Yn]
        FixMul  [ecx+TVertex.Yv]
        add     ebx,eax         ;By
        mov     eax,[esi+TPoly.Zn]
        FixMul  [ecx+TVertex.Zv]
        add     ebx,eax         ;Zy
        mov     [esi+TPoly.Dn],ebx

        add     esi,TPolyLENGTH
        dec     bp
        jnz     @@1
        popad
        ret
ENDP

;############################################################################
PROC    CalcVertexNormals
;IN     eax=object number
;calculates the vertex-normals of an object
;############################################################################
        pushad
        shl     eax,5
        add     eax,[GPObjects]         ;addres of object

;clear vertex-normals
        xor     ebp,ebp
        mov     bp,[eax+TObject.NrVertices]
        mov     esi,[eax+TObject.PFirstVertex]
        push    esi
        push    ebp
        xor     ebx,ebx
@@1:    mov     [esi+TVertex.Xn],ebx
        mov     [esi+TVertex.Yn],ebx
        mov     [esi+TVertex.Zn],ebx
        mov     [esi+TVertex.Temp],bx
        add     esi,TVertexLENGTH
        dec     ebp
        jnz     @@1

;add poly-normals to vertex-normals
        xor     ebp,ebp
        mov     bp,[eax+TObject.NrPolys]
        mov     esi,[eax+TObject.PFirstPoly]
@@2:    mov     eax,[esi+TPoly.Xn]
        mov     ebx,[esi+TPoly.Yn]
        mov     ecx,[esi+TPoly.Zn]

        mov     edi,[esi+TPoly.PE1]
        add     [edi+TVertex.Xn],eax
        add     [edi+TVertex.Yn],ebx
        add     [edi+TVertex.Zn],ecx
        inc     [edi+TVertex.Temp]

        mov     edi,[esi+TPoly.PE2]
        add     [edi+TVertex.Xn],eax
        add     [edi+TVertex.Yn],ebx
        add     [edi+TVertex.Zn],ecx
        inc     [edi+TVertex.Temp]

        mov     edi,[esi+TPoly.PE3]
        add     [edi+TVertex.Xn],eax
        add     [edi+TVertex.Yn],ebx
        add     [edi+TVertex.Zn],ecx
        inc     [edi+TVertex.Temp]

        add     esi,TPolyLENGTH
        dec     ebp
        jnz     @@2

;divide vertex-normals by TVertex.Temp
        pop     [Count]
        pop     esi
@@3:    xor     edi,edi
        mov     di,[esi+TVertex.Temp]
        test    edi,edi
        jz      @@MysteriousVertex

        mov     eax,[esi+TVertex.Xn]
        cdq
        idiv    edi
        mov     ecx,eax
        FixMul  eax
        mov     ebx,eax

        mov     eax,[esi+TVertex.Yn]
        cdq
        idiv    edi
        mov     [Temp0],eax
        FixMul  eax
        add     ebx,eax

        mov     eax,[esi+TVertex.Zn]
        cdq
        idiv    edi
        mov     edi,eax
        FixMul  eax
        add     eax,ebx

        call    SqrRoot
        mov     ebp,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TVertex.Xn],eax

        mov     eax,[Temp0]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TVertex.Yn],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TVertex.Zn],eax

@@MysteriousVertex:
        add     esi,TVertexLENGTH
        dec     [Count]
        jnz     @@3

        popad
        ret
ENDP

;############################################################################
PROC    MarkSeenObjects
;sets the Seen-byte of an object should be drawn, otherwise clears it
;############################################################################
        pushad
        mov     esi,[GPObjects]
        mov     ecx,[GSeeingRange]
        mov     bp,[GNrObjects]
@@1:    mov     eax,[esi+TObject.Xo]
        sub     eax,[CameraXPos]
        imul    eax
        mov     ebx,edx
        mov     eax,[esi+TObject.Yo]
        sub     eax,[CameraYPos]
        imul    eax
        add     ebx,edx
        mov     eax,[esi+TObject.Zo]
        sub     eax,[CameraZPos]
        imul    eax
        add     ebx,edx
        cmp     ebx,ecx
        setbe   al
        and     al,[esi+TObject.Status]
        mov     [esi+TObject.Seen],al
        add     esi,TObjectLENGTH
        dec     bp
        jnz     @@1
        popad
        ret
ENDP

;############################################################################
PROC    PrepareScene
;sets the Seen-Bytes of the polygons and vertices that can be seen,
;transforms and projects
;############################################################################
        pushad

;***************************************
;copy timer-variables to work-variables
;***************************************
        cli
        mov     edx,[GPObjects]
        mov     bp,[GNrObjects]
@@copy:
        lea     esi,[edx+TObject.O11T]
        lea     edi,[edx+TObject.O11]
        mov     ecx,9+3
rep     movsd
        add     edx,TObjectLENGTH
        dec     bp
        jnz     @@copy
        mov     esi,O GCameraO11T
        mov     edi,O CameraO11
        mov     ecx,9+3
rep     movsd
        sti

;*************************************
;invert the camera orientation matrix
;*************************************
;calculate the determinant:
;detR=O11*(O22*O33-O23*O32)+O12*(O23*O31-O21*O33)+O13*(O21*O32-O22*O31)
        mov     eax,[CameraO33]
        mov     esi,eax         ;save O33 in esi
        FixMul  [CameraO22]
        mov     ecx,eax
        mov     eax,[CameraO23]
        mov     edi,eax         ;save O23 in edi
        FixMul  [CameraO32]
        sub     ecx,eax
        mov     [InvCameraO11],ecx
        mov     eax,[CameraO11]
        FixMul  ecx
        mov     ebp,eax

        mov     eax,edi         ;O23 is in edi
        FixMul  [CameraO31]
        mov     ecx,eax
        mov     eax,esi         ;O33 is in esi
        FixMul  [CameraO21]
        sub     ecx,eax
        mov     [InvCameraO21],ecx
        mov     eax,[CameraO12]
        FixMul  ecx
        sub     ebp,eax

        mov     eax,[CameraO32]
        FixMul  [CameraO21]
        mov     ecx,eax
        mov     eax,[CameraO22]
        FixMul  [CameraO31]
        sub     ecx,eax
        mov     [InvCameraO31],ecx
        mov     eax,[CameraO13]
        FixMul  ecx
        add     ebp,eax

;calculate the invert matrix
;InvO11=O22*O33-O23*O32
;part already calculated (determinant)
        mov     eax,[InvCameraO11]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [InvCameraO11],eax
;InvO12=-O12*O33+O13*O32
        mov     eax,[CameraO12]
        imul    [CameraO33]
        mov     esi,eax
        mov     edi,edx
        mov     eax,[CameraO13]
        imul    [CameraO32]
        sub     eax,esi
        sbb     edx,edi
        idiv    ebp
        mov     [InvCameraO12],eax
;InvO13=O12*O23-O13*O22
        mov     eax,[CameraO13]
        imul    [CameraO22]
        mov     esi,eax
        mov     edi,edx
        mov     eax,[CameraO12]
        imul    [CameraO23]
        sub     eax,esi
        sbb     edx,edi
        idiv    ebp
        mov     [InvCameraO13],eax
;InvO21=-O21*O33+O23*O31
;part already calculated (determinant)
        mov     eax,[InvCameraO21]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [InvCameraO21],eax
;InvO22=O11*O33-O13*O31
        mov     eax,[CameraO13]
        imul    [CameraO31]
        mov     esi,eax
        mov     edi,edx
        mov     eax,[CameraO11]
        imul    [CameraO33]
        sub     eax,esi
        sbb     edx,edi
        idiv    ebp
        mov     [InvCameraO22],eax
;InvO23=-O11*O23+O13*O21
        mov     eax,[CameraO11]
        imul    [CameraO23]
        mov     esi,eax
        mov     edi,edx
        mov     eax,[CameraO13]
        imul    [CameraO21]
        sub     eax,esi
        sbb     edx,edi
        idiv    ebp
        mov     [InvCameraO23],eax
;InvO31=O21*O32-O22*O31
;part already calculated (determinant)
        mov     eax,[InvCameraO31]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [InvCameraO31],eax
;InvO32=-O11*O32+O12*O31
        mov     eax,[CameraO11]
        imul    [CameraO32]
        mov     esi,eax
        mov     edi,edx
        mov     eax,[CameraO12]
        imul    [CameraO31]
        sub     eax,esi
        sbb     edx,edi
        idiv    ebp
        mov     [InvCameraO32],eax
;InvO33=O11*O22-O12*O21
        mov     eax,[CameraO12]
        imul    [CameraO21]
        mov     esi,eax
        mov     edi,edx
        mov     eax,[CameraO11]
        imul    [CameraO22]
        sub     eax,esi
        sbb     edx,edi
        idiv    ebp
        mov     [InvCameraO33],eax

;*************************************
;beginning of the big object loop :-)
;*************************************
        mov     esi,[GPObjects]
        mov     bp,[GNrObjects]
        mov     [W Count2],bp
@@a1:   cmp     [esi+TObject.Seen],0    ;can the object be seen?
        jz      @@ObjectCannotBeSeen

;*************************************
;invert the object orientation matrix
;*************************************
;calculate the determinant:
;detR=O11*(O22*O33-O23*O32)-O12*(O21*O33-O23*O31)+O13*(O21*O32-O22*O31)
        mov     eax,[esi+TObject.O33]
        mov     ebx,eax         ;save O33 in ebx
        FixMul  [esi+TObject.O22]
        mov     ecx,eax
        mov     eax,[esi+TObject.O23]
        mov     edi,eax         ;save O23 in edi
        FixMul  [esi+TObject.O32]
        sub     ecx,eax
        mov     eax,[esi+TObject.O11]
        FixMul  ecx
        mov     ebp,eax

        mov     eax,ebx         ;O33 is in ebx
        FixMul  [esi+TObject.O21]
        mov     ecx,eax
        mov     eax,edi         ;O23 is in edi
        FixMul  [esi+TObject.O31]
        sub     ecx,eax
        mov     eax,[esi+TObject.O12]
        FixMul  ecx
        sub     ebp,eax

        mov     eax,[esi+TObject.O32]
        FixMul  [esi+TObject.O21]
        mov     ecx,eax
        mov     eax,[esi+TObject.O22]
        FixMul  [esi+TObject.O31]
        sub     ecx,eax
        mov     eax,[esi+TObject.O13]
        FixMul  ecx
        add     ebp,eax

;calculate the invert matrix
;InvO11=O22*O33-O23*O32
        mov     eax,[esi+TObject.O23]
        imul    [esi+TObject.O32]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O22]
        imul    [esi+TObject.O33]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO11],eax
;InvO12=-O12*O33+O13*O32
        mov     eax,[esi+TObject.O12]
        imul    [esi+TObject.O33]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O13]
        imul    [esi+TObject.O32]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO12],eax
;InvO13=O12*O23-O13*O22
        mov     eax,[esi+TObject.O13]
        imul    [esi+TObject.O22]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O12]
        imul    [esi+TObject.O23]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO13],eax
;InvO21=-O21*O33+O23*O31
        mov     eax,[esi+TObject.O21]
        imul    [esi+TObject.O33]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O23]
        imul    [esi+TObject.O31]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO21],eax
;InvO22=O11*O33-O13*O31
        mov     eax,[esi+TObject.O13]
        imul    [esi+TObject.O31]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O11]
        imul    [esi+TObject.O33]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO22],eax
;InvO23=-O11*O23+O13*O21
        mov     eax,[esi+TObject.O11]
        imul    [esi+TObject.O23]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O13]
        imul    [esi+TObject.O21]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO23],eax
;InvO31=O21*O32-O22*O31
        mov     eax,[esi+TObject.O22]
        imul    [esi+TObject.O31]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O21]
        imul    [esi+TObject.O32]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO31],eax
;InvO32=-O11*O32+O12*O31
        mov     eax,[esi+TObject.O11]
        imul    [esi+TObject.O32]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O12]
        imul    [esi+TObject.O31]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO32],eax
;InvO33=O11*O22-O12*O21
        mov     eax,[esi+TObject.O12]
        imul    [esi+TObject.O21]
        mov     ebx,eax
        mov     edi,edx
        mov     eax,[esi+TObject.O11]
        imul    [esi+TObject.O22]
        sub     eax,ebx
        sbb     edx,edi
        idiv    ebp
        mov     [InvObjectO33],eax

;************************************************
;transform the camera position into object space
;************************************************
;translate the camera K'=K-O
        mov     eax,[CameraXPos]
        sub     eax,[esi+TObject.Xo]
        mov     ecx,eax
        mov     eax,[CameraYPos]
        sub     eax,[esi+TObject.Yo]
        mov     edi,eax
        mov     eax,[CameraZPos]
        sub     eax,[esi+TObject.Zo]
        mov     ebp,eax

;rotate camera position
        mov     eax,[InvObjectO11]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO12]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO13]
        FixMul  ebp
        add     ebx,eax
        mov     [Temp0],ebx

        mov     eax,[InvObjectO21]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO22]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO23]
        FixMul  ebp
        add     ebx,eax
        mov     [Temp1],ebx

        mov     eax,[InvObjectO31]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO32]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO33]
        FixMul  ebp
        add     ebx,eax
        mov     [Temp2],ebx

;******************************************
;transform camera vector into object space
;******************************************
        mov     ecx,[CameraO13]
        mov     edi,[CameraO23]
        mov     ebp,[CameraO33]

;rotate camera vector
        mov     eax,[InvObjectO11]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO12]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO13]
        FixMul  ebp
        add     ebx,eax
        mov     [Temp3],ebx

        mov     eax,[InvObjectO21]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO22]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO23]
        FixMul  ebp
        add     ebx,eax
        mov     [Temp4],ebx

        mov     eax,[InvObjectO31]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO32]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO33]
        FixMul  ebp
        add     ebx,eax
        mov     [Temp5],ebx

;D=Ax+By+Cz
        mov     eax,[Temp0]
        FixMul  [Temp3]
        mov     ebx,eax
        mov     eax,[Temp1]
        FixMul  [Temp4]
        add     ebx,eax
        mov     eax,[Temp2]
        FixMul  [Temp5]
        add     ebx,eax
        add     ebx,16384       ;plane is 0.25 before the camera
        mov     [Temp6],ebx

;******************************
;check vertices for visibility
;******************************
        mov     ebx,[esi+TObject.PFirstVertex]
        mov     cx,[esi+TObject.NrVertices]
        mov     [W Count],cx
@@a2:   mov     eax,[Temp3]
        FixMul  [ebx+TVertex.Xv]
        mov     ebp,eax
        mov     eax,[Temp4]
        FixMul  [ebx+TVertex.Yv]
        add     ebp,eax
        mov     eax,[Temp5]
        FixMul  [ebx+TVertex.Zv]
        add     ebp,eax
        cmp     ebp,[Temp6]
        setge   al
        mov     [ebx+TVertex.Seen],1;al
        add     ebx,TVertexLENGTH
        dec     [W Count]
        jnz     @@a2

;******************************
;check polygons for visibility
;******************************
        mov     ebx,[esi+TObject.PFirstPoly]
        mov     cx,[esi+TObject.NrPolys]
        mov     [W Count],cx
        push    esi
@@b2:
;check if all three edge-vertices have their seen byte set to 1
        xor     al,al
        mov     esi,[ebx+TPoly.PE1]
        cmp     [esi+TVertex.Seen],0
        jz      @@b3
        mov     esi,[ebx+TPoly.PE2]
        cmp     [esi+TVertex.Seen],0
        jz      @@b3
        mov     esi,[ebx+TPoly.PE3]
        cmp     [esi+TVertex.Seen],0
        jz      @@b3
;check if poly shows the right side to the camera
        mov     eax,[ebx+TPoly.Xn]
        FixMul  [Temp0] ;A*x
        mov     ebp,eax
        mov     eax,[ebx+TPoly.Yn]
        FixMul  [Temp1] ;B*y
        add     ebp,eax
        mov     eax,[ebx+TPoly.Zn]
        FixMul  [Temp2] ;C*z
        add     ebp,eax
        cmp     ebp,[ebx+TPoly.Dn]
        setge   al
;yahoo, the poly can be seen!
@@b3:   mov     [ebx+TPoly.Seen],al
        add     ebx,TPolyLENGTH
        dec     [W Count]
        jnz     @@b2
@@b4:   pop     esi

;*****************************************
;transform light vector into object space
;*****************************************
        mov     ecx,[GLightVectorX]
        mov     edi,[GLightVectorY]
        mov     ebp,[GLightVectorZ]

;rotate light vector
        mov     eax,[InvObjectO11]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO12]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO13]
        FixMul  ebp
        add     ebx,eax
        mov     [LightVectorXObj],ebx

        mov     eax,[InvObjectO21]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO22]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO23]
        FixMul  ebp
        add     ebx,eax
        mov     [LightVectorYObj],ebx

        mov     eax,[InvObjectO31]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[InvObjectO32]
        FixMul  edi
        add     ebx,eax
        mov     eax,[InvObjectO33]
        FixMul  ebp
        add     ebx,eax
        mov     [LightVectorZObj],ebx

;*********************************************************
;calculate light intensity and/or env mapping coordinates
;for every vertex that can be seen
;*********************************************************
        cli
        mov     [Temp0],esp

;calculate (Ox1*Ox2) to speed up transformation into world space
        mov     eax,[esi+TObject.O11]
        FixMul  [esi+TObject.O12]
        mov     [O11xO12],eax
        mov     eax,[esi+TObject.O21]
        FixMul  [esi+TObject.O22]
        mov     [O21xO22],eax

        mov     ebx,[esi+TObject.PFirstVertex]
        mov     cx,[esi+TObject.NrVertices]
        mov     [W Count],cx
@@l1:
        cmp     [ebx+TVertex.Seen],0
        jz      @@NextVertex
        test    [ebx+TVertex.Attr],3
        jz      @@NextVertex
        test    [ebx+TVertex.Attr],1
        jz      @@EnvMappingCoords
;calculate light intensity
        mov     eax,[ebx+TVertex.Xn]
        FixMul  [LightVectorXObj]
        mov     ecx,eax
        mov     eax,[ebx+TVertex.Yn]
        FixMul  [LightVectorYObj]
        add     ecx,eax
        mov     eax,[ebx+TVertex.Zn]
        FixMul  [LightVectorZObj]
        add     ecx,eax
        mov     al,0
        jns     @@l2
        neg     ecx
        mov     al,ch
        cmp     ecx,65536
        jb      @@l2
        mov     al,255
@@l2:   shr     al,1
        add     al,128
        mov     [ebx+TVertex.Light],al
        test    [ebx+TVertex.Attr],2
        jz      @@NextVertex

;calculate environment mapping coordinates
@@EnvMappingCoords:
;C'=-(2N(C*N)-C)
        mov     ecx,[ebx+TVertex.Xn]
        mov     esp,[ebx+TVertex.Yn]
        mov     edi,[ebx+TVertex.Zn]
;(C*N)
        mov     eax,ecx
        FixMul  [Temp3]
        mov     ebp,eax
        mov     eax,esp
        FixMul  [Temp4]
        add     ebp,eax
        mov     eax,edi
        FixMul  [Temp5]
        add     ebp,eax
;2N(C*N)
        mov     eax,ecx
        imul    ebp
        shrd    eax,edx,15      ;!!! only 15 'coz of the multiplication by 2
        mov     ecx,eax
        mov     eax,esp
        imul    ebp
        shrd    eax,edx,15      ;!!! only 15 'coz of the multiplication by 2
        mov     esp,eax
        mov     eax,edi
        imul    ebp
        shrd    eax,edx,15      ;!!! only 15 'coz of the multiplication by 2
        mov     edi,eax
;-(2N(C*N)-C)
        sub     ecx,[Temp3]
        sub     esp,[Temp4]
        sub     edi,[Temp5]
        neg     ecx
        neg     esp
        neg     edi

;transform vector into world space
;calculate X*Y to speed up the calculations
        mov     eax,ecx
        FixMul  esp
        mov     [Temp1],eax
;transform
        mov     eax,[esi+TObject.O13]
        FixMul  edi
        mov     ebp,eax
        mov     eax,[esi+TObject.O11]
        add     eax,esp
        mov     edx,[esi+TObject.O12]
        add     edx,ecx
        FixMul  edx
        sub     eax,[Temp1]     ;-X*Y
        DB      2dh             ;sub eax,O11xO12
O11xO12 DD      ?
        add     eax,ebp

        sar     eax,7
        add     eax,512+64
        DB      8ah,80h         ;mov al,[eax+PArcSinModify1]
PArcSinModify1  DD      ?
        mov     [ebx+TVertex.Xe],al

        mov     eax,[esi+TObject.O23]
        FixMul  edi
        mov     ebp,eax
        mov     eax,[esi+TObject.O21]
        add     eax,esp
        mov     edx,[esi+TObject.O22]
        add     edx,ecx
        FixMul  edx
        sub     eax,[Temp1]     ;-X*Y
        DB      2dh             ;sub eax,O21xO22
O21xO22 DD      ?
        add     eax,ebp

        sar     eax,7
        add     eax,512+64
        DB      8ah,80h         ;mov al,[eax+PArcSinModify2]
PArcSinModify2  DD      ?
        mov     [ebx+TVertex.Ye],al


@@NextVertex:
        add     ebx,TVertexLENGTH
        dec     [W Count]
        jnz     @@l1

        mov     esp,[Temp0]
        sti

;*******************************************
;transform and project the visible vertices
;*******************************************
;calculate translation vector
        mov     eax,[esi+TObject.Xo]
        mov     ebx,[esi+TObject.Yo]
        mov     ecx,[esi+TObject.Zo]
        sub     eax,[CameraXPos]
        sub     ebx,[CameraYPos]
        sub     ecx,[CameraZPos]
        mov     [Temp0],eax
        mov     [Temp1],ebx
        mov     [Temp2],ecx
;A=rc1*ro1+rc2*ro4+rc3*ro7
        mov     eax,[InvCameraO11]
        FixMul  [esi+TObject.O11]
        mov     ebx,eax
        mov     eax,[InvCameraO12]
        FixMul  [esi+TObject.O21]
        add     ebx,eax
        mov     eax,[InvCameraO13]
        FixMul  [esi+TObject.O31]
        add     eax,ebx
        mov     [_A],eax
;B=rc1*ro2+rc2*ro5+rc3*ro8
        mov     eax,[InvCameraO11]
        FixMul  [esi+TObject.O12]
        mov     ebx,eax
        mov     eax,[InvCameraO12]
        FixMul  [esi+TObject.O22]>
        add     ebx,eax
        mov     eax,[InvCameraO13]
        FixMul  [esi+TObject.O32]
        add     eax,ebx
        mov     [_B],eax
;C=rc1*ro3+rc2*ro6+rc3*ro9
        mov     eax,[InvCameraO11]
        FixMul  [esi+TObject.O13]
        mov     ebx,eax
        mov     eax,[InvCameraO12]
        FixMul  [esi+TObject.O23]
        add     ebx,eax
        mov     eax,[InvCameraO13]
        FixMul  [esi+TObject.O33]
        add     eax,ebx
        mov     [_C],eax
;D=rc1*t1+rc2*t2+rc3*t3-A*B
        mov     eax,[InvCameraO11]
        FixMul  [Temp0]
        mov     ebx,eax
        mov     eax,[InvCameraO12]
        FixMul  [Temp1]
        add     ebx,eax
        mov     eax,[InvCameraO13]
        FixMul  [Temp2]
        add     ebx,eax
        mov     eax,[_A]
        FixMul  [_B]
        neg     eax
        add     eax,ebx
        mov     [_D],eax
;E=rc4*ro1+rc5*ro4+rc6*ro7
        mov     eax,[InvCameraO21]
        FixMul  [esi+TObject.O11]
        mov     ebx,eax
        mov     eax,[InvCameraO22]
        FixMul  [esi+TObject.O21]
        add     ebx,eax
        mov     eax,[InvCameraO23]
        FixMul  [esi+TObject.O31]
        add     eax,ebx
        mov     [_E],eax
;F=rc4*ro2+rc5*ro5+rc6*ro8
        mov     eax,[InvCameraO21]
        FixMul  [esi+TObject.O12]
        mov     ebx,eax
        mov     eax,[InvCameraO22]
        FixMul  [esi+TObject.O22]
        add     ebx,eax
        mov     eax,[InvCameraO23]
        FixMul  [esi+TObject.O32]
        add     eax,ebx
        mov     [_F],eax
;G=rc4*ro3+rc5*ro6+rc6*ro9
        mov     eax,[InvCameraO21]
        FixMul  [esi+TObject.O13]
        mov     ebx,eax
        mov     eax,[InvCameraO22]
        FixMul  [esi+TObject.O23]
        add     ebx,eax
        mov     eax,[InvCameraO23]
        FixMul  [esi+TObject.O33]
        add     eax,ebx
        mov     [_G],eax
;H=rc4*t1+rc5*t2+rc6*t3-E*F
        mov     eax,[InvCameraO21]
        FixMul  [Temp0]
        mov     ebx,eax
        mov     eax,[InvCameraO22]
        FixMul  [Temp1]
        add     ebx,eax
        mov     eax,[InvCameraO23]
        FixMul  [Temp2]
        add     ebx,eax
        mov     eax,[_E]
        FixMul  [_F]
        neg     eax
        add     eax,ebx
        mov     [_H],eax
;I=rc7*ro1+rc8*ro4+rc9*ro7
        mov     eax,[InvCameraO31]
        FixMul  [esi+TObject.O11]
        mov     ebx,eax
        mov     eax,[InvCameraO32]
        FixMul  [esi+TObject.O21]
        add     ebx,eax
        mov     eax,[InvCameraO33]
        FixMul  [esi+TObject.O31]
        add     eax,ebx
        mov     [_I],eax
;J=rc7*ro2+rc8*ro5+rc9*ro8
        mov     eax,[InvCameraO31]
        FixMul  [esi+TObject.O12]
        mov     ebx,eax
        mov     eax,[InvCameraO32]
        FixMul  [esi+TObject.O22]
        add     ebx,eax
        mov     eax,[InvCameraO33]
        FixMul  [esi+TObject.O32]
        add     eax,ebx
        mov     [_J],eax
;K=rc7*ro3+rc8*ro6+rc9*ro9
        mov     eax,[InvCameraO31]
        FixMul  [esi+TObject.O13]
        mov     ebx,eax
        mov     eax,[InvCameraO32]
        FixMul  [esi+TObject.O23]
        add     ebx,eax
        mov     eax,[InvCameraO33]
        FixMul  [esi+TObject.O33]>
        add     eax,ebx
        mov     [_K],eax
;L=rc7*t1+rc8*t2+rc9*t3-I*J
        mov     eax,[InvCameraO31]
        FixMul  [Temp0]
        mov     ebx,eax
        mov     eax,[InvCameraO32]
        FixMul  [Temp1]
        add     ebx,eax
        mov     eax,[InvCameraO33]
        FixMul  [Temp2]
        add     ebx,eax
        mov     eax,[_I]
        FixMul  [_J]
        neg     eax
        add     eax,ebx
        mov     [_L],eax

        mov     ebx,[esi+TObject.PFirstVertex]
        mov     cx,[esi+TObject.NrVertices]
        mov     [W Count],cx
        push    esi
@@c2:   cmp     [ebx+TVertex.Seen],0
        jz      @@c3
;calculate x*y and save into ebp
        mov     eax,[ebx+TVertex.Xv]
        FixMul  [ebx+TVertex.Yv]
        mov     ebp,eax         ;ebp=x*y
;calculate z-distance from camera to vertex
;z'=(x+J)*(y+I)-T+L+z*K
        mov     eax,[ebx+TVertex.Xv]
        add     eax,[_J]
        mov     edx,[ebx+TVertex.Yv]
        add     edx,[_I]
        FixMul  edx             ;(x+J)*(y+I)
        sub     eax,ebp         ;-T
        add     eax,[_L]        ;+L
        mov     esi,eax         ;save eax
        mov     eax,[ebx+TVertex.Zv]
        FixMul  [_K]
        add     eax,esi
        mov     [ebx+TVertex.CamDist],eax
;x'=(x+B)*(y+A)-T+D+z*C
        mov     eax,[ebx+TVertex.Xv]
        add     eax,[_B]
        mov     edx,[ebx+TVertex.Yv]
        add     edx,[_A]
        FixMul  edx             ;(x+B)*(y+A)
        sub     eax,ebp         ;-T
        add     eax,[_D]        ;+D
        mov     esi,eax         ;save eax
        mov     eax,[ebx+TVertex.Zv]
        FixMul  [_C]
        add     eax,esi
;project x-coordinate
        imul    [GXEyeDist]
        idiv    [ebx+TVertex.CamDist]
        add     ax,[GXMiddle]
        mov     [ebx+TVertex.Xs],ax
;y'=(x+F)*(y+E)-T+H+z*G
        mov     eax,[ebx+TVertex.Xv]
        add     eax,[_F]
        mov     edx,[ebx+TVertex.Yv]
        add     edx,[_E]
        FixMul  edx             ;(x+F)*(y+E)
        sub     eax,ebp         ;-T
        add     eax,[_H]        ;+H
        mov     esi,eax         ;save eax
        mov     eax,[ebx+TVertex.Zv]
        FixMul  [_G]
        add     eax,esi
;project y-coordinate
        imul    [GYEyeDist]
        idiv    [ebx+TVertex.CamDist]
        add     ax,[GYMiddle]
        mov     [ebx+TVertex.Ys],ax

@@c3:   add     ebx,TVertexLENGTH
        dec     [W Count]
        jnz     @@c2
        pop     esi
@@ObjectCannotBeSeen:
        add     esi,TObjectLENGTH
        dec     [W Count2]
        jnz     @@a1

        popad
        ret
ENDP

;############################################################################
PROC    SortPolys
;sorts the polygons
;############################################################################
        pushad

;*********************
;init the sort buffer
;*********************
        mov     esi,[GPObjects]
        xor     eax,eax
        mov     ax,[GNrObjects]
        mov     [Count],eax
        mov     edx,[PSortMainBuffer]
        xor     ebp,ebp                 ;number of items in the buffer
@@a1:   cmp     [esi+TObject.Seen],0    ;can the object be seen?
        jz      @@a4
        mov     edi,[esi+TObject.PFirstPoly]
        xor     ecx,ecx
        mov     cx,[esi+TObject.NrPolys]
@@a2:   cmp     [edi+TPoly.Seen],0
        jz      @@a3
        mov     ebx,[edi+TPoly.PE1]
        mov     eax,[ebx+TVertex.CamDist]
        mov     ebx,[edi+TPoly.PE2]
        add     eax,[ebx+TVertex.CamDist]
        mov     ebx,[edi+TPoly.PE3]
        add     eax,[ebx+TVertex.CamDist]
        mov     [edx],eax       ;save the distance to the camera
        mov     [edx+4],edi     ;save the address of the poly
        inc     ebp
        add     edx,8
@@a3:   add     edi,TPolyLENGTH
        dec     ecx
        jnz     @@a2
@@a4:   add     esi,TObjectLENGTH
        dec     [Count]
        jnz     @@a1
        mov     [NumberOfItems],ebp
        test    ebp,ebp
        jz      @@end

;*********************************************
;fill the index-variables with correct values
;*********************************************
        mov     ecx,16
        mov     edi,O SortIndices
        mov     esi,[PSortHelpBuffers]
@@b1:   mov     [edi],esi
        add     edi,4
        add     esi,MAXPOLYS*8
        dec     ecx
        jnz     @@b1

;****************
;sort the buffer
;****************
        mov     [Count],8       ;with this two values you can
        mov     cl,0            ;control the speed of the routine
@@c1:
        mov     ebp,[NumberOfItems]
        mov     esi,[PSortMainBuffer]
@@c2:
        mov     eax,[esi]
        mov     edi,eax
        shr     edi,cl
        not     edi
        and     edi,15
        mov     ebx,[SortIndices+edi*4]
        mov     [ebx],eax
        mov     eax,[esi+4]
        mov     [ebx+4],eax
        add     ebx,8
        mov     [D SortIndices+edi*4],ebx
        add     esi,8
        dec     ebp
        jnz     @@c2

        push    es
        push    ds
        pop     es
        mov     ch,16
        mov     ebx,[PSortHelpBuffers]
        mov     edx,O SortIndices
        mov     edi,[PSortMainBuffer]
@@c3:   push    ecx
        mov     ecx,[edx]
        sub     ecx,ebx         ;how many bytes to copy?
        mov     [edx],ebx
        shr     ecx,2
        mov     esi,ebx
rep     movsd
        pop     ecx
        add     ebx,MAXPOLYS*8
        add     edx,4
        dec     ch
        jnz     @@c3
        pop     es

        add     cl,4
        dec     [Count]
        jnz     @@c1

@@end:
        popad
        ret
ENDP

;############################################################################
PROC    DrawScene
;draws the szene to a buffer
;############################################################################
        pushad
        mov     ebp,[NumberOfItems]
        test    ebp,ebp
        jz      @@end
        mov     edi,[PSortMainBuffer]
        add     edi,4           ;poly address needed
        xor     ebx,ebx
@@1:    mov     esi,[edi]
        mov     bl,[esi+TPoly.Attr]
        call    [CallTable+ebx*4]
        add     edi,8
        dec     ebp
        jnz     @@1
@@end:
        popad
        ret
ENDP

ALIGN 4

CallTable DD    O DrawSolidPoly         ;0
        DD      O DrawGouroudPoly       ;1
        DD      O DrawTexturedPoly      ;2
        DD      O DrawEnvMappedPoly     ;3

Temp0   DD      ?       ;some temporary vars for undefined use
Temp1   DD      ?
Temp2   DD      ?
Temp3   DD      ?
Temp4   DD      ?
Temp5   DD      ?
Temp6   DD      ?
Temp7   DD      ?
Temp8   DD      ?
Count   DD      ?
Count2  DD      ?

_A      DD      ?
_B      DD      ?
_C      DD      ?
_D      DD      ?
_E      DD      ?
_F      DD      ?
_G      DD      ?
_H      DD      ?
_I      DD      ?
_J      DD      ?
_K      DD      ?
_L      DD      ?

GSeeingRange DD 5000*5000 ;The maximal distance to an object that is displayed.
                        ;This value has to be the quadrat of the real number.
                        ;This has NOT to be a fixed point number!

GPObjects       DD      ?       ;pointer to objects
GPSinTable      DD      ?       ;begin of the 1024-item sinus table (16.16)
                                ;used also for cosinus
;modificated by the timer
GCameraO11T     DD      65536 ;camera orientation matrix
GCameraO12T     DD      0
GCameraO13T     DD      0
GCameraO21T     DD      0
GCameraO22T     DD      65536
GCameraO23T     DD      0
GCameraO31T     DD      0
GCameraO32T     DD      0
GCameraO33T     DD      65536
GCameraXPosT    DD      0       ;x-position of the camera
GCameraYPosT    DD      0       ;y-position of the camera
GCameraZPosT    DD      0       ;z-position of the camera

;used for calculations
CameraO11       DD      ?       ;camera orientation matrix
CameraO12       DD      ?
CameraO13       DD      ?
CameraO21       DD      ?
CameraO22       DD      ?
CameraO23       DD      ?
CameraO31       DD      ?
CameraO32       DD      ?
CameraO33       DD      ?
CameraXPos      DD      ?       ;x-position of the camera
CameraYPos      DD      ?       ;y-position of the camera
CameraZPos      DD      ?       ;z-position of the camera

InvCameraO11    DD      ?       ;invert camera orientation matrix
InvCameraO12    DD      ?
InvCameraO13    DD      ?
InvCameraO21    DD      ?
InvCameraO22    DD      ?
InvCameraO23    DD      ?
InvCameraO31    DD      ?
InvCameraO32    DD      ?
InvCameraO33    DD      ?

InvObjectO11    DD      ?       ;invert object orientation matrix
InvObjectO12    DD      ?
InvObjectO13    DD      ?
InvObjectO21    DD      ?
InvObjectO22    DD      ?
InvObjectO23    DD      ?
InvObjectO31    DD      ?
InvObjectO32    DD      ?
InvObjectO33    DD      ?

GXEyeDist       DD      ?       ;factor to be multiplicated with x before projection
GYEyeDist       DD      ?       ;factor to be multiplicated with y before projection

GLightVectorX   DD      -22415  ;light vector used for gouroud shading
GLightVectorY   DD      0
GLightVectorZ   DD      61584

LightVectorXObj DD      ?       ;light vector in object space used for gouroud
LightVectorYObj DD      ?       ;shading
LightVectorZObj DD      ?

NumberOfItems   DD      ?       ;number of items in the sort buffer
PSortMainBuffer DD      ?       ;pointer to the main sort buffer
PSortHelpBuffers DD     ?       ;pointer to begin of the 16 help buffers
PArcSinTable    DD      ?       ;pointer to arcus sinus table
SortIndices     DD      16 DUP (?)
GXMiddle        DW      ?       ;x-coordinate added when projecting a vertex
GYMiddle        DW      ?       ;y-coordinate added when projecting a vertex
GNrObjects      DW      ?
ENDS

END