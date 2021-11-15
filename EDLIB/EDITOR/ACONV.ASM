ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³;EdLib EDL-2-D00 converter ..... (C) Copyright 1992, 1993 Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³;Converts the file currently in EdLib to the compact D00 format needed by the ³
³;Play-Driver or the programmer of the game or demo.                           ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³;Revision 007, 11/1993. <- This revision is new and unsaved, work with this.  ³
³;                                                                             ³
³;                                                                             ³
³; 15/11-1993: Debugged the INSTR converter into altering the SpFX pointers   ³
³;  too, and to work with empty SpFX tabels.                                   ³
³;                                                                             ³
³; Debugged the SEQ converter part. The CUT command was replaced by REST or   ³
³;  CONT instead of a CUT (6000h) with duration.                               ³
³;                                                                             ³
³; At last the converter seems to be working. However, the wrapmark converter ³
³;  does not put any safe loop transpositions in this version. That will have  ³
³;  to wait until a later version.                                             ³
³;                                                                             ³
³; 21/11-1993: Adapted NextPass for the SubValue/Chk stuff.                   ³
³;                                                                             ³
³; Modified the data text for save filename input string.                     ³
³;                                                                             ³
³; 27/11-1993: Source modified GREATLY to work in IDEAL mode.                 ³
³;                                                                             ³
³;                                                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TpoinPos        =       6bh                     ;Default positions in v04.00.
SeqPoiPos       =       6dh
InstrPos        =       6fh
DataInfoPos     =       71h
SpecialPos      =       73h

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT         Data    PUBLIC 'Data'

ConvName        db      13 dup (0)

ConvSize        dw      0                       ;Size of the saved file.

ConvTxt1        db      22,29,0cfh,'Converting to D00 format',0
ConvTxt2        db      24,29,0c9h,'  Please type filename. ',0
ConvTxt3        db      26,29,0cfh,'     Name:              ',0
ConvTxt4        db      24,29,0c9h,'      Pass 0 of 9       ',0

ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT         Code    PUBLIC 'Code'

                JUMPS
Convert:
                cld

                mov     es,[cs:FindSeg]         ;Clear segment for ACONV usage.
                xor     di,di
                mov     cx,8000h
                rep     stosw

                mov     es,[InstrSeg]           ;Find 0FFFFh (end of pointers).
                xor     di,di
                mov     al,-1
                mov     cx,-1
con20:          repne   scasb
                scasb                           ;Is second byte also 0FFh?
                jne     con20

                xor     ax,ax                   ;Now see if the 0000h is there.
                scasw
                jne     con20

                mov     cx,di                   ;CX contains size of start.
                dec     cx
                dec     cx

                mov     es,[cs:FindSeg]         ;Now copy the start over.
                push    ds
                mov     ds,[InstrSeg]
                xor     si,si
                mov     di,si
                rep     movsb
                pop     ds
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvTrack:                                      ;Convert the tracks.

                call    NextPass                ;Pass 1.

                push    ds

                mov     cx,[TrackSize]

                xor     bx,bx
                mov     si,2                    ;First word is not used.
                mov     ds,[TrackSeg]

                mov     [cs:MaxSeq],0           ;Used to find highest sequence.
ct10:
                mov     [cs:FindTraOffset+bx],di

                movsw                           ;Copy speed.

                mov     dx,si                   ;Start of track in TrackSeg.

                push    si
                mov     [cs:WrapPoint],-1
ct12:           lodsw
                cmp     ax,0fffeh
                jz      ct20
                cmp     ax,0ffffh               ;Get wrapmark value, if used.
                jne     ct12
                lodsw
                mov     [cs:WrapPoint],ax
                shl     ax,1
                mov     [cs:RawWrap],ax
ct20:           pop     si

                mov     [cs:SameTransp],-1
ct25:
                lodsw                           ;Get a track value.
                cmp     ax,7fffh
                jb      ct40
                cmp     ax,0fffeh               ;Stop track.
                jne     ct27
                stosw
                jmp     short ct70
ct27:           cmp     ax,0ffffh
                jne     ct30                    ;End and wrap track.
                mov     ax,si
                sub     ax,2
                cmp     ax,dx
                jne     ct28
                mov     ax,0fffeh               ;Prevent the deadlock wrapping.
                stosw
                jmp     short ct70
ct28:           mov     ax,0ffffh
                stosw
                mov     ax,[cs:WrapPoint]
                stosw
                jmp     short ct70
ct30:
                cmp     ax,[cs:SameTransp]
                jz      ct33
                mov     [cs:SameTransp],ax      ;New transpose value.
                stosw
                jmp     short ct25
ct33:
                mov     ax,si                   ;Are we past the wrap point?
                sub     ax,dx
                cmp     ax,[cs:RawWrap]
                ja      ct25
                dec     [cs:WrapPoint]          ;No, decrease the wrap value.
                jmp     short ct25
ct40:
                stosw                           ;Sequence number.
                cmp     ax,[cs:MaxSeq]
                jbe     ct25
                mov     [cs:MaxSeq],ax          ;New highest sequence found.
                jmp     short ct25
ct70:
                mov     si,dx
                sub     si,2                    ;Get to speed too.
                add     si,cx

                inc     bx                      ;Bump to next voice track.
                inc     bx
                cmp     bx,18
                jne     ct10

                pop     ds

                inc     [cs:MaxSeq]

                jmp     short ConvTpoin

SameTransp      dw      0
WrapPoint       dw      0
RawWrap         dw      0
MaxSeq          dw      0
SeqPointers     dw      0
FindTraOffset   dw      9 dup (?)
CutFlag         db      0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvTpoin:                                      ;Convert the TPOIN tabel.

                call    NextPass                ;Pass 2.

                mov     [es:TpoinPos],di        ;Write the TPOIN position.

                mov     cx,[Voices]
                xor     bx,bx
ctp20:          mov     ax,[cs:FindTraOffset+bx]
                stosw
                inc     bx                      ;Copy all TRACK pointers.
                inc     bx
                loop    ctp20

                push    ds

                mov     cx,[Voices]
                mov     ds,[InstrSeg]           ;Copy all voice levels.
                mov     si,8bh
                rep     movsb

                pop     ds

                xor     al,al                   ;Five zero's for player v04.00.
                mov     cx,5
                rep     stosb

                mov     ax,-1                   ;And a 0FFFFh to end TPOIN.
                stosw

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvSpecial:                                    ;Convert the SPECIAL tabel.

                call    NextPass                ;Pass 3.

                mov     dx,[es:SpecialPos]      ;Get editor offset pointer.

                mov     [es:SpecialPos],di      ;Write the SPECIAL position.

                mov     di,dx
                add     di,3fffh
                mov     es,[InstrSeg]
                std
                mov     cx,3fffh
                xor     al,al
                repe    scasb                   ;Search for non zero data.
                cld
                mov     es,[cs:FindSeg]
                mov     cx,di
                mov     di,[es:SpecialPos]
                jz      ConvPointers            ;Tabel is unused, skip it.

                sub     cx,dx
                add     cx,8                    ;Add 8 just to be sure.

                push    ds
                mov     ds,[InstrSeg]
                mov     si,dx
                rep     movsb                   ;Now copy the relevant data.
                pop     ds

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvPointers:                                   ;Convert the sequence pointers.

                call    NextPass                ;Pass 4.

                mov     [es:SeqPoiPos],di

                mov     [cs:SeqPointers],di

                mov     cx,[cs:MaxSeq]          ;Dummy fill with 0FFFFh.
                mov     ax,-1
                rep     stosw

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvSeq:                                        ;Convert the sequences.

                call    NextPass                ;Pass 5.

                mov     [cs:CutFlag],0

                xor     bx,bx                   ;Sequence number.

                mov     cx,2                    ;Seq POS, bypass SeqLen word.
cos100:
                mov     si,[cs:SeqPointers]
                mov     [es:si+bx],di           ;Store sequence pointer.

                mov     si,cx

                push    ds
                mov     ds,[SeqSeg]
cos200:
                mov     [cs:CutFlag],0

                lodsw
                mov     dx,ax

                cmp     ax,0ffffh               ;End of sequence.
                jz      cos900
                cmp     ax,0f000h               ;No operation word.
                jz      cos200

                and     ah,0f0h

                cmp     ah,60h                  ;Cut.
                jne     cos210
                mov     [cs:CutFlag],1
                xor     dx,dx
                lodsw
                cmp     ax,207eh
                jz      cos282
                cmp     ax,007eh
                jz      cos282
                jmp     short cos272            ;Go for the REST type instead.
cos210:
                cmp     ah,70h                  ;Commands 7000h-EFFFh.
                jb      cos270
                mov     ax,dx
                stosw
                jmp     short cos200
cos270:
                or      al,al                   ;Rest...
                jne     cos280
                xor     dx,dx
cos272:         lodsw
                cmp     ax,2000h
                jz      cos275
                or      ax,ax
                jz      cos275                  ;Collect REST duration.
                cmp     ax,0f000h
                jz      cos272
                dec     si
                dec     si
                jmp     short cos276
cos275:         inc     dx
                cmp     dx,1fh
                jne     cos272
cos276:         cmp     [cs:CutFlag],0
                jz      cos278
cos277:         mov     ah,60h                  ;Make it look like a CUT.
                mov     al,dl
                stosw
                jmp     cos200
cos278:         mov     ax,dx
                xchg    al,ah
                stosw
                jmp     cos200
cos280:
                cmp     al,7eh                  ;Cont...
                jne     cos290
                xor     dx,dx
cos282:         lodsw
                cmp     ax,207eh
                jz      cos285
                cmp     ax,007eh
                jz      cos285                  ;Collect CONT duration.
                cmp     ax,0f000h
                jz      cos282
                dec     si
                dec     si
                jmp     short cos286
cos285:         inc     dx
                cmp     dx,1fh
                jne     cos282
cos286:         cmp     [cs:CutFlag],0
                jne     cos277
                mov     al,7eh
                mov     ah,dl
                stosw
                jmp     cos200
cos290:
                push    dx                      ;Raw note.
                xor     dx,dx
cos292:         lodsw
                cmp     ax,207eh
                jz      cos295
                cmp     ax,007eh
                jz      cos295                  ;Collect CONT duration.
                cmp     ax,0f000h
                jz      cos292
                dec     si
                dec     si
                jmp     short cos297
cos295:         inc     dx
                cmp     dx,1fh
                jne     cos292
cos297:
                pop     ax                      ;DX popped as AX.
                add     ah,dl
                stosw                           ;Add duration to note word.
                jmp     cos200
cos900:
                stosw                           ;Store the end of sequence.

                inc     bx
                inc     bx

                pop     ds

                add     cx,[SeqSize]

                dec     [cs:MaxSeq]
                jne     cos100
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvInst:                                       ;Convert the instruments.

                call    NextPass                ;Pass 6.

                mov     si,[es:InstrPos]        ;Get editor offset.
                mov     [cs:InPos],si

                mov     [es:InstrPos],di        ;Write offset in FINDSEG.

                push    ds
                mov     ds,[InstrSeg]           ;Copy instrument #0 (CUT).
                mov     cx,8
                rep     movsw
                mov     [cs:FindPos],di
                pop     ds

                mov     si,[es:SeqPoiPos]       ;Get position of SEQ #0.
                mov     si,[es:si]

                mov     cx,di                   ;Get size of all sequences.
                sub     cx,16
                sub     cx,si

                mov     dx,0c001h               ;DX used as CXXXh value.

                push    ds
                mov     ds,[cs:FindSeg]

                push    cx si
coi20:          lodsw
                mov     bl,ah
                and     bl,0f0h
                cmp     bl,0c0h
                jne     coi30
                cmp     ax,dx
                jbe     coi30
                mov     dx,ax                   ;Find the largest CXXXh value.
coi30:          loop    coi20

                mov     si,[es:SpecialPos]      ;Any larger in the SpFx tabel?
                cmp     si,[es:SeqPoiPos]
                jz      coi38
                mov     ax,dx
                and     ax,0fffh
                mov     [cs:TempAX],ax
coi32:          lodsw
                and     ax,0fffh
                cmp     ax,[cs:TempAX]          ;Search all position #0.
                jbe     coi37
                mov     [cs:TempAX],ax
coi37:          add     si,6
                cmp     si,[es:SeqPoiPos]
                jb      coi32

                mov     dx,[cs:TempAX]
                add     dx,0c000h               ;Make it look like a command.
coi38:
                pop     si cx ds                ;DX is now the largest CXXXh.

                call    NextPass                ;Pass 7.
coi39:
                mov     [cs:TempDI],si
                mov     bx,cx
                mov     ax,0c001h
                mov     [cs:PackC],0001h
coi40:
                mov     di,[cs:TempDI]
                mov     cx,bx
                repne   scasw                   ;Find the next RealC.
                jz      coi52

                mov     si,[es:SpecialPos]      ;Check instrument in SpFx tabel.
                cmp     si,[es:SeqPoiPos]
                jz      coi60
                and     ax,0fffh
                mov     [cs:TempAX],ax
                push    ds
                mov     ds,[cs:FindSeg]
coi48:          lodsw
                and     ax,0fffh
                cmp     ax,[cs:TempAX]          ;Search all position #0.
                jz      coi49
                add     si,6
                cmp     si,[es:SeqPoiPos]
                jb      coi48
                pop     ds
                mov     ax,[cs:TempAX]
                add     ax,0c000h
                jmp     coi60
coi49:
                pop     ds
                mov     ax,[cs:TempAX]          ;Restore AX back to what it was.
                add     ax,0c000h
coi52:
                mov     si,ax                   ;Fetch instrument in INSTRSEG.
              ; sub     si,0c000h
                shl     si,1
                shl     si,1
                shl     si,1
                shl     si,1
                add     si,[cs:InPos]
                mov     cx,8
                push    ds
                mov     ds,[InstrSeg]           ;Copy the instrument to FINDSEG.
                mov     di,[cs:FindPos]
                rep     movsw
                mov     [cs:FindPos],di
                pop     ds

                mov     cx,bx
                mov     di,[cs:TempDI]
coi50:          scasw                           ;Improve all CXXXh values.
                jne     coi55
                push    ax
                mov     ax,[cs:PackC]
                add     ax,0c000h
                dec     di
                dec     di
                stosw
                pop     ax
coi55:          loop    coi50

                mov     si,[es:SpecialPos]      ;Alter instrument in SpFx tabel.
                cmp     si,[es:SeqPoiPos]
                jz      coi58
                and     ax,0fffh
                mov     [cs:TempAX],ax
                push    ds
                mov     ds,[cs:FindSeg]
coi56:          lodsw
                mov     ch,ah
                and     ax,0fffh
                cmp     ax,[cs:TempAX]
                jne     coi57
                and     cx,0f000h               ;Replace the instrument pointer.
                add     cx,[cs:PackC]
                mov     ax,cx
                mov     di,si
                dec     di
                dec     di
                stosw
coi57:
                add     si,6
                cmp     si,[es:SeqPoiPos]
                jb      coi56
                pop     ds
                mov     ax,[cs:TempAX]
                add     ax,0c000h
coi58:
                inc     [cs:PackC]              ;Next crunched instrument.
coi60:
                inc     ax                      ;Increase real used instrument.
                cmp     ax,dx
                jbe     coi40

                mov     di,[cs:FindPos]         ;Point to last FINDSEG position.

                xor     ax,ax                   ;Add 16 bytes more to be sure.
                mov     cx,8
                rep     stosw

                jmp     short ConvDataInfo

TempDI          dw      0
InPos           dw      0
PackC           dw      0
FindPos         dw      0
TempAX          dw      0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvDataInfo:                                   ;Do the final DataInfo text.

                call    NextPass                ;Pass 8.

                mov     [es:DataInfoPos],di     ;Write offset in FINDSEG.

                mov     ax,-1                   ;Just write an endmark.
                stosw

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³;Note: DI must be set to the last position as this is used when saving...     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ConvSave:
                call    NextPass                ;Pass 9.

                mov     ax,Data
                mov     ds,ax

                mov     [ConvSize],di

                lea     dx,[ConvName]           ;Save it with a preset name.
                mov     ah,3ch
                xor     cx,cx
                int     21h                     ;Create file.
                jc      ConvError
                mov     [Handle],ax

                mov     bx,ax
                xor     dx,dx
                mov     al,dl
                mov     cx,dx
                mov     ah,42h
                int     21h                     ;Lseek.
                jc      ConvError

                mov     bx,[Handle]
                mov     cx,[ConvSize]
                push    ds
                mov     ds,[cs:FindSeg]
                xor     dx,dx
                mov     ah,40h
                int     21h                     ;Write.
                pop     ds
                jc      ConvError

                mov     bx,[Handle]
                mov     ah,3eh
                int     21h                     ;Close.
                jc      ConvError

                ret
ConvError:
                call    ClrWindow
                call    FileError
                ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NextPass:                                       ;Increase the PASS number.
                push    ax bx es
                mov     ax,0b800h
                mov     es,ax
                mov     ax,24
                cmp     [Chk],0
                jz      npa11
                cmp     [Patch],0               ;See if position remains.
                jz      npa11
                sub     ax,[SubValue]
npa11:          mov     bl,160
                mul     bl
                mov     bx,ax
                inc     [byte es:bx+80]
                pop     es bx ax
                ret
ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
