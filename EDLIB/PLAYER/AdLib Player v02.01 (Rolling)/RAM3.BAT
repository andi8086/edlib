@echo off
cdd e:\
xcopy c:collect\commands.mac
attrib +h commands.mac
tasm c:mdrv
tasm c:mplayer
tasm c:mdata
cdd c:\work\adlib
