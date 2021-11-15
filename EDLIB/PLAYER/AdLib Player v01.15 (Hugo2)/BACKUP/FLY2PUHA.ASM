;-------------------------------------------------------------------------------
; MUSIC DATA - Player by JCH/Vibrants.           ...Remember to alter DATAINFO!
;-------------------------------------------------------------------------------
; Hugo II fly-scenen - Hugo er l›bet "t›r" og falder ned (Til en afveksling!).
;-------------------------------------------------------------------------------
public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
version1        db      01h                     ;Major music-player version
timer           db      70                      ;Timerspeed for the block
max             db      6                       ;Number of music & sfx's

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      t17,t18,t19,t20,00h,00h,00h,00h,00h     ;Motor-hak
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
              ; db      3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk1,tk2,00h,00h,00h,00h,00h,00h,00h     ;Piouw!
                db      00h,10h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk3,tk4,00h,00h,00h,00h,00h,00h,00h     ;Quick falling
                db      00h,08h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0
                
                dw      00h,00h,tk5,tk6,00h,00h,00h,00h,00h     ;Bremse lyd
                db      00h,00h,00h,0ch,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk7,00h,00h,00h,00h,00h,00h,00h,00h     ;Lineal-lyd
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk8,tk9,t10,t11,t12,t13,t14,t15,t16     ;BRAG! (Klir!)
                db      00h,10h,00h,00h,00h,18h,00h,00h,04h
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

                db      0f5h,034h,00h,00100100b,1               ;C001   Piouw!
                db      0f8h,034h,08h,00000100b,0,(7*2)+1
                db      0,0,0,0,0
                piouw   equ     1

                db      03fh,006h,00h,00100001b,1               ;C002   Quick
                db      0ffh,000h,00h,00100100b,0,(5*2)+0
                db      0,0,0,0,0
                qfall   equ     2

                db      0ffh,006h,00h,00100000b,3               ;C003   Skriiid!
                db      0ffh,014h,00h,00000001b,2,(3*2)+0
                db      0,0,0,0,0
                skrid   equ     3

                db      07fh,006h,00h,00100010b,3               ;C004   Skrid2
                db      0ffh,000h,3fh,00100011b,0,(0*2)+0
                db      0,0,0,0,0
                skrid2  equ     4

                db      0f9h,009h,00h,01001111b,1               ;C005   Lineal
                db      0f9h,009h,00h,01000100b,1,(2*2)+0
                db      0,0,0,0,0
                lineal  equ     5

                db      0ffh,007h,00h,00100010b,0               ;C006   Dunk
                db      0ffh,007h,00h,00100100b,0,(0*2)+1
                db      0,0,0,0,0
                dunk    equ     6

                db      0ffh,008h,00h,00100000b,0               ;C007   Hakken
                db      0ffh,005h,05h,00000000b,0,(6*2)+0
                db      0,0,0,0,0
                noise   equ     7

                db      0ffh,007h,00h,00100010b,0               ;C008   Bulder
                db      0ffh,00ch,0eh,00100001b,0,(0*2)+0
                db      0,0,0,0,0
                bulder  equ     8

                db      0ffh,005h,00h,00000011b,0               ;C009   Ballon
                db      0ffh,000h,00h,10000001b,0,(5*2)+0
                db      0,0,0,0,0
                bb      equ     2
                ballon  equ     9

                db      0ffh,00ah,00h,00000100b,0               ;C00A   Klir
                db      0ffh,000h,00h,00101000b,0,(1*2)+0
                db      0,0,0,0,0
                klir    equ     0ah

                db      0ffh,007h,00h,00000000b,0               ;C00B   Crash
                db      0ffh,000h,00h,00100000b,0,(7*2)+0
                db      0,0,0,0,0
                crash   equ     0bh

                db      0ffh,00ah,00h,00000000b,0               ;C00C   Ild-lyde
                db      0ffh,005h,00h,00100000b,0,(4*2)+0
                db      0,0,0,0,0
                ild     equ     0ch
                ddd     equ     8

                db      0ffh,007h,34h,00100000b,0               ;C00D   Brusen
                db      0ffh,000h,00h,00101111b,0,(7*2)+0
                db      0,0,0,0,0
                brusen  equ     0dh

                db      0ffh,005h,08h,00100000b,3               ;C00E   Motor 5
                db      0ffh,023h,00h,00100001b,3,(6*2)+0
                db      0,0,0,0,0
                motor5  equ     0eh

                db      0ffh,006h,05h,00100000b,0               ;C00F   Motor 7
                db      0ffh,023h,00h,00100001b,2,(2*2)+0
                db      0,0,0,0,0
                motor7  equ     0fh

;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h         Set level 00-3f (ff=Continue with last set or instr's level)
; 0001h 	Speed 00-ff (01=slow up, ff=slow down) - see also frameskipper!
; 0002h         Duration 00-ff before next set is read
; 0003h         Pointer to next set
;-------------------------------------------------------------------------------
levelpuls       label byte
              ; db      006h,001h,000h,002h     ;1
              ; db      0ffh,001h,02ah,003h     ;2
              ; db      0ffh,0ffh,02ah,002h     ;3

              ; db      008h,001h,010h,005h     ;4
              ; db      0ffh,000h,000h,005h     ;5

;-------------------------------------------------------------------------------
; Values        Comments
;-------------------------------------------------------------------------------
; -----		First position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;-------------------------------------------------------------------------------
tk1             dw      1                                       ;Piouw!
                dw      8000h,1
                tstop

tk2             dw      1                                       ;Piouw!
                dw      8000h,0,1
                tstop

tk3             dw      1                                       ;Quick falling
                dw      8000h,2
                tstop

tk4             dw      1                                       ;Quick falling
                dw      8000h,3
                tstop

tk5             dw      1                                       ;Bremse lyd
                dw      8000h,4
                tstop

tk6             dw      1                                       ;Bremse lyd
                dw      8001h,4
                tstop

tk7             dw      1                                       ;Lineal lyd
                dw      8000h,5
                tstop

tk8             dw      1                                       ;Buldren...
                dw      8000h,6,0eh,0fh
                twrap   3

tk9             dw      1                                       ;Buldren...
                dw      8000h,0bh,6
                tstop

t10             dw      1                                       ;Brag
                dw      8000h,7
                tstop

t11             dw      1                                       ;Brag
                dw      8000h,8,0,0bh
                tstop

t12             dw      1                                       ;Brag
                dw      8000h,9
                tstop

t13             dw      1                                       ;Brag
                dw      8000h,0ah,6,0bh
                tstop

t14             dw      1                                       ;Brag
                dw      8000h,0,0,9
                tstop

t15             dw      4                                       ;Klir klir
                dw      8000h,0ch,0bh,0bh,0dh
                twrap   4

t16             dw      6                                       ;Ild
                dw      8000h,0ah,0dh
                twrap   2

t17             dw      1                                       ;Motorhakken
                dw      8000h,11h
                tstop

t18             dw      1                                       ;Motorhakken
                dw      8000h,12h
                tstop

t19             dw      1                                       ;Motorhakken
                dw      8000h,13h
                tstop

t20             dw      1                                       ;Motorhakken
                dw      8000h,14h
                tstop

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

s01:                                                            ;Piouw!
                snd piouw
                dw      0e010h
                dw      0345h,0e001h
                rest 1fh
                rest 0fh
                cut 0
                seqend

s02:                                                            ;Quick falling
                snd qfall
                cut 0
                dw      073ah
                down 1
                cont 07h
                cont 1ah
                rest 9
                cut 0
                seqend

s03:                                                            ;Quick falling
                snd qfall
                cut 0
                down 3
                dw      003ah
                down 0
                cont 6
                down 1
                cont 07h
                cont 1ah
                rest 9
                cut 0
                seqend

s04:                                                            ;Bremse lyd
                cut 0
                snd skrid2
                down 2
                lvl 8
                vib 0420h
                dw      094ah
                lvl 8
                snd skrid
                dw      0041h
                rest 0
                dw      0040h
                lvl 4
                dw      003fh
                lvl 2
                dw      003eh
                rest 0
                lvl 0
                dw      003eh
                down 8
                cont 1
                up 8
                cont 1
                down 8
                cont 1
                up 8
                cont 1
                down 8
                rest 2
                cut 0
                seqend

s05:                                                            ;Lineal
                snd lineal
                dw      000ah+5,000bh+5,9000h
                dw      000bh+5,000ah+5,9002h
                dw      000ah+5,000bh+5,9004h
                dw      000bh+5,000ch+5,9006h
                dw      000ch+5,000bh+5,9008h
                dw      000bh+5,000ch+5,900ah
                dw      000ch+5,000dh+5,900ch
                dw      000dh+5,000ch+5,9010h
                dw      000ch+5,000dh+5,9013h
                dw      000dh+5,000eh+5,9015h
                dw      000eh+5,000dh+5,9018h
                dw      000dh+5,000eh+5,9020h
                dw      000eh+5,000fh+5,9028h
                dw      000fh+5,000eh+5,9030h
                dw      000eh+5,000fh+5,9038h
                rest 2
                seqend

s06:                                                            ;Buldren...
                snd bulder
                down 6
                dw      0301h
                down 5
                dw      0202h
                down 4
                dw      0304h
                down 5
                dw      0105h
                down 3
                dw      0106h
                down 5
                dw      0207h
                down 4
                dw      0106h
                down 4
                dw      0205h
                down 4
                dw      0303h
                down 4
                dw      0402h
                seqend

s07:                                                            ;Bl† ballon BUM
                snd dunk
                down 20h
                dw      000ch
                cut 0
                down 10h
                dw      0312h
                down 10h
                dw      0310h
                down 10h
                lvl 3
                dw      030eh
                down 10h
                lvl 6
                dw      030ch
                down 10h
                lvl 9
                dw      030ah
                rest 3
                seqend

s08:                                                            ;Bl† ballon BUM
                snd noise
                cut 1
                down 04h
                dw      0a16h
                rest 3
                cut 0
                seqend

s09:                                                            ;Bl† ballon BUM
                snd ballon
                cut 1
                down 10
                dw      1f0ch+bb
                cont 0fh
                cut 0
                seqend

s0a:                                                            ;Bl† ballon BUM
                cut 10h
                seqend

s0b:                                                            ;Klir
                snd klir
                dw      0014h
                dw      0018h
                dw      001ch
                dw      0014h
                dw      0017h
                dw      001eh
                dw      0015h
                dw      0116h
                dw      0013h
                dw      0118h
                dw      0019h
                dw      0112h
                lvl 04h
                dw      0216h
                lvl 08h
                dw      0111h
                lvl 10h
                dw      031ah
                lvl 14h
                dw      0214h
                cut 0
                seqend

s0c:                                                            ;Crash
                snd crash
                dw      050ch
                seqend

s0d:                                                            ;Fly'et br‘nder
                snd ild
                lvl 8
                dw      0102h+ddd
                lvl 0
                dw      0003h+ddd
                dw      0104h+ddd
                lvl 4
                dw      0202h+ddd
                lvl 8
                dw      0104h+ddd
                lvl 2
                dw      0302h+ddd
                dw      0103h+ddd
                lvl 0
                dw      0002h+ddd
                lvl 4
                dw      0203h+ddd
                lvl 8
                dw      0104h+ddd
                dw      0302h+ddd
                lvl 2
                dw      0302h+ddd
                lvl 0
                dw      0104h+ddd
                dw      0003h+ddd
                lvl 4
                dw      0204h+ddd
                lvl 8
                dw      0103h+ddd
                lvl 4
                dw      0202h+ddd
                lvl 0
                dw      0104h+ddd
                dw      0304h+ddd
                dw      0303h+ddd
                lvl 8
                dw      0002h+ddd
                seqend

s0e:                                                            ;Brusen
                snd brusen
                dw      0001h
                seqend

s0f:                                                            ;Brusen
                cont 1fh
                seqend

s10:                                                            ;Brusen
                rest 03h
                cut 0
                seqend

s11:                                                            ;Motorhakken
                snd dunk
                down 30h
                lvl 4
                dw      0214h
                down 1ch
                lvl 2
                dw      0212h
                lvl 0
                down 10h
                dw      0212h
                down 20h
                lvl 6
                dw      0311h
                down 20h
                dw      0513h
                seqend

s12:                                                            ;Motorhakken
                snd noise
                dw      0312h
                cut 1
                lvl 04h
                dw      0312h
                lvl 8
                dw      0712h
                cut 0
                seqend

s13:                                                            ;Motorhakken
                snd motor5
                down 5
                dw      0708h
                cut 0
                dw      030ah
                seqend

s14:                                                            ;Motorhakken
                snd motor7
                down 3
                dw      0207h
                cut 0
                dw      0207h
                seqend

;-------------------------------------------------------------------------------
datainfo        label byte
              ; db      ' AdLib rules, but watch out for AdLib Gold 1000! '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
