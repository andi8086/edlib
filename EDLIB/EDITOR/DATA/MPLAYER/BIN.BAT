@echo off
tasm %1
tlink %1 /x
exe2bin %1
del %1.exe
