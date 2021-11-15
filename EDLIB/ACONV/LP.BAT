@echo off
if %@attrib[ACONV.asm,A] == 0 goto run
tasm ACONV
if not exist ACONV.obj goto error
tlink ACONV.obj /x
if not exist ACONV.exe goto error
attrib -a ACONV.asm
:run
echo.
echo.
echo.
echo.
echo Ready to run it...
:error
e:
