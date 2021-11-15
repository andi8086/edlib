@echo off
cdd d:\
xcopy e:collect\commands.mac
attrib +h commands.mac
tasm e:mdrv
tasm e:mplayer
tasm e:mdata
cdd e:\adl-02xx
