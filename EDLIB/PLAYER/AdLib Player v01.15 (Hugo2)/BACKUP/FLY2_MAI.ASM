;-------------------------------------------------------------------------------
; MUSIC DATA - Player by JCH/Vibrants.           ...Remember to alter DATAINFO!
;-------------------------------------------------------------------------------
; Hugo II, Flyscenen MAIN BLOCK. Februar 1992. Update March 1992.
;-------------------------------------------------------------------------------
public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
version1        db      01h                     ;Major music-player version
timer           db      70                      ;Timerspeed for the block
max             db      12                      ;Number of music & sfx's

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16,s17
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      tk1,tk2,00h,00h,00h,00h,00h,00h,00h     ;Motorlyd
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk3,t11,00h,00h,00h,00h,00h,00h,00h     ;Stigning op
                db      80h,80h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk4,t26,00h,00h,00h,00h,00h,00h,00h     ;Fald tilbage
                db      80h,80h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0
                
                dw      tk5,tk5,00h,00h,00h,00h,00h,00h,00h     ;Motor fader ud
                db      80h,80h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      00h,00h,tk8,tk9,00h,00h,00h,00h,t10     ;Lyn
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      00h,00h,tk6,tk7,00h,00h,00h,00h,00h     ;Pick up
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      00h,00h,00h,00h,t12,t13,t14,00h,00h     ;Buldren...
                db      00h,00h,00h,00h,00h,04h,08h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0
                
                dw      00h,00h,t12,t14,t15,t16,t17,t18,t19     ;R›d ballon BUM
                db      00h,00h,00h,10h,00h,00h,00h,18h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      00h,00h,00h,00h,00h,00h,00h,t20,00h     ;Low on fuel
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      00h,00h,00h,00h,00h,00h,00h,00h,t21     ;Lineal-lyd
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      t22,t23,00h,00h,00h,00h,00h,00h,00h     ;Blafren...
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      t24,t25,00h,00h,00h,00h,00h,00h,00h     ;Fluff !
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

                db      0ffh,005h,08h,00100000b,3               ;C001   Motor 5
                db      0ffh,023h,00h,00100001b,3,(6*2)+0
                db      0,0,0,0,0
                motor5  equ     1

                db      0ffh,006h,05h,00100000b,0               ;C002   Motor 7
                db      0ffh,023h,00h,00100001b,2,(2*2)+0
                db      0,0,0,0,0
                motor7  equ     2

                db      0ffh,005h,00h,00100111b,1               ;C003   Pickup
                db      0f8h,003h,10h,00001000b,0,(0*2)+0
                db      0,0,0,0,0
                pickup  equ     3

                db      0ffh,007h,00h,00100010b,0               ;C004   Dunk
                db      0ffh,007h,00h,00100100b,0,(0*2)+1
                db      0,0,0,0,0
                dunk    equ     4

                db      0ffh,008h,00h,00100000b,0               ;C005   Hakken
                db      0ffh,005h,05h,00000000b,0,(6*2)+0
                db      0,0,0,0,0
                noise   equ     5

                db      0ffh,007h,00h,00100010b,0               ;C006   Bulder
                db      0ffh,00ch,0eh,00100001b,0,(0*2)+0
                db      0,0,0,0,0
                bulder  equ     6

                db      0ffh,005h,00h,00000011b,0               ;C007   Ballon
                db      0ffh,000h,00h,10000001b,0,(5*2)+0
                db      0,0,0,0,0
                bb      equ     2
                ballon  equ     7

                db      0ffh,006h,00h,00101010b,0               ;C008   Low fuel
                db      0ffh,002h,00h,00000000b,1,(4*2)+0
                db      0,0,0,0,0
                fuel    equ     8

                db      0f9h,009h,00h,01001111b,1               ;C009   Lineal
                db      0f9h,009h,00h,01000100b,1,(2*2)+0
                db      0,0,0,0,0
                lineal  equ     9

                db      07fh,007h,00h,00100001b,1               ;C00A   Blafren
                db      09fh,007h,00h,00000001b,1,(1*2)+0
                db      0,0,0,0,0
                blafren equ     0ah

                db      0ffh,006h,00h,00000011b,0               ;C00B   Dunk 2
                db      0ffh,006h,00h,00000100b,0,(0*2)+1
                db      0,0,0,0,0
                dunk2   equ     0bh

                db      0ffh,00fh,3fh,00000000b,0               ;C00C   Noise 2
                db      0ffh,003h,00h,00101111b,0,(7*2)+1
                db      0,0,0,0,0
                noise2  equ     0ch

                db      0ffh,004h,00h,00000000b,0               ;C00D   Torden
                db      0ffh,000h,00h,00100000b,0,(6*2)+0
                db      0,0,0,0,0
                torden  equ     0dh

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
tk1             dw      3                                       ;Motorlyd
                dw      8000h,1,3
                twrap   2

tk2             dw      3                                       ;Motorlyd
                dw      8000h,2,3
                twrap   2

tk3             dw      3                                       ;Stigning op
                dw      8000h,4,3
                twrap   2

tk4             dw      3                                       ;Fald tilbage
                dw      8000h,5,3
                twrap   2

tk5             dw      3                                       ;Motor fader ud
                dw      8000h,6
                tstop

tk6             dw      1                                       ;Pickup
                dw      8020h,7
                tstop

tk7             dw      1                                       ;Pickup
                dw      8020h,8
                tstop

tk8             dw      1                                       ;Motorhakken
                dw      8000h,9
                tstop

tk9             dw      1                                       ;Motorhakken
                dw      8000h,0ah
                tstop

t10             dw      1                                       ;Motorhakken
                dw      8000h,0bh
                tstop

t11             dw      3                                       ;Stigning op
                dw      8000h,0ch,3
                twrap   2

t12             dw      1                                       ;Buldren...
                dw      8000h,0dh
                tstop

t13             dw      1                                       ;Buldren...
                dw      8002h,0,0,0,0dh
                tstop

t14             dw      1                                       ;Buldren...
                dw      8000h,0,0,0,0,0,0,0dh
                tstop

t15             dw      1                                       ;Bl† ballon BUM
                dw      8000h,0eh
                tstop

t16             dw      1                                       ;Bl† ballon BUM
                dw      8000h,0fh
                tstop

t17             dw      1                                       ;Bl† ballon BUM
                dw      8000h,10h
                tstop

t18             dw      1                                       ;Bl† ballon BUM
                dw      8000h,11h,0dh
                tstop

t19             dw      1                                       ;Bl† ballon BUM
                dw      8000h,0,0,10h
                tstop

t20             dw      1                                       ;Low on fuel
                dw      8000h,12h
                tstop

t21             dw      1                                       ;Lineal
                dw      8000h,13h
                tstop

t22             dw      1                                       ;Blafren...
                dw      8000h,14h
                twrap   1

t23             dw      1                                       ;Blafren...
                dw      8000h,0,0,0,14h
                twrap   2

t24             dw      1                                       ;Fluff !
                dw      8000h,15h
                tstop

t25             dw      1                                       ;Fluff !
                dw      8000h,16h
                tstop

t26             dw      3                                       ;Fald tilbage
                dw      8000h,17h,3
                twrap   2

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

s01:                                                            ;Motorlyd
                snd motor5
                dw      0105h
                seqend

s02:                                                            ;Motorlyd
                snd motor7
                dw      0107h
                seqend

s03:                                                            ;Motorlyd
                cont 01h
                seqend

s04:                                                            ;Stigning op
                dw      2005h
                up 2
                cont 07h
                up 0
                dw      2007h
                seqend

s05:                                                            ;Fald tilbage
                dw      2007h
                down 2
                cont 07h
                down 0
                dw      2005h
                seqend

s06:                                                            ;Motor fader ud
                rest 1fh
                cut 0
                seqend

s07:                                                            ;Pickup
                snd pickup
                dw      0111h,2116h,211ah,211dh,2122h
                rest 0fh
                rest 1fh
                seqend

s08:                                                            ;Pickup
                cut 0
                snd pickup
                dw      010eh,2111h,2116h,211ah,211dh
                rest 0fh
                rest 1fh
                seqend

s09:                                                            ;Lyn
                snd dunk2
                down 20h
                dw      0222h
                down 20h
                dw      0220h
                down 20h
                dw      0218h
                down 10h
                dw      0214h
                down 10h
                dw      0212h
                down 8
                dw      0210h
                down 8
                dw      0208h
                down 10h
                dw      0212h
                down 8
                dw      0208h
                down 6
                lvl 04h
                dw      0206h
                down 8
                lvl 08h
                dw      0208h
                seqend

s0a:                                                            ;Lyn
                snd noise2
                dw      003fh
                rest 3
                lvl     08h
                dw      003fh
                rest 0ah
                cut 0
                seqend

s0b:                                                            ;Lyn
                snd torden
                down 08h
                dw      1f20h
                cut 0
                seqend

s0c:                                                            ;Stigning op
                dw      2007h
                up 2
                cont 07h
                up 0
                dw      2009h
                seqend

s0d:                                                            ;Buldren...
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

s0e:                                                            ;Bl† ballon BUM
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

s0f:                                                            ;Bl† ballon BUM
                snd noise
                cut 1
                down 04h
                dw      0a16h
                rest 3
                cut 0
                seqend

s10:                                                            ;Bl† ballon BUM
                snd ballon
                cut 1
                down 10
                dw      1f0ch+bb
                cont 0fh
                cut 0
                seqend

s11:                                                            ;Bl† ballon BUM
                cut 10h
                seqend

s12:                                                            ;Low on fuel
                snd fuel
                dw      0a24h
                rest 5
                seqend

s13:                                                            ;Lineal
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

s14:                                                            ;Blafren...
                snd blafren
                lvl 2
                dw      0101h
                cut 1
                lvl 0
                dw      0203h
                cut 0
                dw      0202h
                lvl 2
                dw      0101h
                cut 1
                lvl 0
                dw      0202h
                cut 1
                dw      0102h
                lvl 3
                dw      0201h
                cut 1
                dw      0202h
                cut 0
                lvl 0
                dw      0101h
                cut 1
                dw      0203h
                cut 0
                lvl 2
                dw      0102h
                seqend

s15:                                                            ;Fluff!
                snd ballon
                lvl 0ch
                dw      0107h
                rest 5
                lvl 0
                snd blafren
                down 08h
                dw      0711h
                cut 0
                seqend

s16:                                                            ;Fluff !
                snd dunk
                cut 7
                down 10h
                dw      070ch
                seqend

s17:                                                            ;Fald tilbage
                dw      2009h
                down 2
                cont 07h
                down 0
                dw      2007h
                seqend

;-------------------------------------------------------------------------------
datainfo        db      ' Hugo II sfx (C) Copyright 1992 Silverrock productions. AdLib player (C) Copyright 1992 JCH of VIBRANTS. '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
