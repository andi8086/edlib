@echo off
break=off
if "%1"=="" goto end
pkzip songs\%1 music.trk music.seq music.dat
del music.trk >nul
del music.seq >nul
del music.dat >nul
:end
