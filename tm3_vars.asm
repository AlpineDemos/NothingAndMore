;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ  ßßßßßßßßßßÛÛÛÛÛÛÜ  THE MODULE V3.00á
;           ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ          ßßÛÛÛÛÛÛÛ   (C) Spring 1997
;           ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ  ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß  by Syrius / Alpine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; VARIABLES NEEDED FOR TM3-PLAYER                                            ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;


;Û²±° General Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

 StartPattern dd ?
 TM3SyncF     dw ?
 TM3SyncCount dd ?

 ChCount    db ?           ; Channel-Counter
 CHINC      dd ?           ; For Track-View
 Stereo     db ?       ; 0=Mono, 1=Stereo
 SongLoop   db ?
 PatternLen dd ?

 ALIGN 16

 PTRPattern  dd 128 dup (?)
 DMABuf      dd ?                 ; Pointer to Start of TM3Buffer
 TM3_IRQ     dd ?
 SBVer       dw ?

;Û²±° Hardware Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

 ADR   dw ?
 IRQ   db ?
 DMA   db ?

 IRQ2 dd ?
 IRQ3 dd ?
 IRQ5 dd ?
 IRQ7 dd ?
 IRQA dd ?

 SB_OldIrq   dd ?
 SB_CallBack dd ?
 SB_Stub_Buf db 21 dup (?)

 Port21 db ?
 PortA1 db ?
 DMAFlipFlop db ?
 MixProc     dd ?               ; Offset of MixStereo or MixMono

;Û²±° Mixer Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

 DivConst      dd  ?

 SamplingRate  dw  ?
 CPattern      db  ?     ; Current Position in ORDERS
 C_BufPosition dd  ?     ; Buffer-Address !

 Bytes2Fill    dw  ?     ; Bytes, that have to be filled until buffer is ready
 MaxSampleBytes dw ?     ; Length of 1 Buffer
 Bytes4Tick    dw  ?
 C_BPT         dw  ?     ; Current Bytes Per Tick to be mixed
 BytesPerTick  dw  ?     ; Bytes per Tick -> Length of DMA-Transfer.

 Ticks         db  ?     ; Ticks = Speed - 1

 PatternJMP    db  ?
 PatternROW    db  ?
 PatternLine   db  ?     ; Current Line in Pattern
 LoopIt        db  ?     ; Loop Song ?
 IRQ_Stop      db  ?     ; 1=Enable Self-Switch-Down
 IRQ_Finished  db  ?     ; 1=Switch-Down fulfilled...
 ChPointer     dd  ?     ; Pointer to Current Channel in Pattern
 TM3CalcBuf    dd  ?

 ALIGN 16

 IFNDEF TM3INC
  MasterSpace  dw ?
  GlobalVol    db ?
  Speed        db ?
  BPM          db ?     ; BPM default = 50
  Tempo        db ?
  Channels     db ?
  SongLen      db ?
  Order        db 128 dup (?)
  PatNum       db ?
  SmpNum       db ?
  Panning      db 32 dup (?)
  SampleVols   db 100 dup (?)
  LineAdd      dd ?
  PackedLen    dw ?
  TM3Handle    dw ?
 ENDIF


;Û²±° Buffer... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

 CSampleP   dd ?
 SampleP    dd ?
 TM3BufferP dd ?
 MixBufP    dd ?
 PostProcP  dd ?

 Voltable    db 16640 dup (?)

;STRUC SampleStruc
; Start     dd ?        ; 0
; Length    dd ?        ; 4
; LStart    dd ?        ; 8
; C2SPD     dd ?        ;12
;ENDS
;
;STRUC CurrentSampleStruc     ; 64 Byte pro Channel = 256 Bytes
; Start     dd ?     ;0
; Length    dd ?     ;4
; LStart    dd ?     ;8
; C2SPD     dd ?     ;12
; Volume    db ?     ;16
; ;----------------------^ 17 Byte Loaded from SampleStruc!
; Status    db ?     ;17  Bit 0:  1-> Playing, 0-> Stopped.
;                    ;    Bit 7:  1-> Left Orientated, 0-> Right orientated
; MonoVol   db ?     ;18
; Panning   db ?     ;19
; VolLeft   db ?     ;20
; VolRight  db ?     ;21
; Period    dw ?     ;22  ; Porta 2 note
; CountI    dd ?     ;24
; CountF    dw ?     ;28
; IncF      dw ?     ;30  ; Intel-Format!!! Lo-Hi
; IncI      dd ?     ;32
; DstPeriod dw ?     ;36
; SmpIndex  db ?     ;38 ¿
; NoteIndex db ?     ;39 ³    Save it for e.g.
; VolumeCol db ?     ;40 ³
; Effect    db ?     ;41 ³ this @$%#() NOTE-DELAY
; FXByte    db ?     ;42 Ù          !!!
;
; TickCmd   db ?     ;43  ; Command-Byte as Index to JmpTable2
; WorkByte  db ?     ;44
; WorkByte2 db ?     ;45
; LastVSld  db ?     ;46
; LastPSldD db ?     ;47
; LastPSldU db ?     ;48
; LastPorta db ?     ;49
; LoopStart db ?     ;50
; LoopCount db ?     ;51
; db52      db ?     ;52
; db53      db ?     ;53
; db54      db ?     ;54
; db55      db ?     ;55
; db56      db ?     ;56
; db57      db ?     ;57
; db58      db ?     ;58
; db59      db ?     ;59
; db60      db ?     ;60
; db61      db ?     ;61
; db62      db ?     ;62
; db63      db ?     ;63
;ENDS
