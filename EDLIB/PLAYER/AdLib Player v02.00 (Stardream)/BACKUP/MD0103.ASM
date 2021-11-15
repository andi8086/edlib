;----------------------------------------------------------------------------
; MUSIC DATA - AdLib player v01.03 by JCH/Vibrants.
; Remember version number in VERSION1 and credits in DATAINFO.
;----------------------------------------------------------------------------
public          version1,max,general,seqpointer,tpoin,instrument,datainfo

musicdata       segment public
assume          ds:musicdata
;----------------------------------------------------------------------------
version1        dw      0103h                   ;Version
max		db	3			;Number of music & sfx's

general         dw	offset tpoin		;00h
                dw      offset seqpointer       ;01h
                dw      offset instrument       ;02h
                dw      offset datainfo         ;03h

		dw	0ffffh			;Endmark
;----------------------------------------------------------------------------
seqpointer      dw      offset s00,offset s01,offset s02,offset s03
		dw	offset s04,offset s05,offset s06,offset s07
		dw	offset s08,offset s09,offset s0a,offset s0b
		dw	offset s0c,offset s0d,offset s0e,offset s0f
		dw	offset s10,offset s11,offset s12,offset s13
		dw	offset s14,offset s15,offset s16,offset s17
		dw	offset s18,offset s19,offset s1a

tpoin		dw	0,0,offset track2
		dw	offset track3,offset track4,offset track5
		dw	offset track6,offset track7,offset track8
		db	00h,00h,00h,00h,00h,00h,00h,06h,06h
		db	0,0,0,0,0 ;unused, to keep tpoin's at 32 bytes.

		dw	0,offset track0,0
		dw	0,0,0
		dw	0,0,0
		db	00h,00h,00h,00h,00h,00h,00h,00h,00h,0,0,0,0,0

		dw	offset track1,0,0
		dw	0,0,0
		dw	0,0,0
		db	00h,00h,00h,00h,00h,00h,00h,00h,00h,0,0,0,0,0

		dw	0ffffh		;Endmark
;----------------------------------------------------------------------------
                ;                (00/40/80/C0)     (0/1/2/3)
 		;        AD   SR  K   lvl  AVEKmult  wave
instrument	db	0ffh,007h,000h+00h,00100000b,1
		db	0f4h,005h,000h+1eh,01000010b,1
		db	2 ;Feedback (0-7)
		db	0 ;Connection (0=Modulated/1=Additive)
		db	0,0,0,0 ;Unused

		db	0ffh,007h,000h+00h,00100001b,1
		db	0f4h,024h,000h+14h,01000001b,2
		db	4,0,0,0,0,0

		db	0ffh,006h,000h+02h,00000000b,0
		db	0ffh,000h,000h+00h,00001111b,3
		db	7,0,0,0,0,0

		db	0f6h,015h,000h+00h,00100000b,1
		db	0f6h,015h,000h+1eh,01000010b,1
		db	7,0,0,0,0,0

		db	0f4h,025h,000h+00h,01100000b,1
		db	0f4h,025h,000h+18h,01000010b,2
		db	3,0,0,0,0,0

		db	0ffh,006h,000h+00h,00100011b,0
		db	0ffh,006h,000h+12h,00100011b,0
		db	0,1,0,0,0,0

		db	0ffh,005h,000h+00h,00100001b,0
		db	0fdh,022h,000h+08h,00100110b,2
		db	7,0,0,0,0,0
;----------------------------------------------------------------------------
; -----		First position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;----------------------------------------------------------------------------
track0  	dw	1,8000h		
                dw      18h,0fffeh
		dw	4,4,4,1,4,4,4,2
		dw	4,4,4,1,4,4,4,2
		dw	0ffffh,0	

track1          dw	1,8018h,1ah,0fffeh
	
		dw	1,800ch,17h,17h,800ah,17h,17h
		dw	8011h,17h,17h,8007h,17h,17h
		dw	0ffffh,0

		dw	1
	        dw	6,6,4,4,4,1,4,4,4,2
		dw	4,4,4,1,4,4,4,2
		dw	0ffffh,0

track2          dw	1,800ch,15h,15h,15h,16h
		dw	0ffffh,0

track3          dw	1,800ch,7,8,7,9
		dw	0ffffh,0

track4          dw	1,8018h,0ah,13h,0dh,0ah,14h,10h
		dw	0ffffh,0

track5		dw	1,8018h,0bh,0eh,0bh,11h,6
		dw	0ffffh,0

track6		dw	1,8018h,0ch,0fh,0ch,12h,6
		dw	0ffffh,0

track7		dw	1
		dw	6,8018h,0bh,0eh,0bh,11h
		dw	0ffffh,0		

track8		dw	1
		dw	6,8018h,0ch,0fh,0ch,12h
		dw	0ffffh,0
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
; e000h-efffh	Slide down 000-fff
; ffffh		End of sequence
;----------------------------------------------------------------------------
s00		dw	8fffh,0,0ffffh

s01		dw	0c000h
		dw	8007h,0ch+24,0fh+24
		dw	8003h,11h+24,0,12h+24
		dw	0c001h
		dw	8007h,13h+24
		dw	8003h,16h+24,16h+24,0,16h+24,13h+24
		dw	16h+24,18h+24
		dw	0ffffh

s02		dw	0c000h
		dw	8007h,0ch+24,0fh+24,11h+24
                dw	8003h,12h+24
                dw	8007h,13h+24
		dw	8001h,0bh+24,10ah+24	
		dw	8007h,07h+24,0ah+24,0bh+24
		dw	0ffffh

s03		dw	0c001h,8003h
		dw	0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh,10h,11h
		dw	12h,13h,14h,15h,16h,17h,18h,19h,1ah,1bh,1ch,1dh,1eh
		dw	1fh,20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2ah,2bh
		dw	2ch,2dh,2eh,2fh,30h,31h,32h,33h,34h,35h,36h,37h,38h
		dw	39h,3ah,3bh,3ch,3dh,3eh,3fh,40h,41h,42h,43h,44h,45h
		dw	46h,47h,48h,49h,4ah,4bh,4ch,4dh,4eh,4fh,50h,51h,52h
		dw	53h,54h,55h,56h,57h,58h,59h,5ah,5bh,5ch,5dh,5eh,5fh
		dw	0ffffh	

s04		dw	0c000h
		dw	8007h,0ch+24,0fh+24
                dw	8003h,11h+24,0,12h+24
		dw	0c001h
		dw	8003h,13h+24,0,13h+24
		dw	8007h,12h+24,11h+24,0fh+24
		dw	0ffffh

s05		dw	0c001h,8003h
		dw	0ch+24,0fh+24,0ch+24,0fh+24
		dw	10ch+24,10fh+24,10ch+24,10fh+24
		dw	0ffffh

s06		dw	8001h,0,0ffffh

s07	        dw	0c001h,8007h,0ch
		dw	8003h,0ah,8007h,0ch,8003h,0fh
		dw	0c002h,8007h,230h
		dw	0c001h,8003h,0ah,8007h,0ch
		dw	8003h,0fh,8007h,11h,8003h,13h
		dw	8007h,0fh,8003h,0ch
		dw	0c002h,8007h,230h
		dw	0c001h,8003h,0ch,8007h,0ah
		dw	8003h,07h,0ffffh

s08	        dw	0c001h,8007h,0ch
		dw	8003h,0ah,8007h,0ch,8003h,0fh
		dw	0c002h,8007h,230h
		dw	0c001h,8003h,0ah,8007h,0ch
		dw	8003h,0fh,8007h,11h,8003h,13h
		dw	8007h,16h,8003h,18h
		dw	0c002h,8007h,230h
		dw	0c001h,8003h,0ch,0ah,07h,0ah,0ffffh

s09	        dw	0c001h,8007h,0ch
		dw	8003h,0ah,8007h,0ch,8003h,0fh
		dw	0c002h,8007h,230h
		dw	0c001h,8003h,0ah,8007h,0ch
		dw	8003h,0fh,8007h,11h,8003h,13h
		dw	8007h,16h,8003h,18h
		dw	0c002h,8007h,230h,230h,230h,0ffffh

s0a		dw      0c003h
		dw	800bh,0,8007h,24h,8003h,0
		dw	8007h,27h,800fh,0
		dw	8007h,27h,800bh,0
        	dw	8007h,26h,8007h,0
        	dw	8007h,22h,8003h,0
        	dw	8007h,24h,8003h,0
        	dw	8003h,26h,8003h,0
        	dw	8007h,24h
		dw	0ffffh

s0b		dw      0c003h
		dw	800bh,0,8007h,1fh,8003h,0
		dw	8007h,22h,800fh,0
		dw	8007h,24h,800bh,0
        	dw	8007h,1fh,8007h,0
        	dw	8007h,1dh,8003h,0
        	dw	8007h,1fh,8003h,0
        	dw	8003h,22h,8003h,0
        	dw	8007h,1fh,800fh,0
        	dw	800fh,0,0,8013h,0
		dw	0ffffh

s0c		dw      0c003h
		dw	800bh,0,8007h,1bh,8003h,0
		dw	8007h,1fh,800fh,0
		dw	8007h,1dh,800bh,0
        	dw	8007h,1bh,8007h,0
        	dw	8007h,1dh,8003h,0
        	dw	8007h,1bh,8003h,0
        	dw	8003h,1fh,8003h,0
        	dw	8007h,1bh,800fh,0
        	dw	800fh,0,0,8013h,0
		dw	0ffffh


s0d		dw      0c003h,8007h,0
		dw	8003h,1fh
		dw	8003h,24h,8007h,0
		dw	8007h,27h,8003h,0
		dw	8007h,27h,8003h,0
        	dw	8007h,29h,8003h,0
        	dw	8007h,29h,8003h,0
        	dw	8007h,27h,8003h,0
        	dw	8003h,29h,8003h,0
        	dw	8007h,2bh,800fh,0
        	dw	800fh,0,0,802bh,0
		dw	0ffffh

s0e		dw      0c003h
		dw	800bh,0,8003h,1fh,8007h,0
		dw	8007h,24h,8003h,0
		dw	8007h,24h,8003h,0
        	dw	8007h,27h,8003h,0
        	dw	8007h,26h,8003h,0
        	dw	8007h,24h,8003h,0
        	dw	8003h,27h,8003h,0
        	dw	8007h,27h,800fh,0
        	dw	800fh,0,0,802bh,0
		dw	0ffffh

s0f		dw      0c003h
		dw	800bh,0,8003h,1bh,8007h,0
		dw	8007h,1fh,8003h,0
		dw	8007h,1fh,8003h,0
        	dw	8007h,22h,8003h,0
        	dw	8007h,1fh,8003h,0
        	dw	8007h,1fh,8003h,0
        	dw	8003h,22h,8003h,0
        	dw	8007h,24h,800fh,0
        	dw	800fh,0,0,802bh,0
		dw	0ffffh



s10		dw      0c003h,8007h,0
		dw	8001h,1bh,11fh
		dw	8003h,24h,8007h,0
		dw	8007h,27h,8003h,0
		dw	8007h,27h,8003h,0
        	dw	8007h,29h,8003h,0
        	dw	8007h,29h,8003h,0
        	dw	8007h,27h,8003h,0
        	dw	8003h,26h,8003h,0
        	dw	8007h,24h,800fh,0
        	dw	800fh,0,0,802bh,0
		dw	0ffffh

s11		dw      0c003h
		dw	800bh,0,8003h,1fh,8007h,0
		dw	8007h,24h,8003h,0
		dw	8007h,24h,8003h,0
        	dw	8007h,27h,8003h,0
        	dw	8001h,26h,8003h,24h,8001h,0,1fh,122h
        	dw	8007h,24h,8003h,0
        	dw	8003h,22h,8003h,0
        	dw	8007h,1fh,800fh,0
        	dw	800fh,0,0,8029h,0
		dw	0ffffh

s12		dw      0c003h
		dw	800bh,0,8003h,1bh,8007h,0
		dw	8007h,1fh,8003h,0
		dw	8007h,1fh,8003h,0
        	dw	8007h,22h,8003h,0
        	dw	8007h,1fh,8003h,0
        	dw	8007h,1fh,8003h,0
        	dw	8003h,1dh,8003h,0
        	dw	8007h,1bh,800fh,0
        	dw	800fh,0,0,8029h,0
		dw	0ffffh

s13		dw	8007h,0,0c004h
		dw	8003h,0d010h,2bh
		dw	8007h,130h
		dw	8001h,2eh,8009h,0
		dw	8007h,2bh,800bh,2eh
		dw	8007h,30h,8003h,0e00ah,0
		dw	8003h,0
		dw	0ffffh

s14		dw	8007h,0,0c004h
		dw	8003h,0d010h,2bh
		dw	8003h,130h,0
		dw	8003h,33h,8001h,135h,133h
		dw	8003h,30h,8007h,33h
		dw	800bh,35h,8003h,0d00ah,33h,137h,8003h
		dw	8001h,135h,133h,130h,0
		dw	0ffffh


s15	        dw	0c005h
		dw	8017h,0,8001h,0e018h,21ch,8004h,0,0e000h
		dw	8028h,0,8001h,0e018h,21ch,8004h,0,0e000h
		dw	8010h,0,0ffffh

s16	        dw	0c005h
		dw	8017h,0,8001h,0e018h,21ch,8004h,0,0e000h
		dw	8028h,0,8001h,0e018h,21ch,8004h,0,0e000h,8000h,0
		dw	8001h,0e018h,21ch,8004h,0,0e000h,8000h,0
		dw	8001h,0e018h,21ch,8004h,0,0e000h,8000h,0
		dw	0ffffh

s17		dw	0c001h,8007h
		dw	0ch,0ch
		dw	0c002h,224h
		dw	0c001h,0ah,0ffffh

s18		dw	0c006h,8001h
		dw	0d010h,10h
		dw	0e010h,0h
		dw	0d020h,0h
		dw	0e020h,0h
		dw	0d030h,0h
		dw	0e030h,0h
		dw	0d040h,0h
		dw	0e040h,0h
		dw	0d050h,0h
		dw	0e050h,0h
		dw	0d060h,0h
		dw	0e060h,0h
		dw	0d070h,0h
		dw	0e070h,0h
                dw	0d080h,0h
		dw	0e080h,0h
		dw	0d090h,0h
		dw	0e090h,0h
		dw	0ffffh

s19		dw	0c001h,8003h
		dw	24h,80h,80h,26h,0,0,29h,80h,0,8007h
		dw	2ah,8003h,0d008h,80h,0e008h,80h
		dw	0d020h,80h,0e002h,80h,80h,80h,80h,0,0ffffh

s1a		dw	0c005h,8002h
                dw      0d020h,30h
                dw	0d020h,02eh
                dw	0d020h,02ch,9004h
                dw	0d020h,02ah,9008h
                dw	0d020h,028h,900ch
                dw	0d020h,026h,9010h
                dw	0d020h,024h,9014h
		dw	0d020h,022h,9018h
		dw	0d020h,020h,901ch
		dw	0d020h,01eh,9020h
		dw	0d020h,01ch,9024h
		dw	0d020h,01ah,9028h
		dw	0d020h,018h,902ch
		dw	0d020h,016h,9030h
		dw	0d020h,014h
		dw	0ffffh
;----------------------------------------------------------------------------
datainfo        db      'Player v01.03 testmusic & sfx '
                db      'by JCH/Vibrants, November 1991'
;----------------------------------------------------------------------------
                ends
                end
