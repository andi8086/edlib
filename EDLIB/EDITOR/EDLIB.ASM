ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ if 0
³ EdLib music editor ............. (C) Copyright 1992-1994 Jens-Christian Huus ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Music editor for DOS in 80x50 text screen. The editor is very configurable,  ³
³ even to the level of other programmers developing players for it.            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ v1.05a rev 55, 01/1994. Version in "EdVers".                                 ³
³ ÄÄÄÄÄÄÂÄÄÄÄÄÄ                                                                ³
³       ³                                                                      ³
³       ÀÄÄ This version and revision is new and unsaved, work with this.      ³
³                                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ endif

EdVers  equ     'v1.05a'

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Demo=0                          ;Set to 1 to produce a DEMO version only. The
				;demo version will not assemble the SAVE and
				;D00 converter instructions, and a WINDOW with
				;a warning will appear if the user tries to
				;access these functions.
IDEAL

ASSUME		ss:Stacks,ds:Data,cs:Code

INCLUDE         "tables\tab.asm"

IF DEMO EQ 0

INCLUDE         "aconv.asm"

ENDIF
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT 	Stacks	STACK 'Stack'

		db	400h dup (?)
ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT 	Data	PUBLIC 'Data'

Col1Jump	db	2	;Number of bytes in sequence's column 1.
Col2Jump	db	2	;Number of bytes in sequence's column 2.
Col1Color	db	8	;Color of column 1, when empty.
RestColor	db	8	;Color of REST-commands in column 2.
NoteColor	db	09h	;Color of notes in column 2.
HoldColor	db	0bh	;Color of HOLD-commands in column 2.
CommandColor	db	04h	;Color of commands in column 1.
NewTrackChr1	db	3eh	;First character to identify new sequence.
NewTrackChr2	db	3ch	;Second character to identify new sequence.
Col1Blank	db	2dh	;Blank character in column 1.
Col2Rest	db	2dh	;Character for REST-commands in column 2.
Col2Hold	db	2bh	;Character for HOLD-commands in column 2.
MidSpace	db	1	;Number of spaces between columns.
Col2RestPos	db	00h	;Position of byte in column 2 to identify REST.
Col2RestMask	db	7fh	;AND-value to use before comparison, for REST.
Col2RestValue	db	00h	;Actual REST value.
Col2HoldPos	db	00h	;Position of byte in column 2 to identify HOLD.
Col2HoldMask	db	7fh	;AND-value to use before comparison, for HOLD.
Col2HoldValue	db	7eh	;Actual HOLD value.
Col2NotePos	db	00h	;Position of byte in column 2 to identify notes.
Col2NoteMask	db	7fh	;AND-value to use before comparison, for notes,
				;notes MUST use values from 00h to max. 7fh!
TiePos		db	81h	;Position of byte to include TIE-note ID-bits,
				;BIT 7=1 means byte number refers to column 2.
TieMaskValue	db	20h	;MASK'N COMPARE value for TIE-note comparison.
TieColor	db	0fh	;Color of TIE-noted note.

LABEL Col1BytePos BYTE		;TABLE: Position of bytes on screen, column 1.

		db	1,0

LABEL Col1BlankValues BYTE	;TABLE: Blank space values in column 1.

		db	00h,0f0h

TrackClearChar	db	20h	;Character for empty space in track table.
TrackClearColor db	00h	;Color for empty space in track table.
TrackJump	db	4	;Number of bytes in track table.
TrackSpace	db	1	;Number of spaces between tracks and sequences.
TrackMidSpace	db	1	;Number of spaces between transpose and seq no.
TrackSeq	db	82h	;Position of byte with sequence-number,
				;BIT 7=1 means POS and POS+1 equals WORD seq-no.
TrackCurGoto	db	0  ;4	;Cursor position on track-number when pressing
				;"ENTER". Note: Value refers to cursor steps!
TrackSkip	dw	4	;Number of bytes of track's start to bypass.
				;This is useful if the beginning of each track
				;table has special functions, I.e. SPEED etc.
Voices		dw	9	;Maximum number of voices in the player.
Visible 	dw	9  ;5	;Number of voices possible on screen at once.

LABEL VoiceOrder WORD		;TABLE: Which voices appears where on screen.

		dw	0,1,2,3,4,5,6,7,8

LABEL VoiceNoCol BYTE		;TABLE: Colors for each voice no. over voices.

		db	0fh,0fh,0fh,0fh,0fh,0fh,0fh,0fh,0fh

LABEL VoiceFlags BYTE		;TABLE: Condition of voice ON/OFF flags.

		db	1,1,1,1,1,1,1,1,1

LABEL TrackBytePos BYTE 	;TABLE: Position of bytes on screen for tracks.

		db	1,0,3,2

LABEL TrackByteCol BYTE 	;TABLE: Colors of each byte in track table.

		db	05h,05h,05h,05h

LABEL TrackBlanks BYTE		;TABLE: Fill value used when clearing tracks.

		db	0ffh,0ffh,00h,00h

LABEL TrackInsert BYTE		;TABLE: Insert value used when inserting.

		db	00h,80h,00h,00h

LABEL TrackEnd	BYTE		;TABLE: Normal End-of-Track values.

		db	0ffh,0ffh,00h,00h

LABEL TrackEndVal BYTE		;TABLE: Values to detect true end of track.

		db	0ffh,0ffh,0ffh,0ffh

Lines		dw	32	;Number of lines available for tracks and seq's.
SeqSize 	dw	180h	;Maximum size of each sequence in memory.
VoiceRow	dw	9	;Row on screen where voices are to appear.
VoiceCol	dw	4	;Column on screen where first voice appears.
VoiceSpace	db	3	;Number of spaces between voices.
TrackHide	db	1	;=1 means don't print Track when voice inactive.
Col1Hide	db	1	;=1 means don't print Col.1 when voice inactive.
BarColor	db	0dfh	;Cursor bar's background color. SPECIAL NOTE:
				;XYh = Colors. X is always bar color itself,
				;Y = 0 means char colors are NOT changed,
				;Y <> 0 means chars in bar gets THIS color.
StepColumn	db	1	;Column on screen where stepcounter appears.
StepLine	db	4	;Position of line to the right of stepcounter.
StepColor	db	0ch	;Color of Step Counter.
StartPointCol	db	02h	;Color of Step Counter from StartPoint mark.
EdgeColor	db	8	;Color of the edge lines.
EdgeChar	db	196	;Character for edge lines.
SkillLines	db	1	;=1 means vertical lines between voices. NOTE:
				;These lines are not visible if VoiceSpace = 0.
LastLine	db	0	;=1 means print last line at far right.
SkillSpace	db	1;0	;Number of spaces before SkillLines appear.
				;NOTE: This can cause line to hide under voice!
SkillChar	db	179	;Character for skillLines.
SkillCornerUp	db	194	;Character to join SkillLines & upper EdgeLine.
SkillCornerDw	db	193	;Character to join SkillLines & lower EdgeLine.
SuperInsValue	dw	10h	;Number of Inserts done by SuperInsert function.
TimerSpeed	dw	0	;Speed of the timer interrupt.
RhythmJump	dw	0	;Down's to be executed after each NOTE typed.
Speed		dw	20h	;Initial tune speed setting.
FrameColor	db	70h	;Color for boxes and designs on screen.
ONcolor 	db	0fh	;Color of VoiceNoCol when voice is ON.
OFFcolor	db	06h	;Color of voiceNoCol when voice is OFF.
BackColor	db	08h	;Color of main background carpet.
ScrollBorder	dw	4	;When to begin scrolling at top or bottom.
				;NOTE: Highest possible value is 15, but it is
				;recommended not to go higher than 8!
ClearOffset	dw	00a3h	;Offset from where the instrument segment may
				;be cleared, to protect pointers and the like.
FileCol 	dw	32	;Where to put the file requester.
FileColor	db	087h	;Colors of the file requester, dark sides.
FileLight	db	07eh	;Colors of the file requester, bright sides.
SubValue	dw	8	;Subtract lines from requesters when OpenPatch.
MidiVibrato	dw	060ah	;Vibrato value used when playing with MIDI.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InstrBuffer	db	TabLength dup (0)

LABEL InstrTable BYTE

		db	29	;Row where table is to appear.
		db	7	;Column where table is to appear.
		db	2	;Column where Step-counter is to appear.
		dw	1	;Format of actual step-counting (Add-value!).
		db	0b9h	;Color of Step-counter.
		db	' '     ;Character to appear after the Step-counter.
		db	0b0h	;Color of StepChar.
		db	0	;How much further is this StepChar to appear.
		db	6	;Max number of lines for the table on screen.
		db	16	;Number of sequentially chosen bytes for a line.

		db	16	;Number of letters for each name component.
                db      53      ;Column where names are to appear.
                db      0b3h    ;Color of names.
                db      009h    ;Color of name when editing.
		db	250	;Substitute for space character in names.

		dw	0094h	;Offset in segment where table can be found.

		dw	4000h	;Maximum size of entire table.

		dw	4094h	;Offset in segment where names can be found.
				;If this value = 0ffffh then names are NOT used.

				;TABLE: How to show the chosen bytes on screen.
				;	These values refers to screen positions,
				;	meaning that the next value should not
				;	be added with a number less than 2.
				;
				;	Add with 80h to display a line (0b3h)
				;	at the position.
				;
				;	End the table with 0ffffh.
				;
				;	Due to a bug I'm too lazy to fix, the
				;	last value MUST be a hex position. If
				;	you want a line at the last position,
				;	put it as the second last value. Also,
				;	the first position cannot be a line.
				;
				;	Double byte values. Every second byte
				;	is the color.

		db	0,0b0h
                db      2,0b0h
                db      5,0b0h
                db      8,0b0h
                db      11,0b0h
                db      14,0b3h
                db      16,0b3h
                db      19,0b3h
                db      22,0b3h
                db      25,0b3h
                db      28,0b0h
                db      31,0b0h
                db      34,0b0h
                db      37,0b0h
                db      40,0b0h
	      ; db	59+80h,0b0h
		db	43,0b0h
		dw	0ffffh

				;TABEL: Help text pointers for each hex byte
				;	position.

		dw	CarADSR
		dw	CarADSR
		dw	CarLvl
		dw	CarMult
		dw	CarWave
		dw	ModADSR
		dw	ModADSR
		dw	ModLvl
		dw	ModMult
		dw	ModWave
		dw	FeedTxt
		dw	TuneTxt
		dw	HardRs1
		dw	HardRs2
		dw	NoTxt
		dw	NoTxt
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CarADSR 	db	'XXXX³CARRIER ADSR - Controls volumen. AD/R uses'
		db	'³slope timers 0-F with F for fast. S is the'
		db	'ADSR³actual volumen, 0 for loud, F for silence.'

CarLvl		db	'00111111³CARRIER LEVEL - Main volume 00-3F with'
		db	'À´ÀÄÄÄÂÙ³00 as loudest. Add 40/80/C0 for KSL to'
		db	'KSL  LVL³decrease level towards higher notes.  '

CarMult 	db	'00001111³CARRIER MULTIPLE - 00-0F sets multiple'
		db	'ÀÄÂÙ³freq (kinda like octave). Add: 10=KSR,'
		db	'TVEK MLT³20=ADSR or ADR, 40=Vibrato, 80=Tremolo'

CarWave 	db	'XX³CARRIER WAVEFORM - Only values 00-03 is used'
		db	'³here. 00 is a sine and is loudest. Waveforms'
		db	'-W³02/03 are also one octave higher than 00/01.'

ModADSR 	db	'XXXX³MODULATOR ADSR - Modulates sound. AD/R are'
		db	'³slope timers 0-F with F for fast. S is the'
		db	'ADSR³actual volumen, 0 for loud, F for silence.'

ModLvl		db	'00111111³MODULATOR LEVEL - Use 00-3F, 00 equals'
		db	'À´ÀÄÄÄÂÙ³100% modulate. Add 40/80/C0 for KSL to'
		db	'KSL  LVL³decrease level towards higher notes.  '

ModMult 	db	'00001111³MODULATOR MULTIPLE - 00-0F is multiple'
		db	'ÀÄÂÙ³freq (kinda like octave). Add: 10=KSR,'
		db	'TVEK MLT³20=ADSR or ADR, 40=Vibrato, 80=Tremolo'

ModWave 	db	'XX³MODULATOR WAVEFORM - Only use 00,01,02 or 03'
		db	'³here. 00 is a sine and is loudest. Waveforms'
		db	'-W³02/03 are also one octave higher than 00/01.'

FeedTxt 	db	'00001110³FEEDBACK/CONNECTION - Set the level of'
		db	'    ÀÂÙ³the feedback with bits 1-3 (0,2,4...),'
		db	'     F C³add with 01 for additive connection.  '

TuneTxt 	db	'XX³FINETUNE - Keep within values 00-7F. Used to'
		db	'À´³phase two voices together, or when using the'
		db	'FT³lock mode in the SpFX table.                '

HardRs1 	db	'XX³HARD RESTART TIMER - At XX frames before the'
		db	'À´³next note, activate the sustain/release byte'
		db	'HR³following this byte. 00 turns this OFF.     '

HardRs2 	db	'XX³HARD RESTART S/R - New sustain/release value'
		db	'À´³when using hard restart. See the byte to the'
		db	'SR³left for more information on hard restart.  '

NoTxt		db	'XX³UNUSED - For future expansion. Please do not'
		db	'À´³change this byte, leave it at 00.           '
		db	'??³                                            '
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ExtraBuffer	db	TabLength dup (0)

LABEL ExtraTable1 BYTE

		db	36  ;29 ;Row where table is to appear.
                db      7   ;56 ;Column where table is to appear.
                db      2   ;51 ;Column where Step-counter is to appear.
		dw	1	;Format of actual step-counting (Add-value!).
		db	0b9h	;Color of Step-counter.
		db	' '     ;Character to appear after the Step-counter.
		db	0b0h	;Color of StepChar.
		db	0	;How much further is this StepChar to appear.
		db	6   ;13 ;Max number of lines for the table on screen.
		db	8	;Number of sequentially chosen bytes for a line.

		db	0	;Number of letters for each name component.
		db	0	;Column where names are to appear.
		db	0	;Color of names.
                db      0       ;Color of name when editing.
		db	0	;Substitute for space character in names.

		dw	8094h	;Offset in segment where table can be found.

		dw	4000h	;Maximum size of entire table.

		dw	0ffffh	;Offset in segment where names can be found.
				;If this value = 0ffffh then names are NOT used.

				;TABLE: How to show the chosen bytes on screen.
				;	These values refers to screen positions,
				;	meaning that the next value should not
				;	be added with a number less than 2.
				;
				;	Add with 80h to display a line (0b3h)
				;	at the position.
				;
				;	End the table with 0ffffh.
				;
				;	Due to a bug I'm too lazy to fix, the
				;	last value MUST be a hex position. If
				;	you want a line at the last position,
				;	put it as the second last value. Also,
				;	the first position cannot be a line.
				;
				;	Double byte values. Every second byte
				;	is the color.

		db	2,0b0h
		db	0,0b0h
		db	5,0b0h
		db	8,0b3h
		db	11,0b3h
		db	14,0b0h
		db	19,0b0h
	      ; db	22+80h,0b0h
		db	17,0b0h
		dw	0ffffh

				;TABEL: Help text pointers for each hex byte
				;	position.

		dw	SpFXins
		dw	SpFXins
		dw	SpFXarp
		dw	SpFXlvl
		dw	SpFXadd
		dw	SpFXdur
		dw	SpFXpoi
		dw	SpFXpoi
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SpFXins 	db	'XXXX³INSTRUMENT - Instrument used for this set.'
		db	'ÀÄÂÙ³Same values used as when using CXXX in the'
		db	'INST³seq. Add with 8000 for locked freq values.'

SpFXarp 	db	'XX³HALF NOTE VALUE - Signed byte, Use 00-7F for'
		db	'À´³positive add or FF-80 for negative. Added to'
		db	'HN³the actual note, unless locked mode is used.'

SpFXlvl 	db	'XX³MODULATOR LEVEL - Values 00-3F goes into the'
		db	"À´³instrument's 8th byte. If LV=FF, continue on"
		db	'LV³whatever value is currently present here.   '

SpFXadd 	db	'XX³MODULATOR LEVEL ADD - Signed byte. Use 00-7F'
		db	'À´³for positive or FF-80 for negative. Added to'
		db	"MA³the instrument's 8th byte each frame.       "

SpFXdur 	db	'XX³DURATION - Duration in frames (00-FF) of the'
		db	'À´³set. 00 is ONE frame. When done counting, it'
		db	'DR³jumps to the set specified in the next word.'

SpFXpoi 	db	'XXXX³POINTER - When the duration counter in the'
		db	'ÀÄÂÙ³previous byte has finished, this word will'
		db	'BXXX³tell which set to take next.              '
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Seq0		dw	1	;Length of sequence, in steps.

		dw	0f000h,0000h,0ffffh
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Seq1		 dw	 16
;
;		 dw	 01234h,000ch,0f000h,007eh,0f000h,007eh,0f000h,007eh
;		 dw	 0f000h,007eh,0f000h,007eh,0f000h,0000h,0f000h,0000h
;		 dw	 0f000h,0000h,0f000h,0000h,0f000h,0000h,0f000h,0000h
;		 dw	 0f000h,0000h,0f000h,0030h,0f000h,0000h,03333h,003ch
;		 dw	 0ffffh
;
;Seq2		 dw	 24
;
;		 dw	 04444h,0000h,05555h,0000h,0f000h,000dh,0f000h,0000h
;		 dw	 0f000h,0000h,0f000h,0000h,0d040h,0031h,0f000h,2032h
;		 dw	 0f000h,0000h,0f000h,0000h,0f000h,0000h,0f000h,000bh
;		 dw	 0f000h,0000h,0f000h,0000h,0f000h,0000h,01234h,0000h
;		 dw	 0f000h,0000h,0f000h,0000h,0f000h,0000h,0f000h,000bh
;		 dw	 0f000h,0000h,0f000h,0000h,0f000h,0000h,0abbah,0006h
;		 dw	 0ffffh
;
;Seq3		 dw	 2
;
;		 dw	 0f000h,0000h,0f000h,0000h,0ffffh
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Track0 	 dw	 800ch,1,800ch,2,8111h,1,8112h,3
;		 dw	 800ch,3,800ch,3,8000h,1,8000h,2
;		 dw	 800ch,1,800ch,2,8000h,1,8000h,2
;
;		 dw	 16 dup (0ffffh,0)
;
;Track1 	 dw	 8103h,3,8107h,3,8103h,2,8107h,1
;		 dw	 800ch,0,800ch,3,8000h,2,8000h,1
;		 dw	 800ch,2,800ch,1,8000h,0,8000h,2
;
;		 dw	 16 dup (0ffffh,0)
;
;Track2 	 dw	 8111h,2,8112h,2,8113h,2,8114h,3
;		 dw	 8115h,0,8116h,1,8117h,2,8118h,3
;		 dw	 8119h,2,811ah,3,811bh,0,811ch,2
;
;		 dw	 16 dup (0ffffh,0)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HelpPage        db      'EdLib ',EdVers,' rev 055, Copyright (C) 1992-1994, Jens-Christian Huus.',0ah,0ah,0dh

	       IF DEMO

		db	'Note that this is a DEMO version only - you cannot save or convert any music.',0ah,0ah,0dh

	       ENDIF

		db	'Usage: EDLIB [<Switches>] [<Name of EDL file>]',0ah,0ah,0dh

		db	'               -f      Use followplay immediately.',0ah,0dh
		db	'               -p      Do not fade colors when quitting.',0ah,0dh
		db	'               -c      Convert EDL to D00 (NOT READY YET).',0ah,0dh
                db      '               -m      Use the MPU-401 interface.',0ah,0dh
                db      '               -a      Ignore AdLib detection.',0ah,0dh

		db	24h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BarColBuffer	db	80 dup (0) ;TABLE: Which colors were at the BAR pos.

CreditTxt1      db      2,2,0bah,'Şßß  üı ÑØ  ',0
CreditTxt2      db      3,2,0bah,'Şß Şßıı ŞŞßİ',0
CreditTxt3      db      4,2,0bah,'ŞÛÛŞÛıÛÛŞŞÛİ',0

CreditTxt1b	db	2,15,0b0h,'     ...by JCH',0
CreditTxt2b	db	3,15,0b0h,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',0
CreditTxt3b     db      4,15,0b0h,EdVers,' rev 055',0

CreditTxt4	db	2,67,0b0h
CredCard	db	'??? v'
CredVers	db	'??.??',0
CreditTxt5	db	3,67,0b0h,'ÄÄÄÄÄÄÄÄÄÄ',0
CreditTxt6	db	4,67,0b0h,'Time 00:00',0

MiddleTxt1	db	2,32,0b0h,'Name.........................N/A',0
MiddleTxt2	db	3,32,0b0h,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',0
MiddleTxt3	db	4,32,0b0h,'Composer.....................N/A',0

Notes		db	'C-C#D-D#E-F-F#G-G#A-A#B-'

Hexv		db	'0123456789ABCDEF'

;Text1		 db	 44,0,0b0h,80h,'ÚÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓË',219,'ÚÓÓÓÓÓÓÓÓÕÓÓÓÓÓÓÓÓÕÓÓÓÕÓÓÓË',219,219
;		 db		   219,'Ñ                                               Ì',219,'ÑIrq:    ºRtJ:    º   º   Ì',219,219
;		 db		   219,'Ñ                                               Ì',219,'ÒÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÊÍÍÍÎ',219,219
;		 db		   219,'Ñ                                               Ì',219,'ÑSpd:    ºSpI:    º   ºOc Ì',219,219
;		 db		   219,'ÆĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞÇ',219,'ÆĞĞĞĞĞĞĞĞÏĞĞĞĞĞĞĞĞÏĞĞĞÏĞĞĞÇ',219,219,0

;Text1		 db	 44,0,0b0h,80h,'ÚÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓË',219,'ÚÓÓÓÓÓÓÓÓË',212,'ÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓË',219,219
;		 db		   219,'Ñ                                               Ì',219,'ÑIrq:    Ì',212,' RtJ:     º    Ì',219,219
;		 db		   219,'Ñ                                               Ì',219,'ÑÄÄÄÄÄÄÄÄÌ',212,' ÄÄÄÄÄÄÄÄ º ÄÄÄÌ',219,219
;		 db		   219,'Ñ                                               Ì',219,'ÑSpd:    Ì',212,' SpI:     º Oc Ì',219,219
;		 db		   219,'ÆĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞÇ',219,'ÆĞĞĞĞĞĞĞĞÇ',212,'ĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞÇ',219,219,0

BotTxt1 	db	45,52,0b0h,'Irq:    ',80h,80h,80h,'RtJ:    ',0
BotTxt2 	db	46,52,0b0h,'ÄÄÄÄÄÄÄÄ',80h,80h,80h,'ÄÄÄÄÄÄÄÄ',80h,80h,80h,'ÄÄÄ',0
BotTxt3 	db	47,52,0b0h,'Spd:    ',80h,80h,80h,'SpI:    ',80h,80h,80h,'Oc',0

ScreenPatch	db	28,0,0b0h,80h,'ÚÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓÓË',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ä                                                                           Ì',212,80h
		db		  80h,'ÆĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞÇ',212,80h,0

Text8		db	5,80,08h,80 dup (223),0
Text9		db	49,2,08h,77 dup (220),0
Text10		db	44,50,08h,214,27 dup (80h),214,0dbh,0dbh
		db	49 dup (80h),212,27 dup (80h),212,0dbh,0dbh
		db	49 dup (80h),212,27 dup (80h),212,0dbh,0dbh
		db	49 dup (80h),212,27 dup (80h),212,0dbh,0dbh
		db	49 dup (80h),212,27 dup (80h),212,0dbh,0dbh
		db	49 dup (80h),215,219,26 dup (80h),215,0
Text17		db	42,80,08h,80 dup (220),0

HelpText	db	'                             EdLib HELP pages                              '
		db	'                             ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                              '
		db	'                                                                           '
		db	'Key            Description                                                 '
		db	'ÄÄÄ            ÄÄÄÄÄÄÄÄÄÄÄ                                                 '
		db	'                                                                           '
		db	'F1             Play normally from StartPoint position.                     '
		db	'F2             Stop all music activity.                                    '
		db	'F3             FollowPlay from StartPoint position.                        '
		db	'F4             Set new StartPoint position.                                '
		db	'F5             Copy any sequence into the currently edited sequence.       '
		db	'F6             Decrease the tune speed.                                    '
		db	'F7             Increase the tune speed.                                    '
		db	'F8             Define new SuperInsert size.                                '
		db	'F9             Execute the SuperInsert in a sequence.                      '
		db	'F10            Goto any stepcounter line.                                  '
		db	'F11            Define new RhythmJump value.                                '
		db	'F12            Load music in EDL format.                                   '
		db	'                                                                           '
		db	'Shift F1       Clear all tracks and sequences.                             '
		db	'Shift F2       Clear instruments and SpFX tables.                          '
		db	'Shift F5       Copy any sequence into another sequence.                    '

	       IF DEMO
		db	'Shift F12      Save music in EDL format (NOT AVAILABLE IN THIS DEMO).      '
	       ELSE
		db	'Shift F12      Save music in EDL format.                                   '
	       ENDIF

		db	'                                                                           '
		db	'Ctrl F1        Decrease the IRQ timer speed.                               '
		db	'Ctrl F2        Increase the IRQ timer speed.                               '
		db	'Ctrl F3        Load music in EDL format.                                   '

	       IF DEMO
		db	'Ctrl F4        Save music in EDL format (NOT AVAILABLE IN THIS DEMO).      '
	       ELSE
		db	'Ctrl F4        Save music in EDL format.                                   '
	       ENDIF

	       IF DEMO
		db	'Ctrl F5        Convert music to D00 and save (NOT AVAILABLE IN THIS DEMO). '
	       ELSE
		db	'Ctrl F5        Convert the music to D00 format and save it.                '
	       ENDIF

		db	'Ctrl F6        Define new tune speed.                                      '
		db	'Ctrl F7        Define new tune speed.                                      '
		db	'Ctrl F9        Input music name in top of screen.                          '
		db	'Ctrl F10       Input composer name in top of screen.                       '
		db	'                                                                           '
		db	'M              Enter instrument table.                                     '
		db	'K              Enter SpFX table.                                           '
		db	'L              Toggle between instrument and SpFX tables.                  '
		db	'                                                                           '
		db	'Alt Down       Change main volume byte below the current voice.            '
		db	'Alt Up         Change logical voice number above the current voice.        '
		db	'                                                                           '
		db	'Ctrl           Fast forward while in FollowPlay mode.                      '
		db	'                                                                           '
		db	'Alt 1-9        Toggles voices 1-9 ON or OFF.                               '
		db	'Alt Tab        Turn all voices OFF except the edited voice.                '
		db	',              Turn all voices ON.                                         '
		db	'.              Turn all voices OFF.                                        '
		db	'-              Toggle current voice ON or OFF.                             '
		db	'                                                                           '
		db	'Q2W3ER5...     Keyboard play in note column or instrument/SpFX tables.     '
		db	'                                                                           '
		db	'Spacebar       Erase sequence command or put a REST in note column.        '
		db	'X/C/V          Put a HOLD (continue) in the note column.                   '
		db	'Z              HOLD to the previous note, REST to the next note.           '
		db	'«              Toggle tienote ON or OFF.                                   '
		db	'Enter          Switch between track editing or sequence editing.           '
                db      '               Also used to edit names in the instrument table.            '
		db	'Tab            Jump to the right voice.                                    '
		db	'Ctrl Tab       Jump to the left voice.                                     '
		db	'Q              Enter the next unused sequence number in the track.         '
		db	'                                                                           '
		db	'///        Cursor keys, used globally in the editor.                   '
		db	'Home/End       Used globally in the editor.                                '
		db	'Delete         Delete in track or sequence mode.                           '
		db	'Insert         Insert in track or sequence mode.                           '
		db	'ESC            Exits modes, also stops the music.                          '
		db	'Page Up/Down   Used globally in the editor.                                '
		db	'Ctrl Up        Increase the note octave.                                   '
		db	'Ctrl Down      Decrease the note octave.                                   '
		db	'Ctrl Pg Up     Home to the absolute top.                                   '
		db	'Ctrl Pg Down   Home to the absolute bottom.                                '
		db	'                                                                           '
		db	'S              Toggle CPU rastertime ON or OFF.                            '
		db	'                                                                           '
		db	'Ctrl Break     Exit to DOS.                                                '
		db	'                                                                           '
		db	'                                                                           '
		db	'                           MIDI keyboard mode                              '
		db	'                           ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                              '
		db	'                                                                           '
		db	' If you have a MPU-401 interface (or compatible) attached,  you can use it '
		db	' with a synth  keyboard to  play all instruments or SpFX sounds. This will '
		db	' work everywhere in the editor. By cursoring up and down in the instrument '
		db	' or SpFX tables you can choose which  instrument to play on the synth. You '
		db	' can  use aftertouch to test  vibrato on the instrument, and full velocity '
		db	' is available too. Note that if any sounds get stuck (Eg, if an instrument '
		db	' with an infinite release value is triggered) you can press F2 to stop the '
		db	' sound in all voices. All playing will of course be polyfonic.             '
		db	'                                                                           '
		db	0

WaitText	db	10,'Press any key to continue...',10,13,24h

ConfirmTxt1	db	22,25,0dfh,'          WARNING!           ',0
ConfirmTxt2	db	24,25,0d9h,'This song has NOT been saved.',0
ConfirmTxt3	db	25,25,0d9h,'    Are you sure (Y/N) ?     ',0

ExistsTxt1	db	22,21,0dfh,'              WARNING!                ',0
ExistsTxt2	db	24,21,0d9h,'This file already exists. Are you sure',0
ExistsTxt3	db	25,21,0d9h,'  you want to overwrite it (Y/N) ?   ',0

IF DEMO

NATxt1		db	22,25,0dfh,'      DEMO VERSION ONLY!      ',0
NATxt2		db	24,25,0d9h,'  The requested function is   ',0
NATxt3		db	25,25,0d9h,'NOT available in this version.',0
NATxt4		db	27,25,0dfh,'    Press any key to exit.    ',0

ENDIF

CompTxt1	db	22,21,08fh,'          Input composer name         ',0
CompTxt2	db	24,21,089h,'  Please keep the string towards the  ',0
CompTxt3	db	25,21,089h,'   left boundary, do NOT center it.   ',0
CompTxt4	db	27,21,08fh,'    Composer:                         ',0

NameTxt1	db	22,21,08fh,'        Input name of the music       ',0
NameTxt2	db	24,21,089h,'  Please keep the string towards the  ',0
NameTxt3	db	25,21,089h,'   left boundary, do NOT center it.   ',0
NameTxt4	db	27,21,08fh,'      Name:                           ',0

AboutTxt1       db      23,22,089h,'       Coded in 1992-1994 by       ',0
AboutTxt2       db      24,22,089h,'  Jens-Christian Huus / Vibrants.  ',0
AboutTxt3       db      26,22,08fh,' Press ALT-F1 at any time for help.',0

ErrorTxt1       db      22,22,0dfh,'            FILE ERROR!            ',0
ErrorTxt2	db	24,22,0d9h,'  The file operation could not be  ',0
ErrorTxt3	db	25,22,0d9h,'successfully completed. DOS reports',0
ErrorTxt4	db	26,22,0d9h,'       the following error:        ',0
ErrorTxt5	db	30,22,0d9h,'      Press any key to abort.      ',0

ErrorPointers	dw	Err00,Err01,Err02,Err03,Err04,Err05,Err06,Err07,Err08
		dw	Err09,Err10,Err11,Err12
		dw	32 dup (Err00)

		el=28
		ec=22

Err00		db	el,ec,0dfh,'    "Nothing should be wrong!?"    ',0
Err01		db	el,ec,0dfh,'     "Function number invalid"     ',0
Err02		db	el,ec,0dfh,'         "File not found"          ',0
Err03		db	el,ec,0dfh,'         "Path not found"          ',0
Err04		db	el,ec,0dfh,'       "No handle available"       ',0
Err05		db	el,ec,0dfh,'          "Access denied"          ',0
Err06		db	el,ec,0dfh,'         "Invalid handle"          ',0
Err07		db	el,ec,0dfh,' "Memory control blocks destroyed" ',0
Err08		db	el,ec,0dfh,'       "Insufficient memory"       ',0
Err09		db	el,ec,0dfh,'  "Invalid memory block address"   ',0
Err10		db	el,ec,0dfh,'       "Invalid environment"       ',0
Err11		db	el,ec,0dfh,'         "Invalid format"          ',0
Err12		db	el,ec,0dfh,'        "Open mode invalid"        ',0

FileTxt1	db	9,0,0b0h,'LOAD or SAVE',0
FileTxt2	db	40,0,0b0h,'    ',0

LoadingText	db	23,29,89h,'LOADING - please wait.',0
SavingText	db	23,30,89h,'SAVING - please wait.',0

Copy1Text	db	23,18,89h,'Overwrite current sequence with number ?     ',0
Copy2Txt1	db	22,28,8fh,'Copy sequence to sequence',0
Copy2Txt2	db	24,28,89h,' From ?                  ',0
Copy2Txt3	db	24,41,89h,'- To ?      ',0
SpeedText	db	23,26,89h,'Define new tune speed ?     ',0
InsertText	db	23,26,89h,'New SuperInsert value ?     ',0
RhythmText	db	23,26,89h,'New RhythmJump value ?     ',0
GotoText	db	23,29,89h,'Goto which line ?     ',0

RestText	db	'REST'
HoldText	db	'HOLD'

ClearHelp	db	'                                               '
		db	'                                               '
		db	'                                               '
					       ;;
Column1 	db	'Player commands³7XYY-Vibrato ON³CXXX-Instrument'
		db	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´90XX-Lvls 00-3F³DXXX-Slide  ON'
		db	'6000-Cut/Lvl 00³BXXX-SpFX sound³EXXX-Slide  ON'
				       ;;	       ;;
Column2 	db	'Type notes with QWERTY keys, press CTRL / for'
		db	'octaves. The «-key toggles tienote ON/OFF. Hold'
		db	'notes with Z or X/C/V, release them with SPACE.'

TrackTxt	db	'Track commands in words³8XYY????-X=Dir,Y=Transp'
		db	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´FFFFXXXX-Go to pos XXXX'
		db	'????YYYY-Seqs 0000-0FFF³FFFE????-Stop the track'

ConvExt 	db	'.d00',0

Composer	db	32 dup (20h)
TuneName	db	32 dup (20h)
ConvertName	db	9 dup (20h)

DSR=080h				;Constants used by MIDI routines.
DRR=040h
ACK=0feh

DataPort	dw	0330h		;Ports used by the MPU-401 interface.
LABEL ComPort	WORD
StatPort	dw	0331h

SeqWhere	dw	256 dup (0)	;Used at late seq's in top of screen.
YSeqWhere	dw	256 dup (0)	;Twin variable's used under FollowPlay.
TrackCountRes	dw	256 dup (0)	;Position in track table.
YTrackCountRes	dw	256 dup (0)	;Twin variable's used under FollowPlay.
FirstSeqLen	dw	256 dup (0)	;Holds length of the 1st seq on screen.
YFirstSeqLen	dw	256 dup (0)	;Twin variable's used under FollowPlay.
VoicePos	dw	256 dup (0)	;Pos of voice (Track & Seq) on screen.
AllVoiceCol	db	256 dup (0)	;Position of cursor columns for voices.
XVoiceFlags	db	256 dup (0)	;Current state of voice ON/OFF flags.

XSeqWhere	dw	0	;Twin variable used when printing voice.
XFirstSeqLen	dw	0	;Twin variable used when printing voice.
SeqCounter	dw	0	;Keeps track of the sequences length.
ScreenPos	dw	0	;Used when plotting sequences to screen.
ScreenAdd	dw	0	;Used to align sequences properly on screen.
TrackCount	dw	0	;Real-time position in track table.
TrackPos	dw	0	;Used to plot correctly on screen.
LineCount	dw	0	;Makes sure "LINES" are used properly.
IntTrackCount	dw	0	;Which sequence number is "IntWhere" in.
YIntTrackCount	dw	0	;Twin variable used under FollowPlay.
IntWhere	dw	0	;Where the cursor really is inside the sequence.
YIntWhere	dw	0	;Twin variable used under FollowPlay.
IntByte 	dw	0	;Same as above, but with BYTE precision.
YIntByte	dw	0	;Twin variable used under FollowPlay.
Old09Adr	dw	0	;Adress of normal INT 09h routine (not used).
Old09Seg	dw	0	;Segment of normal INT 09h routine (not used).
CurRow		db	0	;Row on screen where the cursor is.
CurCol		db	0	;Column on screen where the cursor is.
CurLineCount	dw	0	;Makes sure the cursor stays within top/bottom.
StepCount	dw	0	;Step counter value to the left of the screen.
YStepCount	dw	0	;Twin variable used under FollowPlay.
TempNoteCol	db	0	;Temporary color holder in a critical routine.
CurColCount	dw	0	;Keeps track of the cursors column within voice.
Octave		db	0	;Octave used when typing notes in column 2.
HoldRest	db	0	;Flag to tell the SpaceBar which mode to use.
MaxStepSeq	dw	0	;Maximum number of lines a sequence may eat.
Mode		db	0	;Flag to distinguish between Track and Seq mode.
TrackMove	db	0	;Flag to determine; go to last seq cursor pos.?
ShIntWhere	dw	0	;Twin variable used to remember old IntWhere.
HexCol		db	0	;Used to count columns in the HexInput routine.
HexInputVar	dw	0	;Remembers the last value typed in HexInput.
SeqSeg		dw	0	;Segment address of block with sequences.
TrackSeg	dw	0	;Segment address of block with tracks.
TrackVoice	dw	0	;Current track (= voice!) in use.
TempCol 	db	0	;Color AND for use at the end of track tables.
TrackSize	dw	0	;Maximum size of each track in memory.
Copy1Value	dw	0	;Seq-number to be copied into seq at cursor.
Copy2Source	dw	0	;Source sequence number to be copied into...
Copy2Dest	dw	0	; ...This destination sequence number.
Minimize	db	0	;Flag to tell PrintVoice to minimize printing.
PlayMode	db	0	;Flag to determine if the player is playing.
Handle		dw	0	;Handle, used when accessing files on disk.
VoiceNoFlag	db	0	;Voice no. in top only needs to be printed once.
VolumeFlag	db	0	;Volumes below only needs to be printed once.
FollowWait	db	0	;Keeps FollowPlay at a reasonable speed.
StartPoint	dw	0	;Equals StepCount when F4 is pressed.
SpeedVar	dw	0	;Holds the current tune-speed.
Patch		db	0	;Determines if an extra screen-patch is present.
WhichPatch	db	0	;Information about which Window-screen is up.
ScrollTemp	dw	0	;Backup of ScrollBorder value.
InsideTable	db	0	;Flag to determine if a table is being edited.
TempAH		db	0	;Temporary storage for key value from tables.
CallExternal	db	0	;Check to see if it is time to do other keys.
Touched 	db	0	;Flag to determine if the song is unsaved.
Rast		db	0	;Flag for showing rastertime or not.
BreakState	db	0	;State of BREAK flag, ON or OFF.
FastOn		db	0	;Flag to see if fast forward mode is ON.
Psp		dw	0	;Position of the current PSP.
WhichTable	db	0	;Flag to determine which table is being edited.
Chk		db	0	;Flag to tell Print/Window to sub if patch ON.
ExtLoadNow	db	0	;Flag which is set when prompt load is wanted.
FolNow		db	0	;Flag for forcing followplay from the prompt.
HelpPos 	dw	0	;Line position in the help text block.
FollowFirst	db	0	;Flag for timing FollowPlay perfectly.
FadeDown	db	0	;Flag to tell FadeOut to run when quitting.
ResetInstr	db	0	;Flag to see if instrument table is a "virgin".
ResetExtra	db	0	;Flag to see if extra table is a "virgin".
KeyStatus	db	0	;Key value from IN port in new INT 09h handler.
KeyON		db	0	;Flag to check if a note is gated ON or OFF.
MPU_Flag	db	0	;Flag to tell MIDI routines to run or not.
AboutNow        db      0       ;Flag to see if the "about" text may be printed.

TempWord1	dw	0	;Used in routines where registers runs out...
TempWord2	dw	0
TempWord3	dw	0
TempWord4	dw	0
TempByte1	db	0
TempByte2	db	0
TempByte3	db	0

NewPalette	db 00,00,00	;0 Black.
		db 51,32,36	;1 Bright red.
		db 43,39,63	;2 Bright sky blue.
                db 10,15,20     ;3 Almost black.        38,34,51   58,48,30
                db 45,62,48     ;4 Bright green.        36,63,00
		db 31,39,36	;5 Dim green.
		db 25,25,30	;6 Brighter dark grey.
		db 30,30,36	;7 Middle grey.
		db 19,19,26	;8 Dark grey.
		db 63,59,36	;9 Bright yellow.
                db 51,47,36     ;A Normal ye1low.       51,47,36
		db 38,35,36	;B Dim yellow.
		db 22,19,35	;C Dark blue.
		db 35,19,27	;D Dark red.
		db 39,39,45	;E Light grey.
		db 57,57,63	;F White.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NumChars	=	24

WhatChars	db	211,218,203,204,213,205,206,186,202,207,208,199,198,228
		db	210,212,214,215,216,200,201,209,253,252

NewChars	db	11111111b	;211, Upper line.
		db	11111111b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b

		db	11111111b	;218, Upper left corner.
		db	11111111b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b

		db	11111111b	;203, Upper right corner.
		db	11111111b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b

		db	00000011b	;204, Right line.
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b

		db	11111111b	;213, Upper split line.
		db	11111111b
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b

		db	00000000b	;205, Middle horizontal line.
		db	00000000b
		db	00000000b
		db	11111111b
		db	11111111b
		db	00000000b
		db	00000000b
		db	00000000b

		db	00000011b	;206, Middle to right line.
		db	00000011b
		db	00000011b
		db	11111111b
		db	11111111b
		db	00000011b
		db	00000011b
		db	00000011b

		db	00011100b	;186, Middle vertical line.
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b

		db	00011100b	;202, Cross.
		db	00011100b
		db	00011100b
		db	11111111b
		db	11111111b
		db	00011100b
		db	00011100b
		db	00011100b

		db	00011100b	;207, Lower split line.
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b
		db	00011100b
		db	11111111b
		db	11111111b

		db	00000000b	;208, Lower line.
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111111b
		db	11111111b

		db	00000011b	;199, Lower right corner.
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	11111111b
		db	11111111b

		db	11100000b	;198, Lower left corner.
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11111111b
		db	11111111b

		db	11100000b	;228, Lower left corner.
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b
		db	11100000b

		db	11100000b	;210, Middle to left line.
		db	11100000b
		db	11100000b
		db	11111111b
		db	11111111b
		db	11100000b
		db	11100000b
		db	11100000b

		db	00000011b	;212, Right vertical shadow.
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b
		db	00000011b

		db	11111111b	;214, Right vertical shadow.
		db	11111111b
		db	11111111b
		db	11111111b
		db	11111111b
		db	00000011b
		db	00000011b
		db	00000011b

		db	00000011b	;215, Right vertical shadow.
		db	00000011b
		db	00000011b
		db	00000011b
		db	11111111b
		db	11111111b
		db	11111111b
		db	11111111b

		db	00000000b	;216, Top of "b" in "EdLib".
		db	00000000b
		db	00001111b
		db	00001111b
		db	00001111b
		db	00001111b
		db	00001111b
		db	00001111b

		db	00000011b	;200, Specialized shadow corner.
		db	00000011b
		db	00000011b
		db	00000011b
		db	11111111b
		db	00000000b
		db	00000000b
		db	00000000b

		db	11111111b	;201, Specialized shadow corner.
		db	11111111b
		db	11111111b
		db	11111111b
		db	11111111b
		db	00000000b
		db	00000000b
		db	00000000b

		db	00000000b	;209, The dot above the i.
		db	00000000b
		db	00001111b
		db	00001111b
		db	00001111b
		db	00001111b
		db	00000000b
		db	00000000b

		db	11111000b	;253, Slighty fatter line.
		db	11111000b
		db	11111000b
		db	11111000b
		db	11111000b
		db	11111000b
		db	11111000b
		db	11111000b

		db	00000000b	;252, Top of "d" in "EdLib".
		db	00000000b
		db	11111000b
		db	11111000b
		db	11111000b
		db	11111000b
		db	11111000b
		db	11111000b
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InstrName	db	'player\data.bin',0
InterfaceName	db	'player\interfac.bin',0
PlayerName	db	'player\player.bin',0

MusicName	db	'temp.edl',0

ExePara 	dw	16 dup (0)
ExePacker	db	'edlib.001',0
ExeUnpack	db	'edlib.002',0

EdlName 	db	64 dup (0)

RealName	db	'songs\'
FileName	db	16 dup (0)		;Modified by input routine.

AreaBuffer	db	7000 dup (?)		;For Amnesia/Cure routines.

InstrSeg	dw	0,0
Interface	dw	0,0	;There MUST be a zero'ed word before Interface.
Player		dw	0,0
WinBuffer	dw	0,0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LABEL Keys	WORD		;TABLE: Keys used / Jumps to key-actions.

		dw	0bh,TypeKey ;0 - Hexadecimal values.
		dw	02h,TypeKey ;1
		dw	03h,TypeKey ;2
		dw	04h,TypeKey ;3
		dw	05h,TypeKey ;4
		dw	06h,TypeKey ;5
		dw	07h,TypeKey ;6
		dw	08h,TypeKey ;7
		dw	09h,TypeKey ;8
		dw	0ah,TypeKey ;9
		dw	1eh,TypeKey ;A
		dw	30h,TypeKey ;B
		dw	2eh,HoldKey ;C
		dw	20h,TypeKey ;D
		dw	12h,TypeKey ;E
		dw	21h,TypeKey ;F

		dw	78h,AltNum  ;1 - Alt 1-9 toggles voice ON or OFF.
		dw	79h,AltNum  ;2
		dw	7ah,AltNum  ;3
		dw	7bh,AltNum  ;4
		dw	7ch,AltNum  ;5
		dw	7dh,AltNum  ;6
		dw	7eh,AltNum  ;7
		dw	7fh,AltNum  ;8
		dw	80h,AltNum  ;9

		dw	39h,SpaceBar

		dw	29h,SetTieNote	;Toggle a tie-note in column 2 («-key).

		dw	98h,AltUp	;Edit the voice number over the voice.
		dw	8dh,CtrlUp
		dw	91h,CtrlDown
		dw	74h,CtrlDown	;Ctrl Right Arrow.

		dw	2dh,TypeHold	;Put a HOLD (+++) in Column 2 (X).
		dw	2fh,TypeHold	;Put a HOLD (+++) in Column 2 (V).
		dw	3bh,F1Key	;Start music-player.
		dw	3ch,F2Key	;Stop music-player.
		dw	3dh,F3Key	;Start music-player with FollowPlay.
		dw	3eh,F4Key	;Define new StartPoint.
		dw	40h,F6Key	;Decrease tune speed.
		dw	41h,F7Key	;Increase tune speed.
		dw	63h,NewTuneSpd	;Input new tune speed (Ctrl-F6)
		dw	64h,NewTuneSpd	;Input new tune speed (Ctrl-F7)
		dw	5eh,TimerDown	;Decrease timer IRQ speed.
		dw	5fh,TimerUp	;Increase timer IRQ speed.
		dw	3fh,F5Key	;Copy a sequence into seq at cursor.
		dw	58h,ShF5Key	;Copy a sequence into another sequence.
		dw	42h,F8Key	;Define new SuperInsert value.
		dw	43h,F9Key	;SuperInsert function.
		dw	44h,F10Key	;Goto line number.
		dw	85h,F11Key	;Define new RhythmJump value.
		dw	86h,F12Key	;Load Track, Seq and Instr from disk.
		dw	60h,F12Key	;Same as above, but with Ctrl-F3.
		dw	88h,ShF12Key	;Save Track, Seq and Instr to disk.
		dw	61h,ShF12Key	;Same as above, but with Ctrl-F4.
		dw	54h,ClearTune	;Clear both Tracks and Seq's (Shift-F1)
		dw	2ch,SetRelease	;Set spot where HOLD goes into REST (Z).
		dw	28h,SwitchTable ;Open or close the Table-window (' / ›).
		dw	32h,InstrEdit	;Edit the Instrument table.
		dw	25h,ExtraEdit1	;Edit an additional table 1.
		dw	26h,ToggleTab	;Toggle between the two tables.
		dw	55h,ShF2Key	;Clear entire instrument segment.
		dw	1fh,ToggleRast	;Toggle rastertime ON or OFF (S).
		dw	10h,NextSeq	;Enter the next unused sequence (Q).
		dw	66h,CtrlF9	;Input the music name.
		dw	67h,CtrlF10	;Input composer name.

		dw	1ch,EnterKey	;Toggle between Track and Sequence.

		dw	50h,Down
		dw	48h,Up
		dw	4dh,Right
		dw	4bh,Left
		dw	51h,PageDown
		dw	49h,PageUp
		dw	47h,HomeKey
		dw	4fh,EndKey
		dw	53h,Delete
		dw	52h,Insert
		dw	01h,Escape

		dw	0fh,TabKey	;Go to the next voice.
		dw	94h,CtrlTab	;Go to the previous voice.

		dw	84h,CtrlPgUp	;Go to StepCount 0000 and enter the seq.
		dw	76h,CtrlPgDw	;Go to the end of ...ehrm... Song ?

		dw	68h,AltF1	;Help page controlled with cursor keys.

		dw	33h,VcON	;Turn all voices ON (Comma-key).
		dw	34h,VcOFF	;Turn all voices OFF (FullStop-key).
		dw	35h,VcToggle	;Toggle edited voice ON/OFF (Minus-key).
		dw	0a5h,AltTab	;Turn all voices OFF except the current.
		dw	0a0h,AltDown	;Edit main voice volume below the voice.
		dw	62h,CtrlF5	;Convert and save music as "D0x" file.

		dw	00h	;Indicates end of key-table.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LABEL NoteKeys	BYTE		;TABLE: Keys used for notes / Jumps to actions.

		db	10h ;Q - C
		db	03h ;2 - C#
		db	11h ;W - D
		db	04h ;3 - D#
		db	12h ;E - E
		db	13h ;R - F
		db	06h ;5 - F#
		db	14h ;T - G
		db	07h ;6 - G#
		db	15h ;Y - A
		db	08h ;7 - A#
		db	16h ;U - B

		db	17h ;I - C
		db	0ah ;9 - C#
		db	18h ;O - D
		db	0bh ;0 - D#
		db	19h ;P - E

		db	00h	;Indicates end of key-table.
ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT 	Code	PUBLIC 'Code'

		JUMPS

MACRO		Window	wdi,wbx,wsi,wdx,wal,wah ;X,Y,X,Y,Color,BackColor.

		mov	di,wdi
		mov	bx,wbx
		mov	si,wsi
		mov	dx,wdx
		mov	al,wal
		mov	ah,wah
		call	PrintWindow
ENDM

MACRO		Input	wbp,wdi,wbx,wax,wdl	;String,X,Y,Length,Color.

		lea	bp,[wbp]
		mov	di,wdi
		mov	bx,wbx
		mov	ax,wax
		mov	dl,wdl
		call	InputNow
ENDM

MACRO		ResES

		push	ax
		mov	ax,0b800h
		mov	es,ax
		pop	ax
ENDM
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Start:		cld

		mov	ax,Data
		mov	ds,ax

		mov	[Psp],es

		mov	bx,60000/16		;Size of main editor program.
		call	SetBlock
		jc	DosExit

		mov	bl,'?'                  ;Help page wanted?
		call	ExtSwitch
		jc	sta05

		lea	dx,[HelpPage]
		mov	ah,9
		int	21h

		mov	ax,4c00h
		int	21h
sta05:
                mov     bl,'m'                  ;Enable MPU-401 from prompt.
		call	ExtSwitch
                jnc     sta052
		mov	bl,'M'
		call	ExtSwitch
                jc      sta055
sta052:
		mov	[MPU_Flag],1

		mov	bl,0ffh 		;Initialize MPU-401 interface.
		call	MPU_Command
		jc	sta055
		mov	bl,03fh 		;Switch into UART mode.
		call	MPU_Command
		jnc	sta056
sta055:
		mov	[MPU_Flag],0
sta056:
		mov	[ExtLoadNow],0

		lea	di,[EdlName]
		call	ExtName 		;Get filename from prompt.
		jc	sta06

		mov	[ExtLoadNow],1
sta06:
		mov	[FolNow],0
                mov     [AboutNow],1

		mov	bl,'f'                  ;Force followplay immediately.
		call	ExtSwitch
		jnc	sta061
		mov	bl,'F'
		call	ExtSwitch
		jc	sta065
sta061:
		mov	[FolNow],1
                mov     [AboutNow],0
sta065:
		mov	[FadeDown],0

		mov	bl,'p'                  ;Do not fade down when quitting.
		call	ExtSwitch
		jnc	sta066
		mov	bl,'P'
		call	ExtSwitch
		jc	sta068
sta066:
		mov	[FadeDown],1
sta068:
		mov	bx,9000/16		;Size of window buffer.
		call	Allocate
		jc	DosExit
		mov	[WinBuffer],ax
		mov	bx,1000h		;64 kb for file segment.
		call	Allocate
		jc	DosExit
		mov	[cs:FindSeg],ax
		mov	bx,1000h		;Make space for track tables.
		call	Allocate
		jc	DosExit
		mov	[TrackSeg],ax
		mov	es,ax

		call	NoCursor
		call	Init
		call	ClearTrackSeg
		mov	[Patch],0
		mov	[WhichPatch],0
		mov	[Rast],0
		mov	[Lines],32
		mov	ax,[ScrollBorder]
		and	ax,15			;No higher than 15 possible.
		mov	[ScrollTemp],ax
		mov	[ScrollBorder],0
		mov	[HelpPos],offset HelpText

	      ; lea	si,[Track0]		;Copy test tracks.
	      ; xor	di,di
	      ; mov	cx,50
	      ; rep	movsw
	      ; lea	si,[Track1]
	      ; mov	di,[TrackSize]
	      ; mov	cx,50
	      ; rep	movsw
	      ; lea	si,[Track2]
	      ; mov	di,[TrackSize]
	      ; add	di,[TrackSize]
	      ; mov	cx,50
	      ; rep	movsw

		mov	bx,1000h		;Make space for sequence tables.
		call	Allocate
		jc	DosExit
		mov	[SeqSeg],ax
		mov	es,ax

		lea	si,[Seq0]		;Copy empty sequence no. 0000h.
		xor	di,di
		mov	cx,80h
		rep	movsw

		call	ClearSeqSeg

	      ; lea	si,[seq1]		;Copy test sequences.
	      ; mov	di,[SeqSize]
	      ; mov	cx,80h
	      ; rep	movsw
	      ; lea	si,[seq2]
	      ; mov	di,[SeqSize]
	      ; add	di,di
	      ; mov	cx,80h
	      ; rep	movsw
	      ; lea	si,[seq3]
	      ; mov	di,[SeqSize]
	      ; add	di,di
	      ; add	di,[SeqSize]
	      ; mov	cx,80h
	      ; rep	movsw

		mov	bx,1000h		;Make space for instruments.
		call	Allocate
		jc	DosExit
		mov	[InstrSeg],ax

		mov	bx,1024/16
		call	Allocate
		jc	DosExit
		mov	[Interface],ax
		mov	bx,8192/16
		call	Allocate
		jc	DosExit
		mov	[Player],ax

		mov	bx,[Interface]		;Load necessary files.
		lea	dx,[InterfaceName]
		call	Load
		mov	bx,[InstrSeg]
		lea	dx,[InstrName]
		call	Load
		mov	bx,[Player]
		lea	dx,[PlayerName]
		call	Load

                mov     di,[TrackSize]          ;Register for INIT player.

                mov     bl,'a'                  ;Force followplay immediately.
                call    ExtSwitch
                jnc     sta080
                mov     bl,'A'
                call    ExtSwitch
                jc      sta081
sta080:
                or      di,8000h                ;No AdLib detection wanted.
sta081:
		mov	es,[Player]		;Initialize the music-player.
		mov	bx,[InstrSeg]
		mov	cx,[TrackSeg]
		mov	dx,[SeqSeg]
		mov	bp,[SeqSize]
		mov	si,4*160+10		;Position of tune clock.
		xor	ah,ah
		call	[dword Interface-2]
		jnc	sta20
		call	WaitKey
		jmp	Quit
sta20:
		push	es			;Force timer IRQ to 70 times.
		mov	es,[InstrSeg]
		mov	[byte es:8],70
		pop	es

		call	SetTimerSpeed

		call	ClearInstrSeg

		call	DefaultSpeed

		call	IntOn

	      ; mov	ax,3300h		;Get BREAK state.
	      ; int	21h
	      ; mov	[BreakState],dl

		mov	ax,3301h		;Set BREAK to OFF.
		xor	dl,dl
		int	21h

		mov	bx,[SpeedVar]		;Prepare INTERFACE FollowTimer.
		mov	ah,3
		call	[dword Interface-2]

		call	ResetVoice		;Reset all voices after CONFIG.

		mov	ax,0003h
		int	10h

		mov	ax,1112h		;80 x 50 chars mode.
		xor	bl,bl
		int	10h

		mov	ax,ds			;Redefine a couple of chars.
		mov	es,ax
		mov	cx,NumChars
		xor	si,si
		lea	bp,[NewChars]
sta08:		push	cx si bp
		mov	ax,1110h
		mov	cx,1
		mov	dl,[WhatChars+si]
		mov	bx,0800h
		mov	dh,bl
		int	10h
		pop	bp si cx
		inc	si
		add	bp,8
		loop	sta08

		mov	ax,1003h		;No blinking colors.
		xor	bl,bl
		int	10h

		lea	di,[NewPalette] 	;Set up a new palette.
		call	Palette

		RESES

		xor	di,di			;Print background carpet.
		mov	ah,[BackColor]
		mov	al,0dbh
		mov	cx,80*6
		rep	stosw
		mov	di,160*44
		mov	cx,80*6
		rep	stosw

		xor	di,di			;Top line is halfed.
		mov	cx,80
		mov	al,0dch
		rep	stosw

	      ; xor	di,di			;Menu line in top.
	      ; mov	cx,80
	      ; mov	ah,0eh
	      ; mov	al,0dbh
	      ; rep	stosw
	      ; mov	al,211
	      ; mov	ah,[BackColor]
	      ; ror	ah,1
	      ; ror	ah,1
	      ; ror	ah,1
	      ; ror	ah,1
	      ; mov	cx,80
	      ; rep	stosw

	      ; mov	al,[FrameColor]
	      ; mov	[Text1+2],al
	      ; mov	[Text2+2],al
	      ; mov	[CreditText+2],al

	      ; lea	bx,[Text1]
	      ; call	Print
	      ; lea	bx,[Text8]
	      ; call	Print
	      ; lea	bx,[Text9]
	      ; call	Print
	      ; lea	bx,[Text10]
	      ; call	Print
		lea	bx,[Text17]
		call	Print

		mov	[cs:Top],1

		WINDOW	1,1,29,5,0bh,08h	;Top windows.
		WINDOW	31,1,64,5,0bh,08h
		WINDOW	66,1,77,5,0bh,08h

		mov	[cs:Top],0

		WINDOW	1,44,49,48,0bh,08h	;Bottom windows.
		WINDOW	51,44,60,48,0bh,08h
		WINDOW	62,44,71,48,0bh,08h
		WINDOW	73,44,77,48,0bh,08h

		lea	bx,[BotTxt1]
		call	Print
		lea	bx,[BotTxt2]
		call	Print
		lea	bx,[BotTxt3]
		call	Print

		RESES				;Plot special shadow chars.
		mov	al,200
		mov	ah,[BackColor]
		mov	[es:6*160+130],ax
		mov	[es:6*160+60],ax
		mov	al,201
		mov	[es:6*160+132],ax
		mov	[es:6*160+62],ax

		call	VoiceBorder

		call	SetupExe

		call	Init
		call	ResetSP
		call	Edge
		call	ClearVoiceArea

		call	GetVers

		lea	si,[Column1]
		call	Help

		lea	bx,[CreditTxt1]
		call	Print
		lea	bx,[CreditTxt2]
		call	Print
		lea	bx,[CreditTxt3]
		call	Print
		lea	bx,[CreditTxt1b]
		call	Print
		lea	bx,[CreditTxt2b]
		call	Print
		lea	bx,[CreditTxt3b]
		call	Print
		lea	bx,[CreditTxt4]
		call	Print
		lea	bx,[CreditTxt5]
		call	Print
		lea	bx,[CreditTxt6]
		call	Print
		lea	bx,[MiddleTxt1]
		call	Print
		lea	bx,[MiddleTxt2]
		call	Print
		lea	bx,[MiddleTxt3]
		call	Print
GoMain:
		call	Cursor
Main:
		cmp	[InsideTable],0
		jne	Other
		RESES
	      ; mov	bl,[StepLine]
	      ; add	bl,[SkillSpace]
	      ; xor	bh,bh
	      ; call	VertLine
		call	NewVertLine
		call	StepCounter

		mov	cx,[Visible]
		xor	bx,bx
ma20:		mov	[Minimize],1
		mov	dx,[VoiceOrder+bx]
		mov	ax,bx
		shr	ax,1
		cmp	ax,[TrackVoice]
		jne	ma25
		mov	[Minimize],0
ma25:		call	PrintVoice
		inc	bx
		inc	bx
		loop	ma20
		call	ColorBar
Other:
		RESES
		call	PrintOctave
		call	PrintInt		;Prints internal variables.
	      ; call	PrintHoldRest

		call	PromptLoad

		cmp	[FolNow],0		;Force followplay from prompt.
		jz	ot08
		mov	[FolNow],0
		jmp	F3key
ot08:
                cmp     [AboutNow],0
                jz      ot09
                jmp     AboutText               ;Time for a little egotrip!
ot09:
		mov	es,[SeqSeg]

		cmp	[InsideTable],0
		jz	ot11
		cmp	[CallExternal],0
		jz	ContEdit
                mov     [CallExternal],0
		mov	ah,[TempAH]
		jmp	short kl20
ot11:
		cmp	[PlayMode],2
		jz	FollowPlay
KeyLoop:
		cmp	[CurColCount],80h
		jne	kl13
		call	Keyboard		;Play on the "QWERTY" keyboard.
kl13:
		call	Key			;Remember it WAITS for a key !
		or	ah,ah
		jz	GetOut			;Ctrl-Break, exit editor.
kl20:
		xor	di,di
		cmp	[InsideTable],0
		jne	kl30
		cmp	[CurColCount],80h
		jz	NoteKeyLoop
kl30:		cmp	ah,[byte Keys+di]
		jz	kl40
		add	di,4
		cmp	[byte Keys+di],0
		jne	kl30
		cmp	[InsideTable],0
		jz	KeyLoop
		jmp	ContEdit
kl40:		mov	bx,[Keys+di+2]
		jmp	bx
NoteKeyLoop:
		cmp	ah,[NoteKeys+di]	;Check for notes to column 2.
		jz	TypeNote
		inc	di
		cmp	[NoteKeys+di],0
		jne	NoteKeyLoop
		xor	di,di
		jmp	short kl30
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TypeKey:					;Type Hex...
		call	Changed

		shr	di,1
		shr	di,1

		cmp	[Mode],0
		jz	ty80
ty10:						;1) Type hex in the track.
		mov	bx,[IntTrackCount]
		call	GetSeqNumber
		mov	[TempWord1],ax

		mov	cl,0f0h 		;AND-mask.
		mov	dx,di
		mov	bx,[CurColCount]
		cmp	bx,4
		jb	ty13
		dec	bx
ty13:		shr	bl,1
		jc	ty30
		shl	dl,1			;High nibble is manipulated.
		shl	dl,1
		shl	dl,1
		shl	dl,1
		mov	cl,0fh
ty30:
		mov	si,[IntTrackCount]
		xor	ah,ah
		mov	al,[TrackBytePos+bx]
		add	si,ax
		push	es
		mov	es,[TrackSeg]
		mov	al,[es:si]
		and	al,cl
		or	al,dl
		mov	[es:si],al
		pop	es

		mov	bx,[IntTrackCount]	;Was a new sequence typed ?
		call	GetSeqNumber
		cmp	ax,[TempWord1]
		jz	Right
		mov	[TrackMove],0
		jmp	Right
ty80:						;2) Type hex in the sequence.
		cmp	[CurColCount],80h
		jz	CheckSpecial		; ...but not in column 2.

		mov	bx,[IntTrackCount]
		call	GetSequence
		inc	bx			;Get past SeqLength info.
		inc	bx

		push	bx
		mov	ah,08h			;Check for blank character...
		xor	bh,bh
		int	10h
		pop	bx
		cmp	al,[Col1Blank]
		jne	ty200
		mov	si,[IntByte]		;Fill entire column 1 with "0".
		mov	cl,[Col1Jump]
		xor	ch,ch
ty100:		mov	[byte es:bx+si],00h
		inc	si
		loop	ty100
ty200:
		push	bx
		mov	cl,0f0h 		;AND-mask.
		mov	dx,di
		mov	bx,[CurColCount]
		shr	bl,1
		jc	ty300
		shl	dl,1			;High nibble is manipulated.
		shl	dl,1
		shl	dl,1
		shl	dl,1
		mov	cl,0fh
ty300:
		mov	si,[IntByte]
		xor	ah,ah
		mov	al,[Col1BytePos+bx]
		pop	bx
		add	si,ax
		mov	al,[es:bx+si]
		and	al,cl
		or	al,dl
		mov	[es:bx+si],al
		jmp	Right
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CheckSpecial:					;Check for hex keys used double.
		cmp	ah,2eh
		jz	AlterSpace
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TypeNote:					;Type a note in column 2.
		call	Changed

		mov	bx,[IntTrackCount]
		call	GetSequence
		inc	bx			;Get past SeqLength info.
		inc	bx

		mov	dx,di			;Calculate correct note value.
		mov	al,[Octave]
		mov	cl,12
		mul	cl
		add	dl,al
		cmp	dl,78h
		jb	tn20
		sub	dl,78h
tn20:
		mov	al,[Col1Jump]		;Put note byte into sequence.
		add	al,[Col2NotePos]
		xor	ah,ah
		add	ax,[IntByte]
		mov	si,ax
		mov	al,[es:bx+si]
		mov	cl,[Col2NoteMask]
		xor	cl,0ffh
		and	al,cl			;Only touch what is "allocated"!
		or	al,dl
		mov	[es:bx+si],al

		mov	al,[TiePos]		;Unmask tie-note ID-bits.
		and	al,7fh
		xor	ah,ah
		add	ax,[IntByte]
		test	[TiePos],10000000b
		jz	tn40
		mov	cl,[Col1Jump]
		xor	ch,ch
		add	ax,cx
tn40:		mov	si,ax
		mov	cl,[TieMaskValue]
		xor	cl,0ffh
		mov	al,[es:bx+si]
		and	al,cl
		mov	[es:bx+si],al
Rhythm:
		mov	cx,[RhythmJump] 	;Do the Rhythm Jump.
		jcxz	Main
		push	cx
		call	EraseBar
		pop	cx
tn50:
		mov	ax,[ScrollTemp]
		mov	[ScrollBorder],ax
		call	MainDown
		call	FixCursor
		loop	tn50
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetTieNote:					;Toggle tie-note in column 2.
		call	Changed

		cmp	[Mode],0
		jne	Other
		cmp	[InsideTable],0
		jne	Other

		mov	bx,[IntTrackCount]
		call	GetSequence
		inc	bx			;Get past SeqLength info.
		inc	bx

		mov	al,[TiePos]		;Toggle tie-note ID-bits.
		and	al,7fh
		xor	ah,ah
		add	ax,[IntByte]
		test	[TiePos],10000000b
		jz	st40
		mov	cl,[Col1Jump]
		xor	ch,ch
		add	ax,cx
st40:		mov	si,ax
		mov	al,[es:bx+si]
		and	al,[TieMaskValue]
		cmp	al,[TieMaskValue]
		jne	st50
		mov	cl,[TieMaskValue]	;Erase tie-note command.
		xor	cl,0ffh
		mov	al,[es:bx+si]
		and	al,cl
st60:		mov	[es:bx+si],al
		jmp	Rhythm
st50:		mov	al,[es:bx+si]		;Put a tie-note command.
		or	al,[TieMaskValue]
		jmp	short st60
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EnterKey:					;1) Toggle between Track/Seq.
		cmp	[InsideTable],0
		jne	Other

		call	EraseBar

		mov	al,[Mode]
		xor	al,1
		mov	[Mode],al
		or	al,al
		jz	GoSeq
GoTrack:
		mov	[TrackMove],1
		mov	ax,[IntWhere]		;Save old sequence pointer.
		mov	[ShIntWhere],ax
gt100:
		cmp	[IntWhere],0
		jz	gt200
		call	MainUp			;Cursor to start of sequence.
		jmp	short gt100
gt200:
		call	GetVoiceCol		;Put cursor on the track.
		add	al,[TrackCurGoto]
		mov	[CurCol],al

		mov	al,[TrackCurGoto]	;Set it on a defined position.
		xor	ah,ah
		mov	[CurColCount],ax
		call	Cursor
		lea	si,[TrackTxt]
		call	Help
		jmp	Main
GoSeq:
		cmp	[TrackMove],0
		jz	gs200
		mov	cx,[ShIntWhere] 	;Put cursor in seq on old place.
		jcxz	gs200
gs100:		call	MainDown
		loop	gs100
gs200:
		call	HomeSeq

		lea	si,[Column1]
		call	Help

		mov	[CurColCount],0
gs210:
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SpaceBar:					;1) Erase Command in column 1.
		call	Changed

		cmp	[Mode],0
		jne	Other
		cmp	[InsideTable],0
		jne	Other

		mov	bx,[IntTrackCount]
		call	GetSequence
		inc	bx			;Get past SeqLength info.
		inc	bx

		cmp	[CurColCount],80h
		jz	sb30

		mov	si,[IntByte]		;Put blank space value in col 1.
		xor	di,di
		mov	cl,[Col1Jump]
		xor	ch,ch
sb20:		mov	al,[Col1BlankValues+di]
		mov	[es:bx+si],al
		inc	si
		inc	di
		loop	sb20
		jmp	Main
sb30:						;2) Put a REST in column 2.
		xor	ah,ah
		mov	dx,[IntByte]

		call	PutRest
		jmp	Rhythm
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HoldKey:					;First see if in column 2.
		push	ax di

		call	Changed

		cmp	[Mode],0
		jne	NoHold
		cmp	[InsideTable],0
		jne	NoHold

		mov	bx,[IntTrackCount]
		call	GetSequence
		inc	bx			;Get past SeqLength info.
		inc	bx

		cmp	[CurColCount],80h	;See if the column is right.
		jz	tho20
NoHold:
		pop	di ax			;No, proceed with TypeKey then.
		jmp	TypeKey
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TypeHold:					;2) Put a HOLD in column 2.
		call	Changed

		cmp	[Mode],0
		jne	Other
		cmp	[InsideTable],0
		jne	Other

		mov	bx,[IntTrackCount]
		call	GetSequence
		inc	bx			;Get past SeqLength info.
		inc	bx

		cmp	[CurColCount],80h	;See if the column is right.
		jne	Other
tho20:
		xor	ah,ah
		mov	dx,[IntByte]

		call	PutHold
		jmp	Rhythm
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Down:
		call	EraseBar

		cmp	[Mode],0
		jz	do200
do100:						;1) Move cursor down in track.
		mov	[TrackMove],0
		mov	bx,[IntTrackCount]
		call	GetSequence
		mov	cx,[word es:bx]
do110:		call	CursorDown
		loop	do110
		jmp	Main
do200:						;2) Move cursor down in seq.
		mov	ax,[ScrollTemp]
		mov	[ScrollBorder],ax
		call	MainDown
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MainDown:					;Move cursor down in sequence.
		call	IntDown
		jc	md40
		mov	ax,[Lines]
		dec	ax
		sub	ax,[ScrollBorder]
		mov	[ScrollBorder],0
		cmp	[CurLineCount],ax
		jae	md20
		inc	[CurLineCount]
		inc	[CurRow]
		ret
md20:
		inc	[StepCount]

		push	cx
		mov	cx,[Voices]
		xor	bx,bx
md25:
		inc	[SeqWhere+bx]		;Move entire voice.
		mov	ax,[SeqWhere+bx]
		cmp	ax,[FirstSeqLen+bx]
		jne	md30
		mov	[SeqWhere+bx],0
		xor	ah,ah
		mov	al,[TrackJump]
		add	[TrackCountRes+bx],ax
md30:
		inc	bx
		inc	bx
		loop	md25
		pop	cx
md40:		mov	[ScrollBorder],0
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IntDown:					;Move cursor down in memory.
		mov	bp,[IntByte]
		mov	al,[Col1Jump]
		add	al,[Col2Jump]
		xor	ah,ah
		add	[IntByte],ax
		inc	[IntWhere]
		mov	bx,[IntTrackCount]
		call	GetSequence
		mov	ax,[word es:bx]
		cmp	[IntWhere],ax
		jne	id20

		push	cx			;Check for end of track table.
		mov	di,[IntTrackCount]
		mov	cl,[TrackJump]
		xor	ch,ch
		add	di,cx
		lea	si,[TrackEndVal]
		push	es
		mov	es,[TrackSeg]
		rep	cmpsb
		jne	id10
		pop	es cx
		dec	[IntWhere]
		mov	[IntByte],bp
		stc
		ret
id10:
		pop	es cx
		mov	[IntWhere],0		;Move in track table too.
		mov	[IntByte],0
		xor	ah,ah
		mov	al,[TrackJump]
		add	[IntTrackCount],ax
id20:		clc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintInt:					;Print info about memory vars.
	      ; mov	ax,[IntWhere]
	      ; push	ax
	      ; mov	al,ah
	      ; mov	di,160*4+4
	      ; call	HexByte
	      ; add	di,4
	      ; pop	ax
	      ; call	HexByte
	      ; add	di,8

	      ; mov	ax,[IntByte]
	      ; push	ax
	      ; mov	al,ah
	      ; call	HexByte
	      ; add	di,4
	      ; pop	ax
	      ; call	HexByte
	      ; add	di,8

	      ; mov	ax,[IntTrackCount]
	      ; push	ax
	      ; mov	al,ah
	      ; call	HexByte
	      ; add	di,4
	      ; pop	ax
	      ; call	HexByte
	      ; add	di,8

	      ; mov	ax,[CurColCount]
	      ; call	HexByte
	      ; add	di,8

	      ; mov	ax,[MaxStepSeq]
	      ; push	ax
	      ; mov	al,ah
	      ; call	HexByte
	      ; add	di,4
	      ; pop	ax
	      ; call	HexByte
	      ; add	di,8

	      ; mov	al,[PlayMode]
	      ; call	HexByte

		mov	ax,[SuperInsValue]
		push	ax
		mov	al,ah
		mov	di,47*160+134
		call	HexByte
		add	di,4
		pop	ax
		call	HexByte

		mov	ax,[RhythmJump]
		push	ax
		mov	al,ah
		mov	di,45*160+134
		call	HexByte
		add	di,4
		pop	ax
		call	HexByte

		mov	ax,[SpeedVar]
		push	ax
		mov	al,ah
		mov	di,47*160+112
		call	HexByte
		add	di,4
		pop	ax
		call	HexByte

		mov	ax,[TimerSpeed]
		push	ax
		mov	al,ah
		mov	di,45*160+112
		call	HexByte
		add	di,4
		pop	ax
		call	HexByte
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TestHex:					;Tests a word by printing hex.
		push	ax di ax
		mov	al,ah
		mov	di,160*4+146
		call	HexByte
		add	di,4
		pop	ax
		call	HexByte
		pop	di ax
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Up:
		call	EraseBar

		cmp	[Mode],0
		jz	up200
up100:						;1) Move cursor up in track.
		mov	ax,[TrackSize]
		call	GetVoiceNo
		mul	bx
		mov	bl,[TrackJump]
		xor	bh,bh
		add	ax,bx
		add	ax,[TrackSkip]		;Possible secret 'Bug' here.
		cmp	[IntTrackCount],ax
		jbe	ReachTop

		mov	[TrackMove],0

		call	CursorUp		;Main movement in track.
		mov	bx,[IntTrackCount]
		call	GetSequence
		mov	cx,[word es:bx]
		dec	cx
		jcxz	up120
up110:		call	CursorUp
		loop	up110
up120:
		xor	ax,ax			;Check for top boundary passed.
		sub	ax,[Lines]
		cmp	[StepCount],ax
		jb	Main
		mov	ax,[IntTrackCount]
		mov	[TempWord1],ax
		call	VoiceInit
up170:
		mov	bx,[IntTrackCount]	;Align tracks properly.
		call	GetSequence
		mov	cx,[word es:bx]
up180:		call	MainDown
		loop	up180
		mov	ax,[TempWord1]
		cmp	[IntTrackCount],ax
		jne	up170
		call	Cursor
		jmp	Main
up200:						;2) Move cursor up in sequence.
		mov	ax,[ScrollTemp]
		mov	[ScrollBorder],ax
		call	MainUp
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MainUp: 					;Move cursor up in a sequence.
		mov	ax,[ScrollBorder]
		mov	[ScrollBorder],0
		cmp	[CurLineCount],ax
		jbe	mu20
mu15:		call	Intup
		dec	[CurLineCount]
		dec	[CurRow]
		ret
mu20:
		cmp	[StepCount],0
		jne	mu21
		cmp	[CurLineCount],0	;Top of score scrolling.
		jne	mu15
		jmp	short mu30
mu21:
		call	IntUp

		dec	[StepCount]		;Move entire voice.

		push	cx
		mov	cx,[Voices]
		xor	bx,bx
mu22:
		dec	[SeqWhere+bx]
		cmp	[SeqWhere+bx],0f000h
		jb	mu28
		xor	ah,ah
		mov	al,[TrackJump]
		sub	[TrackCountRes+bx],ax
		push	bx
		mov	bx,[TrackCountRes+bx]
		call	GetSequence
		mov	ax,[word es:bx]
		pop	bx
		dec	ax
		mov	[SeqWhere+bx],ax
mu28:		inc	bx
		inc	bx
		loop	mu22
		pop	cx
mu30:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IntUp:						;Move cursor up in memory.
		mov	bl,[Col1Jump]
		add	bl,[Col2Jump]
		xor	bh,bh
		sub	[IntByte],bx
		dec	[IntWhere]
		cmp	[IntWhere],0f000h
		jb	iu20

		xor	ah,ah
		mov	al,[TrackJump]
		sub	[IntTrackCount],ax

		push	bx
		mov	bx,[IntTrackCount]
		call	GetSequence
		mov	ax,[word es:bx]
		pop	bx
		dec	ax
		mov	[IntWhere],ax
		mul	bx			;Multiply with byte widths.
		mov	[IntByte],ax
iu20:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Right:
		cmp	[mode],0
		jz	ri170

		mov	al,[TrackJump]		;1) Cursor right in track.
		shl	al,1
		xor	ah,ah
		dec	ax
		add	al,[TrackMidSpace]
		cmp	[CurColCount],ax
		jz	Main
		inc	[CurColCount]
		inc	[CurCol]
		cmp	[CurColCount],4 	;Made for AdLib only.
		jne	ri160
		mov	al,[TrackMidSpace]
		xor	ah,ah
		add	[CurColCount],ax
		add	[CurCol],al
ri160:		call	Cursor
		jmp	Main
ri170:						;2) Cursor right in sequence.
		cmp	[CurColCount],80h
		jz	Other
		xor	ah,ah
		mov	al,[Col1Jump]
		mov	bl,al
		shl	al,1
		dec	ax
		cmp	[CurColCount],ax
		jz	ri200
		inc	[CurColCount]
		inc	[CurCol]
		call	Cursor
		lea	si,[Column1]
		call	Help
		jmp	Main
ri200:
		mov	al,[MidSpace]		;Extreme boundary (right) met.
		inc	al
		add	[CurCol],al
		mov	[CurColCount],80h
		call	Cursor
		lea	si,[Column2]
		call	Help
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Left:						;Moves the cursor left.
		cmp	[CurColCount],0
		jz	Main
		cmp	[CurColCount],80h	;Check for cursor in column 2.
		jz	le20
		dec	[CurColCount]
		dec	[CurCol]
		cmp	[CurColCount],4
		jne	le10
		mov	al,[TrackMidSpace]
		xor	ah,ah
		sub	[CurColCount],ax
		sub	[CurCol],al
le10:		call	Cursor			;Used in both Track and Seq !
		jmp	Main
le20:
		xor	ah,ah
		mov	al,[Col1Jump]
		mov	bl,al
		shl	al,1
		dec	ax
		mov	[CurColCount],ax
		mov	al,[MidSpace]
		inc	al
		sub	[CurCol],al
		call	Cursor
		lea	si,[Column1]
		call	Help
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PageDown:					;Move entire voice [LINES] down.
		cmp	[Mode],0
		jne	Down

		mov	cx,[Lines]
	      ; dec	cx			;[LINES] minus one line.
pd20:		call	CursorDown
		loop	pd20
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CursorDown:					;General cursor DOWN in seq.
		call	IntDown
		jc	cd30

		push	cx
		inc	[StepCount]

		mov	cx,[Voices]
		xor	bx,bx
cd10:
		inc	[SeqWhere+bx]
		mov	ax,[SeqWhere+bx]
		cmp	ax,[FirstSeqLen+bx]
		jne	cd20
		mov	[SeqWhere+bx],0
		xor	ah,ah
		mov	al,[TrackJump]
		add	[TrackCountRes+bx],ax
		push	bx
		mov	bx,[TrackCountRes+bx]
		call	GetSequence
		mov	ax,[word es:bx]
		pop	bx
		mov	[FirstSeqLen+bx],ax
cd20:
		inc	bx
		inc	bx
		loop	cd10
		pop	cx
cd30:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PageUp: 					;Move entire voice [LINES] up.
		cmp	[Mode],0
		jne	Up

		mov	cx,[Lines]
	      ; dec	cx			;[LINES] minus one line.
pu20:		cmp	[StepCount],0
		jz	ReachTop
		call	CursorUp
		loop	pu20
		jmp	Main
ReachTop:
		call	EraseBar		;Put cursor to the top.
		call	VoiceInit
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CursorUp:					;General Cursor up in sequence.
		call	IntUp
		dec	[StepCount]

		push	cx
		mov	cx,[Voices]
		xor	bx,bx
cu10:
		dec	[SeqWhere+bx]
		cmp	[SeqWhere+bx],0f000h
		jb	cu20
		xor	ah,ah
		mov	al,[TrackJump]
		sub	[TrackCountRes+bx],ax
		push	bx
		mov	bx,[TrackCountRes+bx]
		call	GetSequence
		mov	ax,[word es:bx]
		pop	bx
		dec	ax
		mov	[SeqWhere+bx],ax
cu20:
		inc	bx
		inc	bx
		loop	cu10
		pop	cx
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Delete:
		call	Changed

		cmp	[InsideTable],0
		jne	Other

		cmp	[Mode],0
		jz	de200
de100:						;1) Delete once in track table.
		mov	[TrackMove],0

		push	es
		mov	es,[TrackSeg]
		call	FetchEnd
		sub	di,dx
		sub	di,dx
		push	di
		sub	di,[IntTrackCount]
		mov	cx,di			;CX = Block to move.
		shr	cx,1

		mov	si,[IntTrackCount]
		mov	di,si
		add	si,dx
		push	ds es
		pop	ds
		rep	movsw
		pop	ds

		pop	di			;Place blank at end of table.
		lea	si,[TrackBlanks]
		mov	cx,dx
		rep	movsb
		pop	es
		jmp	Main
de200:
		call	Del			;2) Delete once in a sequence.
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Del:						;Delete in a sequence.
		mov	bx,[IntTrackCount]
		call	GetSequence
		mov	ax,[IntWhere]
		inc	ax
		cmp	[word es:bx],ax 	;Check for end of sequence.
		jne	de20
		ret
de20:
		dec	[word es:bx]
		inc	bx
		inc	bx

		mov	al,[Col1Jump]
		add	al,[Col2Jump]
		xor	ah,ah			;AX = Size of each step.
		mov	di,[IntByte]
		add	di,bx
		mov	si,di
		add	si,ax

		mov	cx,[SeqSize]
		sub	cx,[IntByte]
		sub	cx,ax
		shr	cx,1
		push	ds es
		pop	ds
		rep	movsw			;Move all above cursor down.
		pop	ds

		jmp	InsDelFix
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Insert:
		call	Changed

		cmp	[InsideTable],0
		jne	Other

		cmp	[Mode],0
		jz	ins200
ins100: 					;1) Insert once in track table.
		mov	[TrackMove],0

		push	es
		mov	es,[TrackSeg]
		call	FetchEnd

		sub	di,dx
		mov	ax,di
		sub	di,dx
		mov	si,di
		sub	si,dx

		sub	ax,[IntTrackCount]
		sub	ax,dx
		mov	cx,ax			;CX = Block to move.
		shr	cx,1
		std
		push	ds es
		pop	ds
		rep	movsw
		pop	ds
		cld

		mov	di,[IntTrackCount]	;Place the inserted value.
		lea	si,[TrackInsert]
		mov	cx,dx
		rep	movsb
		pop	es
		jmp	Main
ins200: 					;2) Insert once in a sequence.
		call	Inst
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FetchEnd:					;Fetch end of track table.
		mov	di,[IntTrackCount]
		mov	dl,[TrackJump]
		xor	dh,dh
fe110:		mov	cx,dx
		lea	si,[TrackEndVal]
		rep	cmpsb
		jne	fe110
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Inst:						;Insert in a sequence.
		mov	bx,[IntTrackCount]
		call	GetSequence
		mov	ax,[MaxStepSeq]
		cmp	[word es:bx],ax 	;Check for sequence boundary.
		jb	in10
		ret
in10:
		inc	[word es:bx]
		inc	bx
		inc	bx
		mov	al,[Col1Jump]
		add	al,[Col2Jump]
		xor	ah,ah			;AX = Size of each step.
		mov	di,[SeqSize]
		add	di,bx
		mov	si,di
		sub	di,ax
		sub	si,ax
		sub	si,ax			;4 to 5, 3 to 4 and so on.

		mov	cx,[SeqSize]
		sub	cx,[IntByte]
		sub	cx,ax
		shr	cx,1
		push	ds es
		pop	ds
		std
		rep	movsw			;Move all above cursor up.
		cld
		pop	ds

		mov	si,[IntByte]		;Put a blank on the new space.
		xor	di,di
		mov	cl,[Col1Jump]
		xor	ch,ch
in20:		mov	al,[Col1BlankValues+di] ;First a blank command...
		mov	[es:bx+si],al
		inc	di
		inc	si
		loop	in20

		xor	ah,ah
		cmp	[HoldRest],0
		jz	in25

		mov	al,[Col2RestPos]	; ...and then a REST.
		add	si,ax
		mov	al,[es:bx+si]
		mov	cl,[Col2RestMask]
		xor	cl,0ffh
		and	al,cl			;Only touch what is "allocated"!
		or	al,[Col2RestValue]
		mov	[es:bx+si],al
		jmp	InsDelFix
in25:
		mov	al,[Col2HoldPos]	; ...or a HOLD.
		add	si,ax
		mov	al,[es:bx+si]
		mov	cl,[Col2HoldMask]
		xor	cl,0ffh
		and	al,cl			;Only touch what is "allocated"!
		or	al,[Col2HoldValue]
		mov	[es:bx+si],al
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InsDelFix:
		mov	ax,[IntTrackCount]	;Remember where the cursor IS !
		mov	[TempWord1],ax
		mov	ax,[IntWhere]
		mov	[TempWord2],ax
		mov	ax,[VoiceRow]
		add	ax,[Lines]
		sub	al,[CurRow]
		mov	[TempByte1],al

		call	EraseBar
		call	VoiceInit		;Restore back to absolute start.
in30:
		mov	ax,[TempWord1]		;Move down to the right track.
		cmp	[IntTrackCount],ax
		jz	in40
		call	MainDown
		call	FixCursor
		jmp	short in30
in40:
		mov	ax,[TempWord2]		;And to the right step in seq.
		cmp	[IntWhere],ax
		jz	GoRow
		call	MainDown
		call	FixCursor
		jmp	short in40
GoRow:
		mov	cl,[TempByte1]		;Now go to the correct row.
		xor	ch,ch
		dec	cx
		jcxz	in80
		push	cx
in60:		call	MainDown
		call	FixCursor
		loop	in60
		pop	cx
in70:		call	MainUp
		call	FixCursor
		loop	in70
in80:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FixCursor:
		push	cx
		mov	cx,[Voices]
		xor	bx,bx
fc20:
		push	bx
		mov	bx,[TrackCountRes+bx]
		call	GetSequence
		mov	ax,[word es:bx]
		pop	bx
		mov	[FirstSeqLen+bx],ax
		inc	bx
		inc	bx
		loop	fc20
		pop	cx
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlUp: 					;Increases the Octave.
		inc	[Octave]
		cmp	[Octave],10
		jne	Other
		mov	[Octave],0
		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlDown:					;Decreases the Octave.
		dec	[Octave]
		jns	Other
		mov	[Octave],9
		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HomeKey:					;Go to beginning of a line.
		cmp	[Mode],0
		jz	ho200
ho100:						;1) Home in track mode.
		call	GetVoiceCol
		mov	[CurCol],al
		jmp	short ho230
ho200:						;2) Home in sequence mode.
		lea	si,[Column1]
		call	Help
		call	GetVoiceCol
		mov	bl,[TrackJump]
		shl	bl,1
		add	al,bl
		add	al,[TrackSpace]
		add	al,[TrackMidSpace]
		mov	[CurCol],al
ho230:		mov	[CurColCount],0
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VcON:						;Turn all voices ON.
		mov	cl,1
		call	AllVcSet
		call	PrintVcFlags
		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VcOFF:						;Turn all voices OFF.
		xor	cl,cl
		call	AllVcSet
		call	PrintVcFlags
		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AltNum: 					;Toggle Alt 1-9 voice ON/OFF.
		shr	di,1
		shr	di,1
		sub	di,10h
		mov	bx,di
		jmp	short vct20
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VcToggle:					;Toggle current voice ON/OFF.
		call	GetVoiceNo
vct20:
		mov	dl,[XVoiceFlags+bx]
		xor	dl,1
		mov	[XVoiceFlags+bx],dl
		mov	ah,5
		call	[dword Interface-2]

		call	PrintVcFlags

		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ToggleRast:					;Toggle rastertime ON or OFF.
		not	[Rast]
		mov	dl,[Rast]
		mov	ah,7
		call	[dword Interface-2]
		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AltTab: 					;Toggle all voices except edit.
		mov	cl,1
		call	AllVcSet

		call	GetVoiceNo
		mov	[TempWord1],bx

		mov	cx,[Voices]
at20:		mov	bx,cx
		dec	bx
		cmp	bx,[TempWord1]
		jz	at30
		mov	dl,[XVoiceFlags+bx]
		xor	dl,1
		mov	[XVoiceFlags+bx],dl
		mov	ah,5
		call	[dword Interface-2]
at30:		loop	at20

		call	PrintVcFlags

		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetRelease:					;Set spot where HOLD goes REST.
		cmp	[Mode],0
		jne	Other
		cmp	[InsideTable],0
		jne	Other

		call	Changed

		call	EraseBar
		call	NoCursor

		mov	bx,[IntTrackCount]
		call	GetSequence
		mov	ax,[word es:bx]
		xor	dx,dx
		mov	cl,[Col1Jump]
		add	cl,[Col2Jump]
		xor	ch,ch
		mul	cx
		mov	[TempWord2],ax
		inc	bx
		inc	bx
		mov	dx,[IntByte]
sr10:
		cmp	dx,0
		jz	sr20
		mov	al,[Col1Jump]		;Count backwards.
		add	al,[Col2Jump]
		xor	ah,ah
		sub	dx,ax

		call	TestHold		;If HOLD is there, ignore it.
		jc	sr10
		call	TestNote		;If a note is there, stop HOLD.
		jc	sr20

		call	PutHold
		jmp	short sr10
sr20:
		mov	dx,[IntByte]
sr30:
		cmp	dx,[TempWord2]
		jae	sr50

		call	TestHold		;If HOLD is there, ignore it.
		jc	sr40
		call	TestNote		;If a note is there, stop REST.
		jc	sr50
sr40:
		call	PutRest
		mov	al,[Col1Jump]		;Count upwards.
		add	al,[Col2Jump]
		xor	ah,ah
		add	dx,ax
		jmp	short sr30
sr50:
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TestHold:					;Test to see if HOLD is there.
		mov	al,[Col1Jump]
		add	al,[Col2HoldPos]	;DX = IntByte
		xor	ah,ah
		add	ax,dx
		mov	si,ax
		mov	al,[es:bx+si]
		and	al,[Col2HoldMask]
		cmp	al,[Col2HoldValue]
		jne	th24
		stc
		ret
th24:		clc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TestNote:					;Test to see if NOTE is there.
		mov	al,[Col1Jump]
		add	al,[Col2NotePos]	;DX = IntByte
		xor	ah,ah
		add	ax,dx
		mov	si,ax
		mov	al,[es:bx+si]
		and	al,[Col2NoteMask]
		jz	tn24
		stc
		ret
tn24:		clc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PutRest:					;Put a REST in column 2.
		mov	al,[Col1Jump]
		add	al,[Col2RestPos]	;DX = IntByte
		xor	ah,ah
		add	ax,dx
		mov	si,ax
		mov	al,[es:bx+si]
		mov	cl,[Col2RestMask]
		xor	cl,0ffh
		and	al,cl			;Only touch what is "allocated"!
		or	al,[Col2RestValue]
		mov	[es:bx+si],al
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PutHold:					;Put a HOLD in column 2.
		mov	al,[Col1Jump]
		add	al,[Col2HoldPos]	;DX = IntByte
		xor	ah,ah
		add	ax,dx
		mov	si,ax
		mov	al,[es:bx+si]
		mov	cl,[Col2HoldMask]
		xor	cl,0ffh
		and	al,cl			;Only touch what is "allocated"!
		or	al,[Col2HoldValue]
		mov	[es:bx+si],al
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlTab:					;Go to the previous voice.
		cmp	[InsideTable],0
		jne	Other

		cmp	[TrackVoice],0
		jz	Other
		dec	[TrackVoice]
		jmp	short EnterVoice
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TabKey: 					;Go to the next voice.
		cmp	[InsideTable],0
		jne	Other

		mov	ax,[Visible]		;Check for right-most voice.
		dec	ax
		cmp	[TrackVoice],ax
		jz	Other
		inc	[TrackVoice]
EnterVoice:
		mov	ax,[CurColCount]	;Remember last column.
		mov	[TempWord3],ax

		call	SetScreenPos

		mov	[TempByte2],0
		cmp	[Mode],0
		jz	tk28
		mov	[TempByte2],1
		mov	[Mode],0
		call	HomeSeq
tk28:
		mov	[TrackMove],0

		mov	ax,[StepCount]
		mov	[TempWord2],ax

		mov	ax,[VoiceRow]		;Remember old screen positions.
		add	ax,[Lines]
		sub	al,[CurRow]
		mov	[TempByte1],al
		mov	al,[CurRow]
		xor	ah,ah
		sub	ax,[VoiceRow]
		mov	[TempWord1],ax

		call	EraseBar
		call	NoCursor
		call	VoiceInit

		mov	cx,[TempWord2]		;Move down to the right step.
		jcxz	tk40
tk30:		call	MainDown
		call	FixCursor
		loop	tk30
tk40:
		mov	cx,[TempWord1]		;Move down to old CurRow.
		jcxz	tk50
tk45:		call	MainDown
		call	FixCursor
		loop	tk45
tk50:
		call	GoRow

		call	GetVoiceCol		;Calculate cursor position.
		mov	bl,[TrackJump]
		shl	bl,1
		add	al,bl
		add	al,[TrackSpace]
		add	al,[TrackMidSpace]
		mov	bx,[TempWord3]
		mov	[CurColCount],bx
		cmp	bl,80h
		jne	tk55
		mov	bl,[Col1Jump]
		shl	bl,1
		add	al,bl
		add	al,[MidSpace]
		jmp	short tk56
tk55:		add	al,bl
tk56:		mov	[CurCol],al

		call	ClearVoiceArea
		call	Edge

		cmp	[TempByte2],0
		jz	tk60
		mov	[Mode],1
		jmp	gt100			;Enter track in the other voice.
tk60:		cmp	[CurColCount],80h
		jz	tk70
		jmp	HomeKey
tk70:		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AlterSpace:					;Alter SpaceBar in Column 2.
	      ; mov	al,[HoldRest]
	      ; xor	al,1
	      ; mov	[HoldRest],al		;This routine is skipped...
		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AltUp:						;Edit voice number over voice.
		cmp	[InsideTable],0
		jne	Other

		call	EraseBar
		call	NoCursor

		mov	bx,[TrackVoice] 	;Find current column 2.
		mov	dl,[AllVoiceCol+bx]
		mov	al,[TrackJump]
		shl	al,1
		add	dl,al
		add	dl,[TrackSpace]
		add	dl,[TrackMidSpace]
		mov	al,[Col1Jump]
		shl	al,1
		add	dl,al
		add	dl,[MidSpace]
		dec	dl

		mov	ax,[VoiceRow]
		mov	dh,al
		dec	dh
		dec	dh
		shl	bx,1
		mov	ax,[VoiceOrder+bx]
		inc	ax
		mov	bl,1
		call	HexInput
		jc	au70
		dec	ax
		cmp	ax,[Voices]		;Boundary check.
		jae	au70
	      ; or	ax,ax
	      ; jz	au70
		mov	bx,[TrackVoice]
		shl	bx,1
		mov	[VoiceOrder+bx],ax

		jmp	EnterVoice
au70:
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AltDown:					;Edit voice volume below voice.
		cmp	[InsideTable],0
		jne	Other

		call	EraseBar
		call	NoCursor

		mov	bx,[TrackVoice] 	;Find current column 2.
		mov	dl,[AllVoiceCol+bx]
		mov	al,[TrackJump]
		shl	al,1
		add	dl,al
		add	dl,[TrackSpace]
		add	dl,[TrackMidSpace]
		mov	al,[Col1Jump]
		shl	al,1
		add	dl,al
		add	dl,[MidSpace]
		dec	dl

		mov	ax,[VoiceRow]
		add	ax,[Lines]
		add	ax,3
		mov	dh,al
		dec	dh
		dec	dh
		push	es
		mov	es,[InstrSeg]
		mov	ax,[es:bx+8bh]
		mov	bl,1
		call	HexInput
		jc	ad70
		cmp	al,40h			;Boundary check.
		jae	ad70
		mov	bx,[TrackVoice]
		mov	[es:bx+8bh],al
ad70:
		pop	es
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F1Key:						;Start music-player.
		mov	[PlayMode],1
		mov	ah,1
		call	[dword Interface-2]
		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F2Key:						;Stop music-player.
		mov	[PlayMode],0
		mov	ah,2
		call	[dword Interface-2]
		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F3Key:						;Start music with FollowPlay.
		cmp	[InsideTable],0
		jne	Other

		mov	ah,4
		call	[dword Interface-2]
		jc	F1Key			;FollowPlay NOT available.

		mov	[FollowFirst],0

		cmp	[Mode],0		;Key pressed in track ?
		jz	f3k2
		mov	[Mode],0
		mov	[TrackMove],0

		call	HomeSeq

		mov	[CurColCount],0
		mov	[FastOn],0
f3k2:						;Continue as in a sequence.
		call	EraseBar
		call	VoiceInit
		call	FixCursor
		call	NoCursor

		mov	cx,[StartPoint]
		jcxz	F3k5
f3k4:		call	CursorDown
		call	FixCursor
		loop	f3k4
f3k5:
		call	Memorize

		mov	[PlayMode],2		;Start music.
		mov	ah,1
		call	[dword Interface-2]
FollowPlay:
		mov	ah,4			;Get FollowTimer.
		call	[dword Interface-2]
		or	al,al
		jne	f3k6

		mov	[FollowWait],0

		mov	ah,11h
		int	16h
		jz	FollowPlay

		mov	[PlayMode],0		;Stop music.
		mov	ah,2
		call	[dword Interface-2]
		jmp	Main
f3k6:
		cmp	[FollowWait],1
		jz	FollowPlay

		push	es
		xor	ax,ax
		mov	es,ax
		test	[byte es:417h],4	;Check for CTRL key.
		pop	es
		jz	f3k63

		cmp	[FastOn],1
		jz	f3k66

		mov	bx,200
		mov	cx,1
		mov	ah,8			;Fast timer IRQ speed.
		call	[dword Interface-2]
		mov	[FastOn],1
		jmp	f3k66
f3k63:
		cmp	[FastOn],0
		jz	f3k66

		mov	bx,[TimerSpeed] 	;Normal timer IRQ speed.
		xor	cx,cx
		mov	ah,8
		call	[dword Interface-2]
		mov	[FastOn],0
f3k66:
	      ; cmp	[FollowFirst],11	;Obviously a critical value...
	      ; jz	f3k67
	      ; inc	[FollowFirst]		;Skipped, only worked on 66 Mhz!
	      ; jmp	f3k8
f3k67:
		call	EraseBar
		call	NoCursor
		mov	[FollowWait],1

		mov	ax,[ScrollTemp]
		mov	[ScrollBorder],ax
		call	MainDown
		call	FixCursor

		mov	di,[IntTrackCount]	;Check for normal end of track.
		mov	cl,[TrackJump]
		xor	ch,ch
		lea	si,[TrackEnd]
		push	es
		mov	es,[TrackSeg]
		rep	cmpsb
		jne	f3k8
		pop	es
		call	Restore
		jmp	Main
f3k8:
		pop	es
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F4Key:						;Define new StartPoint.
		cmp	[InsideTable],0
		jne	Other

		call	EraseBar
		call	NoCursor

		mov	al,[CurRow]		;Remember cursor position.
		xor	ah,ah
		sub	ax,[VoiceRow]
		mov	[TempByte1],al

		mov	bx,[StepCount]		;StartPoint = StepCount + Row.
		add	bx,ax
		mov	[StartPoint],bx

		mov	cx,[Lines]		;Scroll current row to the top.
		push	cx
f4k10:		call	MainDown
		call	FixCursor
		loop	f4k10
		pop	cx
f4k20:		call	MainUp
		call	FixCursor
		loop	f4k20

		call	SetSP
GoRow2:
		mov	cl,[TempByte1]		;Now go to the correct row.
		xor	ch,ch
		jcxz	gr80
		push	cx
gr60:		call	MainUp
		call	FixCursor
		loop	gr60
		pop	cx
gr70:		call	MainDown
		call	FixCursor
		loop	gr70
gr80:		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetSP:
		mov	cx,[Voices]		;Send new Track/Seq pointers.
		xor	si,si
		mov	di,si
ss30:		xor	dx,dx
		mov	ax,[TrackSize]		;Track's offset must be from 0.
		mul	di
		mov	dx,[TrackCountRes+si]
		sub	dx,ax
		sub	dx,[TrackSkip]		; ...and a TRUE offset at 0!
		mov	ax,[SeqWhere+si]
		mov	bl,[Col1Jump]
		add	bl,[Col2Jump]
		mul	bl			;Seq's pointer must be bytefine.
		mov	bx,ax
		push	di si cx
		mov	ah,6
		call	[dword Interface-2]	;Especially DI is manipulated.
		pop	cx si di
		inc	di
		inc	si
		inc	si
		loop	ss30
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ResetSP:					;Reset Track/Seq pointers to 0.
		push	es
		mov	es,[SeqSeg]
		call	FixCursor

		mov	cx,[Voices]
rs30:		xor	dx,dx
		mov	bx,dx
		mov	di,cx
		dec	di
		push	cx
		mov	ah,6
		call	[dword Interface-2]
		pop	cx
		loop	rs30
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F7Key:						;Increase tune speed.
		cmp	[SpeedVar],40h
		jae	Other
		call	Changed
		inc	[SpeedVar]
		jmp	short sf72
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F6Key:						;Decrease tune speed.
		cmp	[SpeedVar],0
		jz	Other
		call	Changed
		dec	[SpeedVar]
sf72:
		mov	bx,[SpeedVar]
		mov	ah,3
		call	[dword Interface-2]
		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TimerUp:					;Increase timer IRQ speed.
		call	Changed
		inc	[TimerSpeed]
		jmp	short tdo20
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TimerDown:					;Decrease timer IRQ speed.
		cmp	[TimerSpeed],19
		jz	Other			;No lower than 19 times a sec.
		call	Changed
		dec	[TimerSpeed]
tdo20:
		mov	bx,[TimerSpeed]
		xor	cx,cx
		mov	ah,8
		call	[dword Interface-2]

		push	es
		mov	es,[InstrSeg]		;Send to data block as well.
		mov	[es:8],bl
		pop	es

		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NewTuneSpd:					;Input new tune speed.
		call	EraseBar

		mov	[Chk],1

		WINDOW	24,22,55,24,78h,00h

		lea	bx,[SpeedText]
		call	Print

		mov	dh,23
		mov	dl,50
		mov	ax,[SpeedVar]
		xor	bl,bl
		call	HexInput
		mov	[Chk],0
		jc	f69
		cmp	ax,40h			;Keep within 00h-40h.
		jbe	nts20
		mov	ax,40h
nts20:
		mov	[SpeedVar],ax

		mov	bx,ax
		mov	ah,3
		call	[dword Interface-2]

		call	Changed
		jmp	f69
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F5Key:						;Copy seq into seq at cursor.
		cmp	[InsideTable],0
		jne	Other

		call	EraseBar

		mov	[Chk],1

		WINDOW	16,22,64,24,78h,00h

		lea	bx,[Copy1Text]
		call	Print

		mov	dh,23
		mov	dl,59
		mov	ax,[Copy1Value]
		xor	bl,bl
		call	HexInput
		mov	[Chk],0
		jc	f69

		call	Changed

		mov	[Copy1Value],ax
		cmp	[Mode],0
		jne	f58
f57:
		cmp	[IntWhere],0
		jz	f58
		call	MainUp			;Cursor to start of sequence.
		jmp	short f57
f58:
		call	NoCursor

		mov	bx,[IntTrackCount]
		call	GetSequence		;Get position of target seq.
		mov	di,bx
		mov	ax,[SeqSize]
		mul	[Copy1Value]		;Get position of source seq.
		mov	si,ax
CopySeq:
		mov	cx,[SeqSize]
		shr	cx,1
		push	ds es
		pop	ds
		rep	movsw			;Do the copying.
		pop	ds

		call	InsDelFix
f69:
		mov	[Chk],0
		call	ClrWindow
		call	ClearVoiceArea
		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ShF5Key:					;Copy seq into another seq.
		cmp	[InsideTable],0
		jne	Other

		mov	[Chk],1

		call	EraseBar

		WINDOW	26,21,54,25,78h,00h

		lea	bx,[Copy2Txt1]
		call	Print
		lea	bx,[Copy2Txt2]
		call	Print

		mov	dh,24
		mov	dl,36
		mov	ax,[Copy2Source]
		xor	bl,bl
		call	HexInput
		jc	f69
		mov	[Copy2Source],ax

		lea	bx,[Copy2Txt3]
		call	Print

		mov	dh,24
		mov	dl,48
		mov	ax,[Copy2Dest]
		xor	bl,bl
		call	HexInput
		jc	f69

		mov	[Chk],0

		call	Changed

		mov	[Copy2Dest],ax
		cmp	[Mode],0
		jne	sf58
sf57:
		cmp	[IntWhere],0
		jz	sf58
		call	MainUp			;Cursor to start of sequence.
		jmp	short sf57
sf58:
		call	NoCursor

		mov	ax,[SeqSize]
		mul	[Copy2Dest]		;Get position of target seq.
		mov	di,ax
		mov	ax,[SeqSize]
		mul	[Copy2Source]		;Get position of source seq.
		mov	si,ax
		jmp	CopySeq
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F8Key:						;Define new SuperInsert value.
		call	EraseBar

		mov	[Chk],1

		WINDOW	24,22,55,24,78h,00h

		lea	bx,[InsertText]
		call	Print

		mov	dh,23
		mov	dl,50
		mov	ax,[SuperInsValue]
		xor	bl,bl
		call	HexInput
		jc	f69
		mov	[SuperInsValue],ax
		jmp	f69
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AltF1:						;Help page, cursor controlled.
		cmp	[InsideTable],0
		jne	Other

		cmp	[Patch],1
		jne	al909
		cmp	[WhichPatch],3
		jz	al910
		cmp	[WhichPatch],4
		jz	al910
al909:		call	FixPatch
		jc	al920			;CARRY = Patch removed.
al910:
		call	EraseBar
		call	NoCursor

		mov	[WhichPatch],4
		call	HelpMe
al920:
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FixPatch:					;Switch screen-patch.
		call	NoCursor
		call	EraseBar

		mov	al,[Patch]
		xor	al,1
		mov	[Patch],al
		cmp	al,1
		jne	ClosePatch		;Continues into OpenPatch.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
OpenPatch:					;Insert an extra screen-patch.

		mov	[Lines],16

		mov	cl,[CurRow]		;Get cursor out of patch area...
		xor	ch,ch
		sub	cx,[VoiceRow]
op10:		cmp	cx,15
		jbe	op15
		call	MainUp
		call	FixCursor
		loop	op10
op15:
	      ; mov	cx,[ScrollTemp] 	; ...and out of ScrollBorder.
	      ; jcxz	op18
op16:	      ; call	MainUp
	      ; call	FixCursor
	      ; loop	op16
op18:
		push	es
		RESES
		call	Edge

		mov	al,20h			;Clear a line.
		mov	di,26*160
		mov	cx,80
op20:		stosb
		inc	di
		loop	op20

		mov	ax,08dch		;Print a grey outline.
		mov	cx,80
		rep	stosw

		mov	[word es:26*160],08ddh
		mov	[word es:26*160+158],08deh
		mov	[word es:27*160],08dbh
		mov	[word es:27*160+158],08dbh

		mov	[word es:27*160+2],08dbh
		mov	[word es:27*160+4],08dbh
		mov	[word es:27*160+6],08dbh
		mov	[word es:27*160+8],08dbh
		mov	[word es:27*160+10],08dbh

		mov	[word es:27*160+148],08dbh
		mov	[word es:27*160+150],08dbh
		mov	[word es:27*160+152],08dbh
		mov	[word es:27*160+154],08dbh
		mov	[word es:27*160+156],08dbh

		lea	bx,[ScreenPatch]
		call	Print
		call	Shadow

		mov	[word es:43*160+4],08dch
		mov	[word es:43*160+6],08dch
		mov	[word es:43*160+8],08dch
		mov	[word es:43*160+10],08dch

		mov	[word es:43*160+148],08dch
		mov	[word es:43*160+150],08dch
		mov	[word es:43*160+152],08dch
		mov	[word es:43*160+154],08dch
		mov	[word es:43*160+156],08d7h

		call	NewVertLine

		pop	es
		clc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClosePatch:					;Clean up after the patch!

		mov	[Lines],32
		mov	[WhichPatch],0

		push	es
		RESES

		mov	ax,0720h		;Clear a line.
		mov	di,42*160
		mov	cx,80
		rep	stosw

		mov	ax,08dch		;Print a grey outline.
		mov	cx,80
		rep	stosw

		call	VoiceBorder

		call	Edge
		call	ClearVoiceArea
		pop	es
		stc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F9Key:						;SuperInsert function.
		cmp	[Mode],0
		jne	Other
		cmp	[InsideTable],0
		jne	Other

		call	Changed

		call	NoCursor

		mov	cx,[SuperInsValue]
		mov	bx,[IntTrackCount]
		call	GetSequence
		cmp	[word es:bx],1		;Check for unopened sequence.
		jne	f92
		dec	cx			; ...it requires one less INST.
f92:
		push	cx
		call	Inst
		pop	cx
		loop	f92
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SwitchTable:					;Toggle the table window ON/OFF.
		cmp	[InsideTable],0
		jne	Other

		call	SwTab
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SwTab:						;Open or close the table window.
		cmp	[Patch],1
		jne	st808
		cmp	[WhichPatch],3
		jne	st810
st808:		call	FixPatch
		jc	st820			;CARRY = Patch removed.
st810:
		lea	bx,[ScreenPatch]
		call	Print
		call	Shadow
UpdateTables:
		push	es
		mov	es,[InstrSeg]
		push	es
		lea	bx,[ExtraTable1]
                call    TabDef
		cmp	[ResetExtra],1
		jne	st811
		lea	si,[ExtraBuffer]
		call	TabCure
st811:		call	TabPlot
		pop	es
		lea	bx,[InstrTable]
                call    TabDef
		cmp	[ResetInstr],1
		jne	st813
		lea	si,[InstrBuffer]
		call	TabCure
st813:		call	TabPlot
		pop	es
		mov	[WhichPatch],3
st820:
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Shadow: 					;Print a shadow beneath window.
		push	es
		RESES

		mov	[byte es:43*160],219
		mov	[byte es:43*160+2],219
		mov	[byte es:44*160-2],219

		mov	[word es:43*160-4],08d4h
		mov	[word es:42*160-4],08d4h
		mov	[word es:41*160-4],08d4h
		mov	[word es:40*160-4],08d4h
		mov	[word es:39*160-4],08d4h
		mov	[word es:38*160-4],08d4h
		mov	[word es:37*160-4],08d4h
		mov	[word es:36*160-4],08d4h
		mov	[word es:35*160-4],08d4h
		mov	[word es:34*160-4],08d4h
		mov	[word es:33*160-4],08d4h
		mov	[word es:32*160-4],08d4h
		mov	[word es:31*160-4],08d4h
		mov	[word es:30*160-4],08d4h

		mov	[word es:43*160-2],08dbh
		mov	[word es:42*160-2],08dbh
		mov	[word es:41*160-2],08dbh
		mov	[word es:40*160-2],08dbh
		mov	[word es:39*160-2],08dbh
		mov	[word es:38*160-2],08dbh
		mov	[word es:37*160-2],08dbh
		mov	[word es:36*160-2],08dbh
		mov	[word es:35*160-2],08dbh
		mov	[word es:34*160-2],08dbh
		mov	[word es:33*160-2],08dbh
		mov	[word es:32*160-2],08dbh
		mov	[word es:31*160-2],08dbh
		mov	[word es:30*160-2],08dbh
		mov	[word es:29*160-2],08dbh

		mov	[word es:42*160],08dbh
		mov	[word es:41*160],08dbh
		mov	[word es:40*160],08dbh
		mov	[word es:39*160],08dbh
		mov	[word es:38*160],08dbh
		mov	[word es:37*160],08dbh
		mov	[word es:36*160],08dbh
		mov	[word es:35*160],08dbh
		mov	[word es:34*160],08dbh
		mov	[word es:33*160],08dbh
		mov	[word es:32*160],08dbh
		mov	[word es:31*160],08dbh
		mov	[word es:30*160],08dbh
		mov	[word es:29*160],08dbh
		mov	[word es:28*160],08dbh

		mov	[word es:29*160-4],08d6h
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InstrEdit:					;Edit the Instrument table.
		cmp	[WhichTable],0
		jz	ie20
		call	RememberTable
		mov	[WhichTable],0
ie20:
		lea	ax,[ResetInstr]
		lea	bx,[InstrTable]
		lea	dx,[InstrBuffer]
TableEdit:
		mov	[TempWord2],ax
		mov	[TempWord3],bx
		mov	[TempWord4],dx

	      ; cmp	[InsideTable],0
	      ; jne	Other

		cmp	[WhichPatch],3
		jz	te21

		call	SwTab
te21:
		call	EraseBar
		call	NoCursor

		mov	[InsideTable],1

		push	es
		mov	es,[InstrSeg]		;Point to the right table.
		mov	bx,[TempWord3]
                call    TabDef
		pop	es

		call	MidLine

		mov	si,[TempWord2]
		cmp	[byte si],0
		jz	te77
		mov	si,[TempWord4]		;Continue from last positions.
		call	TabCure
te77:
		call	TabPlot
ContEdit:
		mov	[CallExternal],0
		call	TabEdit
		jc	ce30
		call	Keyboard
		mov	[CallExternal],1
		mov	[TempAH],ah
		jmp	Other
ce30:
		mov	di,[TempWord4]
		call	TabAmnesia		;Remember where you got to.
		mov	si,[TempWord2]
		mov	[byte si],1
		mov	[InsideTable],0
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ExtraEdit1:					;Edit an additional table 1.
		cmp	[WhichTable],1
		jz	ee20
		call	RememberTable
		mov	[WhichTable],1
ee20:
		lea	ax,[ResetExtra]
		lea	bx,[ExtraTable1]
		lea	dx,[ExtraBuffer]
		jmp	TableEdit
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MidLine:					;Insert a divide line in patch.
		push	es

		RESES

		mov	cx,75
		mov	ax,0b0c4h
		mov	di,35*160+4
		rep	stosw

	      ; mov	[word es:35*160+132],0b0c1h
	      ; mov	[word es:35*160+58],0b0c2h

           ;    push    ds cs
           ;    pop     ds                      ;Test strings...
           ;    mov     cx,48
           ;    lea     si,[tttttt]
           ;    mov     di,36*160+58
           ;    mov     ah,0b3h
sdsd:      ;    lodsb
           ;    stosw
           ;    push    di
           ;  REPT    5
           ;    add     di,158
           ;    stosw
           ;  ENDM
           ;    pop     di
           ;    loop    sdsd

           ;    lea     si,[dddddd]
           ;    mov     di,29*160+140
           ;    mov     cx,7
fgfg:      ;    lodsb
           ;    stosw
           ;    push    di
           ;  REPT    5
           ;    add     di,158
           ;    stosw
           ;  ENDM
           ;    pop     di
           ;    loop    fgfg
           ;
           ;    pop     ds
           ;
                pop     es
		ret


tttttt          db      48 dup (176)
              ; db      '0000 0000 ',13 dup ('00 ')

dddddd          db      7 dup (176)
              ; db      '0000 00'
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ToggleTab:					;Toggle between the two tables.
		cmp	[WhichTable],0
		jz	ExtraEdit1
		jmp	InstrEdit
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RememberTable:					;Remember the last edited table.
		cmp	[InsideTable],1
		jz	rt19
		ret
rt19:
		cmp	[WhichTable],0
		jne	rt21

		lea	di,[InstrBuffer]
		call	TabAmnesia
		mov	[ResetInstr],1
		ret
rt21:
		lea	di,[ExtraBuffer]
		call	TabAmnesia
		mov	[ResetExtra],1
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlPgDw:					;Go to the end of ...erhm... ?
	      ; cmp	[InsideTable],0
	      ; jne	Other

		jmp	Other
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlPgUp:					;Go to StepCount 0000; Sequence.
		cmp	[InsideTable],0
		jne	Other

		call	GotoTop
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GotoTop:					;Go to StepCount 0000; Sequence.
		call	EraseBar
		call	NoCursor

		cmp	[Mode],0		;Key pressed in track ?
		jz	gt101
		mov	[Mode],0
		mov	[TrackMove],0
gt101:						;Continue as in a sequence.
		call	HomeSeq

		mov	[CurColCount],0

		call	VoiceInit
		call	FixCursor
		call	Cursor
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F10Key: 					;Goto line number
		cmp	[InsideTable],0
		jne	Other

		call	EraseBar

		mov	[Chk],1

		WINDOW	27,22,52,24,78h,00h

		lea	bx,[GotoText]
		call	Print

		mov	dh,23
		mov	dl,47
		mov	ax,[HexInputVar]
		xor	bl,bl
		call	HexInput
		jc	f69

		mov	[Chk],0

		push	ax
		cmp	[Mode],0		;Key pressed in track ?
		jz	f100
		mov	[Mode],0
		mov	[TrackMove],0

		call	HomeSeq

		mov	[CurColCount],0
f100:						;Continue as in a sequence.
		call	VoiceInit
		call	FixCursor
		call	NoCursor
		pop	ax
		mov	[HexInputVar],ax

		mov	cx,ax
		jcxz	GoMain
f101:		call	CursorDown
		call	FixCursor
		loop	f101

		mov	cx,[ScrollTemp] 	;Adjust to ScrollBorder.
		jcxz	GoMain
f102:		call	MainDown
		call	FixCursor
		loop	f102
		jmp	f69
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F11Key: 					;Define new RhythmJump value.
		call	EraseBar

		mov	[Chk],1

		WINDOW	24,22,54,24,78h,00h

		lea	bx,[RhythmText]
		call	Print

		mov	dh,23
		mov	dl,49
		mov	ax,[RhythmJump]
		xor	bl,bl
		call	HexInput
		jc	f69
		mov	[RhythmJump],ax
		jmp	f69
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
F12Key: 					;Load Track and Seq from disk.
		call	Question
		jc	f12NO
f12YES:
		mov	ah,2			;Stop music-player.
		call	[dword Interface-2]

		call	FileHandler
		jc	GoMain			;If error or escape, abort.

		call	ClearSeqSeg		;Fill all seq's with seq #0.

		call	ClearTrackSeg		;Reset all track voices.

		call	ClearInstrSeg
f1205:
		mov	[Chk],1

		WINDOW	26,22,54,24,78h,00h

		lea	bx,[LoadingText]
		call	Print
		call	NoCursor

		mov	[Chk],0

		call	UnPackFile
		jc	f12err

		lea	dx,[MusicName]
		mov	ax,3d00h		;Open - mode not used.
		int	21h
		jc	f12err
		mov	[Handle],ax

		mov	bx,ax
		xor	dx,dx
		mov	al,dl
		mov	cx,dx
		mov	ah,42h
		int	21h			;Lseek.
		jc	f12err

		mov	bx,[Handle]		;Load into predefined segments.
		mov	cx,0ff00h
		push	ds
		mov	ds,[TrackSeg]
		xor	dx,dx
		mov	ah,3fh			;Read.
		int	21h
		pop	ds
		jc	f12err

		mov	bx,[Handle]
		mov	cx,0ff00h
		push	ds
		mov	ds,[SeqSeg]
		xor	dx,dx
		mov	ah,3fh			;Read.
		int	21h
		pop	ds
		jc	f12err

		mov	bx,[Handle]
		mov	cx,0ff00h
		push	ds
		mov	ds,[InstrSeg]
		xor	dx,dx
		mov	ah,3fh			;Read.
		int	21h
		pop	ds
		jc	f12err

		mov	bx,[Handle]
		mov	ah,3eh
		int	21h			;Close.
		jc	f12err

		mov	ah,41h			;Delete temporary file.
		lea	dx,[MusicName]
		int	21h
		jc	f12err
f1209:
		call	ClearVoiceArea
		call	Edge

		cmp	[WhichPatch],3
		jne	f1210
		call	UpdateTables
f1210:
		call	Init
		call	ResetSP

		mov	cl,1			;Switch ON all voices.
		call	AllVcSet
		call	PrintVcFlags

		push	ds es

		mov	ax,ds
		mov	es,ax
		mov	ds,[InstrSeg]

		mov	si,0bh			;Get tune name in music data.
		mov	di,offset TuneName
		mov	cx,16
		rep	movsw

		mov	si,2bh			;Get composer in music data.
		mov	di,offset Composer
		mov	cx,16
		rep	movsw

		pop	es ds

		mov	bx,2*160		;Line position.
		lea	bp,[TuneName]
		call	PrintString

		mov	bx,4*160
		lea	bp,[Composer]
		call	PrintString

		call	SetTimerSpeed

		push	es
		mov	es,[TrackSeg]
		mov	bx,[es:2]
		pop	es
		mov	[SpeedVar],bx
		mov	ah,3			;Temporarily made for the old
		call	[dword Interface-2]	;AdLib player system.

		call	ConvertSpd
f12NO:
		jmp	f69
f12err:
		call	ClrWindow
		call	FileError
		jmp	f1209
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ShF12Key:					;Save Track and Seq to disk.
	       IF DEMO

		call	NotAvailable
		jmp	f69

	       ELSE

		mov	ah,2			;Stop music-player.
		call	[dword Interface-2]
shf10:
		call	FileHandler
		jc	GoMain			;If error or escape, abort.

		call	Exists			;If the file exists, warn user.
		jc	shf10

		mov	[Chk],1

		WINDOW	26,22,54,24,78h,00h

		lea	bx,[SavingText]
		call	Print
		call	NoCursor

		mov	[Chk],0

		lea	dx,[MusicName]		;Save TrackSeg with preset name.
		mov	ah,3ch
		xor	cx,cx
		int	21h			;Create file.
		jc	shf12err
		mov	[Handle],ax

		mov	bx,ax
		xor	dx,dx
		mov	al,dl
		mov	cx,dx
		mov	ah,42h
		int	21h			;Lseek.
		jc	shf12err

		mov	bx,[Handle]
		mov	cx,0ff00h
		push	ds
		mov	ds,[TrackSeg]
		xor	dx,dx
		mov	ah,40h
		int	21h			;Write.
		pop	ds
		jc	shf12err

		mov	bx,[Handle]
		mov	cx,0ff00h
		push	ds
		mov	ds,[SeqSeg]
		xor	dx,dx
		mov	ah,40h
		int	21h			;Write.
		pop	ds
		jc	shf12err

		mov	bx,[Handle]
		mov	cx,0ff00h
		push	ds
		mov	ds,[InstrSeg]
		xor	dx,dx
		mov	ah,40h
		int	21h			;Write.
		pop	ds
		jc	shf12err

		mov	bx,[Handle]
		mov	ah,3eh
		int	21h			;Close.
		jc	shf12err

		call	PackFile
		jc	shf12err

		call	UnChanged		;Song is not "Changed" anymore.

		mov	ah,41h			;Delete temporary file.
		lea	dx,[MusicName]
		int	21h
		jc	f12err

		jmp	f69
shf12err:
		call	ClrWindow
		call	FileError
		jmp	f69

	       ENDIF
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HexInput:					;Enter a hexadecimal WORD.
		cmp	[Chk],0
		jz	hi08
		cmp	[Patch],0
		jz	hi08
		mov	cx,[SubValue]
		sub	dh,cl
hi08:
		mov	[TempWord1],ax
		mov	[TempWord2],dx
		mov	[TempByte3],bl
hi10:
		mov	bl,[TempByte3]
		mov	[HexCol],bl
hi20:
		mov	dx,[TempWord2]
		push	dx
		add	dl,[HexCol]
		mov	ah,02h
		xor	bh,bh			;Put cursor at screen pos.
		int	10h
		pop	dx
hi50:
		mov	al,dh
		mov	bl,160
		mul	bl
		xor	dh,dh
		shl	dl,1
		add	ax,dx
		mov	di,ax
		mov	ax,[TempWord1]		;Print the WORD value at pos.
		push	ax
		mov	al,ah
		call	HexByte
		add	di,4
		pop	ax
		call	HexByte
hi100:
		call	Key			;Remember it WAITS for a key !
		xor	di,di
hi120:		cmp	ah,[byte Keys+di]
		jz	hi140
		add	di,4
		cmp	di,64
		jne	hi120

		cmp	ah,4dh			;Cursor right.
		jne	hi125
hi122:		cmp	[HexCol],3
		jz	hi20
		inc	[HexCol]
		jmp	short hi20
hi125:
		cmp	ah,4bh			;Cursor left.
		jne	hi128
		mov	al,[TempByte3]
		cmp	[HexCol],al
		jz	hi100
		dec	[HexCol]
		jmp	short hi20
hi128:
		cmp	ah,47h			;Home.
		jz	hi10

		cmp	ah,4fh			;End.
		jne	hi133
		mov	[HexCol],3
		jmp	hi20
hi133:
		cmp	ah,01h			;Esc.
		jz	hi300

		cmp	ah,1ch			;Enter.
		jz	hi250
		jmp	short hi100
hi140:
		shr	di,1			;Type/input hex digit.
		shr	di,1

		mov	cl,0f0h 		;AND-mask.
		mov	dx,di
		mov	bl,[HexCol]
		shr	bl,1
		jc	hi144
		shl	dl,1			;High nibble is manipulated.
		shl	dl,1
		shl	dl,1
		shl	dl,1
		mov	cl,0fh
hi144:
		mov	ax,[TempWord1]
		cmp	[HexCol],2
		jb	hi146
		and	al,cl
		or	al,dl
		jmp	short hi148
hi146:		and	ah,cl
		or	ah,dl
hi148:		mov	[TempWord1],ax
		jmp	hi122

hi250:						;Accept input.
		mov	ax,[TempWord1]
		clc
		ret

hi300:		stc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClearTune:					;Clear Tracks and Sequences.
		call	Question
		jc	CtNO
CtYES:
		mov	ah,2			;Stop music-player.
		call	[dword Interface-2]

		call	ClearSeqSeg		;Fill all seq's with seq #0.

		call	ClearTrackSeg		;Reset all track voices.

		call	ClearVoiceArea
		call	Edge

		call	Init
		call	ResetSP
		call	DefaultSpeed
CtNO:
		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ShF2Key:					;Clear instrument segment.
		call	Question
		jc	CtNOf2
CtYESf2:
		mov	ah,2			;Stop music-player.
		call	[dword Interface-2]

		call	ClearInstrSeg

		cmp	[WhichPatch],3
		jne	CtNOf2
		call	UpdateTables
CtNOf2:
		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Question:					;"Are you sure ?" and key test.
		cmp	[Touched],0
		jz	qu30

		call	EraseBar

		mov	[Chk],1

		WINDOW	20,21,58,27,01dh,00h

		lea	bx,[ConfirmTxt1]
		call	Print
		lea	bx,[ConfirmTxt2]
		call	Print
		lea	bx,[ConfirmTxt3]
		call	Print

		mov	ah,02h			;Set cursor coordinates.
		mov	dx,1932h
		cmp	[Patch],0
		jz	qu20
		mov	cx,[SubValue]
		sub	dh,cl
qu20:		xor	bh,bh
		int	10h

		mov	[Chk],0
		call	Key
		call	ClrWindow
		cmp	ah,15h			;Only "Y" gets the YES !
		jz	qu30
		stc
		ret
qu30:
		call	UnChanged

		clc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FileError:					;Error while loading or saving.
		push	ax

		mov	[Chk],1

		WINDOW	18,21,60,32,01dh,00h

		lea	bx,[ErrorTxt1]		;This routine needs ClrWindow!
		call	Print
		lea	bx,[ErrorTxt2]
		call	Print
		lea	bx,[ErrorTxt3]
		call	Print
		lea	bx,[ErrorTxt4]
		call	Print
		lea	bx,[ErrorTxt5]
		call	Print

		pop	bx

		shl	bx,1
		mov	bx,[ErrorPointers+bx]
		call	Print

		mov	[Chk],0

		jmp	Key
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AboutText:                                      ;Initial welcome message.
                call    EraseBar
                call    NoCursor

		mov	[Chk],1

                WINDOW  20,22,58,27,78h,00h

                lea     bx,[AboutTxt1]
		call	Print
                lea     bx,[AboutTxt2]
		call	Print
                lea     bx,[AboutTxt3]
		call	Print

                call    Key

                mov     [AboutNow],0

                jmp     f69
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NoCursor:					;Get rid of the cursor.
		mov	ah,2
		xor	bh,bh
		mov	dx,8080h
		int	10h
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EndKey: 					;Go to the end of a line.
		cmp	[InsideTable],0
		jne	Other

		cmp	[Mode],0
		jz	ek200
ek100:						;1) EndKey in track mode.
		call	GetVoiceCol
		mov	bl,[TrackJump]
		shl	bl,1
		add	bl,[TrackMidSpace]
		add	al,bl
		dec	al
		mov	[CurCol],al
		xor	bh,bh
		dec	bl
		mov	[CurColCount],bx
		jmp	short ek230
ek200:						;2) EndKey in sequence mode.
		lea	si,[Column2]
		call	Help
		call	GetVoiceCol
		mov	bl,[TrackJump]
		shl	bl,1
		add	al,bl
		add	al,[TrackSpace]
		add	al,[TrackMidSpace]
		mov	bl,[Col1Jump]
		shl	bl,1
		add	al,bl
		add	al,[MidSpace]
		mov	[CurCol],al
		mov	[CurColCount],80h
ek230:		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Escape: 					;Exit modes.
		cmp	[InsideTable],0
		jne	Other

		mov	[PlayMode],0
		mov	ah,2
		call	[dword Interface-2]	;Stop music.

		mov	[Patch],0		;Close screen-patch.
		call	ClosePatch
		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetOut: 					;Exit to DOS.
		mov	ax,Data
		mov	ds,ax

		call	Question
		jnc	go20
		jmp	GoMain
go20:
		mov	ah,2			;Stop player.
		call	[dword Interface-2]

		mov	ah,0bh
		call	[dword Interface-2]	;Disable TIMER IRQ.

		call	IntOff

		call	NoCursor

		cmp	[FadeDown],0
		jne	go30

		mov	bx,50			;Speed of fading.
		lea	di,[NewPalette]
		call	FadeOut
go30:
	      ; mov	ax,3301h		;Set BREAK state.
	      ; mov	dl,[BreakState]
	      ; int	21h
Quit:
	      ; mov	es,[WinBuffer]		;This is really not necessary.
	      ; call	DeAllocate
	      ; jc	DosExit
	      ; mov	es,[cs:FindSeg]
	      ; call	DeAllocate
	      ; jc	DosExit
	      ; mov	es,[SeqSeg]
	      ; call	DeAllocate
	      ; jc	DosExit
	      ; mov	es,[TrackSeg]
	      ; call	DeAllocate
	      ; jc	DosExit
	      ; mov	es,[Player]
	      ; call	DeAllocate
	      ; jc	DosExit
	      ; mov	es,[Interface]
	      ; call	DeAllocate
	      ; jc	DosExit
	      ; mov	es,[InstrSeg]
	      ; call	DeAllocate
	      ; jc	DosExit

		mov	ax,0003h
		int	10h
		mov	ax,0c06h
		mov	dl,0ffh
		int	21h
DosExit:
		mov	ax,4c00h
		int	21h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TestTrackEnd:					;Test for end of track table.
		push	es cx
		mov	es,[TrackSeg]
		mov	[TempCol],0ffh

		lea	si,[TrackEndVal]
		mov	di,[TrackCount]
		mov	cl,[TrackJump]
		xor	ch,ch
		rep	cmpsb
		jne	tte10
		mov	[TempCol],00h		;If found, color the rest black.
tte10:
		pop	cx es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintVoice:
		push	bx cx
		mov	[TempWord1],dx
		mov	[TempWord2],bx
		shl	dx,1
		mov	si,dx
		push	si
		mov	[VoiceNoFlag],0
		mov	[VolumeFlag],0
		mov	ax,[SeqWhere+si]
		mov	[XSeqWhere],ax
		mov	[XFirstSeqLen],0
		mov	ax,[Lines]
		mov	[LineCount],ax
		mov	di,[VoicePos+bx]
		mov	[TrackPos],di
		mov	[TempCol],0ffh
		mov	ax,[TrackCountRes+si]
		mov	[TrackCount],ax
prv10:
		call	TestTrackEnd
		call	PrintTrack
		cmp	[LineCount],0
		jne	prv10
PrSkillLine:
		cmp	[LastLine],0		;Skip last skill line or not.
		jne	prv15

		cmp	[TempWord2],16
		jz	prv20
prv15:
		mov	ax,di
		mov	cl,160
		div	cl
		shr	ah,1
		mov	bl,ah
		xor	bh,bh
		add	bl,[SkillSpace]
		call	VertLine		;Print SkillLine after voice.
prv20:
		pop	si
		mov	ax,[XFirstSeqLen]
		mov	[FirstSeqLen+si],ax
		mov	ax,[XSeqWhere]
		mov	[SeqWhere+si],ax
		pop	cx bx
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintTrack:
		mov	bx,[TrackCount]
		cmp	[Minimize],0
		jz	prt02
		cmp	[TrackHide],0
		jz	prt02
		mov	di,[TrackPos]		;Don't print the track table.
		jmp	prt25
prt02:
		xor	ch,ch
		mov	cl,[TrackJump]		;Plot the track table's colors.
		xor	bp,bp
		mov	al,20h
		mov	di,[TrackPos]
		push	cx di
prt05:		mov	ah,[TrackByteCol+bp]
		and	ah,[TempCol]
		stosw
		stosw
		inc	bp
		cmp	bp,2
		jne	prt07
		push	ax
		mov	al,[TrackMidSpace]
		xor	ah,ah
		shl	al,1
		add	di,ax
		pop	ax
prt07:		loop	prt05
		pop	di cx
PrTrComm:
		mov	es,[TrackSeg]
		xor	bp,bp
prt10:		xor	ah,ah
		mov	al,[TrackBytePos+bp]
		mov	si,ax
		mov	al,[es:bx+si]		;Plot the command bytes.
		cmp	[XFirstSeqLen],0
		jne	prt14
		cmp	[XSeqWhere],0
		jne	prt15
prt14:		call	Hexbyte
prt15:		add	di,4
		inc	bp
		cmp	bp,2
		jne	prt16
		mov	al,[TrackMidSpace]
		xor	ah,ah
		shl	al,1
		add	di,ax
prt16:		loop	prt10

		xor	ah,ah			;Get ready to print sequence.
		mov	al,[TrackSpace]
		shl	al,1
		add	di,ax
	      ; mov	al,[TrackMidSpace]
	      ; shl	al,1
	      ; add	di,ax
		jmp	prt26
prt25:
		call	NewTrack
prt26:
		call	GetSequence

		xor	ah,ah
		mov	al,[TrackJump]		;Bump to next track number.
		add	[TrackCount],ax
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintSeq:
		mov	[ScreenPos],di
		mov	[ScreenAdd],di
		mov	es,[SeqSeg]
		mov	ax,[word es:bx]
		cmp	[XFirstSeqLen],0
		jne	prc01
		mov	[XFirstSeqLen],ax
		sub	ax,[XSeqWhere]
		call	AddBX
prc01:		mov	[SeqCounter],ax
		inc	bx
		inc	bx
PrCol1:
		mov	es,[SeqSeg]
		mov	al,[NoteColor]
		and	al,[TempCol]
		mov	[TempNoteCol],al

		test	[TiePos],10000000b
		jne	prc02
		call	TieNote
prc02:
		cmp	[Minimize],0
		jz	prc03
		cmp	[Col1Hide],0
		jz	prc03
		mov	al,[Col1Jump]		;Don't print Column 1.
		mov	cl,2
		shl	al,cl
		mov	dl,[MidSpace]
		shl	dl,1
		add	al,dl
		xor	ah,ah
		sub	[ScreenPos],ax
		jmp	short PrCol2
prc03:
		xor	ch,ch
		mov	cl,[Col1Jump]		;Search for column 1's blank.
		xor	si,si
prc04:		mov	al,[es:bx+si]
		cmp	al,[Col1BlankValues+si]
		jne	PrCol1Plot
		inc	si
		loop	prc04
PrCol1Blank:
		xor	ch,ch
		mov	cl,[Col1Jump]
		shl	cl,1
		mov	ah,[Col1Color]		;Plot a blank command.
		and	ah,[TempCol]
		mov	al,[Col1Blank]
		mov	di,[ScreenPos]
		RESES
		rep	stosw
		jmp	short PrCol2
PrCol1Plot:
		xor	ch,ch
		mov	cl,[Col1Jump]
		mov	ah,[CommandColor]	;Plot the command color.
		and	ah,[TempCol]
		mov	al,20h
		mov	di,[ScreenPos]
		push	cx di
		shl	cl,1
		RESES
		rep	stosw
		pop	di cx
PrCol1Pos:
		xor	bp,bp
prc09:		xor	ah,ah
		mov	al,[Col1BytePos+bp]
		mov	si,ax
		mov	es,[SeqSeg]
		mov	al,[es:bx+si]		;Plot the command bytes.
		call	Hexbyte
		add	di,4
		inc	bp
		loop	prc09
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrCol2:
		xor	ah,ah
		mov	al,[Col1Jump]
		add	bx,ax

		mov	es,[SeqSeg]
		test	[TiePos],10000000b
		jz	prc10
		call	TieNote
prc10:
		call	ToCol2
		call	PrintVoiceNo
		call	PrintVolume
PrRest:
		xor	ah,ah
		mov	al,[Col2RestPos]
		mov	si,ax
		mov	al,[es:bx+si]
		and	al,[Col2RestMask]
		cmp	al,[Col2RestValue]	;Plot a REST-command.
		jne	PrHold
		mov	ah,[RestColor]
		and	ah,[TempCol]
		mov	al,[Col2Rest]
		RESES
		stosw
		stosw
		stosw
		jmp	PrNextLine
PrHold:
		xor	ah,ah
		mov	al,[Col2HoldPos]
		mov	si,ax
		mov	al,[es:bx+si]
		and	al,[Col2Holdmask]
		cmp	al,[Col2HoldValue]	;Plot a HOLD-command.
		jne	PrNote
		mov	ah,[HoldColor]
		and	ah,[TempCol]
		mov	al,[Col2Hold]
		RESES
		stosw
		stosw
		stosw
		jmp	short PrNextLine
PrNote:
		xor	ah,ah
		mov	al,[Col2NotePos]
		mov	si,ax
		mov	al,[es:bx+si]
		and	al,[Col2NoteMask]

		sub	dl,dl
prn10:
		cmp	al,0ch
		jb	prn20
		inc	dl			;Count the octave.
		sub	al,0ch
		jmp	short prn10
prn20:
		shl	al,1
		xor	ah,ah
		mov	si,ax
		mov	ah,[TempNoteCol]
		and	ah,[TempCol]
		mov	al,[Notes+si]
		RESES
		stosw
		mov	al,[Notes+1+si] 	;Plot the entire note.
		stosw
		add	dl,30h
		mov	al,dl
		stosw
PrNextLine:
		xor	ah,ah
		mov	al,[Col2Jump]
		add	bx,ax
		add	[ScreenAdd],160
		mov	ax,[ScreenAdd]
		mov	[ScreenPos],ax
		add	[TrackPos],160

		dec	[LineCount]
		jz	prn30

		cmp	[Minimize],0
		jz	prn24
		cmp	[TrackHide],0
		jne	prn26
prn24:
		xor	ch,ch
		mov	cl,[TrackJump]		;Clear track table column step.
		shl	cx,1
		add	cl,[TrackMidSpace]
		mov	al,[TrackClearChar]
		mov	ah,[TrackClearColor]
		and	ah,[TempCol]
		push	di
		mov	di,[TrackPos]
		RESES
		rep	stosw
		pop	di
		jmp	prn27
prn26:
		push	di			;Clear track indentifier.
		mov	di,[ScreenPos]
		sub	di,2
		RESES
		mov	ax,0020h
		stosw
		add	di,6
		stosw
		pop	di
prn27:
		dec	[SeqCounter]
		jne	PrCol1
prn30:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NewTrack:					;Identify start of track.
		push	es
		RESES

		cmp	[XFirstSeqLen],0
		jne	nt20

		cmp	[XseqWhere],0
		jz	nt20

		mov	[word es:di-2],0020h
		mov	[word es:di+6],0020h

		pop	es
		ret
nt20:
		mov	ah,[TrackByteCol+1]
		mov	al,[NewTrackChr1]
		mov	[es:di-2],ax
		mov	ah,[TrackByteCol+3]	;Made especially for AdLib.
		mov	al,[NewTrackChr2]
		mov	[es:di+6],ax

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ToCol2: 					;Move screen pointer to col 2.
		xor	ah,ah
		mov	al,[Col1Jump]
		shl	al,1
		shl	al,1
		mov	cl,[MidSpace]
		shl	cl,1
		add	al,cl
		add	[ScreenPos],ax
		mov	di,[ScreenPos]
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TieNote:					;Plot TIE-note function.
		xor	ah,ah
		mov	al,[TiePos]
		and	al,7fh
		mov	si,ax

		mov	al,[es:bx+si]
		and	al,[TieMaskValue]
		cmp	al,[TieMaskValue]
		jne	NoTie

		mov	al,[TieColor]
		and	al,[TempCol]
		mov	[TempNoteCol],al
NoTie:
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetVoiceNo:					;Get current voice number.
		mov	bx,[TrackVoice]
		shl	bx,1
		mov	bx,[VoiceOrder+bx]
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VoiceInit:					;Set/Reset variables for voice.
		mov	[IntWhere],0
		mov	[IntByte],0
		mov	[CurLineCount],0
		mov	[StepCount],0
		mov	[TrackMove],0
		mov	ax,[VoiceRow]
		mov	[CurRow],al		;Only some of it, though!

		mov	ax,[TrackSize]
		call	GetVoiceNo
		mul	bx
		add	ax,[TrackSkip]
		mov	[IntTrackCount],ax

		mov	cx,[Voices]
		xor	bx,bx
		mov	ax,[TrackSkip]
vi20:		mov	[SeqWhere+bx],0
		mov	[TrackCountRes+bx],ax
		add	ax,[TrackSize]
		inc	bx
		inc	bx
		loop	vi20
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init:
                mov     [HoldRest],1            ;Set/Reset general variables.
		mov	[Octave],1
		mov	[CurColCount],0
		mov	[Mode],0
	      ; mov	[HexInputVar],0
	      ; mov	[Copy1Value],0
		mov	[TrackVoice],0
		mov	[PlayMode],0
		mov	[StartPoint],0
		mov	[InsideTable],0
		mov	[Touched],0
		mov	[ResetInstr],0
		mov	[ResetExtra],0
		mov	[KeyON],0

		mov	ah,01h			;Big fat cursor.
		mov	cx,000fh
		int	10h

		mov	ax,0ffffh		;Calc space for tracks chunks.
		xor	dx,dx
		div	[Voices]
		dec	ax
		mov	[TrackSize],ax

		mov	bl,[Col1Jump]		;Calculate MAX lines for seq's.
		add	bl,[Col2Jump]
		xor	bh,bh
		xor	dx,dx
		mov	ax,[SeqSize]
		div	bx
		dec	ax			;Minus space for SeqLen and END.
		dec	ax
		mov	[MaxStepSeq],ax

		mov	ax,[VoiceRow]		;Calculate screen positions.
		mov	bl,160
		mul	bl
		mov	bx,[VoiceCol]
		shl	bx,1
		add	ax,bx
		mov	bl,[VoiceSpace]
		shl	bl,1
		xor	bh,bh
		add	ax,bx
		mov	[VoicePos],ax		;Voice 1's variable.

		mov	ax,[VoiceCol]
		add	al,[VoiceSpace]
		mov	[AllVoiceCol],al
		call	SetScreenPos

		call	VoiceInit

		xor	bx,bx
		call	GetVoiceCol		;Calculate cursor position.
		mov	bl,[TrackJump]
		shl	bl,1
		add	al,bl
		add	al,[TrackSpace]
		add	al,[TrackMidSpace]
		mov	[CurCol],al
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetScreenPos:					;Set screen pos's for voices.
		mov	al,[TrackJump]
		mov	cl,2
		shl	al,cl
		mov	dl,[TrackSpace] 	;Calc format for full voice.
		shl	dl,1
		add	al,dl
		mov	dl,[TrackMidSpace]
		shl	dl,1
		add	al,dl
		mov	ah,al
		mov	dl,[Col1Jump]
		shl	dl,cl
		add	al,dl
		mov	dl,[MidSpace]
		shl	dl,1
		add	al,dl
		add	al,6			;This value is for Col2 (Notes).
		mov	dl,[VoiceSpace]
		shl	dl,1
		add	al,dl
		mov	[TempByte1],al

		cmp	[TrackHide],0		;Calc format for reduced voice.
		jz	ssp15
		sub	al,ah
ssp15:		cmp	[Col1Hide],0
		jz	ssp18
		mov	dl,[Col1Jump]
		shl	dl,cl
		sub	al,dl
		mov	dl,[MidSpace]
		shl	dl,1
		sub	al,dl
ssp18:		mov	[TempByte2],al

		mov	cx,[Voices]		;Calc proper screen positions.
		dec	cx
		jcxz	ssp40
		xor	bx,bx
		mov	di,bx
		mov	dh,bh
ssp30:		mov	dl,[TempByte2]
		cmp	di,[TrackVoice]
		jne	ssp32
		mov	dl,[TempByte1]
ssp32:		mov	ax,[VoicePos+bx]
		add	ax,dx
		mov	[VoicePos+bx+2],ax
		shr	dl,1
		mov	al,[AllVoiceCol+di]
		add	al,dl
		mov	[AllVoiceCol+di+1],al
		inc	bx
		inc	bx
		inc	di
		loop	ssp30
ssp40:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetVoiceCol:					;Get correct col acc. to voice.
		push	bx
		mov	bx,[TrackVoice]
		mov	al,[AllVoiceCol+bx]
		xor	ah,ah
		pop	bx
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Cursor: 					;Plot cursor on screen.
		cmp	[InsideTable],0
		jne	cu29
		mov	ah,02h
		mov	dh,[CurRow]
		mov	dl,[CurCol]
		xor	bh,bh
		int	10h
cu29:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EraseBar:					;Remove the color bar.
		xor	ah,ah
		mov	al,[CurRow]
		mov	bl,160
		mul	bl
		inc	ax
		add	ax,2
		mov	si,ax
		mov	di,ax

		push	es
		RESES
		push	es
		pop	ds

		xor	bx,bx
		mov	cx,78
eb30:		lodsb
		push	ds
		mov	dx,Data
		mov	ds,dx
		mov	dl,[BarColor]
		and	dl,0fh
		jz	eb35
		mov	al,[BarColBuffer+bx]
eb35:		pop	ds
		inc	bx
		and	al,0fh
		stosb
		inc	si
		inc	di
		loop	eb30

		pop	es
		jmp	short col35
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ColorBar:
		xor	ah,ah
		mov	al,[CurRow]
	      ; dec	al
		mov	bl,160
		mul	bl
		inc	ax
		add	ax,2
		mov	si,ax
		mov	di,ax
		mov	cx,78
		mov	dl,[BarColor]
		mov	dh,dl
		and	dh,0fh
		push	es
		pop	ds

col10:	      ; lodsb				;Fix the bar one line before.
	      ; and	al,0fh
	      ; stosb
	      ; inc	si
	      ; inc	di
	      ; loop	col10

		xor	bx,bx
		mov	cx,78			;Main color bar routine.
col20:		or	dh,dh
		jz	col21
		lodsb
		push	ds
		mov	bp,Data
		mov	ds,bp
		mov	[BarColBuffer+bx],al
		pop	ds
		or	al,al			;Are colors black, clear char.
		jne	col200
		dec	di
		stosb
col200: 	mov	al,dl
		inc	bx
		jmp	short col22
col21:		lodsb
		or	al,al
		jne	col211
		dec	di
		stosb
col211: 	and	al,0fh
		or	al,dl
col22:		stosb
		inc	si
		inc	di
		loop	col20
col25:
	      ; mov	cx,78			;Fix the bar one line after.
col30:	      ; lodsb
	      ; and	al,0fh
	      ; stosb
	      ; inc	si
	      ; inc	di
	      ; loop	col30
col35:
		mov	ax,Data
		mov	ds,ax
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
StepCounter:					;Plot a row of step numbers.
		mov	ax,[VoiceRow]
		mov	bl,160
		mul	bl
		mov	di,ax
		mov	cx,[Lines]

		mov	al,[StepColumn]
		shl	al,1
		xor	ah,ah
		add	di,ax

		push	cx di
		mov	bx,[StepCount]
		inc	di
		mov	al,[StepColor]		;Color the step row.
ste10:		cmp	bx,[StartPoint]
		jb	ste12
		mov	al,[StartPointCol]
ste12:		stosb
		inc	di
		stosb
		inc	di
		stosb
		inc	di
		stosb
		inc	bx
		add	di,153
		loop	ste10
		pop	di cx
		mov	ax,[StepCount]
ste20:
		push	ax			;Plot step number.
		mov	al,ah
		call	HexByte
		add	di,4
		pop	ax
		push	ax
		call	HexByte
		add	di,156
		pop	ax
		inc	ax
		loop	ste20
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AddBX:						;Find position in sequence.
		mov	cx,[XSeqWhere]
		jcxz	ad30
		xor	dh,dh
ad20:		mov	dl,[Col1Jump]
		add	bx,dx
		mov	dl,[Col2Jump]
		add	bx,dx
		loop	ad20
ad30:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintOctave:
		mov	al,[Octave]
		add	al,30h
		mov	[es:47*160+152],al
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Print:						;Print text directly to screen.
		push	es
		RESES
		mov	al,[bx]
		xor	ah,ah
		cmp	[Chk],0 		;Called by requesters?
		jz	pr08
		cmp	[Patch],0		;Is the patch up?
		jz	pr08
		sub	ax,[SubValue]
pr08:		mov	cl,160
		mul	cl
		mov	dl,[bx+1]
		shl	dl,1
		xor	dh,dh
		add	ax,dx
		mov	di,ax
		mov	ah,[bx+2]
		add	bx,3
		mov	si,bx
pr12:		lodsb
		or	al,al
		jz	pr22
		cmp	al,80h			;80h = Skip without printing.
		jz	pr23
	      ; cmp	al,0c4h
	      ; jz	pr121
	      ; cmp	al,0b3h
	      ; jz	pr121
	      ; cmp	al,0c5h
	      ; jne	pr13
pr121:	      ; push	ax
	      ; mov	ah,0b8h 		;Yellow.
	      ; stosw
	      ; pop	ax
	      ; jmp	short pr12
pr13:		stosw
		jmp	short pr12
pr22:		pop	es
		ret
pr23:		inc	di
		inc	di
		jmp	short pr12
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Print2: 					;Print text to screen with 09h.
		push	bx
		mov	ah,02h			;Set cursor coordinates.
		mov	dh,[bx]
		mov	dl,[bx+1]
		xor	bh,bh
		int	10h

		pop	dx
		push	dx
		inc	dx
		inc	dx
		inc	dx
		mov	ah,09h			;Print text-string.
		int	21h

		pop	bx
		push	es
		RESES

		xor	dx,dx
		cmp	[byte bx+1],0
		jz	pr18
		mov	dx,2
pr18:		mov	al,[bx]
		mov	cl,160
		mul	cl
		mov	di,ax
		inc	di
		add	di,dx
		mov	al,[bx+2]
		mov	cx,80
		sub	cx,dx
pr20:		stosb				;Color the text line.
		inc	di
		loop	pr20
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Print3: 					;Print line on the text screen.
		push	es

		mov	ax,0b800h
		mov	es,ax

		cld
pr10:
		lodsw
		shl	ah,1
		mov	cl,ah
		xor	ch,ch
		mov	bl,160
		mul	bl			;Get coordinate.
		add	ax,cx
		mov	di,ax

		lodsb
		mov	dl,al			;Get color.
pr14:
		lodsb
		or	al,al			;00h = Terminate the routine.
		jz	pr25

		cmp	al,0ffh 		;FFh = Get new parameters.
		jz	pr10

		stosb

		mov	al,dl
		stosb

		jmp	short pr14
pr25:
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EraseTop:					;Clear the top text line.
		mov	di,162
		mov	cx,77
		xor	al,al
		mov	ah,[FrameColor]
		push	es
		RESES
		rep	stosw
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Edge:						;Print edge lines around voices.
		push	es
		RESES
		mov	ax,[VoiceRow]
		dec	ax
		mov	bl,160
		mul	bl
		mov	di,ax
		add	di,2
	      ; push	di
		mov	ah,[EdgeColor]
		mov	al,[EdgeChar]
		mov	cx,78
		rep	stosw
		push	ax
		mov	ax,[Lines]
		mul	bl
		add	di,ax
		add	di,4
		mov	cx,78
		pop	ax
		rep	stosw

		add	di,12			;On line below the voice area.
		mov	cx,70
		mov	ax,20h
		rep	stosw

	      ; pop	di			;Two lines over the voice area..
	      ; sub	di,320
	      ; mov	cx,80
	      ; rep	stosw
	      ; xor	di,di			; ...And on the edge of screen.
	      ; mov	cx,80
	      ; rep	stosw
	      ; mov	di,160*49
	      ; mov	cx,80
	      ; rep	stosw
	      ; mov	di,160*2
	      ; mov	cx,80
	      ; rep	stosw
	      ; mov	di,160*47
	      ; mov	cx,80
	      ; rep	stosw
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintHoldRest:					;Print SpaceBar mode for col. 2.
	      ; cmp	[HoldRest],0
	      ; jz	PriHold
PriRest:      ; lea	si,[RestText]
	      ; jmp	short pri20
PriHold:      ;
	      ; lea	si,[HoldText]		;Not used anymore...
pri20:	      ; mov	di,45*160+112
	      ; mov	cx,4
pri30:	      ; movsb
	      ; inc	di
	      ; loop	pri30
	      ; ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetSequence:					;Get current sequence in memory.
		push	es dx
		mov	es,[TrackSeg]
		xor	ah,ah
		mov	al,[TrackSeq]
		and	al,7fh
		mov	si,ax
		mov	al,[es:bx+si]
		test	[TrackSeq],10000000b
		jz	get20
		xor	dx,dx
		mov	ah,[es:bx+si+1]
get20:
		mul	[SeqSize]		;Multiply with size of sequence.

	      ; lea	bx,[Seq]		;BX = True sequence in memory.
	      ; add	bx,ax
		mov	bx,ax
		pop	dx es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetSeqNumber:					;Get current sequence-number.
		push	es
		mov	es,[TrackSeg]
		xor	ah,ah
		mov	al,[TrackSeq]
		and	al,7fh
		mov	si,ax
		mov	al,[es:bx+si]
		test	[TrackSeq],10000000b
		jz	gsn20
		mov	ah,[es:bx+si+1]
gsn20:		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Key:						;Get a key.
		push	bx cx dx si di bp

		call	Midi

		pop	bp di si dx cx bx

		mov	ah,11h			;Extended INT 16h routine (!).
		int	16h
		jz	Key
		mov	ah,10h
		int	16h
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WaitKey:					;Error message wait routine.
		mov	ah,9
		lea	dx,[WaitText]
		int	21h
		jmp	short Key
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HomeSeq:					;Home cursor on the sequence.
		call	GetVoiceCol
		mov	bl,[TrackJump]
		shl	bl,1
		add	al,bl
		add	al,[TrackSpace]
		add	al,[TrackMidSpace]
		mov	[CurCol],al
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClearSeqSeg:					;Fill seq segment with seq #0.
		push	ds es
		mov	es,[SeqSeg]

		mov	di,[SeqSize]
		mov	bx,di
		mov	ax,0ffffh
		xor	dx,dx
		div	[SeqSize]
		mov	cx,ax
		dec	cx
		mov	ds,[SeqSeg]
css20:		push	cx
		xor	si,si
		mov	cx,bx
		rep	movsb
		pop	cx
		loop	css20

		pop	es ds
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClearInstrSeg:					;Clear entire segment.
		push	es
		mov	di,[ClearOffset]
		xor	cx,cx
		sub	cx,di
		mov	es,[InstrSeg]
		xor	ax,ax
		rep	stosb

		mov	cl,1
		call	AllVcSet
		call	PrintVcFlags

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClearTrackSeg:					;Clear/Fill track segment.
		push	es
		mov	es,[TrackSeg]

		mov	cx,[Voices]
cts10:
		push	cx
		mov	ax,[TrackSize]		;Bump to next pos in Track Seg.
		xor	dx,dx
		dec	cx
		mul	cx
		mov	di,ax

		mov	ax,[TrackSize]		;Divide by size of each step...
		xor	dx,dx
		mov	cl,[TrackJump]
		mov	ch,dh
		div	cx
		mov	dl,[TrackJump]
		xor	dh,dh
		sub	ax,dx
		mov	cx,ax
cts20:		lea	si,[TrackBlanks]
		mov	dl,[TrackJump]
cts22:		movsb
		dec	dl			; ...coz they are looped here.
		jne	cts22
		loop	cts20

		lea	si,[TrackEndVal]	;Apply an End-of-Track mark.
		mov	dl,[TrackJump]
cts23:		movsb
		dec	dl
		jne	cts23

		pop	cx
		loop	cts10
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClearVoiceArea: 				;Clear entire voice area.
		push	es
		RESES

		mov	ax,[VoiceRow]
		dec	ax
		dec	ax
		mov	cl,160
		mul	cl
		mov	di,ax
		add	di,2
		xor	ax,ax
		mov	cx,78
		rep	stosw			;First clear voice no. line...
		add	di,160+8

		mov	cx,[Lines]
cva20:
		push	cx			; ...then clear main voice area.
		mov	cx,76
		rep	stosw
		pop	cx
		add	di,8
		loop	cva20

		add	di,160+6		;Now clear the volume line.
		mov	cx,68
		rep	stosw

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VertLine:					;Plot a vertical line.
		cmp	[SkillLines],0
		jz	vl30
		push	es
		RESES
		mov	ax,[VoiceRow]
		dec	ax
		mov	cl,160
		mul	cl
		shl	bx,1
		add	ax,bx			;BX = Column.
		mov	di,ax

		mov	ah,[EdgeColor]
		mov	al,[SkillCornerUp]
		stosw
		add	di,158
		mov	cx,[Lines]
		mov	al,[SkillChar]
vl20:		stosw
		add	di,158
		loop	vl20
		mov	al,[SkillCornerDw]
		stosw
		pop	es
vl30:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ResetVoice:					;Set all voices after SETUP.
		mov	cx,[Voices]
rv23:		mov	bx,cx
		dec	bx
		mov	dl,[VoiceFlags+bx]
		mov	[XVoiceFlags+bx],dl
		mov	ah,5
		call	[dword Interface-2]
		loop	rv23
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintVcFlags:					;Mark state of voice ON/OFF's.
		xor	si,si
pvf10:
		cmp	[XvoiceFlags+si],0
		jz	pvf20
		mov	al,[ONcolor]
		jmp	short pvf30
pvf20:
		mov	al,[OFFcolor]
pvf30:
		mov	[VoiceNoCol+si],al
		inc	si
		cmp	si,9
		jne	pvf10

		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AllVcSet:					;Turn ON or OFF all voice flags.
		push	es
		xor	bx,bx
avo20:		mov	dl,cl			;DH = ON/OFF state (1/0).
		mov	[XVoiceFlags+bx],dl
		mov	ah,5
		push	bx
		call	[dword Interface-2]
		pop	bx
		inc	bx
		cmp	bx,[Voices]
		jne	avo20
		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintVoiceNo:					;Print voice number over voices.
		cmp	[VoiceNoFlag],0
		jne	prn80
		mov	[VoiceNoFlag],1
		push	es di bx
		RESES
		sub	di,320
		mov	bx,[TempWord1]
		mov	ah,[VoiceNoCol+bx]	;First three color positions.
		xor	al,al
		stosw
		stosw
		stosw
		inc	bx
		push	bx
		sub	di,8
		mov	al,bh
		call	HexByte 		;Then four character digits.
		pop	ax
		add	di,4
		call	HexByte
		pop	bx di es		;But only the three can be seen!
prn80:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintVolume:					;Print volumes below voices.
		cmp	[VolumeFlag],0
		jne	prn90
		mov	[VolumeFlag],1
		push	es di bx
		RESES
		mov	al,160
		mov	cx,[Lines]
		inc	cl
		mul	cl
		add	di,ax
		mov	ax,0e00h		;Color.
		stosw
		stosw
		stosw
		sub	di,8
		call	HexByte 		;Then four character digits.
		mov	es,[InstrSeg]
		mov	bx,[TempWord1]
		mov	al,[es:bx+8bh]
		add	di,4
		call	HexByte
		pop	bx di es		;But only the three can be seen!
prn90:		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DefaultSpeed:					;Set the default tune speed.
		mov	bx,[Speed]
		mov	[SpeedVar],bx
		mov	ah,3
		call	[dword Interface-2]
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Memorize:					;Remember where FollowPlay is.
		mov	ax,[StepCount]
		mov	[YStepCount],ax
		mov	ax,[IntByte]
		mov	[YIntByte],ax
		mov	ax,[IntWhere]
		mov	[YIntWhere],ax
		mov	ax,[IntTrackCount]
		mov	[YIntTrackCount],ax

		mov	cx,256
		xor	bx,bx
me56:		mov	ax,[SeqWhere+bx]
		mov	[YSeqWhere+bx],ax
		mov	ax,[FirstSeqLen+bx]
		mov	[YFirstSeqLen+bx],ax
		mov	ax,[TrackCountRes+bx]
		mov	[YTrackCountRes+bx],ax
		inc	bx
		inc	bx
		loop	me56
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Restore:					;Return to where FollowPlay was.
		mov	ax,[YStepCount]
		mov	[StepCount],ax
		mov	ax,[YIntByte]
		mov	[IntByte],ax
		mov	ax,[YIntWhere]
		mov	[IntWhere],ax
		mov	ax,[YIntTrackCount]
		mov	[IntTrackCount],ax

		mov	cx,255
		xor	bx,bx
re56:		mov	ax,[YSeqWhere+bx]
		mov	[SeqWhere+bx],ax
		mov	ax,[YFirstSeqLen+bx]
		mov	[FirstSeqLen+bx],ax
		mov	ax,[YTrackCountRes+bx]
		mov	[TrackCountRes+bx],ax
		inc	bx
		inc	bx
		loop	re56

		mov	ax,[VoiceRow]
		mov	[CurRow],al

		mov	[CurLineCount],0
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintWindow:					;Save background and do window.

		push	ax bx cx dx si di ds es

		ror	al,1
		ror	al,1
		ror	al,1
		ror	al,1
		mov	[cs:WinCol],al
		mov	[cs:BackCol],ah

		mov	ax,0b800h
		mov	es,ax

		cmp	[Chk],0 		;See if position remains.
		jz	pw10
		cmp	[Patch],0
		jz	pw10

		sub	bx,[SubValue]
		sub	dx,[SubValue]
pw10:
		mov	ds,[WinBuffer]

		sub	dl,bl
		xor	dh,dh
		add	dx,2
		mov	[cs:CouLine],dx 	;Number of lines.

		sub	si,di
		add	si,2
		mov	[cs:CouCols],si 	;Number of columns.

		shl	si,1
		shl	di,1

		mov	cl,160			;Get top left corner.
		mov	al,bl
		mul	cl
		add	ax,di
		mov	di,ax
		mov	[cs:WinCoord],ax

		xor	si,si

		push	di

		mov	ax,[es:di]
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,218			;Upper left corner.
		mov	ah,[cs:WinCol]
		stosw

		mov	cx,[cs:CouCols]
		dec	cx
		dec	cx
		dec	cx
pw20:
		mov	ax,[es:di]
		mov	[ds:si],ax
		mov	al,211
		mov	ah,[cs:WinCol]
		stosw				;First line.
		inc	si
		inc	si
		loop	pw20

		mov	ax,[es:di]		;Remember a perfect square.
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,203			;Upper right corner.
		mov	ah,[cs:WinCol]
		stosw

		mov	ax,[es:di]
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,214
		mov	ah,[cs:BackCol]
		stosw

		pop	di
		add	di,160

		mov	cx,[cs:CouLine]
		dec	cx
		dec	cx
		dec	cx
pw30:
		push	cx

		mov	cx,[cs:CouCols]
		dec	cx
		dec	cx
		dec	cx

		push	di

		mov	ax,[es:di]
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,228			;Left side.
		mov	ah,[cs:WinCol]
		stosw
pw40:
		mov	ax,[es:di]
		mov	[ds:si],ax
		mov	al,20h
		mov	ah,[cs:WinCol]
		stosw
		inc	si
		inc	si			;In-between lines.
		loop	pw40

		mov	ax,[es:di]
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,204			;Right side.
		mov	ah,[cs:WinCol]
		stosw

		mov	ax,[es:di]
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,212
		mov	ah,[cs:BackCol]
		stosw				;Shadow.

		pop	di
		add	di,160

		pop	cx

		loop	pw30

		mov	ax,[es:di]		;Lower left corner.
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,198
		mov	ah,[cs:WinCol]
		stosw

		mov	cx,[cs:CouCols]
		dec	cx
		dec	cx
		dec	cx

		push	di
pw45:
		mov	ax,[es:di]
		mov	[ds:si],ax
		mov	al,208
		mov	ah,[cs:WinCol]
		stosw				;Last line.
		inc	si
		inc	si
		loop	pw45

		mov	ax,[es:di]		;Remember a perfect square.
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,199			;Lower right corner.
		mov	ah,[cs:WinCol]
		stosw

		mov	ax,[es:di]		;Last side shadow.
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,212
		mov	ah,[cs:BackCol]
		stosw

		pop	di
		add	di,158

		mov	cx,[cs:CouCols]
		dec	cx
		dec	cx

		mov	ax,[es:di]		;Remember a perfect square.
		mov	[ds:si],ax
		inc	si
		inc	si

		inc	di
		inc	di
pw50:
		mov	ax,[es:di]
		mov	[ds:si],ax
		mov	ah,[cs:BackCol]
		mov	al,196
		cmp	[cs:Top],1
		jz	pw52
		mov	al,220
pw52:		stosw				;Bottom line.
		inc	si
		inc	si
		loop	pw50

		mov	ax,[es:di]
		mov	[ds:si],ax
		inc	si
		inc	si
		mov	al,215
		mov	ah,[cs:BackCol] 	;Lower right shadow corner.
		stosw

		pop	es ds di si dx cx bx ax
		ret

CouCols 	dw	0
CouLine 	dw	0
WinCol		db	0
BackCol 	db	0
WinCoord	dw	0
Top		db	0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ClrWindow:					;Restore window background.

		push	ax bx cx si di ds es

		mov	ax,0b800h
		mov	es,ax

		mov	ds,[WinBuffer]

		mov	cx,[cs:CouLine]
		mov	di,[cs:WinCoord]
		xor	si,si
cw20:
		push	cx
		mov	cx,[cs:CouCols]
		push	di
		rep	movsw
		pop	di
		add	di,160
		pop	cx
		loop	cw20

		pop	es ds di si cx bx ax
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Changed:					;Changes were made to the song.
		push	ax es
		mov	[Touched],1
		mov	ax,0b800h
		mov	es,ax
		mov	[byte es:45*160+150],251
		pop	es ax
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UnChanged:					;The song was saved or the like.
		push	ax es
		mov	[Touched],0
		mov	ax,0b800h
		mov	es,ax
		mov	[byte es:45*160+150],32
		pop	es ax
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetupExe:					;Prepare EXE-file loader.
		mov	ah,62h
		int	21h

		push	es			;Copy filename to PSP.
		mov	es,bx
		lea	si,[RealName]
		mov	di,82h
		mov	cx,10
		rep	movsw
		pop	es
st20:
		mov	[ExePara],0000h 	;Environment segment.
		mov	[ExePara+2],0081h
		mov	[ExePara+4],bx		;Command line.
		mov	[ExePara+6],005ch
		mov	[ExePara+8],bx		;FCB #1.
		mov	[ExePara+10],006ch
		mov	[ExePara+12],bx 	;FCB #2.
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PackFile:					;Compress file into SONGS dir.
		push	ds es ds
		pop	es

		mov	[cs:TempSS],ss
		mov	[cs:TempSP],sp

		mov	ax,4b00h		;Load EXE-file and run it.
		lea	dx,[ExePacker]
		lea	bx,[ExePara]
		int	21h

		mov	ss,[cs:TempSS]
		mov	sp,[cs:TempSP]

		pop	es ds
		ret

TempSS		dw	0
TempSP		dw	0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UnPackFile:					;Decompress file to "TEMP.EDL".
		push	ds es ds
		pop	es

		mov	[cs:TempSS],ss
		mov	[cs:TempSP],sp

		mov	ax,4b00h		;Load EXE-file and run it.
		lea	dx,[ExeUnpack]
		lea	bx,[ExePara]
		int	21h

		mov	ss,[cs:TempSS]
		mov	sp,[cs:TempSP]

		pop	es ds
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FileHandler:					;Set up directory and input.
		push	es

		RESES

		call	EraseBar
		call	NoCursor

		call	Amnesia

		mov	ah,01h			;Small cursor again.
		mov	cx,0405h
		int	10h

		mov	di,6*160
		mov	ax,08dch
		mov	cx,80
		rep	stosw

		mov	ax,08dbh		;Big carpet.
		mov	cx,80*37
		rep	stosw

		mov	ax,08dbh		;Correct some shadows.
		mov	[es:6*160],ax
		mov	[es:6*160+2],ax
		mov	[es:6*160+62],ax
		mov	[es:6*160+132],ax
		mov	[es:6*160+158],ax
		mov	ax,08d7h
		mov	[es:6*160+60],ax
		mov	[es:6*160+130],ax
		mov	[es:6*160+156],ax

	      ; mov	cx,20			;Clean up bottom of window.
	      ; mov	di,43*160
		mov	bx,[FileCol]
		shl	bx,1
	      ; add	di,bx
	      ; mov	ax,08dch
	      ; rep	stosw

		mov	di,[FileCol]
		add	di,1
		mov	bx,12
		mov	si,di
		add	si,13
		mov	dx,37
		mov	ax,080bh
		call	PrintWindow
		mov	bx,8
		mov	dx,10
		call	PrintWindow
		mov	bx,39
		mov	dx,41
		call	PrintWindow

		mov	ax,[FileCol]		;Adjust column of text.
		add	al,2
		mov	[FileTxt1+1],al
		mov	[FileTxt2+1],al

		lea	bx,[FileTxt1]
		call	Print
	      ; lea	bx,[FileTxt2]
	      ; call	Print

		mov	ax,[FileCol]
		add	al,2
		mov	[cs:FileCur],al

		mov	[cs:InpPos],0

		call	FindFiles

		call	Fcursor
fh25:
		call	PrintFiles
fh27:
		call	HomeCurs
		call	BarToInput

		mov	cl,0dfh
		call	PrintBar
fh28:
		mov	cx,8
		mov	di,40*160
		mov	ax,[FileCol]		;Print input string.
		shl	ax,1
		add	ax,4
		add	di,ax
		push	ds cs
		pop	ds
		lea	si,[InputString]
fh29:		movsb
		inc	di
		loop	fh29
		pop	ds
fh30:
		call	Key

		MaxWin=22

		cmp	ah,50h			;Down.
		jne	fh35
		mov	cl,0b0h
		call	PrintBar
		mov	ax,[cs:FileMax]
		cmp	[cs:BarPos],ax
		jz	fh27
		cmp	[cs:BarPos],MaxWin
		ja	fh31
		inc	[cs:BarPos]
		jmp	fh27
fh31:		sub	ax,MaxWin+1
		cmp	[cs:WinPos],ax
		jz	fh27
		inc	[cs:WinPos]
		jmp	fh25
fh35:
		cmp	ah,48h			;Up.
		jne	fh40
		mov	cl,0b0h
		call	PrintBar
		cmp	[cs:BarPos],0
		jz	fh37
		dec	[cs:BarPos]
		jmp	fh27
fh37:		cmp	[cs:WinPos],0
		jz	fh27
		dec	[cs:WinPos]
		jmp	fh25
fh40:
		cmp	ah,51h			;Page down.
		jne	fh47
		mov	cl,0b0h
		call	PrintBar
		mov	cx,MaxWin+1
fh41:		mov	ax,[cs:FileMax]
		cmp	[cs:BarPos],ax
		jz	fh27
		cmp	[cs:BarPos],MaxWin
		ja	fh43
		inc	[cs:BarPos]
		loop	fh41
		jmp	fh27
fh43:		sub	ax,MaxWin+1
		cmp	[cs:WinPos],ax
		jz	fh25
		inc	[cs:WinPos]
		loop	fh41
		jmp	fh25
fh47:
		cmp	ah,49h			;Page up.
		jne	fh50
		mov	cl,0b0h
		call	PrintBar
		mov	cx,MaxWin+1
fh48:		cmp	[cs:BarPos],0
		jz	fh49
		dec	[cs:BarPos]
		loop	fh48
		jmp	fh27
fh49:		cmp	[cs:WinPos],0
		jz	fh25
		dec	[cs:WinPos]
		loop	fh48
		jmp	fh25
fh50:
		cmp	ah,01h			;Escape.
		jz	fh95

		cmp	ah,53h			;Delete right in input.
		jne	fh60
		mov	bx,[cs:InpPos]
fh52:		cmp	bx,7
		jz	fh53
		mov	al,[cs:InputString+bx+1]
		mov	[cs:InputString+bx],al
		inc	bx
		jmp	fh52
fh53:		mov	[cs:InputString+bx],0
		jmp	fh28
fh60:
		cmp	ah,4bh			;Left in input.
		jne	fh65
		cmp	[cs:InpPos],0
		jz	fh30
		dec	[cs:InpPos]
		dec	[cs:FileCur]
		call	Fcursor
		jmp	fh28
fh65:
		cmp	ah,4dh			;Right in input.
		jne	fh70
		cmp	[cs:InpPos],7
		jz	fh30
		jmp	fh81
fh70:
		cmp	ah,0eh			;Backspace.
		jne	fh72
		cmp	[cs:InpPos],0
		jz	fh30
		mov	bx,[cs:InpPos]
		mov	al,[cs:InputString+bx]
		mov	[cs:InputString+bx-1],al
		dec	[cs:InpPos]
		dec	[cs:FileCur]
		push	bx
		call	Fcursor
		pop	bx
		jmp	fh52
fh72:
		cmp	ah,47h			;Home.
		jne	fh74
		call	HomeCurs
		jmp	fh28
fh74:
		cmp	ah,4fh			;End.
		jne	fh78
		mov	[cs:InpPos],7
		mov	ax,[FileCol]
		add	al,2
		add	al,7
		mov	[cs:FileCur],al
		mov	cx,7
		mov	bx,6
fh75:		cmp	[byte cs:InputString+bx],0
		jne	fh76
		dec	bx
		dec	[cs:InpPos]
		dec	[cs:FileCur]
		loop	fh75
fh76:		call	Fcursor
		jmp	fh28
fh78:
		cmp	ah,1ch			;Enter, accept filename.
		jne	fh80

		push	ds es ds
		pop	es
		push	cs
		pop	ds
		mov	cx,8
		lea	si,[InputString]
		lea	di,[FileName]
fh781:		lodsb				;Copy main filename.
		or	al,al
		jz	fh79
		stosb
		loop	fh781
fh79:		lea	si,[Extension]
		mov	cx,5
		rep	movsb
		pop	es ds

		call	SetupExe

		mov	ah,01h			;Big fat cursor.
		mov	cx,000fh
		int	10h

		call	ClrWindow
		pop	es

		call	Cure

		clc				;CF=0 = Filename accepted.
		ret
fh80:
                xor     bx,bx                   ;Exclude certain keys.
fh801:          cmp     ah,[cs:DontType+bx]
                jz      fh30
                inc     bx
                cmp     bx,DontLen
                jne     fh801

		mov	bx,[cs:InpPos]		;Type something.
		mov	[cs:InputString+bx],al
		cmp	[cs:InpPos],7
		jz	fh28
fh81:		inc	[cs:InpPos]
		inc	[cs:FileCur]
		call	Fcursor
		jmp	fh28
fh95:
		mov	ah,01h			;Big fat cursor.
		mov	cx,000fh
		int	10h

		call	ClrWindow
		pop	es

		call	Cure

		stc				;CF=1 = Abort LOAD or SAVE.
		ret

CurrentPos	dw	8
WinPos		dw	0
BarPos		dw	0
InputString	db	8 dup (0)
InpPos		dw	0
Extension	db	'.edl',0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HomeCurs:					;Home cursor on the input.
		mov	[cs:InpPos],0
		mov	ax,[FileCol]
		add	al,2
		mov	[cs:FileCur],al
		jmp	Fcursor
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BarToInput:					;Copy bar name to input name.
		mov	ax,[cs:BarPos]
		add	ax,[cs:WinPos]
		xor	dx,dx
		mov	bx,21
		mul	bx
		mov	si,[cs:CurrentPos]
		add	si,ax

		push	ds es

		lea	di,[InputString]

		mov	ds,[cs:FindSeg]
		mov	ax,cs
		mov	es,ax

		mov	cx,8
bti10:		lodsb
		cmp	al,2eh
		jz	bti20
		stosb
		loop	bti10
bti20:
		xor	al,al			;Clear out rest of the name.
		rep	stosb

		pop	es ds
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Fcursor:					;Position file input cursor.
		mov	ah,02h
		mov	dh,40
		mov	dl,[cs:FileCur]
		xor	bh,bh
		int	10h
		ret

FileCur 	db	0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintBar:					;Print cursor bar in window.
		mov	ax,[cs:BarPos]
		xor	dx,dx
		mov	bx,160
		mul	bx
		mov	bx,[FileCol]
		shl	bx,1
		add	ax,bx
		mov	di,ax
		add	di,13*160+5

		mov	al,cl
		mov	cx,12
pba20:		stosb
		inc	di
		loop	pba20
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintFiles:					;Print files in window hole.
		mov	[cs:FileMode],0

		mov	ax,[cs:WinPos]
		xor	dx,dx
		mov	bx,21
		mul	bx
		mov	si,[cs:CurrentPos]
		add	si,ax

		push	ds

		mov	cx,24			;Number of lines.
		mov	di,13*160
		mov	ax,[FileCol]
		shl	ax,1
		add	di,ax
		add	di,4

		mov	ds,[cs:FindSeg]
pfi20:
		push	si di cx
		mov	cx,8
		cmp	[cs:FileMode],1
		jz	pfi30
pfi25:		lodsb
		cmp	al,2ah			;End of list, no more printing.
		jz	pfi40
		cmp	al,2eh			;Don't print "EDL" extension.
		jz	pfi30
		stosb
		inc	di
		loop	pfi25
pfi30:
		mov	ax,0b020h		;Clear out rest of the name.
		rep	stosw

		pop	cx di si
		add	si,21
		add	di,160
		loop	pfi20

		pop	ds
		ret
pfi40:
		mov	[cs:FileMode],1
		jmp	short pfi30
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FindFiles:					;Copy files to FindSegment.
		push	es ds cs
		pop	ds

		mov	ah,1ah
		lea	dx,[DTAblock]		;Set Disk Transfer Address.
		int	21h

		mov	[cs:FindPointer],0	;Initialize variables.
		nop
		mov	[byte cs:FindSecond],0
		mov	[cs:FileMax],0

		mov	cx,3000 		;Maximum 3000 files!
LoopFind:
		push	cx
		xor	cx,cx			;No special attributes.
		lea	dx,[FileSpec]
		call	FileToSeg
		pop	cx
		jc	lf20
		inc	[cs:FileMax]
		loop	LoopFind
lf20:
		dec	[cs:FileMax]
		cmp	[cs:FileMax],3000
		jb	lf30
		mov	[cs:FileMax],0
lf30:		pop	ds es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FileToSeg:					;Transfer names to a directory.

		cmp	[byte cs:FindSecond],0
		jne	ff21

		mov	ah,4eh			;Find first matching.
		int	21h
		jc	ff30
		mov	[byte cs:FindSecond],1
		jmp	short CopyFind
ff21:
		mov	ah,4fh			;Find next matching.
		int	21h
		jc	ff30
		jmp	short CopyFind
ff30:
		push	ax			;No more files.
		lea	si,[EndMark]
		call	CopyEnd 		;Write an end mark.
		stc
		pop	ax			;Errors: 2=No files, 3=No path.
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CopyFind:					;Copy DTA to directory segment.
		lea	si,[DTAblock]
		add	si,16h
CopyEnd:
		mov	di,[cs:FindPointer]
		mov	es,[cs:FindSeg]

		mov	cx,21
		rep	movsb

		mov	[cs:FindPointer],di
		ret

FindSecond	db	0
FindSeg 	dw	0
FindPointer	dw	0
FileMax 	dw	0
FileMode	db	0

EndMark 	db	21 dup (42)
FileSpec	db	'songs\*.edl',0
DTAblock	db	80h dup (0)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Exists: 					;Check if the file exists.
		mov	ah,4eh
		xor	cx,cx
		lea	dx,[RealName]
		int	21h
		jnc	ex10
		clc
		ret
ex10:
		mov	[Chk],1

		WINDOW	18,21,60,27,1dh,00h

		lea	bx,[ExistsTxt1]
		call	Print
		lea	bx,[ExistsTxt2]
		call	Print
		lea	bx,[ExistsTxt3]
		call	Print

		mov	ah,02h			;Set cursor coordinates.
		mov	dx,1938h
		xor	bh,bh
		cmp	[Patch],0
		jz	ex15
		mov	cx,[SubValue]
		sub	dh,cl
ex15:		int	10h

		mov	[Chk],0
		call	Key
		call	ClrWindow
		cmp	ah,15h			;Only "Y" gets the YES !
		jz	ex30
		stc
		ret
ex30:
		clc
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VoiceBorder:					;Print the solid side border.
		push	es
		RESES

		mov	di,6*160
		mov	cx,38
		mov	ax,08ddh
vb20:		stosw
		add	di,158
		loop	vb20

		mov	di,6*160+158
		mov	cx,38
		mov	ax,08deh
vb30:		stosw
		add	di,158
		loop	vb30

		mov	[word es:6*160],08dbh
		mov	[word es:6*160+158],08dbh
		mov	[word es:43*160],08dbh
		mov	[word es:43*160+158],08dbh

		mov	[word es:6*160+2],08dbh
		mov	[word es:6*160+4],08dch
		mov	[word es:6*160+6],08dch
		mov	[word es:6*160+8],08dch

		mov	[word es:43*160+2],08dbh
		mov	[word es:43*160+4],08dbh
		mov	[word es:43*160+6],08dbh
		mov	[word es:43*160+8],08dbh

		mov	[word es:6*160+148],08dch
		mov	[word es:6*160+150],08dch
		mov	[word es:6*160+152],08dch
		mov	[word es:6*160+154],08dch
		mov	[word es:6*160+156],08d7h

		mov	[word es:43*160+148],08dbh
		mov	[word es:43*160+150],08dbh
		mov	[word es:43*160+152],08dbh
		mov	[word es:43*160+154],08dbh
		mov	[word es:43*160+156],08dbh

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NewVertLine:					;New vertical line by steps.
		push	es
		RESES

		mov	di,7*160
		mov	al,[StepLine]
		add	al,[SkillLines]
		shl	al,1
		xor	ah,ah
		add	di,ax

		mov	[word es:di-160],08dch

		mov	cx,36
		cmp	[Patch],0
		jz	nvl10
		mov	cx,20
		jmp	nvl15
nvl10:
		mov	[word es:di+36*160],08dbh
nvl15:
		mov	ax,08deh		;Left line.
nvl20:		stosw
		add	di,158
		loop	nvl20

		mov	di,7*160+148

		mov	cx,36			;Right line.
		cmp	[Patch],0
		jz	nvl25
		mov	cx,20
nvl25:
		mov	ax,08ddh
nvl30:		stosw
		add	di,158
		loop	nvl30


		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetTimerSpeed:					;Grab timer IRQ speed from data.
		push	es

		mov	es,[InstrSeg]

		mov	bl,[es:8]
		xor	bh,bh
		mov	[TimerSpeed],bx
		xor	cx,cx
		mov	ah,8
		call	[dword Interface-2]

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ConvertSpd:					;Convert old player speeds.
		push	es

		mov	es,[InstrSeg]
		cmp	[byte es:7],4		;Check version number.
		jb	cvs20
		pop	es
		ret
cvs20:
		mov	bx,[SpeedVar]		;Convert speed to newer system.
		shl	bx,1
		mov	ax,[cs:ConvSpd+bx]
		cmp	ax,40h
		jbe	cvs30
		mov	ax,40h
cvs30:		mov	[SpeedVar],ax

		mov	[byte es:7],4		;Convert to new version.

		mov	bx,ax
		mov	ah,3
		call	[dword Interface-2]

		pop	es
		ret

ConvSpd 	dw	40h	;00h
		dw	36h	;01h
		dw	28h	;02h
		dw	20h	;03h û
		dw	1ah	;04h û
		dw	15h	;05h û
		dw	13h	;06h û
		dw	10h	;07h û
		dw	0eh	;08h
		dw	0dh	;09h û
		dw	0ch	;0ah
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Help:						;Print in the bottom left box.
		push	es
		RESES

		mov	di,45*160+4

		mov	cx,3
he10:
		push	cx di
		mov	cx,47
he20:
		lodsb
		stosb
		inc	di
		loop	he20

		pop	di cx
		add	di,160
		loop	he10

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Amnesia:					;Remember the main area.
		push	si di cx ax es ds

		mov	ax,ds
		mov	es,ax

		mov	ax,0b800h
		mov	ds,ax

		mov	si,6*160
		lea	di,[AreaBuffer]
		mov	cx,38*80
		rep	movsw

		pop	ds es ax cx di si
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Cure:						;Restore the main area.
		push	si di cx ax es

		RESES

		lea	si,[AreaBuffer]
		mov	di,6*160
		mov	cx,38*80
		rep	movsw

		pop	es ax cx di si
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ExtSwitch:					;Get a switch in the prompt.
                push    di ds cs
		pop	es

		mov	cx,32			;Clear switch line.
		lea	di,[Switch]
		rep	stosw

		mov	ds,[Psp]
		mov	si,82h
		lea	di,[Switch]
		mov	cl,[cs:80h]
		xor	ch,ch
		jcxz	es60

		lodsb
		cmp	al,'-'                  ;Is the very first a switch?
		jz	es40
		cmp	al,'/'
		jz	es40
		jmp	short es25
es20:
		lodsb
es25:		cmp	al,20h			;First search a space character.
		jne	es50
		lodsb
		cmp	al,'-'                  ;Then see if there is a switch.
		jz	es40
		cmp	al,'/'
		jz	es40
		jmp	short es50
es40:		lodsb
		cmp	al,bl			;What character is with switch.
		jz	es70
es50:		loop	es20

es60:		stc				;No switch found.
                pop     ds di
		ret
es70:
		lodsb				;Switch found, copy extension.
		cmp	al,20h
		jz	es80
		cmp	al,0dh
		jz	es80
		stosb
		loop	es70
es80:
		clc				;Switch found and copied.
                pop     ds di
		ret

Switch		db	64 dup (0)		;Contains text after "-" or "/".
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ExtName:					;Get filename extension.
		push	ds ds
		pop	es
		mov	ds,[Psp]
		mov	si,82h
		mov	cl,[ds:80h]
		xor	ch,ch
		jcxz	en60
en20:
		lodsb
		cmp	al,20h
		jz	en50
		cmp	al,'-'                  ;Test for switch commands.
		jz	en70
		cmp	al,'/'
		jz	en70
		jmp	short en85
en50:		loop	en20

en60:		stc				;Filename not found.
		pop	ds
		ret
en70:
		lodsb
		cmp	al,20h			;Get past that switch thing.
		jz	en20
		loop	en70
		jmp	short en60
en80:
		lodsb				;Copy the filename.
		cmp	al,20h
		jz	en90
		cmp	al,0dh
		jz	en90
en85:		stosb
		loop	en80
en90:
		clc				;Succesful filename processing.
		pop	ds
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PromptLoad:					;Load from prompt name.
		cmp	[ExtLoadNow],0
		jne	plo20
		ret
plo20:
		mov	[ExtLoadNow],0

		mov	ah,62h
		int	21h

		push	es			;Copy filename to PSP.
		mov	es,bx
		lea	si,[EdlName]
		mov	di,82h
		mov	cx,32
		rep	movsw
		pop	es

		call	st20			;Call rest of SetUpExe.

		jmp	f1205			;Go to main load routine.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlF5: 					;Convert/Save music as "D0x".
	       IF DEMO

		call	NotAvailable
		jmp	f69

	       ELSE

		mov	[Chk],1

		WINDOW	27,21,54,27,2ch,00h

		lea	bx,[ConvTxt1]		;Be userfriendly.
		call	Print
		lea	bx,[ConvTxt2]
		call	Print
		lea	bx,[ConvTxt3]
		call	Print

		INPUT	ConvertName,40,26,8,04h

		cmp	[ConvertName],20h	;Empty input aborts totally.
		jz	ctf70

		lea	bx,[ConvTxt4]
		call	Print

		push	es
		lea	si,[ConvertName]
		lea	di,[ConvName]		;Copy filename with extension.
		mov	ax,ds
		mov	es,ax
		mov	cx,8
ctf50:		lodsb
		cmp	al,20h
		jbe	ctf60
		stosb
		loop	ctf50
ctf60:		mov	si,offset ConvExt
		mov	cx,5
		rep	movsb
		pop	es

		call	Convert
ctf70:
		mov	[Chk],0
		jmp	f69

	       ENDIF
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HelpMe: 					;Print and scroll help pages.
		push	es

		mov	si,[HelpPos]

		mov	ax,0b800h
		mov	es,ax
hp20:
		push	si
		mov	di,29*160+4
		mov	cx,13
hp25:		push	cx
		mov	cx,75
		mov	ah,0b0h
hp30:		lodsb				;Print the current position.
		stosw
		loop	hp30
		add	di,10
		pop	cx
		loop	hp25
		pop	si

		call	Key

		cmp	ah,50h			;Down.
		jne	hp50
		cmp	[byte si+(13*75)],0
		jz	hp20
		add	si,75
		jmp	hp20
hp50:
		cmp	ah,48h			;Up.
		jne	hp51
		cmp	si,offset HelpText
		jz	hp20
		sub	si,75
		jmp	hp20
hp51:
		cmp	ah,51h			;Page down.
		jne	hp58
		mov	cx,13
hp53:		cmp	[byte si+(13*75)],0
		jz	hp20
		add	si,75
		loop	hp53
		jmp	hp20
hp58:
		cmp	ah,49h			;Page up.
		jne	hp62
		mov	cx,13
hp61:		cmp	si,offset HelpText
		jz	hp20
		sub	si,75
		loop	hp61
		jmp	hp20
hp62:
		cmp	ah,47h			;Home.
		jne	hp63
		lea	si,[HelpText]
		jmp	hp20
hp63:
		cmp	ah,4fh			;End.
		jne	hp65
hp64:		cmp	[byte si+(13*75)],0
		jz	hp20
		add	si,75
		jmp	short hp64
hp65:
		cmp	ah,01h			;Escape.
		jne	hp20

		mov	[HelpPos],si

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NextSeq:					;Do the next unused sequence.
		cmp	[Mode],1
		jne	Other

		call	NoCursor

		push	es
		mov	es,[TrackSeg]

		mov	dx,[TrackSize]
		mov	bp,[Voices]
		mov	bx,0001h

		push	ds
		mov	ax,es
		mov	ds,ax
ns10:
		mov	cx,bp
		mov	si,4			;Skip the speed value (DWORD).
ns12:
		push	si
ns14:		lodsw
		cmp	ax,0fffeh
		jae	ns20
		cmp	ax,8000h		;Bypass transpositions.
		jae	ns14
		cmp	ax,bx			;Is this sequence present?
		jne	ns14
		inc	bx			;Try the next sequence then.
		pop	si
		jmp	short ns10
ns20:
		pop	si
		add	si,dx
		loop	ns12

		pop	ds

		mov	di,[IntTrackCount]	;Enter the SEQ into track.
		mov	ax,bx
		inc	di
		inc	di
		stosw

		pop	es

		call	Cursor
		jmp	Main
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetVers:					;Print version of music player.
		push	es

		mov	es,[Player]
		mov	ax,[es:9]
		push	ax
		and	al,0fh
		add	al,30h
		mov	[CredVers+4],al
		and	ah,0fh
		add	ah,30h
		mov	[CredVers+1],ah
		pop	ax
		and	al,0f0h
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		add	al,30h
		mov	[CredVers+3],al
		and	ah,0f0h
		shr	ah,cl
		add	ah,30h
		mov	[CredVers],ah

		mov	bl,[es:0bh]		;Print music hardware initials.
		shl	bl,1
		shl	bl,1
		xor	bh,bh
		mov	al,[cs:HardWare+bx]
		mov	[CredCard],al
		mov	al,[cs:HardWare+bx+1]
		mov	[CredCard+1],al
		mov	al,[cs:HardWare+bx+2]
		mov	[CredCard+2],al

		pop	es
		ret

Hardware	db	'ADL ','SBL '
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlF10:					;Input composer name.
		mov	[Chk],1

		call	EraseBar

		WINDOW	19,21,60,28,78h,00h

		lea	bx,[CompTxt1]
		call	Print
		lea	bx,[CompTxt2]
		call	Print
		lea	bx,[CompTxt3]
		call	Print
		lea	bx,[CompTxt4]
		call	Print

		INPUT	Composer,35,27,20,04h

		mov	[Chk],0

		mov	bx,4*160		;Line position.
		lea	bp,[Composer]
		call	PrintString

		push	es
		mov	es,[InstrSeg]
		lea	si,[Composer]
		mov	di,2bh			;Store composer in music data.
		mov	cx,16
		rep	movsw
		pop	es

		call	ClrWindow
		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintString:					;Print the input string in top.
		push	es
		mov	ax,0b800h
		mov	es,ax

		mov	di,bx
		add	di,84			;Erase the line first.
		mov	ax,0b02eh
		mov	cx,22
		rep	stosw

		mov	si,20
pc10:		cmp	[byte ds:bp+si],20h
		ja	pc20
		dec	si			;Get length of the string.
		jns	pc10

		mov	[word es:bx+122],0b04eh ;Write "N/A" for no input.
		mov	[word es:bx+124],0b02fh
		mov	[word es:bx+126],0b041h

		pop	es
		ret
pc20:
		inc	si
		mov	cx,si
		mov	si,bp
		mov	di,bx
		add	di,128
		mov	ax,cx
		shl	ax,1
		sub	di,ax
		mov	ah,0b0h 		;The color of the text.
pc30:
		lodsb
		stosw
		loop	pc30			;Do the actual printing.

		pop	es
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CtrlF9: 					;Input the name of music.
		mov	[Chk],1

		call	EraseBar

		WINDOW	19,21,60,28,78h,00h

		lea	bx,[NameTxt1]
		call	Print
		lea	bx,[NameTxt2]
		call	Print
		lea	bx,[NameTxt3]
		call	Print
		lea	bx,[NameTxt4]
		call	Print

		INPUT	TuneName,33,27,20,04h

		mov	[Chk],0

		mov	bx,2*160		;Line position.
		lea	bp,[TuneName]
		call	PrintString

		push	es
		mov	es,[InstrSeg]
		lea	si,[TuneName]
		mov	di,0bh			;Store name in music data.
		mov	cx,16
		rep	movsw
		pop	es

		call	ClrWindow
		jmp	GoMain
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InputNow:					;Input a string of text.
		cmp	[Chk],0
		jz	inn08
		cmp	[Patch],0		;See if position remains.
		jz	inn08

		sub	bx,[SubValue]
inn08:
		mov	[cs:InpLen],ax
		mov	[cs:InColor],dl

		push	es
		mov	ax,0b800h
		mov	es,ax

		mov	[cs:InLine],bl
		mov	ax,di
		mov	[cs:InCol],al
		mov	[cs:InCol2],al

		mov	[cs:RawPos],0
inn10:
		mov	al,[cs:InLine]		;Calculate matrix position.
		mov	cl,160
		mul	cl
		mov	bl,[cs:InCol2]
		shl	bl,1
		xor	bh,bh
		add	ax,bx
		mov	di,ax

		push	bp
		mov	cx,[cs:InpLen]
inn20:		mov	al,[ds:bp]		;Print the string.
		mov	ah,[cs:InColor]
		stosw
		inc	bp
		loop	inn20
		pop	bp
inn30:
		call	Curs
inn32:
		call	Key

		cmp	ah,4bh			;Left.
		jne	inn40
		cmp	[cs:RawPos],0
		jz	inn32
		dec	[cs:RawPos]
		dec	[cs:InCol]
		jmp	short inn30
inn40:
		cmp	ah,4dh			;Right.
		jne	inn42
		call	InRight
		jmp	short inn30
inn42:
		cmp	ah,47h			;Home.
		jne	inn44
		mov	al,[cs:RawPos]
		sub	[cs:InCol],al
		mov	[cs:RawPos],0
		jmp	inn30
inn44:
		cmp	ah,4fh			;End.
		jne	inn46
		mov	al,[cs:RawPos]
		sub	[cs:InCol],al
		mov	ax,[cs:InpLen]
		dec	al
		add	[cs:InCol],al
		mov	[cs:RawPos],al
		xor	ah,ah
		mov	si,ax
inn45:		cmp	[cs:RawPos],0
		jz	inn30
		cmp	[byte ds:bp+si-1],20h
		ja	inn30
		dec	[cs:RawPos]
		dec	[cs:InCol]
		dec	si
		jmp	short inn45
inn46:
		cmp	ah,53h			;Delete.
		jne	inn54
		mov	cl,[cs:RawPos]
		xor	ch,ch
		mov	si,cx
inn48:		cmp	si,[cs:InpLen]
		jz	inn51
		mov	al,[ds:bp+si+1]
		mov	[ds:bp+si],al
		inc	si
		jmp	inn48
inn51:		mov	[byte ds:bp+si],20h
		jmp	inn10
inn54:
		cmp	ah,0eh			;Backspace.
		jne	inn60
		cmp	[cs:RawPos],0
		jz	inn32
		mov	cl,[cs:RawPos]
		xor	ch,ch
		mov	si,cx
		mov	al,[ds:bp+si]
		mov	[ds:bp+si-1],al
		dec	[cs:RawPos]
		dec	[cs:InCol]
		jmp	inn48
inn60:
		cmp	ah,01h			;Escape.
		jne	inn70
		mov	cx,[cs:InpLen]
		push	es
		mov	ax,ds
		mov	es,ax
		mov	di,bp
		mov	al,20h
		rep	stosb
		pop	es
		mov	al,[cs:RawPos]
		sub	[cs:InCol],al
		mov	[cs:RawPos],0
		jmp	inn10
inn70:
		cmp	ah,1ch			;Enter.
		jne	inn80
		call	NoCursor
		pop	es
		ret
inn80:
                xor     bx,bx                   ;Exclude certain keys.
inn82:          cmp     ah,[cs:DontType+bx]
                jz      inn32
                inc     bx
                cmp     bx,DontLen
                jne     inn82

		mov	cl,[cs:RawPos]		;Just type something.
		xor	ch,ch
		mov	si,cx
		mov	[ds:bp+si],al
		call	InRight
		jmp	inn10

InColor 	db	0
InLine		db	0
InCol		db	0
InCol2		db	0
InpLen		dw	0
RawPos		db	0

DontType        db      0fh     ;Tab
                db      52h     ;Insert
                db      49h     ;Page up
                db      51h     ;Page down
                db      48h     ;Up
                db      50h     ;Down

DontLen=$-DontType
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InRight:
		mov	ax,[cs:InpLen]
		dec	al
		cmp	[cs:RawPos],al
		jz	inr10
		inc	[cs:RawPos]
		inc	[cs:InCol]
inr10:
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Curs:
		mov	ah,02h
		mov	dl,[cs:InCol]
		mov	dh,[cs:InLine]
		xor	bh,bh
		int	10h
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NotAvailable:
	       IF DEMO

		mov	[Chk],1

		call	EraseBar
		call	NoCursor

		WINDOW	20,21,58,28,01dh,00h

		lea	bx,[NATxt1]
		call	Print
		lea	bx,[NATxt2]
		call	Print
		lea	bx,[NATxt3]
		call	Print
		lea	bx,[NATxt4]
		call	Print

		jmp	Key

	       ENDIF
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IntOn:						;Take over new interrupts.
		mov	ax,3505h
		int	21h
		mov	[word cs:Old05],bx
		mov	[word cs:Old05+2],es

		mov	ax,3509h
		int	21h
		mov	[word cs:Old09],bx
		mov	[word cs:Old09+2],es

		push	ds
		mov	ax,cs
		mov	ds,ax

		lea	dx,[New05]		;Disable INT 05h (Print Screen).
		mov	ax,2505h
		int	21h

		lea	dx,[New09]		;Enhanced keyboard handler.
		mov	ax,2509h
		int	21h

		pop	ds
		ret

Old05		dd	0
Old09		dd	0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IntOff: 					;Restore all interrupts.
		push	ds

		mov	ax,2505h
		lds	dx,[cs:Old05]		;Enable INT 05h again.
		int	21h

		mov	ax,2509h
		lds	dx,[cs:Old09]
		int	21h

		pop	ds
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
New05:						;New INT 05h, does nothing.
		mov	al,20h
		out	20h,al
		iret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
New09:
		push	ax ds

		mov	ax,Data
		mov	ds,ax

		in	al,60h			;Direct IN 60h routine.
		mov	[KeyStatus],al

		pop	ds ax

		jmp	[dword cs:Old09]	;Do the normal INT 16h crap.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Keyboard:					;Play on the "QWERTY" keyboard.
		xor	di,di
kb10:
		mov	al,[NoteKeys+di]
		or	al,al
		jne	kb35
		cmp	[KeyON],0
		jne	kb12
		ret
kb12:
		xor	bx,bx			;Gate OFF.
		mov	cx,bx
		xor	ah,ah
		mov	al,[TabCurRow]		;Add with table position.
		sub	al,[TabRow]
		add	ax,[TabStep]
		cmp	[WhichTable],0
		jz	kb16
		add	ax,8000h
kb16:		mov	bp,ax
		mov	ah,9
		call	[dword Interface-2]

		mov	[KeyON],0
		ret
kb35:
		cmp	al,[KeyStatus]
		jz	kb40
		inc	di
		jmp	short kb10
kb40:
		mov	bx,di			;Get the note.
		mov	al,[Octave]
		mov	cl,0ch
		mul	cl
		add	bl,al

		mov	bh,20h			;Gate ON.
		xor	cx,cx
		xor	ah,ah
		mov	al,[TabCurRow]		;Add with table position.
		sub	al,[TabRow]
		add	ax,[TabStep]
		cmp	[WhichTable],0
		jz	kb42
		add	ax,8000h
kb42:		mov	bp,ax
		mov	ah,9
		call	[dword Interface-2]

		mov	[KeyOn],1

		mov	ax,0c06h		;Clear keyboard buffer.
		mov	dl,0ffh
		int	21h

		jmp	Keyboard
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MPU_Read:					;Read data from the MPU-401.
		push	cx dx

		mov	dx,[StatPort]
		mov	cx,800h 		;CX=-1 is too slow for SB16.
mp10:
		in	al,dx
		and	al,al			;Check to see if ready to read.
		jns	mp20
		loop	mp10
mp20:
		mov	dx,[DataPort]		;Ready to read.
		in	al,dx

		pop	dx cx
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MPU_Command:					;Send a command to the MPU-401.
		push	ax bx cx dx

		mov	dx,[DataPort]
		in	al,dx
		mov	dx,[StatPort]
mp30:
		in	al,dx
		and	al,DRR			;Wait for receive ready.
		jne	mp30

		mov	dx,[ComPort]
		mov	al,bl
		out	dx,al
		mov	dx,[StatPort]
		mov	cx,-1
mp40:
		in	al,dx			;Wait for data send ready.
		and	al,DSR
		jns	mp50
		loop	mp40
mp50:
		mov	dx,[DataPort]
		mov	cx,-1
mp60:		in	al,dx			;Wait for acknowledge.
		cmp	al,ACK
		jz	mp70
		loopne	mp60
		stc
		jmp	short mp80
mp70:		clc				;CF=0 if command accepted.

mp80:		pop	dx cx bx ax
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Midi:						;Play from a MIDI keyboard.
		cmp	[MPU_Flag],0
		jne	mi30
		ret
mi30:
		call	MPU_Read

		cmp	al,90h			;Key ON.
		jne	mi40

		call	MPU_Read		;Note.
		mov	bl,al
		sub	bl,24h
		mov	al,[Octave]		;Better add the octave too.
		mov	cl,0ch
		mul	cl
		add	bl,al

		call	GetEmpty

		mov	[cs:WhichNote+si],bl

		call	MPU_Read		;Velocity.
		neg	al
		shr	al,1
		mov	cl,al
		and	cl,3fh
		shr	cl,1			;Only 1fh should be enough.

		mov	bh,20h			;Bit 5=Key ON or OFF.
		mov	ax,si
		mov	ch,al			;Voice (0-8).
		xor	ah,ah
		mov	al,[TabCurRow]		;Add with table position.
		sub	al,[TabRow]
		add	ax,[TabStep]
		cmp	[WhichTable],0
		jz	mi32
		add	ax,8000h
mi32:		mov	bp,ax
		mov	ah,9
		call	[dword Interface-2]

		inc	[cs:VoiceCount]
		cmp	[cs:VoiceCount],9
		jne	Midi
		mov	[cs:VoiceCount],0
		jmp	short Midi		;Check for simultaneous keys.
Releasing:
		call	MPU_Read
mi40:
		cmp	al,80h			;Key OFF.
		jz	mi50

		cmp	al,0d0h 		;Check for aftertouch.
		jz	mi45
		ret
mi45:
		call	MPU_Read		;Vibrato ON or OFF?
		mov	cl,al

		xor	ch,ch
mi47:		mov	dx,[MidiVibrato]	;Vibrato value.
		mov	ah,0ah
		push	cx
		call	[dword Interface-2]	;Enable vibrato.
		pop	cx
		inc	ch
		cmp	ch,9
		jne	mi47
		ret
mi50:
		call	MPU_Read		;Note.
		mov	bl,al
		sub	bl,24h
		mov	al,[Octave]		;Better add the octave too.
		mov	cl,0ch
		mul	cl
		add	bl,al

		call	VoiceActive

		xor	bx,bx
		mov	cl,bl
		xor	ah,ah
		mov	al,[TabCurRow]		;Add with table position.
		sub	al,[TabRow]
		add	ax,[TabStep]
		cmp	[WhichTable],0
		jz	mi52
		add	ax,8000h
mi52:		mov	bp,ax
		mov	ah,9
		call	[dword Interface-2]

		jmp	short Releasing 	;More keys going OFF?

VoiceCount	dw	0			;Polyfonic counter for voices.

WhichNote	db	9 dup (0ffh)		;Which note is played in voice.
						;0ffh=No note played.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VoiceActive:					;Which voice belongs to note.
		xor	di,di
		mov	cx,di
va10:
		cmp	bl,[cs:WhichNote+di]
		jz	va20

		inc	di
		inc	ch
		cmp	di,9
		jne	va10
		xor	di,di
		ret				;If nothing, just forget it.
va20:
		mov	[byte cs:WhichNote+di],0ffh
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetEmpty:					;Only take an empty voice.
		mov	si,[cs:VoiceCount]
		xor	ax,ax
ge20:
		cmp	[byte cs:WhichNote+si],0ffh
		jz	ge30
		inc	ax
		cmp	ax,9
		jne	ge25
		ret				;If nothing, just forget it.
ge25:
		inc	si
		cmp	si,9
		jne	ge20
		xor	si,si
		jmp	short ge20
ge30:
		mov	[cs:VoiceCount],si
		ret
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE         "\lib\hexbyte.lib"
INCLUDE 	"\lib\load.lib"

INCLUDE 	"\lib\memory.lib"
INCLUDE 	"\lib\vga_16.lib"

ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
END		Start
