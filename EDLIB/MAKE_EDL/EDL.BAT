@echo off
if not "%1"=="" goto convert
echo.
echo Usage: EDL [Name of ZIP file without extension]
goto end
:convert
pkunzip %1.zip
del %1.zip
copy /b music.trk+music.seq+music.dat temp.edl
make_edl
del temp.edl
ren temp.pak %1.edl
del music.*
echo.
echo ZIP file now converted to EDL format.
:end
