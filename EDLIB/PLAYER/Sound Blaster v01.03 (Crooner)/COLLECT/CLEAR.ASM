;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  Sound Blaster/8-BIT DMA smpls/data block. Remember VERSION1 and DATAINFO.  ³
;³                                                                             ³
;³  CLEAR                                                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
tspeed          equ     3

public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls,samples,maxsamp,names,loadpos

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
detection       db      'JCH',26h,02h,66h       ;System detection bytes
kind            db      80h                     ;00h for music data block
                                                ;Bit 7=Sample block needed!
version1        db      01h                     ;Major music-player version
timer           db      70                      ;Timerspeed for the block
max             db      1                       ;Number of music & sfx's
card            db      01h                     ;01h for normal Sound Blaster
                                                ;with samples in 8-BIT DMA.

blockname       db      '                                '      ;32 bytes names
composer        db      'Thomas Mogensen (DRAX)          '

                db      32 dup (0)              ;For future expansion...

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h
                dw      samples                 ;05h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s1a,s1b
                dw      s1c,s1d,s1e,s1f,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      tk1,tk2,tk3,tk4,tk5,tk6,tk7,tk8,tk9,t10
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
              ; db      3fh,3fh,3fh,3fh,3fh,00h,3fh,3fh,3fh,00h
                db      0,0

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

                db      0fdh,024h,00h,00100001b,0               ;c001   lead2
                db      0f3h,034h,00h,00100000b,2,(5*2)+0
                db      8,4,0,0,0
                lead2   equ     1

                db      0afh,005h,00h,00000010b,0               ;c002   Bass2
                db      0ffh,044h,00h,00000001b,0,(4*2)+0
                db      0,0,0,0,0
                bass2   equ     2

                db      0afh,006h,03h,00000010b,0               ;c003   DOUH!
                db      0ffh,006h,20h,00000001b,1,(0*2)+0
                db      0,0,1,0,0
                douh    equ     3

                db      09fh,005h,00h,00000001b,0               ;c004   Bass
                db      0fbh,055h,00h,00000000b,1,(4*2)+0
                db      0,0,0,0,0
                bass    equ     4

                db      0ffh,034h,04h,00000001b,0               ;c005   Chord
                db      0ffh,000h,00h,00100000b,2,(0*2)+0
		db	1,5,0,0,0
                chord   equ     5

                db      0fah,034h,00h,00100001b,0               ;c006   Leader
                db      0ffh,000h,00h,00000001b,1,(1*2)+0
                db      4,3,0,0,0
                leader  equ     6

                db      0ffh,024h,02h,00000001b,0               ;c007   Single
                db      0ffh,004h,02h,00000001b,1,(5*2)+0
                db      0,0,0,0,0
                single  equ     7

                db      0f9h,037h,00h,01100000b,0               ;c008   MYsnare
                db      0ffh,000h,00h,00100001b,0,(7*2)+0
                db      0,0,2,0,0
                snare2  equ     8

                db      096h,025h,02h,00100001b,1               ;c009   Strange
                db      0ffh,000h,00h,00100001b,0,(4*2)+0
                db      4,5,0,0,0
                strange equ     9

                db      0ffh,007h,00h,00000001b,0               ;c00a   Bassdrum
                db      0cfh,008h,00h,00000001b,0,(3*2)+0
                db      0,0,1,0,0
                bassdr  equ     0ah
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h         Set level 00-3f (ff=Continue with last set or instr's level)
; 0001h 	Speed 00-ff (01=slow up, ff=slow down) - see also frameskipper!
; 0002h         Duration 00-ff before next set is read
; 0003h         Pointer to next set
;-------------------------------------------------------------------------------
levelpuls       db      00ch,001h,000h,002h     ;1
		db	0ffh,001h,02ah,003h	;2
		db	0ffh,0ffh,02ah,002h	;3

                db      00eh,001h,00ch,005h     ;4
                db      0ffh,0feh,006h,006h     ;5
                db      0ffh,001h,008h,007h     ;6
                db      0ffh,0ffh,004h,004h     ;7

                db      00bh,001h,008h,009h     ;8
                db      0ffh,0ffh,00ch,00ah     ;9
                db      0ffh,000h,010h,009h     ;A
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0001h   Sample offset start word
; 0002h-0003h   Sample length word
; 0004h-0005h   Reserved for future expansion (Like sample loop)
; 0006h         Sample rate byte (Time_constant)
; 0007h         Unused, to align the tabel to 8 bytes.
;-------------------------------------------------------------------------------
q1      equ     3452+40h
q2      equ     5948
q3      equ     16913
q4      equ     3630
q5      equ     1442
q6      equ     1442
q7      equ     8513
q8      equ     6646
q9      equ     5607

qq1     equ     q1/16
qq2     equ     q2/16
qq3     equ     q3/16
qq4     equ     q4/16
qq5     equ     q5/16
qq6     equ     q6/16
qq7     equ     q7/16
qq8     equ     q8/16

qx1     equ     qq1*16
qx2     equ     qq2*16+qx1
qx3     equ     qq3*16+qx2
qx4     equ     qq4*16+qx3
qx5     equ     qq5*16+qx4
qx6     equ     qq6*16+qx5
qx7     equ     qq7*16+qx6
qx8     equ     qq8*16+qx7

samples         dw      60h,q1-40h,0
                db      256-1000000/15000,0                     ;Bassdrum
                xbassdr equ     0

                dw      qx1+20h,q2,0
                db      256-1000000/16390,0                     ;Snare
                xsnare2 equ     1

                dw      qx2+20h,q3,0
                db      256-1000000/15000,0                     ;Bassdr + Cymb
                xcymbal equ     2

                dw      qx3+20h,q4,0
                db      256-1000000/16390,0                     ;Snare 50%
                xlow    equ     3

                dw      qx4+20h,q5,0
                db      256-1000000/16390,0                     ;Highhat
                xhigh   equ     4

                dw      qx5+20h,q6,0
                db      256-1000000/16390,0                     ;Highhat 50%
                xhigh2  equ     5

                dw      qx6+20h,q7,0
                db      256-1000000/16390,0                     ;Highhat long
                xh2     equ     6

                dw      qx7+20h,q8,0
                db      256-1000000/15390,0                     ;Thunk 1
                xthu1   equ     7

                dw      qx8+20h,q9,0
                db      256-1000000/15390,0                     ;Thunk 2
                xthu2   equ     8

;-------------------------------------------------------------------------------
maxsamp         db      1

names           db      'samp.dat                                       ',0 ;48

loadpos         dw      6000h,0
;-------------------------------------------------------------------------------
; Values        Comments
;-------------------------------------------------------------------------------
; -----		First position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;-------------------------------------------------------------------------------
tk1             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk2             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk3             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk4             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk5             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk6             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk7             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk8             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

tk9             dw      tspeed                                  ;
                dw      8000h,0
                twrap   0

t10             dw      tspeed                                  ;
                dw      8000h,0
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

s1c:                                                            ;

                seqend

s1d:                                                            ;

                seqend

s1e:                                                            ;

                seqend

s1f:                                                            ;

                seqend

s20:                                                            ;

                seqend

s21:                                                            ;

                seqend

s22:                                                            ;

                seqend

s23:                                                            ;

                seqend

s24:                                                            ;

                seqend

s25:                                                            ;

                seqend

s26:                                                            ;

                seqend

s27:                                                            ;

                seqend

s28:                                                            ;

                seqend

s29:                                                            ;

                seqend

;-------------------------------------------------------------------------------
datainfo        db      ' Music converted from Commodore 64 to IBM PC and compatibles by JCH/Vibrants. '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
