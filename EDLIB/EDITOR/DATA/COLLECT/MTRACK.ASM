;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  MUSIC-PLAYER (C) Copyright 1992 Jens-Christian Huus. All rights reserved.  ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  Normal 9-voice ADLIB/track block - this system is for EDITOR usage only !  ³
;³                                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

musictrack      segment public
assume          ds:musictrack
;-------------------------------------------------------------------------------
; Values        Comments        * = Special modification made for EDITOR usage.
;-------------------------------------------------------------------------------
; -----       * First position of all tracktables is undefined.
; -----       * Second position of all tracktables is always speed.
; 0000h-7fffh	Sequences
; 8000h-8fffh	Transpose - 8XYYh: X=Direction, YY=Actual transpose value
; fffeh		Stop the track
; ffffh,XXXX	Wrap the track to position XXXX (In steps of one)
;-------------------------------------------------------------------------------
tk1             db      802 dup (0)                     ;802 bytes for track.

tk2             db      802 dup (0)

tk3             db      802 dup (0)

tk4             db      802 dup (0)

tk5             db      802 dup (0)

tk6             db      802 dup (0)

tk7             db      802 dup (0)

tk8             db      802 dup (0)

tk9             dw      0,4

                dw      8000h,1,0ffffh,0

                dw      800 dup (0)
;-------------------------------------------------------------------------------
                ends
                end
