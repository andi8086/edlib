ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ Normal 9-voice ADLIB globals ............. Copyright (C) Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ All globals and macros used by the ADLIB player system - Updated 02/10-1993. ³
³                                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^


ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ *** MACROS ***                                                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

c               macro   trn,dval
                dw      dval*100h+(00h+(trn*12))
                endm

cz              macro   trn,dval
                dw      dval*100h+(01h+(trn*12))
                endm

d               macro   trn,dval
                dw      dval*100h+(02h+(trn*12))
                endm

dz              macro   trn,dval
                dw      dval*100h+(03h+(trn*12))
                endm

e               macro   trn,dval
                dw      dval*100h+(04h+(trn*12))
                endm

f               macro   trn,dval
                dw      dval*100h+(05h+(trn*12))
                endm

fz              macro   trn,dval
                dw      dval*100h+(06h+(trn*12))
                endm

g               macro   trn,dval
                dw      dval*100h+(07h+(trn*12))
                endm

gz              macro   trn,dval
                dw      dval*100h+(08h+(trn*12))
                endm

a               macro   trn,dval
                dw      dval*100h+(09h+(trn*12))
                endm

az              macro   trn,dval
                dw      dval*100h+(0ah+(trn*12))
                endm

b               macro   trn,dval
                dw      dval*100h+(0bh+(trn*12))
                endm
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
twrap           macro   wrap
                dw      0ffffh,wrap
                endm

tstop           macro
                dw      0fffeh
                endm

seqend          macro
                dw      0ffffh
                endm

rest            macro   dval
                dw      dval*100h
                endm

cont            macro   dval
                dw      dval*100h+7eh
                endm

cut             macro   cval
                dw      6000h+cval
                endm

lvl             macro   lval
                dw      9000h+lval
                endm

snd             macro   ival
                dw      0c000h+ival
                endm

up              macro   uval
                dw      0d000h+uval
                endm

down            macro   doval
                dw      0e000h+doval
                endm

lc              macro   lcval,dval
                dw      dval*100h+(lcval+80h)
                endm

vib             macro   vval
                dw      7000h+vval
                endm

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ comment ^
³ *** GLOBALS ***                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ^

global          Version1:byte
global          Max:byte
global          General:word
global          SeqPointer:word
global          Tpoin:word
global          Instrument:byte
global          DataInfo:byte
global          Special:byte
global          Timer:byte

global          Player:far
global          Version2:word
global          Voicon:byte
global          Credits:byte
global          StopVoice:near
global          Sound:near

global          Tempw:word
global          ESeg:word
global          EOffset:word
global          Levels:byte
global          Note:byte
global          ShNote:byte
global          Speed:byte
global          Spedr:byte
global          TrackPointer:word
global          Inst:word
global          Dur:word
global          Durr:word
global          SeqPoi:word
global          TrackPoi:word
global          Freq:word
global          Gate:byte
global          Transp:word
global          SlFreq:word
global          Nog:byte
global          ShSlFreq:word
global          ShGate:byte
global          ShFreq:word
global          Level2:byte
global          Level3:byte
global          Carrier:byte
global          Modulator:byte
global          FreqTab:word
global          ShVib:word
global          VWidth:byte
global          VWid:byte
global          Vspeed:byte
global          KsLevel:byte
global          AdLevel:byte
global          FeedCon:byte
global          MvolLo:byte
global          MvolHi:byte
global          BreakVoicOn:byte
global          FirstSeg:word
global          FirstOffset:word
global          SecondSeg:word
global          SecondOffset:word
global          TempSeg:word
global          TempOffset:word
global          DivLine:word
global          MvolLine:byte
global          FineTune:byte
global          HardRst:byte
global          HardTimer:byte
global          HardRel:byte

global          Spec:word
global          Specr:word
global          SpArp:byte
global          SpModLevel:byte
global          SpModAdd:byte
global          SpDur:byte
global          SpRaw:byte

