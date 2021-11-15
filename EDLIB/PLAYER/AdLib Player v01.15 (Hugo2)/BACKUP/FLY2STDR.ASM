;-------------------------------------------------------------------------------
; MUSIC DRIVER v01.04, updated DECEMBER 1991. Remember driver version in TEX222
;-------------------------------------------------------------------------------
; Lowest player supported is v01.10...
;-------------------------------------------------------------------------------
                .model tiny
                .stack 80h

extrn           version1:word,max:byte,general:word,seqpointer:word,tpoin:word
extrn           instrument:byte,datainfo:byte

extrn           player:far,version2:word,voicon:word,credits:byte,stopvoice:near
extrn           sound:near

extrn           tempw:word,mvol:byte,eseg:word,eoffset:word,levels:byte
extrn           speed:word,spedr:word,trackpointer:word,inst:word,dur:word
extrn           durr:word,seqpoi:word,trackpoi:word,freq:word,gate:word
extrn           transp:word,slfreq:word,nog:word,shslfreq:word,shgate:word
extrn           shfreq:word,level2:byte,level3:byte,carrier:byte,modulator:byte
extrn           freqtab:word,shvib:word,vwidth:word,vwid:word,vspeed:word
extrn           kslevel:byte,feedcon:byte

musicdata       segment
                ends
musicplayer     segment
                ends
;-------------------------------------------------------------------------------
                .data

tex1            dw      6*160+16
                db      'AdLib player v01.15 and sfx by Jens-Christian Huus, March 1992.',0ffh
                dw      8*160+24
                db      201,52 dup (205),187,0ffh
                dw      9*160+24
                db      186,' HUGO II part 2: The plane scene, CHAIR FALL, v2.00 ',186,0ffh
                dw      10*160+24
                db      200,52 dup (205),188,0ffh
                dw      12*160+32
                db      'The plane turns into dust....................1 ',0ffh
                dw      13*160+32
                db      'Hugo falls from a charred plane..............2 ',0ffh
                dw      14*160+32
                db      'He hits the ground, sitting on a chair.......3 ',0ffh
              ; dw      21*160+32
              ; db      'Pause the chosen sound...................SPACE',0ffh
                dw      16*160+32
                db      'Fast forward..............................CTRL',0ffh
                dw      17*160+32
                db      'Alter main volumen.....................UP/DOWN',0ffh
                dw      18*160+32
                db      'Stop all and reset volumen to max........ENTER',0feh

keys            db      02h,03h,04h,05h,06h,07h,08h,09h,0ah,0bh ; Keys 1-0.
                db      1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h
                db      18h,19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch ; A-Z.

oldadr          dw      0
oldseg		dw	0

toggle          db      0
dontplay        db      0
tunenr          dw      0
newvol          db      0
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

		mov	ax,0003h
		int	10h

                mov     ah,2            ;Cursor in 1,1
		mov	dx,0101h
                xor     bh,bh
		int	10h

                mov     ax,0b800h
                mov     es,ax

                call    wire
                lea     si,tex1
                call    print

                mov     al,0fh
                mov     cx,78
                mov     di,6*160+3
st14:           stosb
                inc     di
                loop    st14

              ; mov     cx,78
              ; mov     di,19*160+3
st16:         ; stosb
              ; inc     di
              ; loop    st16

                mov     cx,78
                mov     di,16*160+3
st17:           stosb
                inc     di
                loop    st17

                mov     cx,78
                mov     di,17*160+3
st18:           stosb
                inc     di
                loop    st18

                mov     cx,78
                mov     di,18*160+3
st19:           stosb
                inc     di
                loop    st19

                mov     al,03h
                mov     cx,78
                mov     di,8*160+3
st15:           stosb
                inc     di
                loop    st15

                mov     cx,78
                mov     di,9*160+3
st155:          stosb
                inc     di
                loop    st155

                mov     cx,78
                mov     di,10*160+3
st156:          stosb
                inc     di
                loop    st156

                xor     ah,ah
                mov     bx,musicdata
                xor     cx,cx
                call    player

                mov     cx,6000h        ;Timer for rastertime.
st20:           loop    st20

		cli
		mov	ax,0000h
		mov	es,ax

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
                out	40h,al
                nop
                nop
	        mov	al,42h
                out	40h,al
                sti
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
                mov     [newvol],0      ;Added to the driver...
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
                cmp     bl,[es:max]
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

		mov	ax,0003h
		int	10h
quit:
                mov     ah,1
                call    player

                mov     ax,0c00h
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
include         \work\lib\raster.lib
;-------------------------------------------------------------------------------
                end     startdriver
