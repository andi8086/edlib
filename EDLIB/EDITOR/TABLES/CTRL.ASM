ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³;Control-Program ............... (C) Copyright 1992, 1993 Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³;Merely tests the Table-Routines (TAB.ASM) to make sure it works before using ³
³;them with EdLib.                                                             ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³;Revision 005, 12/1993.                                                       ³
³;                                                                             ³
³;                                                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IDEAL

ASSUME          ss:Stacks,ds:Data,cs:Code

INCLUDE         "tab.asm"
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT         Stacks  STACK 'Stack'

                db      100h dup (?)
ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT         Data    PUBLIC 'Data'

TestData        db      20h dup (1,2,3,4,5,6,7,8)

TestNames       db      7 dup ('Jensjensjensjens','erikerikerikerik','    karlkarlkarl','Axelaxelaxelaxel')
                db      'poulPoulPoulPoul'
                db      'prutprut        '
                db      'babberlabpru',0,0,0,0
                db      '-!-!-!-! ! ! ! !'

Text            db      'Table-Routines, Control-Program.',10,10,13
                db      'EdLib (C) Copyright 1992, 1993 Jens-Christian Huus.'
                db      10,13,'$'

Hexv            db      '0123456789ABCDEF'

Eseg            dw      0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE         "\lib\old\alloerr.lib"
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LABEL Table1    BYTE

                db      5       ;Row where table is to appear.
                db      8       ;Column where table is to appear.
                db      1       ;Column where Step-counter is to appear.
                dw      8       ;Format of actual step-counting (Add-value!).
                db      6       ;Color of Step-counter.
                db      '-'     ;Character to appear after the Step-counter.
                db      8       ;Color of StepChar.
                db      1       ;How much further is this StepChar to appear.
                db      16      ;Max number of lines for the table on screen.
                db      8       ;Number of sequentially chosen bytes for a line.

                db      16      ;Number of letters for each name component.
                db      35      ;Column where names are to appear.
                db      3       ;Color of names.
                db      1bh     ;Color of name when editing it.
                db      250     ;Substitute for space character in names.

                dw      0100h   ;Offset in segment where table can be found.

                dw      0100h   ;Maximum size of entire table.

                dw      0200h   ;Offset in segment where names can be found.
                                ;If this value = 0ffffh then names are NOT used.

                                ;TABLE: How to show the chosen bytes on screen.
                                ;       These values refers to screen positions,
                                ;       meaning that the next value should not
                                ;       be added with a number less than 2.
                                ;
                                ;       Add with 80h to display a line (0b3h)
                                ;       at the position.
                                ;
                                ;       End the table with 0ffffh.

                db      0,7
                db      3,3
                db      6+80h,14
                db      8,7
                db      11,7
                db      14+80h,2
                db      18,8
                db      16,8
                db      23,7
                db      21,7
                dw      0ffffh

ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT         Code    PUBLIC 'Code'

                JUMPS
Start:
                mov     ax,Data
                mov     ds,ax

                mov     bx,6000/16
                call    SetBlock
                mov     bx,1000h
                call    Allocate
                mov     [Eseg],ax
                mov     es,ax

                lea     si,[TestData]           ;Move testdata into testsegment.
                mov     di,100h
                mov     cx,180h
                rep     movsw

                lea     si,[TestNames]
                mov     di,200h
                mov     cx,200h
                rep     movsw

                mov     ax,0003h
                int     10h

                mov     ah,11h                  ;80 x 50 chars mode.
                mov     al,12h
                mov     bl,00h
                int     10h

                mov     ah,01h                  ;Big fat cursor.
                mov     cx,000fh
                int     10h

                mov     ah,9
                lea     dx,[Text]
                int     21h

                push    es
                mov     es,[Eseg]
                lea     bx,[Table1]             ;Init and print the table.
                call    TabDef
                call    TabPlot
                pop     es
st20:
                call    TabEdit                 ;Edit the current table.
                jnc     st20

                mov     es,[Eseg]
                call    Deallocate

                mov     ax,0003h
                int     10h
                mov     ax,4c00h
                int     21h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Key:                                            ;Get a key.
                mov     ah,11h                  
                int     16h
                jz      Key                     ;Extended INT 16h routine (!).
                mov     ah,10h
                int     16h
                ret
Help:
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InputNow:                                       ;Input a string of text.
		mov	[cs:InpLen],ax
		mov	[cs:InColor],dl

		push	es
		mov	ax,0b800h
		mov	es,ax

		mov	[cs:InLine],bl
		mov	ax,di
		mov	[cs:InCol],al
		mov	[cs:InCol2],al

		mov	[cs:RawPos],0
inn10:
		mov	al,[cs:InLine]		;Calculate matrix position.
		mov	cl,160
		mul	cl
		mov	bl,[cs:InCol2]
		shl	bl,1
		xor	bh,bh
		add	ax,bx
		mov	di,ax

		push	bp
		mov	cx,[cs:InpLen]
inn20:		mov	al,[ds:bp]		;Print the string.
		mov	ah,[cs:InColor]
		stosw
		inc	bp
		loop	inn20
		pop	bp
inn30:
		call	Curs
inn32:
		call	Key

		cmp	ah,4bh			;Left.
		jne	inn40
		cmp	[cs:RawPos],0
		jz	inn32
		dec	[cs:RawPos]
		dec	[cs:InCol]
		jmp	short inn30
inn40:
		cmp	ah,4dh			;Right.
		jne	inn42
		call	InRight
		jmp	short inn30
inn42:
		cmp	ah,47h			;Home.
		jne	inn44
		mov	al,[cs:RawPos]
		sub	[cs:InCol],al
		mov	[cs:RawPos],0
		jmp	inn30
inn44:
		cmp	ah,4fh			;End.
		jne	inn46
		mov	al,[cs:RawPos]
		sub	[cs:InCol],al
		mov	ax,[cs:InpLen]
		dec	al
		add	[cs:InCol],al
		mov	[cs:RawPos],al
		xor	ah,ah
		mov	si,ax
inn45:		cmp	[cs:RawPos],0
		jz	inn30
		cmp	[byte ds:bp+si-1],20h
		ja	inn30
		dec	[cs:RawPos]
		dec	[cs:InCol]
		dec	si
		jmp	short inn45
inn46:
		cmp	ah,53h			;Delete.
		jne	inn54
		mov	cl,[cs:RawPos]
		xor	ch,ch
		mov	si,cx
inn48:		cmp	si,[cs:InpLen]
		jz	inn51
		mov	al,[ds:bp+si+1]
		mov	[ds:bp+si],al
		inc	si
		jmp	inn48
inn51:		mov	[byte ds:bp+si],20h
		jmp	inn10
inn54:
		cmp	ah,0eh			;Backspace.
		jne	inn60
		cmp	[cs:RawPos],0
		jz	inn32
		mov	cl,[cs:RawPos]
		xor	ch,ch
		mov	si,cx
		mov	al,[ds:bp+si]
		mov	[ds:bp+si-1],al
		dec	[cs:RawPos]
		dec	[cs:InCol]
		jmp	inn48
inn60:
		cmp	ah,01h			;Escape.
		jne	inn70
		mov	cx,[cs:InpLen]
		push	es
		mov	ax,ds
		mov	es,ax
		mov	di,bp
		mov	al,20h
		rep	stosb
		pop	es
		mov	al,[cs:RawPos]
		sub	[cs:InCol],al
		mov	[cs:RawPos],0
		jmp	inn10
inn70:
		cmp	ah,1ch			;Enter.
		jne	inn80
		call	NoCursor
		pop	es
		ret
inn80:
		mov	cl,[cs:RawPos]		;Just type something.
		xor	ch,ch
		mov	si,cx
		mov	[ds:bp+si],al
		call	InRight
		jmp	inn10

InColor 	db	0
InLine		db	0
InCol		db	0
InCol2		db	0
InpLen		dw	0
RawPos		db	0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InRight:
		mov	ax,[cs:InpLen]
		dec	al
		cmp	[cs:RawPos],al
		jz	inr10
		inc	[cs:RawPos]
		inc	[cs:InCol]
inr10:
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Curs:
		mov	ah,02h
		mov	dl,[cs:InCol]
		mov	dh,[cs:InLine]
		xor	bh,bh
		int	10h
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NoCursor:                                       ;Get rid of the cursor.
		mov	ah,2
		xor	bh,bh
		mov	dx,8080h
		int	10h
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE         "\lib\hexbyte.lib"
INCLUDE         "\lib\old\setblock.lib"
INCLUDE         "\lib\old\allocate.lib"
INCLUDE         "\lib\old\deallo.lib"

ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
END             Start
