;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  Sound Blaster/8-BIT DMA smpls/data block. Remember VERSION1 and DATAINFO.  ³
;³                                                                             ³
;³  CROONER with sampled drums.                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
tspeed          equ     2

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
timer           db      50                      ;Timerspeed for the block
max             db      1                       ;Number of music & sfx's
card            db      01h                     ;01h for normal Sound Blaster
                                                ;with samples in 8-BIT DMA.

blockname       db      'Crooner                         '      ;32 bytes names
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
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16
                dw      s17,s18,s19,s1a,s1b,s1c,s1d,s1e,s1f,s20,s21,s22,s23,s24
                dw      s25,s26
                dw      s27,s28,s29,s2a
                dw      s2b,s2c,s2d,s2e,s2f,s30
;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0011h   Offsets to tracks
; 0012h-001ah   Tracklevels 00-3f. Bit 7 (80h) ties start/stop sfx.
; 001bh-001fh   Unused, to align the tabels to 32 bytes.
;-------------------------------------------------------------------------------
tpoin           dw      tk1,tk2,tk3,tk4,tk5,tk6,tk7,tk8,tk9,t10
                db      00h,00h,00h,00h,00h,00h,08h,00h,10h,00h
              ; db      3fh,00h,3fh,3fh,3fh,00h,3fh,3fh,3fh,00h
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

                db      096h,014h,00h,00100001b,1               ;c001   "Gnamn"
                db      06fh,033h,00h,00000000b,2,(0*2)+0
                db      0,0,0,0,0
                gnamn   equ     1

                db      0cfh,005h,40h,00100001b,0               ;c002   Bass2
                db      0f4h,036h,0fh,00100000b,2,(5*2)+0
                db      0,0,0,0,0
                bass2   equ     2
                             ;34
                db      0aah,024h,00h,00100001b,1               ;c003   Chord
                db      0ffh,004h,0ah,00100001b,0,(3*2)+0
                db      0,0,0,0,0
                ch058   equ     3
                ch057   equ     3
                ch05a   equ     3
                ch038   equ     3
                ch049   equ     3
                ch047   equ     3
                ch059   equ     3
                ch037   equ     3
                ch046   equ     3

                db      0f9h,015h,00h,00100001b,1               ;c004   Leader
                db      0ffh,001h,08h,00000000b,2,(1*2)+0
                db      0,0,0,0,0
                lead10  equ     4
                lead12  equ     4


                db      0ffh,026h,00h,00100000b,0               ;c005   Wave11
                db      0f7h,064h,10h,00100001b,1,(4*2)+0
                db      0,0,0,0,0
                wave11  equ     5

                db      0cfh,005h,46h,01100001b,0               ;c006   Bass
                db      0ffh,005h,10h,01000001b,0,(0*2)+0
                db      0,0,0,0,0
                bass    equ     6

                db      0ffh,008h,10h,00000010b,0               ;c007   Tick
                db      0ffh,000h,0ah,00001000b,2,(6*2)+0
                db      0,0,0,0,0
                tick    equ     7

;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h         Set level 00-3f (ff=Continue with last set or instr's level)
; 0001h 	Speed 00-ff (01=slow up, ff=slow down) - see also frameskipper!
; 0002h         Duration 00-ff before next set is read
; 0003h         Pointer to next set
;-------------------------------------------------------------------------------
levelpuls:    ; db      010h,0fch,004h,002h     ;1
              ; db      0ffh,004h,004h,003h     ;2
              ; db      0ffh,000h,0ffh,003h     ;3

;-------------------------------------------------------------------------------
; Byte-steps    Comments
;-------------------------------------------------------------------------------
; 0000h-0001h   Sample offset start word
; 0002h-0003h   Sample length word
; 0004h-0005h   Reserved for future expansion (Like sample loop)
; 0006h         Sample rate byte (Time_constant)
; 0007h         Unused, to align the tabel to 8 bytes.
;-------------------------------------------------------------------------------
samples         dw      60h,12411,0
                db      256-1000000/22000,0                     ;Snare
                xsnare  equ     0

                dw      30e5h,8158,0
                db      256-1000000/22000,0                     ;Bassdrum
                xbassdr equ     1

;-------------------------------------------------------------------------------
maxsamp         db      1

names           db      'f:crooner.s01                                  ',0 ;48

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
tk1             dw      tspeed
                dw      8008h,0010h,8008h,0010h,0010h,0010h
                dw      0001h,0002h
                dw      0003h,0008h,0001h,0002h,0003h,0008h,000bh,000ch
                dw      000dh,000eh,8014h,0013h,0014h,0013h,0014h
                twrap   0

tk2             dw      tspeed
                dw      8008h,0004h,8008h,0005h,0004h,0005h,0004h,0005h
                dw      0004h,0005h,0004h,0005h,0004h,0005h,0009h,0009h
                dw      0009h,0015h,0004h,0005h,0004h,0005h
                twrap   0

tk3             dw      tspeed
                dw      8008h,0006h,8008h,0007h,0006h,0007h,0006h,0007h
                dw      0006h,0007h,0006h,0007h,0006h,0007h,000ah,000ah
                dw      000fh,0016h,0011h,0012h,0011h,0012h
                twrap   0

tk4             dw      tspeed
                dw      8008h,0017h,8008h,0018h,0017h,0018h,0017h,0018h
                dw      0017h,0018h,0017h,0018h,0017h,0018h,001ah,001ah
                dw      001bh,001eh,001ch,001dh,001ch,001dh
                twrap   0

tk5		dw	tspeed
                dw      8008h,001fh,8008h,0020h,001fh,0020h,001fh,0020h
                dw      001fh,0020h,001fh,0020h,001fh,0020h,0022h,0022h
                dw      0023h,0026h,0024h,0025h,0024h,0025h
		twrap	0

tk6		dw	tspeed
                dw      8008h,0027h,8008h,0028h,0027h,0028h,0027h,0028h
                dw      0027h,0028h,0027h,0028h,0027h,0028h,0029h,0029h
                dw      0029h,002ah,0027h,0028h,0027h,0028h
                twrap   0

tk7		dw	tspeed
                dw      0
                dw      8008h,0010h,8008h,0010h,0010h,0010h
                dw      0001h,0002h
                dw      0003h,0008h,0001h,0002h,0003h,0008h,000bh,000ch
                dw      000dh,000eh,8014h,0013h,0014h,0013h,0014h
                twrap   1

tk8             dw      tspeed
                dw      40 dup (30h)
                dw      2fh
                twrap   40

tk9             dw      tspeed
                dw      0,0
                dw      40 dup (30h)
                dw      2fh
                twrap   42
;-------------------------------------------------------------------------------
t10             dw      tspeed

                dw      2bh,2ch,2bh,2dh
                dw      2bh,2ch,2bh,2eh

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
s6032h  equ     504h
s6041h  equ     408h
s6042h  equ     508h

s0020h  equ     1       ;Up
s0048h  equ     4
s0070h  equ     4
s00f0h  equ     7
s0140h  equ     15
s10f0h  equ     24

s2040h  equ     14      ;Down
s20d0h  equ     5
s2250h  equ     20

s9038h  equ     18h     ;Level
s90d8h  equ     0
;-------------------------------------------------------------------------------
s00:
                rest 0000h
                seqend

s01:
                snd lead10
                lvl s90d8h
                dw      0033h,2034h
                cont 0002h
                vib s6031h
                cont 0001h
                rest 0000h
                dw      022dh
                vib s6032h
                cont 0000h
                lvl s9038h
                dw      012dh
                vib s6032h
                cont 1
                lvl s90d8h
                dw      0334h,032dh,0038h,2039h
                cont 0000h
                rest 0000h
                vib s6031h
                dw      0737h
                vib 0
                down s20d0h
                cont 0003h
                dw      0032h
                up s10f0h
                cont 0000h
                dw      2034h
                cont 0001h
                vib s6031h
                cont 0006h
                dw      0033h,2034h
                rest 0001h
                dw      0137h
                rest 0001h
                dw      0139h
                rest 0001h
                seqend

s02:
                up s00f0h
                dw      0137h,2039h
                cont 0000h
                dw      0336h,0332h
                vib s6031h
                dw      0b2dh,032dh,032fh
                vib s6031h
                dw      0730h,0031h,2032h
                cont 0002h
                vib s6031h
                cont 0002h
                dw      032fh,202bh
                cont 0002h
                snd lead12
                dw      0328h
                up s0048h
                dw      032bh
                seqend

s03:
                dw      202dh
                cont 0006h
                vib s6041h
                cont 000fh
                cont 000fh
                cont 000fh
                cont 0007h
                seqend

s04:
                snd bass
                dw      0309h,0121h,0015h
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      0113h,0115h,0309h,0115h,0021h
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      010bh,0117h,030ch,0024h
                rest 0000h
                dw      0118h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      0118h,0024h
                rest 0000h
                dw      030ch,0118h,0024h
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0000h
              ; snd bass
                cut 1

                dw      0018h
                rest 0000h
                dw      010dh,0019h
                rest 0000h
                seqend

s05:
                snd bass
                dw      020eh
                rest 0000h
                dw      010eh,001ah
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      0118h,001ah
                rest 0000h
                dw      030eh,010eh,001ah
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      010eh,011ah,0305h,0111h,001dh
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0000h
              ; snd bass
                cut 1

                dw      001dh
                rest 0000h
                dw      0111h,001dh
                rest 0000h
                dw      0307h,0113h,001fh
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0000h
              ; snd bass
                cut 1

                dw      011fh,0113h
              ; snd snare
              ; dw      gg
              ; rest 0000h
                cut 1
                seqend

s06:
                snd ch049
                dw      0024h
                rest 0006h
                dw      0024h
                rest 000ah
                dw      0024h
                rest 0006h
                dw      0024h
                rest 0002h
                snd ch047
                dw      0024h
                rest 0006h
                dw      0024h
                rest 000ah
                dw      0024h
                rest 0006h
                dw      0024h
                rest 0002h
                seqend

s07:
                dw      0026h
                rest 0006h
                dw      0026h
                rest 000ah
                dw      0026h
                rest 0006h
                dw      0026h
                rest 0002h
                snd ch059
                dw      0024h
                rest 0006h
                dw      0024h
                rest 0006h
                dw      0026h
                rest 0006h
                dw      0026h
                rest 0006h
                seqend

s08:
                cont 000fh
                cont 0000h
                rest 000ah
                snd wave11
                dw      013ch,013eh
                up s0140h
                dw      003fh,2040h
                vib s6031h
                dw      0343h,003ch
                rest 0000h
                dw      003fh,2040h,013eh
                vib s6031h
                dw      033ch
                vib s6031h
                dw      073eh,003ch
                vib s6031h
                cont 0004h
                dw      0039h
                rest 0000h
                seqend

s09:
                snd bass
                dw      030eh,011ah,000eh
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      010eh,011ah,0310h,011ah,001ch
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      0110h,011ch,0311h,001dh
                rest 0000h
                dw      0129h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      011dh,0029h
                rest 0000h
                dw      0313h,011fh,002bh
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0000h
              ; snd bass
                cut 1

                dw      001fh
                rest 0000h
                dw      012bh,001fh
                rest 0000h
                seqend

s0a:
                snd ch037
                dw      0026h
                rest 0006h
                dw      0026h
                rest 0006h
                dw      0028h
                rest 0006h
                dw      0028h
                rest 0006h
                snd ch059
                dw      0024h
                rest 0006h
                dw      0024h
                rest 0006h
                dw      0026h
                rest 0006h
                dw      0026h
                rest 0006h
                seqend

s0b:
                snd gnamn
                dw      0035h
                vib s6032h
                cont 0004h
                dw      0534h,0332h
                vib s6032h
                dw      0530h,052fh,032bh
                vib s6031h
                dw      0529h,0528h,0324h
                vib s6031h
                dw      0523h,0524h,0326h
                seqend

s0c:
                dw      0528h,0529h,032dh,052fh,0530h,0332h,0534h,0535h
                dw      2034h
                cont 0002h
                vib s6031h
                dw      0b32h,0130h,0132h
                seqend

s0d:
                dw      0137h,0135h
                vib s6031h
                dw      0330h,032dh,0329h,0135h,0134h
                vib s6031h
                dw      032fh,0328h,032bh,0137h,0135h,0330h,0135h,0134h
                dw      032dh,012fh,012bh
                vib s6031h
                dw      0326h,0130h,012fh
                vib s6031h
                dw      032bh
                seqend

s0e:
                dw      0137h,0135h
                vib s6031h
                dw      0330h,032dh,0329h,0135h,0134h
                vib s6031h
                dw      032fh,0328h,032bh,0137h,0135h,0330h,0135h,0134h
                dw      012dh,012bh,032dh
                vib s6031h
                cont 0001h
                rest 0001h
              ; snd snare
              ; dw      0013h
              ; rest 0004h
              ; dw      0021h
              ; rest 0000h
                cut 7

                seqend

s0f:
                snd ch037
                dw      0026h
                rest 000ah
                dw      0026h
                rest 0002h
                dw      0028h
                rest 000ah
                dw      0028h
                rest 0002h
                snd ch059
                dw      0024h
                rest 0006h
                dw      0024h
                rest 0006h
                dw      0026h
                rest 0006h
                dw      0026h
                rest 0006h
                seqend

s10:
                snd empty
                dw      002dh
                rest 000fh
                rest 000fh
                rest 000fh
                rest 000eh
                seqend

s11:
                snd ch058
                dw      0028h
                rest 0000h
                dw      0028h
                rest 0002h
                dw      0028h
                rest 0000h
                snd ch057
                dw      0028h
                rest 0002h
                snd ch058
                dw      0028h
                rest 0002h
                snd ch05a
                dw      0028h
                rest 0002h
                snd ch058
                dw      0028h
                rest 0000h
                dw      0028h
                rest 0002h
                dw      0028h
                rest 0000h
                snd ch057
                dw      0028h
                rest 0002h
                snd ch038
                dw      0028h
                rest 0002h
                dw      0028h
                rest 0000h
                snd ch059
                dw      002bh
                rest 0002h
                dw      002bh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch047
                dw      0024h
                rest 0002h
                dw      0024h
                rest 0000h
                snd ch038
                dw      0028h
                rest 0002h
                dw      0028h
                rest 0002h
                dw      0028h
                rest 0000h
                seqend

s12:
                snd ch059
                dw      002dh
                rest 0002h
                dw      002dh
                rest 0000h
                snd ch057
                dw      002dh
                rest 0002h
                snd ch059
                dw      002dh
                rest 0000h
                dw      002dh
                rest 0002h
                snd ch038
                dw      002ah
                rest 0000h
                dw      002ah
                rest 0002h
                dw      002ah
                rest 0000h
                snd ch047
                dw      0026h
                rest 0002h
                dw      0026h
                rest 0002h
                dw      0029h
                rest 0002h
                dw      0029h
                rest 0000h
                snd ch046
                dw      0029h
                rest 0002h
                dw      0029h
                rest 0000h
                snd ch059
                dw      0024h
                rest 0002h
                snd ch047
                dw      002bh
                rest 0002h
                dw      002bh
                rest 0000h
                snd ch05a
                dw      0026h
                rest 0002h
                dw      0026h
                rest 0000h
                snd ch059
                dw      0026h
                rest 0002h
                seqend

s13:
                snd wave11
                dw      0028h
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      002fh
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      0030h
                rest 0000h
                dw      0028h
                rest 0000h
                seqend

s14:
                dw      002ah
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0032h
                rest 0000h
                dw      002ah
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0032h
                rest 0000h
                dw      002ah
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0032h
                rest 0000h
                dw      002ah
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0032h
                rest 0000h
                dw      002ah
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0032h
                rest 0000h
                dw      002ah
                rest 0000h
                dw      0024h
                rest 0000h
                dw      0029h
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0024h
                rest 0000h
                dw      0029h
                rest 0000h
                dw      002dh
                rest 0000h
                dw      0024h
                rest 0000h
                dw      0029h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      002fh
                rest 0000h
                dw      0032h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      002fh
                rest 0000h
                dw      0032h
                rest 0000h
                dw      002bh
                rest 0000h
                dw      002fh
                rest 0000h
                seqend

s15:
                snd bass
                dw      030eh,011ah,000eh
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      010eh,011ah,0310h,011ah,001ch
                rest 0000h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      0110h,011ch,0311h,001dh
                rest 0000h
                dw      0129h
              ; snd snare
              ; dw      gg
              ; rest 0002h
              ; snd bass
                cut 3

                dw      011dh,0029h
                rest 0000h
                dw      0709h,001ah
                down s2040h
                cont 0006h
                seqend

s16:
                snd ch037
                dw      0026h
                rest 000ah
                dw      0026h
                rest 0002h
                dw      0028h
                rest 000ah
                dw      0028h
                rest 0002h
                snd ch059
                dw      0024h
                rest 0006h
                dw      0024h
                rest 0006h
                snd ch058
                dw      0028h
                rest 000eh
                seqend
;-------------------------------------------------------------------------------
s17:
                snd ch049
                dw      0024h+4
                rest 0006h
                dw      0024h+4
                rest 000ah
                dw      0024h+4
                rest 0006h
                dw      0024h+4
                rest 0002h
                snd ch047
                dw      0024h+4
                rest 0006h
                dw      0024h+4
                rest 000ah
                dw      0024h+4
                rest 0006h
                dw      0024h+4
                rest 0002h
                seqend

s18:
                dw      0026h+4
                rest 0006h
                dw      0026h+4
                rest 000ah
                dw      0026h+4
                rest 0006h
                dw      0026h+4
                rest 0002h
                snd ch059
                dw      0024h+5
                rest 0006h
                dw      0024h+5
                rest 0006h
                dw      0026h+5
                rest 0006h
                dw      0026h+5
                rest 0006h
                seqend

s19:

s1a:
                snd ch037
                dw      0026h+3
                rest 0006h
                dw      0026h+3
                rest 0006h
                dw      0028h+3
                rest 0006h
                dw      0028h+3
                rest 0006h
                snd ch059
                dw      0024h+5
                rest 0006h
                dw      0024h+5
                rest 0006h
                dw      0026h+5
                rest 0006h
                dw      0026h+5
                rest 0006h
                seqend

s1b:
                snd ch037
                dw      0026h+3
                rest 000ah
                dw      0026h+3
                rest 0002h
                dw      0028h+3
                rest 000ah
                dw      0028h+3
                rest 0002h
                snd ch059
                dw      0024h+5
                rest 0006h
                dw      0024h+5
                rest 0006h
                dw      0026h+5
                rest 0006h
                dw      0026h+5
                rest 0006h
                seqend

s1c:
                snd ch058
                dw      0028h+5
                rest 0000h
                dw      0028h+5
                rest 0002h
                dw      0028h+5
                rest 0000h
                snd ch057
                dw      0028h+5
                rest 0002h
                snd ch058
                dw      0028h+5
                rest 0002h
                snd ch05a
                dw      0028h+5
                rest 0002h
                snd ch058
                dw      0028h+5
                rest 0000h
                dw      0028h+5
                rest 0002h
                dw      0028h+5
                rest 0000h
                snd ch057
                dw      0028h+5
                rest 0002h
                snd ch038
                dw      0028h+3
                rest 0002h
                dw      0028h+3
                rest 0000h
                snd ch059
                dw      002bh+5
                rest 0002h
                dw      002bh+5
                rest 0002h
                dw      002bh+5
                rest 0000h
                snd ch047
                dw      0024h+4
                rest 0002h
                dw      0024h+4
                rest 0000h
                snd ch038
                dw      0028h+3
                rest 0002h
                dw      0028h+3
                rest 0002h
                dw      0028h+3
                rest 0000h
                seqend

s1d:
                snd ch059
                dw      002dh+5
                rest 0002h
                dw      002dh+5
                rest 0000h
                snd ch057
                dw      002dh+5
                rest 0002h
                snd ch059
                dw      002dh+5
                rest 0000h
                dw      002dh+5
                rest 0002h
                snd ch038
                dw      002ah+3
                rest 0000h
                dw      002ah+3
                rest 0002h
                dw      002ah+3
                rest 0000h
                snd ch047
                dw      0026h+4
                rest 0002h
                dw      0026h+4
                rest 0002h
                dw      0029h+4
                rest 0002h
                dw      0029h+4
                rest 0000h
                snd ch046
                dw      0029h+4
                rest 0002h
                dw      0029h+4
                rest 0000h
                snd ch059
                dw      0024h+5
                rest 0002h
                snd ch047
                dw      002bh+4
                rest 0002h
                dw      002bh+4
                rest 0000h
                snd ch05a
                dw      0026h+5
                rest 0002h
                dw      0026h+5
                rest 0000h
                snd ch059
                dw      0026h+5
                rest 0002h
                seqend

s1e:
                snd ch037
                dw      0026h+3
                rest 000ah
                dw      0026h+3
                rest 0002h
                dw      0028h+3
                rest 000ah
                dw      0028h+3
                rest 0002h
                snd ch059
                dw      0024h+5
                rest 0006h
                dw      0024h+5
                rest 0006h
                snd ch058
                dw      0028h+5
                rest 000eh
                seqend
;-------------------------------------------------------------------------------
s1f:
                snd ch049
                dw      0024h+9
                rest 0006h
                dw      0024h+9
                rest 000ah
                dw      0024h+9
                rest 0006h
                dw      0024h+9
                rest 0002h
                snd ch047
                dw      0024h+7
                rest 0006h
                dw      0024h+7
                rest 000ah
                dw      0024h+7
                rest 0006h
                dw      0024h+7
                rest 0002h
                seqend

s20:
                dw      0026h+7
                rest 0006h
                dw      0026h+7
                rest 000ah
                dw      0026h+7
                rest 0006h
                dw      0026h+7
                rest 0002h
                snd ch059
                dw      0024h+9
                rest 0006h
                dw      0024h+9
                rest 0006h
                dw      0026h+9
                rest 0006h
                dw      0026h+9
                rest 0006h
                seqend

s21:

s22:
                snd ch037
                dw      0026h+7
                rest 0006h
                dw      0026h+7
                rest 0006h
                dw      0028h+7
                rest 0006h
                dw      0028h+7
                rest 0006h
                snd ch059
                dw      0024h+9
                rest 0006h
                dw      0024h+9
                rest 0006h
                dw      0026h+9
                rest 0006h
                dw      0026h+9
                rest 0006h
                seqend

s23:
                snd ch037
                dw      0026h+7
                rest 000ah
                dw      0026h+7
                rest 0002h
                dw      0028h+7
                rest 000ah
                dw      0028h+7
                rest 0002h
                snd ch059
                dw      0024h+9
                rest 0006h
                dw      0024h+9
                rest 0006h
                dw      0026h+9
                rest 0006h
                dw      0026h+9
                rest 0006h
                seqend

s24:
                snd ch058
                dw      0028h+8
                rest 0000h
                dw      0028h+8
                rest 0002h
                dw      0028h+8
                rest 0000h
                snd ch057
                dw      0028h+7
                rest 0002h
                snd ch058
                dw      0028h+8
                rest 0002h
                snd ch05a
                dw      0028h+0ah
                rest 0002h
                snd ch058
                dw      0028h+8
                rest 0000h
                dw      0028h+8
                rest 0002h
                dw      0028h+8
                rest 0000h
                snd ch057
                dw      0028h+7
                rest 0002h
                snd ch038
                dw      0028h+8
                rest 0002h
                dw      0028h+8
                rest 0000h
                snd ch059
                dw      002bh+9
                rest 0002h
                dw      002bh+9
                rest 0002h
                dw      002bh+9
                rest 0000h
                snd ch047
                dw      0024h+7
                rest 0002h
                dw      0024h+7
                rest 0000h
                snd ch038
                dw      0028h+8
                rest 0002h
                dw      0028h+8
                rest 0002h
                dw      0028h+8
                rest 0000h
                seqend

s25:
                snd ch059
                dw      002dh+9
                rest 0002h
                dw      002dh+9
                rest 0000h
                snd ch057
                dw      002dh+7
                rest 0002h
                snd ch059
                dw      002dh+9
                rest 0000h
                dw      002dh+9
                rest 0002h
                snd ch038
                dw      002ah+8
                rest 0000h
                dw      002ah+8
                rest 0002h
                dw      002ah+8
                rest 0000h
                snd ch047
                dw      0026h+7
                rest 0002h
                dw      0026h+7
                rest 0002h
                dw      0029h+7
                rest 0002h
                dw      0029h+7
                rest 0000h
                snd ch046
                dw      0029h+6
                rest 0002h
                dw      0029h+6
                rest 0000h
                snd ch059
                dw      0024h+9
                rest 0002h
                snd ch047
                dw      002bh+7
                rest 0002h
                dw      002bh+7
                rest 0000h
                snd ch05a
                dw      0026h+0ah
                rest 0002h
                dw      0026h+0ah
                rest 0000h
                snd ch059
                dw      0026h+9
                rest 0002h
                seqend

s26:
                snd ch037
                dw      0026h+7
                rest 000ah
                dw      0026h+7
                rest 0002h
                dw      0028h+7
                rest 000ah
                dw      0028h+7
                rest 0002h
                snd ch059
                dw      0024h+9
                rest 0006h
                dw      0024h+9
                rest 0006h
                snd ch058
                dw      0028h+8
                rest 000eh
                seqend
;-------------------------------------------------------------------------------
s27:
                snd bass2
                dw      0309h,0121h,0015h
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      0113h,0115h,0309h,0115h,0021h
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      010bh,0117h,030ch,0024h
                rest 0000h
                dw      0118h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      0118h,0024h
                rest 0000h
                dw      030ch,0118h,0024h
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0000h
              ; snd bass2
                cut 1

                dw      0018h
                rest 0000h
                dw      010dh,0019h
                rest 0000h
                seqend

s28:
                snd bass2
                dw      020eh
                rest 0000h
                dw      010eh,001ah
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      0118h,001ah
                rest 0000h
                dw      030eh,010eh,001ah
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      010eh,011ah,0305h,0111h,001dh
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0000h
              ; snd bass2
                cut 1

                dw      001dh
                rest 0000h
                dw      0111h,001dh
                rest 0000h
                dw      0307h,0113h,001fh
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0000h
              ; snd bass2
                cut 1

                dw      011fh,0113h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0000h
                cut 1
                seqend

s29:
                snd bass2
                dw      030eh,011ah,000eh
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      010eh,011ah,0310h,011ah,001ch
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      0110h,011ch,0311h,001dh
                rest 0000h
                dw      0129h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      011dh,0029h
                rest 0000h
                dw      0313h,011fh,002bh
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0000h
              ; snd bass2
                cut 1

                dw      001fh
                rest 0000h
                dw      012bh,001fh
                rest 0000h
                seqend

s2a:
                snd bass2
                dw      030eh,011ah,000eh
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      010eh,011ah,0310h,011ah,001ch
                rest 0000h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      0110h,011ch,0311h,001dh
                rest 0000h
                dw      0129h
              ; snd bum
              ; down    ff
              ; dw      zz
              ; rest 0002h
              ; snd bass2
                cut 3

                dw      011dh,0029h
                rest 0000h
                dw      0709h,001ah
                down s2040h
                cont 0006h
                seqend
;-------------------------------------------------------------------------------
s2b:
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      0b0ch
                snd xbassdr
                dw      030ch
                snd xsnare
                dw      070ch
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      0b0ch
                snd xbassdr
                dw      030ch
                snd xsnare
                dw      030ch
                snd xbassdr
                dw      030ch
                seqend

s2c:
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      0b0ch
                snd xbassdr
                dw      030ch
                snd xsnare
                dw      070ch
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      0b0ch
                snd xbassdr
                dw      030ch
                snd xsnare
                dw      050ch
                dw      010ch
                seqend

s2d:
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      0b0ch
                snd xbassdr
                dw      030ch
                snd xsnare
                dw      070ch
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      070ch
                dw      030ch
                snd xbassdr
                dw      030ch
                snd xsnare
                dw      030ch
                snd xbassdr
                dw      030ch
                seqend

s2e:
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      0b0ch
                snd xbassdr
                dw      030ch
                snd xsnare
                dw      070ch
                snd xbassdr
                dw      070ch
                snd xsnare
                dw      070ch
                dw      030ch
                dw      010ch
                dw      030ch
                dw      010ch
                dw      030ch
                seqend
;-------------------------------------------------------------------------------
s2f:
                snd tick
                lvl 00h
                lc 3ch 3
                lvl 03h
                lc 3ch 3
                seqend

s30:
                cut 1fh
                seqend
;-------------------------------------------------------------------------------
datainfo:     ; db      ' "Crooner" was converted from the C64 original (By Thomas "DRAX" Mogensen) to the PC by JCH/Vibrants. '

                dw      0ffffh          ;Endmark
;-------------------------------------------------------------------------------
                ends
                end
