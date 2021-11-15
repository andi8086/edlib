ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ Normal 9-voice ADLIB data block .......... Copyright (C) Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Remember to alter VERSION1 and DATAINFO.                                     ³
³                                                                              ³
³                                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

MusicData       segment public
assume          ds:MusicData

include         globals.inc
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
                dw      Special                 ;04h    ;New!

                dw      0ffffh                  ;Endmark.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SeqPointer      dw      s00,s01,s02,s03,s04,s05,s06,s07,s08,s09,s0a,s0b,s0c,s0d
                dw      s0e,s0f,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s1a,s1b
                dw      s1c,s1d,s1e,s1f,s20

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ 0000h-0011h   Offset pointers to tracks.                                     ³
³ 0012h-001Ah   Tracklevels 00-3F. Bit 7 (80h) ties START/STOP style effects.  ³
³                                  Bit 6 (40h) enables "play out" priority.    ³
³ 001Bh-001Fh   Unused, aligns the tabels to 32 bytes each.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

Tpoin           dw      Tk1,Tk2,Tk3,Tk7,Tk5,Tk6,Tk7,Tk7,Tk7     ;
                db      00h,00h,00h,00h,00h,00h,00h,00h,00h
                db      0,0,0,0,0

                dw      0ffffh                  ;Endmark.

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ 0000h-0001h   Carrier ADSR.                                                  ³
³ 0002h         Carrier level 00-3F + KSL 00/40/80/C0.                         ³
³ 0003h         Carrier AM/VIB/EG/KSR bits + multiplier in lonibble.           ³
³ 0004h         Carrier waveform 00-03.                                        ³
³ 0005h-0009h   Modulator mirror bytes (Same as carrier).                      ³
³ 000Ah         Feedback/Conn. (Bit 0=Modulated/Additive, bit 1-3=Feedback).   ³
³ 000Bh         Finetune - signed (00=Same, 01=+1, FF=-1).                     ³
³ 000Ch         Hard Restart, 00=Off, 01-FF frames before note end, cut there. ³
³ 000Dh         Carrier Sustain/Release to perform when using Hard Restart.    ³
³ 000Eh-000Fh   Unused, aligns the tabels to 16 bytes each.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄADÄÄÄSRÄÄLVÄÄAVEKmultÄÄWÄÄFÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ^

Instrument      db      0ffh,0ffh,3fh,00100000b,0
                db      0ffh,0ffh,3fh,00100000b,0,00h
                db      000h,000h,000h,0,0
                empty   equ     0

                db      0ffh,005h,00h,00000000b,1
                db      0ffh,006h,0eh,00000010b,1,04h
                db      000h,000h,000h,0,0
                bass    equ     1

                db      0f6h,014h,00h,00100010b,1
                db      0ffh,001h,0ch,00000100b,1,04h
                db      000h,004h,00bh,0,0
                lead    equ     2

                db      0f6h,014h,00h,00100010b,1
                db      0ffh,001h,0ch,00000100b,1,04h
                db      001h,004h,00bh,0,0
                lead3   equ     3

                db      0ffh,016h,00h,00100001b,0
                db      0ffh,000h,0ah,01100101b,2,0ch
                db      000h,000h,000h,0,0
                noise   equ     4

                db      0ffh,001h,00h,00100101b,0
                db      0ffh,001h,00h,00100110b,0,01h
                db      000h,000h,000h,0,0
                sine    equ     5

                db      022h,032h,00h,00100010b,1
                db      02fh,002h,0ah,00000000b,2,08h
                db      000h,005h,00ah,0,0
                lead2   equ     6

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ 0000h-0001h   (Word) Instrument used in this step.                           ³
³                      Bit 15 (8000h) = Use RAW arpeggio values only (drums).  ³
³ 0002h         (Byte) Arpeggio value - 00=Same, 03=3 «'s up, FD=3 «'s down.   ³
³ 0003h         (Byte) Modulator level 00-3F - FF=Ignore/Use current value.    ³
³ 0004h         (Byte) Modulator add - signed (00=Same, 01=1 up, FF=1 down).   ³
³ 0005h         (Byte) Duration in player calls 00-FF, 00=1 player call.       ³
³ 0006h-0007h   (Word) Jump to this pointer when duration has exceeded.        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

Special         label   byte

                dw      bass
                db      00ch,0ffh,001h,004h     ;0000h
                dw      0001h

                dw      lead
                db      000h,0ffh,001h,004h     ;0001h
                dw      0000h

                dw      lead
                db      000h,0ffh,000h,000h     ;0002h
                dw      0003h

                dw      lead
                db      003h,0ffh,000h,000h     ;0003h
                dw      0004h

                dw      lead
                db      007h,0ffh,000h,000h     ;0004h
                dw      0002h

             ;--------------

                dw      noise+8000h
                db      02fh,0ffh,000h,000h     ;0005h
                dw      0006h

                dw      sine+8000h
                db      00eh,0ffh,000h,000h     ;0006h
                dw      0007h

                dw      sine+8000h
                db      00ch,0ffh,000h,000h     ;0007h
                dw      0008h

                dw      noise+8000h
                db      031h,0ffh,000h,001h     ;0008h
                dw      0009h

                dw      sine+8000h
                db      008h,0ffh,000h,000h     ;0009h
                dw      000ah

                dw      noise+8000h
                db      031h,0ffh,000h,000h     ;000ah
                dw      000ah


                dw      lead2
                db      000h,0ffh,000h,001h     ;000bh
                dw      000ch

                dw      lead2
                db      003h,0ffh,000h,001h     ;000ch
                dw      000dh

                dw      lead2
                db      007h,0ffh,000h,001h     ;000dh
                dw      000bh


                dw      lead2
                db      000h,0ffh,000h,001h     ;000eh
                dw      000fh

                dw      lead2
                db      005h,0ffh,000h,001h     ;000fh
                dw      0010h

                dw      lead2
                db      008h,0ffh,000h,001h     ;0010h
                dw      000eh

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ -----         First position of all tracktabels is the speed value.          ³
³ 0000h-7FFFh   Sequences.                                                     ³
³ 8000h-8FFFh   Transpose - 8XYYh: X=Direction, YY=Actual transpose value.     ³
³ 9000h-9040h   New tune speed.                                                ³
³ FFFEh         Stop the track.                                                ³
³ FFFFh,XXXXh   Wrap the track to position XXXXh (word counted!).              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

Spd2=24h        ;Speed of Leader Bent.

Tk1:                                    ;Bass.
                dw      24h
                dw      8000h,1,2,1,3
                twrap   0

Tk2:                                    ;Bass.
                dw      24h
                dw      8000h,4
                dw      1,2,1,3
                twrap   2

Tk3:                                    ;Snare track.
                dw      24h
                dw      8000h,6,6,6,7
                twrap   0

Tk4:                                    ;Leader Bent.
                dw      Spd2
                dw      8000h,5
                tstop

Tk5:
                dw      24h             ;Arpeggio chords (Yuck!)
                dw      8000h,8,9
                twrap   0

Tk6:                                    ;Arpeggio chords (Yuck!)
                dw      24h
                dw      8000h,0ah
                dw      8,9
                twrap   2

Tk7:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk8:                                    ;
                dw      40h
                dw      8000h,0
                tstop

Tk9:                                    ;Leader Bent.
                dw      Spd2
                dw      8000h,0bh
                tstop

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ 6000h-6FFFh   Cut x   Cut duration 000-FFF.                                  ³
³ 7000h-7FFFh   Vib x   Vibrato - 7XYYh: X=Vibrato width, YY=Vibrato speed.    ³
³ 9000h-903Fh   Lvl x   Levels 00-3F (Real volume).                            ³
³ C000h-CFFFh   Snd x   Instrument 000-FFF.                                    ³
³ D000h-DFFFh   Up x    Slide up 000-FFF.                                      ³
³ E000h-EFFFh   Down x  Slide down 000-FFF.                                    ³
³ FFFFh         SeqEnd  End of sequence.                                       ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ XXYYh         d=DUR.  Duration, note, tienote and lock function in ONE word: ³
³                                                                              ³
³ XX: 00h-1Fh     --    Normal duration 00-1F.                                 ³
³ XX: 20h-3Fh     --    Duration 00-1F with tienote ON.                        ³
³ YY: 00h/80h   Rest d  Rest (Release).                                        ³
³ YY: 01h-5Fh   Cz x d  Notes (C#0 and up).                                    ³
³ YY: 7Eh       Cont d  Hold (Continue).                                       ³
³ YY: 81h-DFh   Lc x d  Locked notes (Ignores track transpositions).           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^
s00:                                                            ;Cut sequence
                cut 0
                seqend

s01:                                                            ;
                snd bass
                c 3 3
                c 3 3
                dz 3 3
                c 3 3
                dz 3 3
                c 3 3
                dz 3 3
                f 3 3
                seqend

s02:                                                            ;
                c 3 3
                c 3 3
                dz 3 3
                c 3 3
                dz 3 3
                c 3 3
                az 2 3
                b  2 3
                seqend

s03:                                                            ;
                c 3 3
                c 3 3
                dz 3 3
                c 3 3
                fz 3 1
                g 3 1
                dz 3 3
                g 2 3
                az 2 3
                seqend

s04:                                                            ;
                cut 5
                lvl 15h
                seqend

s05:                                                            ;Leader Bent.
                snd lead
                c 3 0
                c 3 1
                c 3 0
                cont 0
                rest 0
                rest 0
                rest 0
                rest 0
                rest 0
                rest 0
                c 3 7
                dz 3 3
                g 3 3
                dz 3 3
                f 3 15
                up 3
                cont 2
                g 3 21h
                vib 0603h
                cont 9
                rest 7
                seqend

s06:                                                            ;Snare.
                cut 7
                lvl 00h
                dw      0b005h
                dw      0118h
                rest 5
                seqend

s07:                                                            ;Snare.
                cut 7
                lvl 00h
                dw      0b005h
                dw      0118h
                rest 1
                dw      0018h
                rest 2
                seqend

s08:                                                            ;Chords.
                dw      0b00bh
                C 5 1fh
                cont 1fh
                rest 1fh
                rest 1fh
                seqend

s09:                                                            ;Chords.
                dw      0b00eh
                C 5 1fh
                cont 1fh
                rest 1fh
                rest 1fh
                seqend

s0a:                                                            ;Chords delay.
                cut 3
                lvl 0ah
                seqend

s0b:                                                            ;Leader Bent.
                snd lead3
                c 3 0
                c 3 1
                c 3 0
                cont 0
                rest 0
                rest 0
                rest 0
                rest 0
                rest 0
                rest 0
                c 3 7
                dz 3 3
                g 3 3
                dz 3 3
                f 3 15
                up 3
                cont 2
                g 3 21h
                vib 0603h
                cont 9
                rest 7
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

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DataInfo        label   byte

                dw      0ffffh                                  ;Endmark.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                ends
                end
