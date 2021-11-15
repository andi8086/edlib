;----------------------------------------------------------------------------
; MUSIC DRIVER v01.00 - AdLib players up to v01.04 by JCH/Vibrants.
;----------------------------------------------------------------------------
                .model tiny
                .stack 200h

extrn           reset:far,start:far,player:far,toggle:far,mainvol:far,max:byte
extrn           voicon:word,tempw:word,mvol:byte,eseg:word,version2:word
extrn           eoffset:word,levels:byte,speed:word,spedr:word,trackpointer:word
extrn           inst:word,dur:word,durr:word,seqpoi:word,trackpoi:word,freq:word
extrn           gate:word,transp:word,slfreq:word,nog:word,shslfreq:word
extrn           shgate:word,shfreq:word,level2:byte,level3:byte

musicdata       segment
                ends
musicplayer     segment
                ends
;----------------------------------------------------------------------------
                .data
tex1            dw      1*160+4
                db      'AdLib player v'
tex111          db      '??.??'
                db      ' by JCH/Vibrants.',0ffh
                dw      3*160+4
                db      'Voicon....',0ffh
                dw      4*160+4
                db      'Levels....',0ffh
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
                dw      3*160+132
                db      'Tempw...',0ffh
                dw      4*160+132
                db      'Mvol....',0ffh
                dw      5*160+132
                db      'Eseg....',0ffh
                dw      6*160+132
                db      'Eoffset.',0feh

hexv            db      '0123456789ABCDEF'

keys            db      02h,03h,04h,05h,06h,07h,08h,09h,0ah,0bh ; Keys 1-0.
                db      1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h
                db      18h,19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch ; A-Z.

oldadr          dw      0
oldseg		dw	0
old09adr	dw	0
old09seg	dw	0

tunenr          dw      0
hold		db	0
eoffset2        dw      0000h   ;Test offset value for musicdata.
;----------------------------------------------------------------------------
                .code
                jumps

raster          macro   color           ;only VGA!
                mov     dx,3c0h
                in      al,dx
                mov     al,31h
                out     dx,al
                mov     al,color
                out     dx,al
                endm

runplay:        push    ax bx cx dx di si
                raster  7
                call    player
                raster  0
                pop     si di dx cx bx ax
		iret
nokey:
		mov	al,20h
		out	20h,al
                iret
;----------------------------------------------------------------------------
startdriver:    cld

                mov     ax,@data
		mov	ds,ax

                mov     [tunenr],0

		mov	ax,0003h
		int	10h

                mov     ah,2            ;Cursor in 1,1
		mov	dx,0101h
                sub     bh,bh
		int	10h

                mov     ax,musicplayer
                mov     es,ax

                mov     ax,[es:version2]
		push	ax
                and     al,0fh          ;Music-player version
		add	al,30h
		mov     [tex111+4],al
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
                lea     si,tex1
                call    print

                mov     bx,musicdata
                mov     cx,[eoffset2]
                call    reset
              ; mov     bx,0
              ; call    start

                mov     cx,0a00h        ;Timer for rastertime.
st20:		loop	st20

		cli
		mov	ax,0000h
		mov	es,ax

		mov	ax,[es:09h*4]	;Get lost, keyboard check.
		mov	[old09adr],ax
		mov	ax,[es:09h*4+2]
		mov	[old09seg],ax
		lea	ax,nokey
		mov	[es:09h*4],ax
		mov	ax,cs
		mov	[es:09h*4+2],ax

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
	        mov	al,42h
                out	40h,al
                sti
driver:
                mov     ax,musicplayer
		mov	es,ax

                sub     bx,bx
                sub     si,si
                mov     cx,3*160+24
dri30:
		mov	di,cx
                mov     ax,[es:voicon+bx]
                call    hexword
                add     di,160
                mov     al,[es:levels+si]
                sub     ah,ah
		call	hexword
                add     di,160
                mov     al,[es:level2+si]
                call    hexword
                add     di,160
                mov     al,[es:level3+si]
                call    hexword
		add	di,160
                mov     ax,[es:speed+bx]
		call	hexword
                add     di,160
                mov     ax,[es:spedr+bx]
                call    hexword
                add     di,160
                mov     ax,[es:dur+bx]
                call    hexword
                add     di,160
                mov     ax,[es:durr+bx]
		call	hexword
		add	di,160
                mov     ax,[es:inst+bx]
		call	hexword
                add     di,160
                mov     ax,[es:trackpointer+bx]
                call    hexword
                add     di,160
                mov     ax,[es:trackpoi+bx]
		call	hexword
		add	di,160
                mov     ax,[es:seqpoi+bx]
		call	hexword
		add	di,160
                mov     ax,[es:freq+bx]
		call	hexword
		add	di,160
                mov     ax,[es:shfreq+bx]
		call	hexword
		add	di,160
                mov     ax,[es:transp+bx]
		call	hexword
		add	di,160
                mov     ax,[es:slfreq+bx]
		call	hexword
                add     di,160
                mov     ax,[es:shslfreq+bx]
                call    hexword
                add     di,160
                mov     ax,[es:gate+bx]
                call    hexword
                add     di,160
                mov     ax,[es:shgate+bx]
                call    hexword
                add     di,160
                mov     ax,[es:nog+bx]
                call    hexword
		inc	si
		inc	bx
		inc	bx
		add	cx,12
		cmp	bx,18
                jne     dri30

                mov     di,3*160+148
                mov     ax,[es:tempw]
                call    hexword
                add     di,160
                mov     al,[es:mvol]
                sub     ah,ah
                call    hexword
                add     di,160
                mov     ax,[es:eseg]
                call    hexword
                add     di,160
                mov     ax,[es:eoffset]
                call    hexword
dri40:
                mov     ax,musicdata
                mov     es,ax

                in      al,60h
		cmp     al,0fh ;TAB
                jne     dri55
		cli
        	int	1ch
                sti
                jmp     driver
dri55:
		cmp	al,39h ;SPACE
                jne     dri59
		cmp	[hold],1
                jz      driver
		mov	[hold],1
                mov     bx,[tunenr]
                call    toggle
                jmp     driver
dri59:
                sub     bx,bx
dri592:		cmp	al,[keys+bx]
		jne	dri593 ;1-9
		cmp	[hold],1
		jz 	driver
		mov	[hold],1
                mov     [tunenr],bx
                call    start
                jmp     driver
dri593:		inc	bx
                mov     si,[eoffset2]
                cmp     bl,[es:max+si]
		jne	dri592
dri80:
                mov     [hold],0
		cmp	al,01h ;ESC
                jne     driver

                cli
		mov	ax,0000h
		mov	es,ax
	
		mov	ax,[old09adr]   ;Restore INT 09h (Keyboard check)
		mov	[es:09h*4],ax
		mov	ax,[old09seg]
		mov	[es:09h*4+2],ax

		mov	ax,[oldadr]	;Restore INT 1Ch (Timer irq)
		mov	[es:1ch*4],ax
		mov	ax,[oldseg]
		mov	[es:1ch*4+2],ax
                mov     al,36h
                out	43h,al
                sub     al,al
                out	40h,al
                nop
		nop
                out	40h,al
		sti

		mov	ax,0003h
		int	10h
quit:
                mov     bx,musicdata
                mov     cx,[eoffset2]
                call    reset

                mov     ax,0c00h
		int	21h
		mov	ax,4c00h
		int	21h
;----------------------------------------------------------------------------
hexbyte         proc 			;AX=value, DI=position
                push    es dx cx bx ax
                mov     bx,0b800h
                mov     es,bx
                sub     bh,bh
                and     al,0fh		
                mov     bl,al
                mov     dl,[hexv+bx]
                mov     [es:di+2],dl
                pop     ax
                push    ax
                and     al,0f0h
                mov     cl,4
                shr     al,cl
                mov     bl,al
                mov     dl,[hexv+bx]
                mov     [es:di],dl
                pop     ax bx cx dx es
		ret
	        endp
;------------------------
hexword         proc                    ;AX=value, DI=position
                push    es dx cx bx ax
                mov     bx,0b800h
                mov     es,bx
                sub     bh,bh
                and     al,0fh
                mov     bl,al
                mov     dl,[hexv+bx]
                mov     [es:di+6],dl
                pop     ax
                push    ax
                and     al,0f0h
                mov     cl,4
                shr     al,cl
                mov     bl,al
                mov     dl,[hexv+bx]
                mov     [es:di+4],dl
                and     ah,0fh
                mov     bl,ah
                mov     dl,[hexv+bx]
                mov     [es:di+2],dl
                pop     ax
                push    ax
                and     ah, 0f0h
                mov     cl,4
                shr     ah,cl
                mov     bl,ah
                mov     dl,[hexv+bx]
                mov     [es:di],dl
                pop     ax bx cx dx es
                ret
                endp
;------------------------
wire            proc
		sub	di,di
                mov     ah,08h ;Lne text
                mov     bh,04h ;Top text
                mov     bl,07h ;Mid text

                mov     al,218
		stosw				
                mov     al,196
		mov	cx,78
		rep stosw
                mov     al,191
		stosw

        ;	mov 	dx,2
wi20:
                mov     al,179
		stosw
		push	ax
		mov	ah,bh
                sub     al,al
		mov	cx,78
		rep stosw
		pop	ax
                mov     al,179
		stosw
	;	dec	dx
	;	jne	wi20

                mov     al,195
                stosw
		mov	al,196
		mov	cx,78
		rep stosw
                mov     al,180
		stosw

                mov     dx,21
wi30:
                mov     al,179
		stosw
		push	ax
		mov	ah,bl
                sub     al,al
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
;------------------------
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
;----------------------------------------------------------------------------
                end     startdriver




