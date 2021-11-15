@echo off
cdd e:\
xcopy f:collect\commands.mac
attrib +h commands.mac
xcopy f:samp.dat
tasm f:mdrv
tasm f:mplayer
tasm f:mdata
cdd f:\sbl-01xx
