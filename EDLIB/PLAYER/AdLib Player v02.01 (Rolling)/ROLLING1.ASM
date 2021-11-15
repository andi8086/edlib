;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  Normal 9-voice ADLIB data block. Remember to alter VERSION1 and DATAINFO.  ³
;³                                                                             ³
;³  Drax's "Rolling"...                                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
tspeed          equ     2

public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
detection       db      'JCH',26h,02h,66h       ;System detection bytes
kind            db      00h                     ;00h for music data block
version1        db      02h                     ;Major music-player version
timer           db      50                      ;Timerspeed for the block
max             db      1                       ;Number of music & sfx's
card            db      00h                     ;00h for normal Adlib

blockname       db      '                                '      ;32 bytes names
composer        db      '                                '

                db      32 dup (0)              ;For future expansion...

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s1a,s1b
                dw      s1c
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin		dw	tk1,tk2,tk3,tk4,tk5,tk6,tk7,tk8,tk9
              ; db      00h,00h,00h,00h,00h,00h,00h,00h,00h
                db      00h,00h,00h,3fh,3fh,3fh,3fh,3fh,3fh
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

                db      0ffh,026h,00h,00100001b,0               ;c001   Tynde Ib
                db      0f7h,064h,10h,00100001b,1,(4*2)+0
                db      0,0,0,0,0
                tynd    equ     1

                db      0f8h,014h,02h,01000000b,0               ;c002   Cymbal
                db      0ffh,000h,02h,01000011b,2,(5*2)+0
                db      0,0,2,0,0
                cymbal  equ     2
                bb      equ     24h

                db      0ffh,007h,00h,00100110b,0               ;c003   Bassdr
                db      0d9h,064h,0ah,00100001b,0,(5*2)+0
                db      0,0,1,0,0
                bassdr  equ     3
                gg      equ     20

                db      08fh,005h,02h,00100001b,0               ;c004   Bass
                db      0ffh,024h,00h,00000000b,2,(1*2)+0
                db      0,0,0,0,0
                bass    equ     4

                db      096h,025h,00h,00100000b,1               ;c005   Chord
                db      0ffh,003h,0ch,00100001b,1,(0*2)+0
                db      0,0,0,0,0
                ch0     equ     5
                ch05    equ     5
                ch04a   equ     5
                ch049   equ     5
                ch038   equ     5
                ch059   equ     5
                ch047a  equ     5
                ch0359  equ     5
                ch047a  equ     5

                db      0fah,026h,00h,00100000b,1               ;c006   Leader
                db      0ffh,001h,08h,00000001b,1,(1*2)+0
                db      0,0,0,0,0
                leader  equ     6

                db      096h,025h,04h,00100001b,1               ;c007   Ringmod
		db	0ffh,000h,00h,00100000b,1,(2*2)+0
		db	1,3,0,0,0
                ringmod equ     7

                db      0f6h,056h,00h,00100000b,0               ;c008   Snare
                db      0ffh,000h,01h,00100010b,2,(5*2)+0
                db      0,0,2,0,0
                snare   equ     8
                ddd     equ     20
                xx      equ     24h

              ; db      0f8h,026h,00h,00100110b,0               ;c008   Snare
              ; db      0ffh,002h,00h,00100010b,0,(6*2)+0
              ; db      0,0,2,0,0
              ; snare   equ     8       God tromme, men ikke her.
              ; ddd     equ     16
              ; xx      equ     09h

                db      0fah,017h,00h,01100010b,0               ;c009   "Khlok"
                db      07fh,00fh,00h,01100011b,2,(5*2)+0
                db      0,0,2,0,0
                khlok   equ     9
                kk      equ     30h
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
                dw      800ch,0001h,800ch,0003h,0009h,000ah,000bh,000ch
                dw      0009h,000ah,000bh,000ch,000fh,0011h,000fh,0013h
                dw      0001h,0018h,0008h,0008h,0008h,001ch
                twrap   0

tk2             dw      tspeed
                dw      800ch,0002h,800ch,0004h,0005h,0005h,0005h,0005h
                dw      0005h,0005h,0005h,0005h,000dh,0010h,000dh,0012h
                dw      0002h,0004h,0015h,0017h,0015h,001ah
                twrap   0

tk3             dw      tspeed
                dw      800ch,0006h,800ch,0007h,0008h,0008h,0008h,0008h
                dw      0008h,0008h,0008h,0008h,000eh,000eh,000eh,0014h
                dw      0006h,0007h,801ch,0016h,0019h,0016h,001bh
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
s6031h  equ     404h    ;Vibrato
s6041h  equ     406h

s0003h  equ     1       ;Up
s0050h  equ     4
s0080h  equ     5
s1010h  equ     2
s1016h  equ     2
s1020h  equ     2
s1080h  equ     10

s2030h  equ     5       ;Down
s2060h  equ     7
s2130h  equ     18
s2150h  equ     22
s2200h  equ     30

s9026h  equ     12h     ;Reset
s9038h  equ     0ch
reset   equ     0
;-------------------------------------------------------------------------------
s00:
                rest 0000h
                seqend

s01:
                snd ch05
                dw      022bh
                rest 0000h
                dw      002bh
                rest 0000h
                snd Ch0
                dw      002dh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch05
                dw      022bh
                rest 0000h
                dw      002bh
                rest 0000h
                snd Ch0
                dw      002dh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch05
                dw      022bh
                rest 0000h
                dw      002bh
                rest 0000h
                snd Ch0
                dw      002dh
                rest 0002h
                snd ch05
                dw      022bh
                rest 0002h
                snd Ch0
                dw      002bh
                rest 0000h
                dw      002ch,202dh
                rest 0001h
                dw      002bh
                rest 0000h
                seqend

s02:
                snd bass
                dw      020ch
                rest 000fh
                rest 000fh
                rest 0004h
                dw      0007h
                rest 0000h
                dw      0109h
                rest 0001h
                dw      0007h
                rest 0000h
                seqend

s03:
                snd ch05
                dw      022bh
                rest 0000h
                dw      002bh
                rest 0000h
                snd Ch0
                dw      002dh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch05
                dw      022bh
                rest 0000h
                dw      002bh
                rest 0000h
                snd Ch0
                dw      002dh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch04a
                dw      0229h
                rest 0000h
                dw      0029h
                rest 0000h
                snd ch049
                dw      0229h
                rest 0000h
                snd ch038
                dw      0527h
                snd leader
                dw      002bh
                rest 0000h
                dw      032dh
                down s2130h
                cont 0000h
                dw      202bh
                seqend

s04:
                snd bass
                dw      020ch
                rest 000fh
                rest 0004h
                dw      020fh
                rest 0000h
                dw      0003h
                rest 0000h
                dw      020eh
                rest 0000h
                dw      030ch
                rest 0003h
                dw      000bh
                up s0003h
                cont 0004h
                seqend

s05:
                dw      020ch
                rest 0000h
                dw      000ch
                rest 0000h
                dw      0310h
                rest 0001h
                dw      0211h
                rest 0000h
                dw      0102h,0403h
                rest 0000h
                dw      0205h
                rest 0000h
                dw      0105h,0209h
                rest 0000h
                dw      0009h
                rest 0000h
                dw      010ah
                vib s6041h
                cont 0002h
                rest 0000h
                dw      010bh
                vib s6041h
                cont 0002h
                rest 0000h
                seqend

s06:
                snd cymbal
                dw      0080h+bb
                rest 000fh
                rest 000fh
                rest 000eh
                seqend

s07:
                snd cymbal
                dw      0080h+bb
                rest 000fh
                rest 0006h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                snd cymbal
                dw      0080h+bb
                rest 0000h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 0004h
                down    ddd
                dw      0080h+xx
                rest 0000h
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 0000h
                seqend

s08:
                snd bassdr
                down    gg
                dw      008ch
                rest 0004h
                snd ch047a
                dw      0024h
                rest 0004h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                lvl s9038h
                down    ddd
                dw      0080h+xx
                rest 0000h
                lvl reset
                snd ch047a
                dw      0024h
                rest 0004h
                snd bassdr
                down    gg
                dw      008ch
                rest 0004h
                snd ch0359
                dw      0024h
                rest 0004h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                lvl s9038h
                down    ddd
                dw      0080h+xx
                rest 0000h
                lvl reset
                snd ch0359
                dw      0024h
                rest 0002h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0000h
                seqend

s09:
                dw      002fh
                up s1020h
                cont 0004h
                dw      2030h
                cont 0001h
                vib s6041h
                cont 0008h
                down s2150h
                cont 0001h
                rest 0001h
                cut 5           ;;;
                dw      0027h
                rest 0000h
                dw      0229h
                rest 0002h
                dw      0229h
                rest 0002h
                dw      0229h
                rest 0000h
                dw      0027h
                rest 0000h
                seqend

s0a:
                up s0080h
                dw      0127h,2029h
                cont 0000h
                dw      202bh,2029h
                vib s6031h
                dw      0327h,0024h
                rest 0004h
                dw      0022h
                rest 0000h
                dw      0124h
                rest 0001h
                dw      0026h
                up s1016h
                cont 0004h
                dw      2027h
                cont 0003h
                vib s6031h
                cont 0004h
                down s2150h
                cont 0000h
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0232h
                rest 0002h
                seqend

s0b:
                dw      0032h
                up s1020h
                cont 0004h
                dw      2033h
                cont 0006h
                vib s6031h
                cont 0003h
                dw      0332h,2033h,2032h,2030h
                cont 0000h
                rest 0007h
                dw      002dh
                rest 0000h
                dw      002dh,202eh
                cont 0000h
                rest 0002h
                dw      022fh
                rest 0000h
                dw      002bh
                rest 0000h
                seqend

s0c:
                dw      002fh
                up s1020h
                cont 0004h
                dw      2030h
                cont 0003h
                vib s6041h
                cont 000fh
                cont 000dh
                rest 0000h
                snd tynd
                dw      022dh
                rest 0000h
                dw      002bh
                rest 0000h
                seqend

s0d:
                snd bass
                dw      020ch
                vib s6041h
                cont 0000h
                rest 0001h
                dw      000ch
                rest 0002h
                dw      010ch,020ch
                vib s6041h
                cont 0000h
                rest 0001h
                dw      000ch
                rest 0002h
                dw      010ch,020ch
                vib s6041h
                cont 0000h
                rest 0001h
                dw      000ch
                rest 0002h
                dw      000ch
                rest 0000h
                dw      010eh,200fh
                rest 0000h
                dw      000eh
                rest 0000h
                dw      020ch
                rest 0000h
                dw      0009h
                rest 0000h
                seqend

s0e:
                snd bassdr
                down    gg
                dw      008ch
                rest 0003h
                cut 0
                snd khlok
                dw      0080h+kk
                rest 0002h
                lvl s9026h
                dw      0080h+kk
                rest 0000h
                lvl reset
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                lvl s9038h
                down    ddd
                dw      0080h+xx
                cut 0
                lvl reset
                snd khlok
                dw      0080h+kk
                rest 0002h
                lvl s9026h
                dw      0080h+kk
                rest 0000h
                lvl reset
                snd bassdr
                down    gg
                dw      008ch
                rest 0003h
                cut 0
                snd khlok
                dw      0080h+kk
                rest 0002h
                lvl s9026h
                dw      0080h+kk
                rest 0000h
                lvl reset
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                lvl s9038h
                down    ddd
                dw      0080h+xx
                cut 0000h
                lvl reset
                snd khlok
                dw      0080h+kk
                rest 0002h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0000h
                seqend

s0f:
                snd ch038
                dw      0127h
                rest 0007h
                dw      0127h
                rest 0005h
                dw      0127h
                rest 0009h
                dw      0027h
                rest 0004h
                snd ch04a
                dw      0929h
                rest 0001h
                seqend

s10:
                snd bass
                dw      020ch
                vib s6041h
                cont 0000h
                rest 0001h
                dw      000ch
                rest 0002h
                dw      010ch,020ch
                vib s6041h
                cont 0000h
                rest 0001h
                dw      000ch
                rest 0002h
                dw      010ch,020ch
                vib s6041h
                cont 0000h
                rest 0001h
                dw      000ch
                rest 0002h
                dw      000ch
                rest 0000h
                dw      010fh,010eh,010ch,010eh,200fh
                cont 0000h
                dw      010eh
                seqend

s11:
                snd ch038
                dw      0127h
                rest 0007h
                dw      0127h
                rest 0005h
                dw      0127h
                rest 0009h
                dw      0027h
                rest 0004h
                snd ch059
                dw      0924h
                rest 0001h
                seqend

s12:
                snd bass
                dw      0205h
                rest 0000h
                dw      0209h
                rest 0000h
                dw      010ch
                rest 0001h
                dw      0207h
                rest 0000h
                dw      010bh
                rest 0001h
                dw      010eh
                rest 0001h
                dw      0a0ch
                vib s6041h
                cont 0004h
                rest 0001h
                dw      0003h
                up s1010h
                cont 0004h
                seqend

s13:
                snd ch059
                dw      0124h
                rest 0001h
                dw      0124h
                rest 0001h
                dw      0124h
                rest 0001h
                dw      0126h
                rest 0001h
                dw      0126h
                rest 0001h
                dw      0126h
                rest 0001h
                snd ch038
                dw      0f27h
                rest 0007h
                seqend

s14:
                snd bassdr
                down    gg
                dw      008ch
                rest 0003h
                cut 0
                snd khlok
                dw      0080h+kk
                rest 0002h
                lvl s9026h
                dw      0080h+kk
                rest 0000h
                lvl reset
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                lvl s9038h
                down    ddd
                dw      0080h+xx
                cut 0
                lvl reset
                snd khlok
                dw      0080h+kk
                rest 0002h
                lvl s9026h
                dw      0080h+kk
                rest 0000h
                lvl reset
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 000ah
                seqend

s15:
                snd bass
                dw      020ch
                vib s6041h
                cont 0002h
                vib s6031h
                dw      0318h,010ch
                vib s6031h
                dw      0316h,010ch,0315h,0104h,0305h
                vib s6041h
                cont 0001h
                dw      0311h,0105h,030fh,0105h,030eh,010bh
                seqend

s16:
                snd ringmod
                dw      050ch,0318h,010ch,0316h,010ch,0315h,0104h,0505h
                dw      0311h,0105h,030fh,0105h,030eh,010bh
                seqend

s17:
                snd bass
                dw      030ch
                vib s6041h
                cont 0001h
                vib s6031h
                dw      0318h,010ch
                vib s6031h
                dw      0316h,010ch,0315h,0104h,0305h,0011h
                rest 0000h
                dw      0208h
                vib s6041h
                cont 0001h
                rest 0000h
                dw      0209h
                vib s6041h
                cont 0001h
                rest 0000h
                dw      010fh
                vib s6041h
                cont 0003h
                seqend

s18:
                snd ch05
                dw      022bh
                rest 0000h
                dw      002bh
                rest 0000h
                snd Ch0
                dw      002dh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch05
                dw      022bh
                rest 0000h
                dw      002bh
                rest 0000h
                snd Ch0
                dw      002dh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch04a
                dw      0229h
                rest 0000h
                dw      0029h
                rest 0000h
                snd ch049
                dw      0229h
                rest 0000h
                snd ch038
                dw      0727h
                rest 0005h
                seqend

s19:
                snd ringmod
                dw      050ch,0318h,010ch,0316h,010ch,0315h,0104h,0305h
                dw      0011h
                rest 0000h
                dw      0008h
                up s1080h
                cont 0003h
                rest 0000h
                dw      0009h
                up s1080h
                cont 0003h
                rest 0000h
                dw      000fh
                up s1080h
                cont 0004h
                seqend

s1a:
                snd bass
                dw      030ch
                vib s6041h
                cont 0001h
                vib s6031h
                dw      0318h,010ch
                vib s6031h
                dw      0316h,010ch
                vib s6031h
                dw      0315h,0104h,0205h
                rest 0000h
                dw      020ah
                rest 0000h
                dw      020bh
                rest 0000h
                dw      040ch
                vib s6041h
                cont 0006h
                seqend

s1b:
                snd ringmod
                dw      050ch,0318h,010ch,0316h,010ch,0315h,0104h,0205h
                rest 0008h
                snd ch047a
                dw      0014h
                rest 000ah
                seqend

s1c:
                snd bassdr
                down    gg
                dw      008ch
                rest 0004h
                snd ch047a
                dw      0024h
                rest 0004h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                lvl s9038h
                down    ddd
                dw      0080h+xx
                rest 0000h
                lvl reset
                snd ch047a
                dw      0024h
                rest 0004h
                snd snare
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 0002h
                down    ddd
                dw      0080h+xx
                rest 000ah
                seqend
;-------------------------------------------------------------------------------
datainfo        db      '                              '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
