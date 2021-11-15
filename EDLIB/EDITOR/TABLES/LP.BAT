@echo off
if %@attrib[TAB.asm,A] != 0 goto asm
if %@attrib[CTRL.asm,A] == 0 goto run
:asm
tasm CTRL /m2
if not exist CTRL.obj goto error
tlink CTRL.obj /x
if not exist CTRL.exe goto error
attrib -a CTRL.asm
attrib -a TAB.asm
:run
CTRL
mode co80,50
keystack 13
:error
