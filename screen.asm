;hardware-dependent screen routines for the ALPiNE 3D-Engine
;written in spring and summer 1997 by Ziron

IDEAL
P386
ASSUME	cs:code32,ds:code32

SEGMENT code32	PARA PUBLIC USE32
MASM
INCLUDE pmode.inc
IDEAL
INCLUDE 'decl.inc'
INCLUDE 'screen.inc'

;###########################################################################
PROC	ScrSaveCurrentMode
;saves the current screen mode, so it can be restored at the end
;###########################################################################
	push	ax
	mov	al,[gs:449h]
	mov	[ScrOldMode],al
	pop	ax
	ret
ENDP

;###########################################################################
PROC	ScrRestoreOldMode
;restores the old screen-mode
;###########################################################################
	push	ax
	mov	al,[ScrOldMode]
	xor	ah,ah
	mov	[v86r_ax],ax
	mov	al,10h
	int	33h
	pop	ax
	ret
ENDP

;###########################################################################
PROC	ScrSetMode
;IN	AL=mode-number
;OUT	CF=0 if success
;	CF=1 if failure
;sets the screen-mode
;###########################################################################
	pushad
	mov	ebp,eax
	cmp	[PVBEBuffer],0
	jnz	@@BufferAllocated
	mov	eax,512
	call	_getlomem
	jc	@@failure
	mov	[PVBEBuffer],eax
@@BufferAllocated:
	mov	eax,ebp

	movzx	eax,al
	lea	ebx,[eax*8+ModeData]
	movzx	eax,[W ebx+4]
	mov	[GScrXRes],ax
	movzx	ecx,[W ebx+6]
	mov	[GScrYRes],cx
	imul	eax,ecx
	mov	[GScrBytes],eax
	cmp	[W ebx],1
	je	@@XMode
	cmp	[W ebx],2
	je	@@VBE10
	cmp	[W ebx],3
	je	@@VBE20

@@VGA:
	mov	[FrameBufferType],0	;LFB
	mov	ax,[ebx+2]
	mov	[v86r_ax],ax
	mov	al,10h
	int	33h
	mov	[ScrAddress],0a0000h
	jmp	@@end

@@XMode:	;320x400
	mov	[FrameBufferType],2	;X-Mode
	mov	ax,[ebx+2]
	mov	[v86r_ax],ax
	mov	al,10h
	int	33h
	mov	[ScrAddress],0a0000h

	mov	dx,3c4h
	mov	al,4h
	out	dx,al
	mov	dx,3c5h
	in	al,dx
	and	al,11110111b
	out	dx,al

	mov	dx,3d4h
	mov	al,14h
	out	dx,al
	mov	dx,3d5h
	in	al,dx
	and	al,10111111b
	out	dx,al

	mov	dx,3d4h
	mov	al,17h
	out	dx,al
	mov	dx,3d5h
	in	al,dx
	or	al,01000000b
	out	dx,al

	mov	ax,0f02h	;clear video-RAM
	mov	dx,3c4h
	out	dx,ax
	mov	edi,0a0000h
	sub	edi,[_code32a]
	mov	ecx,16384
	xor	eax,eax
rep	stosd

	mov	dx,3d4h
	mov	ax,0009h
	out	dx,ax		;set resolution 320*400

	jmp	@@end

@@VBE10:
	mov	[FrameBufferType],1	;BFB
	mov	edi,[PVBEBuffer]
	add	edi,[_code32a]
	shld	eax,edi,28
	mov	[v86r_es],ax
	and	edi,0fh
	mov	[v86r_di],di
	mov	[v86r_ax],4f00h
	mov	al,10h
	int	33h
	cmp	[v86r_ax],004fh
	jne	@@failure

	movzx	edi,[v86r_es]
	shl	edi,4
	movzx	eax,[v86r_di]
	add	edi,eax
	cmp	[W gs:edi+4],0100h	;check version
	jb	@@failure

	mov	ax,[ebx+2]
	mov	bp,ax			;save video mode number
	mov	[v86r_cx],ax
	mov	edi,[PVBEBuffer]
	add	edi,[_code32a]
	shld	eax,edi,28
	mov	[v86r_es],ax
	and	edi,0fh
	mov	[v86r_di],di
	mov	[v86r_ax],4f01h
	mov	al,10h
	int	33h
	cmp	[v86r_ax],004fh
	jne	@@failure

	mov	edi,[PVBEBuffer]
	mov	ax,[edi]
	test	ax,1
	jz	@@failure
	mov	ax,[W edi+4]
	mov	[WinGranularity],ax
	movzx	eax,[W edi+8]
	shl	eax,4
	mov	[ScrAddress],eax

	mov	[v86r_ax],4f02h
	mov	[v86r_bx],bp
	mov	al,10h
	int	33h
	cmp	[v86r_ax],004fh
	jne	@@failure
	jmp	@@end

@@VBE20:
;	mov	[FrameBufferType],0	;LFB
;	mov	edi,[PVBEBuffer]
;	mov	[D edi],'2EBV'
;	add	edi,[_code32a]
;	shld	eax,edi,28
;	mov	[v86r_es],ax
;	and	edi,0fh
;	mov	[v86r_di],di
;	mov	[v86r_ax],4f00h
;	mov	al,10h
;	int	33h
;	cmp	[v86r_ax],004fh
;	jne	@@failure
;
;	movzx	edi,[v86r_es]
;	shl	edi,4
;	movzx	eax,[v86r_di]
;	add	edi,eax
;	cmp	[W gs:edi+4],0100h	;check version
;WriteLnHexWord [gs:edi+4]
;	jb	@@failure
;
;	mov	ax,[ebx+2]
;	mov	bp,ax			;save video mode number
;	mov	[v86r_cx],ax
;	mov	edi,[PVBEBuffer]
;	add	edi,[_code32a]
;	shld	eax,edi,28
;	mov	[v86r_es],ax
;	and	edi,0fh
;	mov	[v86r_di],di
;	mov	[v86r_ax],4f01h
;	mov	al,10h
;	int	33h
;	cmp	[v86r_ax],004fh
;	jne	@@failure
;mov	edi,[PVBEBuffer]
;WriteLnBinWord [edi]
;
;	mov	edi,[PVBEBuffer]
;	mov	ax,[edi]
;	test	ax,1
;	jz	@@failure
;	mov	ax,[W edi+4]
;	mov	[WinGranularity],ax
;	movzx	eax,[W edi+8]
;	shl	eax,4
;	mov	[ScrAddress],eax
;
;	mov	[v86r_ax],4f02h
;	mov	[v86r_bx],bp
;	mov	al,10h
;	int	33h
;	cmp	[v86r_ax],004fh
;	jne	@@failure
;	jmp	@@end

@@end:
	popad
	clc
	ret
@@failure:
	popad
	stc
	ret
ENDP

;###########################################################################
PROC	ScrCopyBuffer
;IN	ESI=linear address of buffer
;copies a buffer to the screen
;###########################################################################
	cmp	[FrameBufferType],1
	je	@@BFB
	cmp	[FrameBufferType],2
	je	@@XMode
;Linear Frame Buffer
	push	cx
	push	esi
	push	edi
	mov	ecx,[GScrBytes]
	shr	ecx,2
	mov	edi,[ScrAddress]
	sub	edi,[_code32a]
rep	movsd
	pop	edi
	pop	esi
	pop	cx
	ret

@@BFB:
;Banked Frame Buffer
	pushad
	mov	bx,1
	cmp	[WinGranularity],64
	je	@@WinGran64
;granulity is 4  if not, it won't work ;-)
	mov	bx,16
@@WinGran64:
	xor	dx,dx		;window position
	mov	ebp,[GScrBytes]
	shr	ebp,2		;DWords to be written
@@1:	mov	ecx,16384
	cmp	ebp,16384
	jnb	@@2
	mov	ecx,ebp
@@2:	sub	ebp,ecx
	mov	[v86r_ax],4f05h
	mov	[v86r_bx],0
	mov	[v86r_dx],dx
	add	dx,bx
	mov	al,10h
	push	es
	int	33h
	pop	es
	mov	edi,[ScrAddress]
	sub	edi,[_code32a]
rep	movsd
	test	ebp,ebp
	jnz	@@1
	popad
	ret

@@XMode:	;(320x400)
	pushad
	mov	edi,0a0000h+32000
	cmp	[XModePage],0
	jz	@@Page0
	mov	edi,0a0000h
@@Page0: sub	edi,[_code32a]
	mov	ax,0102h
	mov	cl,4

@@3:	mov	dx,3c4h
	out	dx,ax
	shl	ah,1
	mov	edx,32000
@@4:	mov	bl,[esi]
	mov	[edi],bl
	add	esi,4
	inc	edi
	dec	edx
	jnz	@@4
	sub	esi,128000-1
	sub	edi,32000
	dec	cl
	jnz	@@3

	xor	bx,bx
	xor	[XModePage],1
	jz	@@Page0b
	mov	bx,32000
@@Page0b:
	mov	dx,3d4h
	mov	al,0ch
	mov	ah,bh
	out	dx,ax
	mov	al,0dh
	mov	ah,bl
	out	dx,ax
	popad
	ret
XModePage	DB	0
ENDP

;###########################################################################
PROC	ScrWaitVRetrace
;waits for vertical retrace
;###########################################################################
	push	ax
	push	dx
	mov	dx,3dah
@@1:	in	al,dx
	test	al,08h
	jnz	@@1
@@2:	in	al,dx
	test	al,08h
	jz	@@2
	pop	dx
	pop	ax
	ret
ENDP

LABEL	ModeData BYTE
;Mode 320x200x256
	DW	0	;0=VGA, 1=X-Mode(320x400), 2=VBE 1.0, 3=VBE 2.0 (LFB)
	DW	13h	;mode
	DW	320	;X-Res
	DW	200	;Y-Res
;Mode 320x400x256
	DW	1	;0=VGA, 1=X-Mode(320x400), 2=VBE 1.0, 3=VBE 2.0 (LFB)
	DW	13h	;mode
	DW	320	;X-Res
	DW	400	;Y-Res
;Mode 640x400x256
	DW	2	;0=VGA, 1=X-Mode(320x400), 2=VBE 1.0, 3=VBE 2.0 (LFB)
	DW	100h	;mode
	DW	640	;X-Res
	DW	400	;Y-Res
;Mode 640x480x256
	DW	2	;0=VGA, 1=X-Mode(320x400), 2=VBE 1.0, 3=VBE 2.0 (LFB)
	DW	101h	;mode
	DW	640	;X-Res
	DW	480	;Y-Res
;Mode 800x600x256
	DW	2	;0=VGA, 1=X-Mode(320x400), 2=VBE 1.0, 3=VBE 2.0 (LFB)
	DW	103h	;mode
	DW	800	;X-Res
	DW	600	;Y-Res
;Mode 1024x768x256
	DW	2	;0=VGA, 1=X-Mode(320x400), 2=VBE 1.0, 3=VBE 2.0 (LFB)
	DW	105h	;mode
	DW	1024	;X-Res
	DW	768	;Y-Res

GScrBytes	DD	?	;number of bytes the video mode needs
ScrAddress	DD	?	;beginning of the video-data
WinGranularity	DW	?
GScrXRes	DW	?
GScrYRes	DW	?
PVBEBuffer	DD	0	;Pointer to a 512 byte buffer
ScrOldMode	DB	?	;old screen-mode
FrameBufferType DB	?	;0=LFB (VGA or VBE 2.0), 1=BFB (VBE 1.0)

ENDS
END