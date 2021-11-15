@echo off
if %@attrib[%1,A] == 0 goto run
tasm %1
if not exist mdrv.obj goto error
if not exist mplayer.obj goto error
tlink mdrv mplayer,mtest /x
if not exist mtest.exe goto error
attrib -a %1
:run
mtest
c:\dos\mode co80,50
keystack 13
:error
