@echo off
title Cleaning up your system...
color 07
mode con: cols=70 lines=15


:confirmation
echo  You're going to PERMANENTLY delete all the setup files.
echo  Continue?
set /p confirm=y/n^>
if %confirm%==y goto c1
if %confirm%==n goto failure


:c1
echo.
echo  Would you like to delete python and ffmpeg setup files too?
set /p confirm=y/n^>
if %confirm%==y goto cleanups
if %confirm%==n goto cleanup


:cleanup
echo  Cleaning up your system...
del "SPOTYdl - SETUP.bat" /f /q
del 7z /f /q
del pathed /f /q
del "bitsadmin.exe" /f /q
del ClnUp.bat /f /q
goto success


:cleanups
echo  Cleaning up your system...
del "SPOTYdl - SETUP.bat" /f /q
del 7z /f /q
rd 7z
del pathed /f /q
rd pathed
del "bitsadmin.exe" /f /q
del "ffmpeg-n5.0-latest-win64-gpl-5.0.zip" /f /q
del "python.exe" /f /q
start SPOTYdl.bat
del ClnUp.bat /f /q
exit


:failure
cls
echo  Cleanup not done.
echo  by GabiBrawl
echo.
echo  Press any key to exit...
pause >nul
exit


::success
cls
echo  Your system is now cleared up!
echo  Now you can start downloading your spotify music!
echo  by GabiBrawl
echo.
echo  Press any key to exit and launch SPOTYdl...
pause >nul
start SPOTYdl.bat
exit
