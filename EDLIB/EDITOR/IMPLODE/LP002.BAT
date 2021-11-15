@echo off
tasm ed002
tlink ed002.obj implode.obj,ed002 /x
move ed002.exe ..\edlib.002
