ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ Normal 9-voice ADLIB player .............. Copyright (C) Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Standard ADLIB player for use with the Play-Driver and EdLib, apart from all ³
³ future game and demo projects.                                               ³
³                                                                              ³
³ SPECIAL VERSION for EDLIB only, please search for the word "EDITOR".         ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ v04.01, 12/1993. Version numbers in "VERSION2" and "CREDITS".                ³
³                                                                              ³
³                                                                              ³
³  After some struggle I implemented a new table system called "SpFX" which   ³
³   bypasses the instrument and calls a seperate table with arpeggio and level ³
³   sliding effects in the modulator.                                          ³
³                                                                              ³
³  Finetune in instrument added, alters the FREQ variable in SETSOUND.        ³
³                                                                              ³
³  Added hard restart with a frame timer PLUS the new Sustain/Release value   ³
³   to perform when hard restarting. It was a little tricky adapting for the   ³
³   complicated floating point speed system, but eventually I got around it.   ³
³                                                                              ³
³  Made sure slide works in SpFX mode. However, hard restart will not always  ³
³   work 100% properly in this mode, for quite obvious reasons though. Using   ³
³   different instruments in this mode cannot work in any other way. Also made ³
³   sure vibrato functions properly under the SpFX mode. The combinations are  ³
³   not perfect though, slide, vibrato and SpFX simultaneously may not work.   ³
³                                                                              ³
³  Fixed an old bug, DURR should be set in the NUMBER function.               ³
³                                                                              ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ EDITOR...                                                                    ³
³                                                                              ³
³  8/12-1993: Added a 9th function to play using a keyboard. Fully working as ³
³   intended so far.                                                           ³
³                                                                              ³
³  Added function 0ah too, which controls the vibrato in keyboard play mode.  ³
³                                                                              ³
³  11/12-1993: Modified function 0ah to set vibrato ON or OFF, depending on   ³
³   the flag in register CL.                                                   ³
³                                                                              ³
³  Copied part of the INIT routine into function 09h, to make sure all the    ³
³   variables are cleared the first time this function is used.                ³
³                                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

GeneralPtr      equ     107

ClearArea       equ     Carrier-Dur             ;Area to clear in INIT routine.

                                                ;EDITOR: Now "-Dur" because of
                                                ;certain variables not cleared.
                                                ;Previously "Carrier-Inst", with
                                                ;INST placed before SPEC.

include         globals.inc


MusicPlayer     segment public
assume          cs:MusicPlayer,ds:MusicPlayer
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Player          proc    far

                jmp     Function                ;This JMP must be 3 bytes long.

Detection	db	'JCH',26h,02h,66h       ;System detection bytes.
Version2        dw      0401h                   ;Current card player version.
Card		db	00h			;00h for normal Adlib.
NumVoices	db	9			;Number of voices supported.

CardName        db      'AdLib / EDITOR version          '      ;32 bytes name.

Active		dw	Inst			;Pointers to active variables.
                db      1                       ;Byte: 00h=Bytes, 01h=Words.
		dw	Dur
                db      1
		dw	SeqPoi
                db      1
		dw	TrackPoi
                db      1
		dw	Freq
                db      1
		dw	Spedr
                db      0
		dw	Gate
                db      0
		dw	Nog
                db      0
		dw	Note			;Note includes transposition.
                db      0

                db      32 dup (0)              ;For future expansion...

VoicOn		db	0,0,0,0,0,0,0,0,0	;Voice ON/OFF flags.

Credits         db      ' Player v04.01 (C) Copyright 1993 Jens-Christian Huus. '
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Main:		xor	bx,bx			;Voice no. for bytes.
		mov	si,bx			;Voice no. for words.
m10:
		mov	es,[Eseg+si]

              cmp     [KeyMode],0               ;EDITOR: Keyboard play mode.
              jz      m12
              jmp     RealTime
m12:
		cmp	byte ptr [VoicOn+bx],0
                jne     m15
		jmp	Next
m15:
		mov	al,[Spedr+bx]
		add	[Speed+bx],al
                jns     m40
		and	[Speed+bx],7fh		;Floating point speed.

		dec	[Dur+si]
		jge	m30
		jmp	SetAll
m30:		
		jmp	RealTime
m40:
                cmp     [HardRst+bx],1          ;Already done this once?
                jz      m30

                mov     dl,[Speed+bx]           ;Hard restart/Key-off.
                mov     cl,[HardTimer+bx]
                or      cl,cl
                jne     m50
                inc     cl
m50:            mul     cl                      ;Get hard restart frame timer.
                add     dl,al
                jns     m30
                cmp     [Dur+si],0
                jne     m30
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ReadTrack:
              mov     es,[TrackSeg]             ;EDITOR.

                mov     [HardRst+bx],1          ;Flag, don't call this twice.

		mov	[Tempw],0		;Clear slfreq.

                mov     ax,[SlReal+si]
                mov     [ShSlReal+si],ax

		mov	bp,[TrackPoi+si]
		add	bp,[TrackPointer+si]
r05:
                mov     di,[es:bp]
		cmp	di,0fffeh		;Stopmark.
                jne	r06
                mov     byte ptr [VoicOn+bx],0
		mov	[Freq+si],0
                mov     [Vfreq+si],0
                mov     byte ptr [FineTune+bx],0
		mov	byte ptr [Gate+bx],0
		mov	byte ptr [Speed+bx],0
		mov	byte ptr [Vspeed+bx],0
		jmp	SetSound
r06:
		cmp	di,0ffffh		;Wrapmark.
		jne	r07
              mov     dx,[TrackPoi+si]          ;EDITOR.
		mov	ax,[es:bp+2]		;Loopvalue.
		shl	ax,1
                mov     [TrackPoi+si],ax
              cmp     dx,ax                     ;EDITOR: Don't meet a deadlock.
              jne     r062
              jmp     Next
r062:         mov     ax,[SeqPoi+si]            ;EDITOR: StartPoint wrap in seq.
              add     ax,[SPseq+si]
              mov     [SeqPoi+si],ax
		jmp	short ReadTrack
r07:
		mov	dx,di			;Transpose.
		and	dx,0f000h
		cmp	dx,8000h
                jne     r08
		mov	dx,di
                and     dx,00ffh
                shl     dx,1
		mov	[Transp+si],dx
                mov     dx,di
                and     dx,0f00h
		jz	r12
		neg	[Transp+si]
                jmp	short r12
r08:
		cmp	dx,9000h		;New speed.
                jne     readseq
                mov     dx,di
		mov	[Spedr+bx],dl
                jmp     short r12
ReadSeq:
              ; shl     di,1
              ; mov     bp,[Eoffset+si]
              ; add     di,[es:GeneralPtr+(01h*2)+bp]
              ; add     di,bp
              ; mov     bp,[SeqPoi+si]
              ; add     bp,[es:di]
              ; add     bp,[Eoffset+si]

              mov     ax,[SeqAdd]               ;EDITOR.
              xor     dx,dx
              mul     di                        ;Predefined locations for seq's.
              mov     bp,[SeqPoi+si]
              add     bp,ax
r10:
              mov     es,[SeqSeg]               ;EDITOR.
            
                mov     ax,[es:bp]
		add	[SeqPoi+si],2
		cmp	ax,0ffffh
		jne	r20
              mov     [seqpoi+si],2             ;EDITOR: Skip word in seq's.

              ; mov     [SeqPoi+si],0           ;End of sequence.
r12:
		add	[TrackPoi+si],2
		jmp	ReadTrack
r20:
              cmp     ax,0f000h                 ;EDITOR: No operation.
              jz      ReRead

		mov	di,ax
		and	ax,0f000h
		cmp	ax,0c000h		;Instrument.
		jne	r25
		and	di,0fffh
		mov	[Inst+si],di
                mov     [Spec+si],0ffffh        ;Ignore special effects then.
                mov     [Specr+si],0ffffh
		jmp	short ReRead
r25:
		cmp	ax,9000h		;New level.
                jne     r26
		mov	ax,di
                and	al,003fh
		mov	[ShLevel+bx],al
		jmp	short ReRead
r26:
                cmp     ax,0b000h               ;New special effect.
                jne     r27
                and     di,0fffh
                mov     [Spec+si],di
                mov     [Specr+si],di
                jmp     short ReRead
r27:
		cmp	ax,7000h		;Vibrato.
                jne     r30
                and     di,0fffh
		mov	[ShVib+si],di
		jmp	short ReRead
r30:
		cmp	ax,0d000h		;Slide up.
		jne	r31
		and	di,0fffh
		mov	[ShSlFreq+si],di
		mov	[Tempw],di
		jmp	short ReRead
r31:
		cmp	ax,0e000h		;Slide down.
		jne	r32
		and	di,0fffh
		neg	di
		mov	[ShSlFreq+si],di
		mov	[Tempw],di
ReRead:
                inc     bp
                inc     bp
                jmp     r10
r32:
		cmp	ax,6000h		;Cut command.
		jne	DurNote
              ; mov     [Durr+si],di
              mov     [Durr+si],6000h           ;EDITOR.
		mov	byte ptr [Gate+bx],0
              add     [SeqPoi+si],2             ;EDITOR: Ign. value in "Col 2".
                jmp     Realtime
DurNote:
		mov	dx,di			;Read duration.
                mov     cl,8
                shr     di,cl
                and     di,001fh
		mov	[Durr+si],di

                mov     di,dx
                and     di,007fh
		cmp	di,007eh		;Hold (Continue).
                jz      r37
                or      di,di
                jne     r40

		mov	byte ptr [Gate+bx],0	;Rest.
r37:
		mov	byte ptr [Nog+bx],1
                jmp     Realtime
r40:
                shl     di,1
		test	dh,00100000b		;Tienote.
                jz      r45
		mov	byte ptr [Nog+bx],2
		jmp	short r50
r45:
		mov	byte ptr [Nog+bx],0
		mov	byte ptr [Gate+bx],0	;Key-off anyway.
r50:
		mov	byte ptr [ShGate+bx],20h
                test    dl,10000000b            
                jne     r55                     ;Check for locked note.
		add	di,[Transp+si]
r55:
                mov     ax,di
                mov     [ShNote+bx],al          ;Get note for PLAY drivers.
		mov	ax,[FreqTab+di]
                mov     [ShFreq+si],ax          ;Note.
		mov	ax,[Tempw]
		mov	[ShSlFreq+si],ax
                mov     [ShSlReal+si],0

		mov	byte ptr [Vspeed+bx],0	;Clear vibrato.
                mov     [Vfreq+si],0

                cmp     byte ptr [Nog+bx],0
                jne     r60
                cmp     [HardTimer+bx],0
                jz      r60
                mov     al,[Carrier+bx]         ;Hard restart wanted.
                add     al,80h
                mov     ah,[HardRel+bx]
                call    Sound                   ;New Sustain/Release.
r60:
		jmp	RealTime
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetAll:
              mov     es,[InstrSeg]             ;EDITOR.

                mov     [HardRst+bx],0          ;Flag, okay to call ReadTrack.

		mov	ax,[Durr+si]		;Set duration.
                and     ax,0fffh
		mov	[Dur+si],ax
                xor     bp,bp
		cmp	[Durr+si],6000h 	;Check for cut command.
                jb      se00
                jmp     se05
se00:
		mov	ax,[ShVib+si]
		cmp	ax,1000h		;Tiable vibrato.
                jz      se03

		mov	[Vspeed+bx],al		;Initialize vibrato.
		mov	[Vwidth+bx],ah
                shr     ah,1
		mov	[Vwid+bx],ah
		mov	[ShVib+si],1000h
                mov     [Vfreq+si],0
se03:
		mov	al,[ShLevel+bx]
		mov	[Level3+bx],al
		mov	ax,[ShSlFreq+si]
		mov	[SlFreq+si],ax		;Shadow regs/NOG handler.
                mov     ax,[ShSlReal+si]
                mov     [SlReal+si],ax
		cmp	byte ptr [Nog+bx],1
		jz	r60
		mov	ax,[ShFreq+si]
		mov	[Freq+si],ax
                mov     al,[ShNote+bx]
                mov     [Note+bx],al
		cmp	byte ptr [Nog+bx],2
                jz      r60
		mov	al,[ShGate+bx]
		mov	[Gate+bx],al
KeySetAll:
                mov     ax,[Specr+si]           ;Reset the SpFX pointer.
                mov     [Spec+si],ax

	      ; cmp	[ShVib+si],0
              ; jz      se04
	      ; mov	[ShVib+si],0
	      ; mov	byte ptr [Vspeed+bx],0	;Clear vibrato.
              ; mov     [Vfreq+si],0
se04:
                mov     ch,1                    ;Make sure ADLevel IS set.

                mov     bp,[Spec+si]            ;Check if special effects ON.
                cmp     bp,-1
                jz      se041
SetAgain:
                shl     bp,1
                shl     bp,1
                shl     bp,1
                mov     di,[Eoffset+si]
                add     bp,[es:GeneralPtr+(04h*2)+di]
                add     bp,di
                mov     al,[es:bp+2]
                mov     [SpArp+bx],al
                mov     al,[es:bp+3]
                mov     [SpModLevel+bx],al      ;Initialize SpFX variables.
                mov     al,[es:bp+4]
                mov     [SpModAdd+bx],al
                mov     al,[es:bp+5]
                inc     al
                or      al,al
                jne     se040
                mov     al,-1
se040:          mov     [SpDur+bx],al
                mov     [SpRaw+bx],0
                mov     bp,[es:bp]              ;Get instrument from there.
                test    bp,8000h
                jz      se042
                and     bp,7fffh
                mov     [SpRaw+bx],1
                jmp     short se042
se041:
		mov	bp,[Inst+si]		;Get instrument nr.
se042:
                shl     bp,1
                shl     bp,1
                shl     bp,1
                shl     bp,1
se05:
		mov	di,[Eoffset+si]
                add     bp,[es:GeneralPtr+(02h*2)+di]
                add     bp,di

		mov	al,[es:bp+7]		;Modulator KSL/Level.
                cmp     [Spec+si],0ffffh
                jz      se058
                mov     ah,al
                and     ah,11000000b            ;Mask out KSL.
                cmp     [SpModLevel+bx],0ffh
                jz      se056
                or      ah,[SpModLevel+bx]      ;New SpFX level wanted, set it.
                mov     al,ah
                jmp     short se058

se056:          cmp     ch,1                    ;First time it MUST be set.
                jne     se059
se058:
                mov     [AdLevel+bx],al         
se059:
                mov     al,[Carrier+bx]
		add	al,60h				
                mov     ah,[es:bp]
		call	Sound			;Carrier Attack/Decay.
		mov	al,[Carrier+bx]
		add	al,80h
                mov     ah,[es:bp+1]
		call	Sound			;Carrier Sustain/Release.

		mov	al,[es:bp+2]		;Carrier KSL/Level.
		mov	[KsLevel+bx],al

		mov	al,[Carrier+bx]
		add	al,20h
                mov     ah,[es:bp+3]
		call	Sound			;Carrier Am/Vib/EG/KSR/Multiple.
		mov	al,[Carrier+bx]
		add	al,0e0h
                mov     ah,[es:bp+4]
		call	Sound			;Carrier Waveform.

		mov	al,[Modulator+bx]
		add	al,60h				
                mov     ah,[es:bp+5]
		call	Sound			;Modulator Attack/Decay.
		mov	al,[Modulator+bx]
		add	al,80h
                mov     ah,[es:bp+6]
		call	Sound			;Modulator Sustain/Release.

		mov	al,[Modulator+bx]
		add	al,20h
                mov     ah,[es:bp+8]
		call	Sound			;Modulator Am/Vib/EG/KSR/Mult.
		mov	al,[Modulator+bx]
		add	al,0e0h
                mov     ah,[es:bp+9]
		call	Sound			;Modulator Waveform.

                mov     al,[es:bp+10]
		mov	[FeedCon+bx],al 	;Voice Feedback/Connection.

                mov     al,[es:bp+11]
                mov     [FineTune+bx],al        ;Frequency finetune.

                mov     al,[es:bp+12]
                mov     [HardTimer+bx],al       ;Hard restart frame value.

                mov     al,[es:bp+13]
                mov     [HardRel+bx],al         ;Hard restart, Sustain/Release.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RealTime:

SpecialFX:
                cmp     [Spec+si],0ffffh        ;Is SpFX running?
                jz      Slide

                mov     ch,[ADLevel+bx]
                mov     cl,ch
                and     ch,11000000b            ;Mask out KSL.
                and     cl,00111111b
                add     cl,[SpModAdd+bx]
                and     cl,3fh
                or      cl,ch
                mov     [ADLevel+bx],cl         ;Set modulator level.

                cmp     [SpRaw+bx],0
                jz      spf08
                mov     al,[SpArp+bx]           ;Locked arpeggio values.
                shl     al,1
                jmp     short spf09
spf08:
                mov     al,[Note+bx]
                mov     cl,[SpArp+bx]
                shl     cl,1
                add     al,cl                   ;Add arpeggio to the note.
spf09:          xor     ah,ah
                mov     di,ax
                mov     ax,[FreqTab+di]
                mov     [Freq+si],ax

                cmp     [SpDur+bx],0
                jne     spf10

              mov     es,[InstrSeg]             ;EDITOR.

                mov     bp,[Spec+si]
                shl     bp,1                    ;Point to current SpFX set.
                shl     bp,1
                shl     bp,1
                mov     di,[Eoffset+si]
                add     bp,[es:GeneralPtr+(04h*2)+di]
                add     bp,di

                mov     bp,[es:bp+6]            ;New SPEC pointer.
                mov     [Spec+si],bp

                xor     ch,ch                   ;Don't set it if not needed.
                jmp     SetAgain
spf10:
                dec     [SpDur+bx]
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Slide:
		mov	ax,[SlFreq+si]
                cmp     [Spec+si],0ffffh        ;Is SpFX running?
                jz      sl20
                add     [SlReal+si],ax
                mov     ax,[SlReal+si]
sl20:
                add     [Freq+si],ax
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Vibrato:
                xor     ch,ch
                mov     cl,[Vspeed+bx]

		cmp	byte ptr [Vwid+bx],0
                jl      v40

		dec	[Vwid+bx]
                jg      v50
		mov	al,[Vwidth+bx]
                neg     al
		mov	[Vwid+bx],al
                jmp     short v50
v40:
                dec     cx
                not     cx
		inc	[Vwid+bx]
                jne     v50
		mov	al,[Vwidth+bx]
		mov	[Vwid+bx],al
v50:
                cmp     [Spec+si],0ffffh        ;Is SpFX running?
                jz      v60
                add     [Vfreq+si],cx
                mov     cx,[Vfreq+si]
v60:
                add     [Freq+si],cx
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LevelHandler:
                mov     dh,40h

                mov     dl,dh
                sub     dl,[Level3+bx]          ;Volume from 9000h command.
                mov     al,dh
                sub     al,[Level2+bx]          ;Volume in TPOIN list.
                mul     dl
                div     dh

                or      al,al
                jne     le10
                inc     al
le10:
                mov     cl,[MvolLo]
                cmp     bl,[MvolLine]
                jb      le20
                mov     cl,[MvolHi]             ;Main volume via divide option.
le20:
                mov     dl,dh
                sub     dl,cl
                mul     dl
                div     dh

                or      al,al
                jne     le30
                inc     al
le30:
                mov     [Levels+bx],al          ;All three volumes together.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetSound:
                mov     dh,40h
                mov     ch,[KsLevel+bx]
                mov     cl,ch
                and     ch,11000000b            ;Mask out KSL.
                and     cl,00111111b
                mov     al,dh
                sub     al,cl
                mul     [Levels+bx]             ;Calculate proper level.
                div     dh
                or      al,al
                jne     se10
                inc     al
se10:           sub     dh,al
                or      ch,dh
                mov     ah,ch

                mov     al,[Carrier+bx]
                add     al,40h
		call	Sound			;Carrier KSL/Level.

                mov     ah,[AdLevel+bx]
                test    byte ptr [FeedCon+bx],1 ;Additive connection?
                jz      se20

                mov     dh,40h
                mov     ch,ah
                mov     cl,ah
                and     ch,11000000b            ;Mask out KSL.
                and     cl,00111111b
                mov     al,dh
                sub     al,cl
                mul     [Levels+bx]             ;Calculate proper level.
                div     dh
                or      al,al
                jne     se15
                inc     al
se15:           sub     dh,al
                or      ch,dh
                mov     ah,ch
se20:
		mov	al,[Modulator+bx]
                add     al,40h
                call    Sound                   ;Modulator KSL/Level.

                mov     al,bl
                add     al,0c0h
		mov	ah,[FeedCon+bx]
		call	Sound			;Voice Feedback/Connection.

                mov     cx,[Freq+si]
                mov     al,[FineTune+bx]
                cbw                             ;Finetune the frequency.
                add     cx,ax
                mov     ah,cl
                mov     al,bl
                add     al,0a0h
		call	Sound			;Lo freq.
                mov     ah,ch
                add     ah,[Gate+bx]            ;Key-on.
                mov     al,bl
                add     al,0b0h
		call	Sound			;Key-on/Block/Hi freq.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Next:
                inc     si
                inc     si
                inc     bx
                cmp     bx,9
		jz	n20
		jmp	m10
n20:
                pop     es ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ







ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
StopVoice:
                push    bx
                xor     bh,bh
		mov	cl,[Carrier+di]
		mov	ch,[Modulator+di]

                xor     ah,ah

                mov     al,cl                   ;Zero Am/Vib/EG/KSR/Multiple.
                add     al,20h
		call	Sound2
                mov     al,ch
                add     al,20h
		call	Sound2

                mov     al,cl                   ;Zero Waveform.
                add     al,0e0h
		call	Sound2
                mov     al,ch
                add     al,0e0h
		call	Sound2

                mov     ax,di                   ;Zero KEY-ON and FREQ.
                add     al,0a0h
		call	Sound2
                mov     ax,di
                add     al,0b0h
		call	Sound2

                mov     ax,di                   ;Zero FEEDBACK.
                add     al,0c0h
		call	Sound2

                mov     ah,3fh                  ;Minimum volumen.
                mov     al,cl
                add     al,40h
		call	Sound2
                mov     al,ch
                add     al,40h
		call	Sound2

                mov     ah,0ffh                 ;Fix ADSR too.
                mov     al,cl
                add     al,60h
		call	Sound2
                mov     al,cl
                add     al,80h
		call	Sound2
                mov     al,ch
                add     al,60h
		call	Sound2
                mov     al,ch
                add     al,80h
		call	Sound2
                pop     bx
                retn
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Sound2:
                mov     bl,al
		mov	[OldReg+bx],ah
		jmp	short Sound3
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Sound:
                push    bx
                mov     bl,al
		cmp	ah,[OldReg+bx]
                jne     sou10
                pop     bx
                retn
sou10:		mov	[OldReg+bx],ah
                pop     bx
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Sound3:
                mov     dx,388h
		out	dx,al

                rept    6
                in      al,dx
                endm

                inc     dx
		mov	al,ah
		out	dx,al

                rept    35
                in      al,dx
                endm

                retn
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Scan:                                           ;Adlib card detection routine.
                cli
                mov     ax,6004h                ;Stop timers (MUST include!).
		call	Sound3
                mov     ax,8004h                ;Reset status register.
		call	Sound3

                dec     dx                      ;Remember the old value.
                in      al,dx
                mov     bl,al

                mov     ax,0ff02h               ;Start timer 1.
		call	Sound3
                mov     ax,2104h
		call	Sound3

                dec     dx
                mov     cx,200h                 ;Wait for timer to move.
sca20:          in      al,dx
                loop    sca20

                and     al,0e0h                 ;Check it all out.
                xor     al,0c0h
		jnz	NoCard
                and     bl,0e0h
		jnz	NoCard

                mov     ax,6004h                ;Stop timers.
		call	Sound3
                clc
                jmp     short sca40
NoCard:
                stc
sca40:          pop     es ds
                sti
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Volume:
                and     bx,3f3fh
                mov     [MvolLo],bl             ;Set new main volumes for both
                mov     [MvolHi],bh             ;sides of MvolLine boundaries.


                mov     [MvolLine],cl           ;Sets the dividing line.

                                                ;F.ex. 04h = voices 0-3 / 4-8.
                pop     es ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Pause:
                cld
                mov     cx,(Carrier-Tempw)
                push    ds
                pop     es

                or      bl,bl                   ;Break or Continue?
                jz      pa50

                lea     si,BreakBuffer          ;Continue, now go on with it.
                lea     di,Tempw
                rep     movsb

                mov     cx,9                    ;Fix VoicOn flags.
                lea     si,BreakVoicOn
                lea     di,VoicOn
                rep     movsb

                xor     di,di
pa30:           call    StopVoice               ;Now clear the AdLib card.
                inc     di
                cmp     di,9
                jne     pa30

                mov     bx,20h                  ;All reg values into AdLib!
                mov     cx,16h
                call    OldBack

                mov     bx,40h
                mov     cx,16h
                call    OldBack

                mov     bx,60h
                mov     cx,16h
                call    OldBack

                mov     bx,80h
                mov     cx,16h
                call    OldBack

                mov     bx,0a0h
                mov     cx,9
                call    OldBack

                mov     bx,0b0h
                mov     cx,9
                call    OldBack

                mov     bx,0c0h
                mov     cx,9
                call    OldBack

                mov     bx,0e0h
                mov     cx,6
                call    OldBack

                jmp     short pa90
pa50:
                lea     si,Tempw                ;Break, remember this point.
                lea     di,BreakBuffer
                rep     movsb

                mov     cx,9                    ;Remember VoicOn flags too.
                lea     si,VoicOn
                lea     di,BreakVoicOn
                rep     movsb
pa90:
                pop     es ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
OldBack:

ol30:           mov     ah,[OldReg+bx]
                mov     al,bl
                call    Sound3
                inc     bx
                loop    ol30
                retn
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Busy:
		cmp	bx,[DivLine]		;First or second segment.
                jae     bu05

                mov     es,[FirstSeg]           ;See if a NUMBER is still busy.
		mov	si,[FirstOffset]
                jmp     short bu10
bu05:
                sub     bx,[DivLine]

		mov	es,[SecondSeg]
		mov	si,[SecondOffset]
bu10:
		mov	cl,5
		shl	bx,cl
                add     bx,[es:GeneralPtr+si]
                add     bx,si

                xor     si,si
                mov     di,si
bu20:
                cmp     word ptr [es:bx+si],0   ;Is this voice used by NUMBER?
                jz      bu30
                cmp     [VoicOn+di],0
                jne     bu40
bu30:
                inc     si
                inc     si
                inc     di
                cmp     di,9
                jne     bu20

                clc                             ;CF=0 = NUMBER has stopped.
                jmp     short bu50
bu40:
                stc                             ;CF=1 = No, it is still running.
bu50:
                pop     es ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Number:
              ; cmp     bx,[DivLine]            ;First or second segment.
              ; jae     nu05

              ; mov     es,[FirstSeg]
              ; mov     si,[FirstOffset]
              ; jmp     short nu10
nu05:
              ; sub     bx,[DivLine]

              ; mov     es,[SecondSeg]
              ; mov     si,[SecondOffset]

              mov     es,[InstrSeg]             ;EDITOR: Point to DATA segment.
              xor     si,si
nu10:
                mov     [TempSeg],es
                mov     [TempOffset],si

		mov	cl,5
		shl	bx,cl
                add     bx,[es:GeneralPtr+si]
                add     bx,si

                xor     si,si

              mov     bp,4                      ;EDITOR: Start by SPEED value.
nu20:
                cmp     word ptr [es:bx+si],0
                jne     nu22
                jmp     nu30
nu22:           mov     di,si
                shr     di,1
		cmp	[VoicOn+di],2		;No interruption please.
                jne     nu23
                jmp     nu30
nu23:
                mov     ax,[TempSeg]            ;Point voice to right segment.
                mov     [Eseg+si],ax
                mov     ax,[TempOffset]
                mov     [Eoffset+si],ax

              ; mov     di,[es:bx+si]
              ; add     di,[TempOffset]
              ; mov     ax,[es:di]
              ; inc     di
              ; inc     di
              ; mov     [TrackPointer+si],di

              push    es                        ;EDITOR.
              mov     es,[TrackSeg]
              mov     ax,[es:bp-2]              ;Load speed at the word before.
              pop     es
              mov     dx,bp
              add     dx,[SPtrack+si]           ;StartPoint offset.
              mov     [TrackPointer+si],dx

                mov     di,si
		shr	di,1
		mov	[Spedr+di],al
		mov	[VoicOn+di],1
                mov     al,[es:bx+di+18]
		test	al,01000000b		;Test for PLAY-OUT priority.
                jz      nu25
		inc	[VoicOn+di]
nu25:           and     al,3fh
		mov	[Level2+di],al

              mov     ax,[SPseq+si]
              add     ax,2                      ;EDITOR: Skip a word in seq's.
              mov     [SeqPoi+si],ax

              ; mov     [SeqPoi+si],0           ;Clear variables.
		mov	[TrackPoi+si],0

                cmp     byte ptr [es:bx+di+18],80h      
		jae	nu30			;Check for TIE-SFX flag.

		mov	byte ptr [Speed+di],0
                mov     [Dur+si],0
                mov     [Durr+si],0
                mov     [SlFreq+si],0
		mov	byte ptr [Level3+di],0
		mov	byte ptr [ShLevel+di],0
                mov     [ShVib+si],0

		call	StopVoice
nu30:
              add     bp,[TrackAdd]             ;EDITOR: Add with track sizes.

                inc     si
                inc     si
                cmp     si,18
                jz      nu40
                jmp     nu20
nu40:
              mov     [KeyMode],0               ;EDITOR: Turn off keyboard play.

                pop     es ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Switch:
		cmp	bx,[DivLine]		;First or second segment.
		jae	sw05

		mov	es,[FirstSeg]
		mov	si,[FirstOffset]
                jmp     short sw10
sw05:
                sub     bx,[DivLine]

		mov	es,[SecondSeg]
		mov	si,[SecondOffset]
sw10:
		mov	cl,5
		shl	bx,cl
                add     bx,[es:GeneralPtr+si]
                add     bx,si

                xor     si,si
                mov     di,si
sw20:
                cmp     word ptr [es:bx+si],0
		jz	sw30
		cmp	byte ptr [VoicOn+di],1
		jz	SwOff
		mov	byte ptr [VoicOn+di],1
		jmp	short sw30
SwOff:
		mov	byte ptr [VoicOn+di],0
		call	StopVoice
sw30:
                inc     si
		inc	si
                inc     di
                cmp     di,9
		jne	sw20
                pop     es ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init:
              ; mov     [FirstSeg],bx
              ; mov     [FirstOffset],cx
              ; mov     [SecondSeg],es
              ; mov     [SecondOffset],di

              mov     [InstrSeg],bx             ;EDITOR: Specialized variables.
              mov     [TrackSeg],cx
              mov     [SeqSeg],dx
              mov     [SeqAdd],bp
              mov     [TrackAdd],di

              ; mov     es,bx                   ;Fetch dividing line SFX #.
              ; mov     si,cx
              ; mov     al,[es:9+si]
              ; xor     ah,ah
              ; mov     [DivLine],ax
cl10:
                mov     byte ptr [MvolLo],0
                mov     byte ptr [MvolHi],0
                mov     byte ptr [MvolLine],0

                xor     di,di
cl30:
		call	StopVoice		;Fix certain clearings.
		mov	[VoicOn+di],0
                inc     di
                cmp     di,9
                jne     cl30

		mov	cx,ClearArea		;Clear all other variables.

              lea     di,Dur                    ;EDITOR: Previously INST.

                mov     ax,cs
                mov     es,ax
                xor     al,al
                cld
                rep     stosb

                mov     ax,-1                   ;Fill Spec with 0ffffh values.
                lea     di,Spec
                mov     cx,18                   ;Also fills Specr.
                rep     stosw

		mov	al,01h		
                mov     ah,00100000b            ;Clear testbyte.
		call	Sound3
		mov	al,08h
                mov     ah,00000000b            ;CSM=0/SEL=0.
		call	Sound3
		mov	al,0bdh
                mov     ah,11000000b            ;All depths at max, no rhytm.
		call	Sound3
cl40:           pop     es ds
                clc
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetSP:                                          ;EDITOR: Set STARTPOINT.

              shl     di,1                      ;Word-wise.
              mov     [SPseq+di],bx
              mov     [SPtrack+di],dx           ;Tune-offset, one voice a time.
ss20:
              pop     es ds
              retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function:
                push    ds es cs
                pop     ds

                cmp     ah,0ah                  ;EDITOR: More than usual.
                jg      cl40
                shl     ah,1
                mov     al,ah
                xor     ah,ah
                mov     si,ax
                jmp     JumpTab[si]
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Key:                                            ;EDITOR: Play from keyboard.
              ;BL=Note (00h-5Fh).
              ;BH=Bit 5=Key ON or OFF.
              ;CL=Level (00h-3Fh).
              ;CH=Voice (0-8).
              ;BP=Instrument.
              ;   Bit 7=Use SpFx instead if ON.

              cmp     [KeyMode],1
              jz      ke08

              push    bx cx bp

              xor     di,di
ke02:
              call    StopVoice                 ;Fix certain clearings.
              mov     [VoicOn+di],0
              inc     di
              cmp     di,9
              jne     ke02

              mov     cx,ClearArea              ;Clear all other variables.

              lea     di,Dur                    ;EDITOR: Previously INST.

              mov     ax,cs
              mov     es,ax
              xor     al,al
              cld
              rep     stosb

              mov     ax,-1                     ;Fill Spec with 0ffffh values.
              lea     di,Spec
              mov     cx,18                     ;Also fills Specr.
              rep     stosw

              pop     bp cx bx

              mov     [KeyMode],1
ke08:
              mov     al,bl
              mov     ah,bh

              mov     bl,ch                     ;Get voice in byte and word.
              xor     bh,bh
              mov     si,bx
              shl     si,1

              and     ah,20h                    ;Key ON or OFF.
              cmp     byte ptr [Gate+bx],ah
              jz      ss20
              mov     byte ptr [Gate+bx],ah

              or      ah,ah                     ;Was it a key OFF?
              jne     ke10
              jmp     RealTime
ke10:
              test    bp,8000h                  ;SpFx wanted?
              jz      ke11
              and     bp,7fffh
              mov     [Specr+si],bp
              jmp     short ke12
ke11:
              mov     [Specr+si],0ffffh
              mov     [Inst+si],bp              ;Instrument.
ke12:
              mov     [Vspeed+bx],0             ;Clear vibrato.
              mov     [Vfreq+si],0

              mov     byte ptr [Level3+bx],cl
              mov     byte ptr [Level2+bx],0

              shl     al,1
              mov     [Note+bx],al
              xor     ah,ah
              mov     di,ax                     ;Note.
              mov     ax,[FreqTab+di]
              mov     [Freq+si],ax
              mov     [ShFreq+si],ax

              mov     di,bx
              call    StopVoice

              mov     es,[InstrSeg]
              mov     [Eseg+si],es
              mov     [Eoffset+si],0

              jmp     KeySetAll
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VibKey:                                         ;EDITOR: Enable vibrato.
              ;DX=Vibrato value.
              ;CH=Voice (0-8).
              ;CL=Vibrato ON/OFF - 00h is OFF.

              mov     bl,ch
              xor     bh,bh
              mov     si,bx
              shl     si,1

              or      cl,cl                     ;Vibrato ON or OFF?
              jne     vk15

              mov     [Vspeed+bx],0             ;Vibrato OFF.
              mov     [Vfreq+si],0

              mov     ax,[ShFreq+si]            ;Straighten up the note again.
              mov     [Freq+si],ax

              jmp     short vk20
vk15:
              cmp     [Vspeed+bx],0
              jne     vk20

              and     dh,0fh                    ;Vibrato ON.
              mov     [Vspeed+bx],dl
              mov     [Vwidth+bx],dh
              shr     dh,1
              mov     [Vwid+bx],dh
              mov     [Vfreq+si],0
vk20:
              pop     es ds
              retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
JumpTab         dw      Init    ;00h MAIN RESET
                dw      cl10    ;01h RESET
                dw      Number  ;02h START
                dw      Main    ;03h PLAY
                dw      Switch  ;04h TOGGLE
                dw      Volume  ;05h MAINVOL (Using a cut for voice excluding.)
                dw      Scan    ;06h SCAN
              ; dw      Pause   ;07h BREAK/CONTINUE (Not used in EDITOR anyway)
              dw      SetSP     ;07h SET STARTPOINT (For EDITOR)
                dw      Busy    ;08h REQUEST (See if a SFX has ended.)
              dw      Key       ;09h PLAY NOTE FROM KEYBOARD
              dw      VibKey    ;0ah ENABLE VIBRATO WHEN USING KEYBOARD PLAY
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InstrSeg        dw      0
TrackSeg        dw      0                       ;EDITOR specific variables (INST
SeqSeg          dw      0                       ;has been moved only) - may NOT
SeqAdd          dw      0                       ;be cleared in the INIT routine.
TrackAdd        dw      0

SPseq           dw      0,0,0,0,0,0,0,0,0
SPtrack         dw      0,0,0,0,0,0,0,0,0
Inst            dw      0,0,0,0,0,0,0,0,0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Tempw		dw	0
FirstSeg        dw      0       ;If you mess around in these variables then do
FirstOffset     dw      0       ;remember to adjust the CLEAR settings !!
SecondSeg       dw      0
SecondOffset    dw      0
TempSeg         dw      0
TempOffset      dw      0
DivLine         dw      0
MvolLo          db      0
MvolHi          db      0
MvolLine        db      0

Spec            dw      0,0,0,0,0,0,0,0,0       ;Keep "Specr" after "Spec".
Specr           dw      0,0,0,0,0,0,0,0,0

Dur		dw	0,0,0,0,0,0,0,0,0
Durr		dw	0,0,0,0,0,0,0,0,0
SeqPoi		dw	0,0,0,0,0,0,0,0,0
TrackPoi	dw	0,0,0,0,0,0,0,0,0
TrackPointer	dw	0,0,0,0,0,0,0,0,0
Freq		dw	0,0,0,0,0,0,0,0,0
Transp		dw	0,0,0,0,0,0,0,0,0
SlFreq		dw	0,0,0,0,0,0,0,0,0
SlReal          dw      0,0,0,0,0,0,0,0,0

Eseg            dw      0,0,0,0,0,0,0,0,0
Eoffset         dw      0,0,0,0,0,0,0,0,0

Note		db	0,0,0,0,0,0,0,0,0
ShNote          db      0,0,0,0,0,0,0,0,0

SpArp           db      0,0,0,0,0,0,0,0,0
SpModLevel      db      0,0,0,0,0,0,0,0,0
SpModAdd        db      0,0,0,0,0,0,0,0,0
SpDur           db      0,0,0,0,0,0,0,0,0
SpRaw           db      0,0,0,0,0,0,0,0,0

Vwid		db	0,0,0,0,0,0,0,0,0
Vwidth		db	0,0,0,0,0,0,0,0,0
Vspeed		db	0,0,0,0,0,0,0,0,0
Vfreq           dw      0,0,0,0,0,0,0,0,0

FineTune        db      0,0,0,0,0,0,0,0,0

HardRst         db      0,0,0,0,0,0,0,0,0
HardTimer       db      0,0,0,0,0,0,0,0,0
HardRel         db      0,0,0,0,0,0,0,0,0

ShVib		dw	0,0,0,0,0,0,0,0,0
ShSlFreq	dw	0,0,0,0,0,0,0,0,0
ShSlReal        dw      0,0,0,0,0,0,0,0,0
ShFreq		dw	0,0,0,0,0,0,0,0,0
ShLevel 	db	0,0,0,0,0,0,0,0,0

Speed		db	0,0,0,0,0,0,0,0,0
Spedr		db	0,0,0,0,0,0,0,0,0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
OldReg          label   byte                    ;Used for the register bypassing
Gate		db	0,0,0,0,0,0,0,0,0
ShGate		db	0,0,0,0,0,0,0,0,0
Level2		db	0,0,0,0,0,0,0,0,0
                db      0,0,0,0,0               ;Free
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Resv. 20-35
Level3		db	0,0,0,0,0,0,0,0,0
                db      0                       ;Free
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Resv. 40-55
KsLevel 	db	0,0,0,0,0,0,0,0,0
                db      0                       ;Free
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Resv. 60-75
AdLevel 	db	0,0,0,0,0,0,0,0,0
                db      0                       ;Free
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Resv. 80-95
FeedCon 	db	0,0,0,0,0,0,0,0,0
KeyMode         db      0                       ;EDITOR.
                db      0,0,0,0,0,0,0,0,0       ;Reserved A0-A8
                db      0,0,0,0,0,0,0           ;Free
                db      0,0,0,0,0,0,0,0,0       ;Reserved B0-B8
                db      0,0,0,0,0,0,0           ;Free
                db      0,0,0,0,0,0,0,0,0       ;Reserved C0-C8
Levels		db	0,0,0,0,0,0,0,0,0
Nog		db	0,0,0,0,0,0,0,0,0
                db      0,0,0,0,0               ;Free
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Resv. E0-F5
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Carrier 	db	03h,04h,05h,0bh,0ch,0dh,13h,14h,15h
Modulator	db	00h,01h,02h,08h,09h,0ah,10h,11h,12h

FreqTab 	dw	343,363,385,408,432,458
		dw	485,514,544,577,611,647

		dw	343+0400h,363+0400h,385+0400h
		dw	408+0400h,432+0400h,458+0400h
		dw	485+0400h,514+0400h,544+0400h
		dw	577+0400h,611+0400h,647+0400h

		dw	343+0800h,363+0800h,385+0800h
		dw	408+0800h,432+0800h,458+0800h
		dw	485+0800h,514+0800h,544+0800h
		dw	577+0800h,611+0800h,647+0800h

		dw	343+0c00h,363+0c00h,385+0c00h
		dw	408+0c00h,432+0c00h,458+0c00h
		dw	485+0c00h,514+0c00h,544+0c00h
		dw	577+0c00h,611+0c00h,647+0c00h

		dw	343+1000h,363+1000h,385+1000h
		dw	408+1000h,432+1000h,458+1000h
		dw	485+1000h,514+1000h,544+1000h
		dw	577+1000h,611+1000h,647+1000h

		dw	343+1400h,363+1400h,385+1400h
		dw	408+1400h,432+1400h,458+1400h
		dw	485+1400h,514+1400h,544+1400h
		dw	577+1400h,611+1400h,647+1400h

		dw	343+1800h,363+1800h,385+1800h
		dw	408+1800h,432+1800h,458+1800h
		dw	485+1800h,514+1800h,544+1800h
		dw	577+1800h,611+1800h,647+1800h

		dw	343+1c00h,363+1c00h,385+1c00h
		dw	408+1c00h,432+1c00h,458+1c00h
		dw	485+1c00h,514+1c00h,544+1c00h
		dw	577+1c00h,611+1c00h,647+1c00h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BreakBuffer     db      (Carrier-Tempw) dup (0)

BreakVoicOn     db      0,0,0,0,0,0,0,0,0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                endp
                ends
                end
