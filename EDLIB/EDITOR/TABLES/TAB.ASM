ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³;Table-Routines for EdLib ...... (C) Copyright 1992, 1993 Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³;Controls the internal tables of a player, using a parameter block specifying ³
³;the size, position and structure in a very flexible way.                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³;Revision 005, 12/1993.                                                       ³
³;                                                                             ³
³;  13/12-1993: Enhanced with name block support, new variables added to make ³
³;   sure it's flexible enough - size of each name, color of names, column to  ³
³;   appear - and finally offset in segment. The size is of course indirectly  ³
³;   determined by the size of the hex block. Lower case letters on first      ³
³;   position are converted to upper case, and all spaces are converted to a   ³
³;   userdefinable character.                                                  ³
³;                                                                             ³
³;  Made sure spaces and null bytes are treated equally.                      ³
³;                                                                             ³
³;  Implemented ENTER to edit a name string using the "InputNow" routine. It  ³
³;   simply ignores the key if 0ffffh was used in NameOffset.                  ³
³;                                                                             ³
³;  14/12-1993: Added NameInpColor to define colors when editing name.        ³
³;                                                                             ³
³;  Changed name "Table" into "TabDef" since newer TASM versions dislikes my  ³
³;   use of this particular name. :(                                           ³
³;                                                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ




ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT         Data    PUBLIC 'Data'

TabRow          db      0       ;Row where table is to appear.
TabCol          db      0       ;Column where table is to appear.
StepCol         db      0       ;Column where Step-counter is to appear.
StepFormat      dw      0       ;Format of actual step-counting (Add-value!).
StepMainCol     db      0       ;Color of Step-counter.
StepChar        db      0       ;Character to appear after the Step-counter.
StepCharCol     db      0       ;Color of StepChar.
StepSpace       db      0       ;How much further is this StepChar to appear.
TabLines        db      0       ;Max number of lines for the table on screen.
LineSize        db      0       ;Number of sequentially chosen bytes for a line.

NameSize        db      0       ;Number of letters for each name component.
NameCol         db      0       ;Column where names are to appear.
NameColor       db      0       ;Color of names.
NameInpColor    db      0       ;Color of name when editing it.
NameSubst       db      0       ;Substitute for space character in names.

SegOffset       dw      0       ;Offset in segment where table can be found.

TabSize         dw      0       ;Maximum size of entire table.

NameOffset      dw      0       ;Offset in segment where names can be found.
                                ;If this value = 0ffffh then names are NOT used.

LABEL Format    BYTE            ;TABLE: How to show the chosen bytes on screen.
                                ;       These values refers to screen positions,
                                ;       meaning that the next value should not
                                ;       be added with a number less than 2.
                                ;
                                ;       Add with 80h to display a line (0b3h)
                                ;       at the position.
                                ;
                                ;       End the table with 0ffffh.
                                ;
                                ;       Due to a bug I'm too lazy to fix, the
                                ;       last value MUST be a hex position. If
                                ;       you want a line at the last position,
                                ;       put it as the second last value. Also,
                                ;       the first position cannot be a line.

                db      96 dup (0)

LABEL HelpPtr   WORD            ;Pointer to help text for each byte position.

                dw      48 dup (0)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HexKeys         db      0bh,02h,03h,04h,05h,06h,07h,08h,09h,0ah
                db      1eh,30h,2eh,20h,12h,21h

LABEL Format2   BYTE            ;TABLE: Same as FORMAT, but put in increasing
                                ;       order, for the cursor-routines.

                db      48 dup (0)

LABEL Position  BYTE            ;TABLE: Same as FORMAT, just without screen pos.

                db      48 dup (0)

TabCurCol       db      0       ;Column of cursor on table.
TabCurRow       db      0       ;Row of cursor on table.
TabBytePos      dw      0       ;Position of cursor inside table.
Nibble2nd       db      0       ;Flag; Is the cursor on the 2nd nibble.
TabPos          dw      0       ;Position of table on screen.
TabTemp         dw      0       ;Backup of the TABPOS variable.
MaxLines        dw      0       ;Maximum number of lines according to TABSIZE.
MaxCount        dw      0       ;Counter used when scrolling lines.
TabLines2       db      0       ;Actually TABLINES used in the program.
DataPos         dw      0       ;Pointer used when scrolling the entire table.
TabStep         dw      0       ;Step-counter value for left-most row.
StepPos         dw      0       ;Position for Step-counter on screen.
StepTemp        dw      0       ;Backup of the STEPPOS variable.
NamePos         dw      0       ;Current position of name line internally.
NameScrPos      dw      0       ;Position of name on screen.
ScrollPos       dw      0       ;Name positions used when scrolling.

TabLength = $-TabCurCol

TabSeg          dw      0       ;Segment where table is to be found.

TabWord1        dw      0       ;Temporary word storage.

TableString     db      64 dup (0)

ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT         Code    PUBLIC 'Code'

                JUMPS
TabDef:
                mov     [TabSeg],es
                mov     al,[byte bx]            ;Transfer table informations.
                mov     [TabRow],al
                mov     al,[byte bx+1]
                mov     [TabCol],al
                mov     al,[byte bx+2]
                mov     [StepCol],al
                mov     ax,[word bx+3]
                mov     [StepFormat],ax
                mov     al,[byte bx+5]
                mov     [StepMainCol],al
                mov     al,[byte bx+6]
                mov     [StepChar],al
                mov     al,[byte bx+7]
                mov     [StepCharCol],al
                mov     al,[byte bx+8]
                mov     [StepSpace],al
                mov     al,[byte bx+9]
                mov     [TabLines],al
                mov     cl,[byte bx+10]
                mov     [LineSize],cl
                mov     al,[byte bx+11]
                mov     [NameSize],al
                mov     al,[byte bx+12]
                mov     [NameCol],al
                mov     al,[byte bx+13]
                mov     [NameColor],al
                mov     al,[byte bx+14]
                mov     [NameInpColor],al
                mov     al,[byte bx+15]
                mov     [NameSubst],al
                mov     ax,[word bx+16]
                mov     [SegOffset],ax
                mov     ax,[word bx+18]
                mov     [TabSize],ax
                mov     ax,[word bx+20]
                mov     [NameOffset],ax

                mov     cx,48                   ;Transfer FORMAT of table.
                add     bx,22
                mov     si,bx
                lea     di,[Format]
                push    ds
                pop     es
tbl10:          lodsw
                inc     bx
                inc     bx
                cmp     ax,0ffffh
                jz      tbl20
                stosw
                loop    tbl10
tbl20:
                mov     cx,48                   ;Transfer HELP text pointers.
                mov     si,bx
                lea     di,[HelpPtr]
                rep     movsw

                call    TabInit
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabAmnesia:                                     ;Store the cursor positions.
                push    ax cx si di es
                mov     ax,ds
                mov     es,ax

                mov     cx,TabLength
                lea     si,[TabCurCol]
                rep     movsb

                pop     es di si cx ax
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabCure:                                        ;Fetch the cursor positions.
                push    es
                mov     ax,ds
                mov     es,ax

                mov     cx,TabLength
                lea     di,[TabCurCol]
                rep     movsb

                mov     bx,[TabBytePos]         ;Make the HELP text right too.
                mov     al,[TabCol]
                add     al,[Format2+bx]
                add     al,[Nibble2nd]
                mov     [TabCurCol],al
                shl     bx,1
                mov     si,[HelpPtr+bx]
                call    Help

                pop     es
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FormToForm2:                                    ;Dummy sort Format into Format2.
                push    ds
                pop     es
                xor     bh,bh
                mov     bl,[LineSize]
                lea     di,[Format2]
ftf10:
                mov     cl,[LineSize]
                xor     ch,ch
                lea     si,[Format]
ftf20:
                lodsb
                inc     si
                test    al,80h                 ;Bypass line character.
                jne     ftf20
                cmp     al,bh
                jz      ftf40
                loop    ftf20
                inc     bh
                jmp     short ftf10
ftf40:
                stosb
                inc     bh
                dec     bl
                jne     ftf10
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FormToPosition:                                 ;Calculate Format into Position.
                xor     bx,bx
ftp10:
                lea     si,[Format]
                lea     di,[Position]
                mov     cl,[LineSize]
                xor     ch,ch
ftp20:
                lodsb
                inc     si
                test    al,80h                  ;Bypass line character.
                jne     ftp20
                cmp     al,bl                   ;Format value upwards.
                jne     ftp30
                mov     al,bh                   ;Position value upwards.
                stosb
                inc     bl
                inc     bh
                cmp     bh,[LineSize]
                jz      ftp40
                jmp     short ftp10
ftp30:
                inc     di
                loop    ftp20
                inc     bl
                jmp     short ftp10
ftp40:
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabInit:
                call    FormToForm2

                mov     al,[TabRow]             ;Calculate screen position...
                mov     [TabCurRow],al
                xor     ah,ah
                mov     bl,160
                mul     bl
                push    ax
                mov     bl,[TabCol]
                mov     [TabCurCol],bl
                shl     bl,1
                xor     bh,bh
                add     ax,bx
                mov     [TabPos],ax
                mov     [TabTemp],ax

                pop     ax                      ; ...and for Step-counter too.
                mov     bl,[StepCol]
                shl     bl,1
                xor     bh,bh
                add     ax,bx
                mov     [StepPos],ax
                mov     [StepTemp],ax

                mov     [Nibble2nd],0
                mov     [TabBytePos],0
                mov     [DataPos],0
                mov     [MaxCount],0
                mov     [TabStep],0
                mov     [ScrollPos],0

                mov     si,[HelpPtr]
                call    Help

                mov     al,[TabLines]
                mov     [TabLines2],al

                mov     ax,[TabSize]
                xor     dx,dx
                mov     bl,[LineSize]
                xor     bh,bh
                div     bx
                mov     [MaxLines],ax           ;See if table is too small.
                cmp     ax,0ffh
                ja      ti20
                cmp     al,[TabLines2]
                ja      ti20
                mov     ax,[MaxLines]           ;If it is, shrink no. of lines.
                mov     [TabLines2],al
ti20:           ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabPlot:
                mov     ax,0b800h
                mov     es,ax

                mov     ax,[TabPos]
                mov     [TabTemp],ax
                mov     ax,[StepPos]
                mov     [StepTemp],ax

                mov     [NamePos],0
                mov     [NameScrPos],0

                xor     si,si
                mov     cl,[TabLines2]
                xor     ch,ch
                mov     bp,[TabStep]
tp22:
                push    cx

                xor     bx,bx
                mov     cl,[LineSize]
                mov     ch,bh
tp23:
                mov     di,[DataPos]
                add     di,si
                add     di,[SegOffset]
                push    es
                mov     es,[TabSeg]
                mov     al,[es:di]
                pop     es
                mov     di,[TabTemp]
                mov     dl,[Format+bx]

                test    dl,80h                  ;Test for line character.
                jz      tp25
                and     dl,7fh
                shl     dl,1
                xor     dh,dh
                add     di,dx
                mov     al,0b3h
                stosb
                inc     bx
                mov     al,[Format+bx]          ;Line color.
                stosb
                inc     bx
                jmp     short tp23
tp25:
                shl     dl,1
                xor     dh,dh
                add     di,dx
                push    di
                call    HexByte
                pop     di
                inc     si
                inc     bx
                inc     di
                mov     al,[Format+bx]          ;Color of hex value.
                stosb
                inc     di
                stosb
                inc     bx
                loop    tp23

                pop     cx

                mov     di,[StepTemp]           ;Print the Step-counter.
                push    di
                mov     ax,bp
                push    ax
                mov     al,ah
                call    HexByte
                add     di,4
                pop     ax
                call    HexByte
                add     di,4                    ;Print the seperator.
                mov     al,[StepSpace]
                shl     al,1
                xor     ah,ah
                add     di,ax
                mov     al,[StepChar]
                mov     ah,[StepCharCol]
                stosw

                pop     di                      ;Color the Step-counter.
                mov     al,[StepMainCol]
                inc     di
                stosb
                inc     di
                stosb
                inc     di
                stosb
                inc     di
                stosb

                call    TableNames

                add     [TabTemp],160
                add     [StepTemp],160
                add     [NameScrPos],160
                add     bp,[StepFormat]
                loop    tp22
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TableNames:                                     ;Plot table names too.
                cmp     [NameOffset],0ffffh
                jne     tan10
                ret
tan10:
                push    si cx

                mov     si,[NamePos]            ;Get next name to print.
                add     si,[NameOffset]
                add     si,[ScrollPos]

                mov     cl,160                  ;Get position of name block.
                mov     al,[TabRow]
                mul     cl
                mov     cl,[NameCol]
                shl     cl,1
                xor     ch,ch
                add     ax,cx
                mov     di,ax
                add     di,[NameScrPos]

                mov     cl,[NameSize]
                xor     ch,ch
                add     [NamePos],cx
                mov     ah,[NameColor]

                mov     dl,[NameSubst]

                push    ds
                mov     ds,[TabSeg]

                lodsb                           ;Make first letter upper case.
                or      al,al
                jz      tan22
                cmp     al,20h
                jz      tan22
                cmp     al,61h
                jb      tan15
                cmp     al,7ah
                ja      tan15
                sub     al,20h
tan15:
                stosw
                dec     cx
                jcxz    tan30
tan20:
                lodsb
                or      al,al
                jz      tan22
                cmp     al,20h
                jne     tan25
tan22:
                mov     al,dl
tan25:          stosw
                loop    tan20
tan30:
                pop     ds cx si
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabEdit:
                push    es
te05:
                call    TabCursor
te10:
                call    Key
                cmp     ah,4dh                  ;Right
                jne     te20
                call    TabRight
                jmp     short te05

te20:           cmp     ah,4bh                  ;Left
                jne     te22
                call    TabLeft
                jmp     short te05

te22:           cmp     ah,50h                  ;Down
                jne     te23
                call    TabDown
                call    TabPlot
                jmp     short te05

te23:           cmp     ah,48h                  ;Up
                jne     te24
                call    TabUp
                call    TabPlot
                jmp     short te05
te24:
                cmp     ah,47h                  ;Home
                jne     te25
                call    TabHome
                jmp     short te05
te25:
                cmp     ah,4fh                  ;End
                jne     te26
                call    TabEnd
                jmp     short te05
te26:
                cmp     ah,84h                  ;Ctrl-PgUp
                jne     te27
                call    TabTop
                call    TabPlot
                jmp     short te05
te27:
                cmp     ah,76h                  ;Ctrl-PgDw
                jne     te275
                call    TabBottom
                call    TabPlot
                jmp     short te05
te275:
                cmp     ah,51h                  ;PgDw
                jne     te278
                call    TabPgDw
                call    TabPlot
                jmp     te05
te278:
                cmp     ah,49h                  ;PgUp
                jne     te28
                call    TabPgUp
                call    TabPlot
                jmp     te05
te28:
                cmp     ah,1ch                  ;Enter (Requires "InputNow")
                jne     te288
                call    TabInput
                call    TabPlot
                jmp     te05
te288:
                xor     bx,bx                   ;Hexadecimal
                mov     cx,16
te29:           cmp     ah,[HexKeys+bx]
                jz      te35
                inc     bx
                loop    te29

te30:           cmp     ah,01h                  ;Esc.
                jne     TabExit
                pop     es
                stc
                ret
te35:
                call    TabHex
                call    TabPlot
                call    TabRight
                jmp     te05
TabExit:
                pop     es
                clc
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabRight:
                cmp     [Nibble2nd],1
                jz      NextByte
                mov     [Nibble2nd],1
                inc     [TabCurCol]
                ret
NextByte:
                mov     al,[LineSize]
                dec     al
                xor     ah,ah
                cmp     ax,[TabBytePos]
                jz      nb90
                inc     [TabBytePos]
                mov     [Nibble2nd],0

                mov     bx,[TabBytePos]
                mov     al,[TabCol]
                add     al,[Format2+bx]
                mov     [TabCurCol],al
                shl     bx,1
                mov     si,[HelpPtr+bx]
                call    Help
nb90:
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabLeft:
                cmp     [Nibble2nd],0
                jz      PreviousByte
                mov     [Nibble2nd],0
                dec     [TabCurCol]
                ret
PreviousByte:
                cmp     [TabBytePos],0
                jz      pb90
                dec     [TabBytePos]
                mov     [Nibble2nd],1

                mov     bx,[TabBytePos]
                mov     al,[TabCol]
                add     al,[Format2+bx]
                inc     al
                mov     [TabCurCol],al
                shl     bx,1
                mov     si,[HelpPtr+bx]
                call    Help
pb90:
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabHome:
                mov     al,[TabCol]
                mov     [TabCurCol],al
                mov     [Nibble2nd],0
                mov     [TabBytePos],0
                mov     si,[HelpPtr]
                call    Help
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabTop:
                call    TabHome
                mov     [TabBytePos],0
                mov     [DataPos],0
                mov     [ScrollPos],0
                mov     [MaxCount],0
                mov     [TabStep],0
                mov     al,[TabRow]
                mov     [TabCurRow],al
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabBottom:
                call    TabHome
                mov     cx,0ffffh
tb20:           call    TabDown
                jc      tb22
                loop    tb20
tb22:
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabPgDw:
                mov     al,[TabCurRow]          ;Calc the way to current bottom.
                sub     al,[TabRow]
                mov     cl,[TabLines2]
                sub     cl,al
                dec     cl
                xor     ch,ch
                mov     [TabWord1],cx

                jcxz    tpd15                   ;Cursor down there...
tpd10:          call    TabDown
                loop    tpd10
tpd15:
                mov     cl,[TabLines2]          ; ...Scroll a PageDown...
                xor     ch,ch
tpd20:          call    TabDown
                jc      tpd80
                loop    tpd20

                mov     cx,[TabWord1]           ; ...And cursor back again.
                jcxz    tpd80
tpd40:          call    TabUp
                loop    tpd40
tpd80:
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabPgUp:
                mov     cl,[TabCurRow]          ;Calc the way to current top.
                sub     cl,[TabRow]
                xor     ch,ch
                mov     [TabWord1],cx

                jcxz    tpu15                   ;Cursor up there...
tpu10:          call    TabUp
                loop    tpu10
tpu15:
                mov     cl,[TabLines2]          ; ...Scroll a PageUp...
                xor     ch,ch
tpu20:          call    TabUp
                jc      tpu80
                loop    tpu20

                mov     cx,[TabWord1]           ; ...And cursor back again.
                jcxz    tpu80
tpu40:          call    TabDown
                loop    tpu40
tpu80:
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabEnd:
		mov	[Nibble2nd],1
		mov	bl,[LineSize]
		dec	bl
		xor	bh,bh
		mov	[TabBytePos],bx

                mov     al,[Format2+bx]
                add     al,[TabCol]
                inc     al
                mov     [TabCurCol],al

                shl     bx,1
                mov     si,[HelpPtr+bx]
                call    Help

                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabDown:
                mov     al,[TabCurRow]
                sub     al,[TabRow]
                inc     al
                cmp     al,[TabLines2]
                jz      td90

                inc     [TabCurRow]
                inc     [MaxCount]
                clc
                ret
td90:
                mov     ax,[MaxLines]
                dec     ax
                cmp     ax,[MaxCount]
                jz      td95
                mov     al,[NameSize]
                xor     ah,ah
                add     [ScrollPos],ax
                mov     al,[LineSize]
                add     [DataPos],ax
                inc     [MaxCount]
                mov     ax,[StepFormat]
                add     [TabStep],ax
                clc
                ret
td95:
                stc
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabUp:
                mov     al,[TabCurRow]
                sub     al,[TabRow]
                jz      tu90

                dec     [TabCurRow]
                dec     [MaxCount]
                clc
                ret
tu90:
                cmp     [DataPos],0
                jz      tu95
                mov     al,[NameSize]
                xor     ah,ah
                sub     [ScrollPos],ax
                mov     al,[LineSize]
                sub     [DataPos],ax
                dec     [MaxCount]
                mov     ax,[StepFormat]
                sub     [TabStep],ax
                clc
                ret
tu95:
                stc
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabHex:
                mov     cl,0f0h                 ;AND-mask.
                cmp     [Nibble2nd],1
                jz      th30
                shl     bl,1                    ;High nibble is manipulated.
                shl     bl,1
                shl     bl,1
                shl     bl,1
                mov     cl,0fh
th30:
                mov     si,[TabBytePos]
                xor     dh,dh
                mov     dl,[Position+si]

                mov     al,[TabCurRow]
                sub     al,[TabRow]
                mov     ch,[LineSize]
                mul     ch
                add     dx,ax
                mov     si,[SegOffset]
                add     si,[DataPos]
                add     si,dx

                push    es
                mov     es,[TabSeg]
                mov     al,[es:si]
                and     al,cl
                or      al,bl
                mov     [es:si],al
                pop     es
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabInput:                                       ;Input new name in block.
                cmp     [NameOffset],0ffffh
                jne     tai10
                ret
tai10:
                mov     si,[NameOffset]         ;Internal string position.
                add     si,[ScrollPos]

                mov     al,[TabCurRow]          ;Add with position on table.
                sub     al,[TabRow]
                mov     cl,[NameSize]
                mul     cl
                add     si,ax

                mov     cl,[NameSize]           ;Prepare string to be edited.
                xor     ch,ch
                lea     di,[TableString]
                push    cx si di ds ds
                pop     es
                mov     ds,[TabSeg]
                rep     movsb
                pop     ds

                mov     al,[NameCol]            ;Input new name.
                xor     ah,ah
                mov     di,ax
                mov     bl,[TabCurRow]
                mov     bh,ah
                mov     al,[NameSize]
                mov     dl,[NameInpColor]
                lea     bp,[TableString]
		call	InputNow

                pop     si di cx                ;Put back the edited result.
                push    es
                mov     es,[TabSeg]
                rep     movsb
                pop     es

                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabCursor:                                      ;Position cursor on table.
                mov     ah,02h
                mov     dh,[TabCurRow]
                mov     dl,[TabCurCol]
                xor     bh,bh
                int     10h
                ret
ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
