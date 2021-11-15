;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  Normal 9-voice ADLIB/instr block - this system is for EDITOR usage only !  ³
;³                                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
public          version1,max,general,seqpointer,tpoin,instrument,datainfo
public          timer,levelpuls

musicinstr      segment public
assume          ds:musicinstr

include         commands.mac
;-------------------------------------------------------------------------------
detection       db      'JCH',26h,02h,66h       ;System detection bytes
kind            db      00h                     ;00h for music data block
version1        db      02h                     ;Major music-player version
timer           db      70                      ;Timerspeed for the block
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
seqpointer      dw      00h     ;Not in use in EDITOR player system.

;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      01h,01h,01h,01h,01h,01h,01h,01h,01h     ;Only the levels
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h     ;are used in the
              ; db      3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh,3fh     ;EDITOR player
              ; db      0,0,0,0,0                               ;system in the
                                                                ;normal way. The
              ; dw      0ffffh          ;Endmark                ;first 9 words
                                                                ;here only work
                                                                ;as ON/OFF flags
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
                org instrument+8000h

levelpuls	db	006h,001h,000h,002h	;1
		db	0ffh,001h,02ah,003h	;2
		db	0ffh,0ffh,02ah,002h	;3

                db      012h,001h,010h,005h     ;4
		db	0ffh,000h,000h,005h	;5

;-------------------------------------------------------------------------------
                org levelpuls+4000h

datainfo        db      ' AdLib EDITOR player (C) 1992 Jens-Christian Huus. '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
