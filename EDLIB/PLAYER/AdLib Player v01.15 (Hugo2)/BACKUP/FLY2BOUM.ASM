;-------------------------------------------------------------------------------
; MUSIC DATA - Player by JCH/Vibrants.           ...Remember to alter DATAINFO!
;-------------------------------------------------------------------------------
; Hugo II fly-scenen - Hugo t›flede ind i en r›d ballon.   Dumt.
;-------------------------------------------------------------------------------
public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
version1        db      01h                     ;Major music-player version
timer           db      70                      ;Timerspeed for the block
max             db      5                       ;Number of music & sfx's

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      tk1,tk2,tk3,tk4,00h,00h,00h,00h,00h     ;Knirk og klank
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      00h,00h,00h,00h,tk5,00h,00h,00h,00h     ;Fly'et falder
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0
                
                dw      00h,00h,00h,00h,tk6,tk7,00h,00h,00h     ;Hugo falder
                db      00h,00h,00h,00h,00h,10h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      00h,00h,tk8,tk9,t10,t11,t12,t13,t14     ;Hult brag
                db      00h,00h,00h,10h,00h,00h,00h,18h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      t15,t16,t17,t18,00h,00h,00h,00h,00h     ;Fly'et br‘nder
                db      00h,00h,08h,34h,00h,00h,00h,00h,00h
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
instrument      db      0ffh,0ffh,3fh,00100000b,0               ;C000   CUT!
                db      0ffh,0ffh,3fh,00100000b,0,(0*2)+0
                db      0,0,0,0,0
                empty   equ     0

                db      066h,049h,00h,00101100b,1               ;C001   Knirk
                db      044h,039h,00h,00101111b,3,(0*2)+0
                db      0,0,0,0,0
                trolje1 equ     1

                db      0fdh,006h,00h,00001000b,0               ;C002   Klank
                db      0fah,023h,00h,00000000b,0,(4*2)+0
                db      0,0,0,0,0
                trolje2 equ     2
                cc      equ     5

                db      08fh,004h,08h,00101000b,0               ;C003   Fly fald
                db      08fh,004h,10h,00101100b,0,(0*2)+1
                db      0,0,0,0,0
                flyfald equ     3

                db      0f5h,034h,00h,00100100b,1               ;C004   Piouw!
                db      0f8h,034h,08h,00000100b,0,(7*2)+1
                db      0,0,0,0,0
                piouw   equ     4

                db      0ffh,007h,00h,00100010b,0               ;C004   Dunk
                db      0ffh,007h,00h,00100100b,0,(0*2)+1
                db      0,0,0,0,0
                dunk    equ     5

                db      0ffh,008h,0ch,00100000b,0               ;C005   Hakken
                db      0ffh,005h,05h,00000000b,0,(6*2)+0
                db      0,0,0,0,0
                noise   equ     6

                db      0ffh,007h,04h,00100010b,0               ;C006   Bulder
                db      0ffh,00ch,0eh,00100001b,0,(0*2)+0
                db      0,0,0,0,0
                bulder  equ     7

                db      0ffh,006h,00h,00000011b,0               ;C007   Ballon
                db      0ffh,000h,13h,00000001b,0,(5*2)+0
                db      0,0,0,0,0
                bb      equ     1
                ballon  equ     8

                db      0ffh,00ah,00h,00000000b,0               ;C008   Ild-lyde
                db      0ffh,005h,00h,00100000b,0,(4*2)+0
                db      0,0,0,0,0
                ild     equ     9
                ddd     equ     8

                db      0ffh,007h,00h,00100000b,0               ;C009   Brusen
                db      0ffh,000h,00h,00101111b,0,(7*2)+0
                db      0,0,0,0,0
                brusen  equ     0ah
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
tk1             dw      1                                       ;Knirk og klank
                dw      8000h,4,8005h,3
                tstop

tk2             dw      1                                       ;Knirk og klank
                dw      8000h,2,2,2
                tstop

tk3             dw      1                                       ;Knirk og klank
                dw      8000h,1,1,1
                tstop

tk4             dw      1                                       ;Knirk og klank
                dw      8000h,4,8000h,3
                tstop

tk5             dw      1                                       ;Fly'et falder
                dw      8000h,5
                tstop

tk6             dw      1                                       ;Hugo falder
                dw      8000h,6
                tstop

tk7             dw      1                                       ;Hugo falder
                dw      8000h,0,6
                tstop

tk8             dw      1                                       ;Buldren...
                dw      8000h,07h
                tstop

tk9             dw      1                                       ;Buldren...
                dw      8000h,0,0,0,0,0,0,07h
                tstop

t10             dw      1                                       ;Hult brag
                dw      8000h,08h
                tstop

t11             dw      1                                       ;Hult brag
                dw      8000h,09h
                tstop

t12             dw      1                                       ;Hult brag
                dw      8000h,0ah
                tstop

t13             dw      1                                       ;Hult brag
                dw      8000h,0bh,7
                tstop

t14             dw      1                                       ;Hult brag
                dw      8000h,0,0,0ah
                tstop

t15             dw      4                                       ;Fly'et br‘nder
                dw      8000h,0ch,0ch
                tstop

t16             dw      8                                       ;Fly'et br‘nder
                dw      8000h,0ch
                tstop

t17             dw      6                                       ;Fly'et br‘nder
                dw      8000h,0ch
                tstop

t18             dw      7                                       ;Fly'et br‘nder
                dw      8000h,0dh,0eh,0eh,0fh
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

s01:                                                            ;Knirk og klank
                rest 1
                lvl 4
                snd trolje1
                dw      053ah
                dw      053ah
                rest 00h
                cut 7
                seqend

s02:                                                            ;Knirk og klank
                snd trolje1
                lvl 0
                dw      013ah
                rest 0ch
                cut 7
                seqend

s03:                                                            ;Knirk og klank
                snd trolje2
                lvl 12h
                dw      0004h+cc
                lvl 0
                down 10h
                lvl 0ch
                dw      0406h+cc
                down 8
                lvl 4
                dw      0204h+cc
                lvl 0
                dw      0304h+cc
                cut 0
                seqend

s04:                                                            ;Pause
                cut 10h
                seqend

s05:                                                            ;Fly'et falder
                snd flyfald
                up 8
                dw      0138h
                down 3
                cont 0fh
                down 2
                cont 0fh
                down 1
                rest 12h
                cut 0
                seqend

s06:                                                            ;Hugo falder
                snd piouw
                dw      0e010h
                dw      0345h,0e001h
                rest 1fh
                rest 0fh
                cut 0
                seqend

s07:                                                            ;Buldren...
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

s08:                                                            ;R›d ballon BUM
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

s09:                                                            ;R›d ballon BUM
                snd noise
                cut 1
                down 04h
                dw      0a16h
                rest 3
                cut 0
                seqend

s0a:                                                            ;R›d ballon BUM
                snd ballon
                cut 1
                down 4
                dw      1f0ch+bb
                cont 0fh
                cut 0
                seqend

s0b:                                                            ;R›d ballon BUM
                cut 10h
                seqend

s0c:                                                            ;Fly'et br‘nder
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

s0d:                                                            ;Brusen
                snd brusen
                dw      0001h
                seqend

s0e:                                                            ;Brusen
                cont 1fh
                seqend

s0f:                                                            ;Brusen
                rest 03h
                cut 0
                seqend
;-------------------------------------------------------------------------------
datainfo        label byte
              ; db      '  '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
