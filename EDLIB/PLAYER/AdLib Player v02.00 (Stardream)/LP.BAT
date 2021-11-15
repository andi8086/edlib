@echo off
e:
tasm %1
if not exist mdrv.obj goto error
if not exist mdata.obj goto error
if not exist mplayer.obj goto error
tlink mdrv mdata mplayer,mtest
if not exist mtest.exe goto error
mtest
keystack 13
:error
c:
