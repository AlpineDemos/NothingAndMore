
PROC Timer3D
        Call TimerCopy
	xor	eax,eax
	xor	ebx,ebx
	xor	ecx,ecx
	mov	edx,65536*3
        call    TranslateObjectInWorldSpace
 Ret
ENDP

PROC Timer3D_2
        Call TimerCopy
	xor	eax,eax
	xor	ebx,ebx
	xor	ecx,ecx
	mov	edx,-65536*4
        call    TranslateObjectInWorldSpace
 Ret
ENDP