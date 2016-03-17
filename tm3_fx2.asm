;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ;
; ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€€€€€€‹  €€€€€€€ﬂ€ﬂ€€€€€€‹  ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€€€€€€‹  THE MODULE V3.00·
;           €€€€€€€  €€€€€€€ ﬂ €€€€€€€          ﬂﬂ€€€€€€€   (C) Spring 1997
;           €€€€€€€  €€€€€€€   €€€€€€€  ‹‹‹‹‹‹‹‹‹‹€€€€€€ﬂ  by Syrius / Alpine
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ;
; TICK-EFFECTS
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ;

    ;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ VSlide Up.....: [01h] ∞±±≤≤≤€€€€€
    @VSlideUp:
      mov bl, [edi+CVolume]
      add bl, [edi+CWorkByte]
      cmp bl,65                  ; No Overflow!
      jb @NoVSU
       mov bl,64
      @NoVSU:
       mov [edi+CVolume],bl       ; Save Volume
       mov bh,[GlobalVol]
       mov bl,[VolTable+ebx]      ; Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ; -> Got MonoVolume
       mov bh,[edi+CPanning]      ; Get Panning: 0..64
       mov bh,[Voltable+ebx]      ; Get Volume Right
       sub bl,bh                  ; Get Volume Left
       mov [Edi+CVolLeft],bx      ; Ready
      jmp @ChannelFinishedTx


    ;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ VSlide Dn.....: [02h] ∞±±≤≤≤€€€€€
    @VSlideDn:
      mov bl, [edi+CVolume]
      sub bl, [edi+CWorkByte]
      jns @NoVSD
       xor bl,bl
      @NoVSD:
       mov [edi+CVolume],bl       ; Save Volume
       mov bh,[GlobalVol]
       mov bl,[VolTable+ebx]      ; Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ; -> Got MonoVolume
       mov bh,[edi+CPanning]      ; Get Panning: 0..64
       mov bh,[Voltable+ebx]      ; Get Volume Right
       sub bl,bh                  ; Get Volume Left
       mov [Edi+CVolLeft],bx      ; Ready
      jmp @ChannelFinishedTx


    ;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ PSlide Dn.....: [03h] ∞±±≤≤≤€€€€€
    @PSlideDn:
      xor eax,eax
      mov al, [edi+CWorkByte]
      shl eax, 2
      mov bx, [edi+CPeriod]
      add ebx, eax
      cmp bx,[edi+CDstPeriod]
      jbe @NoStopPSLDD
       mov bx,[edi+CDstPeriod]
       mov [b edi+CTickCmd],0
      @NoStopPSLDD:
      mov eax,[DivConst]     ; (14317056 DIV SamplingRate) shl 16 !
      xor edx,edx
      div ebx                ; EDX = 0!
      mov [d edi+CIncF],eax  ; Ready.
      mov [edi+CPeriod],bx
      jmp @ChannelFinishedTx


    ;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ PSlide Up.....: [04h] ∞±±≤≤≤€€€€€
    @PSlideUp:
      xor eax,eax
      mov al, [edi+CWorkByte]
      shl eax, 2
      mov bx, [edi+CPeriod]
      sub bx, ax
      js  @SetPSLDU
      cmp bx,[edi+CDstPeriod]
      jae @NoStopPSLDU
       @SetPSLDU:
       mov bx,[edi+CDstPeriod]
       mov [b edi+CTickCmd],0
      @NoStopPSLDU:
      mov eax,[DivConst]     ; (14317056 DIV SamplingRate) shl 16 !
      xor edx,edx
      div ebx                ; EDX = 0!
      mov [d edi+CIncF],eax  ; Ready.
      mov [edi+CPeriod],bx
      jmp @ChannelFinishedTx

    ;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ Retrig........: [05h] ∞±±≤≤≤€€€€€
    @TRetrig:
     dec [B edi+CWorkByte]
     jnz @ChannelFinishedTx
      mov al, [edi+CWorkByte2]
      mov [edi+CWorkByte],al
      xor eax,eax
      mov [edi+CCountI],eax
      mov [edi+CCountF],ax
      jmp @ChannelFinishedTx