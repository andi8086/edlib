;-------------------------------------------------------------------------------
; MUSIC PLAYER - AdLib player by JCH/Vibrants, version update DECEMBER 1991.
;-------------------------------------------------------------------------------
; Remember version numbers in VERSION2 and CREDITS!
;-------------------------------------------------------------------------------
general         equ     3

cleararea       equ     carrier-levels  ;Area to clear in INIT routine.

public          player,version2,voicon,credits,stopvoice,sound

public          tempw,mvol,eseg,eoffset,levels,speed,spedr,trackpointer,inst
public          dur,durr,seqpoi,trackpoi,freq,gate,transp,slfreq,nog,shslfreq
public          shgate,shfreq,level2,level3,carrier,modulator,freqtab

public          shvib,vwid,vwidth,vspeed,feedcon,kslevel

musicplayer     segment public
assume          cs:musicplayer, ds:musicplayer
;-------------------------------------------------------------------------------
player:         jmp     function        ;Make sure this JMP is 3 bytes long.

version2        dw      0010h           ;Current player version.

voicon          dw      0,0,0,0,0,0,0,0,0

credits         db      '  AdLib player v00.10 by JCH/Vibrants  '

main:           mov     es,[eseg]
                xor     bx,bx           ;Voice no.
m10:
		cmp	[voicon+bx],1
		jz	m15
		jmp	next
m15:
                dec	[speed+bx]
		jge	m20
                mov     ax,[spedr+bx]	
		mov     [speed+bx],ax   ;Overall speed
m20:
		cmp	[speed+bx],0	
		jne	m40
		dec	[dur+bx]
		jge	m30
		jmp	setall
m30:		
		jmp	realtime
m40:
    		cmp	[speed+bx],1    ;Hard restart/Key-off
    		jne	m30
		cmp	[dur+bx],0
                jne     m30
;-------------------------------------------------------------------------------
readtrack:
		mov	[tempw],0	;Clear slfreq

		mov	si,[trackpoi+bx]
                add	si,[trackpointer+bx]
r05:
                mov     di,[es:si]
                cmp	di,0fffeh    	;Stopmark
                jne	r06
                mov	[voicon+bx],0	
                mov	[freq+bx],0
		mov	[gate+bx],0
		mov	[speed+bx],0
                mov     [vspeed+bx],0
                mov     di,bx
                shr     di,1
                jmp     setsound
r06:
		cmp	di,0ffffh	;Wrapmark
		jne	r07
                mov     ax,[es:si+2]    ;Loopvalue
		shl	ax,1
		mov	[trackpoi+bx],ax	
		jmp	short readtrack
r07:
		mov	dx,di         	;Transpose
		and	dx,0f000h
		cmp	dx,8000h
		jne	readseq
		mov	dx,di
		and	dx,0ffh
		shl	dx,1
		mov	[transp+bx],dx
		mov	dx,di
		and	dx,0f00h
		jz	r12
		neg	[transp+bx]
                jmp	short r12
readseq:
		shl	di,1
                mov     si,[eoffset]
                add     di,[es:general+(01h*2)+si]
                add     di,si
                mov     si,[seqpoi+bx]
                add     si,[es:di]
                add     si,[eoffset]
r10:		
                mov     ax,[es:si]
		add	[seqpoi+bx],2
		cmp	ax,0ffffh
		jne	r20
		mov	[seqpoi+bx],0	;End of sequence
r12:
		add	[trackpoi+bx],2
		jmp	readtrack
r20:
		mov	di,ax
		and	ax,0f000h
		cmp	ax,0c000h	;Instrument
		jne	r25
		and	di,0fffh
		mov	[inst+bx],di
                jmp     short r34
r25:
                cmp	ax,9000h	;New level
                jne     r27
		mov	ax,di
                and	al,003fh
                shr	bx,1
        	mov	[level3+bx],al
	        shl	bx,1
                jmp	short r34
r27:
                cmp     ax,7000h        ;Vibrato
                jne     r30
                and     di,0fffh
                mov     [shvib+bx],di
                jmp     short r34
r30:
		cmp	ax,0d000h	;Slide up
		jne	r31
		and	di,0fffh
		mov	[shslfreq+bx],di
		mov	[tempw],di
		jmp	short r34
r31:
		cmp	ax,0e000h	;Slide down
		jne	r32
		and	di,0fffh
		neg	di
		mov	[shslfreq+bx],di
		mov	[tempw],di
		jmp	short r34
r32:
                cmp     ax,6000h        ;Cut command
                jne     r33
                mov     [durr+bx],di
                mov     [gate+bx],0
                jmp     realtime
r33:
		cmp	ax,8000h	;New Duration
		jne	r35
		and	di,0fffh
		mov	[durr+bx],di
r34:
		inc	si
		inc	si
		jmp	r10		
r35:
		mov	cx,di		
		and	di,00ffh
		cmp	di,0080h	;Hold (Continue)
		jz	r37
		cmp	di,0000h
		jne	r40
		mov	[gate+bx],0     ;Rest
r37:
		mov	[nog+bx],1
		jmp	realtime
r40:
		shl	di,1
		and	ch,0fh		;Tienote
		cmp	ch,1h
		jne	r45
		mov	[nog+bx],2
		jmp	short r50
r45:
		mov	[nog+bx],0
		mov	[gate+bx],0	;Key-off anyway
r50:
		mov	[shgate+bx],2000h
		cmp	ch,02h		;Check for locked note
		jz	r55
		add	di,[transp+bx]
r55:
		mov	ax,[freqtab+di]
		mov	[shfreq+bx],ax	;Note
		mov	ax,[tempw]
		mov	[shslfreq+bx],ax

                mov     [vspeed+bx],0   ;Clear vibrato
r60:
		jmp 	realtime
;-------------------------------------------------------------------------------
setall:
		mov	ax,[durr+bx]	;Set duration
                and     ax,0fffh
                mov     [dur+bx],ax
                mov     si,0
                cmp     [durr+bx],6000h ;Check for cut command
                jae     se05

                mov     ax,[shvib+bx]
                cmp     ax,1000h        ;Tiable vibrato
                jz      se03

                mov     cx,ax           ;Initialize vibrato
                mov     cl,ch
                xor     ch,ch
                mov     [vwidth+bx],cx
                shr     cx,1
                mov     [vwid+bx],cx
                and     ax,0ffh
                mov     [vspeed+bx],ax
                mov     [shvib+bx],1000h
se03:
		mov	ax,[shslfreq+bx]
		mov	[slfreq+bx],ax	;Shadow regs/NOG handler
		cmp	[nog+bx],1
		jz	r60
                mov     ax,[shfreq+bx]
		mov	[freq+bx],ax
		cmp	[nog+bx],2	
                jz      r60
		mov	ax,[shgate+bx]
		mov	[gate+bx],ax

              ; cmp     [shvib+bx],0
              ; jz      se04
              ; mov     [shvib+bx],0
              ; mov     [vspeed+bx],0   ;Clear vibrato
se04:
		mov	si,[inst+bx]	;Get instrument nr.
                mov     cl,4
                shl	si,cl
se05:
                mov     di,[eoffset]
                add     si,[es:general+(02h*2)+di]
                add     si,di

		shr	bl,1		;Bytewise voice counter

		mov	al,[carrier+bx]
		add	al,60h				
                mov     ah,[es:si]
		call	sound     	;Carrier Attack/Decay
		mov	al,[carrier+bx]
		add	al,80h
                mov     ah,[es:si+1]
		call	sound		;Carrier Sustain/Release

                mov     ah,[es:si+2]    ;Carrier KSL/Level
                mov     [kslevel+bx],ah

                mov	al,[carrier+bx]
		add	al,20h
                mov     ah,[es:si+3]
		call	sound		;Carrier Am/Vib/EG/KSR/Multiple
		mov	al,[carrier+bx]
		add	al,0e0h
                mov     ah,[es:si+4]
		call	sound		;Carrier Waveform

		mov	al,[modulator+bx]
		add	al,60h				
                mov     ah,[es:si+5]
		call	sound     	;Modulator Attack/Decay
		mov	al,[modulator+bx]
		add	al,80h
                mov     ah,[es:si+6]
		call	sound		;Modulator Sustain/Release

		mov     al,[modulator+bx]
                add     al,40h
                mov     ah,[es:si+7]
              ; mov     dl,ah
              ; and     dl,11000000b
              ; and     ah,00111111b
              ; cmp     ah,[levels+bx]  ;Check/Choose the voice levels
              ; jg      se20
              ; mov     ah,[levels+bx]
se20:         ; or      ah,dl
		call    sound   	;Modulator KSL/Level

                mov	al,[modulator+bx]
		add	al,20h
                mov     ah,[es:si+8]
                call    sound           ;Modulator Am/Vib/EG/KSR/Multiple
		mov	al,[modulator+bx]
		add	al,0e0h
                mov     ah,[es:si+9]
		call	sound		;Modulator Waveform

                mov     ah,[es:si+10]
		shl	ah,1
                add     ah,[es:si+11]
                mov     [feedcon+bx],ah ;Voice Feedback/Connection

		shl	bl,1            ;Wordwise voice counter
;-------------------------------------------------------------------------------
realtime:

slide:
		mov	ax,[slfreq+bx]
              ; cmp     ax,0
              ; jz      setsound
		add	[freq+bx],ax
;-------------------------------------------------------------------------------
vibrato:
                mov     ax,[vspeed+bx]
              ; cmp     ax,0
              ; jz      levelhandler

                cmp     [vwid+bx],0
                jl      v40

                add     [freq+bx],ax
                dec     [vwid+bx]
                jg      levelhandler
                mov     ax,[vwidth+bx]
                neg     ax
                mov     [vwid+bx],ax
                jmp     short levelhandler
v40:
                sub     [freq+bx],ax
		inc	[vwid+bx]
                jne     levelhandler
		mov	ax,[vwidth+bx]
		mov	[vwid+bx],ax
;-------------------------------------------------------------------------------
levelhandler:
		mov	di,bx
		shr	di,1

		mov	al,[level2+di]
		add	al,[level3+di]
		add	al,[mvol]
		cmp	al,3fh
		jle	le20
		mov	al,3fh
le20:		mov	[levels+di],al
;-------------------------------------------------------------------------------
setsound:
                mov     al,[carrier+di]
                add     al,40h
                mov     ah,[kslevel+di]
                mov     dl,ah
                and     dl,11000000b
                and     ah,00111111b
                cmp     ah,[levels+di]  ;Check/Choose the voice levels
                jg      se10            
                mov     ah,[levels+di]
se10:           or      ah,dl
                call    sound           ;Carrier KSL/Level

                mov     ax,di
                add     al,0c0h
                mov     ah,[feedcon+di]
                call    sound           ;Voice Feedback/Connection

                mov     ax,[freq+bx]
                mov     ah,al
                mov     al,bl
                shr     al,1
                add     al,0a0h
                call    sound           ;Lo freq
                mov     ax,[freq+bx]
                add     ax,[gate+bx]    ;Key-on
                mov     al,bl
                shr     al,1
                add     al,0b0h
                call    sound           ;Key-on/Block/Hi freq
;-------------------------------------------------------------------------------
next:
     		inc	bx
     		inc	bx
		cmp	bx,18
		jz	n20
		jmp	m10
n20:
                pop     es ds
                retf
;-------------------------------------------------------------------------------







;-------------------------------------------------------------------------------
stopvoice       proc
                mov     cl,[carrier+di]
                mov     ch,[modulator+di]

              ; mov     ah,0ffh

              ; mov     al,cl           ;Fix ADSR.
              ; add     al,60h
              ; call    sound
              ; mov     al,cl
              ; add     al,80h
              ; call    sound
              ; mov     al,ch
              ; add     al,60h
              ; call    sound
              ; mov     al,ch
              ; add     al,80h
              ; call    sound

                xor     ah,ah

                mov     al,cl           ;Zero Am/Vib/EG/KSR/Multiple.
                add     al,20h
                call    sound
                mov     al,ch
                add     al,20h
                call    sound

                mov     ax,di           ;Zero KEY-ON and FREQ.
                add     al,0a0h
                call    sound
                mov     ax,di
                add     al,0b0h
                call    sound

                mov     ax,di           ;Zero FEEDBACK.
                add     al,0c0h
                endp
;-------------------------------------------------------------------------------
sound           proc
		mov	dx,388h
		out	dx,al
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                inc     dx
		mov	al,ah
		out	dx,al
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                ret
		endp
;-------------------------------------------------------------------------------
volume		proc
                and     bl,3fh
		mov	[mvol],bl
                pop     es ds
                retf
		endp
;-------------------------------------------------------------------------------
number		proc
                mov     es,[eseg]
		mov	cl,5
		shl	bx,cl
                mov     si,[eoffset]
                add     bx,[es:general+si]
                add     bx,si
        
                xor     si,si
nu20:
                cmp     word ptr [es:bx+si],0
		jz	nu30
                mov     di,[es:bx+si]
                add     di,[eoffset]
                mov     ax,[es:di]
		mov	[spedr+si],ax
		inc	di
		inc	di
		mov	[trackpointer+si],di

                mov	di,si
		shr	di,1
                mov     al,[es:bx+di+18]
                and     al,3fh
                mov     [level2+di],al
		mov     [voicon+si],1

                mov     [seqpoi+si],0   ;Clear variables
                mov     [trackpoi+si],0

                cmp     byte ptr [es:bx+di+18],80h   ;Check for TIE-SFX flag
                jae     nu30

                mov     [speed+si],0
                mov     [dur+si],0
		mov	[slfreq+si],0
		mov	[level3+di],0

                call    stopvoice
nu30:
		inc	si
		inc	si
                cmp     si,18
		jne	nu20
                pop     es ds
                retf
		endp
;-------------------------------------------------------------------------------
switch		proc
                mov     es,[eseg]
		mov	cl,5
		shl	bx,cl
                mov     si,[eoffset]
                add     bx,[es:general+si]
                add     bx,si

                xor     si,si
sw20:
                cmp     word ptr [es:bx+si],0
		jz	sw30
                cmp	[voicon+si],1
                jz	swoff
		mov	[voicon+si],1
		jmp	short sw30
swoff:
                mov     [voicon+si],0
                mov     di,si
                shr     di,1
                call    stopvoice
sw30:
		inc	si
		inc	si
		cmp	si,18
		jne	sw20
                pop     es ds
                retf
                endp
;-------------------------------------------------------------------------------
init 		proc
                mov     [eseg],bx
                mov     [eoffset],cx
cl10:
                mov     [mvol],0

                xor     di,di
cl30:
                call    stopvoice       ;Fix certain clearings.
                mov     si,di
                shl     si,1
                mov     [voicon+si],0   ;Clear all VOICON flags too.
                inc     di
                cmp     di,9
                jne     cl30

                mov     cx,cleararea    ;Clear all other variables
                lea     di,levels
                mov     ax,cs
                mov     es,ax
                xor     al,al
                cld
                rep     stosb

		mov	al,01h		
		mov	ah,00100000b	;Clear testbyte.
		call	sound
		mov	al,08h
                mov     ah,00000000b    ;CSM=0/SEL=0.
		call	sound
		mov	al,0bdh
		mov	ah,11000000b	;All depths at max, no rhytm mode.
		call	sound
                pop     es ds
                retf
		endp
;-------------------------------------------------------------------------------
function        proc
                push    ds es cs
                pop     ds

                cmp     ah,3
                jne     fu10
                jmp     main
fu10:           cmp     ah,0
                jz      init
                cmp     ah,1
                jz      cl10
                cmp     ah,2
                jne     fu20
                jmp     number
fu20:           cmp     ah,4
                jne     fu30
                jmp     switch
fu30:           cmp     ah,5
                jne     fu40
                jmp     volume
fu40:           ret
                endp
;-------------------------------------------------------------------------------
tempw           dw      0
mvol		db	0
eseg            dw      0
eoffset         dw      0

levels		db	0,0,0,0,0,0,0,0,0

speed		dw	0,0,0,0,0,0,0,0,0
spedr		dw	0,0,0,0,0,0,0,0,0

trackpointer	dw	0,0,0,0,0,0,0,0,0

inst		dw	0,0,0,0,0,0,0,0,0
dur             dw      0,0,0,0,0,0,0,0,0
durr            dw      0,0,0,0,0,0,0,0,0
seqpoi		dw	0,0,0,0,0,0,0,0,0
trackpoi	dw	0,0,0,0,0,0,0,0,0
freq		dw	0,0,0,0,0,0,0,0,0
gate            dw      0,0,0,0,0,0,0,0,0
transp		dw	0,0,0,0,0,0,0,0,0
slfreq		dw	0,0,0,0,0,0,0,0,0
nog		dw	0,0,0,0,0,0,0,0,0

vwid		dw	0,0,0,0,0,0,0,0,0
vwidth		dw	0,0,0,0,0,0,0,0,0
vspeed		dw	0,0,0,0,0,0,0,0,0

shvib           dw      0,0,0,0,0,0,0,0,0
shslfreq	dw	0,0,0,0,0,0,0,0,0
shgate		dw	0,0,0,0,0,0,0,0,0
shfreq		dw	0,0,0,0,0,0,0,0,0
level2		db	0,0,0,0,0,0,0,0,0
level3		db	0,0,0,0,0,0,0,0,0
kslevel         db      0,0,0,0,0,0,0,0,0
feedcon         db      0,0,0,0,0,0,0,0,0

carrier		db	03h,04h,05h,0bh,0ch,0dh,13h,14h,15h
modulator	db	00h,01h,02h,08h,09h,0ah,10h,11h,12h

freqtab		dw	343,363,385,408,432,458
		dw	485,514,544,577,611,647

		dw	343+0400h,363+0400h,385+0400h
		dw	408+0400h,432+0400h,458+0400h
		dw	485+0400h,514+0400h,544+0400h
		dw	577+0400h,611+0400h,647+0400h

		dw	343+0800h,363+0800h,385+0800h
		dw	408+0800h,432+0800h,458+0800h
		dw	485+0800h,514+0800h,544+0800h
		dw	577+0800h,611+0800h,647+0800h

		dw	343+0c00h,363+0c00h,385+0c00h
		dw	408+0c00h,432+0c00h,458+0c00h
		dw	485+0c00h,514+0c00h,544+0c00h
		dw	577+0c00h,611+0c00h,647+0c00h

		dw	343+1000h,363+1000h,385+1000h
		dw	408+1000h,432+1000h,458+1000h
		dw	485+1000h,514+1000h,544+1000h
		dw	577+1000h,611+1000h,647+1000h

		dw	343+1400h,363+1400h,385+1400h
		dw	408+1400h,432+1400h,458+1400h
		dw	485+1400h,514+1400h,544+1400h
		dw	577+1400h,611+1400h,647+1400h

		dw	343+1800h,363+1800h,385+1800h
		dw	408+1800h,432+1800h,458+1800h
		dw	485+1800h,514+1800h,544+1800h
		dw	577+1800h,611+1800h,647+1800h

		dw	343+1c00h,363+1c00h,385+1c00h
		dw	408+1c00h,432+1c00h,458+1c00h
		dw	485+1c00h,514+1c00h,544+1c00h
		dw	577+1c00h,611+1c00h,647+1c00h
;-------------------------------------------------------------------------------
                ends
                end
