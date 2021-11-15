;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³       EDITOR 9-voice ADLIB/driver, TEST driver for the EDITOR system.       ³
;³                                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

assume          ss:stackseg,ds:data,cs:code
;-------------------------------------------------------------------------------
stackseg        segment stack 'stack'
                db      100h dup (?)
                ends
;-------------------------------------------------------------------------------
data            segment 'data'

TestText        db      'Testing ADLIB interface program.',10,10,13
                db      'Press F1 to restart/play, ENTER to stop and ESC to exit.',10,13,24h

TrackName       db      'mtrack.bin',0
SeqName         db      'mseq.bin',0
InstrName       db      'minstr.bin',0
InterfaceName   db      'interfac.bin',0
PlayerName      db      'mplayer.bin',0

TrackSeg        dw      0,0
SeqSeg          dw      0,0
InstrSeg        dw      0,0
Interface       dw      0,0
Player          dw      0,0

include         \lib\alloerr.lib
include         \lib\execerr.lib
                ends
;-------------------------------------------------------------------------------
code            segment 'code'
                jumps

GoInterface     macro
                call    dword ptr [Interface-2]
                endm
;-------------------------------------------------------------------------------
Start:
                mov     ax,data
		mov	ds,ax

                mov     ax,3
                int     10h

                mov     bx,7000/16
                call    SetBlock

                mov     bx,12000/16
                call    Allocate
                mov     [TrackSeg],ax
                mov     bx,2024/16
                call    Allocate
                mov     [SeqSeg],ax
                mov     bx,2024/16
                call    Allocate
                mov     [InstrSeg],ax
                mov     bx,2024/16
                call    Allocate
                mov     [Interface],ax
                mov     bx,4200/16
                call    Allocate
                mov     [Player],ax

                lea     bx,[Interface]
                lea     dx,InterfaceName
                call    NoExec
                lea     bx,[InstrSeg]
                lea     dx,InstrName
                call    NoExec
                lea     bx,[SeqSeg]
                lea     dx,SeqName
                call    NoExec
                lea     bx,[TrackSeg]
                lea     dx,TrackName
                call    NoExec
                lea     bx,[Player]
                lea     dx,PlayerName
                call    NoExec

                mov     es,[Player]
                mov     bx,[InstrSeg]
                mov     cx,[TrackSeg]
                mov     dx,[SeqSeg]
                mov     bp,180
                mov     di,802
                xor     ah,ah
                GoInterface
                jc      Quit

                mov     ah,9
                lea     dx,TestText
                int     21h
Drive:
                mov     ah,1
                int     16h
                jz      Drive
                mov     ah,0
                int     16h
dr10:
                cmp     ah,3bh                  ;F1 to restart/play.
                jne     dr30
                mov     ah,1
                GoInterface
                jmp     short Drive
dr30:
                cmp     ah,1ch                  ;ENTER to stop.
                jne     dr50
                mov     ah,2
                GoInterface
                jmp     short Drive
dr50:
                cmp     ah,01h                  ;ESC to exit.
                jne     Drive

                mov     ah,2
                GoInterface
Quit:
                mov     es,[Player]
                call    DeAllocate
                mov     es,[Interface]
                call    DeAllocate
                mov     es,[InstrSeg]
                call    DeAllocate
                mov     es,[SeqSeg]
                call    DeAllocate
                mov     es,[TrackSeg]
                call    DeAllocate

                mov     ax,0c06h
                mov     dl,0ffh
		int	21h
		mov	ax,4c00h
		int	21h
;-------------------------------------------------------------------------------
include         \lib\setblock.lib
include         \lib\allocate.lib
include         \lib\deallo.lib
include         \lib\noexec2.lib
;-------------------------------------------------------------------------------
                ends
                end     Start
