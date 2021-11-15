������������������������������������������������������������������������������Ŀ comment ^
� Normal 9-voice ADLIB data block .......... Copyright (C) Jens-Christian Huus �
������������������������������������������������������������������������������Ĵ
� Remember to alter VERSION1 and DATAINFO.                                     �
�                                                                              �
� This version for EdLib only.                                                 �
�������������������������������������������������������������������������������� ^

MusicData       segment public
assume          ds:MusicData

; include         globals.inc
��������������������������������������������������������������������������������
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
                dw      SeqPointer              ;01h
                dw      Instrument              ;02h
                dw      Instrument+0c000h       ;03h DataInfo.
                dw      Instrument+08000h       ;04h Special.

                dw      0ffffh                  ;Endmark.
��������������������������������������������������������������������������������
SeqPointer      dw      00000h                  ;Not used in EdLib.

��������������������������������������������������������������������������������
Tpoin           dw      01h,01h,01h,01h,01h,01h,01h,01h,01h     ;Only the levels
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h     ;are used in the
              ; db      0,0,0,0,0                               ;EDITOR player
                                                                ;system in the
              ; dw      0ffffh                  ;Endmark        ;normal way. The
                                                                ;first 9 words
                                                                ;here only work
                                                                ;as ON/OFF flags
                                                                                 comment ^
�������������������������AD���SR��LV��AVEKmult��W��F���������������������������� ^

Instrument      db      0ffh,0ffh,3fh,00100000b,0
                db      0ffh,0ffh,3fh,00100000b,0,00h
                db      000h,000h,000h,0,0
                empty   equ     0

��������������������������������������������������������������������������������
                ends
                end