@echo off
::---------------------------------------
set wm=Multiple
set ver=1.7
set channel=Beta
::set edition= [WebUI or non graphical]
set count=0
::---------------------------------------
title SPOTYdl
color 07
::---------------------------------------
if exist setup.bat (del setup.bat)
if exist Downloads (
	if not "%~1"=="" (goto file_import)
	goto aoff
) else (
	md Downloads
	if not "%~1"=="" (goto file_import)
	goto aoff
)


:aoff ::audio output file format
title SPOTYdl
if exist s.ver (del s.ver)
if exist news.temp (del news.temp)
mode con: cols=72 lines=18
color 07
set of=
cls
echo  Working mode: %wm%; for detailed info type "-wm"
echo.
echo.
echo  Available audio file formats:
echo   1) mp3                 4) opus
echo   2) m4a		 5) ogg
echo   3) flac		 6) wav
echo.
echo  Other options:
echo   a) Help                b) Toggle Working Mode
echo   c) About               d) Version
echo   e) News                f) Changelog
echo.
echo  Input the number that corresponds to your choice.
set /p of=^>^>
if not defined %of% (goto aoffe)
if "%of%"=="1" (set format="mp3" && goto set-link)
if "%of%"=="2" (set format="m4a" && goto set-link)
if "%of%"=="3" (set format="flac" && goto set-link)
if "%of%"=="4" (set format="opus" && goto set-link)
if "%of%"=="5" (set format="ogg" && goto set-link)
if "%of%"=="6" (set format="wav" && goto set-link)
if "%of%"=="a" (set hlp=aoff && goto help)
if "%of%"=="b" (if %wm%==Normal (set wm=Multiple&& goto aoff) else (set wm=Normal&& goto aoff))
if "%of%"=="c" (set goto=aoff&&goto about)
if "%of%"=="d" (goto dvfs)
if "%of%"=="e" (goto news)
if "%of%"=="f" (goto changelog)
if "%of%"=="hi" (echo  Hello and Welcome to SPOTYdl!&&timeout /t 5 >nul&&goto aoff)
if "%of%"=="-wm" (set goto=aoff && goto set_working_mode)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto aoff
:aoffe
echo  You can't leave this field in blank. Try again!
timeout /t 3 >nul
goto aoff


:set-link
if exist s.ver (del s.ver)
mode con: cols=69 lines=9
set link=
cls
echo.
echo   Working mode: %wm%, to change it type "-wm"
echo   Output format: %format%, to change it type "-b"
echo   If you wanna download all songs on a txt file, use "-txt"
echo.
echo   Paste the link to your song/playlist or simply the song name!! :D
set /p link=^>^>
if "%link%"=="-b" goto aoff
if "%link%"=="-wm" (set goto=set-link && goto set_working_mode)
if "%link%"=="-txt" (goto multi)
if not %count% EQU 7 (if not defined link goto blank_invalid) else (echo   DOODLE TIME!! && timeout /t 3 >nul && goto set-link)
:download
cls
echo %link%>>history.txt
spotdl "%link%" --output-format %format% --output .\Downloads\
if %errorlevel% == 0 goto clnup
if %errorlevel% == 1 goto error1
::if %errorlevel% == 2 goto success
:blank_invalid
set /a count=%count%+1
echo   You can't leave this field blank. Try again!
timeout /t 3 >nul
goto set-link


:multi
mode con: cols=72 lines=15
cls
echo.
echo                      Multiple songs downloader mode
echo.
echo.
echo   Now input the location to your text file.
echo   Tip: drag and drop your file here to auto type it's location.
echo   Note: To download all songs from artists, paste the spotify
echo  artists' links in the text file and not the artists' name.
echo   Tip: You can drag your txt file over this app's icon to start
echo  downloading your songs faster!
echo.
echo  To go back, use "-b"
set /p txt=^>^>
if "%txt%"=="history.txt" (
	echo  You have to rename the history file to continue.
	timeout /t 4 >nul
	goto multi
)
if not defined txt goto ibtxt
if %txt%==-b goto set-link
for /F "usebackq tokens=*" %%A in (%txt%) do (
	echo %%A>>history.txt
	spotdl "%%A" --output-format %format% --output .\Downloads\
	)
if %errorlevel% == 0 goto clnup
if %errorlevel% == 1 goto error1
echo  This is yet bugged lol
pause
goto aoff
:ibtxt
echo   You can't leave this field blank. Try again!
timeout /t 3 >nul
goto multi


:set_working_mode
mode con: cols=59 lines=10
set swm=""
cls
echo.
echo                Change BEditor working mode
echo.
::by GabiBrawl
echo   1) Normal mode, will download music once and then exit.
echo   2) Multiple mode, won't exit when you download a music.
echo.
echo   Input the value that corresponds to your choice.
set /p swm=^>^> 
if "%swm%"=="1" (set wm=Normal&&goto %goto%)
if "%swm%"=="2" (set wm=Multiple&&goto %goto%)
echo        The value you entered is invalid. Try again!
timeout /t 3 >nul
goto set_working_mode


:dvfs
if %channel%==Stable (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver">nul
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver">nul
		goto version
	)
) else (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver">nul
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver">nul
		goto version
	)
)


:version
mode con: cols=85 lines=15
set swm=
set sver=no connection
set upd?=yes
set /p sver=<s.ver
cls
echo       -Version menu-
echo  Installed Version: %ver%
echo  Server Version: %sver%
echo  Update channel: %channel%
::echo  Edition: %edition%
echo.
::by GabiBrawl
if not "%sver%"=="no connection" (
if not "%sver%"=="%ver%" (
	if not "%ver%" GTR "%sver%" (
		echo  1^) Install updates
) else (
	set upd?=no
	echo  1^) You traveled thru time to get this version bro
)
) else (
	echo  1^) Reinstall SPOTYdl
)) else (
	echo  1^) No connection
)
echo  2) Change update channel
echo  3) Help
echo  4) Go back
echo  5) Reload server version
echo.
echo  Input the number that corresponds to your choice. 
set /p swm=^>^> 
if not defined swm goto biv
if "%swm%"=="1" (if %upd?%==yes (goto donw_and_inst) else (goto version))
if "%swm%"=="2" (goto update_chnl)
if "%swm%"=="3" (goto help_v)
if "%swm%"=="4" (goto aoff)
if "%swm%"=="5" (if %channel%==Stable (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver">nul
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver">nul
		goto version
	)
) else (
	if exist s.ver (
		del s.ver
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver">nul
		goto version
	) else (
		powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver">nul
		goto version
	)
)
)
echo  The value you entered is invalid. Try again!
timeout /t 3 >nul
goto version
:biv
echo  You can't leave this field blank. Try again!
timeout /t 3 >nul
goto version


:donw_and_inst
cls
echo  Downloading and installing the latest version of SPOTYdl.
echo  Don't close this window.
if %channel%==Stable (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/script.bat -Outfile SPOTYdl.temp" >nul) else (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bscript.bat -Outfile SPOTYdl.temp" >nul)
if %errorlevel%==1 goto fail_github
echo.
echo @echo off>>.\setup.bat
echo title Finishing up>>.\setup.bat
echo del SPOTYdl.bat>>.\setup.bat
echo ren SPOTYdl.temp SPOTYdl.bat>>.\setup.bat
echo start SPOTYdl.bat>>.\setup.bat
echo exit>>.\setup.bat
start setup.bat
exit


:update_chnl
mode con: cols=60 lines=12
cls
echo.
echo   How does this work?
echo   When you change your update channel, you will install
echo  the latest update within the channel you chose.
echo   Not ready to change? Just use [Enter] and you'll go back.
echo.
echo  Currently available channels:
echo  a) Stable
echo  b) Beta
set /p chnl=^>
if "%chnl%"=="a" (set channel=Stable && goto donw_and_inst)
if "%chnl%"=="b" (set channel=Beta && goto donw_and_inst)
if "%chnl%"=="c" (goto version)
if not defined chnl goto version


:file_import
mode con: cols=90 lines=18
set _flnm=%~n1
set _ext=%~x1
set txt=%~1
cls
echo.
if not "%_ext%"==".txt" (
	echo  You can only import a txt file.
	echo  Rename your file, or import other one.
	echo.
	echo  Press any key to exit...
	pause>nul
	exit
)
if "%_flnm%%_ext%"=="history.txt" (
	echo  You have to rename the history file to continue.
	timeout /t 4 >nul
	echo  Press any key to exit...
	pause >nul
	exit
)
echo  Imported file: "%_flnm%%_ext%"
echo.
echo  Chose an audio file format:
echo   1) mp3                 4) opus
echo   2) m4a		 5) ogg
echo   3) flac		 6) wav
set /p fiof=^>^> 
if "%fiof%"=="1" (set format="mp3")
if "%fiof%"=="2" (set format="m4a")
if "%fiof%"=="3" (set format="flac")
if "%fiof%"=="4" (set format="opus")
if "%fiof%"=="5" (set format="ogg")
if "%fiof%"=="6" (set format="wav")
if not "%_flnm%" EQU "02_02_2022" (echo  Reading "%_flnm%" and downloading all listed songs on it.) else (echo Reading "Twosday" and downloading all listed songs on it.)
echo.
for /F "usebackq tokens=*" %%A in ("%txt%") do (
	echo %%A>>history.txt
	spotdl "%%A" --output-format %format% --output .\Downloads\
)
echo  Done! Press any key to exit.
pause >nul
exit

:news
title SPOTYdl - NEWS
mode con: cols=66 lines=35
color 4e
if exist news.temp (
	del news.temp
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/news.temp -Outfile news.temp" >nul
	if %errorlevel%==1 goto fail_github
	goto news_read
) else (
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/news.temp -Outfile news.temp" >nul
	if %errorlevel%==1 goto fail_github
	goto news_read
)
:news_read
if not exist news.temp goto fail_github
cls
echo  ------------------------------NEWS------------------------------
type news.temp |More
echo.
echo.
echo       Congrats! You've read all available news for today!
echo          Press any key to go back to the main menu.
pause>nul
goto aoff

:clnup
cls
echo.
echo   Cleaning things up...
del .\Downloads\.spotdl-cache >nul
:success
echo   Song/Playlist was successfuly downloaded!
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download is completed!', [System.Windows.Forms.ToolTipIcon]::None)}">nul
echo.
if %wm%==Normal (echo Press any key to exit) else (echo Press any key to continue)
pause >nul
if %wm%==Normal (exit) else (goto set-link)


:error1
cls
echo  The music you tried to download was not found. Try again.
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Error; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download failed...', [System.Windows.Forms.ToolTipIcon]::None)}">nul
timeout /t 5 >nul
goto set-link


:changelog
if exist changelog.txt (del changelog.txt)
echo|set /p "=Downloading the changelog now... " <nul
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/changelog.txt -Outfile changelog.txt" >nul
if %errorlevel%==1 goto fail_github
echo Done!
timeout /t 1 >nul
start changelog.txt
goto aoff


:fail_github
color 07
mode con: cols=45 lines=4
cls
echo.
echo  Could not establish connection with GitHub.
echo  Please try again later!
timeout /t 4 > nul
goto aoff


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


:help_v
mode con: cols=62 lines=8
cls
echo                    -Version HELP file-
echo.
echo.
echo   Here you cand check and download new updates for SPOTYdl.
echo   The updating process takes no more than some milliseconds.
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
echo  And here we are!
echo.
echo                                      Welcome to SPOTYdl V%ver%!
echo  by GabiBrawl, 21st march 2022
echo.
echo  Press any key to go back...
pause>nul
goto %goto%
