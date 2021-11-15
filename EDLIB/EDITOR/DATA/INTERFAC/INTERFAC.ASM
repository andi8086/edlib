ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ EdLib INTERFACE for ADLIB ..... (C) Copyright 1992, 1993 Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Interfaces the normal 9-voice ADLIB player with EdLib so that the editor can ³
³ communicate with the player. This makes the editor much more flexible, newer ³
³ players for other cards can be written with no fuss.                         ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Rev 04, 01/1994. <- This revision is new and unsaved, work with this.        ³
³                                                                              ³
³  Ideas: * When the editor has been programmed with a smart design for        ³
³           errors as well, with pop-up "Norton"-look-a-like windows, it       ³
³           would be a good idea to SEND the text-string containing the        ³
³           INIT-error (In this case, "No ADLIB card present") to the editor   ³
³           along with the CARRY in such a way, that the editor can print      ³
³           the error-string neatly on screen using it's own system.           ³
³                                                                              ³
³         * To the reader of this example INTERFACE program: It is more than   ³
³           recommended that (when altering the player for the EDITOR) you     ³
³           change the player into skipping track WRAP marks - IF called at    ³
³           position 0000h in the tracktable! Otherwise the editor (which is   ³
³           in fact your player!) might lock up.                               ³
³                                                                              ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                                                                              ³
³  26/9-1993: Added a function for turning rastertime ON or OFF.              ³
³                                                                              ³
³  29/9-1993: Shined up the code a bit.                                       ³
³                                                                              ³
³  29/9-1993: Added a function for adjusting the timer IRQ speed.             ³
³                                                                              ³
³  4/10-1993: Modified the FollowPlay system to cover the complicated speed   ³
³              system found in player v04.00.                                  ³
³                                                                              ³
³  9/10-1993: Added a tune clock system.                                      ³
³                                                                              ³
³  9/12-1993: Two new functions added (09h and 0ah) - for KEYBOARD PLAY and   ³
³              VIBRATO ON/OFF. These functions merely passes the registers on. ³
³                                                                              ³
³  9/12-1993: Had to remove the TIMER IRQ removal code from STOP. However,    ³
³              this made it necessary to add another function that disables    ³
³              it - to prevent the system to lock up of course.                ³
³                                                                              ³
³  22/1-1994: Added detection bypassing by setting bit 15 in the DI register  ³
³              of the INIT function. A little clumsy I know, but I didn't have ³
³              any registers left and I can't use the carry flag! :(           ³
³                                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

General         equ     107

assume          cs:Code, ds:Code
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Code            segment 'Code'

Function:       push    ds cs
                pop     ds

                cmp     ah,0bh          ;All INTERFACE programs should share the
                jg      fu20            ;same call functions !
                shl     ah,1
                mov     al,ah
                xor     ah,ah
                mov     si,ax
                jmp     JumpTab[si]
fu20:           pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
JumpTab         dw      Init    ;00h INITIALIZE ADLIB PLAYER SYSTEM.
                                ;
                                ;    ES = Segment where the player lies.
                                ;    BX = Segment with Instrument tabels.
                                ;    CX = Segment with Track tabels.
                                ;    DX = Segment with Sequence tabels.
                                ;    BP = Size of each Sequence tabel.
                                ;    DI = Size of each Track tabel.
                                ;         Bit15=ON = No detection wanted.
                                ;
                                ;    If CARRY=1 at return, exit the EDITOR fast.
                                ;
                dw      Play    ;01h PLAY ADLIB WITH TIMER INTERRUPT.
                dw      Stop    ;02h STOP BOTH ADLIB AND TIMER INTERRUPT.
                dw      Speed   ;03h SET NEW TUNE SPEED.
                                ;
                                ;    BX = New speed value.
                                ;
                dw      Follow  ;04h INFORM EDITOR ABOUT DECREASED SPEED TIMER.
                                ;
                                ;    RETURN: AX = Decreased FOLLOW timer.
                                ;
                                ;    If CARRY=1 at return, FOLLOW not available.
                                ;
                dw      Voice   ;05h TURN VOICE ON/OFF.
                                ;
                                ;    BX = Voice to be changed.
                                ;    DL = 1=ON, 0=OFF.
                                ;
                dw      SetSP   ;06h SET NEW STARTPOINT OFFSET FOR ONE VOICE.
                                ;
                                ;    BX = Byte-fine SEQUENCE offset.
                                ;    DX = TRACK offset, starting from 0000h.
                                ;    DI = Voice to be changed, starts from 0.
                                ;
                dw      RastTog ;07h TURN RASTERTIME ON/OFF.
                                ;
                                ;    DL = 1=ON, 0=OFF.
                                ;
                dw      IRQsp   ;08h SET NEW SPEED FOR THE TIMER IRQ.
                                ;
                                ;    BX = New timer IRQ speed value.
                                ;    CX = Nonzero = Don't tell ClockSpeed!
                                ;
                dw      Keyb    ;09h PLAY NOTE USING THE KEYBOARD.
                                ;
                                ;    BL = Note (00h-5fh). Ignored at gate off.
                                ;    BH = Gate ON/OFF (20h/00h).
                                ;    CL = Level (00h-3fh).
                                ;    CH = Voice (0-8).
                                ;    BP = Instrument - Bit 7=ON = SpFx value.
                                ;
                dw      Vibrato ;0Ah TOGGLE VIBRATO WHEN USING KEYBOARD PLAY.
                                ;
                                ;    CH = Voice (0-8).
                                ;    CL = Vibrato ON/OFF flag, Nonzero = ON.
                                ;    DX = Vibrato value.
                                ;
                dw      Exit    ;0Bh CLEAN UP WHEN QUITTING EDITOR.
                                ;
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NoCard          db      'No ADLIB compatible soundcard present.',10,13,24h

Player          dw      0,0
OldAdr          dw      0
OldSeg          dw      0
DontPlay        db      0
Dtct            db      0

RastAllow       db      0

PlayerSeg       dw      0
InstrSeg        dw      0
TrackSeg        dw      0
SeqSeg          dw      0
TrackSize       dw      0
SeqSize         dw      0

ScreenPos       dw      0

Clock           db      '00:00'

ClockSpeed      dw      0

TimerSpeed      dw      70
ClockReset      dw      70

FollowTimer     db      0
FollowTick      db      0
TuneSpeed       dw      0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RunPlay:        push    ax bx cx dx di si ds es bp cs
                pop     ds
                cmp     [DontPlay],0
                jz      ru10
                jmp     ru40
ru10:
                cmp     [RastAllow],0
                jz      ru20
                mov     bl,7
                call    Raster
ru20:           mov     ah,3
                call    dword ptr [Player]
                cmp     [RastAllow],0
                jz      ru25
                xor     bl,bl
                call    Raster
ru25:
                inc     [ClockSpeed]
                mov     ax,[ClockReset]
                cmp     [ClockSpeed],ax
                jne     ru30
                mov     [ClockSpeed],0

                inc     [Clock+4]               ;Update the tune clock.
                cmp     [Clock+4],3ah
                jne     ru28
                mov     [Clock+4],30h
                inc     [Clock+3]
                cmp     [Clock+3],36h
                jne     ru28
                mov     [Clock+3],30h
                inc     [Clock+1]
                cmp     [Clock+1],3ah
                jne     ru28
                mov     [Clock+1],30h
                inc     [Clock]
                cmp     [Clock],3ah
                jne     ru28
                mov     [Clock],30h
ru28:
                mov     ax,0b800h
                mov     es,ax
                mov     di,[ScreenPos]          ;Print the clock.
                lea     si,Clock
                mov     cx,5
                cld
ru29:           movsb
                inc     di
                loop    ru29
ru30:
                mov     [FollowTick],0
                mov     ax,[TuneSpeed]
                add     [FollowTimer],al
                jns     ru40
                and     [FollowTimer],7fh
                mov     [FollowTick],1

ru40:           pop     bp es ds si di dx cx bx ax
		iret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init:
                mov     ax,es
                mov     [Player+2],ax
                mov     [PlayerSeg],ax
                mov     [InstrSeg],bx
                mov     [TrackSeg],cx
                mov     [SeqSeg],dx
                mov     [SeqSize],bp
                mov     [Dtct],0
                test    di,8000h
                jz      in02
                not     [Dtct]
in02:           and     di,7fffh
                mov     [TrackSize],di

                mov     [ScreenPos],4*160+144

                push    bp cx dx bx di

                mov     [DontPlay],1

                cmp     [Dtct],0                ;Bypass detection.
                jne     in05

                mov     ah,6                    ;Look for AdLib card!
                call    dword ptr [Player]
                jnc     in05

                mov     ax,3
                int     10h
                mov     ah,9
                lea     dx,NoCard
                int     21h
                pop     di bx dx cx bp
                stc                             ;Tell EDITOR to quit!
                pop     ds
                retf
in05:
                pop     di bx dx cx bp          ;Initialize ADLIB player.
                xor     ah,ah
                call    dword ptr [Player]
                mov     [DontPlay],0

                xor     ax,ax
                mov     es,ax

                mov     ax,[es:1ch*4]           ;Remember old Timer IRQ.
                mov     [OldAdr],ax
                mov     ax,[es:1ch*4+2]
                mov     [OldSeg],ax

                clc                             ;INIT performed OK.
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Play:
                mov     ah,1                    ;Stop/Clear ADLIB player.
                inc     [DontPlay]
                call    dword ptr [Player]      ;This is needed to avoid the
                dec     [DontPlay]              ;trouble with VOICE flags.

                mov     bx,[TimerSpeed]
                mov     dx,0012h
                mov     ax,34dch                ;The famous 1,193,180 value.
                div     bx
                mov     dx,ax

                cli
                xor     ax,ax
                mov     es,ax

                lea     ax,RunPlay              ;Set up ADLIB for 70 times/Sec.
		mov	[es:1ch*4],ax
		mov	ax,cs
		mov	[es:1ch*4+2],ax
                mov     al,36h
                out	43h,al
                mov     al,dl
                out	40h,al
                nop
                nop
                mov     al,dh
                out	40h,al
                sti

                mov     [ClockSpeed],0          ;Reset the tune clock.

                mov     al,30h
                mov     [Clock],al
                mov     [Clock+1],al
                mov     [Clock+3],al
                mov     [Clock+4],al

                push    es

                mov     ax,0b800h
                mov     es,ax
                mov     di,[ScreenPos]          ;Print the clock.
                lea     si,Clock
                mov     cx,5
                cld
pl29:           movsb
                inc     di
                loop    pl29

                pop     es

                mov     ah,2
                inc     [DontPlay]
                mov     [FollowTick],0
                xor     bx,bx
                call    dword ptr [Player]      ;Call tune #0.
                dec     [DontPlay]

                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Stop:
                mov     ah,1                    ;Stop/Clear ADLIB player.
                inc     [DontPlay]
                call    dword ptr [Player]
                dec     [DontPlay]

              ; cli
              ; xor     ax,ax
              ; mov     es,ax
              ;
              ; mov     ax,[Oldadr]             ;Restore INT 1Ch (Timer IRQ).
              ; mov     [es:1ch*4],ax
              ; mov     ax,[Oldseg]
              ; mov     [es:1ch*4+2],ax
              ; mov     al,36h
              ; out     43h,al
              ; xor     al,al
              ; out     40h,al
              ; nop                             ;Disabled for "KEYB" to work.
              ; nop
              ; out     40h,al
              ; sti
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Speed:                                          ;Set new tune speed.
		mov	es,[TrackSeg]
                mov     [TuneSpeed],bx

		mov	cx,9
		mov	di,2
sp20:		mov	[es:di],bx
		add	di,[TrackSize]		;Put speed in start of tracks.
		loop	sp20
		pop	ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Follow:                                         ;Inform EDITOR about FOLLOW.
                cmp     [TuneSpeed],0
                jz      fo20
                mov     al,[FollowTick]
                clc                             ;Clear CARRY = FollowPlay OK.
                pop     ds
                retf
fo20:
                stc                             ;TuneSpeed = 0 won't work !!
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Voice:                                          ;Set the voice ON or OFF.
                mov     es,[InstrSeg]
                mov     di,[es:General]         ;General pos 00h = TPOIN.
                shl     bx,1
                xor     dh,dh
                mov     [es:di+bx],dx
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetSP:                                          ;Set a new StartPoint for voice.
                mov     ah,7
                inc     [DontPlay]
                call    dword ptr [Player]      ;Pass registers further on.
                dec     [DontPlay]
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RastTog:                                        ;Set rastertime ON or OFF.
                mov     [RastAllow],dl
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IRQsp:                                          ;Set new timer IRQ speed.
                mov     [TimerSpeed],bx

                or      cx,cx                   ;May the clock know?
                jne     ir21

                mov     [ClockReset],bx
ir21:
                push    ax dx

                mov     dx,0012h
                mov     ax,34dch                ;The famous 1,193,180 value.
                div     bx
                mov     dx,ax

                cli
                mov     al,36h                  ;Set new timer IRQ speed.
                out	43h,al
                mov     al,dl
                out	40h,al
                nop
                nop
                mov     al,dh
                out     40h,al
                sti

                pop     dx ax ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Keyb:                                           ;Keyboard play a note.
                mov     ah,9
                inc     [DontPlay]
                call    dword ptr [Player]
                dec     [DontPlay]
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Vibrato:                                        ;Do vibrato for keyboard play.
                mov     ah,0ah
                inc     [DontPlay]
                call    dword ptr [Player]
                dec     [DontPlay]
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Exit:                                           ;Clean up when exitting editor.
                cli
                xor     ax,ax
                mov     es,ax

                mov     ax,[Oldadr]             ;Restore INT 1Ch (Timer IRQ).
                mov     [es:1ch*4],ax
                mov     ax,[Oldseg]
                mov     [es:1ch*4+2],ax
                mov     al,36h
                out     43h,al
                xor     al,al
                out     40h,al
                nop
                nop
                out     40h,al
                sti
                pop     ds
                retf
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
include         \lib\old\raster.lib
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                ends
                end
