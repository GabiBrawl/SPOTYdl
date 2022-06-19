@echo off
::tweak----
set ver=2.1
set prep=temporarily deprecated
set channel=Beta
set setupv=3.1
set debug=false
::---------
set count=0
set SN=%~nx0
set curdir=%~dp0Downloads\
set data=%appdata%\SPOTYdl\
set config=%data%config.txt
set store=%data%store\
set temp=%data%temp\
set packages=%data%packages\
set tools=%data%\tools\
set ziper=%tools%\7z.exe
set pathed=%tools%\pathed.exe
set prepi=%data%\prep.txt
set action=none
set v3=%packages%spotdl\v3.9.6\
set v4=%packages%spotdl\v4\
::---------------------------------------
::if exist %prepi% (del %prepi%)
::taskkill /f /fi "windowtitle eq SP - %~dp0" >nul 2>&1
::(
::	echo %~dp0
::	echo %ver%
::	echo %channel%
::) >%prepi%
::---------------------------------------
title SPOTYdl - SETUP MODE
color 07
::---------------------------------------
if exist %~dp0setup.bat (del %~dp0setup.bat)
if not exist %packages% (md %packages%)
md %data%
if %errorlevel%==0 (goto first_run) else (
	if not exist %config% goto config_error
	< %config% (
		set /p history=
		set /p bitrate=
		set /p spotDL_ver=
		set /p downloads_folder=
		set /p atd=
		set /p cfu=
	)
)
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' EQU '0' (
    goto gotAdmin
)
::---------------------------------------
:folder_chk
if not exist %~dp0%downloads_folder% (
	md %~dp0%downloads_folder%
	echo.>>"%~dp0%downloads_folder%\Desktop.ini"
	echo [.ShellClassInfo]>>"%~dp0%downloads_folder%\Desktop.ini"
	echo ConfirmFileOp=0>>"%~dp0%downloads_folder%\Desktop.ini"
	echo IconResource=%%SystemRoot%%\system32\imageres.dll,-184>>"%~dp0%downloads_folder%\Desktop.ini"
	echo [ViewState]>>"%~dp0%downloads_folder%\Desktop.ini"
	echo Mode=>>"%~dp0%downloads_folder%\Desktop.ini"
	echo Vid=>>"%~dp0%downloads_folder%\Desktop.ini"
	echo FolderType=Music>>"%~dp0%downloads_folder%\Desktop.ini"
	attrib +S +H .\%downloads_folder%\Desktop.ini
	attrib +R .\%downloads_folder%
	start "C:\Windows\System32" ie4uinit.exe -show
)
::if %cfu%==enabled (
::	if exist %temp%s.ver del %temp%s.ver
::if %channel%==Stable (
::	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile %temp%s.ver">nul
::) else (
::	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile %temp%s.ver">nul
::)
::	if not exist %temp%s.ver goto import_check
::	set sver=x
::	set /p sver=<%temp%s.ver
::	if not %sver%==x goto ver_alert
::)
:import_check
if not "%~1"=="" (goto file_importing)
goto main_menu


:file_importing
if %atd%==enabled (title SPOTYdl - %cd%) else (title SPOTYdl)
if not exist %~dp0Downloads\ (md %~dp0Downloads\)
mode con: cols=80 lines=22
set _flnm=%~n1
set _ext=%~x1
set imported=%~1
set err=0
set dwl=0
set scs=0
set ttl=0
set et=0
set ttl_time=Calculating...
if "%bitrate%"=="64" (set "bc=Smallest Size (64kbps)") else (if "%bitrate%"=="128" (set "bc=Medium (128kbps)") else (set "bc=Highest Quality (320kbps)"))
if "%bitrate%"=="64" (set "kbps=64k") else (if %bitrate%==128 (set "kbps=128k") else (set "kbps=320k"))
cls
echo.
if "%_ext%"==".spotdlTrackingFile" (
	echo  Resuming the imported download...
	spotdl "%imported%" --output %curdir%
	del "%curdir%.spotdl-cache" >nul
	echo.
	echo  The imported song was successfuly downloaded!
	echo  Press any key to exit...
	pause >nul
	exit
)
if not "%_ext%"==".txt" (
	mode con: cols=40 lines=6
	echo.
	echo  The imported file type is unsupported.
	echo  Rename your file, or pick another one.
	echo.
	echo  Press any key to exit...
	pause>nul
	exit
)
if "%_flnm%%_ext%"=="history.txt" (
	echo   You have to rename the history file to continue.
	echo.
	echo   If I wouldn't lock the use of the history file with
	echo  it's name, you would get into an infinite loop.
	echo   Why? Cause SPOTYdl reads the history file, and
	echo  will add new entries to it each time it downloads
	echo  a song.
	echo.
	timeout /t 4 >nul
	echo  Press any key to exit...
	pause >nul
	exit
)
echo                                  SPOTYdl v%ver%
echo                                -File Importing-
echo.
echo.
echo  Imported file: "%_flnm%%_ext%"
echo  Downloading to: %curdir%
echo  spotDL version: %spotDL_ver%
echo.
echo  Chose an audio file format:
echo   1) mp3		 4) opus
echo   2) m4a		 5) ogg
if %spotDL_ver%==3 (echo   3^) flac		 6^) wav) else (echo   3^) flac)
echo.
echo  Other options:
echo   a) Toggle Bitrate: %bc%
echo   b) Upon completion: %action% device
echo.
echo  Input the value that corresponds to your choice.
set /p fiof=^>^> 
if not defined fiof (
	echo  You can't leave this feald in blank. Try again!
	timeout /t 3 >nul
	goto file_importing
)
if %fiof%==1 (set format="mp3")
if %fiof%==2 (set format="m4a")
if %fiof%==3 (set format="flac")
if %fiof%==4 (set format="opus")
if %fiof%==5 (set format="ogg")
if %spotDL_ver%==3 (if "%of%"=="6" (set format=wav&& goto file_importing) else if %spotDL_ver%==4 (echo  Sorry, but the value you entered is invalid. Try again! && timeout /t 3 >nul && goto main_menu))
if %fiof%==a (
	if %bitrate%==64 (
		set bitrate=128
	) else (
		if %bitrate%==128 (
			set bitrate=320
		) else (
			set bitrate=64
		)
	)
) && goto file_importing
if %fiof%==b (
	if %action%==none (
		if %action%==suspend (
			set action=hibernate
		) else (
			if %action%==hibernate (
				set action=shutdown
			) else (
				if %action%==shutdown (
					set action=restart
				) else (
					set action=none
				)
			)
		)
	)
) && goto file_importing
if not "%_flnm%" EQU "02_02_2022" (echo  Reading "%_flnm%" and downloading all listed songs on it.) else (echo Reading "Twosday" and downloading all listed songs on it.)
echo.
For /f %%j in ('Find "" /v /c ^< %imported%') Do Set /a ttl=%%j
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
SETLOCAL EnableDelayedExpansion
if %spotDL_ver%==3 (
	for /F "usebackq tokens=*" %%A in ("!imported!") do (
		if !history!==true (echo %%A>>history.txt)
		echo  ^>------------------------------------------------------------^<
		set /a dwl+=1
		echo  Currently Downloading: %%A
		echo  Total #!ttl!; Song #!dwl!; Success #!scs!; Failed #!err!
		echo  Estimated remaining time: !ttl_time!
		set v1=!time!
		spotdl "%%A" --output-format !format! --output !curdir! --bitrate !kbps!
		set v2=!time!
		set /a remaining_songs=!ttl!-!dwl!
		set /a ft=!v2!-!v1!
		set /a ttl_time1=!ft! * !remaining_songs!
		set /a ttl_time2=!ttl_time1! / 60
		set ttl_time=!ttl_time2! minutes
		if !errorlevel!==1 (
			echo %%A>>failed_list.txt
			set /a err+=1
		) else (
			set /a scs+=1
		)
	)
) else (
	for /F "usebackq tokens=*" %%A in ("!imported!") do (
		if !history!==true (echo %%A>>history.txt)
		echo  ^>----------------------------------------------------------------------------^<
		set /a dwl+=1
		echo  Currently Downloading: %%A
		echo  Total #!ttl!; Song #!dwl!; Success #!scs!; Failed #!err!
		echo  Estimated remaining time: !ttl_time!
		set v1=!time!
		spotdl download "%%A" --format !format! --output !curdir! --bitrate !kbps!
		set v2=!time!
		set /a remaining_songs=!ttl!-!dwl!
		set /a ft=!v2!-!v1!
		set /a ttl_time1=!ft! * !remaining_songs!
		set /a ttl_time2=!ttl_time1! / 60
		set ttl_time=!ttl_time2! minutes
		if !errorlevel!==1 (
			echo %%A>>failed_list.txt
			set /a err+=1
		) else (
			set /a scs+=1
		)
	)
)
ENDLOCAL
powercfg /change monitor-timeout-ac 10
powercfg /change monitor-timeout-dc 10
if %action%==suspend (
	rundll32.exe powrprof.dll, SetSuspendState Sleep
) else (
	if %action%==hibernate (
		shutdown /h
	) else (
		if %action%==shutdown (
			shutdown /s
		) else (
			if %action%==restart (
				shutdown /r
			)
		)
	)
)
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'We finished the downloading job. Failed: %err%', [System.Windows.Forms.ToolTipIcon]::None)}">nul
echo.
echo   Done!
echo   There were %err% songs that failed downloading. All
echo  failed songs' names were saved to "failed_list.txt"
echo.
echo   Press any key to quit...
pause >nul
exit


:main_menu
if %atd%==enabled (title SPOTYdl - %~dp0) else (title SPOTYdl)
set curdir=%~dp0%downloads_folder%\
if exist %temp%s.ver (del %temp%s.ver)
if exist %temp%news.temp (del %temp%news.temp)
mode con: cols=72 lines=20
color 07
set of=
if "%bitrate%"=="64" (set "bc=Smallest Size ^(64kbps^)") else (if "%bitrate%"=="128" (set "bc=Medium ^(128kbps^)") else (set "bc=Highest Quality ^(320kbps^)"))
if "%bitrate%"=="64" (set "kbps=64k") else (if %bitrate%==128 (set "kbps=128k") else (set "kbps=320k"))
cls
echo.
echo                              -SPOTYdl v%ver%-
echo.
echo.
echo  Available audio file formats:
echo   1) mp3                 4) opus
echo   2) m4a                 5) ogg
if %spotDL_ver%==3 (echo   3^) flac                6^) wav) else (echo   3^) flac)
echo.
echo  Other options:
if %spotDL_ver%==4 (
	echo   a^) Help                b^) Toggle Bitrate: %bc%
) else (
	echo   a^) Help                b^) No Bitrate available on v3
)
echo   c) List songs          d) Resume downloads
echo   e) News                f) Setup v%setupv%
echo   g) Settings            h) Version
echo   i) Disclaimer          j) About
echo.
echo  Input the value that corresponds to your choice.
set /p of=^>^> 
if not defined of (goto aoffe)
if %of%==1 (set format=mp3&& goto sstd)
if %of%==2 (set format=m4a&& goto sstd)
if %of%==3 (set format=flac&& goto sstd)
if %of%==4 (set format=opus&& goto sstd)
if %of%==5 (set format=ogg&& goto sstd)
if %of%==6 (if %spotDL_ver%==3 (set format=wav&& goto sstd) else (echo  Sorry, but that feature is only available with spotDL v3&& timeout /t 3 >nul&& goto main_menu))
if %of%==a (set hlp=main_menu && goto help)
if %of%==b (
	if %spotDL_ver%==3 (
		(
			echo  The bitrate feature is only available with spotDL v4&& timeout /t 3 >nul && goto main_menu
		)
	) else (
		if "%bitrate%"=="64" (set bitrate=128) else (if "%bitrate%"=="128" (set bitrate=HH) else (set bitrate=64))
	)
		goto main_menu
)
if %of%==c (goto list)
if %of%==d (goto resume_sds)
if %of%==e (goto news)
if %of%==f (goto setup)
if %of%==g (goto settings)
if %of%==h (echo  One moment please... && goto dvfs)
if %of%==i (goto disclaimer)
if %of%==j (goto about)
if %of%==hi (echo  Hello and Welcome to SPOTYdl!&&timeout /t 5 >nul&&goto main_menu)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto main_menu
:aoffe
echo  You can't leave this field in blank. Try again!
timeout /t 3 >nul
goto main_menu


:sstd
if exist s.ver (del s.ver)
mode con: cols=66 lines=12
set link=
cls
echo.
echo                          -Search Song-
echo.
echo.
echo   Now you gotta chose the song you wanna download.
echo   Output audio file format: %format%
echo   To go back just hit [ENTER]
echo.
echo   Paste the link to a song/playlist or simply the song name!! :D
set /p link=^>^> 
if not defined link goto main_menu
if not %count% EQU 7 (if not defined link goto blank_invalid) else (echo   DOODLE TIME!! && timeout /t 3 >nul && goto sstd)
cls
if %history%==true (echo %link%>>history.txt)
if %debug%==false (
	if %spotDL_ver%==3 (
		spotdl "%link%" --output-format %format% --output %curdir%
	) else (
		spotdl download "%link%" --format %format% --output %curdir% --bitrate %kbps%
	)
) else (
	if %spotDL_ver%==3 (
		echo spotdl "%link%" --output-format %format% --output %curdir% --log-level DEBUG
		spotdl "%link%" --output-format %format% --output %curdir% --log-level DEBUG
		pause
	) else (
		echo spotdl download "%link%" --format %format% --output %curdir% --bitrate %kbps% --log-level DEBUG
		spotdl download "%link%" --format %format% --output %curdir% --bitrate %kbps% --log-level DEBUG
		pause
	)
)
if %errorlevel% == 0 goto clnup
if %errorlevel% == 1 goto error1
goto spotDL_trouble
:blank_invalid
set /a count=%count%+1
echo   You can't leave this field in blank. Try again!
timeout /t 3 >nul
goto sstd


:ver_alert
set va=
cls
echo.
echo              -NEW VERSION AVAILABLE-
echo.
echo.
echo  Would you like to upgrade now?
echo   (y/n/d - disables future checks)
echo.
set /p va=^>^> 
if %va%==y (goto update)
if %va%==n (goto import_check)
if %va%==d (
	set cfu=disabled
	call :svs
	goto import_check
)


:resume_sds
set ristf=0
mode con: cols=80 lines=20
cls
echo.
echo                   -Songs resumer-
echo.
echo.
echo  Fetching and resuming all incompleted downloads...
for /R "%curdir%" %%r in (*) do (
	if %%~xr==.spotdlTrackingFile (
		spotdl "%%~r" --output %curdir%
		set /a ristf=%ristf%+1
	)
)
echo.
if not %ristf%==0 (
	echo  All incomplete downloads were successfuly resumed! (%ristf% songs)
	if %spotDL_ver%==3 (del "%curdir%.spotdl-cache" >nul)
) else (
	echo  No resumable downloads available.
)
echo  Press any key to go back...
pause >nul
goto main_menu


:dvfs
if exist %temp%s.ver (del %temp%s.ver)
if %channel%==Stable (
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile %temp%s.ver">nul
) else (
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile %temp%s.ver">nul
)
goto version_menu


:version_menu
mode con: cols=51 lines=23
set swm=
set sver=no connection
set upd?=yes
set /p sver=<%temp%s.ver
cls
echo.
echo                   -Version menu-
echo.
echo.
echo  Installed Version: %ver%
echo  Server Version: %sver%
echo  Update channel: %channel%
echo  Preparatory update: %prep%
echo.
echo  SPOTYdl related features:
::by GabiBrawl
if not "%sver%"=="no connection" (
if not "%sver%"=="%ver%" (
	if not "%ver%" GTR "%sver%" (
		echo   1^) Install updates
	) else (
		set upd?=no
		echo   1^) Stop using leaked builds
	)
) else (
	echo   1^) Reinstall SPOTYdl
)) else (
	echo   1^) No connection
)

for /f %%b in ('dir %store% ^| find "File(s)"') do (set vdb=%%b)
if not %vdb%==0 (
	echo   2^) Swap versions
) else (
	echo   2^) No swap versions available
)
echo   3) Change update channel
echo.
echo  Other features:
echo   a) Help
echo   b) Changelog
echo   [ENTER] Go Back
echo.
echo  Input the number that corresponds to your choice. 
set /p swm=^>^> 
if not defined swm goto main_menu
if %swm%==1 (if %upd?%==yes (goto update) else (goto version_menu))
if %swm%==2 (if not %vdb%==0 (goto swap_menu) else (goto no_available_downgrade_entries))
if %swm%==3 (if %upd?%==yes (goto update_chnl) else (goto version_menu))
if %swm%==a (goto help_v)
if %swm%==b (goto changelog)
echo  The value you entered is invalid. Try again!
timeout /t 3 >nul
goto version_menu


:update
title SPOTdl - upgrade
cls
echo.
echo  Updating SPOTYdl installation files...
echo  DON'T CLOSE THIS WINDOW
copy %SN% %store%%ver%.dsv /y >nul
if %channel%==Stable (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/script.bat -Outfile %temp%SPOTYdl.bat" >nul) else (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bscript.bat -Outfile %temp%SPOTYdl.bat" >nul)
if %errorlevel%==1 goto fail_github
echo @echo off>>.\setup.bat
echo title Finishing up>>.\setup.bat
echo del SPOTYdl.bat>>.\setup.bat
echo copy %temp%SPOTYdl.bat %%~dp0>>.\setup.bat
echo start SPOTYdl.bat>>.\setup.bat
echo exit>>.\setup.bat
start setup.bat
exit


:update_chnl
mode con: cols=60 lines=15
set chnl=
cls
echo.
echo                     -Update channel-
echo.
echo.
echo   When you change your update channel, you will need to
echo  run an update within the version menu.
echo   Not ready to change? Just press [Enter] to go back.
echo.
echo  Currently available channels:
echo  a) Stable
echo  b) Beta
set /p chnl=^>
if "%chnl%"=="a" (set channel=Stable && goto dvfs)
if "%chnl%"=="b" (set channel=Beta && goto dvfs)
if "%chnl%"=="c" (goto version_menu)
if not defined chnl goto version_menu


:setup
for %%a in (
	%tools%
	%ziper%
	%pathed%
) do (
	if not exist %%a (
		goto no_tools
	)
)
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
mode con: cols=63 lines=25
set setup=
cls
echo.
echo                             -SETUP-
echo.
echo.
echo  Features:
echo   1) Install Python
echo   2) Install FFmpeg
echo   3) Install spotDL
echo   4) Install C++ Runtime Environment
echo.
echo  Other Options:
echo   a) Help
echo   b) Uninstaller
echo   [ENTER] Restart app in normal mode
set /p setup=^>^> 
if not defined setup (%WINDIR%\explorer.exe %SN% && exit)
if %setup%==1 (goto ip)
if %setup%==2 (goto iff)
if %setup%==3 (goto is)
if %setup%==4 (goto icre)
if %setup%==a (goto ih)
if %setup%==b (goto uninst)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto setup


:no_tools
md %tools%
cls
echo.
echo  Sorry, but you don't have the required tools to run this program.
echo  Downloading and applying the following tools:
echo.
echo   -^> 7z
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/tree/main/server/tools/7z.exe -Outfile %tools%7z.exe"
if %errorlevel%==1 goto tools_download_fail
echo  33^% done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/tree/main/server/tools/7z.dll -Outfile %tools%7z.dll"
if %errorlevel%==1 goto tools_download_fail
echo  66^% done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/tree/main/server/tools/7-zip.dll -Outfile %tools%7-zip.dll"
if %errorlevel%==1 goto tools_download_fail
echo  100^% done
echo.
echo   -^> ffmpeg
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/tree/main/server/tools/pathed.exe -Outfile %tools%pathed.exe"
if %errorlevel%==1 goto tools_download_fail
echo  33^% done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/tree/main/server/tools/log4net.dll -Outfile %tools%log4net.dll"
if %errorlevel%==1 goto tools_download_fail
echo  66^% done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/tree/main/server/tools/GSharpTools.dll -Outfile %tools%GSharpTools.dll"
if %errorlevel%==1 goto tools_download_fail
echo  100^% done
echo.
echo  Done! Press any key to resume...
pause >nul
goto setup


:tools_download_fail
del %tools%
echo  There was an error downloading the tools. Please try again later.
echo.
echo  Press any key to go back...
pause >nul
goto main_menu


:ip
cls
echo.
echo          -Python Installation-
echo.
echo.
echo  Downloading Python...
if not exist %packages%python-3.10.2-amd64.exe (
	powershell -command "Invoke-WebRequest https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe -Outfile %packages%python-3.10.2-amd64.exe"
	if %errorlevel%==1 goto downloads_err
)
echo  Installing Python...
%packages%python-3.10.2-amd64.exe /quiet InstallAllUsers=1 PrependPath=1 /wait
if %errorlevel%==1 goto python_err
echo  Adding path entries...
start %pathed% /append %appdata%\Python\Python310\Scripts\ /machine /wait
if %errorlevel%==1 goto pathed_err
echo.
echo  Python was installed successfully.
echo  Press any key to go back...
pause >nul
goto setup


:iff
md C:\ffmpeg\
cls
echo.
echo          -FFmpeg Installation-
echo.
echo.
echo  Downloading FFmpeg...
if not exist %packages%ffmpeg-n5.0-latest-win64-gpl-5.0.zip (
	powershell -command "Invoke-WebRequest -Uri https://github.com/GabiBrawl/SPOTYdl/blob/main/server/ffmpeg5.0_x64.zip -Outfile %packages%ffmpeg5.0_x64.zip"
	if %errorlevel%==1 goto downloads_err
)
echo  Unzipping downloaded files...
%tools%\7z.exe e %packages%ffmpeg5.0_x64.zip -oC:\ffmpeg\
if %errorlevel%==1 goto unzip_err
echo  Applying files to the system...
start /wait %tools%\pathed.exe /append C:\ffmpeg\ /machine
if %errorlevel%==1 goto pathed_err
echo.
echo  FFmpeg was installed successfully.
echo  Press any key to go back...
pause >nul
goto setup


:is
set sv=
cls
echo.
echo            -spotDL Installation-
echo.
echo.
echo  What version of spotDL do you wanna install?
echo                     (3/4)
set /p sv=^>^>
if not defined sv (echo  Please input a value between 3 or 4 && timeout /t 3 >nul && goto is)
if %sv%==3 (goto isi)
if %sv%==4 (goto isi)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto is


:isi
echo  Downloading spotDL...
if not exist %v3%requirements.txt (
	echo spotdl>%v3%requirements.txt
	pip download -r %v3%requirements.txt >nul
)
if not exist %v4%requirements.txt (
	echo spotdl>%v4%requirements.txt
	pip download -r %v4%requirements.txt >nul
)
if %sv%==3 (
	echo  Installing spotDL...
	pip install -r %v3%requirements.txt --force --no-index --find-links spotdl
) else (
	echo  Installing spotDL...
	pip install -r %v4%requirements.txt --force --no-index --find-links spotdl
	echo pip install -r %v4%requirements.txt --force --no-index --find-links spotdl
)
if %errorlevel%==1 goto downloads_err
del %config% /f /q
set spotDL_ver=%sv%
(
	echo %history%
	echo %bitrate%
	echo %spotDL_ver%
	echo %downloads_folder%
	echo %atd%
) >%config%
echo.
echo  spotDL was installed successfully.
echo  Press any key to go back...
pause >nul
goto setup


:icre
cls
echo.
echo         -C++ Runtime Environment Installation-
echo.
echo.
echo  Downloading the necessary files...
if not exist %packages%vcredist_x64.exe (
	powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/VC_redist.x64.exe -Outfile %packages%VC_redist.x64.exe"
	if %errorlevel%==1 goto downloads_err
)
echo  Installing the downloaded files... This may take some time.
start /wait %packages%VC_redist.x64.exe /install /quiet /norestart
if %errorlevel%==1 goto cre_err
echo.
echo  The Runtime Environment was installed successfully.
echo  Press any key to go back...
pause >nul
goto setup


:downloads_err
echo   There was an error when trying to download the 
echo  required files. Try again later!
echo.
echo   Press any key to go to the main menu.
pause >nul
goto main_menu


:cre_err
echo   There was an error when trying to install the
echo  Runtime Environment. Try again later!
echo.
echo   Press any key to go back.
pause >nul
goto setup


:unzip_err
echo   There was an error when trying to unzip the
echo  downloaded ffmpeg files. Try again later!
echo.
echo   Press any key to go back.
pause >nul
goto setup


:pathed_err
echo   There was an error when trying to add the
echo  path entries. Try again later!
echo.
echo   Press any key to go back.
pause >nul
goto setup


:python_err
echo   There was an error when trying to install
echo  Python. Try checking your permissions!
echo.
echo   Press any key to go back.
pause >nul
goto setup


:uninst
cls
echo.
echo                         -Uninstallation-
echo.
echo.
echo  Uninstallable dependencies:
echo   1) Uninstall Python
echo   2) Uninstall FFmpeg
echo   3) Uninstall spotDL
echo   4) Uninstall C++ Runtime Environment
echo   5) Uninstall all
echo.
echo  Other options:
echo   [ENTER] Restart the app in normal mode
echo   [ESC] Exit
echo.
echo  What do you wanna uninstall?
set /p uninst=^>^>
if not defined uninst (%WINDIR%\explorer.exe %SN% && exit)
if %uninst%==1 (goto uninst_python)
if %uninst%==2 (goto uninst_ffmpeg)
if %uninst%==3 (goto uninst_spotdl)
if %uninst%==4 (goto uninst_cre)
if %uninst%==5 (goto uninst_all)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto uninst


:uninst_python
cls
echo.
echo  Uninstalling Python...
start /wait %packages%python-3.10.2-amd64.exe /quiet /uninstall
echo.
echo  Python was uninstalled successfully.
echo  Press any key to go back...
pause >nul
goto uninst


:uninst_ffmpeg
cls
echo.
echo  Uninstalling FFmpeg...
delete C:\ffmpeg\ /q /f
echo.
echo  FFmpeg was uninstalled successfully.
echo  Press any key to go back...
pause >nul
goto uninst


:uninst_spotdl
cls
echo.
echo  Uninstalling spotDL...
pip uninstall spotdl
echo.
echo  spotDL was uninstalled successfully.
echo  Press any key to go back...
pause >nul
goto uninst


:uninst_cre
cls
echo.
echo          -C++ Runtime Environment Uninstallation-
echo.
echo.
echo  Uninstalling the C++ Runtime Environment...
start /wait %packages%VC_redist.x64.exe /uninstall /quiet /norestart
if %errorlevel%==1 goto pathed_err
echo.
echo  The C++ Runtime Environment was uninstalled successfully.
echo  Press any key to go back...
pause >nul
goto uninst


:uninst_all
cls
echo.
echo  Uninstalling all dependencies...
echo   - spotDL (25% of the total progress)
pip uninstall spotdl
echo   - Python (50% of the total progress)
start /wait %packages%python-3.10.2-amd64.exe /quiet /uninstall
echo   - FFmpeg (75% of the total progress)
del C:\ffmpeg\ /q /f
echo   - C++ Runtime Environment (100% of the total progress)
start /wait %packages%VC_redist.x64.exe /uninstall /quiet /norestart
echo.
echo  All dependencies were uninstalled successfully.
echo  Press any key to go back...
pause >nul
goto uninst


:nede
echo  The codename of the version you chose doesn't exist.
echo  Please try again...
timeout /t 4 >nul
goto swap_menu


:swap_menu
set dc=
for /f %%b in ('dir %store% ^| find "File(s)"') do (set dmva=%%b)
if %dmva%==0 (goto no_available_downgrade_entries)
set /a mcdm=%dmva%+13
mode con: cols=60 lines=%mcdm%
cls
echo.
echo                         -SWAP MENU-
echo.
echo.
echo  All available swap versions: (current v%ver%)
for /R "%store%" %%A in (*) do (echo   -^> %%~nA ^(%%~zA bytes^))
echo.
echo  Input the codename of the version you wanna swap to.
echo      Not ready to SWAP? Press [ENTER] to go back.
set /p dc=^>^> 
if not defined dc (goto version_menu)
if not exist %store%%dc%.dsv goto nede
copy %SN% %store%%ver%.dsv /y /v >nul
copy %store%%dc%.dsv %cd%\sptdl.bat /y /v >nul
del %config% /f /q >nul
del %temp% /f /q >nul
echo @echo off>>.\setup.bat
echo title Swapping between versions>>.\setup.bat
echo del /f /q SPOTYdl.bat>>.\setup.bat
echo ren sptdl.bat SPOTYdl.bat>>.\setup.bat
echo start SPOTYdl.bat>>.\setup.bat
echo exit>>.\setup.bat
start setup.bat
exit


:no_available_downgrade_entries
mode con: cols=51 lines=6
cls
echo.
echo  There ain't any swap versions available.
echo.
echo  This menu will be unlocked as soon as you update.
echo  Press any key to go back...
pause >nul
goto version_menu


:list
set ftl=
mode con: cols=72 lines=11
if exist %curdir%.spotdl-cache (del %curdir%.spotdl-cache >nul)
if exist SongList.txt (goto overwrite)
cls
echo.
echo                            -SONGS listing-
echo.
echo.
echo   Chose the option that corresponds to the folder you wanna list:
echo.
echo    1^) "Downloads" folder
echo    2^) Select another folder
echo.
set /p ftl=^>^> 
if not defined ftl goto main_menu
if %ftl%==1 (
	set sfl=.\%downloads_folder%\*
	goto slisting
	)
if %ftl%==2 (goto sfsl)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto ftl


:sfsl
set sfl=
set sfsl=
cls
echo.
echo                            -SONGS listing-
echo.
echo.
echo   Now input the location of the folder you wanna list it's music:
echo.
set /p sfsl=^>^> 
set sfl=%sfsl%\
md %sfl% >nul
if not %errorlevel%==0 (goto slisting) else (
	echo You have to input a valid folder location.
	timeout /t 3 >nul
	goto sfsl
)


:slisting
cls
echo.
echo                            -SONGS listing-
echo.
echo.
echo   We're listing all the songs in the selected folder into SongList.txt
echo   Wait a moment please...
for %%f in (%sfl%*) do @echo %%~nf >> SongList.txt
for /f %%b in ('dir %sfl% ^| find "File(s)"') do (set lcount=%%b)
echo   Done! %lcount% entries were registered to "SongList.txt"
echo.
echo   Press any key to go to the main menu...
pause >nul
goto main_menu


:overwrite
mode con: cols=33 lines=5
cls
echo.
echo             -ERROR-
echo  "SongList.txt" already exists.
echo         Overwrite? (y/n)
set /p o=^>^> 
if %o%==y (
	del SongList.txt
	goto list
)
if %o%==n (goto main_menu)
cls
echo The value you entered is invalid. Try again!
timeout /t 3 >nul
goto overwrite


:news
title SPOTYdl - NEWS
mode con: cols=66 lines=35
color 4e
if exist %temp%news.temp (del %temp%news.temp)
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/news.temp -Outfile %temp%news.temp" >nul
if %errorlevel%==1 goto fail_github
:news_read
if not exist %temp%news.temp goto fail_github
cls
echo                               -NEWS-                             
type %temp%news.temp |More
echo.
echo.
echo       Congrats! You've read all available news for today!
echo          Press any key to go back to the main menu.
pause>nul
goto main_menu


:clnup
echo.
if %spotDL_ver%==4 goto success
echo   Cleaning things up...
del %curdir%.spotdl-cache >nul
:success
echo   Song/Playlist was successfuly downloaded!
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download is finished!', [System.Windows.Forms.ToolTipIcon]::None)}">nul
echo.
echo   Press any key to continue...
pause >nul
goto main_menu


:error1
echo.
echo  The song/playlist you tried downloading failed.
echo  ERRC: #3
echo.
echo  Please try again later...
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Error; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download failed...', [System.Windows.Forms.ToolTipIcon]::None)}">nul
timeout /t 5 >nul
goto sstd


:changelog
if exist changelog.txt (del changelog.txt)
echo|set /p "=Downloading the changelog now... " <nul
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/changelog.txt -Outfile %temp%changelog.txt" >nul
if %errorlevel%==1 goto fail_github
echo Done!
timeout /t 1 >nul
start %temp%changelog.txt
goto version_menu


:fail_github
color 07
mode con: cols=45 lines=4
cls
echo.
echo  Could not establish connection with GitHub.
echo  Please try again later!
timeout /t 4 > nul
goto main_menu


:disclaimer
mode con: cols=57 lines=9
cls
echo.
echo                      -Disclaimer-
echo.
echo.
echo   SPOTYdl is not endorsed by, directly affiliated with,
echo  maintained, authorized, or sponsored by spotDL.
echo.
echo   Press any key to go back to the main menu...
pause >nul
goto main_menu


:help
mode con: cols=52 lines=12
cls
echo.
echo                     -HELP file-
echo.
echo.
echo   This script lets you download music using spotDL
echo  more easily.
echo   Start by chosing a song format (1-6), after that
echo  type in the song link/name.
echo.
echo  Press any key to go back...
pause >nul
goto %hlp%


:help_v
mode con: cols=62 lines=9
cls
echo.
echo                    -Version HELP file-
echo.
echo.
echo   Here you cand check and download new updates for SPOTYdl.
echo   The updating process takes no more than some milliseconds.
echo.
echo   Press any key to go back...
pause >nul
goto version_menu


:about
mode con: cols=102 lines=20
cls
echo.
echo                                             ---About---
echo.
echo.
echo   I'm sure of us had already searched about how to download spotify songs without having to buy the
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
echo   by GabiBrawl, 21st march 2022
echo.
echo   Press any key to go back...
pause >nul
goto main_menu


:spotDL_trouble
mode con: cols=54 lines=14
cls
echo.
echo   Hey there! You can't simply run this script without
echo  installing spotDL first... There's a script on my
echo  github to automate the installation!
echo.
echo.
echo   ERRC: #1
echo   ERROR CODE: spotdl was not recognized as a command.
echo    - Maybe your settings are incorrect? Try changing
echo  the currently defined spotDL version. Current: v%spotDL_ver%
echo.
echo   Press any key to go to the main menu...
pause >nul
goto main_menu


:aure
mode con: cols=51 lines=10
if not exist %store% (md %store%)
if not exist %temp% (md %temp%)
set downloads_folder=Downloads
cls
echo.
echo              Welcome back to SPOTYdl!
echo.
echo.
echo   We've just reset the app's configuration, so you
echo  gotta do some configurations to continue.
echo.
echo   Press any key to start...
pause >nul
goto ----1----
:reset
mode con: cols=51 lines=10
if not exist %store% (md %store%)
if not exist %temp% (md %temp%)
set downloads_folder=Downloads
cls
echo.
echo              Welcome back to SPOTYdl!
echo.
echo.
echo   You've just reset the app configuration, so you
echo  gotta do some configurations to continue.
echo.
echo   Press any key to start...
pause >nul
goto ----1----
:first_run
mode con: cols=56 lines=10
if not exist %store% (md %store%)
if not exist %temp% (md %temp%)
set downloads_folder=Downloads
set atd=disabled
set cfu=enabled
cls
echo.
echo                   Welcome to SPOTYdl!
echo.
echo.
echo   Seems like it's your first time running this app, so
echo  you gotta do some configurations to continue.
echo.
echo   Press any key to start...
pause >nul
:----1----
mode con: cols=63 lines=7
cls
echo.
echo   Firstly, do you want us to create a history file to
echo  store your downloads history? (y/n)
echo.
set /p history=^>^> 
if not defined history (
	echo   You gotta chose between y/n ^(yes or no^). Try again!
	timeout /t 3 >nul
	goto ----1----
)
if %history%==y (set history=true) 
if %history%==n (set history=false)
:----2----
cls
mode con: cols=63 lines=7
cls
echo.
echo   Nextly, what's your desired bitrate when downloading songs?
echo                          (64/128/320)
echo.
set /p bitrate=^>^> 
if not %bitrate%==64 (if not %bitrate%==128 (if not %bitrate%==320 (echo  SPOTYdl only supports 64, 128 and 320kbps. Try again! && timeout /t 5 >nul && goto ----2----)))
:----3----
cls
mode con: cols=59 lines=7
cls
echo.
echo   Finnaly, what version of spotDL have you got installed?
echo                           (3/4)
echo.
set /p spotDL_ver=^>^> v
if not %spotDL_ver%==3 (if not %spotDL_ver%==4 (echo  SPOTYdl only supports v3 and v4. Try again! && timeout /t 5 >nul && goto ----3----))
:---save---
md %data%
(
	echo %history%
	echo %bitrate%
	echo %spotDL_ver%
	echo %downloads_folder%
	echo %atd%
	echo %cfu%
) >%config%
mode con: cols=62 lines=7
cls
echo.
echo   Congrats! You have ended the initial configuration!
echo.
echo   Press any key to begin the app usage...
pause >nul
< %config% (
	set /p history=
	set /p bitrate=
	set /p spotDL_ver=
	set /p downloads_folder=
	set /p atd=
	set /p cfu=
)
goto folder_chk


:dfns
mode con: cols=50 lines=13
set nn=
cls
echo.
echo   Chose the new name for the Downloads folder.
echo              Hit ^[ENTER^] to go back
echo                 Use -r to reset
echo.
echo.
set /p nn=^>^> 
if not defined nn (goto settings)
if %nn%==-r (rename %downloads_folder% Downloads && set downloads_folder=Downloads&& goto ss)
rename %downloads_folder% %nn%
if %errorlevel%==1 (
	echo  There was an error while processing the request.
	echo  ERRC: #2
	echo.
	echo  Press any key to go back
	pause >nul
	goto settings
)
set downloads_folder=%nn%
goto ss

:config_error
mode con: cols=46 lines=9
cls
echo.
echo             -Configuration update-
echo.
echo.
echo   Seems like you updated to this version and
echo  newer features were introduced since then..
echo.
echo   Press any key to run the configuration...
pause >nul
goto first_run


:settings
mode con: cols=60 lines=21
set choice=
cls
echo.
echo                           -Settings-
echo.
echo.
echo  Available tweakable settings:
echo   1) History: %history%
echo   2) Bitrate: %bitrate%
echo   3) spotDL: v%spotDL_ver%
echo   4) Folder Name: %downloads_folder%
echo   5) App Title: %atd%
echo   6) Version Check: %cfu%
echo.
echo  Other options:
echo   a) Save changes ^& exit
echo   b) Exit without saving changes
echo   c) Reset the app configuration
echo.
echo  Input the value that corresponds to your choice
set /p choice=^>^> 
if not defined choice (
	echo  You can't leave this feald in blank. Try again!
	timeout /t 3 >nul
	goto settings
)
if %choice%==1 (if %history%==true (set history=false) else (set history=true)) && goto settings
if %choice%==2 (goto bs)
if %choice%==3 (if %spotDL_ver%==3 (set spotDL_ver=4) else (set spotDL_ver=3)) && goto settings
if %choice%==4 (goto dfns)
if %choice%==5 (if %atd%==enabled (set atd=disabled) else (set atd=enabled)) && goto settings
if %choice%==6 (if %cfu%==enabled (set cfu=disabled) else (set cfu=enabled)) && goto settings
if %choice%==a (goto ss)
if %choice%==b (goto reload)
if %choice%==c (goto rs)
echo  Invalid choice. Please try again!
timeout /t 3 >nul
goto settings


:bs
mode con: cols=32 lines=16
set sh=
cls
echo.
echo    Chose your desired bitrate:
echo          64 - Low Quality
echo         128 - Medium Quality
echo         320 - High Quality
echo     [ENTER] - Go back
echo.
echo.
set /p bs=^>^> 
if not defined bs goto settings
if %bs%==64 (
	set bitrate=64
	goto settings
)
if %bs%==128 (
	set bitrate=128
	goto settings
)
if %bs%==320 (
	set bitrate=320
	goto settings
)
echo  Invalid choice. Please try again!
timeout /t 3 >nul
goto bs


:ss
del %config% /f /q
(
	echo %history%
	echo %bitrate%
	echo %spotDL_ver%
	echo %downloads_folder%
	echo %atd%
	echo %cfu%
) >%config%
:reload
< %config% (
	set /p history=
  	set /p bitrate=
	set /p spotDL_ver=
	set /p downloads_folder=
	set /p atd=
	set /p cfu= 
)
goto main_menu
:rs
del %config% /f /q
goto reset
