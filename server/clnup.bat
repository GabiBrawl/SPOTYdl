@echo off
title Cleaning up your system...
color 07
mode con: cols=70 lines=15


:confirmation
echo You're going to delete all the setup files.
echo.
set /p confirm=y/n^>
if %confirm%==y goto cleanup
if %confirm%==n goto failure


:cleanup
echo Cleaning up your system...
del "SPOTYdl - SETUP" /y
del "7z.dll" /y
del "7z.exe" /y
del "7-zip.dll" /y
del "BITS_DN.cmd" /y
del "bitsadmin.exe" /y
del "ffmpeg-n5.0-latest-win64-gpl-5.0.zip" /y
del "python-3.10.2-amd64.exe" /y
del ClnUp.bat /y
goto success


:failure
cls
echo Cleanup not done.
echo by GabiBrawl
echo.
echo Press any key to exit...
pause >nul


:success
cls
echo Your system is now cleared up!
echo Now you can start downloading your spotify music!
echo by GabiBrawl
echo.
echo Press any key to launch the downloader.
pause >nul
start SPOTYdl.bat
