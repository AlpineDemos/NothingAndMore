;the transformation-routines of the ALPINE 3D-Engine
;written in spring and summer 1997 by Ziron
IDEAL
P386
ASSUME  cs:code32,ds:code32

SEGMENT code32  PARA PUBLIC USE32
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
INCLUDE 'decl.inc'
INCLUDE '3dtransf.inc'
INCLUDE '3dmain.inc'

;############################################################################
PROC    RotateObjectInWorldSpace
;IN     eax=object number, ebx=X-angle, ecx=Y-angle ,edx=Z-angle
;rotates object in object space about the three angles
;angle numbers can be 0-4095, all other are AND'ed
;############################################################################
        pushad
        push    edx
        push    ecx
        shl     eax,5
        add     eax,[GPObjects]         ;addres of object
        mov     esi,eax

;********************
;rotate along x-axis
;********************
;fetch sinus and cosinus values
        and     ebx,4095
        jz      @@zeroX
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the X-rotation matrix with the orientation matrix
        mov     eax,[esi+TObject.O21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[esi+TObject.O22T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O32T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[esi+TObject.O23T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O33T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O23T

        mov     eax,[esi+TObject.O31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[esi+TObject.O32T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O22T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O32T

        mov     eax,[esi+TObject.O33T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O23T]
        FixMul  edi
        sub     ebx,eax

        mov     [esi+TObject.O33T],ebx
        pop     eax
        mov     [esi+TObject.O32T],eax
        pop     eax
        mov     [esi+TObject.O31T],eax
        pop     eax
        mov     [esi+TObject.O23T],eax
        pop     eax
        mov     [esi+TObject.O22T],eax
        pop     eax
        mov     [esi+TObject.O21T],eax
@@zeroX:

;********************
;rotate along y-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroY
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Y-rotation matrix with the orientation matrix
        mov     eax,[esi+TObject.O11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[esi+TObject.O12T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O32T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[esi+TObject.O13T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O33T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[esi+TObject.O31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O11T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[esi+TObject.O32T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O12T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O32T

        mov     eax,[esi+TObject.O33T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O13T]
        FixMul  edi
        sub     ebx,eax

        mov     [esi+TObject.O33T],ebx
        pop     eax
        mov     [esi+TObject.O32T],eax
        pop     eax
        mov     [esi+TObject.O31T],eax
        pop     eax
        mov     [esi+TObject.O13T],eax
        pop     eax
        mov     [esi+TObject.O12T],eax
        pop     eax
        mov     [esi+TObject.O11T],eax
@@zeroY:

;********************
;rotate along z-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroZ
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Z-rotation matrix with the orientation matrix
        mov     eax,[esi+TObject.O11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[esi+TObject.O12T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O22T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[esi+TObject.O13T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O23T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[esi+TObject.O21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O11T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[esi+TObject.O22T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O12T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[esi+TObject.O23T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O13T]
        FixMul  edi
        sub     ebx,eax

        mov     [esi+TObject.O23T],ebx
        pop     eax
        mov     [esi+TObject.O22T],eax
        pop     eax
        mov     [esi+TObject.O21T],eax
        pop     eax
        mov     [esi+TObject.O13T],eax
        pop     eax
        mov     [esi+TObject.O12T],eax
        pop     eax
        mov     [esi+TObject.O11T],eax
@@zeroZ:

;**************************************
;orthonormalize the orientation matrix
;**************************************
;o1=b1/|b1|
        mov     eax,[esi+TObject.O11T]
        FixMul  eax
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  eax
        add     ebx,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebp,eax

        mov     eax,[esi+TObject.O11T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TObject.O11T],eax

        mov     eax,[esi+TObject.O21T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TObject.O21T],eax

        mov     eax,[esi+TObject.O31T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TObject.O31T],eax

;v2=b2-(b2*o1)*o1
        mov     eax,[esi+TObject.O11T]
        mov     ecx,[esi+TObject.O12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        mov     edi,[esi+TObject.O22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[esi+TObject.O31T]
        mov     ebp,[esi+TObject.O32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[esi+TObject.O11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  ebx
        sub     ebp,eax

;o2=v2/|v2|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O12T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O22T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O32T],eax

;v3=b3-(b3*o1)*o1-(b3*o2)*o2
        mov     eax,[esi+TObject.O11T]
        mov     ecx,[esi+TObject.O13T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        mov     edi,[esi+TObject.O23T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[esi+TObject.O31T]
        mov     ebp,[esi+TObject.O33T]
        FixMul  ebp
        add     ebx,eax
        push    ebx

        mov     eax,[esi+TObject.O12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[esi+TObject.O22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[esi+TObject.O32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[esi+TObject.O11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  ebx
        sub     ebp,eax

        pop     ebx
        mov     eax,[esi+TObject.O11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  ebx
        sub     ebp,eax

;o3=v3/|v3|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O13T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O23T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O33T],eax

        popad
        ret
ENDP

;############################################################################
PROC    RotateObjectInObjectSpace
;IN     eax=object number, ebx=X-angle, ecx=Y-angle ,edx=Z-angle
;rotates object in object space about the three angles
;angle numbers can be 0-4095, all other are AND'ed
;############################################################################
        pushad
        push    edx
        push    ecx
        shl     eax,5
        add     eax,[GPObjects]         ;addres of object
        mov     esi,eax

;********************
;rotate along x-axis
;********************
;fetch sinus and cosinus values
        and     ebx,4095
        jz      @@zeroX
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the X-rotation matrix with the orientation matrix
        mov     eax,[esi+TObject.O12T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O13T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[esi+TObject.O22T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O23T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[esi+TObject.O32T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O33T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O32T

        mov     eax,[esi+TObject.O12T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O13T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[esi+TObject.O22T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O23T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O23T

        mov     eax,[esi+TObject.O32T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O33T]
        FixMul  ebp
        add     ebx,eax

        mov     [esi+TObject.O33T],ebx
        pop     eax
        mov     [esi+TObject.O23T],eax
        pop     eax
        mov     [esi+TObject.O13T],eax
        pop     eax
        mov     [esi+TObject.O32T],eax
        pop     eax
        mov     [esi+TObject.O22T],eax
        pop     eax
        mov     [esi+TObject.O12T],eax
@@zeroX:

;********************
;rotate along y-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroY
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Y-rotation matrix with the orientation matrix
        mov     eax,[esi+TObject.O11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O13T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[esi+TObject.O21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O23T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[esi+TObject.O31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O33T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[esi+TObject.O11T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O13T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[esi+TObject.O21T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O23T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O23T

        mov     eax,[esi+TObject.O31T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O33T]
        FixMul  ebp
        add     ebx,eax

        mov     [esi+TObject.O33T],ebx
        pop     eax
        mov     [esi+TObject.O23T],eax
        pop     eax
        mov     [esi+TObject.O13T],eax
        pop     eax
        mov     [esi+TObject.O31T],eax
        pop     eax
        mov     [esi+TObject.O21T],eax
        pop     eax
        mov     [esi+TObject.O11T],eax
@@zeroY:

;********************
;rotate along z-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroZ
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Z-rotation matrix with the orientation matrix
        mov     eax,[esi+TObject.O11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O12T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[esi+TObject.O21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O22T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[esi+TObject.O31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[esi+TObject.O32T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[esi+TObject.O11T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O12T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[esi+TObject.O21T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O22T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[esi+TObject.O31T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[esi+TObject.O32T]
        FixMul  ebp
        add     ebx,eax

        mov     [esi+TObject.O32T],ebx
        pop     eax
        mov     [esi+TObject.O22T],eax
        pop     eax
        mov     [esi+TObject.O12T],eax
        pop     eax
        mov     [esi+TObject.O31T],eax
        pop     eax
        mov     [esi+TObject.O21T],eax
        pop     eax
        mov     [esi+TObject.O11T],eax
@@zeroZ:

;**************************************
;orthonormalize the orientation matrix
;**************************************
;o1=b1/|b1|
        mov     eax,[esi+TObject.O11T]
        FixMul  eax
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  eax
        add     ebx,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebp,eax

        mov     eax,[esi+TObject.O11T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TObject.O11T],eax

        mov     eax,[esi+TObject.O21T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TObject.O21T],eax

        mov     eax,[esi+TObject.O31T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [esi+TObject.O31T],eax

;v2=b2-(b2*o1)*o1
        mov     eax,[esi+TObject.O11T]
        mov     ecx,[esi+TObject.O12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        mov     edi,[esi+TObject.O22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[esi+TObject.O31T]
        mov     ebp,[esi+TObject.O32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[esi+TObject.O11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  ebx
        sub     ebp,eax

;o2=v2/|v2|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O12T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O22T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O32T],eax

;v3=b3-(b3*o1)*o1-(b3*o2)*o2
        mov     eax,[esi+TObject.O11T]
        mov     ecx,[esi+TObject.O13T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[esi+TObject.O21T]
        mov     edi,[esi+TObject.O23T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[esi+TObject.O31T]
        mov     ebp,[esi+TObject.O33T]
        FixMul  ebp
        add     ebx,eax
        push    ebx

        mov     eax,[esi+TObject.O12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[esi+TObject.O22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[esi+TObject.O32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[esi+TObject.O11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  ebx
        sub     ebp,eax

        pop     ebx
        mov     eax,[esi+TObject.O11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  ebx
        sub     ebp,eax

;o3=v3/|v3|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O13T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O23T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [esi+TObject.O33T],eax

        popad
        ret
ENDP

;############################################################################
PROC    TranslateObjectInWorldSpace
;IN     eax=object number, ebx=X-value, ecx=Y-value ,edx=Z-value
;translate object in world space
;X-,Y- and Z-values are 16.16 numbers
;############################################################################
        pushad
        shl     eax,5
        add     eax,[GPObjects]         ;addres of object
        mov     esi,eax
        add     [esi+TObject.XoT],ebx
        add     [esi+TObject.YoT],ecx
        add     [esi+TObject.ZoT],edx
        popad
        ret
ENDP

;############################################################################
PROC    TranslateObjectInObjectSpace
;IN     eax=object number, ebx=X-value, ecx=Y-value ,edx=Z-value
;translate object in object space
;X-,Y- and Z-values are 16.16 numbers
;############################################################################
        pushad
        push    edx
        push    ecx
        shl     eax,5
        add     eax,[GPObjects]         ;addres of object
        mov     esi,eax

        xor     ecx,ecx
        xor     edi,edi
        xor     ebp,ebp

        test    ebx,ebx
        jz      @@zeroX
        mov     eax,[esi+TObject.O11T]
        FixMul  ebx
        add     ecx,eax
        mov     eax,[esi+TObject.O21T]
        FixMul  ebx
        add     edi,eax
        mov     eax,[esi+TObject.O31T]
        FixMul  ebx
        add     ebp,eax
@@zeroX:

        pop     ebx
        test    ebx,ebx
        jz      @@zeroY
        mov     eax,[esi+TObject.O12T]
        FixMul  ebx
        mov     ecx,eax
        mov     eax,[esi+TObject.O22T]
        FixMul  ebx
        mov     edi,eax
        mov     eax,[esi+TObject.O32T]
        FixMul  ebx
        mov     ebp,eax
@@zeroY:

        pop     ebx
        test    ebx,ebx
        jz      @@zeroZ
        mov     eax,[esi+TObject.O13T]
        FixMul  ebx
        mov     ecx,eax
        mov     eax,[esi+TObject.O23T]
        FixMul  ebx
        mov     edi,eax
        mov     eax,[esi+TObject.O33T]
        FixMul  ebx
        mov     ebp,eax
@@zeroZ:

        add     [esi+TObject.XoT],ecx
        add     [esi+TObject.YoT],edi
        add     [esi+TObject.ZoT],ebp

        popad
        ret
ENDP



;############################################################################
PROC    RotateCameraInWorldSpace
;IN     ebx=X-angle, ecx=Y-angle ,edx=Z-angle
;rotates camera in object space about the three angles
;angle numbers can be 0-4095, all other are AND'ed
;############################################################################
        pushad
        push    edx
        push    ecx

;********************
;rotate along x-axis
;********************
;fetch sinus and cosinus values
        and     ebx,4095
        jz      @@zeroX
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the X-rotation matrix with the orientation matrix
        mov     eax,[GCameraO21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO31T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[GCameraO22T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO32T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[GCameraO23T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO33T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O23T

        mov     eax,[GCameraO31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[GCameraO32T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO22T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O32T

        mov     eax,[GCameraO33T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO23T]
        FixMul  edi
        sub     ebx,eax

        mov     [GCameraO33T],ebx
        pop     eax
        mov     [GCameraO32T],eax
        pop     eax
        mov     [GCameraO31T],eax
        pop     eax
        mov     [GCameraO23T],eax
        pop     eax
        mov     [GCameraO22T],eax
        pop     eax
        mov     [GCameraO21T],eax
@@zeroX:

;********************
;rotate along y-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroY
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Y-rotation matrix with the orientation matrix
        mov     eax,[GCameraO11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO31T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[GCameraO12T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO32T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[GCameraO13T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO33T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[GCameraO31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO11T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[GCameraO32T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO12T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O32T

        mov     eax,[GCameraO33T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO13T]
        FixMul  edi
        sub     ebx,eax

        mov     [GCameraO33T],ebx
        pop     eax
        mov     [GCameraO32T],eax
        pop     eax
        mov     [GCameraO31T],eax
        pop     eax
        mov     [GCameraO13T],eax
        pop     eax
        mov     [GCameraO12T],eax
        pop     eax
        mov     [GCameraO11T],eax
@@zeroY:

;********************
;rotate along z-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroZ
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Z-rotation matrix with the orientation matrix
        mov     eax,[GCameraO11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[GCameraO12T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO22T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[GCameraO13T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO23T]
        FixMul  edi
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[GCameraO21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO11T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[GCameraO22T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO12T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[GCameraO23T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO13T]
        FixMul  edi
        sub     ebx,eax

        mov     [GCameraO23T],ebx
        pop     eax
        mov     [GCameraO22T],eax
        pop     eax
        mov     [GCameraO21T],eax
        pop     eax
        mov     [GCameraO13T],eax
        pop     eax
        mov     [GCameraO12T],eax
        pop     eax
        mov     [GCameraO11T],eax
@@zeroZ:

;**************************************
;orthonormalize the orientation matrix
;**************************************
;o1=b1/|b1|
        mov     eax,[GCameraO11T]
        FixMul  eax
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        FixMul  eax
        add     ebx,eax
        mov     eax,[GCameraO31T]
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebp,eax

        mov     eax,[GCameraO11T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [GCameraO11T],eax

        mov     eax,[GCameraO21T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [GCameraO21T],eax

        mov     eax,[GCameraO31T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [GCameraO31T],eax

;v2=b2-(b2*o1)*o1
        mov     eax,[GCameraO11T]
        mov     ecx,[GCameraO12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        mov     edi,[GCameraO22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[GCameraO31T]
        mov     ebp,[GCameraO32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[GCameraO11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[GCameraO21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[GCameraO31T]
        FixMul  ebx
        sub     ebp,eax

;o2=v2/|v2|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO12T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO22T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO32T],eax

;v3=b3-(b3*o1)*o1-(b3*o2)*o2
        mov     eax,[GCameraO11T]
        mov     ecx,[GCameraO13T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        mov     edi,[GCameraO23T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[GCameraO31T]
        mov     ebp,[GCameraO33T]
        FixMul  ebp
        add     ebx,eax
        push    ebx

        mov     eax,[GCameraO12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[GCameraO22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[GCameraO32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[GCameraO11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[GCameraO21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[GCameraO31T]
        FixMul  ebx
        sub     ebp,eax

        pop     ebx
        mov     eax,[GCameraO11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[GCameraO21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[GCameraO31T]
        FixMul  ebx
        sub     ebp,eax

;o3=v3/|v3|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO13T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO23T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO33T],eax

        popad
        ret
ENDP

;############################################################################
PROC    RotateCameraInCameraSpace
;IN     ebx=X-angle, ecx=Y-angle ,edx=Z-angle
;rotates camera in camera space about the three angles
;angle numbers can be 0-4095, all other are AND'ed
;############################################################################
        pushad
        push    edx
        push    ecx

;********************
;rotate along x-axis
;********************
;fetch sinus and cosinus values
        and     ebx,4095
        jz      @@zeroX
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the X-rotation matrix with the orientation matrix
        mov     eax,[GCameraO12T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO13T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[GCameraO22T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO23T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[GCameraO32T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO33T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O32T

        mov     eax,[GCameraO12T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO13T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[GCameraO22T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO23T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O23T

        mov     eax,[GCameraO32T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO33T]
        FixMul  ebp
        add     ebx,eax

        mov     [GCameraO33T],ebx
        pop     eax
        mov     [GCameraO23T],eax
        pop     eax
        mov     [GCameraO13T],eax
        pop     eax
        mov     [GCameraO32T],eax
        pop     eax
        mov     [GCameraO22T],eax
        pop     eax
        mov     [GCameraO12T],eax
@@zeroX:

;********************
;rotate along y-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroY
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Y-rotation matrix with the orientation matrix
        mov     eax,[GCameraO11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO13T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[GCameraO21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO23T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[GCameraO31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO33T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[GCameraO11T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO13T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O13T

        mov     eax,[GCameraO21T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO23T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O23T

        mov     eax,[GCameraO31T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO33T]
        FixMul  ebp
        add     ebx,eax

        mov     [GCameraO33T],ebx
        pop     eax
        mov     [GCameraO23T],eax
        pop     eax
        mov     [GCameraO13T],eax
        pop     eax
        mov     [GCameraO31T],eax
        pop     eax
        mov     [GCameraO21T],eax
        pop     eax
        mov     [GCameraO11T],eax
@@zeroY:

;********************
;rotate along z-axis
;********************
;fetch sinus and cosinus values
        pop     ebx
        and     ebx,4095
        jz      @@zeroZ
        shl     ebx,2
        mov     eax,ebx
        add     eax,[GPSinTable]
        add     ebx,4096
        and     ebx,16383
        add     ebx,[GPSinTable]
        mov     edi,[eax]       ;sinus
        mov     ebp,[ebx]       ;cosinus

;multiply the Z-rotation matrix with the orientation matrix
        mov     eax,[GCameraO11T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO12T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O11T

        mov     eax,[GCameraO21T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO22T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O21T

        mov     eax,[GCameraO31T]
        FixMul  ebp
        mov     ebx,eax
        mov     eax,[GCameraO32T]
        FixMul  edi
        sub     ebx,eax
        push    ebx     ;save new O31T

        mov     eax,[GCameraO11T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO12T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O12T

        mov     eax,[GCameraO21T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO22T]
        FixMul  ebp
        add     ebx,eax
        push    ebx     ;save new O22T

        mov     eax,[GCameraO31T]
        FixMul  edi
        mov     ebx,eax
        mov     eax,[GCameraO32T]
        FixMul  ebp
        add     ebx,eax

        mov     [GCameraO32T],ebx
        pop     eax
        mov     [GCameraO22T],eax
        pop     eax
        mov     [GCameraO12T],eax
        pop     eax
        mov     [GCameraO31T],eax
        pop     eax
        mov     [GCameraO21T],eax
        pop     eax
        mov     [GCameraO11T],eax
@@zeroZ:

;**************************************
;orthonormalize the orientation matrix
;**************************************
;o1=b1/|b1|
        mov     eax,[GCameraO11T]
        FixMul  eax
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        FixMul  eax
        add     ebx,eax
        mov     eax,[GCameraO31T]
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebp,eax

        mov     eax,[GCameraO11T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [GCameraO11T],eax

        mov     eax,[GCameraO21T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [GCameraO21T],eax

        mov     eax,[GCameraO31T]
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebp
        mov     [GCameraO31T],eax

;v2=b2-(b2*o1)*o1
        mov     eax,[GCameraO11T]
        mov     ecx,[GCameraO12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        mov     edi,[GCameraO22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[GCameraO31T]
        mov     ebp,[GCameraO32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[GCameraO11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[GCameraO21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[GCameraO31T]
        FixMul  ebx
        sub     ebp,eax

;o2=v2/|v2|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO12T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO22T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO32T],eax

;v3=b3-(b3*o1)*o1-(b3*o2)*o2
        mov     eax,[GCameraO11T]
        mov     ecx,[GCameraO13T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[GCameraO21T]
        mov     edi,[GCameraO23T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[GCameraO31T]
        mov     ebp,[GCameraO33T]
        FixMul  ebp
        add     ebx,eax
        push    ebx

        mov     eax,[GCameraO12T]
        FixMul  ecx
        mov     ebx,eax
        mov     eax,[GCameraO22T]
        FixMul  edi
        add     ebx,eax
        mov     eax,[GCameraO32T]
        FixMul  ebp
        add     ebx,eax

        mov     eax,[GCameraO11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[GCameraO21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[GCameraO31T]
        FixMul  ebx
        sub     ebp,eax

        pop     ebx
        mov     eax,[GCameraO11T]
        FixMul  ebx
        sub     ecx,eax
        mov     eax,[GCameraO21T]
        FixMul  ebx
        sub     edi,eax
        mov     eax,[GCameraO31T]
        FixMul  ebx
        sub     ebp,eax

;o3=v3/|v3|
        mov     eax,ecx
        FixMul  eax
        mov     ebx,eax
        mov     eax,edi
        FixMul  eax
        add     ebx,eax
        mov     eax,ebp
        FixMul  eax
        add     eax,ebx
        call    SqrRoot
        mov     ebx,eax

        mov     eax,ecx
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO13T],eax

        mov     eax,edi
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO23T],eax

        mov     eax,ebp
        cdq
        shld    edx,eax,16
        shl     eax,16
        idiv    ebx
        mov     [GCameraO33T],eax

        popad
        ret
ENDP

;############################################################################
PROC    TranslateCameraInWorldSpace
;IN     ebx=X-value, ecx=Y-value ,edx=Z-value
;translate camera in world space
;X-,Y- and Z-values are 16.16 numbers
;############################################################################
        add     [GCameraXPosT],ebx
        add     [GCameraYPosT],ecx
        add     [GCameraZPosT],edx
        ret
ENDP

;############################################################################
PROC    TranslateCameraInCameraSpace
;IN     ebx=X-value, ecx=Y-value ,edx=Z-value
;translate camera in camera space
;X-,Y- and Z-values are 16.16 numbers
;############################################################################
        pushad
        push    edx
        push    ecx

        xor     ecx,ecx
        xor     edi,edi
        xor     ebp,ebp

        test    ebx,ebx
        jz      @@zeroX
        mov     eax,[GCameraO11T]
        FixMul  ebx
        add     ecx,eax
        mov     eax,[GCameraO21T]
        FixMul  ebx
        add     edi,eax
        mov     eax,[GCameraO31T]
        FixMul  ebx
        add     ebp,eax
@@zeroX:

        pop     ebx
        test    ebx,ebx
        jz      @@zeroY
        mov     eax,[GCameraO12T]
        FixMul  ebx
        mov     ecx,eax
        mov     eax,[GCameraO22T]
        FixMul  ebx
        mov     edi,eax
        mov     eax,[GCameraO32T]
        FixMul  ebx
        mov     ebp,eax
@@zeroY:

        pop     ebx
        test    ebx,ebx
        jz      @@zeroZ
        mov     eax,[GCameraO13T]
        FixMul  ebx
        mov     ecx,eax
        mov     eax,[GCameraO23T]
        FixMul  ebx
        mov     edi,eax
        mov     eax,[GCameraO33T]
        FixMul  ebx
        mov     ebp,eax
@@zeroZ:

        add     [GCameraXPosT],ecx
        add     [GCameraYPosT],edi
        add     [GCameraZPosT],ebp

        popad
        ret
ENDP


ENDS
END