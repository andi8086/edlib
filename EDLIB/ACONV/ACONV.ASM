;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Editor AdLib source code generator v01.04 (C) Copyright Jens-Christian Huus ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³                                                                             ³
;³                                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaxInst         equ     64
MaxLP           equ     16
MaxVoices       equ     9
MaxSeqSize      equ     180h
;-------------------------------------------------------------------------------
General         equ     107

assume          ss:StackSeg,ds:Data,cs:Code

include         \lib\save64.lib
;-------------------------------------------------------------------------------
StackSeg        segment stack 'Stack'
                db      100h dup (?)
                ends
;-------------------------------------------------------------------------------
Data            segment public 'Data'

MusicTrk        db      'test\music.trk',0
MusicSeq        db      'test\music.seq',0
MusicDat        db      'test\music.dat',0

SaveName        db      'music.all',0

TrkSeg          dw      0,0
SeqSeg          dw      0,0
DatSeg          dw      0,0
NewData         dw      0,0
Psp             dw      0

TrackSize       dw      0
LabelTemp       dw      0
TrackTemp       dw      0
RepeatTrack	dw	0

NewPoi          dw      0
SeqPoi          dw      0
LineLen         db      0
MaxSeq          dw      0

Mode            db      0

StartUp         db      'Editor ADLIB source generator v01.04, by Jens-Christian Huus.',10,13,'$'

Hexv            db      '0123456789abcdef'

TpoinLabel      db      'Tpoin dw tk1,tk2,tk3,tk4,tk5,tk6,tk7,tk8,tk9',0
TpoinLab2       db      '      db ',0

InstrLabel      db      'Instrument db ',0
EndInstr        db      0ah,'           db 0,0,0,0,0                                         ;c0',0
EndIn2          db      0ah,0ah,'           db ',0
;LevelLabel      db      'LevelPuls       db      ',0
LevelLabel      db      'LevelPuls: ;<- NOT COMPILED - Please DO NOT use this table !',0
Level2          db      0ah,'                db      ',0
SeqPoiLabel     db      'SeqPointer dw ',0
SeqPoi2         db      '           dw ',0
FeedMe          db      0

T1Label         db      'tk1:',0
                db      'tk2:',0
                db      'tk3:',0
                db      'tk4:',0
                db      'tk5:',0
                db      'tk6:',0
                db      'tk7:',0
                db      'tk8:',0
                db      'tk9:',0

WorkingVoice    db      0,0,0,0,0,0,0,0,0

CutMacro        db      'cut ',0
RestMacro       db      'rest ',0
ContMacro       db      'cont ',0
SndMacro        db      'snd ',0
SeqEnd          db      'seqend',0
VibMacro        db      'vib ',0
LvlMacro        db      'lvl ',0
UpMacro         db      'up ',0
DownMacro       db      'down ',0
TwrapMacro      db      'twrap ',0
TstopMacro      db      'tstop',0

Voices          dw      MaxVoices
SeqSize         dw      MaxSeqSize
;-------------------------------------------------------------------------------
include         \lib\alloerr.lib
include         \lib\execerr.lib

                ends
;-------------------------------------------------------------------------------
Code            segment public 'Code'
                jumps

Set             macro
                mov     es,[NewData]
                endm

Reset           macro
                mov     ax,Data
                mov     ds,ax
                mov     ax,0b800h
                mov     es,ax
                endm
;-------------------------------------------------------------------------------
Start:          cld
                mov     ax,Data
                mov     ds,ax
                mov     [Psp],es

                mov     bx,4096/16
                call    SetBlock
                mov     bx,1000h
                call    Allocate
                mov     [TrkSeg],ax
                mov     bx,1000h
                call    Allocate
                mov     [SeqSeg],ax
                mov     bx,1000h
                call    Allocate
                mov     [DatSeg],ax
                mov     bx,1000h
                call    Allocate
                mov     [NewData],ax

                mov     ah,9
                lea     dx,StartUp
                int     21h

              ; push    ds
              ; pop     es
              ; mov     ds,[Psp]
              ; mov     si,82h                  ;Command tail handler.
              ; mov     di,offset LoadName
              ; mov     cl,[ds:80h]
              ; xor     ch,ch
              ; jcxz    EmptyName
              ; rep     movsb

              ; xor     al,al                   ;Remove the enter-sign.
              ; dec     di
              ; stosb

                mov     ax,Data
                mov     ds,ax

                call    FillNewData

                lea     dx,MusicTrk
                lea     bx,TrkSeg
                call    NoExec
                lea     dx,MusicSeq
                lea     bx,SeqSeg
                call    NoExec
                lea     dx,MusicDat
                lea     bx,DatSeg
                call    NoExec
;-------------------------------------------------------------------------------
                Reset

                call    CalcTrackSize
                call    InitNew

                lea     si,FeedMe
                call    NewLabel
                call    Line

                lea     si,T1Label              ;Do the tracks.
                mov     [LabelTemp],si
                mov     [TrackTemp],2
                mov     [MaxSeq],1
                mov     cx,[Voices]
TrackLoop:
                mov     [RepeatTrack],0
                push    cx
                mov     si,[LabelTemp]
                call    NewLabel
                mov     si,[TrackTemp]
                call    ConvertTrack
                pop     cx
                mov     ax,[TrackSize]
                add     [TrackTemp],ax
                add     [LabelTemp],5
                loop    TrackLoop

                call    Line
;-------------------------------------------------------------------------------
                call    Tpoin
                call    Line
;-------------------------------------------------------------------------------
                call    Instrument
                sub     [NewPoi],16     ;26
                call    Line
;-------------------------------------------------------------------------------
                call    LevelPuls
             ;  sub     [NewPoi],25    DON'T COMPILE the levelpuls table.
                call    Line
;-------------------------------------------------------------------------------
                call    SeqPointer
                call    Line
;-------------------------------------------------------------------------------
                mov     [SeqPoi],2              ;'2' to bypass SeqLen word.
                mov     cx,[MaxSeq]
                inc     cx
                xor     dx,dx
st800:
                push    cx dx
                call    SeqLabel
                call    ConvertSeq
                pop     dx cx
                mov     ax,[SeqSize]
                add     [SeqPoi],ax
                inc     dx
                loop    st800

                call    Line
;-------------------------------------------------------------------------------
SaveData:
                Reset

                xor     ax,ax                   ;Save the new data.
                mov     bx,[NewData]
                mov     cx,[NewPoi]
                lea     dx,SaveName
                call    Save64
              ; jc      Exit

              ; mov     ax,0003h
              ; int     10h
Exit:
                mov     ax,Data
                mov     ds,ax
                mov     es,[NewData]
                call    DeAllocate
                mov     es,[TrkSeg]
                call    DeAllocate
                mov     es,[SeqSeg]
                call    DeAllocate
                mov     es,[DatSeg]
                call    DeAllocate
                mov     ax,4c00h
                int     21h
;-------------------------------------------------------------------------------
SeqPointer      proc                            ;Make the seqpointer table.
                lea     si,SeqPoiLabel
                call    NewLabel
                mov     byte ptr [LineLen],0

                mov     cx,[MaxSeq]
                inc     cx
                mov     es,[NewData]
                xor     dx,dx
sp10:
                dec     [NewPoi]
                dec     di
sp20:
                mov     al,'s'
                stosb

                lea     bx,Hexv                 ;Print the sequence number.
                mov     ax,dx
                shr     al,1
                shr     al,1
                shr     al,1
                shr     al,1
                xlat
                stosb
                mov     ax,dx
                and     al,0fh
                xlat
                stosb

                mov     al,','
                stosb

                inc     byte ptr [LineLen]
                cmp     byte ptr [LineLen],14
                jne     sp30
                mov     byte ptr [LineLen],0

                dec     di
                push    es
                mov     [NewPoi],di
                lea     si,SeqPoi2
                call    NewLabel
                pop     es
                inc     dx
                loop    sp10
                jmp     short sp40
sp30:
                inc     dx
                loop    sp20
sp40:
                dec     di
                mov     al,0ah
                stosb
                Reset
                mov     [NewPoi],di
                mov     byte ptr [LineLen],0
                ret
                endp
;-------------------------------------------------------------------------------
LevelPuls       proc                            ;Make the levelpuls table.
                lea     si,LevelLabel
                call    NewLabel

                ret             ;DON'T COMPILE use the LevelPuls table at all !

                dec     [NewPoi]
                dec     di

                mov     cx,MaxLP
                mov     es,[DatSeg]
                mov     si,[es:General+(04h*2)]
                mov     es,[NewData]
lp22:
                push    cx
                mov     cx,4
                jmp     short lp24
lp23:
                mov     al,','
                stosb
lp24:
                push    ds
                mov     ds,[DatSeg]
                lodsb
                pop     ds
                mov     bp,1
                mov     ah,al
                push    cx
                call    Hexa
                pop     cx
                loop    lp23

                push    si
                lea     si,Level2
lp36:           lodsb
                cmp     al,0
                jz      lp38
                stosb
                jmp     short lp36
lp38:
                pop     si
                add     si,5
                pop     cx
                inc     dl
                loop    lp22

                jmp     Finish
                endp
;-------------------------------------------------------------------------------
Instrument      proc                            ;Make the instrument tables.
                lea     si,InstrLabel
                call    NewLabel
                dec     [NewPoi]
                dec     di

                mov     cx,MaxInst
                mov     es,[DatSeg]
                mov     si,[es:General+(02h*2)]
                mov     es,[NewData]
                xor     dl,dl
in22:
                push    cx
                mov     cx,11
                jmp     short in24
in23:
                mov     al,','
                stosb
in24:
                push    ds
                mov     ds,[DatSeg]
                lodsb
                pop     ds
                mov     bp,1
                mov     ah,al
                push    cx
                call    Hexa
                pop     cx
                loop    in23

                push    si
                lea     si,EndInstr
in36:           lodsb
                cmp     al,0
                jz      in38
                stosb
                jmp     short in36
in38:
                mov     [NewPoi],di
                mov     ah,dl
                mov     bp,1
                call    Hexa

                lea     si,EndIn2
in39:           lodsb
                cmp     al,0
                jz      in40
                stosb
                jmp     short in39
in40:
                pop     si
                add     si,5
                pop     cx
                inc     dl
                loop    in22

                jmp     short Finish
                endp
;-------------------------------------------------------------------------------
Tpoin           proc                            ;Make the Tpoin table.
                lea     si,TpoinLabel
                call    NewLabel

                mov     cx,[Voices]
                mov     es,[NewData]
                sub     di,36
tp20:
                mov     si,cx
                dec     si
                cmp     byte ptr [WorkingVoice+si],0
                jne     tp25
                add     di,4
                jmp     short tp30
tp25:
                mov     al,'0'
                stosb
                stosb
                mov     al,'h'
                stosb
                inc     di
tp30:           loop    tp20

                dec     [NewPoi]
                lea     si,TpoinLab2
                call    NewLabel

                dec     di
                mov     cx,[Voices]
                mov     es,[DatSeg]
                mov     si,[es:General]
                add     si,18
                mov     es,[NewData]
                jmp     short tp40
tp35:
                mov     al,','
                stosb
tp40:
                push    ds
                mov     ds,[DatSeg]
                lodsb
                pop     ds
                mov     bp,1
                mov     ah,al
                call    Hexa
                loop    tp35
Finish:
                mov     al,0ah
                stosb
                mov     [NewPoi],di
                mov     byte ptr [LineLen],0
                Reset
                ret
                endp
;-------------------------------------------------------------------------------
ConvertTrack    proc                            ;Convert Track into new format.
                mov     ds,[TrkSeg]
                mov     ax,Data
                mov     es,ax

                lodsw
                push    cx
                xor     bp,bp
                call    Feed
                call    EndFeed
                pop     cx
                push    si
                lodsw
                pop     si
                cmp     ax,0ffffh
                jne     ct100
                dec     cx
                mov     si,cx
                mov     byte ptr [es:WorkingVoice+si],1
                call    EndFeed
                lea     si,TstopMacro
                mov     ax,Data
                mov     ds,ax
                mov     es,[NewData]
              ; mov     cx,16                   ;Two TAB's in.
              ; mov     al,20h
              ; rep     stosb
                jmp     nl15
ct100:
                lodsw
                cmp     ax,0ffffh               ;Check for end of track table.
                jz      ct900

                test    ah,80h
                jz      ct500
                cmp     ax,[es:RepeatTrack]
                jz      ct100
                mov     [es:RepeatTrack],ax
                jmp     short ct600
ct500:
                cmp     ax,[es:MaxSeq]
                jb      ct600
                mov     [es:MaxSeq],ax
ct600:
                xor     bp,bp
                call    Feed
                jmp     short ct100
ct900:
                lodsw
                call    EndFeed
                lea     bx,[es:TwrapMacro]
                call    Command
                call    EndFeed
                Reset
                ret
                endp
;-------------------------------------------------------------------------------
; Values        Macro   Comments
;-------------------------------------------------------------------------------
; 6000h-6fffh   Cut x   Cut duration 000-fff
; 7000h-7fffh   Vib x   Vibrato - 7XYYh: X=Vibrato width, YY=Vibrato speed
; 9000h-903fh   Lvl x   Levels 00-3f
; c000h-cfffh   Snd x   Instrument 000-fff
; d000h-dfffh   Up x    Slide up 000-fff
; e000h-efffh   Down x  Slide down 000-fff
; ffffh         Seqend  End of sequence
;-------------------------------------------------------------------------------;
; XXYYh         d=DUR.  Duration, note, tienote and lock-function in one word:
;
; XX: 00h-1fh     --    Normal duration 00-1f
; XX: 20h-3fh     --    Duration 00-1f with tienote on
; YY: 00h/80h   Rest d  Rest (Release)
; YY: 01h-5fh   Cz x d  Notes (C#0 and up)
; YY: 7eh       Cont d  Hold (Continue)
; YY: 81h-dfh   Lc x d  Locked notes (Ignores track transpositions)
;-------------------------------------------------------------------------------
ConvertSeq      proc                            ;Convert seq into new format.
                mov     si,[SeqPoi]
                mov     ds,[SeqSeg]
                mov     ax,Data
                mov     es,ax
cs100:
                lodsw
                mov     dx,ax
                cmp     ax,0ffffh               ;End of Sequence.
                jz      cs900
                cmp     ax,0f000h               ;No operation word.
                jz      cs100

                and     ah,0f0h

                cmp     ah,60h                  ;Cut.
                jne     cs140
                call    CollectCut
                lea     bx,[es:CutMacro]
cs120:          push    dx es ds si bx
                call    EndFeed
                pop     bx si ds es dx
                mov     ax,dx
                and     ax,0fffh
                call    Command
                jmp     cs100
cs140:
                cmp     ah,70h                  ;Vibrato.
                jne     cs180
                lea     bx,[es:VibMacro]
                jmp     cs120
cs180:
                cmp     ah,90h                  ;Level.
                jne     cs200
                lea     bx,[es:LvlMacro]
                jmp     cs120
cs200:
                cmp     ah,0c0h                 ;New instrument.
                jne     cs220
                lea     bx,[es:SndMacro]
                jmp     cs120
cs220:
                cmp     ah,0d0h                 ;Slide up.
                jne     cs240
                lea     bx,[es:UpMacro]
                jmp     cs120
cs240:
                cmp     ah,0e0h                 ;Slide down.
                jne     cs260
                lea     bx,[es:DownMacro]
                jmp     cs120
cs260:
                cmp     al,00h                  ;Rest...
                jne     cs300
                call    CollectRest
                lea     bx,[es:RestMacro]
                jmp     cs120
cs300:
                cmp     al,7eh                  ;Cont...
                jne     cs400
                call    CollectCont
                lea     bx,[es:ContMacro]
         ;      xor     dx,dx                   ;Force to zero. HVORFOR DET ?!?!
                jmp     cs120
cs400:
                push    dx                      ;Print raw note as dword.
                call    CollectCont
                pop     ax
                add     ah,dl                   ;v01.04: Add note length.
                xor     bp,bp
                call    Feed
                jmp     cs100
cs900:
                call    EndFeed                 ;Do a "SeqEnd".
                lea     si,SeqEnd
                mov     ax,Data
                mov     ds,ax
                mov     es,[NewData]
              ; mov     cx,16                   ;Two TAB's in.
              ; mov     al,20h
              ; rep     stosb
                jmp     nl15
                endp
;-------------------------------------------------------------------------------
CollectRest     proc                            ;Check for repeated rests.
                xor     dx,dx
cr10:           lodsw
                cmp     ax,2000h
                jz      cr20
                cmp     ax,0000h
                jz      cr20
                cmp     ax,0f000h
                jz      cr10
                dec     si
                dec     si
                ret
cr20:
                inc     dx
                cmp     dx,1fh
                jne     cr10
                ret
                endp
;-------------------------------------------------------------------------------
CollectCont     proc                            ;Check for repeated conts.
                xor     dx,dx
cc10:           lodsw
                cmp     ax,207eh
                jz      cc20
                cmp     ax,007eh
                jz      cc20
                cmp     ax,0f000h
                jz      cc10
                dec     si
                dec     si
                ret
cc20:
                inc     dx
                cmp     dx,1fh
                jne     cc10
                ret
                endp
;-------------------------------------------------------------------------------
CollectCut      proc                            ;Check for repeated rests/conts.
                xor     dx,dx
                lodsw
                cmp     ax,207eh
                jz      cc10
                cmp     ax,007eh
                jz      cc10
                jmp     short cr10              ;Go for the REST type instead.
                endp
;-------------------------------------------------------------------------------
InitNew         proc                            ;Prepare NEWDATA for DW stuff.
                mov     [NewPoi],0
                mov     byte ptr [LineLen],0
                mov     byte ptr [Mode],0
                ret
                endp
;-------------------------------------------------------------------------------
NewLabel        proc                            ;Make a label in NEWDATA.
                mov     es,[NewData]
                mov     di,[NewPoi]
                mov     al,0ah                  ;Linefeed.
                stosb
nl15:           lodsb
                cmp     al,0
                jz      nl20
                stosb
                jmp     short nl15
nl20:
                mov     al,0ah                  ;Linefeed.
                stosb
                Reset
                mov     [NewPoi],di
                ret
                endp
;-------------------------------------------------------------------------------
SeqLabel        proc                            ;Print SEQ label with new no.
                mov     es,[NewData]
                mov     di,[NewPoi]
                mov     al,0ah                  ;LineFeed
                stosb
                mov     al,'s'
                stosb

                lea     bx,Hexv                 ;Print the sequence number.
                mov     ax,dx
                shr     al,1
                shr     al,1
                shr     al,1
                shr     al,1
                xlat
                stosb
                mov     ax,dx
                and     al,0fh
                xlat
                stosb

                mov     al,':'
                stosb
                jmp     short nl20
                endp
;-------------------------------------------------------------------------------
Command         proc                            ;Write a macro to NEWDATA.
                push    si ds es ax
                mov     ax,Data
                mov     ds,ax
                mov     es,[NewData]
                mov     di,[NewPoi]

              ; mov     cx,16                   ;Two TAB's in.
              ; mov     al,20h
              ; rep     stosb

                mov     si,bx

co16:           lodsb                           ;Print main macro.
                cmp     al,0
                jz      co20
                stosb
                jmp     short co16
co20:
                pop     ax
                xor     bp,bp
                call    Hexa
                push    ax
                jmp     fe580
                endp
;-------------------------------------------------------------------------------
Hexa            proc                            ;Print hexadecimal word.
                push    ax
                mov     al,ah
                shr     al,1
                shr     al,1
                shr     al,1
                shr     al,1
                cmp     al,0ah
                jb      he550
                push    ax
                mov     al,30h                  ;Insert a zero in some cases.
                stosb
                pop     ax
he550:
                lea     bx,Hexv
                xlat
                stosb                           ;Write 0x000h.
                pop     ax
                push    ax
                mov     al,ah
                and     al,0fh
                xlat
                stosb                           ;Write 00x00h.
                pop     ax
                cmp     bp,0
                jne     he560
                push    ax
                shr     al,1
                shr     al,1
                shr     al,1
                shr     al,1
                xlat
                stosb                           ;Write 000x0h.
                pop     ax
                and     al,0fh
                xlat
                stosb                           ;Write 0000xh.
he560:          mov     al,'h'
                stosb                           ;Write the "h" (as in "HEX").
                ret
                endp
;-------------------------------------------------------------------------------
Feed            proc                            ;Write DW words to NEWDATA.
                push    si ds es ax
                mov     ax,Data
                mov     ds,ax
                mov     es,[NewData]
                mov     di,[NewPoi]

                cmp     [LineLen],0
                jne     fe500

              ; mov     cx,16                   ;Two TAB's in...
              ; mov     al,20h
              ; rep     stosb
                mov     al,'d'                  ;...DW...
                stosb
                mov     al,'w'
                stosb
                mov     cx,1      ;6            ;...and another TAB.
                mov     al,20h
                rep     stosb
fe500:
                pop     ax
                call    Hexa
                push    ax

                cmp     byte ptr [Mode],0
                jne     fe560

                inc     [LineLen]
                cmp     bp,0
                jz      fe520
                cmp     [LineLen],11
                jne     fe600
                jmp     short fe560
fe520:          cmp     [LineLen],8             ;Check for end of line.
                jne     fe600
fe560:
                mov     byte ptr [LineLen],0
                mov     byte ptr [Mode],0
fe580:
                mov     al,0ah                  ;Linefeed.
                jmp     short fe800
fe600:
                mov     al,','                  ;Comma.
fe800:
                stosb
                mov     [NewPoi],di
                pop     ax es ds si
                ret
                endp
;-------------------------------------------------------------------------------
EndFeed         proc                            ;Avoid the last comma.
                push    es ds ax
                mov     ax,Data
                mov     ds,ax
                mov     es,[NewData]
                mov     di,[NewPoi]
                mov     al,0ah
                dec     di
                stosb
                mov     byte ptr [LineLen],0
                pop     ax ds es
                ret
                endp
;-------------------------------------------------------------------------------
Line            proc                            ;Do a line in the NEWDATA.
                mov     ax,Data
                mov     ds,ax
                mov     es,[NewData]
                mov     di,[NewPoi]
                mov     al,';'
                stosb
                mov     cx,79
                mov     al,'-'
                rep     stosb

                add     [NewPoi],80
                ret
                endp
;-------------------------------------------------------------------------------
FillNewData     proc                            ;Fill up segment with spaces.
                mov     es,[NewData]
                mov     ax,0a20h
                mov     cx,7000h
                xor     di,di
                rep     stosw
                ret
                endp
;-------------------------------------------------------------------------------
;EmptyName       proc                            ;The command tail was empty !?
;                mov     ax,Data
;                mov     ds,ax
;                mov     ah,9
;                lea     dx,NoName
;                int     21h
;                jmp     Exit
;                ret
;                endp
;-------------------------------------------------------------------------------
CalcTrackSize   proc
                mov     ax,0ffffh               ;Calc space for tracks chunks.
                xor     dx,dx
                div     [Voices]
                dec     ax
                mov     [TrackSize],ax
                ret
                endp
;-------------------------------------------------------------------------------
include         \lib\allocate.lib
include         \lib\deallo.lib
include         \lib\setblock.lib
include         \lib\noexec2.lib
;-------------------------------------------------------------------------------
                ends
                end     Start
