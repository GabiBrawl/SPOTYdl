@echo off
::tweak----
set ver=2.4
set channel=Stable
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
set info=%data%info\
set users=%data%users\
set puser=%users%\public\
set devid=%users%%logged_username%\device.id
set logged=%data%logged.txt
title SPOTYdl - setup_menu MODE
color 07
set script_path=%~dp0
set sp="%script_path:~0,-1%\"
cd %sp%
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
if not exist %sp%"%downloads_folder%" (
	md %sp%"%downloads_folder%"
	echo.>>%sp%"%downloads_folder%"\Desktop.ini"
	echo [.ShellClassInfo]>>%sp%"%downloads_folder%"\Desktop.ini"
	echo ConfirmFileOp=0>>%sp%"%downloads_folder%"\Desktop.ini"
	echo IconResource=%%SystemRoot%%\system32\imageres.dll,-184>>%sp%"%downloads_folder%"\Desktop.ini"
	echo [ViewState]>>%sp%"%downloads_folder%"\Desktop.ini"
	echo Mode=>>%sp%"%downloads_folder%"\Desktop.ini"
	echo Vid=>>%sp%"%downloads_folder%"\Desktop.ini"
	echo FolderType=Music>>%sp%"%downloads_folder%"\Desktop.ini"
	attrib +S +H .\%downloads_folder%\Desktop.ini
	attrib +R .\%downloads_folder%
	start "C:\Windows\System32" ie4uinit.exe -show
)
if not exist %logged% goto login_menu
< %logged% (
	set /p logged_username=
	echo %logged_username%
	pause
)
if "logged_username"=="Admin" (del %logged% && goto folder_chk)
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
set fiof=
if "%bitrate%"=="64" (set "bc=Smallest File Size (64kbps)") else (if "%bitrate%"=="128" (set "bc=Medium Audio Quality (128kbps)") else (set "bc=Best Audio Quality (320kbps)"))
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
echo  spotDL version: %spotDL_ver%, restart in normal mode to toggle in settings
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
if %fiof%==1 (set format=mp3 && goto s_fi_start)
if %fiof%==2 (set format=m4a && goto s_fi_start)
if %fiof%==3 (set format=flac && goto s_fi_start)
if %fiof%==4 (set format=opus && goto s_fi_start)
if %fiof%==5 (set format=ogg && goto s_fi_start)
if %spotDL_ver%==3 (if "%of%"=="6" (set format=wav&& goto file_importing))
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
		set action=suspend
		goto file_importing
	) else (
		if %action%==suspend (
			set action=hibernate
			goto file_importing
		) else (
			if %action%==hibernate (
				set action=shutdown
				goto file_importing
			) else (
				if %action%==shutdown (
					set action=restart
					goto file_importing
				) else (
					set action=none
					goto file_importing
				)
			)
		)
	)
)
echo  Invalid choice! Try again. :^)
timeout /t 3 >nul
goto file_importing
:s_fi_start
if not "%_flnm%" EQU "02_02_2022" (echo  Reading "%_flnm%" and downloading all listed songs on it.) else (echo Reading "Twosday" and downloading all listed songs on it.)
echo.
For /f %%j in ('Find "" /v /c ^< %imported%') Do Set /a ttl=%%j
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
SETLOCAL EnableDelayedExpansion
if %spotDL_ver%==3 (
	mode con: cols=80 lines=5
	for /F "usebackq tokens=*" %%A in ("!imported!") do (
		if !history!==true (echo %%A>>history.txt)
		echo  ^>----------------------------------------------------------------------------^<
		set /a dwl+=1
		echo  Currently Downloading: %%A
		echo  Downloading song #!dwl! out of #!ttl! entries
		echo  Estimated remaining time: !ttl_time!
		set v1=!time!
		spotdl "%%A" --output-format !format! --output "!curdir!" >nul
		set v2=!time!
		set /a remaining_songs=!ttl!-!dwl!
		set /a ft=!v2!-!v1!
		set /a ttl_time1=!ft! * !remaining_songs!
		set /a ttl_time2=!ttl_time1! / 60
		set ttl_time=!ttl_time2! minutes
	)
) else (
	mode con: cols=80 lines=11
	for /F "usebackq tokens=*" %%A in ("!imported!") do (
		if !history!==true (echo %%A>>history.txt)
		echo  ^>----------------------------------------------------------------------------^<
		set /a dwl+=1
		echo  Currently Downloading: %%A
		echo  Total #!ttl!; Song #!dwl!; Success #!scs!; Failed #!err!
		echo  Estimated remaining time: !ttl_time!
		set v1=!time!
		spotdl download "%%A" --format !format! --output "!curdir!" --bitrate !kbps! >nul
		set v2=!time!
		set /a remaining_songs=!ttl!-!dwl!
		set /a ft=!v2!-!v1!
		set /a ttl_time1=!ft! * !remaining_songs!
		set /a ttl_time2=!ttl_time1! / 60
		set ttl_time=!ttl_time2! minutes
		if !errorlevel!==0 (
			set /a scs+=1
			cls
		) else (
			echo %%A>>failed_list.txt
			set /a err+=1
			cls
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
if %atd%==enabled (title SPOTYdl - %logged_username% - %~dp0) else (title SPOTYdl - %logged_username%)
set curdir=%~dp0%downloads_folder%\
if exist %temp%news.temp (del %temp%news.temp)
if %logged_username%==Admin (goto :control_panel)
mode con: cols=80 lines=20
color 07
set of=
if "%bitrate%"=="64" (set "bc=Smallest File Size ^(64kbps^)") else (if "%bitrate%"=="128" (set "bc=Medium Audio Quality ^(128kbps^)") else (set "bc=Best Audio Quality ^(320kbps^)"))
if "%bitrate%"=="64" (set "kbps=64k") else (if %bitrate%==128 (set "kbps=128k") else (set "kbps=320k"))
cls
echo.
echo                                 -SPOTYdl v%ver%-
echo.
echo.
echo  Available audio file formats:
echo   1) mp3                      4) opus
echo   2) m4a                      5) ogg
if %spotDL_ver%==3 (echo   3^) flac                     6^) wav) else (echo   3^) flac)
echo.
echo  Other options:
if %spotDL_ver%==4 (
	echo   a^) Help                     b^) Toggle Bitrate: %bc%
) else (
	echo   a^) Help                     b^) No Bitrate available on v3
)
echo   c) List songs               d) Resume downloads
echo   e) Manual Audio Matching    f) Setup v%setupv%
echo   g) BSync                    h) Users Beta: %logged_username%
echo   i) Settings                 j) Version
echo.
echo  Input the value that corresponds to your choice.
set /p of=^>^> 
if not defined of (goto aoffe)
if %of%==1 (set format=mp3&& goto search_song_menu)
if %of%==2 (set format=m4a&& goto search_song_menu)
if %of%==3 (set format=flac&& goto search_song_menu)
if %of%==4 (set format=opus&& goto search_song_menu)
if %of%==5 (set format=ogg&& goto search_song_menu)
if %of%==6 (if %spotDL_ver%==3 (set format=wav&& goto search_song_menu) else (echo  Sorry, but that feature is only available with spotDL v3&& timeout /t 3 >nul&& goto main_menu))
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
if %of%==e (goto manual_audio_matching)
if %of%==f (goto setup_menu)
if %of%==g (goto bsync)
if %of%==h (goto user_info_menu)
if %of%==i (goto settings)
if %of%==j (echo  One moment please... && goto dvfs)
if %of%==hi (echo  Hello and Welcome to SPOTYdl!&&timeout /t 5 >nul&&goto main_menu)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto main_menu
:aoffe
echo  You can't leave this field in blank. Try again!
timeout /t 3 >nul
goto main_menu



:search_song_menu
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
echo "%link%"|findstr /R "[%%#^&^^^^@^$~!]" 1>nul
if %errorlevel%==0 (
	setlocal enabledelayedexpansion
	for %%j in (%link%) do (
		set shit=!link:@=_!
	) 
	endlocal
	echo.
    echo   Invalid song name: "%shit%"
    echo   Please remove special symbols: "%#&^@$~!"
	timeout /t 6 >nul
	goto search_song_menu
)
if not %count% EQU 7 (if not defined link goto blank_invalid) else (echo   DOODLE TIME!! && timeout /t 3 >nul && goto search_song_menu)
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
		echo spotdl download "%link%" --format %format% --output "%curdir%" --bitrate %kbps% --log-level DEBUG
		spotdl download "%link%" --format %format% --output "%curdir%" --bitrate %kbps% --log-level DEBUG
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
goto search_song_menu



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
:version_menu
if not exist %info% (md %info%)
mode con: cols=51 lines=25
set swm=
set sver=no_connection
set upd?=yes
set /p last_updated=<%info%last_updated.dat
if not defined last_updated (set last_updated=not defined)
set /p sver=<%temp%s.ver
cls
echo.
echo                   -Version menu-
echo.
echo.
echo  Running Version: %ver%
echo    - updated on: %last_updated%
echo  Server Version: %sver%
echo  Update channel: %channel%
echo.
echo  SPOTYdl related features:
::by GabiBrawl
if not %sver%==no_connection (
	if not "%sver%"=="%ver%" (
		if not "%ver%" GTR "%sver%" (
			echo   1^) Install updates
		) else (
			set upd?=no
			echo   1^) Stop using leaked builds
)) else (
	echo   1^) Reinstall SPOTYdl
)) else (
	echo   1^) No_connection
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
echo                       -DON'T CLOSE THIS WINDOW-
echo.
echo  Updating SPOTYdl installation files...
copy %SN% %store%%ver%.dsv /y >nul
if %channel%==Stable (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/script.bat -Outfile %temp%SPOTYdl.bat" >nul) else (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bscript.bat -Outfile %temp%SPOTYdl.bat" >nul)
if %errorlevel%==1 goto fail_github
echo %date%>%info%last_updated.dat
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



:setup_menu
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
set setup_menu=
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
set /p setup_menu=^>^> 
if not defined setup_menu (%WINDIR%\explorer.exe %SN% && exit)
if %setup_menu%==1 (goto ip)
if %setup_menu%==2 (goto iff)
if %setup_menu%==3 (goto is)
if %setup_menu%==4 (goto icre)
if %setup_menu%==a (goto ih)
if %setup_menu%==b (goto uninst)
echo  Sorry, but the value you entered is invalid. Try again!
timeout /t 3 >nul
goto setup_menu



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
goto setup_menu



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
goto setup_menu



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
goto setup_menu


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
goto setup_menu


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
goto setup_menu


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
goto setup_menu


:unzip_err
echo   There was an error when trying to unzip the
echo  downloaded ffmpeg files. Try again later!
echo.
echo   Press any key to go back.
pause >nul
goto setup_menu


:pathed_err
echo   There was an error when trying to add the
echo  path entries. Try again later!
echo.
echo   Press any key to go back.
pause >nul
goto setup_menu


:python_err
echo   There was an error when trying to install
echo  Python. Try checking your permissions!
echo.
echo   Press any key to go back.
pause >nul
goto setup_menu


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
start setup_menu.bat
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
	goto slis   ting
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
echo   Input the location of the folder you wanna list it's music:
echo.
set /p sfsl=^>^> 
set sfl=%sfsl%\
md %sfl% >nul
if not %errorlevel%==0 (goto slisting) else (
	echo You have to input a valid folder location.
	timeout /t 3 >nul
	goto sfsl
)
goto :slisting


:slisting
cls
echo.
echo                            -SONGS listing-
echo.
echo.
echo   We're listing all the songs of the selected folder into SongList.txt
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
echo   Song(s) was(were) successfuly downloaded!
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download is finished!', [System.Windows.Forms.ToolTipIcon]::None)}">nul
echo.
echo   Press any key to continue...
pause >nul
goto sstd


:error1
echo.
echo  The song(s) you tried downloading failed.
echo  ERRC: #3
echo.
echo  Please try again later...
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Error; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your download failed...', [System.Windows.Forms.ToolTipIcon]::None)}">nul
timeout /t 5 >nul
goto search_song_menu


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
mode con: cols=57 lines=10
cls
echo.
echo                      -Disclaimer-
echo.
echo.
echo   SPOTYdl is not endorsed by, directly affiliated with,
echo  maintained, authorized, or sponsored by spotDL, 7zip,
echo  pathed, Bluetooth Command Line Tools, ffmpeg or Python.
echo.
echo   Press any key to go back to settings...
pause >nul
goto settings


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
mode con: cols=103 lines=21
cls
echo.
echo                                                -About-
echo.
echo.
echo   I'm sure you've already googled on ways how to download Spotify songs without having to purchase the
echo  "Premium" they offer us. In my research I found about spotDL, a project that helps people downloading
echo  spotify songs for free and legally using youtube. Initially when I saw the whole setup_menu we have to do,
echo  in order to start the usage, I abandoned. But after some more research I found out that spotDL was my
echo  best choice. I installed it, and it worked nicely but it's not that motivating to open cmd every time
echo  I wanna download a song. So I created SPOTYdl to run spotDL's commands without having to remember all
echo  the needed commands. Working great but, I wanted to publish it. So I prepaired the script to download
echo  and setup_menu spotDL and its requirements automaticaly, so you don't need to go through all the hassle of
echo  installation nor usage. :D
echo  And here we are!
echo.
echo                                       Welcome to SPOTYdl V%ver%!
echo   by GabiBrawl, 21st march 2022
echo.
echo   Press any key to go back...
pause >nul
goto settings





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


:user_info_menu
set choice=
cls
echo.
echo                                 -User info-
echo.
echo.
echo  Welcome back %logged_username%!
echo  Here are the available account management options:
echo.
echo   1^) Logout
echo   2^) Change password
echo   3^) Delete account, doesn't delete downloaded songs.
echo.
echo  Other options:
echo   [ENTER] Go back
echo.
set /p choice=^>^>
if not defined choice goto :main_menu
if %choice%==1 (goto :login_menu)
if %choice%==2 (goto :change_password)
if %choice%==3 (
	del %users%\%logged_username%\ /f /q
	rmdir %users%\%logged_username%\
	goto :login_menu
)
echo   That's an invalid option. Try again!
timeout /t 3 >nul
goto user_info_menu

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


:change_password
if exist %users%%logged_username%/psw.id (
    < %users%%logged_username%/psw.id (
    	set /p psw=
    )
) else (
    goto set_new_password
)
set input=
cls
echo.
echo                                 -Password-
echo.
echo.
echo  Enter %logged_username%'s password to proceed.
echo  Other options:
echo   [ENTER] Go Back
echo.
set /p input=^>^>
if not defined input (goto user_info_menu)
if not %input%==%psw% (
	echo  Wrong input. Try again!
	timeout /t 3 >nul
	goto change_password
)
:set_new_password
set input=
cls
echo.
echo                                 -Password-
echo.
echo.
echo  Input your new password:
echo   Is case sensitive
echo   [ENTER] Removes the current password, if any is set
echo.
set /p input=^>^> 
if not defined input (del %users%%logged_username%\psw.id /f /q) else (echo %input%>%users%%logged_username%\psw.id)
goto user_info_menu


:login_menu
title SPOTYdl - Login menu
if exist %logged% (del %logged%)
if not exist %users% (goto :register_admin)
if not exist "%users%Admin\" (goto :register_admin)
for /f %%b in ('dir %users% ^| find "Dir(s)"') do (set dmva=%%b)
set /a mcdm=%dmva%+10
set count=0
set usrn=
mode con: cols=60 lines=%mcdm%
cls
echo.
echo                            -LogIn-
echo.
echo.
echo  All available users:
setlocal enabledelayedexpansion
set count=0
for /F "delims=" %%A in ('dir /a:d /b %users%*') do (
    REM Increment %count% here so that it doesn't get incremented later
    set /a count+=1
    REM Add the file name to the options array
    set "options[!count!]=%%A"
	set /a value+=1
	set !value!=%%A
)
for /f %%b in ('dir %users% ^| find "Folder(s)"') do (set fc=%%b)
:: Type each user's name
for /L %%A in (1,1,!count!) do echo   %%A^) !options[%%A]!
echo.
echo  Other Options:
echo   [ENTER] Register New User
echo.
set /p usrn=^>^> 
if not defined usrn (goto register_new_user)
for /L %%A in (1,1,!count!) do (if %usrn%==%%A (set usrn=!options[%%A]!))


:password_check
if exist %users%%usrn%/psw.id (
    < %users%%usrn%/psw.id (
    	set /p psw=
    )
) else (
    goto :sui
)
:pass_input
set input=
cls
echo.
echo                            -LogIn-
echo.
echo.
echo  Enter %usrn%'s password.
echo  Other options:
echo   [ENTER] Go Back
echo.
set /p input=^>^>
if not defined input (goto login_menu)
if not %input%==%psw% (
	echo  Wrong input. Try again!
	timeout /t 3 >nul
	goto pass_input
)
:sui
del %logged% /f /q
(
	echo %usrn%
) >%logged%
:rui
< %logged% ( 
	set /p logged_username=
)
if exist %users%%usrn%\user.id (goto main_menu) else (
	echo  That username isn't registered yet.
	timeout /t 4 >nul
	goto login_menu
)


:register_admin
md "%users%Admin"
echo Admin>>"%users%Admin\user.id"
set choice=
cls
echo.
echo                      -Admin registration-
echo.
echo.
echo   Enter the Admin account's password.
echo   This account won't be like a normal account. It'll be the
echo  Control Panel for some settings and upcomming features.
set /p choice=^>^>
echo %choice%>%users%Admin/psw.id



:register_new_user
mode con: cols=60 lines=13
set new_username=
cls
echo.
echo                     -New User Registration-
echo.
echo.
echo   Chose your desired username wisely!
echo   Rules: No Spaces, No Special Characters.
echo   If you break the rules, you may brick this
echo  script.
echo.
echo  Other options:
echo   [ENTER] Go Back
echo.
set /p new_username=^>^> 
if not defined new_username (goto login_menu)
if exist "%users%\%new_username%\user.id" (
	echo  Oops! That username is already taken. Try again.
	timeout /t 3 >nul
	goto register_new_user
) else (
	if not "%VAR%"=="%VAR:^%%" (
		md "%users%%new_username%"
		echo %new_username%>>"%users%%new_username%\user.id"
		echo  Wowza! New username was successfuly registered.
		timeout /t 4 >nul
		goto login_menu
	) else (
		echo  No spaces or special characters allowed.
		timeout /t 3 >nul
		goto login_menu
	)
)


:bsync
set choice=
set devid=%users%%logged_username%\device.id
< %users%%logged_username%\device.id (
	set /p devname=
)
cls
echo.
echo                     -BSync-
echo.
echo.
echo  Main Options:
echo   1) Start Syncing
echo   b) Start Syncing (NOT READY)
echo   2) Target Device ID: %devname%
echo.
echo  Other Options:
echo   a) Help
echo   [ENTER] Go Back
echo.
set /p choice=^>^> 
if not defined choice (goto main_menu)
if %choice%==b (goto transfer)
if %choice%==1 (
	set goto=transfer_2
	goto device_id
)
if %choice%==2 (
	set goto=bsync
	goto device_id
)


:device_id
set devname=
set device_id=
cls
echo.
echo                -Bluetooth Device ID-
echo.
echo.
echo   Please pair your target device, and type in the
echo  device's name.
set /p devname=^>^> 
if exist %devid% del %devid%
echo %devname%>%devid%
goto %goto%


:transfer
set synced=%users%%logged_username%\synced_%devname%.txt
if not exist %synced% (echo.> "%synced%")
if not exist %devid% (
	set goto=transfer
	goto device_id
)
cls
echo.
echo                             -Transferring-
echo.
echo.
echo   Check your target device for any incoming transfers!
for /f %%b in ('dir %curdir% ^| find "File(s)"') do (set ttl=%%b)
setlocal EnableDelayedExpansion
for %%A in (!curdir!*) do (
	findstr /m "%%~nA" "!synced!" >nul
	if errorlevel 1 (
		echo  ^>------------------------------------------------------------^<
		set /a dwl+=1
		echo  Currently Transferring: %%~nA
		echo  Total #!ttl!; Song #!dwl!; Success #!scs!; Failed #!err!
		echo  Estimated remaining time: !ttl_time!
		set v1=!time!
		btobex -n"%devname%" "!curdir!%%~nA%%~xA"
		set v2=!time!
		set /a remaining_songs=!ttl!-!dwl!
		set /a ft=!v2!-!v1!
		set /a ttl_time1=!ft! * !remaining_songs!
		set /a ttl_time2=!ttl_time1! / 60
		set ttl_time=!ttl_time2! minutes
		if errorlevel 1 (
			set /a err+=1
		) else (
			set /a scs+=1
			echo %%~nA%%~xA>>"!synced!"
		)
	)
)
endlocal
pause >nul
goto bsync



:transfer_2
set rmt=
echo.
echo                             -Transferring-
echo.
echo.
for /f %%b in ('dir %users% ^| find "File(s)"') do (set dmva=%%b)
set /a rmt=%dmva%+%dmva%
echo   This job will take around %rmt% minutes. Started on %time%  
btobex -n"%devname%" %curdir%*
echo  Done!
pause >nul
echo  Press any key to continue...
goto main_menu




:settings
mode con: cols=60 lines=22
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
echo   5) Title dir info: %atd%
::echo   6) Version Check: %cfu%
echo.
echo  Other options:
echo   a) Save changes ^& exit
echo   b) Exit without saving changes
echo   c) Reset the app configuration
echo   d) About SPOTYdl
echo   e) Disclaimer
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
::if %choice%==6 (if %cfu%==enabled (set cfu=disabled) else (set cfu=enabled)) && goto settings
if %choice%==a (goto ss)
if %choice%==b (goto reload)
if %choice%==c (goto rs)
if %choice%==d (goto about)
if %choice%==e (goto disclaimer)
echo  Invalid choice. Please try again!
timeout /t 3 >nul
goto settings


:bs
mode con: cols=32 lines=16
set sh=
cls
echo.
echo    Chose your desired bitrate:
echo          64 - Low Audio Quality
echo         128 - Medium Audio Quality
echo         320 - High Audio Quality
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
) >%config%
:reload
< %config% (
	set /p history=
  	set /p bitrate=
	set /p spotDL_ver=
	set /p downloads_folder=
	set /p atd=
)
goto main_menu
:rs
del %config% /f /q
goto reset


:manual_audio_matching
set mam=
if not defined format set format=not defined
if not defined yt_url set yt_url=not defined
if not defined sp_url set sp_url=not defined
mode con: cols=80 lines=16
cls
echo.
echo                              -Manual Audio Matching-
echo.
echo.
echo  1) Audio file format: %format%
echo  2) YouTube URL: %yt_url%
echo  3) Spotify URL: %sp_url%
echo.
echo  To start downloading hit [ENTER] when all values are defined, otherwise
echo [ENTER] will go back.
echo.
echo  Chose a value to define then hit [ENTER]:
set /p mam=^>^> 
if not defined mam (
	if not defined format (
       goto main_menu) else (
          if not defined yt_url (
             goto main_menu) else (
		  	 if not defined sp_url (
             goto main_menu) else (
					goto manual_audio_matching_download
          )
       )
    )
)
if %mam%==1 goto manual_audio_matching_format
if %mam%==2 goto manual_audio_matching_yt_url
if %mam%==3 goto manual_audio_matching_sp_url
echo  Invalid choice. Please try again!
timeout /t 3 >nul
goto manual_audio_matching

:manual_audio_matching_format
set format=
mode con: cols=80 lines=16
cls
echo.
echo                              -Manual Audio Matching-
echo.
echo.
echo  Available audio file formats:
echo   1) mp3                      4) opus
echo   2) m4a                      5) ogg
if %spotDL_ver%==3 (echo   3^) flac                     6^) wav) else (echo   3^) flac)
echo.
echo  Input the value that corresponds to your choice.
set /p format=^>^> 
if %format%==1 (set format=mp3&& goto manual_audio_matching)
if %format%==2 (set format=m4a&& goto manual_audio_matching)
if %format%==3 (set format=flac&& goto manual_audio_matching)
if %format%==4 (set format=opus&& goto manual_audio_matching)
if %format%==5 (set format=ogg&& goto manual_audio_matching)
if %format%==6 (if %spotDL_ver%==3 (set format=wav&& goto manual_audio_matching) else (echo  Sorry, but that feature is only available with spotDL v3&& timeout /t 3 >nul&& goto set_audio_file_format))
echo   Invalid input. Try again!
timeout /t 3 >nul
goto manual_audio_matching_format

:manual_audio_matching_yt_url
mode con: cols=66 lines=12
set yt=
cls
echo.
echo                   -Manual Audio Matching-
echo                         YouTube URL
echo.
echo.
echo   Input the YouTube song URL. It's form there that we'll
echo  get the song downloaded from.
echo.
set /p yt_url= YT^>^> 
if not defined yt_url goto manual_audio_matching
echo "%yt_url%"|findstr /R "[%%#^&^^^^@^$~!]" 1>nul
if %errorlevel%==0 (
    echo.
    echo   Invalid song name: "%link%"
    echo   Please remove special symbols: "%#&^@$~!"
    timeout /t 6 >nul
	 set yt_url=
    goto manual_audio_matching_yt_url
)
goto manual_audio_matching

:manual_audio_matching_sp_url
set sp_url=
cls
echo.
echo                   -Manual Audio Matching-
echo                         Spotify URL
echo.
echo.
echo   Input the Spotify song URL. It's form there that we'll
echo  get the metadata downloaded from.
echo.
set /p sp_url=SP^>^> 
if not defined sp_url goto manual_audio_matching
echo "%sp_url%"|findstr /R "[%%#^&^^^^@^$~!]" 1>nul
if %errorlevel%==0 (
    echo.
	 echo   Invalid song name: "%link%"
	 echo   Please remove special symbols: "%#&^@$~!"
    timeout /t 6 >nul
	 set sp_url=
	 goto manual_audio_matching_sp_url
)
goto manual_audio_matching

:manual_audio_matching_download
cls
echo.
echo                   -Manual Audio Matching-
echo.
echo.
echo   We're now downloading the desired song, with the selected
echo  metadata. One moment plase...
echo.
cls
set mam_download_command="%yt_url%|%sp_url%"
if %history%==true (echo %mam_download_command%>>history.txt)
if %debug%==false (
	if %spotDL_ver%==3 (
		spotdl %mam_download_command% --output-format %format% --output %curdir%
	) else (
		spotdl download %mam_download_command% --format %format% --output %curdir% --bitrate %kbps%
	)
) else (
	if %spotDL_ver%==3 (
		echo spotdl %mam_download_command% --output-format %format% --output %curdir% --log-level DEBUG
		spotdl %mam_download_command% --output-format %format% --output %curdir% --log-level DEBUG
		pause
	) else (
		echo spotdl download %mam_download_command% --format %format% --output %curdir% --bitrate %kbps% --log-level DEBUG
		spotdl download %mam_download_command% --format %format% --output %curdir% --bitrate %kbps% --log-level DEBUG
		pause
	)
)
if %errorlevel% == 0 goto clnup
if %errorlevel% == 1 goto error1
goto spotDL_trouble


:control_panel
mode con: cols=60 lines=15
set choice=
cls
echo.
echo                        -CONTROL PANEL-
echo.
echo  Welcome back %logged_username%!
echo.
echo.
echo  Available options:
echo   1) Registered accounts' info
echo   2) Installation level settings
echo   3) LogOut
echo.
set /p choice=^>^> 
if %choice%==1 (goto registered_accounts_info)
if %choice%==2 (goto installation_settings)
if %choice%==3 (goto login_menu)
echo  You can't leave this field in blank. Try again!
timeout /t 4 >nul
goto control_panel


:registered_accounts_info
set choice=
cls
echo.
echo                                 -Accounts-
echo.
set count=0
for /F "delims=" %%A in ('dir /a:d /b %users%*') do (
   set /a count+=1
   set "choice[!count!]=%%A"
	set /a value+=1
	set !value!=%%A
)
for /f %%b in ('dir %users% ^| find "Folder(s)"') do (set fc=%%b)
set count=
for /F "delims=" %%A in ('< %users%%usrn%/psw.id (set /p psw=)') do (
   set /a count+=1
   set "choice[!count!]=%%A"
	set /a value+=1
	set !value!=%%A
)
:: Type each user's name
for /L %%A in (1,1,!count!) do echo   %%A^) !choice[%%A]!
set /p choice=^>^> 
for /L %%A in (1,1,!count!) do (if %usrn%==%%A (set usrn=!choice[%%A]!))


:installation_settings
