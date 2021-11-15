;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  Sound Blaster/8-BIT DMA smpls/data block. Remember VERSION1 and DATAINFO.  ³
;³                                                                             ³
;³  Laxity's "The Alibi", converted by JCH/Vibrants.                           ³
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
max             db      2                       ;Number of music & sfx's
card            db      01h                     ;01h for normal Sound Blaster
                                                ;with samples in 8-BIT DMA.

blockname       db      'The Alibi                       '      ;32 bytes names
composer        db      'Thomas Egeskov Petersen (LAXITY)'

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
                dw      s2a,s2b,s2c,s2d,s2e,s2f,s30
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      t11,t11,t11,t11,t11,t11,t11,t11,t11,t10
                db      00h,00h,00h,00h,00h,00h,0ah,00h,00h,00h
              ; db      3fh,3fh,3fh,3fh,3fh,00h,3fh,3fh,3fh,00h
                db      0,0

                dw      tk1,tk2,tk3,tk4,tk8,tk6,tk7,t12,tk9,tk5
                db      00h,00h,00h,00h,00h,00h,0ah,00h,00h,00h
              ; db      00h,00h,00h,00h,00h,3fh,3fh,00h,00h,00h
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

              ; db      0afh,006h,03h,00000010b,0               ;c003   DOUH!
              ; db      0ffh,006h,20h,00000001b,1,(0*2)+0
              ; db      0,0,1,0,0
              ; douh    equ     2

                db      09fh,005h,00h,00000001b,0               ;c004   Bass
                db      0fbh,055h,00h,00000000b,1,(4*2)+0
                db      0,0,0,0,0
                bass    equ     3

                db      0ffh,034h,04h,00000001b,0               ;c005   Chord
                db      0ffh,000h,00h,00100000b,2,(0*2)+0
		db	1,5,0,0,0
                chord   equ     4

                db      0fah,034h,00h,00100001b,0               ;c006   Leader
                db      0ffh,000h,00h,00000001b,1,(1*2)+0
                db      4,3,0,0,0
                leader  equ     5

                db      0ffh,024h,02h,00000001b,0               ;c007   Single
                db      0ffh,004h,02h,00000001b,1,(5*2)+0
                db      0,0,0,0,0
                single  equ     6

             ;  db      0f9h,037h,00h,01100000b,0               ;c008   MYsnare
             ;  db      0ffh,000h,00h,00100001b,0,(7*2)+0
             ;  db      0,0,2,0,0
             ;  snare2  equ     8

                db      096h,025h,02h,00100001b,1               ;c009   Strange
                db      0ffh,000h,00h,00100001b,0,(4*2)+0
                db      4,5,0,0,0
                strange equ     7

              ; db      0ffh,007h,00h,00000001b,0               ;c00a   Bassdrum
              ; db      0cfh,008h,00h,00000001b,0,(3*2)+0
              ; db      0,0,1,0,0
              ; bassdr  equ     0ah
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
q1      equ     3452
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

qy1     equ     qq1
qy2     equ     qy1+qq2
qy3     equ     qy2+qq3
qy4     equ     qy3+qq4
qy5     equ     qy4+qq5
qy6     equ     qy5+qq6
qy7     equ     qy6+qq7
qy8     equ     qy7+qq8

samples         dw      20h,q1,0
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
maxsamp         db      9

names           db      '\sound\sbpro\vedit2\drums1\dbassdr.voc         ',0 ;48
                db      '\sound\sbpro\vedit2\drums1\diron.voc           ',0
                db      '\sound\sbpro\vedit2\drums1\dbdcymb.voc         ',0
                db      '\sound\sbpro\vedit2\drums1\dishort2.voc        ',0
                db      '\sound\sbpro\vedit2\drums1\dhighhat.voc        ',0
                db      '\sound\sbpro\vedit2\drums1\dhighha2.voc        ',0
                db      '\sound\sbpro\vedit2\drums1\dhigh2.voc          ',0
                db      '\sound\sbpro\vedit2\drums1\dthunk1.voc         ',0
                db      '\sound\sbpro\vedit2\drums1\dthunk2.voc         ',0

loadpos         dw      6000h,0
                dw      6000h+qy1,0
                dw      6000h+qy2,0
                dw      6000h+qy3,0
                dw      6000h+qy4,0
                dw      6000h+qy5,0
                dw      6000h+qy6,0
                dw      6000h+qy7,0
                dw      6000h+qy8,0
;-------------------------------------------------------------------------------
; Values        Comments
;-------------------------------------------------------------------------------
; -----		First position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;-------------------------------------------------------------------------------
tk1             dw      tspeed                                  ;Bassline
                dw      800ch,1,8011h,1,8008h,1,8007h,1         ;2
                dw      800ch,1,8011h,1,8008h,1,8007h,1         ;2
                dw      800ah,1,800dh,1,800ch,1,8011h,1         ;4
                dw      800ah,1,800dh,1,800ch,1,8011h,1         ;4
                dw      800ah,1,1,1,1,1,1,1,1                   ;2
                dw      8012h,1,8011h,1,800fh,1,1               ;8
                dw      8012h,1,8011h,1,800fh,1,1               ;8
                dw      800ah,1,800fh,1,8012h,1,8011h,1         ;2
                dw      800ah,1,800fh,1,8012h,1,8011h,1         ;2
                dw      800fh,1,8012h,1,800ah,1,1
                dw      800fh,1,8012h,1,800ah,1,1
                dw      800bh,1,8011h,1,800bh,1,8011h,1
                dw      800ah,1,800dh,1,800ch,1,8011h,1
                dw      800ah,1,800dh,1,800ch,1,8011h,1
                dw      8012h,1,800eh,1,8007h,1,800bh,1
                dw      800ah,1,8011h,1,800ch,1,1
                twrap   0

tk2             dw      tspeed                                  ;Chords 1
                dw      800ch,2,2,4,4,800ah,2,2
                dw      800ch,8,8,800ah,2,2
                dw      800ch,0bh,0bh,0eh,0eh,4,4,12h,14h
                twrap   0

tk3             dw      tspeed                                  ;Chords 2
                dw      800ch,16h,16h,17h,17h,800ah,16h,16h
                dw      800ch,18h,18h,800ah,16h,16h
                dw      800ch,19h,19h,1ah,1ah,17h,17h,1bh,1ch
                twrap   0

tk4             dw      tspeed                                  ;Chords 3
                dw      800ch,1dh,1dh,1eh,1eh,800ah,1dh,1dh
                dw      800ch,1fh,1fh,800ah,1dh,1dh
                dw      800ch,20h,20h,21h,21h,1eh,1eh,22h,23h
                twrap   0

tk5             dw      tspeed                                  ;Percussion
                dw      25h,24h,25h,26h
                dw      25h,24h,25h,2eh

                dw      25h,24h,25h,2eh
                dw      25h,24h,25h,2ch

                dw      2dh,24h,25h,30h
                dw      25h,24h,25h,2fh

                dw      2dh,24h,25h,26h
                dw      25h,24h,25h,2eh

                dw      2dh,24h,25h,26h
                dw      25h,24h,25h,2eh

                dw      25h,24h,25h,2eh
                dw      25h,24h,25h,2ch

                dw      2dh,24h,25h,2eh

                dw      25h,24h,25h,2eh
                dw      2dh,24h,25h,30h

                dw      25h,24h,25h,26h
                dw      25h,24h,25h,2fh



                dw      2dh,24h,25h,26h
                dw      25h,24h,25h,2eh

                dw      25h,24h,25h,2eh
                dw      25h,24h,25h,2ch

                dw      2dh,24h,25h,30h
                dw      25h,24h,25h,2fh

                dw      2dh,24h,25h,26h
                dw      25h,24h,25h,2eh

                dw      2dh,24h,25h,26h
                dw      25h,24h,25h,2eh

                dw      25h,24h,25h,2eh
                dw      25h,24h,25h,2ch


                dw      2dh,24h,25h,2eh

                dw      25h,24h,25h,2eh
                dw      2dh,24h,25h,30h

                dw      25h,24h,25h,26h
                dw      25h,24h,25h,2fh


             ;  dw      2dh,24h,25h,2eh
             ;  dw      25h,24h,25h,31h

             ;  dw      2dh,24h,25h,26h
             ;  dw      25h,24h,25h,2eh

             ;  dw      2dh,24h,25h,2fh
                twrap   68

tk6             dw      tspeed                                  ;Leader
                dw      800ch,3,3
                dw      5,6,7,7,7,7,7,7,7,7
                dw      9,0ah,800ah,3,3
                dw      800ch,0ch,0dh,0fh,10h,5,6
                dw      13h,15h
		twrap	0

tk7             dw      tspeed                                  ;Leader
                dw      0,0,800ch,3,3
                dw      5,6,7,7,7,7,7,7,7,7
                dw      9,0ah,800ah,3,3,800ch,0ch,0dh,0fh,10h,5,6
                dw      13h,15h
                twrap   2

tk8             dw      tspeed                                  ;Chords 3
                dw      8000h,1dh,1dh,1eh,1eh,8102h,1dh,1dh
                dw      8000h,1fh,1fh,8102h,1dh,1dh
                dw      8000h,20h,20h,21h,21h,1eh,1eh,22h,23h
                twrap   0

tk9             dw      tspeed                                  ;Bassline 2
                dw      800ch,28h,8011h,28h,8008h,28h,8007h,28h
                dw      800ch,28h,8011h,28h,8008h,28h,8007h,28h
                dw      800ah,28h,800dh,28h,800ch,28h,8011h,28h
                dw      800ah,28h,800dh,28h,800ch,28h,8011h,28h
                dw      800ah,28h,28h,28h,28h,28h,28h,28h,28h
                dw      8012h,28h,8011h,28h,800fh,28h,28h
                dw      8012h,28h,8011h,28h,800fh,28h,28h
                dw      800ah,28h,800fh,28h,8012h,28h,8011h,28h
                dw      800ah,28h,800fh,28h,8012h,28h,8011h,28h
                dw      800fh,28h,8012h,28h,800ah,28h,28h
                dw      800fh,28h,8012h,28h,800ah,28h,28h
                dw      800bh,28h,8011h,28h,800bh,28h,8011h,28h
                dw      800ah,28h,800dh,28h,800ch,28h,8011h,28h
                dw      800ah,28h,800dh,28h,800ch,28h,8011h,28h
                dw      8012h,28h,800eh,28h,8007h,28h,800bh,28h
                dw      800ah,28h,8011h,28h,800ch,28h,28h
                twrap   0

t10             dw      2                                       ;Drum line
                dw      8000h,29h,29h,29h,2ah
                dw      29h,29h,29h,2bh
                twrap   0

t11             dw      tspeed                                  ;Empty
                dw      0
                tstop

t12             dw      tspeed                                  ;Chords 1
                dw      8000h,2,2,4,4,8102h,2,2
                dw      8000h,8,8,8102h,2,2
                dw      8000h,0bh,0bh,0eh,0eh,4,4,12h,14h
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

s01:                                                            ;Bassline
                snd bass
                az 1 3
                az 1 1
                az 1 3
                az 1 1
                rest 3
              ; snd snare
              ; c 1 3
              ; snd bass
                az 2 1
                az 1 3
                az 1 5
                az 1 1
                az 1 3
                az 1 1
              ; rest 3
                az 1 1
                rest 1
              ; snd snare
              ; c 1 3
              ; snd bass
                az 2 1
                az 1 3
                az 1 1
                seqend

p00x1   equ     0
p04x1   equ     0
p08x1   equ     0
p0cx1   equ     0
p10x1   equ     0
p14x1   equ     0
p18x1   equ     0
p1cx1   equ     0
p20x1   equ     0

p00x2   equ     5
p00x3   equ     8
p04x2   equ     5
p04x3   equ     0ah
p08x2   equ     4
p08x3   equ     7
p0cx2   equ     4
p0cx3   equ     0bh
p10x2   equ     5
p10x3   equ     9
p14x2   equ     3
p14x3   equ     8
p18x2   equ     4
p18x3   equ     9
p1cx2   equ     3
p1cx3   equ     7
p20x2   equ     2
p20x3   equ     7

;----------------------------------------------
; RAM placements in Laxity's C64 music-routine:
;----------------------------------------------
; Sequence $02 - $4863
; Sequence $04 - $490a
; Sequence $08 - $4a1f
; Sequence $0b - $4aff
; Sequence $0e - $4baf
; Sequence $12 - $4cd6
; Sequence $14 - $4d39
;----------------------------------------------

s02:                                                            ;Chords 1
                snd chord
                dw      0b29h
                dw      0529h
                dw      0529h
                dw      0329h
                dw      0529h
                dw      0729h
                dw      0529h
                dw      0b2ah
                dw      052ah
                dw      052ah
                dw      032ah
                dw      052ah
                dw      072ah
                dw      052ah

                dw      0b29h
                dw      0529h
                dw      0529h
                dw      0329h
                dw      0529h
                dw      0729h
                dw      0529h
                dw      0b27h
                dw      0527h
                dw      0527h
                dw      0327h
                dw      0527h
                dw      0727h
                dw      0527h
                seqend

v1      equ     0502h
v2      equ     0602h

s03:                                                            ;Main leader
                snd leader
                dw      0522h
                vib v1
                cont 9
                dw      0122h
                dw      0324h
                dw      0725h
                dw      0327h
                dw      0729h
                dw      032ch
                down 4
                dw      032ch
                dw      252ah
                vib v1
                cont 9
              ; dw      2f2ah

                up 5
                dw      012ch
                dw      232eh
                up 5
                dw      0131h
                dw      2733h
                dw      0738h
                dw      0336h
                up 3
                dw      0333h
                dw      2135h
                vib v1
                cont 0bh
                dw      0131h
                up 4
                dw      032ch
                dw      212eh
                vib v1
                cont 09h
                dw      0129h
                dw      032eh
                dw      0130h
                dw      0331h
                dw      0133h
                up 4
                dw      032eh
                dw      2130h
                vib v1
                cont 09h
                dw      0131h
                dw      0333h
                up 6
                dw      012eh
                dw      2130h
                down 3
                dw      2330h
                dw      232ch
                dw      032ch
                vib v1
                cont 09h
                seqend

s04:                                                            ;Chords 1
                dw      0b2ah+p10x1
                dw      052ah+p10x1
                dw      052ah+p10x1
                dw      032ah+p10x1
                dw      052ah+p10x1
                dw      072ah+p10x1
                dw      052ah+p10x1
                dw      0b2ah+p10x1
                dw      052ah+p10x1
                dw      052ah+p10x1
                dw      032ah+p10x1
                dw      052ah+p10x1
                dw      072ah+p10x1
                dw      052ah+p10x1

                dw      0b29h+p14x1
                dw      0529h+p14x1
                dw      0529h+p14x1
                dw      0329h+p14x1
                dw      0529h+p14x1
                dw      0729h+p14x1
                dw      0529h+p14x1
                dw      0b29h+p14x1
                dw      0529h+p14x1
                dw      0529h+p14x1
                dw      0329h+p14x1
                dw      072ah+p08x1
                dw      052ah+p08x1
                dw      052ah+p08x1
                seqend

s05:                                                            ;Leader
                snd lead2
                dw      032eh
                dw      012fh
                rest 3
                dw      012fh
                rest 3
                dw      012eh
                rest 3
                dw      012eh
                vib v2
                cont 3
                dw      012fh
                rest 5
                dw      012fh
                rest 3
                dw      012eh
                rest 3
                dw      032eh
                dw      012fh
                rest 3
                dw      012fh
                rest 3
                dw      012eh
                rest 3
                dw      012eh
                vib v2
                cont 3
                dw      012fh
                rest 5
                dw      012fh
                rest 3
                dw      0533h
                dw      0535h
                dw      0331h
                dw      052ch
                vib v2
                cont 1fh
                dw      052ch
                dw      032eh
                up 4
                dw      032ch
                dw      252eh
                vib v2
                cont 1bh
                seqend

s06:                                                            ;Leader
                dw      032eh
                dw      012fh
                rest 3
                dw      012fh
                rest 3
                dw      012eh
                rest 3
                dw      012eh
                vib v2
                cont 3
                dw      012fh
                rest 5
                dw      012fh
                rest 3
                dw      012eh
                rest 3
                dw      032eh
                dw      012fh
                rest 3
                dw      012fh
                rest 3
                dw      012eh
                rest 3
                dw      012eh
                vib v2
                cont 3
                dw      012fh
                rest 5
                dw      012fh
                rest 3
                dw      0533h
                dw      0135h
                dw      0133h
                dw      0131h
                up 4
                dw      0131h
                dw      2133h
                dw      0531h
                vib v2
                cont 1fh
                dw      0133h
                dw      0135h
                dw      0133h
                dw      0335h
                up 4
                dw      0133h
                dw      2535h
                vib v2
                cont 9
                dw      0338h
                vib v2
                cont 0fh
                seqend

s07:                                                            ;Plink - Plank
                snd single
                dw      0114h
                dw      011bh
                dw      0120h
                dw      011bh
                dw      0120h
                dw      0127h
                dw      0120h
                dw      0127h
                dw      012ch
                dw      0127h
                dw      012ch
                dw      0133h
                dw      012ch
                dw      0133h
                dw      0138h
                dw      0127h
                dw      012ch
                dw      0133h
                dw      0120h
                dw      0127h
                dw      012ch
                dw      011bh
                dw      0120h
                dw      0127h
                seqend

s08:                                                            ;Chords 1
                dw      0b27h+p00x1
                dw      0527h+p00x1
                dw      0527h+p00x1
                dw      0327h+p00x1
                dw      0527h+p00x1
                dw      0727h+p00x1
                dw      0527h+p00x1

                dw      0b25h+p10x1
                dw      0525h+p10x1
                dw      0525h+p10x1
                dw      0325h+p10x1
                dw      0525h+p10x1
                dw      0725h+p10x1
                dw      0525h+p10x1

                dw      0b28h+p08x1
                dw      0528h+p08x1
                dw      0528h+p08x1
                dw      0328h+p08x1
                dw      0528h+p08x1
                dw      0728h+p08x1
                dw      0528h+p08x1
                dw      0b28h+p08x1
                dw      0528h+p08x1
                dw      0528h+p08x1
                dw      0328h+p08x1
                dw      0528h+p08x1
                dw      0728h+p08x1

                dw      0525h+p10x1
                seqend

s09:                                                            ;Leader
                snd leader
                dw      032fh
                dw      012eh
                dw      032ch
                up 4
                dw      032ah
                dw      252ch
                vib v1
                cont 7
                dw      0733h
                dw      0331h
                dw      072fh
                dw      012eh
                dw      012fh
                dw      0131h
                up 4
                dw      012ch
                dw      212eh
                dw      052ah
                vib v1
                cont 0bh
                dw      0127h
                dw      052ah
                dw      052eh
                dw      052fh
                dw      0533h
                dw      0334h
                up 3
                dw      0133h
                dw      2534h
                vib v1
                cont 0fh
                vib 0
                up 3
                dw      2334h
                dw      2336h
                vib v1
                cont 3
                dw      0138h
                dw      0533h
                vib v1
                cont 9
                dw      0134h
                dw      0336h
                dw      0733h
                dw      0334h
                dw      0731h
                dw      0533h
                seqend

s0a:                                                            ;Leader
                dw      032fh
                dw      012eh
                dw      032ch
                up 4
                dw      032ah
                dw      252ch
                vib v1
                cont 7
                dw      0733h
                dw      0331h
                dw      072fh
                dw      012eh
                dw      012fh
                dw      0131h
                up 4
                dw      012ch
                dw      212eh
                dw      052ah
                vib v1
                cont 9
                dw      0125h
                dw      0127h
                dw      012ah
                dw      012ch
                dw      012eh
                up 3
                dw      012eh
                dw      232fh
                dw      0331h
                dw      0533h
                vib v1
                cont 0bh
                dw      0134h
                dw      0333h
                dw      0134h
                down 2
                dw      2334h
                dw      2133h
                up 2
                dw      0331h
                dw      2533h
                vib v1
                cont 15h
                vib 0
                down 3
                dw      2333h
                dw      2531h
                vib v1
                cont 5
                dw      032fh
                dw      012eh
                dw      052ch
                dw      052ah
                seqend

s0b:                                                            ;Chords 1
                dw      0b28h+p08x1
                dw      0528h+p08x1
                dw      0528h+p08x1
                dw      0328h+p08x1
                dw      0528h+p08x1
                dw      0728h+p08x1
                dw      0528h+p08x1

                dw      0b27h+p00x1
                dw      0527h+p00x1
                dw      0527h+p00x1
                dw      0327h+p00x1
                dw      0527h+p00x1
                dw      0727h+p00x1
                dw      0527h+p00x1

                dw      0b25h+p10x1
                dw      0525h+p10x1
                dw      0525h+p10x1
                dw      0325h+p10x1
                dw      0525h+p10x1
                dw      0725h+p10x1
                dw      0525h+p10x1

                dw      0b27h+p00x1
                dw      0527h+p00x1
                dw      0527h+p00x1
                dw      0327h+p00x1
                dw      0727h+p00x1
                dw      0527h+p00x1
                dw      0527h+p00x1
                seqend

s0c:                                                            ;Leader
                snd lead2
                dw      0531h
                vib v2
                cont 0bh
                dw      032fh
                dw      0531h
                vib v2
                cont 11h
                dw      012fh
                up 4
                dw      0131h
                dw      2333h
                dw      0331h
                up 3
                dw      012eh
                dw      252fh
                vib v2
                cont 1dh
              ; dw      252fh
                dw      052eh
                dw      032fh
                dw      052ch
                vib v2
                cont 19h
                dw      052ah
                dw      032ah
                dw      052ch
                dw      0538h
                vib v2
                cont 19h
                rest 5
                seqend

s0d:                                                            ;Leader
                rest 1
                dw      0136h
                dw      2134h
                dw      0133h
                dw      2131h
                dw      0134h
                dw      2333h
                dw      052fh
                vib v2
                cont 19h
                vib 0
                dw      232fh
                up 4
                dw      0131h
                dw      2133h
                up 4
                dw      0131h
                dw      2133h
                down 4
                dw      2133h
                dw      2131h
                dw      052fh
                vib v2
                cont 19h
                dw      012eh
                dw      012fh
                dw      212eh
                dw      052ch
                vib v2
                cont 19h
                dw      0127h
                dw      012ah
                dw      012ch
                dw      012ah
                dw      012eh
                dw      012fh
                dw      212eh
                dw      0d2ch
                up 3
                dw      0331h
                dw      2533h
                vib v2
                cont 13h
                seqend

s0e:                                                            ;Chords 1
                dw      0b28h+p18x1
                dw      0528h+p18x1
                dw      0528h+p18x1
                dw      0328h+p18x1
                dw      0528h+p18x1
                dw      0728h+p18x1
                dw      0528h+p18x1

                dw      0b2ah+p20x1
                dw      052ah+p20x1
                dw      052ah+p20x1
                dw      032ah+p20x1

                dw      052ah+p08x1
                dw      072ah+p08x1
                dw      052ah+p08x1        
                seqend

s0f:                                                            ;Leader
                snd strange
                dw      0134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      2134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      2134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      2134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                seqend

s10:                                                            ;Leader
                dw      2134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      2134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      2134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      2134h
                dw      2133h
                dw      2131h
                dw      212dh
                dw      2131h
                dw      2133h
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                dw      212ah
                dw      212ch
                dw      2131h
                dw      2133h
                dw      2131h
                dw      212ch
                seqend

s11:                                                            ;

                seqend

s12:                                                            ;Chords 1
                dw      0b2ch+p1cx1
                dw      052ch+p1cx1
                dw      052ch+p1cx1
                dw      032ch+p1cx1
                dw      052ch+p1cx1
                dw      072ch+p1cx1
                dw      052ch+p1cx1

                dw      0b2bh+p18x1
                dw      052bh+p18x1
                dw      052bh+p18x1
                dw      032bh+p18x1
                dw      052bh+p18x1
                dw      072bh+p18x1
                dw      052bh+p18x1

                dw      0b2dh+p1cx1
                dw      052dh+p1cx1
                dw      052dh+p1cx1
                dw      032dh+p1cx1
                dw      052dh+p1cx1
                dw      072dh+p1cx1
                dw      052dh+p1cx1
                dw      0b2dh+p1cx1
                dw      052dh+p1cx1
                dw      052dh+p1cx1
                dw      032dh+p1cx1
                dw      072dh+p1cx1
                dw      052dh+p1cx1
                dw      052dh+p1cx1
                seqend

s13:                                                            ;Weird leader
                snd leader
                dw      052fh
                vib v1
                cont 19h
                cont 0fh
                dw      052fh
                vib v1
                cont 11h
                dw      0b2dh
                dw      0b2dh
                up 4
                dw      032bh
                dw      252dh
                dw      0128h
                dw      032dh
                dw      032fh
                dw      0330h
                dw      0534h
                vib v1
                cont 11h
                dw      0932h
                dw      0d30h
                dw      092fh
                dw      0d30h
                seqend

s14:                                                            ;Chords 1
                dw      0b2bh+p00x1
                dw      052bh+p00x1
                dw      052bh+p00x1
                dw      032bh+p00x1
                dw      052bh+p00x1
                dw      072bh+p00x1
                dw      052bh+p00x1

                dw      0b2eh+p14x1
                dw      052eh+p14x1
                dw      052eh+p14x1
                dw      032eh+p14x1
                dw      052eh+p14x1
                dw      072eh+p14x1
                dw      052eh+p14x1

                dw      0b2ch+p10x1
                dw      052ch+p10x1
                dw      052ch+p10x1
                dw      032ch+p10x1
                dw      052ch+p10x1
                dw      072ch+p10x1
                dw      052ch+p10x1
                dw      0b2ch+p10x1
                dw      052ch+p10x1
                dw      052ch+p10x1
                dw      032ch+p10x1
                dw      072ch+p10x1
                dw      052ch+p10x1
                dw      052ch+p10x1
                seqend

s15:                                                            ;Weird leader
                dw      0932h
                dw      0533h
                vib v1
                cont 19h
                cont 5
                dw      0131h
                dw      0130h
                dw      052eh
                vib v1
                cont 15h
                cont 0fh
                dw      0930h
                dw      0531h
                vib v1
                cont 19h
                dw      0533h
                up 4
                dw      0133h
                dw      2535h
                vib v1
                cont 17h
                rest 0fh
                seqend
;-------------------------------------------------------------------------------
s16:   ;2                                                       ;Chords 2
                snd chord
                dw      0b29h+p00x2
                dw      0529h+p00x2
                dw      0529h+p00x2
                dw      0329h+p04x2
                dw      0529h+p04x2
                dw      0729h+p00x2
                dw      0529h+p00x2
                dw      0b2ah+p08x2
                dw      052ah+p08x2
                dw      052ah+p08x2
                dw      032ah+p0cx2
                dw      052ah+p0cx2
                dw      072ah+p08x2
                dw      052ah+p08x2

                dw      0b29h+p00x2
                dw      0529h+p00x2
                dw      0529h+p00x2
                dw      0329h+p04x2
                dw      0529h+p04x2
                dw      0729h+p00x2
                dw      0529h+p00x2
                dw      0b27h+p10x2
                dw      0527h+p10x2
                dw      0527h+p10x2
                dw      0327h+p04x2
                dw      0527h+p04x2
                dw      0727h+p10x2
                dw      0527h+p10x2
                seqend

s17:   ;4                                                       ;Chords 2
                dw      0b2ah+p10x2
                dw      052ah+p10x2
                dw      052ah+p10x2
                dw      032ah+p10x2
                dw      052ah+p10x2
                dw      072ah+p10x2
                dw      052ah+p10x2
                dw      0b2ah+p10x2
                dw      052ah+p10x2
                dw      052ah+p10x2
                dw      032ah+p10x2
                dw      052ah+p10x2
                dw      072ah+p10x2
                dw      052ah+p10x2

                dw      0b29h+p14x2
                dw      0529h+p14x2
                dw      0529h+p14x2
                dw      0329h+p14x2
                dw      0529h+p14x2
                dw      0729h+p14x2
                dw      0529h+p14x2
                dw      0b29h+p14x2
                dw      0529h+p14x2
                dw      0529h+p14x2
                dw      0329h+p14x2
                dw      072ah+p08x2
                dw      052ah+p08x2
                dw      052ah+p08x2
                seqend

s18:   ;8                                                       ;Chords 2
                dw      0b27h+p00x2
                dw      0527h+p00x2
                dw      0527h+p00x2
                dw      0327h+p00x2
                dw      0527h+p00x2
                dw      0727h+p00x2
                dw      0527h+p00x2

                dw      0b25h+p10x2
                dw      0525h+p10x2
                dw      0525h+p10x2
                dw      0325h+p10x2
                dw      0525h+p10x2
                dw      0725h+p10x2
                dw      0525h+p10x2

                dw      0b28h+p08x2
                dw      0528h+p08x2
                dw      0528h+p08x2
                dw      0328h+p08x2
                dw      0528h+p08x2
                dw      0728h+p08x2
                dw      0528h+p08x2
                dw      0b28h+p08x2
                dw      0528h+p08x2
                dw      0528h+p08x2
                dw      0328h+p08x2
                dw      0528h+p08x2
                dw      0728h+p08x2

                dw      0525h+p10x2
                seqend

s19:   ;0bh                                                     ;Chords 2
                dw      0b28h+p08x2
                dw      0528h+p08x2
                dw      0528h+p08x2
                dw      0328h+p08x2
                dw      0528h+p08x2
                dw      0728h+p08x2
                dw      0528h+p08x2

                dw      0b27h+p00x2
                dw      0527h+p00x2
                dw      0527h+p00x2
                dw      0327h+p00x2
                dw      0527h+p00x2
                dw      0727h+p00x2
                dw      0527h+p00x2

                dw      0b25h+p10x2
                dw      0525h+p10x2
                dw      0525h+p10x2
                dw      0325h+p10x2
                dw      0525h+p10x2
                dw      0725h+p10x2
                dw      0525h+p10x2

                dw      0b27h+p00x2
                dw      0527h+p00x2
                dw      0527h+p00x2
                dw      0327h+p00x2
                dw      0727h+p00x2
                dw      0527h+p00x2
                dw      0527h+p00x2
                seqend

s1a:   ;0eh                                                     ;Chords 2
                dw      0b28h+p18x2
                dw      0528h+p18x2
                dw      0528h+p18x2
                dw      0328h+p18x2
                dw      0528h+p18x2
                dw      0728h+p18x2
                dw      0528h+p18x2

                dw      0b2ah+p20x2
                dw      052ah+p20x2
                dw      052ah+p20x2
                dw      032ah+p20x2

                dw      052ah+p08x2
                dw      072ah+p08x2
                dw      052ah+p08x2
                seqend

s1b:   ;12h                                                     ;Chords 2
                dw      0b2ch+p1cx2
                dw      052ch+p1cx2
                dw      052ch+p1cx2
                dw      032ch+p1cx2
                dw      052ch+p1cx2
                dw      072ch+p1cx2
                dw      052ch+p1cx2

                dw      0b2bh+p18x2
                dw      052bh+p18x2
                dw      052bh+p18x2
                dw      032bh+p18x2
                dw      052bh+p18x2
                dw      072bh+p18x2
                dw      052bh+p18x2

                dw      0b2dh+p1cx2
                dw      052dh+p1cx2
                dw      052dh+p1cx2
                dw      032dh+p1cx2
                dw      052dh+p1cx2
                dw      072dh+p1cx2
                dw      052dh+p1cx2
                dw      0b2dh+p1cx2
                dw      052dh+p1cx2
                dw      052dh+p1cx2
                dw      032dh+p1cx2
                dw      072dh+p1cx2
                dw      052dh+p1cx2
                dw      052dh+p1cx2
                seqend

s1c:   ;14h                                                     ;Chords 2
                dw      0b2bh+p00x2
                dw      052bh+p00x2
                dw      052bh+p00x2
                dw      032bh+p00x2
                dw      052bh+p00x2
                dw      072bh+p00x2
                dw      052bh+p00x2

                dw      0b2eh+p14x2
                dw      052eh+p14x2
                dw      052eh+p14x2
                dw      032eh+p14x2
                dw      052eh+p14x2
                dw      072eh+p14x2
                dw      052eh+p14x2

                dw      0b2ch+p10x2
                dw      052ch+p10x2
                dw      052ch+p10x2
                dw      032ch+p10x2
                dw      052ch+p10x2
                dw      072ch+p10x2
                dw      052ch+p10x2
                dw      0b2ch+p10x2
                dw      052ch+p10x2
                dw      052ch+p10x2
                dw      032ch+p10x2
                dw      072ch+p10x2
                dw      052ch+p10x2
                dw      052ch+p10x2
                seqend
;-------------------------------------------------------------------------------
s1d:   ;2                                                       ;Chords 3

                snd chord
                dw      0b29h+p00x3
                dw      0529h+p00x3
                dw      0529h+p00x3
                dw      0329h+p04x3
                dw      0529h+p04x3
                dw      0729h+p00x3
                dw      0529h+p00x3
                dw      0b2ah+p08x3
                dw      052ah+p08x3
                dw      052ah+p08x3
                dw      032ah+p0cx3
                dw      052ah+p0cx3
                dw      072ah+p08x3
                dw      052ah+p08x3

                dw      0b29h+p00x3
                dw      0529h+p00x3
                dw      0529h+p00x3
                dw      0329h+p04x3
                dw      0529h+p04x3
                dw      0729h+p00x3
                dw      0529h+p00x3
                dw      0b27h+p10x3
                dw      0527h+p10x3
                dw      0527h+p10x3
                dw      0327h+p04x3
                dw      0527h+p04x3
                dw      0727h+p10x3
                dw      0527h+p10x3
                seqend

s1e:   ;4                                                       ;Chords 3
                dw      0b2ah+p10x3
                dw      052ah+p10x3
                dw      052ah+p10x3
                dw      032ah+p10x3
                dw      052ah+p10x3
                dw      072ah+p10x3
                dw      052ah+p10x3
                dw      0b2ah+p10x3
                dw      052ah+p10x3
                dw      052ah+p10x3
                dw      032ah+p10x3
                dw      052ah+p10x3
                dw      072ah+p10x3
                dw      052ah+p10x3

                dw      0b29h+p14x3
                dw      0529h+p14x3
                dw      0529h+p14x3
                dw      0329h+p14x3
                dw      0529h+p14x3
                dw      0729h+p14x3
                dw      0529h+p14x3
                dw      0b29h+p14x3
                dw      0529h+p14x3
                dw      0529h+p14x3
                dw      0329h+p14x3
                dw      072ah+p08x3
                dw      052ah+p08x3
                dw      052ah+p08x3
                seqend

s1f:   ;8                                                       ;Chords 3
                dw      0b27h+p00x3
                dw      0527h+p00x3
                dw      0527h+p00x3
                dw      0327h+p00x3
                dw      0527h+p00x3
                dw      0727h+p00x3
                dw      0527h+p00x3

                dw      0b25h+p10x3
                dw      0525h+p10x3
                dw      0525h+p10x3
                dw      0325h+p10x3
                dw      0525h+p10x3
                dw      0725h+p10x3
                dw      0525h+p10x3

                dw      0b28h+p08x3
                dw      0528h+p08x3
                dw      0528h+p08x3
                dw      0328h+p08x3
                dw      0528h+p08x3
                dw      0728h+p08x3
                dw      0528h+p08x3
                dw      0b28h+p08x3
                dw      0528h+p08x3
                dw      0528h+p08x3
                dw      0328h+p08x3
                dw      0528h+p08x3
                dw      0728h+p08x3

                dw      0525h+p10x3
                seqend

s20:   ;0bh                                                     ;Chords 3
                dw      0b28h+p08x3
                dw      0528h+p08x3
                dw      0528h+p08x3
                dw      0328h+p08x3
                dw      0528h+p08x3
                dw      0728h+p08x3
                dw      0528h+p08x3

                dw      0b27h+p00x3
                dw      0527h+p00x3
                dw      0527h+p00x3
                dw      0327h+p00x3
                dw      0527h+p00x3
                dw      0727h+p00x3
                dw      0527h+p00x3

                dw      0b25h+p10x3
                dw      0525h+p10x3
                dw      0525h+p10x3
                dw      0325h+p10x3
                dw      0525h+p10x3
                dw      0725h+p10x3
                dw      0525h+p10x3

                dw      0b27h+p00x3
                dw      0527h+p00x3
                dw      0527h+p00x3
                dw      0327h+p00x3
                dw      0727h+p00x3
                dw      0527h+p00x3
                dw      0527h+p00x3
                seqend

s21:   ;0eh                                                     ;Chords 3
                dw      0b28h+p18x3
                dw      0528h+p18x3
                dw      0528h+p18x3
                dw      0328h+p18x3
                dw      0528h+p18x3
                dw      0728h+p18x3
                dw      0528h+p18x3

                dw      0b2ah+p20x3
                dw      052ah+p20x3
                dw      052ah+p20x3
                dw      032ah+p20x3

                dw      052ah+p08x3
                dw      072ah+p08x3
                dw      052ah+p08x3
                seqend

s22:   ;12h                                                     ;Chords 3
                dw      0b2ch+p1cx3
                dw      052ch+p1cx3
                dw      052ch+p1cx3
                dw      032ch+p1cx3
                dw      052ch+p1cx3
                dw      072ch+p1cx3
                dw      052ch+p1cx3

                dw      0b2bh+p18x3
                dw      052bh+p18x3
                dw      052bh+p18x3
                dw      032bh+p18x3
                dw      052bh+p18x3
                dw      072bh+p18x3
                dw      052bh+p18x3

                dw      0b2dh+p1cx3
                dw      052dh+p1cx3
                dw      052dh+p1cx3
                dw      032dh+p1cx3
                dw      052dh+p1cx3
                dw      072dh+p1cx3
                dw      052dh+p1cx3
                dw      0b2dh+p1cx3
                dw      052dh+p1cx3
                dw      052dh+p1cx3
                dw      032dh+p1cx3
                dw      072dh+p1cx3
                dw      052dh+p1cx3
                dw      052dh+p1cx3
                seqend

s23:   ;14h                                                     ;Chords 3
                dw      0b2bh+p00x3
                dw      052bh+p00x3
                dw      052bh+p00x3
                dw      032bh+p00x3
                dw      052bh+p00x3
                dw      072bh+p00x3
                dw      052bh+p00x3

                dw      0b2eh+p14x3
                dw      052eh+p14x3
                dw      052eh+p14x3
                dw      032eh+p14x3
                dw      052eh+p14x3
                dw      072eh+p14x3
                dw      052eh+p14x3

                dw      0b2ch+p10x3
                dw      052ch+p10x3
                dw      052ch+p10x3
                dw      032ch+p10x3
                dw      052ch+p10x3
                dw      072ch+p10x3
                dw      052ch+p10x3
                dw      0b2ch+p10x3
                dw      052ch+p10x3
                dw      052ch+p10x3
                dw      032ch+p10x3
                dw      072ch+p10x3
                dw      052ch+p10x3
                dw      052ch+p10x3
                seqend
;-------------------------------------------------------------------------------
bum             macro
                snd xsnare2
                lc 24h 0
                endm

s24:                                                            ;Percussion
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xbassdr
                lc 1 5
                snd xsnare2
                lc 1 3
                snd xbassdr
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                seqend

s25:                                                            ;Percussion
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
              ; snd xhigh2
              ; lc 1 1
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                seqend

s26:                                                            ;Percussion
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xbassdr
                lc 1 5
                snd xsnare2
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xh2
                lc 1 3
                snd xhigh
                lc 1 1
                seqend

s27:                                                            ;Snare backup
              ; snd xsnare2
              ; cut 0bh
              ; lc 0ch 0
              ; rest 6
              ; cut 0fh
              ; lc 0ch 0
              ; rest 6
              ; cut 3
              ; seqend

s2c:                                                            ;Percussion
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
                lc 1 3
                snd xlow
                lc 1 0
                lc 1 0
                snd xsnare2
                lc 1 3
                lc 1 1
                seqend
s2d:                                                            ;Percussion
                snd xcymbal
                lc 1 9
              ; snd xhigh2
              ; lc 1 1
              ; snd xhigh
              ; lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
              ; snd xhigh2
              ; lc 1 1
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                seqend
s2e:                                                            ;Percussion
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xbassdr
                lc 1 5
                snd xsnare2
                lc 1 3
                snd xlow
                lc 1 1
                snd xbassdr
                lc 1 3
                snd xlow
                lc 1 0
                lc 1 0
                seqend
s2f:                                                            ;Percussion
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 3
              ; snd xhigh2
                lc 1 1
                snd xbassdr
                lc 1 3
                snd xlow
                lc 1 0
                lc 1 0
                snd xsnare2
                lc 1 1
                snd xlow
                lc 1 0
                lc 1 0
                snd xsnare2
                lc 1 1
                snd xthu1
                lc 1 1
                lc 1 1
                snd xthu2
                lc 1 1
                seqend
s30:                                                            ;Percussion
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xsnare2
                lc 1 5
                snd xbassdr
                lc 1 3
                snd xhigh2
                lc 1 1
                snd xhigh
                lc 1 3
                snd xsnare2
                lc 1 5
                snd xhigh
                lc 1 1
                snd xsnare2
                lc 1 3
                snd xbassdr
                lc 1 1
                snd xsnare2
                lc 1 3
                snd xh2
                lc 1 1
                seqend

;-------------------------------------------------------------------------------
x       equ     0203h

s28:                                                            ;Bassline 2
                snd bass2
                vib x
                az 0 3
                vib x
                az 0 1
                vib x
                az 0 3
                vib x
                az 0 1
                vib x
                rest 3
              ; snd snare
              ; c 1 3
              ; snd bass
                vib x
                lvl 8
                az 1 1
                lvl 0
                vib x
                az 0 3
                vib x
                az 0 5
                vib x
                az 0 1
                vib x
                az 0 3
                vib x
                az 0 1
              ; rest 3
                vib x
                az 0 1
                rest 1
              ; snd snare
              ; c 1 3
              ; snd bass
                vib x
                lvl 8
                az 1 1
                lvl 0
                vib x
                az 0 3
                vib x
                az 0 1
                seqend
;-------------------------------------------------------------------------------
s29:                                                            ;Drum line ext
                snd xbassdr
                lc 09h 3
                snd xhigh
                lc 09h 3
                snd xsnare2
                lc 09h 3
                snd xhigh
                lc 09h 3
                seqend

s2a:                                                            ;Drum line ext
                snd xbassdr
                lc 09h 3
                snd xh2
                lc 09h 3
                snd xsnare2
                lc 09h 3
                snd xh2
                lc 09h 3
                seqend

s2b:                                                            ;Drum line ext
                snd xbassdr
                lc 09h 3
                snd xlow
                lc 09h 0
                lc 09h 0
                snd xsnare2
                lc 09h 1
                lc 09h 3
              ; snd xhigh
                lc 09h 3
                seqend
;-------------------------------------------------------------------------------
datainfo        db      ' Music originally composed by LAXITY on the Commodore 64 (in his own routine), and then later converted to the PC by JCH, with the addition of a 10th digi-drumtrack "composed" by JCH. '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
