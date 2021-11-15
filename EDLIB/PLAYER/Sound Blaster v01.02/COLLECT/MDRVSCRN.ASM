;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³     Sound Blaster/8-BIT DMA samples/driver, version update MARCH 1992.      ³
;³                    Remember driver version in TEX222!                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

tex1            dw      2*80+4
                db      'VIBRANTS presents..........The Alibi',0ffh
                dw      18*160+4
                db      'Originally composed on the Commodore 64 by Thomas "LAXITY" Egeskov Petersen.',0ffh
                dw      19*160+4
                db      'Converted into SOUND BLASTER/8-BIT DMA player v01.02 by Jens-Christian Huus.',0ffh
                dw      21*160+6
                db      'DMA sample rates at 16 Khz, sampled from KORG M1 using VOICE EDITOR v2.03.',0ffh

                dw      23*160+4
                db      'Player & Sound (C) Copyright Jens-Christian Huus, 1992. All rights reserved.',0ffh

                dw      6*160
                db      'ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',0ffh
                dw      7*160
                db      '³ F1    ³ Restart music.               ³',0ffh
                dw      8*160
                db      'ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',0ffh
                dw      9*160
                db      '³ ENTER ³ Stop music.                  ³',0ffh
                dw      10*160
                db      'ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',0ffh
                dw      11*160
                db      '³ SPACE ³ Toggle pause ON/OFF.         ³',0ffh
                dw      12*160
                db      'ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',0ffh
                dw      13*160
                db      '³ CTRL  ³ Fast forward.                ³',0ffh
                dw      14*160
                db      'ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',0ffh
                dw      15*160
                db      '³ ESC   ³ Exit to DOS.                 ³',0ffh
                dw      16*160
                db      'ÃÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',0feh


                dw      12*80+4
                db      'Restart tune......................F1',0ffh
                dw      14*80+4
                db      'Stop tune......................ENTER',0ffh
                dw      16*80+4
                db      'Toggle pause...................SPACE',0ffh
                dw      18*80+4
                db      'Fast forward....................CTRL',0ffh
                dw      22*80+4
                db      'Exit to DOS......................ESC',0feh






nocard          dw      12*160+44
                db      'No ADLIB compatible soundcard found.',0feh

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
                mov     ah,3
                call    player
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

                mov     ah,2            ;Cursor out of screen
                mov     dx,3131h
                xor     bh,bh
		int	10h

                mov     ax,musicplayer
                mov     es,ax

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
                mov     di,12*160+3
                mov     cx,68
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

              ; mov     al,2            ;Text colors
              ; mov     di,23*160+133
              ; mov     cx,12
st10:         ; stosb
              ; inc     di
              ; loop    st10

              ; mov     al,12
              ; mov     di,1*160+133
              ; mov     cx,12
st11:         ; stosb
              ; inc     di
              ; loop    st11

              ; mov     di,2*160+133
              ; mov     cx,12
st12:         ; stosb
              ; inc     di
              ; loop    st12

              ; mov     al,1
              ; mov     di,4*160+133
              ; mov     cx,12
st13:         ; stosb
              ; inc     di
              ; loop    st13

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

 ;              mov     ah,2            ;Play "The Alibi"
  ;             mov     bx,1
   ;            inc     [dontplay]
    ;           call    player
     ;          dec     [dontplay]
driver:
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
                cmp     ah,3bh
                jne     dri80  ;F1
                mov     ah,2
                mov     bx,1
                inc     [dontplay]
                call    player
                dec     [dontplay]
                jmp     driver
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
                mov     ah,09h ;Lne text
                mov     bl,09h ;Mid text

                mov     al,213
		stosw				
                mov     al,205
                mov     cx,78
		rep stosw
                mov     al,184
		stosw

                mov     dx,23
wi30:           mov     al,179
		stosw
		push	ax
		mov	ah,bl
                xor     al,al
                mov     cx,78
		rep stosw
		pop	ax
                mov     al,179
		stosw
		dec	dx
		jne	wi30

                mov     al,212
		stosw
                mov     al,205
                mov     cx,78
		rep stosw
                mov     al,190
		stosw

                sub     di,3*160
                mov     al,195
                stosw
                mov     al,196
                mov     cx,78
                rep stosw
                mov     al,180
                stosw

              ; mov     byte ptr [es:160+3],00h ;Hide cursor
              ; mov     [es:160+157],ah
              ; mov     [es:23*160+3],ah
              ; mov     [es:23*160+157],ah
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
include         \work\lib\noexec.lib
;-------------------------------------------------------------------------------
                end     startdriver
