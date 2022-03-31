@echo off
mode con: cols=72 lines=15
color 07
title SPOTYdl
:prepreset
if exist "setup.bat" (del "setup.bat" && goto preset) else (goto preset)
:preset
if exist "Downloads" (cls && cd Downloads && goto set) else (md Downloads && goto set)
:set
cls
set wm=Normal
set ver=1.4.3
set channel=Beta
::set edition= [WebUI or non graphical]
goto output-format



:output-format
if exist s.ver (del "s.ver")
mode con: cols=72 lines=15
set of=
cls
echo  Working mode: %wm%; for detailed info type /wm
echo.
echo.
echo  Available formats:
echo   1) mp3                 4) opus
echo   2) m4a		 5) ogg
echo   3) flac		 6) wav
echo.
echo  Other options:
echo   a) Help                b) Toggle Working Mode
echo   c) About               d) Version
echo.
echo Input the number that corresponds to your choice.
SET of=%~1
SET char=%of:~0,1%
set /p of=^>
if "%of%"=="/help" (set hlp=output-format && goto help)
if "%of%"=="a" (set hlp=output-format && goto help)
if "%of%"=="1" (set format="mp3" && goto set-link)
if "%of%"=="2" (set format="m4a" && goto set-link)
if "%of%"=="3" (set format="flac" && goto set-link)
if "%of%"=="4" (set format="opus" && goto set-link)
if "%of%"=="5" (set format="ogg" && goto set-link)
if "%of%"=="6" (set format="wav" && goto set-link)
if "%of%"=="c" (set goto=output-format&&goto about)
if "%of%"=="b" (if %wm%==Normal (set wm=Multiple&& goto output-format) else (set wm=Normal&& goto output-format))
if "%of%"=="d" (cd..&&goto dvfs)
if "%of%"=="mp3" (set format="mp3" && goto set-link)
if "%of%"=="m4a" (set format="m4a" && goto set-link)
if "%of%"=="flac" (set format="flac" && goto set-link)
if "%of%"=="opus" (set format="opus" && goto set-link)
if "%of%"=="ogg" (set format="ogg" && goto set-link)
if "%of%"=="wav" (set format="wav" && goto set-link)
if "%of%"=="/wm" (set goto=output-format && goto set_working_mode)
:invalid
cls
echo Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto output-format


:set-link
if exist s.ver (del "s.ver")
mode con: cols=85 lines=7
cls
echo  Working mode: %wm%, to change it type /wm
echo  Output format: %format%, to change it type /b
echo  If you wanna download all songs on a txt file, use /multi
echo.
echo  Now paste the link to your song/playlist or simply the song name!! :D
set /p link=Now: 
if "%link%"=="/b" goto output-format
if "%link%"=="/wm" (set goto=set-link && goto set_working_mode)
if "%link%"=="/multi" (goto multi)
:download
cls
spotdl %link% --output-format %format%
if link=="" goto invalid12345
if %errorlevel% == 0 goto success
if %errorlevel% == 1 goto error1
::if %errorlevel% == 2 goto success
pause
:invalid12345
echo  You can't leave this blank.
echo  Try again!
timeout /t 3 >nul
goto set-link


:set_working_mode
set swm=""
cls
echo  Chose BEditor working mode
::by GabiBrawl
echo  1) Normal mode
echo  2) Multiple mode
echo  3) Help
echo.
echo  Input the number that corresponds to your choice.
set /p swm= $ 
if "%swm%"=="1" (set wm=Normal&&goto %goto%)
if "%swm%"=="2" (set wm=Multiple&&goto %goto%)
if "%swm%"=="3" (goto help_wm)
::----------------------------------------------------------------------------------------------------
if "%swm%"=="Normal" (set wm=Normal&&goto %goto%)
if "%swm%"=="Multiple" (set wm=Multiple&&goto %goto%)
if "%swm%"=="help" (goto help_wm)
:invalid
cls
echo  The value you entered is invalid. Try again!
timeout /t 3 >nul
goto set_working_mode


:multi
mode con: cols=72 lines=10
cls
echo                      Multiple songs downloader mode
echo.
echo.
echo   Now input the location to your text file.
echo   Tip: drag and drop your file here to auto type it's location.
echo   Note: To download all songs from multiple artists, paste the spotify
echo  artists' links in the text file and not the artist name.
echo.
echo  To go back, use /b
set /p txt=^>
if %txt%==/b goto set-link
for /F "usebackq tokens=*" %%A in (%txt%) do spotdl %%A --output-format %format%
if %errorlevel% == 0 goto success
if %errorlevel% == 1 goto error1
echo This is yet bugged lol
pause
goto output-format


:dvfs
if %channel%==Public (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver"
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver"
		goto version
	)
) else (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver"
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver"
		goto version
	)
)

:version
mode con: cols=85 lines=15
set swm=""
set sver=no connection
set /p sver=<s.ver
cls
echo       -Version menu-
echo  Installed Version: %ver%
echo  Server Version: %sver%
echo  Update channel: %channel%
::echo  Edition: %edition%
echo.
::by GabiBrawl
echo  1) Install updates
echo  2) Change update channel
echo  3) Help
echo  4) Go back
echo  5) Reload server version
echo.
echo  Input the number that corresponds to your choice.
echo  NOTE: you don't need to install updates if server and installed versions are equal 
set /p swm= $ 
if "%swm%"=="1" (goto donw_and_inst)
if "%swm%"=="2" (goto update_chnl)
if "%swm%"=="3" (goto help_v)
if "%swm%"=="4" (cd Downloads && goto output-format)
if "%swm%"=="5" (if %channel%==Public (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver"
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver"
		goto version
	)
) else (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver"
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver"
		goto version
	)
)
)
:invalid
cls
echo  The value you entered is invalid. Try again!
timeout /t 3 >nul
cd Downloads
goto version



:donw_and_inst
if %cd%==Downloads (cd..)
cls
echo  Downloading and installing the latest version of SPOTYdl.
echo  Don't close this window.
if %channel%==Public (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/script.bat -Outfile SPOTYdl.temp") else (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bscript.bat -Outfile SPOTYdl.temp")
if %errorlevel%==1 goto fail_github
echo @echo off>>.\setup.bat
echo title Finishing up>>.\setup.bat
echo del SPOTYdl.bat>>.\setup.bat
echo ren SPOTYdl.temp SPOTYdl.bat>>.\setup.bat
echo start SPOTYdl.bat>>.\setup.bat
echo exit>>.\setup.bat
start setup.bat
exit



:fail_github
cls
echo.
echo  Could not establish connection with GitHub.
echo  Please try again later!
timeout /t 4 > nul
goto version


:update_chnl
cls
echo  How does this work?
echo  When you change your update channel, you will install
echo  the latest update within the channel you chose.
echo.
echo  Currently available channels:
echo  a) Public
echo  b) Beta
echo  c) go back
set /p chnl=^>
if %chnl%==a (set channel=Public && goto donw_and_inst)
if %chnl%==b (set channel=Beta && goto donw_and_inst)
if %chnl%==c (goto version)
:invalid
cls
echo  The value you entered is invalid. Try again!
timeout /t 3 >nul
goto set_working_mode




:success
cls
echo Song/Playlist was successfuly downloaded!
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download is completed!', [System.Windows.Forms.ToolTipIcon]::None)}"
echo.
if %wm%==Normal (echo Press any key to exit) else (echo Press any key to continue)
pause >nul
if %wm%==Normal (exit) else (goto set-link)
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
echo                    -HELP file-
echo  This script lets you download music with spotDL
echo more easily.
echo.
echo  Simply chose a song format, and then the spotify
echo song link/name.
pause >nul
goto %hlp%



:help_wm
mode con: cols=55 lines=14
cls
echo                -WorkingMode HELP file-
echo.
echo.
echo    Normal mode will make SPOTYdl download music
echo   only once, then exit.
echo    Multiple mode will let you download music
echo   multiple times. Search for one music, and it'll
echo   prompt you again for music location without exiting!
echo.
echo   Press any key to go back... && pause >nul && goto set_working_mode



:help_v
mode con: cols=60 lines=14
cls
echo                -Version HELP file-
echo.
echo.
echo   Here you cand check and download new updates for SPOTYdl.
echo  Just check if server and installed versions are equal. If
echo  not, you may want to update.
echo   The updating process takes no more than some seconds.
echo.
echo   Press any key to go back... && pause >nul && goto version




:about
mode con: cols=102 lines=20
cls
echo.
echo                                           ---About---
echo.
echo  I'm sure of us had already searched about how to download spotify songs without having to buy the
echo  "Premium" they offer us. So, I searched about that, and I found spotDL, a project that helps people
echo  downloading spotify songs for free, legally, from youtube. Initially, when I saw all the setup I had
echo  to do, I abandoned. But after some more research, I found out that spotDL was my best choice. So I
echo  installed it, and it worked nicely, but it's not motivating to have to open cmd each time I gotta
echo  download a song. So I created an automated script to chose format and song link. Working great, but
echo  once again, I wanna publish it. So I created a setup to download and setup everything automaticaly,
echo  so we don't need to go thru all that painful process of installation, nor usage.
echo.
echo  Soon a WebUI version will be out. SPOTYdl is now implemented with an update system, so you can
echo  upgrade anytime. Check out "Version" for more info! :D
echo  And here we are!
echo.
echo                                      Welcome to SPOTYdl V%ver%!
echo  by GabiBrawl, 21st march 2022
echo.
echo  Press any key to go back...
pause>nul
goto %goto%
