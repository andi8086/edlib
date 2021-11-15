ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ if 0
³ Test AdLib player v04.00 ............................ by Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ This program demonstrates the use of my AdLib "MPLAYER.OBJ" v04.00. Assemble ³
³ this source using Borland Turbo Assembler v4.0 and Turbo Link v6.00. Use the ³
³ file "-" as a MakeFile for Borland Make utility.                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ endif

P386

IDEAL

INCLUDE         "GLOBALS.INC"

ASSUME          ss:Stacks,ds:Data,cs:Code

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ if 0
³ *** STACK ***                                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ endif

SEGMENT         Stacks  STACK 'Stack'

                db      100h dup (0)
ENDS

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ if 0
³ *** DATA ***                                                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ endif

SEGMENT         Data    PUBLIC 'Data'

FileHandle      dw      0

D00name         db      'str_wise.d00',0

D00segment      dw      0

Counter         dw      0

TestMsg         db      'AdLib Player v04.00 Test Program, by JCH/Vibrants.',0ah,0ah,0dh,24h

NoAdLib         db      'No OPL2 compatible FM soundchip found.',0ah,0dh,24h

DosMsg          db      'Dos reports error AX='
DosVal          db      '0000.',0ah,0dh,24h

Loading         db      'Loading D00 file...',24h
Playing         db      'Playing D00 file - press / for main volume and ESC to quit.',24h

Fading          db      0dh,'                                                             '
                db      0dh,'Fading...',24h
Stopped         db      0dh,'Stopped...',0ah,0dh,24h

GetBack         db      0dh,24h

Old1C           dd      0

TestMainVol     db      0

Hex             db      '0123456789ABCDEF'

ENDS

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ if 0
³ *** PROGRAM ***                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ endif

SEGMENT         Code    PUBLIC 'Code'

                JUMPS
                LOCALS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Start:
                cld

                mov     ax,Data
                mov     ds,ax

                push    es

                lea     dx,[TestMsg]            ;Print initial message.
                mov     ah,09h
                int     21h

                pop     es

                mov     bx,60000/16             ;SetBlock, reduce program size.
                mov     ah,4ah
                int     21h
                jc      DosError
                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                mov     ah,06h                  ;Look for an AdLib card.
                call    Player
                jnc     @@120

                lea     dx,[NoAdLib]
                mov     ah,09h
                int     21h

                jmp     Exit
                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@@120:          lea     dx,[Loading]            ;Loading D00 file.
                mov     ah,09h
                int     21h

                call    LoadIt

                pushf
                push    ax

                lea     dx,[GetBack]            ;Set cursor at start of line.
                mov     ah,09h
                int     21h

                pop     ax
                popf

                jc      DosError                ;Internal load/allocate error.
                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                xor     ah,ah                   ;Initialize player.
                mov     bx,[D00segment]
                xor     cx,cx
                mov     es,bx                   ;BX:CX = Location of D00 data.
                mov     di,cx
                call    Player

                mov     [TestMainVol],00h

                call    SetTimerIrq

                lea     dx,[Playing]
                mov     ah,09h
                int     21h

                mov     ah,02h                  ;Start tune #0000h.
                xor     bx,bx
                call    Player
                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@@150:          mov     ah,01h                  ;Wait for keypress.
                int     16h
                jz      @@150
                xor     ah,ah
                int     16h
@@159:
                cmp     ah,48h                  ;Key "" turns volume up.
                jne     @@160
                cmp     [TestMainVol],00h
                jz      @@150
                dec     [TestMainVol]
                jmp     short @@165
@@160:
                cmp     ah,50h                  ;Key "" turns volume down.
                jne     @@170
                cmp     [TestMainVol],3fh
                jz      @@150
                inc     [TestMainVol]
@@165:          mov     bh,[TestMainVol]
                mov     ah,05h                  ;Set main volume (00h-3Fh).
                xor     bl,bl
                mov     cl,bl
                call    Player
                jmp     @@150
@@170:
                cmp     ah,01h                  ;Key "ESC" quits.
                jne     @@150
                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                lea     dx,[Fading]
                mov     ah,09h
                int     21h

@@180:          cmp     [TestMainVol],3fh       ;Fade out the music.
                jz      @@200

                mov     [Counter],-1
@@185:
                cmp     [Counter],0             ;Wait for timer interrupt.
                jne     @@185

                inc     [TestMainVol]
                mov     bh,[TestMainVol]
                mov     ah,05h                  ;Set main volume (00h-3Fh).
                xor     bl,bl
                mov     cl,bl
                call    Player
                jmp     short @@180
                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@@200:          lea     dx,[Stopped]
                mov     ah,09h
                int     21h

                mov     ah,01h                  ;Stop the player.
                call    Player

                call    RestoreTimer
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Exit:
                mov     ax,4c00h
                int     21h

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ if 0
³ *** SUBROUTINES ***                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ endif

DosError:                                       ;Handle all DOS errors.
                lea     di,[DosVal]
                call    CalcHexWord

                lea     dx,[DosMsg]
                mov     ah,09h
                int     21h

                jmp     Exit
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CalcHexWord:                                    ;Prepare to calculate hex WORD.
                push    ax
                mov     al,ah
                call    CalcHexByte
                pop     ax
CalcHexByte:                                    ;Prepare to calculate hex BYTE.
                push    ax ds
                pop     es
                lea     bx,[Hex]
                shr     al,4
                xlat
                stosb
                pop     ax
                and     al,0fh
                xlat
                stosb
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LoadIt:                                         ;Allocate and load MOD for SB.
                lea     dx,[D00name]
		mov	ax,3d00h
		int	21h			;Open file.
                jnc     @@100
		ret
@@100:
                mov     [FileHandle],ax

		mov	bx,ax			;Lseek.
		xor	cx,cx
		mov	dx,cx
		mov	ax,4202h		;Go to end of file, find length.
		int	21h
                jnc     @@110
		ret
@@110:
                shrd    ax,dx,4                 ;Allocate for the D00 file.
		mov	bx,ax
		add	bx,10h
		mov	ah,48h
		int	21h
                jnc     @@120
		ret
@@120:
                mov     [D00segment],ax

                mov     bx,[FileHandle]         ;Lseek.
                xor     cx,cx
                mov     dx,cx
                mov     ax,4200h                ;Go to the start of file.
                int     21h
                jnc     @@130
                ret
@@130:
                mov     bx,[FileHandle]
                mov     cx,-1
                mov     ds,[D00segment]
                xor     dx,dx
@@135:
                mov     ah,3fh                  ;Read.
                int     21h
                jnc     @@142
                ret
@@142:
                mov     ax,Data
                mov     ds,ax

                mov     bx,[FileHandle]         ;Close file.
		mov	ah,3eh
		int	21h
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetTimerIRQ:                                    ;Setup the timer interrupt.
                cli

                mov     es,[D00segment]
                movzx   bx,[es:8]               ;Usually 70 times a second.

		mov	dx,0012h
		mov	ax,34dch		;The famous 1,193,180 value.
		div	bx
		mov	dx,ax

		mov	al,36h
		out	43h,al
		mov	al,dl
		out	40h,al
		nop
		nop
		mov	al,dh
		out	40h,al

                mov     ax,351ch                ;Backup and change IRQ pointer.
		int	21h
                mov     [word Old1C],bx
                mov     [word Old1C+2],es

		mov	ah,25h
                push    ds cs
                pop     ds
                lea     dx,[TimerIRQ]
                int     21h
                pop     ds

		sti
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RestoreTimer:                                   ;Restore timer interrupt.
                cli
                push    ds

                mov     al,36h                  ;Return to 18.2 times a second.
		out	43h,al
		xor	al,al
		out	40h,al
		nop
		nop
		out	40h,al

                mov     ax,251ch                ;Restore old IRQ pointer.
                lds     dx,[Old1C]
                int     21h

                pop     ds
                sti
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TimerIRQ:                                       ;Called from interrupt 1Ch.
		pushf
                pusha

                mov     ax,Data
                mov     ds,ax

                mov     bl,04h                  ;Turn outscan border red.
                call    Raster

                mov     ah,03h                  ;Update the player.
                call    Player

                xor     bl,bl                   ;Restore outscan back to black.
                call    Raster

                mov     [Counter],0             ;Used when fading music.

                popa
                popf
		iret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Raster:                                         ;Set the outscan color.
                push    ax dx

                mov     dx,3dah
                in      al,dx
                nop
                mov     dx,3c0h
                in      al,dx
                mov     al,31h
                nop
                out     dx,al
                mov     al,bl
                nop
                out     dx,al

                pop     dx ax
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENDS
END             Start
