;-------------------------------------------------------------------------------
; MUSIC DATA - Player by JCH/Vibrants. Remember to alter DATAINFO and VERSION1!
;-------------------------------------------------------------------------------
; Requires player v01.12 or higher...
;-------------------------------------------------------------------------------
tspeed          equ     1

public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
version1        db      01h                     ;Major music-player version
timer           db      70                      ;Timerspeed for the block
max             db      1                       ;Number of music & sfx's

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s1a,s1b
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin		dw	tk1,tk2,tk3,tk4,tk5,tk6,tk7,tk8,tk9
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

		dw	0ffffh		;Endmark
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0001h   Carrier ADSR
; 0002h         Carrier level 00-3f + KSL 00/40/80/c0
; 0003h         Carrier AM/VIB/EG/KSR bits + multiplier in lonibble.
; 0004h         Carrier waveform 0-3
; 0005h-0009h   Modulator mirror bytes (Same as carrier)
; 000ah         Feedback/Connection (Bit 0=Modulated/Additive, bit 1-3=Feedback)
; 000bh         Pointer to LEVELPULS tabel (00h=No levelpuls choosen)
; 000ch 	LEVELPULS frameskipper byte (00h=Fastest)
; 000dh         Indicates a none-note sound (For other players - 2=Snaredrum!)
; 000eh-000fh   Unused, to align the tables to 16 bytes.
;------------------------AD---SR--LV--AVEKmult--W--F----C-----------------------
instrument      db      0ffh,0ffh,3fh,00100000b,0               ;c000   CUT!
                db      0ffh,0ffh,3fh,00100000b,0,(0*2)+0
                db      0,0,0,0,0
                empty   equ     0

                db      0ffh,026h,00h,00100001b,0               ;c001   lead2
                db      0f7h,064h,10h,00100001b,1,(4*2)+0
                db      0,0,0,0,0
                lead2   equ     1

                db      0ffh,006h,02h,00000000b,2               ;c002   Snare
                db      0ffh,003h,00h,00001010b,0,(7*2)+0
                db      0,0,2,0,0
                snare   equ     2

                db      0afh,00ch,03h,00100010b,0               ;c003   DOUH!
                db      0ffh,006h,20h,00000001b,1,(0*2)+0
                db      0,0,1,0,0
                douh    equ     3

                db      0ffh,004h,00h,00100001b,1               ;c004   Bass
                db      0ffh,000h,00h,00100001b,1,(0*2)+0
		db	4,0,0,0,0
                bass    equ     4

                db      096h,025h,00h,00100000b,2               ;c005   Chord
                db      0ffh,000h,00h,00100000b,3,(1*2)+0
		db	1,5,0,0,0
                chord   equ     5

                db      0fah,026h,00h,00100000b,1               ;c006   Leader
                db      0ffh,001h,08h,00000001b,1,(1*2)+0
                db      0,0,0,0,0
                leader  equ     6

		db	096h,025h,04h,00100001b,1		;c007	Single
		db	0ffh,000h,00h,00100000b,1,(2*2)+0
		db	1,3,0,0,0
                single  equ     7

                db      0ffh,005h,06h,01100101b,0               ;c008   MYsnare
                db      0fah,006h,02h,00100000b,2,(7*2)+1
                db      0,0,2,0,0
                snare2  equ     8
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h         Set level 00-3f (ff=Continue with last set or instr's level)
; 0001h 	Speed 00-ff (01=slow up, ff=slow down) - see also frameskipper!
; 0002h         Duration 00-ff before next set is read
; 0003h         Pointer to next set
;-------------------------------------------------------------------------------
levelpuls	db	006h,001h,000h,002h	;1
		db	0ffh,001h,02ah,003h	;2
		db	0ffh,0ffh,02ah,002h	;3

		db	008h,001h,010h,005h	;4
		db	0ffh,000h,000h,005h	;5

;-------------------------------------------------------------------------------
; Values        Comments
;-------------------------------------------------------------------------------
; -----		First position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;-------------------------------------------------------------------------------
tk1             dw      tspeed
                dw      0
                twrap   0

tk2             dw      tspeed
                dw      0
                twrap   0

tk3             dw      tspeed
                dw      0
                twrap   0

tk4             dw      tspeed
                dw      0
                twrap   0

tk5		dw	tspeed
                dw      0
		twrap	0

tk6		dw	tspeed
                dw      0
		twrap	0

tk7		dw	tspeed
                dw      0
		twrap	0

tk8             dw      tspeed
                dw      0
                twrap   0

tk9             dw      tspeed
		dw	0
                twrap   0
;-------------------------------------------------------------------------------
; Values        Macro   Comments
;-------------------------------------------------------------------------------
; 6000h-6fffh   Cut x   Cut duration 000-fff
; 7000h-7fffh   Vib x   Vibrato - 7XYYh: X=Vibrato width, YY=Vibrato speed
; 9000h-903fh   Lvl x   Levels 00-3f
; c000h-cfffh   Snd x   Instrument 000-fff
; d000h-dfffh   Up x    Slide up 000-fff
; e000h-efffh   Down x  Slide down 000-fff
; ffffh         Seqend  End of sequence
;-------------------------------------------------------------------------------;
; XXYYh         d=DUR.  Duration, note, tienote and lock-function in one word:
;
; XX: 00h-1fh     --    Normal duration 00-1f
; XX: 20h-3fh     --    Duration 00-1f with tienote on
; YY: 00h/80h   Rest d  Rest (Release)
; YY: 01h-5fh   Cz x d  Notes (C#0 and up)
; YY: 7eh       Cont d  Hold (Continue)
; YY: 81h-dfh   Lc x d  Locked notes (Ignores track transpositions)
;-------------------------------------------------------------------------------
s00:                                                            ;Cut sequence
                cut 0
                seqend

s01:                                                            ;

                seqend

s02:                                                            ;

                seqend

s03:                                                            ;

                seqend

s04:                                                            ;

                seqend

s05:                                                            ;

                seqend

s06:                                                            ;

                seqend

s07:                                                            ;

                seqend

s08:                                                            ;

                seqend

s09:                                                            ;

                seqend

s0a:                                                            ;

                seqend

s0b:                                                            ;

                seqend

s0c:                                                            ;

                seqend

s0d:                                                            ;

                seqend

s0e:                                                            ;

                seqend

s0f:                                                            ;

                seqend

s10:                                                            ;

                seqend

s11:                                                            ;

                seqend

s12:                                                            ;

                seqend

s13:                                                            ;

                seqend

s14:                                                            ;

                seqend

s15:                                                            ;

                seqend

s16:                                                            ;

                seqend

s17:                                                            ;

                seqend

s18:                                                            ;

                seqend

s19:                                                            ;

                seqend

s1a:                                                            ;

                seqend

s1b:                                                            ;

                seqend
;-------------------------------------------------------------------------------
datainfo        db      '                              '        ;Any length!
                db      '                              '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
