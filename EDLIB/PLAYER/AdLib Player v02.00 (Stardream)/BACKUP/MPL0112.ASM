;-------------------------------------------------------------------------------
; MUSIC PLAYER - AdLib player by JCH/Vibrants, version update JANUARY 1992.
;-------------------------------------------------------------------------------
; Remember version numbers in VERSION2 and CREDITS!
;-------------------------------------------------------------------------------
general         equ     3

cleararea       equ     carrier-inst    ;Area to clear in INIT routine.

public          player,version2,voicon,credits,stopvoice,sound

public          tempw,mvol,eseg,eoffset,levels,speed,spedr,trackpointer,inst
public          dur,durr,seqpoi,trackpoi,freq,gate,transp,slfreq,nog,shslfreq
public          shgate,shfreq,level2,level3,carrier,modulator,freqtab

public		shvib,vwid,vwidth,vspeed,feedcon,kslevel,adlevel,lon,lpdur
public		lppoi,lptabel,lpframe,lpfram2

musicplayer     segment public
assume          cs:musicplayer, ds:musicplayer
;-------------------------------------------------------------------------------
player:         jmp     function        ;Make sure this JMP is 3 bytes long.

version2        dw      0112h           ;Current player version.

voicon          db      0,0,0,0,0,0,0,0,0

credits         db      '  AdLib player v01.12 by JCH/Vibrants  '

main:           mov     es,[eseg]
                xor     bx,bx                   ;Voice no. for bytes
                xor     si,si                   ;Voice no. for words
m10:
                cmp     byte ptr [voicon+bx],1
		jz	m15
		jmp	next
m15:
                dec     [speed+bx]
		jge	m20
                mov     al,[spedr+bx]
                mov     [speed+bx],al           ;Overall speed
m20:
                cmp     byte ptr [speed+bx],0
		jne	m40
                dec     [dur+si]
		jge	m30
		jmp	setall
m30:		
		jmp	realtime
m40:
                cmp     byte ptr [speed+bx],1    ;Hard restart/Key-off
    		jne	m30
                cmp     [dur+si],0
                jne     m30
;-------------------------------------------------------------------------------
readtrack:
                mov     [tempw],0               ;Clear slfreq

                mov     bp,[trackpoi+si]
                add     bp,[trackpointer+si]
r05:
                mov     di,[es:bp]
                cmp     di,0fffeh               ;Stopmark
                jne	r06
                mov     byte ptr [voicon+bx],0
                mov     [freq+si],0
                mov     byte ptr [gate+bx],0
                mov     byte ptr [speed+bx],0
                mov     byte ptr [vspeed+bx],0
                jmp     setsound
r06:
                cmp     di,0ffffh               ;Wrapmark
		jne	r07
                mov     ax,[es:bp+2]            ;Loopvalue
		shl	ax,1
                mov     [trackpoi+si],ax
		jmp	short readtrack
r07:
                mov     dx,di                   ;Transpose
		and	dx,0f000h
		cmp	dx,8000h
		jne	readseq
		mov	dx,di
                and     dx,00ffh
                shl     dx,1
                mov     [transp+si],dx
                mov     dx,di
                and     dx,0f00h
		jz	r12
                neg     [transp+si]
                jmp	short r12
readseq:
		shl	di,1
                mov     bp,[eoffset]
                add     di,[es:general+(01h*2)+bp]
                add     di,bp
                mov     bp,[seqpoi+si]
                add     bp,[es:di]
                add     bp,[eoffset]
r10:		
                mov     ax,[es:bp]
                add     [seqpoi+si],2
		cmp	ax,0ffffh
		jne	r20
                mov     [seqpoi+si],0           ;End of sequence
r12:
                add     [trackpoi+si],2
		jmp	readtrack
r20:
		mov	di,ax
		and	ax,0f000h
                cmp     ax,0c000h               ;Instrument
		jne	r25
		and	di,0fffh
                mov     [inst+si],di
                jmp     short reread
r25:
                cmp     ax,9000h                ;New level
                jne     r27
		mov	ax,di
                and	al,003fh
        	mov	[level3+bx],al
                jmp     short reread
r27:
                cmp     ax,7000h                ;Vibrato
                jne     r30
                and     di,0fffh
                mov     [shvib+si],di
                jmp     short reread
r30:
                cmp     ax,0d000h               ;Slide up
		jne	r31
		and	di,0fffh
                mov     [shslfreq+si],di
		mov	[tempw],di
                jmp     short reread
r31:
                cmp     ax,0e000h               ;Slide down
		jne	r32
		and	di,0fffh
		neg	di
                mov     [shslfreq+si],di
		mov	[tempw],di
reread:
                inc     bp
                inc     bp
                jmp     r10
r32:
                cmp     ax,6000h                ;Cut command
                jne     durnote
                mov     [durr+si],di
                mov     byte ptr [gate+bx],0
                jmp     realtime
durnote:
                mov     dx,di                   ;Read duration
                mov     cl,8
                shr     di,cl
                and     di,001fh
                mov     [durr+si],di

                mov     di,dx
                and     di,007fh
                cmp     di,007eh                ;Hold (Continue)
                jz      r37
                cmp     di,0000h
                jne     r40

                mov     byte ptr [gate+bx],0    ;Rest
r37:
                mov     byte ptr [nog+bx],1
		jmp	realtime
r40:
                shl     di,1
                test    dh,00100000b            ;Tienote
                jz      r45
                mov     byte ptr [nog+bx],2
		jmp	short r50
r45:
                mov     byte ptr [nog+bx],0
                mov     byte ptr [gate+bx],0    ;Key-off anyway
r50:
                mov     byte ptr [shgate+bx],20h
                test    dl,10000000b            ;Check for locked note
                jne     r55
                add     di,[transp+si]
r55:
		mov	ax,[freqtab+di]
                mov     [shfreq+si],ax  ;Note
		mov	ax,[tempw]
                mov     [shslfreq+si],ax

                mov     byte ptr [vspeed+bx],0  ;Clear vibrato
r60:
		jmp 	realtime
;-------------------------------------------------------------------------------
setall:
                mov     ax,[durr+si]            ;Set duration
                and     ax,0fffh
                mov     [dur+si],ax
                xor     bp,bp
                cmp     [durr+si],6000h         ;Check for cut command
                jae     se05

                mov     ax,[shvib+si]
                cmp     ax,1000h                ;Tiable vibrato
                jz      se03

                mov     [vspeed+bx],al          ;Initialize vibrato
                mov     [vwidth+bx],ah
                shr     ah,1
                mov     [vwid+bx],ah
                mov     [shvib+si],1000h
se03:
                mov     ax,[shslfreq+si]
                mov     [slfreq+si],ax          ;Shadow regs/NOG handler
                cmp     byte ptr [nog+bx],1
		jz	r60
                mov     ax,[shfreq+si]
                mov     [freq+si],ax
                cmp     byte ptr [nog+bx],2
                jz      r60
                mov     al,[shgate+bx]
                mov     [gate+bx],al

              ; cmp     [shvib+si],0
              ; jz      se04
              ; mov     [shvib+si],0
              ; mov     byte ptr [vspeed+bx],0  ;Clear vibrato
se04:
                mov     bp,[inst+si]            ;Get instrument nr.
                mov     cl,4
                shl     bp,cl
se05:
                mov     di,[eoffset]
                add     bp,[es:general+(02h*2)+di]
                add     bp,di

                mov     al,[es:bp+7]            ;Modulator KSL/Level
		mov	[adlevel+bx],al

                mov     al,[es:bp+11]
		mov	[lon+bx],al
                cmp     al,0                    ;Check if levelpuls is wanted
		jz	se09
;-------------------------------------
                mov     al,[es:bp+12]           ;Frameskip timer
		mov	[lpfram2+bx],al

                mov     di,bp                   ;Initialize levelpuls
		add	di,8
                mov     [lppoi+si],di

                mov     byte ptr [lpdur+bx],0   ;Clear timers
                mov     byte ptr [lpframe+bx],0
;-------------------------------------
se09:
		mov	al,[carrier+bx]
		add	al,60h				
                mov     ah,[es:bp]
                call    sound                   ;Carrier Attack/Decay
		mov	al,[carrier+bx]
		add	al,80h
                mov     ah,[es:bp+1]
                call    sound                   ;Carrier Sustain/Release

                mov     al,[es:bp+2]            ;Carrier KSL/Level
		mov	[kslevel+bx],al

                mov	al,[carrier+bx]
		add	al,20h
                mov     ah,[es:bp+3]
                call    sound                   ;Carrier Am/Vib/EG/KSR/Multiple
		mov	al,[carrier+bx]
		add	al,0e0h
                mov     ah,[es:bp+4]
                call    sound                   ;Carrier Waveform

		mov	al,[modulator+bx]
		add	al,60h				
                mov     ah,[es:bp+5]
                call    sound                   ;Modulator Attack/Decay
		mov	al,[modulator+bx]
		add	al,80h
                mov     ah,[es:bp+6]
                call    sound                   ;Modulator Sustain/Release

                mov	al,[modulator+bx]
		add	al,20h
                mov     ah,[es:bp+8]
                call    sound                   ;Modulator Am/Vib/EG/KSR/Multiple
		mov	al,[modulator+bx]
		add	al,0e0h
                mov     ah,[es:bp+9]
                call    sound                   ;Modulator Waveform

                mov     al,[es:bp+10]
                mov     [feedcon+bx],al         ;Voice Feedback/Connection
;-------------------------------------------------------------------------------
realtime:

slide:
                mov     ax,[slfreq+si]
              ; cmp     ax,0
              ; jz      setsound
                add     [freq+si],ax
;-------------------------------------------------------------------------------
vibrato:
                xor     ah,ah
                mov     al,[vspeed+bx]
              ; cmp     al,0
              ; jz      levelhandler

                cmp     byte ptr [vwid+bx],0
                jl      v40

                add     [freq+si],ax
                dec     [vwid+bx]
                jg      levelhandler
                mov     al,[vwidth+bx]
                neg     al
                mov     [vwid+bx],al
                jmp     short levelhandler
v40:
                sub     [freq+si],ax
                inc     [vwid+bx]
                jne     levelhandler
                mov     al,[vwidth+bx]
                mov     [vwid+bx],al
;-------------------------------------------------------------------------------
levelhandler:
                mov     al,[level2+bx]
                add     al,[level3+bx]
		add	al,[mvol]
		cmp	al,3fh
		jle	le20
		mov	al,3fh
le20:           mov     [levels+bx],al
;-------------------------------------------------------------------------------
levelpulsate:
                cmp     byte ptr [lon+bx],0
		jz	setsound

                dec     [lpframe+bx]            ;Frameskipper
		jge	setsound
                mov     al,[lpfram2+bx]
                mov     [lpframe+bx],al

                mov     bp,[lppoi+si]

                cmp     byte ptr [lpdur+bx],0
		jne	lp30

                mov     al,[es:bp+3]            ;Get new pointer
		xor	ah,ah
                mov     bp,ax
                dec     bp
                shl     bp,1
                shl     bp,1
                add     bp,[lptabel]
                mov     [lppoi+si],bp

                mov     al,[es:bp+2]            ;Duration timer
		inc	al
                mov     [lpdur+bx],al

                cmp     byte ptr [es:bp],0ffh
		jz	lp30
                mov     al,[es:bp]              ;Level set
                mov     [adlevel+bx],al
lp30:
                dec     [lpdur+bx]

                mov     al,[adlevel+bx]
                add     al,[es:bp+1]
		and	al,3fh
                mov     [adlevel+bx],al
;-------------------------------------------------------------------------------
setsound:
                mov     al,[carrier+bx]
                add     al,40h
                mov     ah,[kslevel+bx]
                mov     dl,ah
                and     dl,11000000b            ;Mask out KSL
                and     ah,00111111b
                cmp     ah,[levels+bx]          ;Check/Choose the voice levels
                jg      se10            
                mov     ah,[levels+bx]
se10:           or      ah,dl
                call    sound                   ;Carrier KSL/Level

                mov     al,[modulator+bx]
                add     al,40h
                mov     ah,[adlevel+bx]
                test    byte ptr [feedcon+bx],1 ;Additive connection?
                jz      se16
                mov     dl,ah                   ;Yes, use the LEVEL variables
                and     dl,11000000b
                and     ah,00111111b
                cmp     ah,[levels+bx]          ;Check/Choose the voice levels
                jg      se15
                mov     ah,[levels+bx]
se15:           or      ah,dl
se16:           call    sound                   ;Modulator KSL/Level

                mov     al,bl
                add     al,0c0h
                mov     ah,[feedcon+bx]
                call    sound                   ;Voice Feedback/Connection

                mov     ax,[freq+si]
                mov     ah,al
                mov     al,bl
                add     al,0a0h
                call    sound                   ;Lo freq
                mov     ax,[freq+si]
                add     ah,[gate+bx]            ;Key-on
                mov     al,bl
                add     al,0b0h
                call    sound                   ;Key-on/Block/Hi freq
;-------------------------------------------------------------------------------
next:
                inc     si
                inc     si
                inc     bx
                cmp     bx,9
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

              ; mov     al,cl                   ;Fix ADSR.
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

                mov     al,cl                   ;Zero Am/Vib/EG/KSR/Multiple.
                add     al,20h
                call    sound
                mov     al,ch
                add     al,20h
                call    sound

                mov     ax,di                   ;Zero KEY-ON and FREQ.
                add     al,0a0h
                call    sound
                mov     ax,di
                add     al,0b0h
                call    sound

                mov     ax,di                   ;Zero FEEDBACK.
                add     al,0c0h
                endp
;-------------------------------------------------------------------------------
sound           proc
                mov     dx,388h
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
scan            proc                    ;Adlib card detection routine.
                cli
                mov     ax,6004h        ;Stop timers (You MUST include this too)
                call    sound
                mov     ax,8004h        ;Reset status register
                call    sound

                dec     dx              ;Remember the old value
                in      al,dx
                mov     bl,al

                mov     ax,0ff02h       ;Start timer 1
                call    sound
                mov     ax,2104h
                call    sound

                dec     dx
                mov     cx,200h         ;Wait for timer to move
sca20:          in      al,dx
                loop    sca20

                and     al,0e0h         ;Check it all out
                xor     al,0c0h
                jnz     nocard
                and     bl,0e0h
                jnz     nocard

                mov     ax,6004h        ;Stop timers
                call    sound
                clc
                jmp     short sca40
nocard:
                stc
sca40:          pop     es ds
                sti
                retf
                endp
;-------------------------------------------------------------------------------
volume          proc
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
		inc	di
		inc	di
                mov     [trackpointer+si],di

                mov     di,si
		shr	di,1
                mov     [spedr+di],al
                mov     al,[es:bx+di+18]
                and     al,3fh
                mov     [level2+di],al
                mov     [voicon+di],1

                mov     [seqpoi+si],0           ;Clear variables
                mov     [trackpoi+si],0

                cmp     byte ptr [es:bx+di+18],80h      
                jae     nu30                    ;Check for TIE-SFX flag

                mov     byte ptr [speed+di],0
                mov     [dur+si],0
                mov     [slfreq+si],0
                mov     byte ptr [level3+di],0

                call    stopvoice
nu30:
                inc     si
                inc     si
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
                xor     di,di
sw20:
                cmp     word ptr [es:bx+si],0
		jz	sw30
                cmp     byte ptr [voicon+di],1
                jz	swoff
                mov     byte ptr [voicon+di],1
		jmp	short sw30
swoff:
                mov     byte ptr [voicon+di],0
                call    stopvoice
sw30:
                inc     si
		inc	si
                inc     di
                cmp     di,9
		jne	sw20
                pop     es ds
                retf
                endp
;-------------------------------------------------------------------------------
init 		proc
                mov     [eseg],bx
                mov     [eoffset],cx

                mov     es,bx                   ;Set a pointer to LEVELPULS.
		mov	di,cx
		mov	si,[es:general+(04h*2)+di]
		add	si,cx
		mov	[lptabel],si
cl10:
                mov     byte ptr [mvol],0

                xor     di,di
cl30:
                call    stopvoice               ;Fix certain clearings.
                mov     [voicon+di],0
                inc     di
                cmp     di,9
                jne     cl30

                mov     cx,cleararea            ;Clear all other variables
                lea     di,inst
                mov     ax,cs
                mov     es,ax
                xor     al,al
                cld
                rep     stosb

		mov	al,01h		
                mov     ah,00100000b            ;Clear testbyte.
		call	sound
		mov	al,08h
                mov     ah,00000000b            ;CSM=0/SEL=0.
		call	sound
		mov	al,0bdh
                mov     ah,11000000b            ;All depths at max, no rhytm.
		call	sound
cl40:           pop     es ds
                retf
		endp
;-------------------------------------------------------------------------------
function        proc
                push    ds es cs
                pop     ds

                cmp     ah,6
                jg      cl40
                shl     ah,1
                mov     al,ah
                xor     ah,ah
                mov     si,ax
                jmp     jumptab[si]
                endp
;-------------------------------------------------------------------------------
jumptab         dw      init    ;00h MAIN RESET
                dw      cl10    ;01h RESET
                dw      number  ;02h START
                dw      main    ;03h PLAY
                dw      switch  ;04h TOGGLE
                dw      volume  ;05h MAINVOL
                dw      scan    ;06h SCAN
;-------------------------------------------------------------------------------
tempw           dw      0
mvol		db	0
eseg            dw      0       ;If you mess around in these variables then do
eoffset         dw      0       ;remember to adjust the CLEAR settings !!
lptabel         dw      0

inst		dw	0,0,0,0,0,0,0,0,0
dur             dw      0,0,0,0,0,0,0,0,0
durr            dw      0,0,0,0,0,0,0,0,0
seqpoi		dw	0,0,0,0,0,0,0,0,0
trackpoi	dw	0,0,0,0,0,0,0,0,0
trackpointer    dw      0,0,0,0,0,0,0,0,0
freq            dw      0,0,0,0,0,0,0,0,0
transp		dw	0,0,0,0,0,0,0,0,0
slfreq		dw	0,0,0,0,0,0,0,0,0

vwid            db      0,0,0,0,0,0,0,0,0
vwidth          db      0,0,0,0,0,0,0,0,0
vspeed          db      0,0,0,0,0,0,0,0,0

lppoi           dw      0,0,0,0,0,0,0,0,0
lpdur		db	0,0,0,0,0,0,0,0,0
lon		db	0,0,0,0,0,0,0,0,0
lpframe 	db	0,0,0,0,0,0,0,0,0
lpfram2 	db	0,0,0,0,0,0,0,0,0

shvib           dw      0,0,0,0,0,0,0,0,0
shslfreq	dw	0,0,0,0,0,0,0,0,0
shfreq          dw      0,0,0,0,0,0,0,0,0

gate            db      0,0,0,0,0,0,0,0,0
shgate          db      0,0,0,0,0,0,0,0,0
level2          db      0,0,0,0,0,0,0,0,0
level3		db	0,0,0,0,0,0,0,0,0
kslevel         db      0,0,0,0,0,0,0,0,0
adlevel         db      0,0,0,0,0,0,0,0,0
feedcon         db      0,0,0,0,0,0,0,0,0
levels          db      0,0,0,0,0,0,0,0,0
speed           db      0,0,0,0,0,0,0,0,0
spedr           db      0,0,0,0,0,0,0,0,0
nog             db      0,0,0,0,0,0,0,0,0

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
