@echo off
break=off
if not "%1"=="" goto load
dir songs
goto end
:load
pkunzip songs\%1
if not exist music.trk goto end
if not exist music.seq goto end
if not exist music.dat goto end
ed
:end
