@echo off
tasm %1
tlink mdriver mdata mplayer,mtest /x
mtest
keystack 13
