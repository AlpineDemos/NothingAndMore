B	EQU	BYTE PTR
W	EQU	WORD PTR
D	EQU	DWORD PTR
O	EQU	OFFSET
S	EQU	SEG

MACRO	FixMul	Factor
	imul	Factor
	shrd	eax,edx,16
ENDM

MACRO	Set0Col R,G,B
	push	ax
	push	dx
	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	mov	al,R
	out	dx,al
	mov	al,G
	out	dx,al
	mov	al,B
	out	dx,al
	pop	dx
	pop	ax
ENDM

MACRO	MemAlign
LOCAL	@@NoLoMem,@@NoHiMem
	push	eax
	call	_lomemsize
	cmp	eax,64
	jb	@@NoLoMem
	mov	eax,[_lomembase]
	add	eax,[_code32a]
	add	eax,31
	and	eax,NOT 31	;align on the nearest 32-byte-boundary
	sub	eax,[_code32a]
	mov	[_lomembase],eax
@@NoLoMem:
	call	_himemsize
	cmp	eax,64
	jb	@@NoHiMem
	mov	eax,[_himembase]
	add	eax,[_code32a]
	add	eax,31
	and	eax,NOT 31	;align on the nearest 32-byte-boundary
	sub	eax,[_code32a]
	mov	[_himembase],eax
@@NoHiMem:
	pop	eax
ENDM