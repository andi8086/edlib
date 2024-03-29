;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;�  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  �
;쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;�     Sound Blaster/8-BIT DMA samples/driver, version update MARCH 1992.      �
;�                    Remember driver version in TEX222!                       �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
                .model tiny
                .stack 100h

extrn           version1:byte,max:byte,general:word,seqpointer:word,tpoin:word
extrn           instrument:byte,datainfo:byte,timer:byte,maxsamp:byte,names:byte
extrn           loadpos:word

extrn           player:far,version2:word,voicon:byte,credits:byte,stopvoice:near
extrn           sound:near

extrn           tempw:word,mvol:byte,eseg:word,eoffset:word,levels:byte
extrn           speed:byte,spedr:byte,trackpointer:word,inst:word,dur:word
extrn           durr:word,seqpoi:word,trackpoi:word,freq:word,gate:byte
extrn           transp:word,slfreq:word,nog:byte,shslfreq:word,shgate:byte
extrn           shfreq:word,level2:byte,level3:byte,carrier:byte,modulator:byte
extrn           freqtab:word,shvib:word,vwidth:byte,vwid:byte,vspeed:byte
extrn		kslevel:byte,adlevel:byte,feedcon:byte,lon:byte,lpdur:byte
extrn           lppoi:word,lptabel:word,lpframe:byte,lpfram2:byte,note:byte
extrn           sampleseg:word,dsp:word

musicdata       segment
                ends
musicplayer     segment
                ends
;-------------------------------------------------------------------------------
                .data

tex1            dw      1*160+132
                db      'MPLAY v'
tex111          db      '??.??',0ffh
                dw      2*160+132
tex222          db      'MDRIV v01.04',0ffh
                dw      4*160+132
                db      'SB/8-BIT DMA',0ffh
                dw      23*160+132
                db      'JCH/Vibrants',0ffh
                dw      1*160+4
                db      'Voicon......',0ffh
                dw      2*160+4
                db      'Levels......',0ffh
                dw      3*160+4
                db      'Kslevel.....',0ffh
                dw      4*160+4
                db      'Adlevel.....',0ffh
                dw      5*160+4
                db      'Level2......',0ffh
                dw      6*160+4
                db      'Level3......',0ffh
                dw      7*160+4
                db      'Speed.......',0ffh
                dw      8*160+4
                db      'Spedr.......',0ffh
                dw      9*160+4
                db      'Dur.........',0ffh
                dw      10*160+4
                db      'Durr........',0ffh
                dw      11*160+4
                db      'Inst........',0ffh
                dw      12*160+4
                db      'Trackpntr...',0ffh
                dw      13*160+4
                db      'Trackpoi....',0ffh
                dw      14*160+4
                db      'Seqpoi......',0ffh
                dw      15*160+4
                db      'Freq........',0ffh
                dw      16*160+4
                db      'Shfreq......',0ffh
                dw      17*160+4
                db      'Transp......',0ffh
                dw      18*160+4
                db      'Slfreq......',0ffh
                dw      19*160+4
                db      'Shslfreq....',0ffh
                dw      20*160+4
                db      'Gate........',0ffh
                dw      21*160+4
                db      'Shgate......',0ffh
                dw      22*160+4
                db      'Nog.........',0ffh
                dw      23*160+4
                db      'Feedcon.....',0ffh
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
                db      'Smplseg.',0ffh
                dw      14*160+132
                db      'Dsp.....',0feh

tex2            dw      1*160+4
                db      'Shvib.......',0ffh
                dw      2*160+4
                db      'Vwidth......',0ffh
                dw      3*160+4
                db      'Vwid........',0ffh
                dw      4*160+4
                db      'Vspeed......',0ffh
		dw	6*160+4
                db      'Lon.........',0ffh
		dw	7*160+4
                db      'Lpdur.......',0ffh
		dw	8*160+4
                db      'Lppoi.......',0ffh
		dw	9*160+4
                db      'Lpframe.....',0ffh
		dw	10*160+4
                db      'Lpfram2.....',0ffh
                dw      12*160+4
                db      'Note........',0feh

nocard          dw      12*160+42
                db      'No ADLIB compatible soundcard present.',0feh

DSPerror        dw      12*160+44
                db      'DSP reset error - no Sound Blaster ?',0feh

hexv            db      '0123456789ABCDEF'

keys            db      02h,03h,04h,05h,06h,07h,08h,09h,0ah,0bh ; Keys 1-0.
                db      1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h
                db      18h,19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch ; A-Z.

oldadr          dw      0
oldseg		dw	0

maxsamp2        db      0
toggle          db      0
dontplay        db      0
tunenr          dw      0
newvol          db      0
eoffset2        dw      0000h   ;Test offset value for musicdata.

nname           db      50 dup (0)
nseg            dw      0,0

include         \work\lib\execerr.lib
;-------------------------------------------------------------------------------
                .code
                jumps

runplay:        push    ax bx cx dx di si
                mov     ax,@data
                mov     ds,ax
                cmp     [dontplay],0
                jne     ru40
                mov     bl,7
                call    raster
                mov     ah,3
                call    player
                mov     bl,0
                call    raster
ru40:           pop     si di dx cx bx ax
		iret
;-------------------------------------------------------------------------------
startdriver:    cld

                mov     ax,@data
		mov	ds,ax

                mov     [tunenr],0
                mov     [newvol],0
                mov     [dontplay],0
                mov     [toggle],0

                call    load_samples

                mov     ax,0003h
		int	10h

                mov     ah,2            ;Cursor in 1,1
		mov	dx,0101h
                xor     bh,bh
		int	10h

                mov     ax,musicplayer
                mov     es,ax

                mov     ax,[es:version2]
		push	ax
                and     al,0fh
		add	al,30h
                mov     [tex111+4],al   ;Music-Player version
		and	ah,0fh
		add	ah,30h
		mov	[tex111+1],ah
		pop	ax
		and	al,0f0h
		mov	cl,4
		shr	al,cl
		add	al,30h
		mov	[tex111+3],al
		and	ah,0f0h
		shr	ah,cl
		add	ah,30h
		mov	[tex111],ah

                mov     ax,0b800h
                mov     es,ax

                call    wire

                mov     ah,6            ;Look for AdLib card!
                call    player
                jnc     st05

                lea     si,nocard       ;It wasn't found...
st03:
                call    print

                mov     al,1
                mov     di,12*160+43
                mov     cx,38
st04:           stosb
                inc     di
                loop    st04

                mov     ah,0
                int     16h
                jmp     quit
st05:
                xor     ah,ah           ;Initialize the music-player
                mov     bx,musicdata
                mov     cx,[eoffset2]
                mov     dx,6000h
                call    player
                jnc     st08

                lea     si,DSPerror     ;Reset error in the DSP voice.
                jmp     short st03
st08:
                lea     si,tex1
                call    print

                mov     al,2            ;Text colors
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

                mov     al,1
                mov     di,4*160+133
                mov     cx,12
st13:           stosb
                inc     di
                loop    st13

                mov     dx,23           ;Colour the DSP channel
                mov     ax,000fh
                mov     di,1*160+121
st14:           mov     cx,4
                rep     stosw
                add     di,152
                dec     dx
                jne     st14

                call    vertical

                mov     cx,4000h        ;Timer for rastertime.
st20:		loop	st20

		cli
                mov     ax,0000h
                mov     es,ax

		mov	ax,[es:1ch*4]
		mov	[oldadr],ax
		mov	ax,[es:1ch*4+2]
		mov	[oldseg],ax
		lea	ax,runplay
		mov	[es:1ch*4],ax
		mov	ax,cs
		mov	[es:1ch*4+2],ax
                mov     al,36h
                out	43h,al
                mov     al,81h
                out     40h,al
                nop
                nop
	        mov	al,42h
                out	40h,al
                sti
driver:
                xor     bx,bx
                xor     si,si
                mov     cx,1*160+28

                mov     ax,musicplayer
                mov     es,ax
dri30:
                cmp     [toggle],0
                jz      dri35
                mov     di,cx
                mov     ax,[es:shvib+si]
                call    hexword
                add     di,160
                mov     al,[es:vwidth+bx]
                xor     ah,ah
                call    hexword
                add     di,160
                mov     al,[es:vwid+bx]
                call    hexword
                add     di,160
                mov     al,[es:vspeed+bx]
		call	hexword
		add	di,320
                mov     al,[es:lon+bx]
		call	hexword
		add	di,160
                mov     al,[es:lpdur+bx]
		call	hexword
		add	di,160
                mov     ax,[es:lppoi+si]
		call	hexword
		add	di,160
                mov     al,[es:lpframe+bx]
		xor	ah,ah
		call	hexword
		add	di,160
                mov     al,[es:lpfram2+bx]
                call    hexword
                add     di,320
                mov     al,[es:note+bx]
                jmp     dri36
dri35:
		mov	di,cx
                mov     al,[es:voicon+bx]
                xor     ah,ah
                call    hexword
                add     di,160
                mov     al,[es:levels+bx]
		call	hexword
                add     di,160
                mov     al,[es:kslevel+bx]
                call    hexword
                add     di,160
                mov     al,[es:adlevel+bx]
                call    hexword
                add     di,160
                mov     al,[es:level2+bx]
                call    hexword
                add     di,160
                mov     al,[es:level3+bx]
                call    hexword
		add	di,160
                mov     al,[es:speed+bx]
		call	hexword
                add     di,160
                mov     al,[es:spedr+bx]
                call    hexword
                add     di,160
                mov     ax,[es:dur+si]
                call    hexword
                add     di,160
                mov     ax,[es:durr+si]
		call	hexword
		add	di,160
                mov     ax,[es:inst+si]
		call	hexword
                add     di,160
                mov     ax,[es:trackpointer+si]
                call    hexword
                add     di,160
                mov     ax,[es:trackpoi+si]
		call	hexword
		add	di,160
                mov     ax,[es:seqpoi+si]
		call	hexword
		add	di,160
                mov     ax,[es:freq+si]
		call	hexword
		add	di,160
                mov     ax,[es:shfreq+si]
		call	hexword
		add	di,160
                mov     ax,[es:transp+si]
		call	hexword
		add	di,160
                mov     ax,[es:slfreq+si]
		call	hexword
                add     di,160
                mov     ax,[es:shslfreq+si]
                call    hexword
                add     di,160
                mov     al,[es:gate+bx]
                xor     ah,ah
                call    hexword
                add     di,160
                mov     al,[es:shgate+bx]
                call    hexword
                add     di,160
                mov     al,[es:nog+bx]
                call    hexword
                add     di,160
                mov     al,[es:feedcon+bx]
dri36:          call    hexword
                inc     si
                inc     si
		inc	bx
                add     cx,10
                cmp     bx,10
                jz      dri38
                cmp     bx,9
                jne     dri30
                add     cx,2
                jmp     dri30
dri38:
                mov     di,6*160+148
                mov     ax,[es:tempw]
                call    hexword
                add     di,160
                mov     al,[es:mvol]
                xor     ah,ah
                call    hexword
                add     di,160
                mov     ax,[es:eseg]
                call    hexword
                add     di,160
                mov     ax,[es:eoffset]
                call    hexword
		add	di,320
		mov	ax,[es:lptabel]
		call	hexword
                add     di,320
                mov     ax,[es:sampleseg]
                call    hexword
                add     di,160
                mov     ax,[es:dsp]
                call    hexword
drivekey1:
                mov     ax,0000h        ;CTRL to fast forward!
                mov     es,ax
                test    byte ptr [es:417h],00000100b
                jz      drivekey2
                inc     [dontplay]
                mov     ah,3
                call    player
                dec     [dontplay]
                jmp     driver
drivekey2:
                mov     ah,1
                int     16h
                jz      driver
                mov     ah,0
                int     16h

                mov     bx,musicdata
                mov     es,bx

                cmp     ah,0fh ;TAB
                jne     dri50
                mov     ax,0b800h
                mov     es,ax
                call    clear
                xor     [toggle],1
                jz      dri410
                lea     si,tex2
                call    print
                jmp     driver
dri410:         lea     si,tex1
                call    print
                jmp     driver
dri50:
                cmp     ah,39h ;SPACE
                jne     dri52
                mov     ah,4
                mov     bx,[tunenr]
                inc     [dontplay]
                call    player
                dec     [dontplay]
                jmp     driver
dri52:
                cmp     ah,50h ;DOWN
                jne     dri54
                cmp     [newvol],3fh
                jz      driver
                inc     [newvol]
                jmp     short dri55
dri54:
                cmp     ah,48h ;UP
                jne     dri57
                cmp     [newvol],0
                jz      driver
                dec     [newvol]
dri55:          mov     ah,5
                mov     bl,[newvol]
                call    player
                jmp     driver
dri57:
                cmp     ah,1ch ;ENTER
                jne     dri59
                mov     ah,1
                inc     [dontplay]
                call    player
                mov     [newvol],0
                dec     [dontplay]
                jmp     driver
dri59:
                xor     bx,bx
dri592:         cmp     ah,[keys+bx]
		jne	dri593 ;1-9
                mov     ah,2
                mov     [tunenr],bx
                inc     [dontplay]
                call    player
                dec     [dontplay]
                jmp     driver
dri593:		inc	bx
                mov     si,[eoffset2]
                cmp     bl,[es:max+si]
		jne	dri592
dri80:
                cmp     ah,01h ;ESC
                jne     driver
dri90:
                cli
                mov     ax,0000h
                mov     es,ax

		mov	ax,[oldadr]	;Restore INT 1Ch (Timer irq)
		mov	[es:1ch*4],ax
		mov	ax,[oldseg]
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
                call    player
quit:
                mov     ax,0003h
                int     10h
                mov     ax,0c06h
                mov     dl,0ffh
		int	21h
		mov	ax,4c00h
		int	21h
;-------------------------------------------------------------------------------
wire            proc
                xor     di,di
                mov     ah,08h ;Lne text
                mov     bl,07h ;Mid text

                mov     al,218
		stosw				
                mov     al,196
		mov	cx,78
		rep stosw
                mov     al,191
		stosw

                mov     dx,23
wi30:           mov     al,179
		stosw
		push	ax
		mov	ah,bl
                xor     al,al
		mov	cx,78
		rep stosw
		pop	ax
                mov     al,179
		stosw
		dec	dx
		jne	wi30

                mov     al,192
		stosw
                mov     al,196
		mov	cx,78
		rep stosw
                mov     al,217
		stosw

		mov	byte ptr [es:160+3],00h ;Black cursor
		mov	[es:160+157],ah
		mov	[es:23*160+3],ah
		mov	[es:23*160+157],ah
		ret
		endp
;-------------------------------------------------------------------------------
print           proc
		mov	di,[si]
		inc	si
		inc	si
pr10:		lodsb
		cmp	al,0ffh
		jne	pr15
		inc	di
		jmp	short print
pr15:		cmp	al,0feh
		jz	pr20
		stosb
		inc	di
		jmp	short pr10
pr20:		ret
		endp
;-------------------------------------------------------------------------------
clear           proc
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
load_samples    proc
                mov     ax,musicdata
                mov     es,ax

                mov     byte ptr [maxsamp2],0
                xor     bx,bx
                xor     di,di
loa20:
                xor     si,si
loa22:          mov     al,[es:names+bx]
                mov     [nname+si],al
                inc     bx
                inc     si
                cmp     si,48
                jne     loa22

                mov     ax,[es:loadpos+di]
                mov     [nseg],ax
                add     di,4

                push    bx
                lea     dx,nname
                lea     bx,nseg
                call    noexec
                pop     bx

                inc     byte ptr [maxsamp2]
                mov     al,[maxsamp2]
                cmp     al,[es:maxsamp]
                jne     loa20
                ret
                endp
;-------------------------------------------------------------------------------
include         \work\lib\hexword.lib
include         \work\lib\raster.lib
include         \work\lib\vertical.lib
include         \work\lib\noexec.lib
;-------------------------------------------------------------------------------
                end     startdriver
