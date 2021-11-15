������������������������������������������������������������������������������Ŀ comment ^
� Normal 9-voice ADLIB data block .......... Copyright (C) Jens-Christian Huus �
������������������������������������������������������������������������������Ĵ
� Remember to alter VERSION1 and DATAINFO.                                     �
�                                                                              �
�                                                                              �
�������������������������������������������������������������������������������� ^

MusicData       segment public
assume          ds:MusicData

include         globals.inc
��������������������������������������������������������������������������������
Detection       db      'JCH',26h,02h,66h       ;System detection bytes.
Kind            db      00h                     ;00h for music data block.
Version1        db      03h                     ;Major music-player version.
Timer           db      70                      ;Timerspeed for the block.
Max             db      1                       ;Number of music and effects.
Card            db      00h                     ;00h for normal Adlib.

BlockName       db      '                                '      ;32 bytes names.
Composer        db      '                                '

                db      32 dup (0)              ;For future expansion...

General         dw      Tpoin                   ;00h
                dw      SeqPointer              ;01h
                dw      Instrument              ;02h
                dw      DataInfo                ;03h

                dw      0ffffh                  ;Endmark.
��������������������������������������������������������������������������������
SeqPointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s1a,s1b
                dw      s1c,s1d,s1e,s1f,s20

������������������������������������������������������������������������������Ŀ comment ^
� 0000h-0011h   Offset pointers to tracks.                                     �
� 0012h-001Ah   Tracklevels 00-3F. Bit 7 (80h) ties START/STOP style effects.  �
�                                  Bit 6 (40h) enables "play out" priority.    �
� 001Bh-001Fh   Unused, aligns the tabels to 32 bytes each.                    �
�������������������������������������������������������������������������������� ^

Tpoin           dw      Tk1,Tk2,Tk3,Tk4,Tk5,Tk6,Tk7,Tk8,Tk9     ;
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
                db      0,0,0,0,0

                dw      0ffffh                  ;Endmark.

������������������������������������������������������������������������������Ŀ comment ^
� 0000h-0001h   Carrier ADSR.                                                  �
� 0002h         Carrier level 00-3F + KSL 00/40/80/C0.                         �
� 0003h         Carrier AM/VIB/EG/KSR bits + multiplier in lonibble.           �
� 0004h         Carrier waveform 00-03.                                        �
� 0005h-0009h   Modulator mirror bytes (Same as carrier).                      �
� 000Ah         Feedback/Conn. (Bit 0=Modulated/Additive, bit 1-3=Feedback).   �
� 000Bh-000Fh   Unused, aligns the tabels to 16 bytes each.                    �
��������������������������������������������������������������������������������

�������������������������AD���SR��LV��AVEKmult��W��F���������������������������� ^

Instrument      db      0ffh,0ffh,3fh,00100000b,0
                db      0ffh,0ffh,3fh,00100000b,0,00h
                db      0,0,0,0,0
                empty   equ     0

������������������������������������������������������������������������������Ŀ comment ^
� -----         First position of all tracktabels is the speed value.          �
� 0000h-7FFFh   Sequences.                                                     �
� 8000h-8FFFh   Transpose - 8XYYh: X=Direction, YY=Actual transpose value.     �
� 9000h-9040h   New tune speed.                                                �
� FFFEh         Stop the track.                                                �
� FFFFh,XXXXh   Wrap the track to position XXXXh (word counted!).              �
�������������������������������������������������������������������������������� ^
Tk1:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk2:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk3:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk4:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk5:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk6:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk7:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk8:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk9:                                    ;
                dw      40h
                dw      8000h,0
                tstop

������������������������������������������������������������������������������Ŀ comment ^
� 6000h-6FFFh   Cut x   Cut duration 000-FFF.                                  �
� 7000h-7FFFh   Vib x   Vibrato - 7XYYh: X=Vibrato width, YY=Vibrato speed.    �
� 9000h-903Fh   Lvl x   Levels 00-3F (Real volume).                            �
� C000h-CFFFh   Snd x   Instrument 000-FFF.                                    �
� D000h-DFFFh   Up x    Slide up 000-FFF.                                      �
� E000h-EFFFh   Down x  Slide down 000-FFF.                                    �
� FFFFh         SeqEnd  End of sequence.                                       �
������������������������������������������������������������������������������Ĵ
� XXYYh         d=DUR.  Duration, note, tienote and lock function in ONE word: �
�                                                                              �
� XX: 00h-1Fh     --    Normal duration 00-1F.                                 �
� XX: 20h-3Fh     --    Duration 00-1F with tienote ON.                        �
� YY: 00h/80h   Rest d  Rest (Release).                                        �
� YY: 01h-5Fh   Cz x d  Notes (C#0 and up).                                    �
� YY: 7Eh       Cont d  Hold (Continue).                                       �
� YY: 81h-DFh   Lc x d  Locked notes (Ignores track transpositions).           �
�������������������������������������������������������������������������������� ^
s00:                                                            ;Cut sequence
                cut 0
                seqend

s01:                                                            ;

                seqend

s02:                                                            ;

                seqend

s03:                                                            ;

                seqend

s04:                                                            ;

                seqend

s05:                                                            ;

                seqend

s06:                                                            ;

                seqend

s07:                                                            ;

                seqend

s08:                                                            ;

                seqend

s09:                                                            ;

                seqend

s0a:                                                            ;

                seqend

s0b:                                                            ;

                seqend

s0c:                                                            ;

                seqend

s0d:                                                            ;

                seqend

s0e:                                                            ;

                seqend

s0f:                                                            ;

                seqend

s10:                                                            ;

                seqend

s11:                                                            ;

                seqend

s12:                                                            ;

                seqend

s13:                                                            ;

                seqend

s14:                                                            ;

                seqend

s15:                                                            ;

                seqend

s16:                                                            ;

                seqend

s17:                                                            ;

                seqend

s18:                                                            ;

                seqend

s19:                                                            ;

                seqend

s1a:                                                            ;

                seqend

s1b:                                                            ;

                seqend

s1c:                                                            ;

                seqend

s1d:                                                            ;

                seqend

s1e:                                                            ;

                seqend

s1f:                                                            ;

                seqend

s20:                                                            ;

                seqend

��������������������������������������������������������������������������������
DataInfo        label   byte

                dw      0ffffh                                  ;Endmark.
��������������������������������������������������������������������������������
                ends
                end