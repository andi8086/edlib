;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³     Sound Blaster/8-BIT DMA samples/driver, version update MARCH 1992.      ³
;³                                                                             ³
;³  This is a commercial screen made in april 1992, to show of my new player.  ³
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

Tex1            dw      2*160+6
                db      'VIBRANTS presents "The Alibi", originally composed on the Commodore 64 by',0ffh
                dw      3*160+6
                db      'Thomas Egeskov Petersen (in his own music-routine there), and then later',0ffh
                dw      4*160+6
                db      'converted to SOUND BLASTER/8-BIT DMA player v01.02 by Jens-Christian Huus.',0ffh
                dw      6*160+6
                db      'Interesting facts about the music:',0ffh
                dw      8*160+8
                db      '* True SOUND BLASTER player using ADLIB and DSP for what they do best',0ffh
                dw      9*160+12
                db      'individually; ADLIB for 9-voice musical part and DSP for percussion.',0ffh
                dw      11*160+8
                db      '* DMA sample rates at 16 Khz, sampled from a KORG M1 using the VOICE',0ffh
                dw      12*160+12
                db      'EDITOR v2.03 on a SOUND BLASTER PRO (with DSP version 3.01).',0ffh
                dw      14*160+8
                db      '* The player automatically checks to see if SOUND BLASTER is present,',0ffh
                dw      15*160+12
                db      'and if it is, what I/O address it is using. It does NOT need IRQ !',0ffh
                dw      17*160+8
                db      '* The colored bar in the border is the processing time required.',0ffh
                dw      19*160+8
                db      '* Use F1 to restart music, ENTER to stop it, CTRL for fast forward,',0ffh
                dw      20*160+12
                db      'SPACE to toggle pause ON/OFF and of course ESC to exit to DOS.',0ffh
                dw      22*160+8
                db      '* I can be reached at: JCH, Tranegaardsvej 71 A, 2900 Hellerup, Denmark.',0feh

nocard          dw      12*160+44
                db      'No ADLIB compatible soundcard found.',0feh

DSPerror        dw      12*160+44
                db      'DSP reset error - no Sound Blaster ?',0feh

hexv            db      '0123456789ABCDEF'

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

                mov     al,1ch
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

                call    vertical
                mov     cx,2000h
st15:           loop    st15

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

                mov     ah,2            ;Play "The Alibi"
                mov     bx,1
                inc     [dontplay]
                call    player
                dec     [dontplay]
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
                mov     ah,1bh ;Lne text
                mov     bl,1eh ;Mid text

                mov     al,201
		stosw				
                mov     al,205
                mov     cx,78
		rep stosw
                mov     al,187
		stosw

                mov     dx,23
wi30:           mov     al,186
		stosw
		push	ax
		mov	ah,bl
                xor     al,al
                mov     cx,78
		rep stosw
		pop	ax
                mov     al,186
		stosw
		dec	dx
		jne	wi30

                mov     al,200
                stosw
                mov     al,205
                mov     cx,78
                rep stosw
                mov     al,188
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
include         \work\lib\raster.lib
include         \work\lib\vertical.lib
;-------------------------------------------------------------------------------
                end     startdriver
