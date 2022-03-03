set /p confirm=y/n^>
if %confirm%==y goto c1
if %confirm%==n goto failure


:c1
echo Would you like o delete the python and ffmpeg setups too?
echo.
set /p confirm=y/n^>
if %confirm%==y goto cleanups
if %confirm%==n goto cleanup


:cleanup
echo Cleaning up your system...
del "SPOTYdl - SETUP.bat" /y
del 7z /y
del pathed /y
del "bitsadmin.exe" /y
del ClnUp.bat /y
goto success


:cleanups
echo Cleaning up your system...
del "SPOTYdl - SETUP.bat" /y
del 7z /y
del pathed /y
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
