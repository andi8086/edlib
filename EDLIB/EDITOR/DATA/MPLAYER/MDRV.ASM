旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커 comment ^
� Normal 9-voice ADLIB driver .............. Copyright (C) Jens-Christian Huus �
쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Programmer's driver for the normal 9-voice ADLIB system, especially used for �
� testing the editor version of the player, the QWERTY playing in particular.  �
쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� v01.00, 12/1993. Player version in "Version1".                               �
�                                                                              �
�                                                                              �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸 ^




include         globals.inc
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MusicPlayer     segment
                ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
TrackSeg        segment
                dw      0,20h,8000h,0,0fffeh
                ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SeqSeg          segment
                dw      0,0c000h,0118h,7504h,017eh,0f00h,0ffffh
                ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InstrSeg        segment

Detection       db      'JCH',26h,02h,66h       ;System detection bytes.
Kind            db      00h                     ;00h for music data block.
Version1        db      04h                     ;Major music-player version.
Timer           db      70                      ;Timerspeed for the block.
Max             db      1                       ;Number of music and effects.
Card            db      00h                     ;00h for normal Adlib.

BlockName       db      '                                '      ;32 bytes names.
Composer        db      '                                '

                db      32 dup (0)              ;For future expansion...

General         dw      Tpoin                   ;00h
                dw      Unused                  ;01h
                dw      Instrument              ;02h
                dw      Unused                  ;03h
                dw      SpFx                    ;04h    ;New!

                dw      0ffffh                  ;Endmark.

Unused          dw      0                       ;Dummy data.

Tpoin           dw      01h,00h,00h,00h,00h,00h,00h,00h,00h
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h

Instrument      db      0a6h,004h,00h,00100010b,0               ;Test sound.
                db      0ffh,003h,0eh,00000001b,2,02h
                db      0,0,0,0,0

                db      0a6h,005h,00h,00100100b,0
                db      073h,025h,0ch,00100010b,1,08h
                db      0,0,0,0,0

SpFx            dw      0001h
                db      00h,0ffh,00h,04h
                dw      0001h

                dw      0001h
                db      0ch,0ffh,00h,04h
                dw      0000h

                ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
assume          ss:Stacks,ds:Data,cs:Code

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Stacks          segment stack 'Stack'
                db      200h dup (?)
                ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Data            segment public 'Data'

Tex1            dw      2*160+8
                db      'Testing player modified for EdLib use...',0ffh
                dw      5*160+8
                db      'Press "1" to check that the player is alive.',0ffh
                dw      7*160+8
                db      'Use "QWERTYUIOP" to play - or use the MIDI keyboard.',0ffh
                dw      9*160+8
                db      'Press left mouse button at the same time to get vibrato.',0ffh
                dw      13*160+8
                db      'Press ESC to quit.',0feh

NoCard          dw      12*160+42
                db      'No ADLIB compatible soundcard present.',0feh

NoMPU           dw      12*160+38
                db      'No MPU-401 seems to be responding at all.',0feh

Hexv            db      '0123456789ABCDEF'

WhatNotes       db      18h,1ah,1ch,1dh,1fh,21h,23h,24h,26h,28h

Deci            db      6 dup (0)

OldAdr          dw      0
OldSeg          dw      0

KeyStatus       db      0

Request         db      0

KeyON           db      0
Toggle          db      0
DontPlay        db      0
TuneNr          dw      0
NewVol          db      0

DSR=080h
DRR=040h
ACK=0feh

DataPort        dw      0330h
ComPort         label   word
StatPort        dw      0331h

                ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Code            segment public 'Code'

                jumps

RunPlay:        push    ax bx cx dx di si
                mov     ax,Data
                mov     ds,ax
                cmp     [DontPlay],0
                jne     ru40
                mov     bl,7
                call    Raster
                mov     ah,3
                call    Player
                xor     bl,bl
                call    Raster
ru40:           pop     si di dx cx bx ax
		iret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
KeyRead:                                        ;Read keys.
                push    ax ds

                mov     ax,Data
                mov     ds,ax

                in      al,60h                  ;Direct IN 60h routine.
                mov     [KeyStatus],al

                pop     ds ax

                jmp     dword ptr [cs:Old09]    ;Do the normal INT 16h crap.

Old09           dd      0
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
StartDriver:    cld

                mov     ax,Data
                mov     ds,ax

                mov     [TuneNr],0
                mov     [NewVol],0
                mov     [DontPlay],0
                mov     [Toggle],0
                mov     [KeyON],0

                mov     ax,0003h
		int	10h

              ; mov     ax,1112h                ;80 x 50 chars mode.
              ; xor     bl,bl
              ; int     10h

                mov     ah,2                    ;Cursor gets the kick.
                mov     dx,5050h
                xor     bh,bh
		int	10h

                mov     ax,0b800h
                mov     es,ax

                call    Wire

                mov     ah,6                    ;Look for AdLib card!
                call    Player
                jnc     st05

                mov     al,1
                mov     di,12*160+43
                mov     cx,38
st04:           stosb
                inc     di
                loop    st04

                lea     si,NoCard               ;It wasn't found...
                call    Print
                xor     ah,ah
                int     16h
                jmp     Quit
st05:
                mov     bl,0ffh                 ;Initialize MPU-401.
                call    MPU_Command
                jc      st10
                mov     bl,03fh                 ;Switch into UART mode.
                call    MPU_Command
                jnc     st20
st10:
                lea     si,NoMPU                ;No MPU-401 responding...
                call    Print
                xor     ah,ah
                int     16h
                jmp     Quit
st20:
                lea     si,Tex1
                call    Print

                xor     ah,ah
                mov     bx,InstrSeg
                mov     cx,TrackSeg
                mov     dx,SeqSeg
                xor     bp,bp
                mov     di,bp
                call    Player

                call    Vertical

                mov     ax,InstrSeg             ;Get frames per second.
                mov     es,ax
                mov     al,byte ptr [es:8]
                xor     ah,ah
                call    CalcTimer

		cli
                xor     ax,ax
                mov     es,ax

		mov	ax,[es:1ch*4]
                mov     [OldAdr],ax
		mov	ax,[es:1ch*4+2]
                mov     [OldSeg],ax
                lea     ax,RunPlay
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

                call    BiosKeysOff
Driver:
                mov     al,[KeyStatus]
                xor     ah,ah
                mov     di,20*160+8
                call    HexWord

                NewVib=050ah

                mov     ax,0005h
                xor     bx,bx
                int     33h                     ;Left mouse button.
                xor     cl,cl
                test    ax,01h
                jz      dri32
                mov     cl,1                    ;Vibrato ON/OFF flag.
dri32:          mov     dx,NewVib               ;Vibrato value.
                mov     ch,01h                  ;Voice (0-8).
                mov     ah,0ah
                call    Player                  ;Enable vibrato.
dri35:
                mov     ah,5                    ;Set volumen.
                mov     bh,[NewVol]
                xor     bl,bl
                mov     cl,bl
                call    Player

                mov     [Request],0
                mov     ah,8                    ;Request, has NUMBER ended?
                mov     bx,[TuneNr]
                call    Player
                rcl     [Request],1

              ; mov     ah,[KeyStatus]

                mov     ah,11h
                int     16h
                jne     dri40
                call    Keyboard
                call    Midi
                jmp     Driver
dri40:
                mov     ah,10h
                int     16h
dri50:
                cmp     ah,39h                  ;SPACE.
                jne     dri51
                mov     ah,4
                mov     bx,[TuneNr]
                inc     [DontPlay]
                call    Player
                dec     [DontPlay]
                jmp     Driver
dri51:
                cmp     ah,50h                  ;DOWN key.
                jne     dri54
                cmp     [NewVol],3fh
                jz      Driver
                inc     [NewVol]
                jmp     Driver
dri54:
                cmp     ah,48h                  ;UP key.
                jne     dri57
                cmp     [NewVol],0
                jz      Driver
                dec     [NewVol]
                jmp     Driver
dri57:
                cmp     ah,1ch                  ;ENTER.
                jne     dri59
                mov     ah,1
                inc     [DontPlay]
                call    Player
                mov     [NewVol],0
                dec     [DontPlay]
                jmp     Driver
dri59:
                cmp     ah,02h
                jne     dri70                   ;Key "1".
                inc     [DontPlay]
                call    ResetSP
                mov     ah,2
                call    Player
                dec     [DontPlay]
                jmp     Driver
dri70:
                cmp     ah,01h ;ESC
                jne     Driver
dri90:
                cli
                xor     ax,ax
                mov     es,ax

                mov     ax,[OldAdr]             ;Restore INT 1Ch (Timer IRQ).
		mov	[es:1ch*4],ax
                mov     ax,[OldSeg]
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
                call    Player

                call    BiosKeysOn
Quit:
                mov     ax,0003h
                int     10h
                mov     ax,0c06h
                mov     dl,0ffh
		int	21h
		mov	ax,4c00h
		int	21h
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CalcTimer:                                      ;Calculate timer frequency.
                mov     bx,ax
                mov     dx,0012h
                mov     ax,34dch                ;The famous 1,193,180 value.
                div     bx
                mov     dx,ax
                mov     ax,bx
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Wire:
                xor     di,di
                mov     ah,08h                  ;Line text color.
                mov     bl,07h                  ;Middle text color.

                mov     al,218
		stosw				
                mov     al,196
		mov	cx,78
                rep     stosw
                mov     al,191
		stosw

                mov     dx,23
wi30:           mov     al,179
		stosw
		push	ax
		mov	ah,bl
                xor     al,al
		mov	cx,78
                rep     stosw
		pop	ax
                mov     al,179
		stosw
		dec	dx
		jne	wi30

                mov     al,192
		stosw
                mov     al,196
		mov	cx,78
                rep     stosw
                mov     al,217
		stosw

              ; mov     byte ptr [es:160+3],00h ;Black cursor.
		mov	[es:160+157],ah
		mov	[es:23*160+3],ah
		mov	[es:23*160+157],ah
		ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Print:
		mov	di,[si]
		inc	si
		inc	si
pr10:		lodsb
		cmp	al,0ffh
		jne	pr15
		inc	di
                jmp     short Print
pr15:		cmp	al,0feh
		jz	pr20
		stosb
		inc	di
		jmp	short pr10
pr20:		ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Clear:
                mov     di,1*160+2
                mov     al,0
cl10:           mov     cx,64
cl20:           stosb
                inc     di
                loop    cl20
                add     di,32
                cmp     di,24*160
                jb      cl10
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ResetSP:
                mov     cx,9
rs30:           xor     dx,dx
                mov     bx,dx
                mov     di,cx
                dec     di
                push    cx
                mov     ah,7
                call    Player
                pop     cx
                loop    rs30
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
WhatHex:
                push    ax
                mov     di,15*160+8
                xor     ah,ah
                call    HexWord
                pop     ax
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Keyboard:
                mov     ah,[KeyStatus]

                cli
                push    ax

                mov     bl,10h                  ;Keys "QWERTYUIOP".
kb62:           cmp     ah,bl
                jz      kb64
                inc     bl
                cmp     bl,1ah
                jne     kb62
                cmp     [KeyON],0
                jz      kb80
                jmp     kb70
kb64:
                push    ax
                mov     di,22*160+8
                xor     al,al
                xchg    al,ah
                call    HexWord
                pop     ax

                mov     bl,ah                   ;Calculate note.
                sub     bl,10h
                xor     bh,bh
                mov     bl,[WhatNotes+bx]

              ; mov     bl,18h                  ;Note to play (00h-5Fh).
                mov     bh,20h                  ;Bit 5=Key ON or OFF.
                mov     cl,08h                  ;Level (00-3Fh).
                mov     ch,00h                  ;Voice (0-8).
                mov     bp,8000h                ;Instrument to play.
                                                ;Bit 7=Use SpFx instead if ON.

                                                ;Set BH=00h if no key has been
                                                ;typed. This is necessary.
                mov     ah,9
                push    bx
                call    Player
                pop     bx

                add     bl,00h
                mov     cl,00h
                mov     ch,01h
                mov     bp,0001h
                mov     ah,9
                call    Player

                mov     [KeyON],1
                jmp     short kb80
Kb70:
                mov     bl,18h                  ;Note ignored when keying OFF.
                mov     bh,00h
                mov     cl,00h
                mov     ch,00h
                mov     bp,8000h
                mov     ah,9
                push    bx
                call    Player
                pop     bx

                mov     cl,00h
                mov     ch,01h
                mov     bp,0001h
                mov     ah,9
                call    Player

                mov     [KeyON],0
kb80:
                sti
                pop     ax
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
BiosKeysOn:
                mov     ax,2509h
                lds     dx,[cs:Old09]
                int     21h
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
BiosKeysOff:
                mov     ax,3509h
                int     21h
                mov     word ptr [cs:Old09],bx
                mov     word ptr [cs:Old09+2],es

                push    ds
                mov     ax,cs
                mov     ds,ax
                lea     dx,[KeyRead]
                mov     ax,2509h
                int     21h
                pop     ds
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
React:                                          ;Show sign of life...
                push    ax es
                mov     ax,0b800h
                mov     es,ax
                inc     word ptr [es:1*160+156]
                pop     es ax
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MPU_Read:                                       ;Read data from the MPU-401.
                push    cx dx

                mov     dx,[StatPort]
                mov     cx,800h
mp10:
                in      al,dx
                and     al,al                   ;Check to see if ready to read.
                jns     mp20
                loop    mp10
mp20:
                mov     dx,[DataPort]           ;Ready to read.
                in      al,dx

                pop     dx cx
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MPU_Command:                                    ;Send a command to the MPU-401.
                push    ax bx cx dx

                mov     dx,[DataPort]
                in      al,dx
                mov     dx,[StatPort]
mp30:
                in      al,dx
                and     al,DRR                  ;Wait for receive ready.
                jne     mp30

                mov     dx,[ComPort]
                mov     al,bl
                out     dx,al
                mov     dx,[StatPort]
                mov     cx,-1
mp40:
                in      al,dx                   ;Wait for data send ready.
                and     al,DSR
                jns     mp50
                loop    mp40
mp50:
                mov     dx,[DataPort]
                mov     cx,-1
mp60:           in      al,dx                   ;Wait for acknowledge.
                cmp     al,ACK
                jz      mp70
                loopne  mp60
                stc
                jmp     short mp80
mp70:           clc                             ;CF=0 if command accepted.

mp80:           pop     dx cx bx ax
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Midi:                                           ;Play from a MIDI keyboard.
                call    MPU_Read

                cmp     al,90h                  ;Key ON.
                jne     mi40

                call    MPU_Read                ;Note.
                mov     bl,al
                sub     bl,24h

                call    GetEmpty

                mov     [cs:WhichNote+si],bl

                call    MPU_Read                ;Velocity.
                neg     al
                shr     al,1
                mov     cl,al
                and     cl,3fh
                shr     cl,1                    ;Only 1fh.

              ; mov     bl,18h                  ;Note to play (00h-5Fh).
                mov     bh,20h                  ;Bit 5=Key ON or OFF.
              ; mov     cl,00h                  ;Level (00-3Fh).
                mov     ax,si
                mov     ch,al                   ;Voice (0-8).
                mov     bp,0001h                ;Instrument to play.
                                                ;Bit 7=Use SpFx instead if ON.
                mov     ah,9
                cli
                call    Player                  ;Player uses the SI register!
                sti

                inc     [cs:VoiceCount]
                cmp     [cs:VoiceCount],9
                jne     Midi
                mov     [cs:VoiceCount],0
                jmp     short Midi              ;Check for simultaneous keys.
Releasing:
                call    MPU_Read
mi40:
                cmp     al,80h                  ;Key OFF.
                jz      mi50

                cmp     al,0d0h                 ;Check for aftertouch.
                jz      mi45
                ret
mi45:
                call    MPU_Read                ;Vibrato ON or OFF?
                mov     cl,al

                xor     ch,ch
mi47:           mov     dx,NewVib               ;Vibrato value.
                mov     ah,0ah
                push    cx
                call    Player                  ;Enable vibrato.
                pop     cx
                inc     ch
                cmp     ch,9
                jne     mi47
                ret
mi50:
                call    MPU_Read                ;Note.
                mov     bl,al
                sub     bl,24h

                call    VoiceActive

                mov     ax,di
                call    WhatHex

                xor     bx,bx
                mov     cl,bl
                mov     bp,0001h
                mov     ah,9
                cli
                call    Player
                sti

                jmp     short Releasing         ;More keys going OFF?

VoiceCount      dw      0

WhichNote       db      0,0,0,0,0,0,0,0,0       ;Which note is played in voice.
                                                ;00h=No note played.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
VoiceActive:                                    ;Which voice belongs to note.
                xor     di,di
                mov     cx,di
va10:
                cmp     bl,[cs:WhichNote+di]
                jz      va20

                inc     di
                inc     ch
                cmp     di,9
                jne     va10
                xor     di,di
                ret                             ;If nothing, just forget it.
va20:
                mov     byte ptr [cs:WhichNote+di],0
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
GetEmpty:                                       ;Only take an empty voice.
                mov     si,[cs:VoiceCount]
                xor     ax,ax
ge20:
                cmp     byte ptr [cs:WhichNote+si],0
                jz      ge30
                inc     ax
                cmp     ax,9
                jne     ge25
                ret                             ;If nothing, just forget it.
ge25:
                inc     si
                cmp     si,9
                jne     ge20
                xor     si,si
                jmp     short ge20
ge30:
                mov     [cs:VoiceCount],si
                ret
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
include         \lib\hexword.lib
include         \lib\old\raster.lib
include         \lib\old\vertical.lib
include         \lib\decimal.lib
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
                ends
                end     StartDriver
