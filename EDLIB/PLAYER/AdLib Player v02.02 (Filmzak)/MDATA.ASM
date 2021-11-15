;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  Normal 9-voice ADLIB data block. Remember to alter VERSION1 and DATAINFO.  ³
;³                                                                             ³
;³  Vistnok ingen forskydelses-bugs nu.                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
timer           db      35                      ;Timerspeed for the block
max             db      1                       ;Number of music & sfx's
card            db      00h                     ;00h for normal Adlib

blockname       db      'Film-type music                 '      ;32 bytes names
composer        db      'Thomas Mogensen (DRAX)          '

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
                dw      s1c,s1d,s1e,s1f,s20,s21,s22,s23
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin		dw	tk1,tk2,tk3,tk4,tk5,tk6,tk7,tk8,tk9
                db      00h,00h,00h,00h,00h,02h,08h,3fh,3fh
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

                db      0afh,025h,00h,00100000b,0               ;c001   echo
                db      041h,0e1h,0ah,00100000b,1,(3*2)+0
                db      0,0,0,0,0
                echo    equ     1

                db      0ffh,004h,00h,00100011b,0               ;c002   Bass
                db      04fh,003h,0ah,01100001b,1,(2*2)+0
                db      1,3,0,0,0
                bass    equ     2

                db      096h,023h,00h,00100001b,1               ;c003   Chord
                db      043h,068h,10h,00100010b,1,(1*2)+0
                db      0,0,0,0,0
                ch_038  equ     3
                ch_047  equ     3
                ch_05a  equ     3
                ch_059  equ     3
                ch_03a  equ     3

                db      08fh,008h,04h,00100000b,1               ;c004   Leader
                db      043h,0c8h,0ch,00100001b,2,(4*2)+0
                db      0,0,0,0,0
                leader  equ     4

                db      0ffh,004h,00h,01100011b,1               ;c005   LeadOct
                db      031h,062h,0ch,01100001b,2,(4*2)+0
                db      0,0,0,0,0
                leadoct equ     5

;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h         Set level 00-3f (ff=Continue with last set or instr's level)
; 0001h 	Speed 00-ff (01=slow up, ff=slow down) - see also frameskipper!
; 0002h         Duration 00-ff before next set is read
; 0003h         Pointer to next set
;-------------------------------------------------------------------------------
levelpuls       db      0ffh,001h,018h,002h     ;1
                db      0ffh,0ffh,018h,001h     ;2


;-------------------------------------------------------------------------------
; Values        Comments
;-------------------------------------------------------------------------------
; -----		First position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;-------------------------------------------------------------------------------
tk1             dw      tspeed                                  ;Bass
                dw      800ch,0001h,000ah,000ah,000ah,000ah,000ah,000ah
                dw      000ah,000ah,000ah,000ah,000ah,000ah,000ah,000ah
                dw      000fh,0011h,0014h,0017h
                twrap   0

tk2             dw      tspeed                                  ;Leader
                dw      800ch,0002h,0003h,0004h,0005h,0002h,0003h,0004h
                dw      0005h,0002h,0003h,0004h,0005h,0002h,0003h,0004h
                dw      0005h,8000h,0010h,0013h,800ch,0016h
                twrap   0

tk3             dw      tspeed                                  ;Echo/Chords 1
                dw      0
                dw      800ch,0006h,0007h,0008h,0009h,0006h,0007h,0008h
                dw      0009h,8000h,000bh,000ch,000dh,000eh,0,000bh,000ch
                dw      000dh,000eh,800ch,0012h,0015h,0015h
                twrap   0

tk4             dw      tspeed                                       ;Chords 2
                dw      000ah,000ah,000ah,000ah,000ah,000ah,000ah
                dw      000ah,8000h,0018h,0019h,001ah,001bh,0018h,0019h
                dw      001ah,001bh,800ch,001ch,001dh,001dh
                twrap   0

tk5             dw      tspeed                                       ;Chords 3
                dw      000ah,000ah,000ah,000ah,000ah,000ah,000ah
                dw      000ah,8000h,001eh,001fh,0020h,0021h,001eh,001fh
                dw      0020h,0021h,800ch,0022h,0023h,0023h
                twrap   0

tk6             dw      tspeed                                  ;Bass echo
                dw      8000h,0001h,000ah,000ah,000ah,000ah,000ah,000ah
                dw      000ah,000ah,000ah,000ah,000ah,000ah,000ah,000ah
                dw      000fh,0011h,0014h,0017h
                twrap   0

tk7             dw      tspeed                                  ;Leader echo
                dw      0,0
                dw      800ch,0002h,0003h,0004h,0005h,0002h,0003h,0004h
                dw      0005h,0002h,0003h,0004h,0005h,0002h,0003h,0004h
                dw      0005h,8000h,0010h,0013h,800ch,0016h
                twrap   2

tk8             dw      tspeed
                tstop

tk9             dw      tspeed
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
s6042h  equ     0403h   ;Vibrato

s0040h  equ     12      ;Up
;-------------------------------------------------------------------------------
s00:
                cut 0000h
                seqend

s01:
                snd bass
                dw      1f0ch
                cont 001fh
                seqend

s02:
                snd leader
                dw      0a24h
                vib s6042h
                cont 0004h
                dw      0a2bh
                vib s6042h
                cont 0004h
                dw      0930h
                vib s6042h
                cont 0005h
                dw      0929h
                vib s6042h
                cont 0005h
                seqend

s03:
                dw      0128h,2129h
                dw      2328h
                dw      2326h
                up s0040h
                dw      0126h,2128h
                vib s6042h
                cont 0007h
                dw      2324h
                dw      0a1fh
                vib s6042h
                cont 0010h
                dw      071fh
                seqend

s04:
                dw      0921h
                vib s6042h
                cont 0005h
                dw      082ah
                vib s6042h
                cont 0006h
                dw      0b2dh,0b2ah,0726h
                seqend

s05:
                up s0040h
                dw      0122h,2924h
                vib s6042h
                cont 0014h
                cont 0016h
                dw      071fh
                seqend

s06:
                snd echo
                dw      0a24h
                vib s6042h
                cont 0004h
                dw      2a2bh
                vib s6042h
                cont 0004h
                dw      2930h
                vib s6042h
                cont 0005h
                dw      2929h
                seqend

s07:
                cont 0005h
                dw      2128h
                dw      2129h
                dw      2328h
                dw      2326h
                up s0040h
                dw      0126h,2128h
                vib s6042h
                cont 0007h
                dw      2324h
                dw      2a1fh
                vib s6042h
                cont 0010h
                dw      211fh
                seqend

s08:
                cont 0005h
                dw      2921h
                vib s6042h
                cont 0005h
                dw      282ah
                vib s6042h
                cont 0006h
                dw      2b2dh
                dw      2b2ah
                dw      2126h
                seqend

s09:
                rest 5
                up s0040h
                dw      0122h,2924h
                vib s6042h
                cont 0013h
                cont 0013h
                rest 3
                dw      071fh
                seqend

s0a:
                cont 001fh
                cont 001fh
                seqend

s0b:
                snd ch_038
                dw      0e28h
              ; snd ch_047
                dw      0f30h
              ; snd ch_038
                dw      0f34h
              ; snd ch_05a
                dw      0f2bh
                seqend

s0c:
              ; snd ch_059
                dw      012bh
              ; snd ch_05a
                dw      212bh
              ; snd ch_059
                dw      032bh
              ; snd ch_03a
                dw      2328h
              ; snd ch_059
                dw      0b2bh
              ; snd ch_038
                dw      2328h
              ; snd ch_059
                dw      1b2bh
              ; snd ch_047
                dw      0724h
                seqend

s0d:
                dw      0f26h
              ; snd ch_059
                dw      0f2dh
              ; snd ch_047
                dw      0b32h
              ; snd ch_059
                dw      0b2dh
              ; snd ch_038
                dw      072ah
                seqend

s0e:
              ; snd ch_05a
                dw      172bh
              ; snd ch_059
                dw      3f2bh
              ; snd ch_047
                dw      0724h
                seqend

s0f:
                cont 001fh
                cont 0017h
                dw      0707h
                seqend

s10:
                snd leadoct
                dw      0121h,2124h
                dw      2121h
                dw      2124h
                dw      2129h
                dw      2124h
                dw      2129h
                dw      2124h
                dw      212dh
                dw      2129h
                dw      212dh
                dw      2129h
                dw      2130h
                dw      212dh
                dw      2130h
                dw      212dh
                dw      2f33h
                dw      2732h
                dw      2730h
                seqend

s11:
                snd bass
                dw      1f05h
                dw      1f08h
                seqend

s12:
              ; snd ch_059
                dw      1f24h
              ; snd ch_038
                dw      1f24h
                seqend

s13:
                dw      1f30h
                dw      0f2fh
                snd leader
                dw      0326h,032bh,032fh,0031h,2232h
                seqend

s14:
                dw      1f07h
                cont 001fh
                seqend

s15:
              ; snd ch_05a
                dw      1f26h
              ; snd ch_059
                dw      1026h
                cont 000bh
                rest 2
                seqend

s16:
                snd leadoct
                dw      0324h,232bh
                dw      2330h
                dw      232bh
                dw      2124h
                dw      212bh
                dw      2130h
                dw      212bh
                dw      2124h
                dw      212bh
                dw      2130h
                dw      212bh
                dw      302fh
                rest 000bh
                rest 2
                seqend

s17:
                dw      0f13h,0f0eh,1013h
                rest 000eh
                seqend
;-------------------------------------------------------------------------------
s18:
                snd ch_038
                dw      0f28h+3
              ; snd ch_047
                dw      0f30h+4
              ; snd ch_038
                dw      0f34h+3
              ; snd ch_05a
                dw      0f2bh+5
                seqend

s19:
              ; snd ch_059
                dw      012bh+5
              ; snd ch_05a
                dw      212bh+5
              ; snd ch_059
                dw      032bh+5
              ; snd ch_03a
                dw      2328h+3
              ; snd ch_059
                dw      0b2bh+5
              ; snd ch_038
                dw      2328h+3
              ; snd ch_059
                dw      1b2bh+5
              ; snd ch_047
                dw      0724h+4
                seqend

s1a:
                dw      0f26h+4
              ; snd ch_059
                dw      0f2dh+5
              ; snd ch_047
                dw      0b32h+4
              ; snd ch_059
                dw      0b2dh+5
              ; snd ch_038
                dw      072ah+3
                seqend

s1b:
              ; snd ch_05a
                dw      172bh+5
              ; snd ch_059
                dw      3f2bh+5
              ; snd ch_047
                dw      0724h+4
                seqend

s1c:
              ; snd ch_059
                dw      1f24h+5
              ; snd ch_038
                dw      1f24h+3
                seqend

s1d:
              ; snd ch_05a
                dw      1f26h+5
              ; snd ch_059
                dw      1026h+5
                cont 000bh
                rest 2
                seqend
;-------------------------------------------------------------------------------
s1e:
                snd ch_038
                dw      0f28h+8
              ; snd ch_047
                dw      0f30h+7
              ; snd ch_038
                dw      0f34h+8
              ; snd ch_05a
                dw      0f2bh+0ah
                seqend

s1f:
              ; snd ch_059
                dw      012bh+9
              ; snd ch_05a
                dw      212bh+0ah
              ; snd ch_059
                dw      032bh+9
              ; snd ch_03a
                dw      2328h+0ah
              ; snd ch_059
                dw      0b2bh+9
              ; snd ch_038
                dw      2328h+8
              ; snd ch_059
                dw      1b2bh+9
              ; snd ch_047
                dw      0724h+7
                seqend

s20:
                dw      0f26h+7
              ; snd ch_059
                dw      0f2dh+9
              ; snd ch_047
                dw      0b32h+7
              ; snd ch_059
                dw      0b2dh+9
              ; snd ch_038
                dw      072ah+8
                seqend

s21:
              ; snd ch_05a
                dw      172bh+0ah
              ; snd ch_059
                dw      3f2bh+9
              ; snd ch_047
                dw      0724h+7
                seqend

s22:
              ; snd ch_059
                dw      1f24h+9
              ; snd ch_038
                dw      1f24h+8
                seqend

s23:
              ; snd ch_05a
                dw      1f26h+0ah
              ; snd ch_059
                dw      1026h+9
                cont 000bh
                rest 2
                seqend

;-------------------------------------------------------------------------------

datainfo:

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
