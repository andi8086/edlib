;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³          Normal 9-voice ADLIB/driver, version update MARCH 1992.            ³
;³                    Remember driver version in TEX222!                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                .model tiny
                .stack 100h

extrn           Version1:byte,Max:byte,General:word,SeqPointer:word,TPoin:word
extrn           Instrument:byte,Datainfo:byte,Timer:byte

extrn           Player:far,Version2:word,Voicon:byte,Credits:byte,Stopvoice:near
extrn           Sound:near

extrn           Tempw:word,Mvol:byte,ESeg:word,EOffset:word,Levels:byte
extrn           Speed:byte,Spedr:byte,TrackPointer:word,Inst:word,Dur:word
extrn           Durr:word,SeqPoi:word,TrackPoi:word,Freq:word,Gate:byte
extrn           Transp:word,SlFreq:word,Nog:byte,ShSlFreq:word,ShGate:byte
extrn           ShFreq:word,Level2:byte,Level3:byte,Carrier:byte,Modulator:byte
extrn           FreqTab:word,ShVib:word,VWidth:byte,VWid:byte,VSpeed:byte
extrn           KsLevel:byte,AdLevel:byte,FeedCon:byte,Lon:byte,LpDur:byte
extrn           LpPoi:word,LpTabel:word,LpFrame:byte,LpFram2:byte,Note:byte

MusicData       segment
                ends
MusicPlayer     segment
                ends
;-------------------------------------------------------------------------------
                .data

Tex1            dw      1*160+132
                db      'MPLAY v'
Tex111          db      '??.??',0ffh
                dw      2*160+132
Tex222          db      'MDRIV v01.09',0ffh
                dw      4*160+132
                db      'Normal ADLIB',0ffh
                dw      23*160+132
                db      'JCH/Vibrants',0ffh
                dw      1*160+4
                db      'Voicon....',0ffh
                dw      2*160+4
                db      'Levels....',0ffh
                dw      3*160+4
                db      'Kslevel...',0ffh
                dw      4*160+4
                db      'Adlevel...',0ffh
                dw      5*160+4
                db      'Level2....',0ffh
                dw      6*160+4
                db      'Level3....',0ffh
                dw      7*160+4
                db      'Speed.....',0ffh
                dw      8*160+4
                db      'Spedr.....',0ffh
                dw      9*160+4
                db      'Dur.......',0ffh
                dw      10*160+4
                db      'Durr......',0ffh
                dw      11*160+4
                db      'Inst......',0ffh
                dw      12*160+4
                db      'Trackpntr.',0ffh
                dw      13*160+4
                db      'Trackpoi..',0ffh
                dw      14*160+4
                db      'Seqpoi....',0ffh
                dw      15*160+4
                db      'Freq......',0ffh
                dw      16*160+4
                db      'Shfreq....',0ffh
                dw      17*160+4
                db      'Transp....',0ffh
                dw      18*160+4
                db      'Slfreq....',0ffh
                dw      19*160+4
                db      'Shslfreq..',0ffh
                dw      20*160+4
                db      'Gate......',0ffh
                dw      21*160+4
                db      'Shgate....',0ffh
                dw      22*160+4
                db      'Nog.......',0ffh
                dw      23*160+4
                db      'Feedcon...',0ffh
                dw      6*160+132
                db      'Tempw...',0ffh
                dw      7*160+132
                db      'Mvol....',0ffh
                dw      8*160+132
                db      'Eseg....',0ffh
                dw      9*160+132
		db	'Eoffset.',0ffh
                dw      11*160+132
                db      'Lptabel.',0ffh
                dw      13*160+132
                db      'Frm/Sec...',0feh

Tex2            dw      1*160+4
		db	'Shvib.....',0ffh
                dw      2*160+4
		db	'Vwidth....',0ffh
                dw      3*160+4
		db	'Vwid......',0ffh
                dw      4*160+4
		db	'Vspeed....',0ffh
		dw	6*160+4
		db	'Lon.......',0ffh
		dw	7*160+4
		db	'Lpdur.....',0ffh
		dw	8*160+4
		db	'Lppoi.....',0ffh
		dw	9*160+4
		db	'Lpframe...',0ffh
		dw	10*160+4
                db      'Lpfram2...',0ffh
                dw      12*160+4
                db      'Note......',0feh

NoCard          dw      12*160+42
                db      'No ADLIB compatible soundcard present.',0feh

Hexv            db      '0123456789ABCDEF'

Keys            db      02h,03h,04h,05h,06h,07h,08h,09h,0ah,0bh ; Keys 1-0.
                db      1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h
                db      18h,19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch ; A-Z.

Deci            db      6 dup (0)

OldAdr          dw      0
OldSeg          dw      0

Toggle          db      0
DontPlay        db      0
TuneNr          dw      0
NewVol          db      0
EOffset2        dw      0000h   ;Test offset value for musicdata.
;-------------------------------------------------------------------------------
                .code
                jumps

RunPlay:        push    ax bx cx dx di si
                mov     ax,@data
                mov     ds,ax
                cmp     [DontPlay],0
                jne     ru40
                mov     bl,7
                call    Raster
                mov     ah,3
                call    Player
                mov     bl,0
                call    Raster
ru40:           pop     si di dx cx bx ax
		iret
;-------------------------------------------------------------------------------
StartDriver:    cld

                mov     ax,@data
		mov	ds,ax

                mov     [TuneNr],0
                mov     [NewVol],0
                mov     [DontPlay],0
                mov     [Toggle],0

                mov     ax,0003h
		int	10h

                mov     ah,2                    ;Cursor in 1,1.
                mov     dx,5050h
                xor     bh,bh
		int	10h

                mov     ax,MusicPlayer
                mov     es,ax

                mov     ax,[es:Version2]
		push	ax
                and     al,0fh
		add	al,30h
                mov     [Tex111+4],al           ;Music-Player version.
		and	ah,0fh
		add	ah,30h
                mov     [Tex111+1],ah
		pop	ax
		and	al,0f0h
		mov	cl,4
		shr	al,cl
		add	al,30h
                mov     [Tex111+3],al
		and	ah,0f0h
		shr	ah,cl
		add	ah,30h
                mov     [Tex111],ah

                mov     ax,0b800h
                mov     es,ax

                call    Wire

                mov     ah,6                    ;Look for AdLib card!
                call    Player
                jnc     st05

                mov     al,1
                mov     di,12*160+43
                mov     cx,38
st04:           stosb
                inc     di
                loop    st04

                lea     si,NoCard               ;It wasn't found...
                call    Print
                mov     ah,0
                int     16h
                jmp     Quit
st05:
                lea     si,Tex1
                call    Print

                mov     al,2                    ;Text colors.
                mov     di,23*160+133
                mov     cx,12
st10:           stosb
                inc     di
                loop    st10

                mov     al,12
                mov     di,1*160+133
                mov     cx,12
st11:           stosb
                inc     di
                loop    st11

                mov     di,2*160+133
                mov     cx,12
st12:           stosb
                inc     di
                loop    st12

                mov     al,0eh
                mov     di,4*160+133
                mov     cx,12
st13:           stosb
                inc     di
                loop    st13

                mov     al,03h
                mov     di,13*160+133
                mov     cx,12
st14:           stosb
                inc     di
                loop    st14

                xor     ah,ah
                mov     bx,MusicData
                mov     cx,[EOffset2]
                call    Player

                call    Vertical

                mov     cx,4000h                ;Timer for rastertime.
st20:		loop	st20

                mov     ax,MusicData            ;Print Frames/Second.
                mov     es,ax
                mov     al,byte ptr [es:8]
                xor     ah,ah
                call    CalcTimer
                mov     di,13*160+152
                call    Decimal

		cli
                mov     ax,0000h
                mov     es,ax

		mov	ax,[es:1ch*4]
                mov     [OldAdr],ax
		mov	ax,[es:1ch*4+2]
                mov     [OldSeg],ax
                lea     ax,RunPlay
		mov	[es:1ch*4],ax
		mov	ax,cs
		mov	[es:1ch*4+2],ax
                mov     al,36h
                out	43h,al
                mov     al,dl
                out	40h,al
                nop
                nop
                mov     al,dh
                out	40h,al
                sti
Driver:
                xor     bx,bx
                xor     si,si
                mov     cx,1*160+24

                mov     ax,MusicPlayer
                mov     es,ax
dri30:
                cmp     [Toggle],0
                jz      dri35
                mov     di,cx
                mov     ax,[es:ShVib+si]
                call    HexWord
                add     di,160
                mov     al,[es:VWidth+bx]
                xor     ah,ah
                call    HexWord
                add     di,160
                mov     al,[es:VWid+bx]
                call    HexWord
                add     di,160
                mov     al,[es:VSpeed+bx]
                call    HexWord
		add	di,320
                mov     al,[es:Lon+bx]
                call    HexWord
		add	di,160
                mov     al,[es:LpDur+bx]
                call    HexWord
		add	di,160
                mov     ax,[es:LpPoi+si]
                call    HexWord
		add	di,160
                mov     al,[es:LpFrame+bx]
		xor	ah,ah
                call    HexWord
		add	di,160
                mov     al,[es:LpFram2+bx]
                call    HexWord
                add     di,320
                mov     al,[es:Note+bx]
                jmp     dri36
dri35:
		mov	di,cx
                mov     al,[es:Voicon+bx]
                xor     ah,ah
                call    HexWord
                add     di,160
                mov     al,[es:Levels+bx]
                call    HexWord
                add     di,160
                mov     al,[es:KsLevel+bx]
                call    HexWord
                add     di,160
                mov     al,[es:AdLevel+bx]
                call    HexWord
                add     di,160
                mov     al,[es:Level2+bx]
                call    HexWord
                add     di,160
                mov     al,[es:Level3+bx]
                call    HexWord
		add	di,160
                mov     al,[es:Speed+bx]
                call    HexWord
                add     di,160
                mov     al,[es:Spedr+bx]
                call    HexWord
                add     di,160
                mov     ax,[es:Dur+si]
                call    HexWord
                add     di,160
                mov     ax,[es:Durr+si]
                call    HexWord
		add	di,160
                mov     ax,[es:Inst+si]
                call    HexWord
                add     di,160
                mov     ax,[es:TrackPointer+si]
                call    HexWord
                add     di,160
                mov     ax,[es:TrackPoi+si]
                call    HexWord
		add	di,160
                mov     ax,[es:SeqPoi+si]
                call    HexWord
		add	di,160
                mov     ax,[es:Freq+si]
                call    HexWord
		add	di,160
                mov     ax,[es:ShFreq+si]
                call    HexWord
		add	di,160
                mov     ax,[es:Transp+si]
                call    HexWord
		add	di,160
                mov     ax,[es:SlFreq+si]
                call    HexWord
                add     di,160
                mov     ax,[es:ShSlFreq+si]
                call    HexWord
                add     di,160
                mov     al,[es:Gate+bx]
                xor     ah,ah
                call    HexWord
                add     di,160
                mov     al,[es:ShGate+bx]
                call    HexWord
                add     di,160
                mov     al,[es:Nog+bx]
                call    HexWord
                add     di,160
                mov     al,[es:FeedCon+bx]
dri36:          call    HexWord
                inc     si
                inc     si
		inc	bx
		add	cx,12
                cmp     bx,9
                jne     dri30

                mov     di,6*160+148
                mov     ax,[es:Tempw]
                call    HexWord
                add     di,160
                mov     al,[es:Mvol]
                xor     ah,ah
                call    HexWord
                add     di,160
                mov     ax,[es:ESeg]
                call    HexWord
                add     di,160
                mov     ax,[es:EOffset]
                call    HexWord
		add	di,320
                mov     ax,[es:LpTabel]
                call    HexWord
DriveKey1:
                mov     ax,0000h                ;CTRL to fast forward!
                mov     es,ax
                test    byte ptr [es:417h],00000100b
                jz      DriveKey2
                inc     [DontPlay]
                mov     ah,3
                call    Player
                dec     [DontPlay]
                jmp     Driver
DriveKey2:
                mov     ah,1
                int     16h
                jz      Driver
                xor     ah,ah
                int     16h

                mov     bx,MusicData
                mov     es,bx

                cmp     ah,0fh                  ;TAB key.
                jne     dri50
                mov     ax,0b800h
                mov     es,ax
                call    Clear
                xor     [Toggle],1
                jz      dri410
                lea     si,Tex2
                call    Print
                jmp     Driver
dri410:         lea     si,Tex1
                call    Print
                jmp     Driver
dri50:
                cmp     ah,39h                  ;SPACE.
                jne     dri52
                mov     ah,4
                mov     bx,[TuneNr]
                inc     [DontPlay]
                call    Player
                dec     [DontPlay]
                jmp     Driver
dri52:
                cmp     ah,50h                  ;DOWN key.
                jne     dri54
                cmp     [NewVol],3fh
                jz      Driver
                inc     [NewVol]
                jmp     short dri55
dri54:
                cmp     ah,48h                  ;UP key.
                jne     dri57
                cmp     [NewVol],0
                jz      Driver
                dec     [NewVol]
dri55:          mov     ah,5
                mov     bl,[NewVol]
                call    Player
                jmp     Driver
dri57:
                cmp     ah,1ch                  ;ENTER.
                jne     dri59
                mov     ah,1
                inc     [DontPlay]
                call    Player
                mov     [NewVol],0
                dec     [DontPlay]
                jmp     Driver
dri59:
                xor     bx,bx
dri592:         cmp     ah,[Keys+bx]
                jne     dri593                  ;1-9 keys.
                mov     ah,2
                mov     [TuneNr],bx
                inc     [DontPlay]
                call    Player
                dec     [DontPlay]
                jmp     Driver
dri593:		inc	bx
                mov     si,[EOffset2]
                cmp     bl,[es:Max+si]
		jne	dri592
dri80:
                cmp     ah,01h ;ESC
                jne     Driver
dri90:
                cli
                mov     ax,0000h
                mov     es,ax

                mov     ax,[OldAdr]             ;Restore INT 1Ch (Timer IRQ).
		mov	[es:1ch*4],ax
                mov     ax,[OldSeg]
		mov	[es:1ch*4+2],ax
                mov     al,36h
                out	43h,al
                xor     al,al
                out	40h,al
                nop
                nop
                out	40h,al
		sti

                mov     ah,1
                call    Player
Quit:
                mov     ax,0003h
                int     10h
                mov     ax,0c06h
                mov     dl,0ffh
		int	21h
		mov	ax,4c00h
		int	21h
;-------------------------------------------------------------------------------
CalcTimer       proc                            ;Calculate timer frequency.
                mov     bx,ax
                mov     dx,0012h
                mov     ax,34dch                ;The famous 1,193,180 value.
                div     bx
                mov     dx,ax
                mov     ax,bx
                ret
                endp
;-------------------------------------------------------------------------------
Wire            proc
                xor     di,di
                mov     ah,08h                  ;Line text color.
                mov     bl,07h                  ;Middle text color.

                mov     al,218
		stosw				
                mov     al,196
		mov	cx,78
                rep     stosw
                mov     al,191
		stosw

                mov     dx,23
wi30:           mov     al,179
		stosw
		push	ax
		mov	ah,bl
                xor     al,al
		mov	cx,78
                rep     stosw
		pop	ax
                mov     al,179
		stosw
		dec	dx
		jne	wi30

                mov     al,192
		stosw
                mov     al,196
		mov	cx,78
                rep     stosw
                mov     al,217
		stosw

              ; mov     byte ptr [es:160+3],00h ;Black cursor.
		mov	[es:160+157],ah
		mov	[es:23*160+3],ah
		mov	[es:23*160+157],ah
		ret
		endp
;-------------------------------------------------------------------------------
Print           proc
		mov	di,[si]
		inc	si
		inc	si
pr10:		lodsb
		cmp	al,0ffh
		jne	pr15
		inc	di
                jmp     short Print
pr15:		cmp	al,0feh
		jz	pr20
		stosb
		inc	di
		jmp	short pr10
pr20:		ret
		endp
;-------------------------------------------------------------------------------
Clear           proc
                mov     di,1*160+2
                mov     al,0
cl10:           mov     cx,64
cl20:           stosb
                inc     di
                loop    cl20
                add     di,32
                cmp     di,24*160
                jb      cl10
                ret
                endp
;-------------------------------------------------------------------------------
include         \work\lib\hexword.lib
include         \work\lib\raster.lib
include         \work\lib\vertical.lib
include         \work\lib\decimal.lib
;-------------------------------------------------------------------------------
                end     StartDriver
