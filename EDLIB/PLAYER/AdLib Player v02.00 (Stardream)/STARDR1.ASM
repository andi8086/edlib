;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;�  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  �
;쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;�  Normal 9-voice ADLIB data block. Remember to alter VERSION1 and DATAINFO.  �
;�                                                                             �
;�  Laxity's Stardream v01.                                                    �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
tspeed          equ     1

public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
detection       db      'JCH',26h,02h,66h       ;System detection bytes
kind            db      00h                     ;00h for music data block
version1        db      02h                     ;Major music-player version
timer           db      33                      ;Timerspeed for the block
max             db      1                       ;Number of music & sfx's
card            db      00h                     ;00h for normal Adlib

blockname       db      'Stardream                       '      ;32 bytes names
composer        db      'Thomas Egeskov Petersen         '

                db      32 dup (0)              ;For future expansion...

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19
                dw      x02,x07,x0a,x0e,x12,x17
                dw      y02,y07,y0a,y0e,y12,y17
                dw      s26,s27,s28
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

                db      0ffh,006h,00h,00000000b,0               ;c001   Lead3
                db      0f7h,024h,10h,00100001b,1,(4*2)+0
                db      0,0,0,0,0
                lead3   equ     1

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
                db      5,0,0,0,0
                bass    equ     4

                db      096h,022h,00h,00100000b,1               ;c005   Chord
                db      0ffh,000h,00h,00100000b,1,(0*2)+0
                db      1,1,0,0,0
                chord   equ     5

                db      0a9h,036h,00h,00100000b,0               ;c006   Lead5
                db      0ffh,002h,0eh,00000001b,1,(3*2)+0
                db      0,0,0,0,0
                lead5   equ     6

                db      022h,002h,00h,00000001b,1               ;c007   Single
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
levelpuls       db      00ah,001h,000h,002h     ;1
                db      0ffh,001h,02ah,003h     ;2
                db      0ffh,0ffh,018h,004h     ;3
                db      0ffh,000h,000h,004h     ;4

                db      008h,001h,010h,006h     ;5
                db      0ffh,000h,000h,006h     ;6

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
                dw      800fh,2,800eh,2,800ch,1,1,8011h,1,800fh,1
                dw      800ch,1,1,800fh,1,1
                dw      800ch,8,0dh,800eh,8,0dh
                dw      800ch,11h,11h,800eh,11h,11h,800ch,17h,19h
                twrap   0

tk2             dw      tspeed
                dw      800fh,1,800eh,1,800ch,2,8013h,7,8011h,2,800ah,7
                dw      800ch,2,2,800fh,2,2,800ch,0ah,0eh,800eh,0ah,0eh
                dw      800ch,12h,12h,800eh,12h,12h,800fh,18h
                twrap   0

tk3             dw      tspeed
                dw      800ch,10h,10h,6,0ch,8011h,6,800fh,0ch,800ch,3,4,5,4
                dw      800fh,3,4,5,4,800ch,9,0bh,0fh,800eh,9,0bh,0fh,800ch
                dw      13h,15h,800eh,14h,16h,800ch,10h,19h,10h,19h
                twrap   0

xx02    equ     1ah
xx07    equ     1bh
xx0a    equ     1ch
xx0e    equ     1dh
xx12    equ     1eh
xx17    equ     1fh

tk4             dw      tspeed
                dw      800fh,xx02,800eh,xx02,800ch,xx02,8013h
                dw      xx07,8011h,xx02,800ah,xx07
                dw      800ch,xx02,xx02,800fh,xx02,xx02
                dw      800ch,xx0a,xx0e,800eh,xx0a,xx0e
                dw      800ch,xx12,xx12,800eh,xx12,xx12,800fh,xx17,19h
                twrap   0

yy02    equ     20h
yy07    equ     21h
yy0a    equ     22h
yy0e    equ     23h
yy12    equ     24h
yy17    equ     25h

tk5             dw      tspeed
                dw      800fh,yy02,800eh,yy02,800ch,yy02,8013h
                dw      yy07,8011h,yy02,800ah,yy07
                dw      800ch,yy02,yy02,800fh,yy02,yy02
                dw      800ch,yy0a,yy0e,800eh,yy0a,yy0e
                dw      800ch,yy12,yy12,800eh,yy12,yy12,800fh,yy17,19h
                twrap   0

tk6		dw	tspeed
                dw      9 dup (26h)
                dw      4 dup (28h)
                dw      800fh,27h,19h
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
akk00_0 equ     0
akk00_1 equ     5
akk00_2 equ     9

akk04_0 equ     0
akk04_1 equ     3
akk04_2 equ     8

akk08_0 equ     0
akk08_1 equ     4
akk08_2 equ     7

akk0c_0 equ     0
akk0c_1 equ     3
akk0c_2 equ     7

akk10_0 equ     0
akk10_1 equ     3
akk10_2 equ     5
akk10_3 equ     8

s00:                                                            ;Cut sequence
                cut 0
                seqend

s01:                                                            ;Bass.
                snd bass
                dw      1f0ch
                dw      3f0ch,3f0ch
                dw      3f0ch
                seqend

s02:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_0
                dw      3f2bh+akk00_0,3f2bh+akk00_0
                rest 1fh
                seqend

s03:                                                            ;Leader 3.
                snd lead3
                rest 3
                dw      032bh
                dw      0330h
                dw      0332h
                dw      0334h
                dw      0332h
                dw      0330h
                dw      032bh
                dw      0336h
                dw      032bh
                dw      0337h
                dw      032bh
                dw      0336h
                dw      032bh
                dw      0332h
                dw      0334h
                rest 3
                seqend

s04:                                                            ;Staircase sound
                snd single
                dw      0024h
                dw      2028h
                dw      202bh
                dw      202fh
                dw      2030h
                dw      202fh
                dw      202bh
                dw      2028h

                dw      2024h
                dw      2028h
                dw      202bh
                dw      202fh
                dw      2030h
                dw      202fh
                dw      202bh
                dw      2028h

                dw      2024h
                dw      2028h
                dw      202bh
                dw      202fh
                dw      2030h
                dw      202fh
                dw      202bh
                dw      2028h

                dw      2024h
                dw      2028h
                dw      202bh
                dw      202fh
                dw      2030h
                dw      202fh
                dw      202bh
                dw      2028h

                dw      2024h
                dw      2028h
                dw      202bh
                dw      202fh
                dw      2030h
                dw      202fh
                dw      202bh
                dw      2028h

                dw      2024h
                dw      2028h
                dw      202bh
                dw      202fh
                dw      2030h
                dw      202fh
                dw      202bh
                dw      2028h

                dw      2024h
                dw      2028h
                dw      202bh
                dw      202fh
                dw      2030h
                dw      202fh
                dw      202bh
                dw      2028h

                dw      2024h
                rest 2
                seqend

s05:                                                            ;Leader 3.
                snd lead3
                rest 3
                dw      032bh
                dw      0330h
                dw      0332h
                dw      0334h
                dw      0332h
                dw      0330h
                dw      032bh
                dw      0336h
                dw      032bh
                dw      0337h
                dw      032bh
                dw      0339h
                dw      032bh
                dw      0336h
                dw      0337h
                rest 3
                seqend

s06:                                                            ;Leader 5.
                snd lead5
                dw      0330h
                dw      032fh
                dw      172bh
                dw      032ah
                dw      032bh
                dw      032ah
                dw      0728h
                dw      0726h
                dw      1328h
                dw      0732h
                dw      0330h
                dw      132fh
                dw      0f2bh
                seqend

s07:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_0
                rest    1fh
                dw      1f2dh+akk04_0
                rest    1fh
                seqend

s08:                                                            ;Bass.
                snd bass
                dw      1f0ch
                dw      1f10h
                dw      1f09h,3f09h
                dw      1f0ch
                dw      1f10h
                dw      1f05h,3f05h
                seqend

s09:                                                            ;

                seqend

s0a:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_0
                dw      1f2bh+akk08_0
                dw      1f2bh+akk00_0
                dw      3f2bh+akk00_0,3f2bh+akk00_0
                dw      1f2bh+akk08_0
                dw      1f29h+akk00_0
                dw      3f29h+akk00_0
                seqend

s0b:                                                            ;

                seqend

s0c:                                                            ;Leader 5.
                snd lead5
                dw      0330h
                dw      032fh
                dw      0f2bh
                dw      0332h
                dw      0f37h
                dw      0332h
                dw      0730h
                dw      072fh
                dw      172bh
                dw      0328h
                dw      1728h,2b28h
                seqend

s0d:                                                            ;Bass.
                dw      1f0eh
                dw      1f07h
                dw      1f08h,3f08h
                dw      1f09h
                dw      1f0bh
                dw      1f12h,3f12h
                seqend

s0e:                                                            ;Chords
                snd chord
                dw      1f29h+akk08_0
                dw      1f2bh+akk08_0
                dw      1f2ah+akk08_0
                dw      1f27h+akk00_0
                dw      1f28h+akk00_0
                dw      1f2ah+akk00_0
                dw      1f2ah+akk0c_0
                dw      3f2ah+akk0c_0
                seqend

s0f:                                                            ;

                seqend

s10:                                                            ;Ring mod.
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                seqend

s11:                                                            ;Bass.
                dw      0b0eh
                dw      0b09h
                dw      1f07h,2707h
                dw      0b0eh
                dw      0b09h
                dw      1f07h,2707h
                seqend

s12:                                                            ;Chords
                snd chord
                dw      0b2dh+akk04_0
                dw      0b2bh+akk00_0
                dw      1b2bh+akk08_0
                dw      2b2bh+akk08_0
                dw      0b2dh+akk04_0
                dw      0b2bh+akk00_0
                dw      1b2bh+akk08_0
                dw      2b2bh+akk08_0
                seqend

s13:                                                            ;

                seqend

s14:                                                            ;

                seqend

s15:                                                            ;

                seqend

s16:                                                            ;

                seqend

s17:                                                            ;Chords.
                snd chord
                dw      1f2eh+akk10_0
                dw      3f2eh+akk10_0
                dw      3f2eh+akk10_0
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                seqend

s18:                                                            ;Bass.
                snd bass
                dw      1f0ch
                dw      3f0ch
                dw      3f0ch
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                seqend

s19:                                                            ;Rests.
                rest    1fh
                rest    1fh
                seqend
;-------------------------------------------------------------------------------
x02:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_1
                dw      3f2bh+akk00_1,3f2bh+akk00_1
                rest 1fh
                seqend

x07:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_1
                rest    1fh
                dw      1f2dh+akk04_1
                rest    1fh
                seqend

x0a:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_1
                dw      1f2bh+akk08_1
                dw      1f2bh+akk00_1
                dw      3f2bh+akk00_1,3f2bh+akk00_1
                dw      1f2bh+akk08_1
                dw      1f29h+akk00_1
                dw      3f29h+akk00_1
                seqend

x0e:                                                            ;Chords
                snd chord
                dw      1f29h+akk08_1
                dw      1f2bh+akk08_1
                dw      1f2ah+akk08_1
                dw      1f27h+akk00_1
                dw      1f28h+akk00_1
                dw      1f2ah+akk00_1
                dw      1f2ah+akk0c_1
                dw      3f2ah+akk0c_1
                seqend

x12:                                                            ;Chords
                snd chord
                dw      0b2dh+akk04_1
                dw      0b2bh+akk00_1
                dw      1b2bh+akk08_1
                dw      2b2bh+akk08_1
                dw      0b2dh+akk04_1
                dw      0b2bh+akk00_1
                dw      1b2bh+akk08_1
                dw      2b2bh+akk08_1
                seqend

x17:                                                            ;Chords.
                snd chord
                dw      1f2eh+akk10_1
                dw      3f2eh+akk10_1
                dw      3f2eh+akk10_1
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                seqend
;-------------------------------------------------------------------------------
y02:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_2
                dw      3f2bh+akk00_2,3f2bh+akk00_2
                rest 1fh
                seqend

y07:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_2
                rest    1fh
                dw      1f2dh+akk04_2
                rest    1fh
                seqend

y0a:                                                            ;Chords.
                snd chord
                dw      1f2bh+akk00_2
                dw      1f2bh+akk08_2
                dw      1f2bh+akk00_2
                dw      3f2bh+akk00_2,3f2bh+akk00_2
                dw      1f2bh+akk08_2
                dw      1f29h+akk00_2
                dw      3f29h+akk00_2
                seqend

y0e:                                                            ;Chords
                snd chord
                dw      1f29h+akk08_2
                dw      1f2bh+akk08_2
                dw      1f2ah+akk08_2
                dw      1f27h+akk00_2
                dw      1f28h+akk00_2
                dw      1f2ah+akk00_2
                dw      1f2ah+akk0c_2
                dw      3f2ah+akk0c_2
                seqend

y12:                                                            ;Chords
                snd chord
                dw      0b2dh+akk04_2
                dw      0b2bh+akk00_2
                dw      1b2bh+akk08_2
                dw      2b2bh+akk08_2
                dw      0b2dh+akk04_2
                dw      0b2bh+akk00_2
                dw      1b2bh+akk08_2
                dw      2b2bh+akk08_2
                seqend

y17:                                                            ;Chords.
                snd chord
                dw      1f2eh+akk10_2
                dw      3f2eh+akk10_2
                dw      3f2eh+akk10_2
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                seqend
;-------------------------------------------------------------------------------
s26:                                                            ;BIIIG pause!
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                seqend
s27:                                                            ;Chords.
                snd chord
                dw      1f2eh+akk10_3
                dw      3f2eh+akk10_3
                dw      3f2eh+akk10_3
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                rest    1fh
                seqend
s28:                                                            ;BIIIG pause!
                rest    0bh
                rest    0bh
                rest    1bh
                rest    0bh
                rest    0bh
                rest    0bh
                rest    1bh
                rest    0bh
                seqend
;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------
datainfo        db      '                              '        ;Any length!

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
