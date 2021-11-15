;----------------------------------------------------------------------------
; MUSIC DATA - AdLib player v01.05 by JCH/Vibrants.
; Remember version number in VERSION1 and credits in DATAINFO.
;----------------------------------------------------------------------------
public          version1,max,general,seqpointer,tpoin,instrument,datainfo

musicdata       segment public
assume          ds:musicdata
;----------------------------------------------------------------------------
version1        dw      0105h                   ;Version
max             db      12                      ;Number of music & sfx's

general         dw	offset tpoin		;00h
                dw      offset seqpointer       ;01h
                dw      offset instrument       ;02h
                dw      offset datainfo         ;03h

		dw	0ffffh			;Endmark
;----------------------------------------------------------------------------
seqpointer      dw      offset s00,offset s01,offset s02,offset s03
                dw      offset s04,offset s05,offset s06,offset s07
                dw      offset s08,offset s09,offset s0a,offset s0b
                dw      offset s0c,offset s0d,offset s0e,offset s0f
                dw      offset s10,offset s11,offset s12,offset s13
                dw      offset s14,offset s15,offset s16,offset s17
                dw      offset s18,offset s19,offset s1a,offset s1b
                dw      offset s1c,offset s1d,offset s1e,offset s1f
                dw      offset s20

tpoin           dw      offset track1,offset track3,0,0,0,0,0,0,0
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
		db	0,0,0,0,0 ;unused, to keep tpoin's at 32 bytes.

                dw      offset track2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

                dw      0,0,offset track4,offset track8,offset track6
                dw      offset track7,0,0,0,0,0,0,0,0,0,0

                dw      offset track5,offset track5,offset track5
                dw      offset track5,offset track5,offset track5
                dw      offset track5,offset track5,offset track5
                dw      0,0,0,0,0,0,0

                dw      0,0,offset track9,offset track10,offset track11
                dw      offset track12,0,0,0
                db      0,0,80h,0,0,80h,0,0,0   ;TIE-SFX
                db      0,0,0,0,0

                dw      offset track13,offset track14,0,0,0,0,0,0,0,0,0,0,0,0,0,0

                dw      0,0,0,0,0,0,offset track15,offset track16
                dw      offset track17
                db      0,0,0,0,0,0,0,08h,10h
                db      0,0,0,0,0

                dw      0,0,0,0,0,0,offset track18,offset track19,0
                dw      0,0,0,0,0,0,0

                dw      0,0,0,0,0,0,offset track20,0,0
                db      0,0,0,0,0,0,80h,0,0     ;TIE-SFX
                db      0,0,0,0,0

                dw      offset track21,offset track22,0,0,0,0,0,0,0
                dw      0,0,0,0,0,0,0

                dw      offset track5,offset track5
                dw      offset track24,offset track25,offset track26
                dw      offset track27,offset track23
                dw      offset track5,offset track5
                db      80h,80h,80h,80h,0,0,80h,80h,80h
                db      0,0,0,0,0               ;TIE-SFX

                dw      offset track28,offset track29,0,0,0,0,0,0,0
                dw      0,0,0,0,0,0,0

		dw	0ffffh		;Endmark
;----------------------------------------------------------------------------
                ;                (00/40/80/C0)     (0/1/2/3)
                ;        AD   SR  K   lvl  AVEKmult  wave
instrument      db      0ffh,0ffh,000h+00h,00000000b,0
                db      0ffh,0ffh,000h+00h,00000000b,0
                db      0 ;Feedback (0-7)
                db      0 ;Connection (0=Modulated/1=Additive) ;        C000
		db	0,0,0,0 ;Unused

                db      066h,049h,000h+00h,00101100b,1    ;Trolje       C001
                db      044h,039h,000h+00h,00101111b,3,0,0,0,0,0,0

                db      0ffh,00ah,000h+0fh,00000001b,0    ;Trolje       C002
                db      0ffh,017h,000h+00h,00000010b,1,0,0,0,0,0,0
                        ;1
                db      0f3h,000h,000h+00h,00100000b,0    ;St›j         C003
                db      0f1h,000h,000h+0bh,10000000b,0,2,0,0,0,0,0

                db      0ffh,006h,000h+0dh,00100001b,2    ;Klank        C004
                db      0f4h,072h,000h+00h,00000111b,0,5,0,0,0,0,0

                db      0ffh,00ch,000h+05h,00100010b,0    ;Klonk        C005
                db      0f4h,00ch,000h+00h,00001111b,0,0,0,0,0,0,0
                        ;1
                db      0fah,000h,000h+18h,00000000b,3    ;Mere st›j 1  C006
                db      0f1h,020h,000h+06h,10000001b,0,7,0,0,0,0,0

                db      0fah,000h,000h+18h,00000000b,3    ;Mere st›j 2  C007
                db      0f1h,020h,000h+06h,10000001b,0,7,0,0,0,0,0

                db      0ffh,005h,000h+00h,00100111b,1    ;Pick up      C008
                db      0f8h,003h,000h+10h,00001000b,0,0,0,0,0,0,0

                db      06fh,006h,000h+00h,00100000b,3    ;Tuut         C009
                db      0ffh,003h,000h+10h,00000001b,1,7,0,0,0,0,0

                db      0ffh,008h,000h+00h,00100001b,3    ;Tjogh        C00A
                db      0ffh,036h,000h+00h,00000011b,0,7,0,0,0,0,0

                db      034h,005h,000h+00h,00100000b,3    ;Tog passerer C00B
                db      011h,000h,000h+0bh,10000101b,0,3,0,0,0,0,0

                db      0ffh,004h,000h+00h,00000000b,2    ;Skrash!      C00C
                db      0ffh,005h,000h+00h,00000010b,2,7,0,0,0,0,0
;----------------------------------------------------------------------------
; -----         First position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;----------------------------------------------------------------------------
track1          dw      1,8000h,1,0fffeh
track2          dw      1,8000h,2,0fffeh
track3          dw      1,8000h,3,0fffeh
track4          dw      1,8000h,4,5,0ffffh,2        ;
track5          dw      1,8000h,6,0fffeh
track6          dw      1,8000h,0bh,0ffffh,1        ;
track7          dw      1,8000h,0ch,0ffffh,1        ;
track8          dw      1,8000h,9,0ah,0ffffh,2      ;
track9          dw      1,8000h,0dh,5,0ffffh,2
track10         dw      1,8000h,0eh,0bh,0ffffh,2
track11         dw      1,8000h,0fh,0ch,0ffffh,2
track12         dw      1,8000h,10h,0ah,0ffffh,2
track13         dw      1,8020h,11h,0fffeh
track14         dw      1,8020h,12h,0fffeh
track15         dw      1,8024h,13h,0fffeh
track16         dw      1,0,8024h,13h,0fffeh
track17         dw      1,0,0,8024h,13h,0fffeh
track18         dw      1,8000h,14h,17h,0ffffh,2
track19         dw      1,8000h,15h,0fffeh
track20         dw      1,8000h,16h,0fffeh
track21         dw      1,8000h,18h,0fffeh
track22         dw      1,8000h,19h,0fffeh
track23         dw      1,8000h,1ah,0fffeh
track24         dw      1,8000h,1bh,0fffeh
track25         dw      1,8000h,1eh,0fffeh
track26         dw      1,8000h,1ch,0fffeh
track27         dw      1,8000h,1dh,0fffeh
track28         dw      1,8000h,1fh,0fffeh
track29         dw      1,8000h,20h,0fffeh
;----------------------------------------------------------------------------
; 0000h		Rest
; 0001h-005fh	Notes (C# and up)
; 0080h		Hold (Continue)
; 0101h-015fh	Notes with tienote (C# and up) - Levelcommands are ignored!
; 0201h-025fh	Locked notes (Ignores track transpositions)
; 8000h-8fffh	Duration 000-fff
; 9000h-903fh	Levels 00-3f
; c000h-cfffh	Instrument 000-fff
; d000h-dfffh	Slide up 000-fff
; e000h-efffh   Slide down 000-fff
; ffffh		End of sequence
;----------------------------------------------------------------------------
s00             dw      8002h,0,0ffffh

s01             dw      8001h,0,8005h
                dw      0c001h,9004h
                dw      3ah,9004h,3ah,801fh,0,0ffffh

s02             dw      8005h,0c001h,9008h,3ah,8003h
                dw      0,0ffffh

s03             dw      0c001h,8001h,9000h,3ah,0,8003h,0c002h,0ch
                dw      0ffffh

s04:
                dw      0c003h,8000h,04h,0ffffh

s05             dw      0c003h,8001h,0e002h,105h
                dw      8002h,103h
                dw      8001h,0e004h,104h
                dw      8003h,104h
                dw      8001h,0e001h,105h
                dw      8002h,102h
                dw      8002h,0e003h,102h
                dw      8001h,104h
                dw      8003h,0e001h,103h
                dw      8002h,102h
                dw      8003h,0e002h,104h
                dw      8001h,106h
                dw      0ffffh

s06             dw      0c000h,01h,0ffffh

s07:
                dw      0c004h,8020h,0,8001h,9018h,05h
                dw      8017h,0,8001h,9012h,05h,8013h,0
                dw      9016h,8001h,05h,8010h,0
                dw      8001h,900ch,05h,800dh,0
                dw      8001h,9006h,05h,800bh,0
                dw      9014h,8001h,05h,8023h,0,0ffffh

s08:
                dw      0c005h,8020h,0,8001h,9018h,10h
                dw      8017h,0,8001h,9012h,10h,8013h,0
                dw      9016h,8001h,10h,8010h,0
                dw      8001h,900ch,10h,800dh,0
                dw      8001h,9006h,10h,800bh,0
                dw      9014h,8001h,10h,8023h,0,0ffffh

s09:
                dw      8000h,0c006h,0ch,0ffffh

s0a             dw      10ch,0ffffh

s0b             dw      0c004h,8001h,9000h,05h,8007h,0,8001h,05h,8007h,0
                dw      9018h,8001h,05h,8008h,0
                dw      8001h,9000h,05h,8007h,0,8001h,05h,8007h,0
                dw      9018h,8001h,05h,8020h,0,0ffffh

s0c             dw      0c005h,8001h,9000h,10h,8007h,0,8001h,10h,8007h,0
                dw      9014h,8001h,10h,8008h,0
                dw      8001h,9000h,10h,8007h,0,8001h,10h,8007h,0
                dw      9014h,8001h,10h,8020h,0,0ffffh




s0d             dw      0c003h,8001h,0e002h,106h
                dw      8002h,108h
                dw      8001h,0e004h,10ah
                dw      8003h,109h
                dw      8001h,0e001h,10eh
                dw      8002h,10ch
                dw      8002h,0e003h,111h
                dw      8001h,10eh
                dw      8003h,0e001h,10bh
                dw      8002h,10fh
                dw      8003h,0e002h,10fh
                dw      8003h,110h
                dw      8002h,0e004h,108h
                dw      8004h,106h
                dw      0ffffh

s0e             dw      0c004h,8001h,9000h,05h,8003h,0,8001h,9018h,05h,8003h,0
                dw      8001h,9000h,05h,8007h,0
                dw      8001h,05h,8003h,0,8001h,9018h,05h,8003h,0
                dw      8001h,9000h,05h,8007h,0
                dw      9018h,8001h,05h,8020h,0,0ffffh

s0f             dw      0c005h,8001h,9000h,10h,8003h,0,8001h,9014h,10h,8003h,0
                dw      8001h,9000h,10h,8007h,0
                dw      8001h,10h,8003h,0,8001h,9014h,10h,8003h,0
                dw      8001h,9000h,10h,8007h,0
                dw      9014h,8001h,10h,8020h,0,0ffffh

s10             dw      800fh,0c007h,0ch,8000h,0ch,0ffffh


s11             dw      8000h,8001h,0c008h,11h,116h,11ah,11dh,122h
                dw      802fh,0,0ffffh

s12             dw      8000h,0,8001h,0c008h,0eh,111h,116h,11ah,11dh
                dw      802fh,0,0ffffh

s13             dw      0c009h,8001h,12h,8003h,0d006h,112h
                dw      8003h,114h,8000h,0,8000h,9018h,14h,9000h,8002h,0
                dw      8003h,14h,8002h,0,9018h,8003h,14h,800fh,0,0ffffh

s14             dw      0c00ah,8004h,9020h,0ch
                dw      9018h,0ch
                dw      9010h,0e003h,0ch
                dw      9008h,0e002h,0ch
                dw      0ffffh

s15             dw      0c000h,8000h,0ch
                dw      0c00bh,801fh,0ah,801fh,0,0c000h,0ch,0ffffh

s16             dw      9002h,0e002h,0ch,9004h,0e001h,0ch
                dw      9008h,0ch
                dw      900ch,0ch
                dw      9010h,0e003h,0ch
                dw      9014h,0ch
                dw      9018h,0e002h,0ch
                dw      9020h,0ch
                dw      9028h,0ch
                dw      0ffffh

s17             dw      9000h,0ch,0e002h,0ch
                dw      0ch,0e004h,0ch,0e003h,0ch
                dw      0ch,0ffffh

s18             dw      800fh,0c00ch,03h,9000h
                dw      0c009h,8001h,12h+22h,8003h,0d006h,112h+22h
                dw      8028h,114h+22h,0,0ffffh

s19             dw      8005h,0c005h,0e020h,20h,800dh,0,900ch
                dw      0c009h,8001h,12h+22h,8003h,0d006h,112h+22h
                dw      8027h,114h+22h,0,0ffffh



s1a             dw      9008h,0e002h,0ch,9014h,0e001h,0ch
                dw      9020h,0ch
                dw      9030h,0ch,0c000h,0ch
                dw      0ffffh

s1b             dw      0c003h,8001h,0e002h,9008h,05h
                dw      8002h,9010h,03h
                dw      8001h,0e004h,9014h,04h
                dw      8003h,9018h,04h
                dw      8001h,0e001h,901ch,05h
                dw      8002h,9020h,02h
                dw      8003h,0e002h,9028h,03h,0c000h,0ch
                dw      0ffffh

s1c             dw      0c004h,8007h,0,8001h,9010h,05h,8007h
                dw      0,8001h,901ch,05h,800ah,0
                dw      9020h,8001h,05h,0,0c000h,0ch,0ffffh

s1d             dw      0c005h,8007h,0,8001h,9010h,10h,8007h
                dw      0,8001h,901ah,10h,800ah,0
                dw      9024h,8001h,10h,0,0c000h,0ch,0ffffh

s1e             dw      800bh,0
                dw      0c001h,800ch,9000h,3ah,0,0c000h,0ch
                dw      0ffffh

s1f             dw      8005h,0c00ah,10h,0ffffh

s20             dw      8005h,0c005h,0e030h,30h,0ffffh
;----------------------------------------------------------------------------
datainfo        db      0

               ; db      '..............................'
               ; db      '..............................'
;----------------------------------------------------------------------------
                ends
                end
