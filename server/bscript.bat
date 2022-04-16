@echo off
::---------------------------------------
set count=0
set ver=1.8
set vcn=1_8
set SN=%~nx0
set wm=Multiple
set channel=Beta
set curdir=%~dp0Downloads\
set data=%appdata%\SPOTYdl\
set config=%data%config.txt
set store=%data%store
::---------------------------------------
title SPOTYdl
color 07
::---------------------------------------
if not exist %store% (md %store%)
if exist setup.bat (del setup.bat)
if not exist Downloads (
	md Downloads
	echo.>>".\Downloads\Desktop.ini"
	echo [.ShellClassInfo]>>".\Downloads\Desktop.ini"
	echo ConfirmFileOp=0>>".\Downloads\Desktop.ini"
	echo LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21798>>".\Downloads\Desktop.ini"
	echo IconResource=%%SystemRoot%%\system32\imageres.dll,-184>>".\Downloads\Desktop.ini"
	echo [ViewState]>>".\Downloads\Desktop.ini"
	echo Mode=>>".\Downloads\Desktop.ini"
	echo Vid=>>".\Downloads\Desktop.ini"
	echo FolderType=Music>>".\Downloads\Desktop.ini"
	attrib +S +H .\Downloads\Desktop.ini
	attrib +R .\Downloads
	start "C:\Windows\System32" ie4uinit.exe -show
)
if not exist %data% (goto first_run) else (
	if not exist %config% goto config_error
	< %config% (
  		set /p history=
	)
)
if not "%~1"=="" (goto file_import)
goto aoff


:aoff ::audio output file format
title SPOTYdl
if exist s.ver (del s.ver)
if exist news.temp (del news.temp)
mode con: cols=72 lines=21
color 07
set of=
cls
echo.
echo  Working mode: %wm%; for detailed info type "-wm"
echo.
echo.
echo  Available audio file formats:
echo   1) mp3                 4) opus
echo   2) m4a                 5) ogg
echo   3) flac                6) wav
echo.
echo  Other options:
echo   a) Help                b) Toggle Working Mode
echo   c) List "Downloads"    d) Version
echo   e) News                f) Changelog
echo   g) Disclaimer          h) About
echo   i) Settings
echo.
echo  Input the value that corresponds to your choice.
set /p of=^>^>
if not defined of (goto aoffe)
if "%of%"=="1" (set format=mp3&& goto sstd)
if "%of%"=="2" (set format=m4a&& goto sstd)
if "%of%"=="3" (set format=flac&& goto sstd)
if "%of%"=="4" (set format=opus&& goto sstd)
if "%of%"=="5" (set format=ogg&& goto sstd)
if "%of%"=="6" (set format=wav&& goto sstd)
if "%of%"=="a" (set hlp=aoff && goto help)
if "%of%"=="b" (if %wm%==Normal (set wm=Multiple&& goto aoff) else (set wm=Normal&& goto aoff))
if "%of%"=="c" (goto list)
if "%of%"=="d" (goto dvfs)
if "%of%"=="e" (goto news)
if "%of%"=="f" (goto changelog)
if "%of%"=="g" (goto disclaimer)
if "%of%"=="h" (goto about)
if "%of%"=="i" (goto settings)
if "%of%"=="hi" (echo  Hello and Welcome to SPOTYdl!&&timeout /t 5 >nul&&goto aoff)
if "%of%"=="-wm" (set goto=aoff && goto set_working_mode)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto aoff
:aoffe
echo  You can't leave this field in blank. Try again!
timeout /t 3 >nul
goto aoff


:sstd
if exist s.ver (del s.ver)
mode con: cols=69 lines=8
set link=
cls
echo.
echo   Now you gotta chose the song you wanna download.
echo   Output audio file format: %format%, to change it type -b
echo.
echo   Paste the link to a song/playlist or simply the song name!! :D
set /p link=^>^>
if "%link%"=="-b" goto aoff
if "%link%"=="-wm" (set goto=sstd && goto set_working_mode)
if not %count% EQU 7 (if not defined link goto blank_invalid) else (echo   DOODLE TIME!! && timeout /t 3 >nul && goto sstd)
cls
if %history%==true (echo %link%>>history.txt)
spotdl "%link%" --output-format %format% --output .\Downloads\
if %errorlevel% == 0 goto clnup
if %errorlevel% == 1 goto error1
::if %errorlevel% == 2 goto success
goto spotDL_trouble
:blank_invalid
set /a count=%count%+1
echo   You can't leave this field in blank. Try again!
timeout /t 3 >nul
goto sstd


:file_import
if not exist %~dp0Downloads\ (md %~dp0Downloads\)
mode con: cols=80 lines=18
set _flnm=%~n1
set _ext=%~x1
set txt=%~1
set "err=0" ::if %errorlevel% EQU 0/1/2 (set /a err=%err%+1)
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
	echo   You have to rename the history file to continue.
	echo.
	echo   If I didn't lock the use of the history file with it's
	echo  original name, you would get into an infinite loop.
	echo   Why? Cause SPOTYdl will be reading the history file,
	echo  and adding new entries to it each time it tries to
	echo  download a song, will create an infinite loop.
	echo.
	timeout /t 4 >nul
	echo  Press any key to exit...
	pause >nul
	exit
)
echo  Imported file: "%_flnm%%_ext%"
echo  Will download to %curdir%
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
	if %history%==true (echo %%A>>history.txt)
	echo Date: %date%, Time: %time% >> %data%\output.txt
	spotdl "%%A" --output-format %format% --output %curdir%
)
echo.
echo  Done!
echo  There were %err% songs that failed downloading.
echo.
echo  Press any key to exit...
pause >nul
exit


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
	if exist s.ver (del s.ver)
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver">nul
	goto version
) else (
	if exist s.ver (del s.ver)
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver">nul
	goto version
)


:version
mode con: cols=85 lines=16
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

for /f %%b in ('dir %store% ^| find "File(s)"') do (set vdb=%%b)
if not %vdb%==0 (echo  2^) Downgrade) else (echo  2^) No downgradable versions available)
echo  3) Change update channel
echo  4) Help
echo  5) Go back
echo  6) Reload server version
echo.
echo  Input the number that corresponds to your choice. 
set /p swm=^>^> 
if not defined swm goto biv
if "%swm%"=="1" (if %upd?%==yes (goto donw_and_inst) else (goto version))
if "%swm%"=="2" (if not %vdb%==0 (goto downgrade_menu) else (goto version))
if "%swm%"=="3" (goto update_chnl)
if "%swm%"=="4" (goto help_v)
if "%swm%"=="5" (goto aoff)
if "%swm%"=="6" (if %channel%==Stable (
	if exist s.ver (del s.ver)
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile s.ver">nul
	goto version
) else (
	if exist s.ver (del s.ver)
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile s.ver">nul
	goto version
))
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
copy %SN% %store%\%ver%.dsv /y >nul
if %channel%==Stable (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/script.bat -Outfile SPOTYdl.temp" >nul) else (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bscript.bat -Outfile SPOTYdl.temp" >nul)
if %errorlevel%==1 goto fail_github
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
set chnl=
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


:downgrade_menu
set dc=
for /f %%b in ('dir %store% ^| find "File(s)"') do (set dmva=%%b)
if %dmva%==0 (goto no_available_downgrade_entries)
set /a mcdm=%dmva%+11
mode con: cols=60 lines=%mcdm%
cls
echo.
echo                       -DOWNGRADE MENU-
echo.
echo  All available versions to downgrade to:
for /R "%store%" %%A in (*) do (echo  -^> %%~nA)
echo.
echo  Input the codename of the version you wanna downgrade to.
set /p dc=^>^> 
if not exist %store%\%dc%.dsv goto nede
copy %SN% %store%\%ver%.dsv /y >nul
copy %store%\%dc%.dsv %cd%\sptdl.bat /y >nul
echo @echo off>>.\setup.bat
echo title Finishing up>>.\setup.bat
echo del SPOTYdl.bat>>.\setup.bat
echo ren sptdl.bat SPOTYdl.bat>>.\setup.bat
echo start SPOTYdl.bat>>.\setup.bat
echo exit>>.\setup.bat
start setup.bat
exit
:nede
echo  The codename of the version you chose doesn't exist.
echo  Please try again...
timeout /t 4 >nul
goto downgrade_menu


:no_available_downgrade_entries
cls
echo.
echo  There ain't any available downgradable version.
echo  Press any key to go back...
pause >nul
goto version


:news
title SPOTYdl - NEWS
mode con: cols=66 lines=35
color 4e
if exist news.temp (del news.temp)
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/news.temp -Outfile news.temp" >nul
if %errorlevel%==1 goto fail_github
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


:list
mode con: cols=62 lines=6
if exist .\Downloads\.spotdl-cache (del .\Downloads\.spotdl-cache >nul)
if exist SongList.txt (goto overwrite)
cls
echo.
echo  We're listing all your downloaded songs into SongList.txt
for /r %%a in (.\Downloads\*) do (@echo %%~na>>SongList.txt)
for /f %%b in ('dir .\Downloads\ ^| find "File(s)"') do (set lcount=%%b)
echo  Done! %lcount% entries were registered.
echo.
echo  Press any key to go back to the main menu...
pause >nul
goto aoff
:overwrite
mode con: cols=33 lines=4
cls
echo             -ERROR-
echo  "SongList.txt" already exists.
echo         Overwrite? (y/n)
set /p o=^>^>
if %o%==y (
	del SongList.txt
	goto lister
)
if %o%==n (goto aoff)
cls
echo The value you entered is invalid. Try again!
timeout /t 3 >nul
goto overwrite

:clnup
cls
echo.
echo   Cleaning things up...
del .\Downloads\.spotdl-cache >nul
:success
echo   Song/Playlist was successfuly downloaded!
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download is completed!', [System.Windows.Forms.ToolTipIcon]::None)}">nul
echo.
if %wm%==Normal (echo  Press any key to exit) else (echo  Press any key to continue)
pause >nul
if %wm%==Normal (exit) else (goto sstd)


:error1
cls
echo  The song/playlist you tried to download failed.
echo  Please try again later...
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Error; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download failed...', [System.Windows.Forms.ToolTipIcon]::None)}">nul
timeout /t 5 >nul
goto sstd


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


:disclaimer
mode con: cols=57 lines=8
cls
echo.
echo                      -Disclaimer-
echo.
echo   SPOTYdl is not endorsed by, directly affiliated with,
echo  maintained, authorized, or sponsored by spotDL.
echo.
echo   Press any key to go back to the main menu...
pause >nul
goto aoff


:help
mode con: cols=52 lines=11
cls
echo.
echo                     -HELP file-
echo.
echo   This script lets you download music using spotDL
echo  more easily.
echo.
echo   Simply chose a song format, and then the spotify
echo  song link/name.
echo.
echo  Press any key to go back...
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
goto aoff


:spotDL_trouble
mode con: cols=54 lines=11
cls
echo.
echo   Hey there! You can't simply run this script without
echo  installing spotDL first... There's a script on my
echo  github to automate the installation!
echo.
echo.
echo   ERROR CODE: spotdl was not recognized as a command.
echo.
echo   Press any key to exit...
pause >nul
exit


:first_run
mode con: cols=56 lines=8
cls
echo.
echo                   Welcome to SPOTYdl!
echo   Seems like it's your first time running this app, so
echo  you gotta do some configurations to continue.
echo.
echo   Press any key to start...
pause >nul
mode con: cols=56 lines=5
cls
echo.
echo   Firstly, do you want us to create a history file to
echo  store your downloads history? (y/n)
echo.
set /p history=^>^>
if %history%==y (set hf=true) 
if %history%==n (set hf=false)
md %data%
(
	echo %hf%
) >%config%
cls
echo.
echo   Congrats! You have ended the configuration!
echo.
echo   Press any key to start using the app...
pause >nul
< %config% (
	set /p history=
)
goto aoff


:settings
mode con: cols=66 lines=12
cls
echo.
echo  Available tweakable settings:
echo   1) History: %history%
echo.
echo  Other options:
echo   a) Save changes ^& exit
echo   b) Exit without saving changes.
echo.
set /p choice=^>^>
if %choice%==1 (goto sh)
if %choice%==a (goto ss)
if %choice%==b (goto reload)
echo  Invalid choice. Please try again!
timeout /t 3 >nul
goto settings

:sh
mode con: cols=49 lines=6
cls
echo.
echo   Do you wanna activate the history file? (y/n)
echo.
set /p sh=^>^>
if %sh%==y (set history=true && goto settings)
if %sh%==n (set history=false && goto settings)
echo   Invalid choice. Please try again!
timeout /t 3 >nul
goto sh

:ss
del %config% /f /q
(
	echo %history%
) >%config%
:reload
< %config% (
	set /p history=
)
goto aoff

:config_error
mode con: cols=46 lines=8
cls
echo.
echo                -config ERROR-
echo.
echo   Seems like you updated to this version and
echo  didn't run the initial configuration.
echo.
echo   Press any key to run the configuration...
pause >nul
goto first_run
