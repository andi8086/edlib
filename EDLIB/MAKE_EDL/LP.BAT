@echo off
if %@attrib[MAKE_EDL.ASM,A] == 0 goto run
tasm MAKE_EDL.ASM
if not exist MAKE_EDL.OBJ goto error
tlink MAKE_EDL.OBJ IMPLODE.OBJ,MAKE_EDL /x
if not exist MAKE_EDL.EXE goto error
attrib -a MAKE_EDL.ASM
:run
echo.
echo No errors...
echo.
pause
mode co80,50
keystack 13
:error
