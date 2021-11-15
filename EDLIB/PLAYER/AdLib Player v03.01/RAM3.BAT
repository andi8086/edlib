@echo off
cdd e:\
xcopy f:collect\commands.mac
attrib +h commands.mac
tasm f:mdrv
tasm f:mplayer
tasm f:mdata
cdd f:\adl-03xx
