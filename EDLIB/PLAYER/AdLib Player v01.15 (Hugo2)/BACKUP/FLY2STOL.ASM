;-------------------------------------------------------------------------------
; MUSIC DATA - Player by JCH/Vibrants.           ...Remember to alter DATAINFO!
;-------------------------------------------------------------------------------
; Hugo II, fly-scenen - Hugo falder ned efter et megalyn har ramt flyet...
;-------------------------------------------------------------------------------
public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicdata       segment public
assume          ds:musicdata

include         commands.mac
;-------------------------------------------------------------------------------
version1        db      01h                     ;Major music-player version
timer           db      70                      ;Timerspeed for the block
max             db      3                       ;Number of music & sfx's

general         dw      tpoin                   ;00h
                dw      seqpointer              ;01h
                dw      instrument              ;02h
                dw      datainfo                ;03h
                dw      levelpuls               ;04h

		dw	0ffffh			;Endmark
;-------------------------------------------------------------------------------
seqpointer      dw      s00,s01,s02,s03,s04
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      tk7,tk7,tk7,00h,00h,00h,00h,00h,00h     ;Flyet forkuller
                db      00h,00h,04h,00h,00h,00h,00h,00h,00h
              ; db      3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk1,tk2,tk3,00h,00h,00h,00h,00h,00h     ;AÜÜÜÜÜh...
                db      00h,10h,14h,00h,00h,00h,00h,00h,00h
	      ; db	3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh
                db      0,0,0,0,0

                dw      tk4,tk5,tk6,00h,00h,00h,00h,00h,00h     ;Skh (not HUHT!)
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

                db      0ffh,004h,00h,01100010b,1               ;C001   èÜÜh!
                db      0ffh,021h,00h,01100001b,1,(4*2)+0
                db      0,0,0,0,0
                aaah    equ     1

                db      0ffh,007h,00h,00100011b,0               ;C002   Dunk
                db      0ffh,007h,00h,00100001b,0,(0*2)+1
                db      0,0,0,0,0
                dunk    equ     2

                db      0f7h,087h,00h,00100000b,0               ;C003   Noise
                db      0ffh,000h,00h,00100000b,0,(6*2)+0
                db      0,0,0,0,0
                noise   equ     3
                bb      equ     0

                db      0afh,004h,08h,00100000b,0               ;C004   Noise 2
                db      0ffh,000h,00h,00101111b,0,(7*2)+0
                db      0,0,0,0,0
                noise2  equ     4

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
tk1             dw      1                                       ;èÜÜÜh...
                dw      8000h,1
                tstop

tk2             dw      1                                       ;èÜÜÜh...
                dw      8000h,0,0,1
                tstop

tk3             dw      1                                       ;èÜÜÜh...
                dw      8000h,0,0,0,0,0,0,1
                tstop

tk4             dw      1                                       ;Skrsh!
                dw      8000h,2
                tstop

tk5             dw      1                                       ;Skrsh!
                dw      8000h,3
                tstop

tk6             dw      1                                       ;Skrsh!
                dw      8001h,0,2
                tstop

tk7             dw      1                                       ;Forkulning
                dw      8000h,0,4
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

s01:                                                            ;èÜÜÜh...
                snd aaah
                up 2
                dw      0531h
                down 2
                vib 0a01h
                rest 07h
                down 1
                vib 0000h
                rest 1fh
                vib 0601h
                rest 1fh
                seqend

s02:                                                            ;Skrsh!
                snd dunk
                down 20h
                dw      0012h
                rest 3
                cut 2
                down 1
                lvl 4
                dw      0008h
                rest 2
                seqend

s03:                                                            ;Skrsh!
                snd noise
              ; down 10h
                dw      0701h+bb
              ; down 8
                lvl 4
                dw      0001h+bb
                rest 2
                cut 0
                seqend

s04:                                                            ;Forkulning
                snd noise2
                dw      0701h
                rest 1fh
                rest 1fh
                rest 1fh
                rest 1fh
                cut 0
                seqend

;-------------------------------------------------------------------------------
datainfo        label byte
              ; db      ' '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
