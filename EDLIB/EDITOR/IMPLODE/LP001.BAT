@echo off
tasm ed001
tlink ed001.obj implode.obj,ed001 /x
move ed001.exe ..\edlib.001
