@echo off
title Cleaning up your system...
color 07
mode con: cols=70 lines=15


:confirmation
echo You're going to delete all the files in the .cache folder.
echo.
set /p confirm=y/n^>
if %confirm%==y goto cleanup
if %confirm%==n goto failure


:cleanup
echo Cleaning up your system...
del .cache /y
del ClnUp.bat /y
goto success


:failure
echo Cleanup not done.
echo by GabiBrawl
echo.
echo Press any key to exit...
pause >nul


:success
echo Your system is now cleared up!
echo Now you can start downloading your spotify music!
echo by GabiBrawl
echo.
echo Press any key to launch the downloader.
pause >nul
start SPOTYdl.bat
