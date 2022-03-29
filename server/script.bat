@echo off
echo lol
pause
color 07
mode con: cols=70 lines=15
title SPOTYdl
:set
if exist "Downloads" (cls && cd Downloads && goto output-format) else (goto mdir)


:mdir
cls
md Downloads >nul
goto set


:output-format
cls
echo Available formats:
echo 1) mp3           4) opus
echo 2) m4a		 5) ogg
echo 3) flac		 6) wav
echo 7) help
echo.
echo Input the number that corresponds to your choice.
set /p of=^>
if "%of%"=="/help" (set hlp=output-format && goto help)
if "%of%"=="7" (set hlp=output-format && goto help)
if "%of%"=="1" (set format="mp3" && goto set-link)
if "%of%"=="2" (set format="m4a" && goto set-link)
if "%of%"=="3" (set format="flac" && goto set-link)
if "%of%"=="4" (set format="opus" && goto set-link)
if "%of%"=="5" (set format="ogg" && goto set-link)
if "%of%"=="6" (set format="wav" && goto set-link)
if "%of%"=="mp3" (set format="mp3" && goto set-link)
if "%of%"=="m4a" (set format="m4a" && goto set-link)
if "%of%"=="flac" (set format="flac" && goto set-link)
if "%of%"=="opus" (set format="opus" && goto set-link)
if "%of%"=="ogg" (set format="ogg" && goto set-link)
if "%of%"=="wav" (set format="wav" && goto set-link)
:invalid
cls
echo Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto output-format


:set-link
cls
echo You chose %format%, to change it type /b
echo Now paste the link to your song/playlist or simply the song name!! :D
set /p link=Now: 
if "%link%"=="/b" GOTO output-format



:download
cls
spotdl %link% --output-format %format%
if %errorlevel% == 0 goto success
if %errorlevel% == 1 goto error1
::if %errorlevel% == 2 goto success
pause


:success
cls
echo Song/Playlist was successfuly downloaded!
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download is completed!', [System.Windows.Forms.ToolTipIcon]::None)}"
echo.
echo Press any key to exit
pause >nul
exit
::set action="exit"
::goto cleanup



:error1
cls
echo The music you tried to download was not found. Try again.
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Error; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download failed...', [System.Windows.Forms.ToolTipIcon]::None)}"
timeout /t 5 >nul
goto set-link
::set action="goto set-link"
::goto cleanup



::cleanup
::del ".spotdl-cache" >nul
::%action%


:help
cls
echo Nothing to show here yet.
echo Press any key to go back.
pause >nul
goto %hlp%
