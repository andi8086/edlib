@echo off
if not exist %1.asm goto error
tasm %1
tlink mdrv minstr mtrack mseq mplayer,mtest /x
mtest
goto end
:error
echo %1 not found.
:end
