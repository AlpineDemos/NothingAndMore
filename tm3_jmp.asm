;����������������������������������������������������������������������������;
; �����������������  �����������������  �����������������  THE MODULE V3.00�
;           �������  ������� � �������          ���������   (C) Spring 1997
;           �������  �������   �������  �����������������  by Syrius / Alpine
;����������������������������������������������������������������������������;
; JUMP-TABLE FOR EFFECTS...                                                  ;
;����������������������������������������������������������������������������;

JumpTable   dd O @ChannelFinished;00h
            dd O @SetSpeed       ;01h
            dd O @PatternJMP     ;02h
            dd O @PatternBreak   ;03h
            dd O @VSlide         ;04h
            dd O @PortaDn        ;05h
            dd O @PortaUp        ;06h
            dd O @TonePorta      ;07h
            dd O @Vibrato        ;08h
            dd O @FineVibrato    ;09h
            dd O @Tremor         ;0Ah
            dd O @Arpeggio       ;0Bh
            dd O @VSlide         ;0Ch @VibVSlide !!!
            dd O @VSlide         ;0Dh @PortaVSlide !!
            dd O @SampleOffset   ;0Eh
            dd O @Retrig         ;0Fh
            dd O @Tremolo        ;10h
            dd O @PatternDelay   ;11h
            dd O @SetLoopStart   ;12h
            dd O @LoopPattern    ;13h
            dd O @NoteCut        ;14h
            dd O @NoteDelay      ;15h
            dd O @SetTempo       ;16h
            dd O @SetGlobalVol   ;17h
            dd O @SetPanning     ;18h

JumpTableTx dd O @ChannelFinishedTx ;00h
            dd O @VSlideUp          ;01h
            dd O @VSlideDn          ;02h
            dd O @PSlideDn          ;03h
            dd O @PSlideUp          ;04h
            dd O @TRetrig           ;05h
