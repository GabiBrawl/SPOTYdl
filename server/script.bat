@echo off
setlocal EnableDelayedExpansion
setlocal EnableExtensions
:RestartScript
title SPOTYdl - setup MODE
color 07
::hey there visitor! if you're reading this, you're probably interested in how this works. well, it's pretty simple. this is a batch script, which means it's a text file that runs commands. the commands are written in a language called "batch", which is a very simple language. if you're interested in learning more about batch, you can find a tutorial here: https://www.computerhope.com/issues/chusedos.htm
::if you're looking forward to adding features to this script, you should do it at the very bottom.
::tweakable
set SPOTYdlCurrentVersion=3.0
set UpdateChannel=Stable
set SPOTYdlSetupVersion=3.4
::DebugState should be either true or false
set DebugState=false
::---------
:InitialVariableLoad
set DoodleCount=0
set ScriptFileName=%~nx0
::CurrentPath
set script_path=%~dp0
set SPOTYdlPath=!script_path:~0,-1!\
cd !SPOTYdlPath!
::Directories
set DefaultDownloadDirectory=!SPOTYdlPath!Downloads\
set DataDirectory=%appdata%\GabiBrawl\SPOTYdl\
set ConfigFile=!DataDirectory!config.txt
set StoreDirectory=!DataDirectory!store\
set TempDirectory=!DataDirectory!temp\
set PackagesDirectory=!DataDirectory!packages\
set ToolsDirectory=!DataDirectory!tools\
set HistoryDirectory=!DataDirectory!history\
set SPOTYdlVersioningInfoDirectory=!DataDirectory!info\
::Tools
set 7zipExecutable=!ToolsDirectory!7z.exe
set PathedExecutable=!ToolsDirectory!pathed.exe
set yt-dlpExecutable=!ToolsDirectory!yt-dlp_x86.exe
set FFmpegExecutable=C:\ffmpeg\ffmpeg.exe
::Actions
set ImportFileDefaultActionOnFinish=none
::Files
set BSyncId=!DataDirectory!BluetoothSyncDevice.id
set SelectedSaveFolder=!DataDirectory!SelectedSaveFolder.txt
set HistoryFile=!DataDirectory!history\history
set TempSetupFile="!SPOTYdlPath!setup.bat"
::ImportFileRelated
set action=none
::others
set DownloadsFolderAssignedName=Downloads
::Finish
echo  - %time% Initial Variable Load Complete
echo  - %time% Reset Mode prompted??
if "%~n1"=="reset" (goto reset)
echo  - %time% Reset Mode not prompted.
::---------
::Check if SetupMode was triggered
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' EQU '0' (
    goto SetupMenu
)
echo  - %time% Setup Mode was not triggered
::Check if the config file is available
if exist "!DataDirectory!" (if not exist "!ConfigFile!" goto ResetConfig) else (goto FirstRun)
echo  - %time% Config file is available
call :LoadConfig
echo  - %time% Config file loaded
if not exist !HistoryDirectory! md !HistoryDirectory!
if not exist !PackagesDirectory! md !PackagesDirectory!
if exist !TempSetupFile! del !TempSetupFile!
echo  - %time% Config file checked
::Check for updates
echo  - %time% Check For Updates on startup started
if !CheckForUpdatesOnStartup!==enabled call:CheckForUpdatesMenu
echo  - %time% Check For Updates on startup ended successfuly
::---------
:DownloadsFolderCheck
set DownloadsFolder=!SPOTYdlPath!!DownloadsFolderAssignedName!\
if not exist "!DownloadsFolder!" (
	md "!DownloadsFolder!"
	(
        echo [.ShellClassInfo]
        echo ConfirmFileOp=0
        echo IconResource=%%SystemRoot%%\system32\imageres.dll,-184
        echo [ViewState]
        echo Mode=
        echo Vid=
        echo FolderType=Music
    ) > "!DownloadsFolder!Desktop.ini"
	attrib +S +H "!DownloadsFolder!Desktop.ini"
	attrib +R .\!DownloadsFolderAssignedName!
	start "C:\Windows\System32" ie4uinit.exe -show
)
echo  - %time% Downloads Folder Check passed successfuly
:ImportCheck
if not "%~1"=="" (if not "%~n1"=="reset" (goto FileImporting))
echo  - %time% Import Check passed successfuly. No imported files.


:MainMenu
color 07
mode con: cols=80 lines=21
::variable resettting
set errorlevel=
set choice=
set pending=False
set OutputSongFormat=
set "DownloadsFolderDirectory=!SPOTYdlPath!!DownloadsFolderAssignedName!\"
if %DirectoryInTitle%==enabled (title SPOTYdl - %~dp0) else (title SPOTYdl)
for /R "!DownloadsFolderDirectory!" %%r in (*) do (if %%~xr==.spotdlTrackingFile (set pending=True) else (set pending=False))
for /f %%b in ('dir !DownloadsFolderDirectory!\* ^| find "File(s)"') do (set TotalDownloadedSongsCount=%%b)
if !pending!==True (set PendingChoiceName=Pending downloads   ) else (set PendingChoiceName=No pending downloads)
::bitrates and descriptions
if !BitrateRawValue!==64 (set BitrateValueDescription=Smallest File Size ^(64kbps^)) else (if !BitrateRawValue!==128 (set BitrateValueDescription=Medium Audio Quality ^(128kbps^)) else (set BitrateValueDescription=Best Audio Quality ^(320kbps^)))
if !BitrateRawValue!==64 (set kbps=64k) else (if !BitrateRawValue!==128 (set kbps=128k) else (set kbps=320k))
::cleaning up if necessary
if exist !TempDirectory!news.temp (del !TempDirectory!news.temp)
::show menu
cls
echo.
echo                                 -SPOTYdl v!SPOTYdlCurrentVersion!-
echo                                !TotalDownloadedSongsCount! songs so far
echo.
echo.
echo  Available audio file formats:
echo   1^) mp3                      4^) opus
echo   2^) m4a                      5^) ogg
echo   3^) flac
echo.
echo  Other options:
echo   a^) Help                     b^) Toggle Bitrate: !BitrateValueDescription!
echo   c^) Manual Audio Matching    d^) Settings
echo   e^) !PendingChoiceName!     f^) Setup v!SPOTYdlSetupVersion!
echo   g^) Version                  h^) Export downloaded songs to file
echo   i^) YouTube only download    j^) More options...
echo.
echo  Input the value that corresponds to your choice
set /p choice=^>^> 
if not defined choice call :blank_input&& goto MainMenu
if !choice!==1 set OutputSongFormat="mp3"&& goto InsertSongNameMenu
if !choice!==2 set OutputSongFormat="m4a"&& goto InsertSongNameMenu
if !choice!==3 set OutputSongFormat="flac"&& goto InsertSongNameMenu
if !choice!==4 set OutputSongFormat="opus"&& goto InsertSongNameMenu
if !choice!==5 set OutputSongFormat="ogg"&& goto InsertSongNameMenu
if !choice!==a goto HelpFile
if !choice!==b goto BitrateMainMenuChoiceToggle
if !choice!==c (
	set format=not defined
	set YouTubeUrl=not defined
	set SpUrl=not defined
	goto ManualAudioMatchingMenu
)
if !choice!==d goto SettingsMenu
if !choice!==e (
	if !pending!==true (
		goto PendingDownloadsMenu
	) else (
		echo  You have no pnding downloads, Hurrah :^)
		timeout /t 3 >nul
		goto MainMenu
	)
	)
if !choice!==f (goto SetupMenu)
if !choice!==g (echo  One moment please... && goto VersionMenu)
if !choice!==h (goto ListSongsIntoFile)
if !choice!==i (goto YouTubeMP3DownloaderMenu)
if !choice!==j (goto MoreOptions)
if !choice!==hi (echo  Hello and Welcome to SPOTYdl!&&timeout /t 5 >nul&&goto MainMenu)
call :InvalidInput
goto MainMenu

:InsertSongNameMenu
mode con: cols=72 lines=13
set DefinedSong=
cls
echo.
echo                               -Search Song-
echo.
echo.
echo   Now input the song name you wanna download. Spotify links supported.
echo   Please remove all special characters. No exceptions.
echo   Current output audio file format: %OutputSongFormat%, downloading to: !DownloadsFolderAssignedName!
echo   To go back just hit [ENTER]
echo.
echo   Paste the link to a song/playlist or simply the song name :D
set /p DefinedSong=^>^> 
if not defined DefinedSong goto MainMenu
echo "!DefinedSong!"|findstr /R "[%%#^&^^^^@^$~!]" 1>nul
if %errorlevel%==0 (
	setlocal enabledelayedexpansion
	for %%j in (!DefinedSong!) do (
		set shit=!DefinedSong:@=_!
	) 
	echo.
    echo   Invalid song name: "%shit%"
    echo   Please remove special symbols: "%#&^@$~!"
	timeout /t 6 >nul
	goto InsertSongNameMenu
)
cls
set "spotDLV4Command=spotdl download "!DefinedSong!" --format !OutputSongFormat! --output !DownloadsFolderDirectory! --bitrate !BitrateRawValue!k --lyrics !SelectedLyricsProvider!"
!spotDLV4Command!
if !DebugState!==true (echo !spotDLV4Command!)
set NextGoto=InsertSongNameMenu
if !errorlevel! == 0 goto CleanUp
if !errorlevel! == 1 goto Error1
goto spotDLTrouble
:blank_invalid
call :blank_input
goto InsertSongNameMenu


:CleanUp
echo.
if !spotDLVersion!==3 (
	echo   Cleaning things up...
	del /f /q !DownloadsFolderDirectory!.spotdl-cache >nul
)
echo !DefinedSong!>>!HistoryDirectory!history.txt
echo   Song(s) was(were) successfuly downloaded!
echo.
echo   Press any key to continue...
pause >nul
goto !NextGoto!


:Error1
echo.
echo  The song(s) you tried downloading failed.
echo  ERRC: #3
echo.
echo  Please try again later...
call :PressAnyKeyToContinue
goto InsertSongNameMenu


:HelpFile
mode con: cols=65 lines=35
cls
echo.
echo                           -HELP file-
echo.
echo.
echo.
echo   Can seem big, but contains the info to almost all questions!
echo.
echo   This script helps you download music using spotDL more easily.
echo   Don't worry, you won't get banned. spotDL doesn't download the
echo  songs from Spotify but from YouTube. (we don't even need your
echo  username). In other words, we get the Metadata (info about the
echo  songs) from Spotify and the songs from Youtube.
echo.
echo   Start by chosing a song format (options 1 to 5), then type in
echo  the song link or name.
echo   For manual audio matching, there's option c.
echo   You can check out settings (option d) where you can set your
echo  preferred lyrics provider, the bitrate defaults, etc...
echo   We got you the version menu too (option g) which you can check
echo  for new updates and install them. Takes no more than a blink of
echo  an eye. ;^)
echo.
echo   To import a txt songs list, you have to drag and drop the file
echo  into the script's icon. The file doesn't need to be in the same
echo  directory as the script. You can import the history file, for
echo  example. The Song listing feature registers the songs you've
echo  downloaded in a txt file. You can import it and download them
echo  again in other machines.
echo.
echo   If you have any questions, feel free to contact me on Discord
echo  (@GabiBrawl) or on GitHub (GabiBrawl).
echo.
call:PressAnyKeyToContinue
goto MainMenu


:FileImporting
set "DownloadsFolderDirectory=!SPOTYdlPath!!DownloadsFolderAssignedName!\"
if !DirectoryInTitle!==enabled (title SPOTYdl - %cd%) else (title SPOTYdl)
mode con: cols=80 lines=22
set _flnm=%~n1
set _ext=%~x1
set ImportedFile=%~1
set err=0
set dwl=0
set scs=0
set ttl=0
set et=0
set ttl_time=Calculating...
set choice=
if !BitrateRawValue!==64 (set BitrateValueDescription=Smallest File Size ^(64kbps^)) else (if !BitrateRawValue!==128 (set BitrateValueDescription=Medium Audio Quality ^(128kbps^)) else (set BitrateValueDescription=Best Audio Quality ^(320kbps^)))
if !BitrateRawValue!==64 (set kbps=64k) else (if !BitrateRawValue!==128 (set kbps=128k) else (set kbps=320k))
cls
echo.
if "!_ext!"==".spotdlTrackingFile" (
	echo  Resuming the imported download...
	spotdl "!ImportedFile!" --output !DownloadsFolderDirectory!
	echo.
	echo  The imported song was successfuly downloaded!
	echo  Press any key to exit...
	pause >nul
	exit
)
if not "!_ext!"==".txt" (
	mode con: cols=40 lines=7
	echo.
	echo  The imported file type is unsupported.
	echo  Only .txt files are supported.
	echo  Rename your file, or pick another one.
	echo.
	echo  Press any key to exit...
	pause>nul
	exit
)
echo                                  SPOTYdl v!SPOTYdlCurrentVersion!
echo                                -File Importing-
echo.
echo.
echo  Imported file: "!_flnm!!_ext!"
echo  Downloading to: !DownloadsFolderDirectory!
echo  spotDL version: !spotDLVersion!
echo.
echo  Chose an audio file format:
echo   1) mp3		 4) opus
echo   2) m4a		 5) ogg
if %spotDLVersion%==3 (echo   3^) flac		 6^) wav) else (echo   3^) flac)
echo.
echo  Other options:
echo   a) Toggle Bitrate: !BitrateValueDescription!
echo   b) Upon completion: !action! device
echo.
echo  Input the value that corresponds to your choice.
set /p choice=^>^> 
if not defined choice (
	echo  You can't leave this feald in blank. Try again!
	timeout /t 3 >nul
	goto FileImporting
)
if !choice!==1 (set OutputSongFormat=mp3 && goto s_fi_start)
if !choice!==2 (set OutputSongFormat=m4a && goto s_fi_start)
if !choice!==3 (set OutputSongFormat=flac && goto s_fi_start)
if !choice!==4 (set OutputSongFormat=opus && goto s_fi_start)
if !choice!==5 (set OutputSongFormat=ogg && goto s_fi_start)
if !spotDLVersion!==3 (if "!choice!"=="6" (set OutputSongFormat=wav&& goto FileImporting))
if !choice!==a (
	if !BitrateRawValue!==64 (
		set BitrateRawValue=128
	) else (
		if !BitrateRawValue!==128 (
			set BitrateRawValue=320
		) else (
			set BitrateRawValue=64
		)
	)
) && goto FileImporting
if !choice!==b (
	if !action!==none set action=sleep&& goto FileImporting
	if !action!==sleep set action=hibernate&& goto FileImporting
	if !action!==hibernate set action=shutdown&& goto FileImporting
	if !action!==shutdown set action=restart&& goto FileImporting
	if !action!==restart set action=none&& goto FileImporting
)
echo  Invalid choice! Try again...
timeout /t 3 >nul
goto FileImporting
:s_fi_start
if not "!_flnm!" EQU "02_02_2022" (echo  Reading "!_flnm!" and downloading all listed songs on it.) else (echo Reading "Twosday" and downloading all listed songs on it.)
echo.
For /f %%j in ('Find "" /v /c ^< !ImportedFile!') Do Set /a ttl=%%j
if %spotDLVersion%==3 (
	mode con: cols=80 lines=5
	for /F "usebackq tokens=*" %%A in ("!ImportedFile!") do (
		echo %%A>>!HistoryDirectory!history.txt
		echo  ^>----------------------------------------------------------------------------^<
		set /a dwl+=1
		echo  Currently Downloading: %%A
		echo  Downloading song #!dwl! out of #!ttl! entries
		echo  Estimated remaining time: !ttl_time!
		set v1=!time!
		spotdl "%%A" --output-format !OutputSongFormat! --output "!DownloadsFolderDirectory!" --lyrics !SelectedLyricsProvider! >nul
		set v2=!time!
		set /a remaining_songs=!ttl!-!dwl!
		set /a ft=!v2!-!v1!
		set /a ttl_time1=!ft! * !remaining_songs!
		set /a ttl_time2=!ttl_time1! / 60
		set ttl_time=!ttl_time2! minutes
	)
) else (
	mode con: cols=80 lines=11
	for /F "usebackq tokens=*" %%A in ("!ImportedFile!") do (
		cls
		echo  ^>----------------------------------------------------------------------------^<
		set /a dwl+=1
		echo  Currently Downloading: %%A
		echo  Total #!ttl!; Song #!dwl!; Success #!scs!; Failed #!err!
		echo  Estimated remaining time: !ttl_time!
		set v1=!time!
		spotdl download "%%A" --format !OutputSongFormat! --output !DownloadsFolderDirectory! --bitrate !BitrateRawValue!k --lyrics !SelectedLyricsProvider!>nul
		if !errorlevel!==0 (
			set /a scs+=1
		    echo %%A>>!HistoryDirectory!history.txt
		) else (
			echo %%A>>failed_list.txt
			set /a err+=1
		)
		set v2=!time!
		set /a remaining_songs=!ttl!-!dwl!
		set /a ft=!v2!-!v1!
		set /a ttl_time1=!ft! * !remaining_songs!
		set /a ttl_time2=!ttl_time1! / 60
		set ttl_time=!ttl_time2! minutes
	)
)
if !action!==sleep (rundll32.exe powrprof.dll, SetSuspendState Sleep)
if !action!==hibernate (shutdown /h)
if !action!==shutdown (shutdown /s)
if !action!==restart (shutdown /r)
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'We finished the downloading job. Failed: %err%', [System.Windows.Forms.ToolTipIcon]::None)}">nul
echo.
echo   Done!
echo   There were !err! songs that failed downloading. All
echo  failed songs' names were saved to "failed_list.txt"
echo.
echo   Press any key to quit...
pause >nul
exit


:PendingDownloadsMenu
set choice=
mode con: cols=85 lines=20
cls
echo.
echo                               -Pending Downloads-
echo.
echo.
echo  Available options:
echo   1^) Resume Downloads
echo   2^) Discard Downloads
echo.
echo  Input the value that corresponds to your choice or hit [ENTER] to go back.
set /p choice=^>^> 
if not defined choice goto MainMenu
if !choice!==1 (goto ResumePendingDownloads)
if !choice!==2 (goto DiscardPendingDownloads)
call :invalid_input
goto pending_downloads


:ResumePendingDownloads
set ristf=0
mode con: cols=80 lines=20
cls
echo.
echo                   -Songs resumer-
echo.
echo.
echo  Fetching and resuming all incompleted downloads...
for /R "!DownloadsFolder!" %%r in (*) do (
	if %%~xr==.spotdlTrackingFile (
		spotdl "%%~r" --output !DownloadsFolder!
		set /a ristf=%ristf%+1
	)
)
echo.
if not %ristf%==0 (
	echo  All incomplete downloads were successfuly resumed! (%ristf% songs)
	if %spotDL_ver%==3 (del "%DownloadsFolder%.spotdl-cache" >nul)
) else (
	echo  No resumable downloads available.
)
echo  Press any key to go back...
pause >nul
goto MainMenu


:DiscardPendingDownloads
set ristf=0
mode con: cols=80 lines=20
cls
echo.
echo                  -Songs discarder-
echo.
echo.
echo  Fetching and discarding all incompleted downloads...
for /R "%DownloadsFolder%" %%r in (*) do (
	if %%~xr==.spotdlTrackingFile (
		del /f /q "%%~r" >nul
		spotdl "%%~r" --output %DownloadsFolder%
		set /a ristf=%ristf%+1
	)
)
echo.
if not %ristf%==0 (
	echo  All incomplete downloads were successfuly discarded! (%ristf% songs)
	if %spotDL_ver%==3 (del "%DownloadsFolder%.spotdl-cache" >nul)
) else (
	echo  No discardable downloads available.
)
call:PressAnyKeyToContinue
goto MainMenu


::SETUP MENU ---------------------------------------------------------------------------------------------
:SetupMenu
for %%a in (
	!tools!
	!ziper!
	!pathed!
) do (if not exist %%a (goto no_tools))
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "!SYSTEMROOT!\system32\config\system"
if '!errorlevel!' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (goto gotAdmin)
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "!temp!\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "!temp!\getadmin.vbs"
    "!temp!\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "!temp!\getadmin.vbs" ( del "!temp!\getadmin.vbs" )
    pushd "!CD!"
    CD /D "%~dp0"
mode con: cols=63 lines=25
set setup_menu=
cls
echo.
echo                             -SETUP-
echo.
echo.
echo   Welcome to the setup menu. Here you can install the tools
echo  that are required for SPOTYdl to work. If you don't know what
echo  to do, just install one by one then restart the script.
echo.
echo  Features:
echo   1) Install Python
echo   2) Install FFmpeg
echo   3) Install spotDL
echo     3a) Force install spotDL. Useful when not working.
echo   4) Install C++ Runtime Environment
echo.
echo  Other Options:
echo   a) Help
echo   b) Uninstaller
echo   [ENTER] Restart script in normal mode
set /p setup_menu=^>^> 
if not defined setup_menu (
	!WINDIR!\explorer.exe !ScriptFileName!
	exit
)
if !setup_menu!==1 (goto install_python)
if !setup_menu!==2 (goto iff)
if !setup_menu!==3 (goto is)
if !setup_menu!==3a (goto isf)
if !setup_menu!==4 (goto icre)
if !setup_menu!==a (goto setup_help)
if !setup_menu!==b (goto uninst)
call:invalid_input
goto SetupMenu


:setup_help
mode con: cols=63 lines=15
cls
echo.
echo                           -SETUP help-
echo.
echo.
echo   In this menu, you can install all the tools that are
echo  required for SPOTYdl to work. If you don't know what to do,
echo  just install one by one then restart the script. If any
echo  of the tools are not working, you can try reinstalling them.
echo   If that doesn't help, open an issue on the GitHub page.
echo.
call :PressAnyKeyToContinue
goto SetupMenu


:no_tools
md !tools!
cls
echo.
echo  Sorry, but you don't have the required tools to run this program.
echo  Downloading and applying the following tools:
echo.
echo   -^> 7z
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/raw/main/server/tools/7z.exe -Outfile !tools!7z.exe"
if !errorlevel!==1 goto tools_download_fail
echo  33^! done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/raw/main/server/tools/7z.dll -Outfile !tools!7z.dll"
if !errorlevel!==1 goto tools_download_fail
echo  66^! done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/raw/main/server/tools/7-zip.dll -Outfile !tools!7-zip.dll"
if !errorlevel!==1 goto tools_download_fail
echo  100^! done
echo.
echo   -^> pathed
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/raw/main/server/tools/pathed.exe -Outfile !tools!pathed.exe"
if !errorlevel!==1 goto tools_download_fail
echo  33^! done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/raw/main/server/tools/log4net.dll -Outfile !tools!log4net.dll"
if !errorlevel!==1 goto tools_download_fail
echo  66^! done
powershell -command "Invoke-WebRequest https://github.com/GabiBrawl/SPOTYdl/raw/main/server/tools/GSharpTools.dll -Outfile !tools!GSharpTools.dll"
if !errorlevel!==1 goto tools_download_fail
echo  100^! done
goto SetupMenu


:tools_download_fail
del !tools!
echo  There was an error downloading the tools. Please try again later.
echo.
call:PressAnyKeyToContinue
goto MainMenu


:install_python
endlocal
set python=python_3.10.2-amd64.exe
set errorlevel=
set size=
set OS=
cls
echo.
echo          -Python Installation-
echo.
echo.
echo Downloading Python...
for /f %%b in ('wmic os get osarchitecture ^| find "-bit"') do (set OS=%%b)
if not !OS!==64-bit (
	 echo  32-bit OS detected. Text failed
	 echo  Sorry, but this setup only supports 64-bit OS.
	 echo  Please install Python manually.
	 echo.
	 call:PressAnyKeyToContinue
	 goto SetupMenu
) else (
	 echo  64-bit OS detected. Test passed
)
if not exist !packages!!python! (
	 powershell -command "Invoke-WebRequest https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe -Outfile !packages!!python!"
	 if !errorlevel!==1 goto downloads_err
)
echo  Done!
echo  Verifying Download...
FOR /F "tokens=*" %%A IN ("!packages!!python!") DO set size=%%~zA
if !size! LSS 27000000 (
	echo  Download failed. Trying again.
	timeout /t 3
	del "!packages!!python!"
	goto install_python
)
echo  Installing Python...
!packages!!python! /quiet InstallAllUsers=1 PrependPath=1 /wait
if !errorlevel!==1 goto python_err
echo  Adding and Loading path entries...
start !pathed! /append !appdata!\Python\Python310\Scripts /wait
set path=!path!;!appdata!\Python\Python310\Scripts
if !errorlevel!==1 goto pathed_err
echo.
echo  Python was installed successfully.
echo  Press any key to exit.
PAUSE >nul
exit /b


:iff
md C:\ffmpeg\
set errorlevel=
set size=
cls
echo.
echo          -FFmpeg Installation-
echo.
echo.
echo  Downloading FFmpeg...
if not exist !packages!ffmpeg5.0_x64.zip (
	powershell -command "Invoke-WebRequest -Uri https://github.com/GabiBrawl/SPOTYdl/raw/main/server/ffmpeg5.0_x64.zip -Outfile !packages!ffmpeg5.0_x64.zip"
	if !errorlevel!==1 goto downloads_err
)
echo  Verifying Download...
FOR /F "tokens=*" %%A IN ("!packages!ffmpeg5.0_x64.zip") DO set size=%%~zA
if !size! LSS 107800000 (
	echo  Download failed. Trying again.
	timeout /t 3
	del "!packages!ffmpeg5.0_x64.zip"
	goto iff
)
echo  Unzipping downloaded files...
set errorlevel=
!tools!\7z.exe e !packages!ffmpeg5.0_x64.zip -oC:\ffmpeg\
if !errorlevel!==1 goto unzip_err
echo  Applying files to the system...
set errorlevel=
start /wait !tools!\pathed.exe /append C:\ffmpeg\ /machine
if !errorlevel!==1 goto pathed_err
echo.
echo  FFmpeg was installed successfully.
call:PressAnyKeyToContinue
goto SetupMenu


:is
set errorlevel=
set sv=
cls
echo.
echo            -spotDL Installation-
echo.
echo.
echo  Installing spotDL...
echo.
pip install spotdl
if !errorlevel!==1 goto downloads_err
echo.
echo   spotDL was installed successfully.
call:PressAnyKeyToContinue
goto SetupMenu


:isf
set errorlevel=
set sv=
cls
echo.
echo             -spotDL forced Installation-
echo.
echo.
echo  Forcing the installation of spotDL...
echo.
pip install --force -U spotdl --user
if !errorlevel!==1 goto downloads_err
echo.
echo  spotDL was installed successfully.
call:PressAnyKeyToContinue
goto SetupMenu


:icre
set size=
set errorlevel=
cls
echo.
echo         -C++ Runtime Environment Installation-
echo.
echo.
echo  Downloading the necessary files...
if not exist !packages!VC_redist.x64.exe (
	powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/VC_redist.x64.exe -Outfile !packages!VC_redist.x64.exe"
	if !errorlevel!==1 goto downloads_err
)
echo  Verifying Download...
FOR /F "tokens=*" %%A IN ("%packages%VC_redist.x64.exe") DO set size=%%~zA
if !size! LSS 25300000 (
	echo  Download failed. Trying again.
	timeout /t 3
	del "!packages!VC_redist.x64.exe"
	goto iff
)
set errorlevel=
echo  Installing the downloaded files... This may take some time.
start /wait !packages!VC_redist.x64.exe /install /quiet /norestart
if !errorlevel!==1 goto cre_err
echo.
echo  The Runtime Environment was installed successfully.
call:PressAnyKeyToContinue
goto :SetupMenu


:downloads_err
echo   There was an error when trying to download the 
echo  required files. Try again later!
echo.
echo   Press any key to go back to the setup menu.
pause >nul
goto SetupMenu


:cre_err
echo   There was an error when trying to install the
echo  Runtime Environment. Try again later!
echo.
call:PressAnyKeyToContinue
goto SetupMenu


:unzip_err
echo   There was an error when trying to unzip the
echo  downloaded ffmpeg files. Try again later!
echo.
call:PressAnyKeyToContinue
goto SetupMenu


:pathed_err
echo   There was an error when trying to add the
echo  path entries. Try again later!
echo.
call:PressAnyKeyToContinue
goto SetupMenu


:python_err
echo   There was an error when trying to install
echo  Python. Try checking your permissions!
echo.
call:PressAnyKeyToContinue
goto SetupMenu


:uninst
set choice=
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
set /p choice=^>^> 
if not defined choice (
	!WINDIR!\explorer.exe !ScriptFileName!
	exit
)
if !choice!==1 (goto uninst_python)
if !choice!==2 (goto uninst_ffmpeg)
if !choice!==3 (goto uninst_spotdl)
if !choice!==4 (goto uninst_cre)
if !choice!==5 (goto uninst_all)
call :invalid_input
goto uninst


:uninst_python
cls
echo.
echo  Uninstalling Python...
start /wait !packages!python_3.10.2.exe /quiet /uninstall
echo.
echo  Python was uninstalled successfully.
call:PressAnyKeyToContinue
goto uninst


:uninst_ffmpeg
cls
echo.
echo  Uninstalling FFmpeg...
delete C:\ffmpeg\ /q /f
echo.
echo  FFmpeg was uninstalled successfully.
call:PressAnyKeyToContinue
goto uninst


:uninst_spotdl
cls
echo.
echo  Uninstalling spotDL...
pip uninstall spotdl
echo.
echo  spotDL was uninstalled successfully.
call:PressAnyKeyToContinue
goto uninst


:uninst_cre
cls
echo.
echo          -C++ Runtime Environment Uninstallation-
echo.
echo.
echo  Uninstalling the C++ Runtime Environment...
start /wait !packages!VC_redist.x64.exe /uninstall /quiet /norestart
if !errorlevel!==1 goto pathed_err
echo.
echo  The C++ Runtime Environment was uninstalled successfully.
call:PressAnyKeyToContinue
goto uninst


:uninst_all
cls
echo.
echo  Uninstalling all dependencies...
echo   - spotDL (25% of the total progress)
pip uninstall spotdl
echo   - Python (50% of the total progress)
start /wait !packages!python_3.10.2.exe /quiet /uninstall
echo   - FFmpeg (75% of the total progress)
del C:\ffmpeg\ /q /f
echo   - C++ Runtime Environment (100% of the total progress)
start /wait !packages!VC_redist.x64.exe /uninstall /quiet /norestart
echo.
echo  All dependencies were uninstalled successfully.
call:PressAnyKeyToContinue
goto uninst


:nede
echo  The codename of the version you chose doesn't exist.
echo  Please try again...
timeout /t 4 >nul
goto SwapMenu
::/SETUP MENU -----------------------------------------------------------------------------------


::youtube only download start
:YouTubeMP3DownloaderMenu
if not exist !yt-dlpExecutable! goto yt-dlpDownloader
if not exist !yt-dlpExecutable! goto yt-dlpDownloader
if not exist !yt-dlpExecutable! goto yt-dlpDownloader
mode con: cols=80 lines=11
set choice=
cls
echo.
echo                  -YouTube only download-
echo.
echo.
echo   No metadata provided by this method. Only available mp3.
echo   Input the YouTube video URL or hit [ENTER] to go back.
echo.
set /p choice=^>^> 
if not defined choice goto MainMenu
if "x!choice:https://www.youtube.com/watch?v=!"=="x!choice!" call :invalidYoutubeUrl && goto YouTubeMP3DownloaderMenu
if "x!choice:www.youtube.com/watch?v=!"=="x!choice!" call :invalidYoutubeUrl && goto YouTubeMP3DownloaderMenu
if "x!choice:youtube.com/watch?v=!"=="x!choice!" call :invalidYoutubeUrl && goto YouTubeMP3DownloaderMenu
goto YouTubeSongDownloading


:YouTubeSongDownloading
mode con: cols=80 lines=11
set vid_title=
set vid_length=
cls
echo.
echo                  -YouTube only download-
echo.
echo.
"!yt-dlpExecutable!" -e --get-title !choice!>"!TempDirectory!\vid_name_temp.txt"
"!yt-dlpExecutable!" --get-duration !choice!>"!TempDirectory!\vid_duration_temp.txt"
set /p vid_title= <"!TempDirectory!\vid_name_temp.txt"
set /p vid_length= <"!TempDirectory!\vid_duration_temp.txt"
del /f /q "!TempDirectory!\vid_name_temp.txt"
del /f /q "!TempDirectory!\vid_duration_temp.txt"
echo   Currently Downloading: !vid_title!
echo   Video length: !vid_length!
echo.
"!yt-dlpExecutable!" -x --audio-format mp3 --audio-quality 0 --ffmpeg-location !FFmpegExecutable! -o "!DownloadsFolderDirectory!%%(title)s.mp3" !choice!
if !errorlevel!==1 goto youtube_only_download_error
move *.mp3 "!DownloadFolderDirectory!" >nul
goto YouTubeOnlyDownloaderSuccess


:yt-dlpDownloader
mode con: cols=65 lines=16
mkdir !ToolsDirectory!
cls
echo.
echo                     -Downloading needed Tools-
echo.
echo.
echo                    This will only happen once.
echo        It may seem like the program is frozen, but it's not
echo          just let it do its thing It will depend on your
echo              connection speed. Patience is the key^^^!
echo.
echo.
echo  Downloading youtube-dl...
if not exist !yt-dlpExecutable! (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/yt-dlp/yt-dlp/releases/download/2023.07.06/yt-dlp_x86.exe', '!yt-dlpExecutable!')"
)
echo.
echo  Done!
timeout /t 5 >nul
goto YouTubeMP3DownloaderMenu


:YouTubeOnlyDownloaderSuccess
echo !link!>>!HistoryDirectory!YThistory.txt
echo   Song was successfuly downloaded!
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your YouTube download has finished!', [System.Windows.Forms.ToolTipIcon]::None)}">nul
echo.
echo   Press any key to continue...
pause >nul
goto YouTubeMP3DownloaderMenu


:youtube_only_download_error
mode con: cols=80 lines=11
echo.
echo  The song you tried downloading failed.
echo  ERRC: #5
echo.
echo  Please try again later...
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Error; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'SPOTYdl', 'Your YouTube download failed...', [System.Windows.Forms.ToolTipIcon]::None)}">nul
call :PressAnyKeyToContinue
goto YouTubeMP3DownloaderMenu
::youtube only download end ---------------------------------------------------------------------


:BitrateMainMenuChoiceToggle
echo  Changing bitrate
if "!BitrateRawValue!"=="64" (set BitrateRawValue=128) else (if "!BitrateRawValue!"=="128" (set BitrateRawValue=320) else (set BitrateRawValue=64))
goto MainMenu


:MoreOptions
color 07
mode con: cols=80 lines=21
set choice=
cls
echo.
echo                           -More options and features-
echo.
echo.
echo  Extra SPOTYdl features:
echo   a) BSync                    b) News
echo   c) About SPOTYdl            d) Disclaimer
echo   e) By Me                    f) Contribute to SPOTYdl
echo.
echo  Extra spotDL features:
echo   -) none yet
echo.
echo   Input the value that corresponds to your choice or hit [ENTER] to go back.
set /p choice=^>^> 
if not defined choice goto MainMenu
if !choice!==a (goto BSync)
if !choice!==b (goto NewsMenu)
if !choice!==c (goto about)
if !choice!==d (goto :Disclaimer)
if !choice!==e (goto ByMe)
if !choice!==f (goto contribute)
call:InvalidInput
goto MoreOptions


:contribute
mode con: cols=80 lines=13
cls
echo.
echo                         -Contribute-
echo.
echo.
echo   If you want to contribute to the project, you can do so by
echo  making a pull request on GitHub. You can also help by donating
echo  to the project. You can do so by going to the following link:
echo.
echo  https://www.paypal.com/paypalme/gabibrawl
echo.
call :PressAnyKeyToContinue
goto MoreOptions


:Disclaimer
mode con: cols=57 lines=13
cls
echo.
echo                      -Disclaimer-
echo.
echo.
echo   SPOTYdl is not endorsed by, directly affiliated with,
echo  maintained, authorized, or sponsored by spotDL, 7zip,
echo  pathed, Bluetooth Command Line Tools, ffmpeg or Python.
echo.
echo   spotDL's official discord server is available at:
echo  https://discord.gg/njSX9FwdFJ
echo.
call:PressAnyKeyToContinue
goto MoreOptions


:about
mode con: cols=103 lines=21
cls
echo.
echo                                                -About-
echo.
echo.
echo   I'm sure you've already googled on ways how to download Spotify songs without having to purchase the
echo  "Premium" they offer us. In my research I found about spotDL, a project that helps people downloading
echo  spotify songs for free and legally using youtube. Initially when I saw the whole setup we have to do,
echo  in order to start the usage, I abandoned. But after some more research I found out that spotDL was my
echo  best choice. I installed it, and it worked nicely but it's not that motivating to open cmd every time
echo  I wanna download a song. So I created SPOTYdl to run spotDL's commands without having to remember all
echo  the needed commands. Working great but I wanted to publish it... so I prepared the script to download
echo  and setup spotDL and its requirements automaticaly, so you don't need to go through all the hassle of
echo  installation nor usage. :D
echo  And here we are!
echo.
echo                                       Welcome to SPOTYdl V!SPOTYdlCurrentVersion!^^^!
echo   by GabiBrawl, 21st march 2022
echo.
call :PressAnyKeyToContinue
goto MoreOptions


:ByMe
mode con: cols=77 lines=23
set choice=
cls
echo.
echo                               -About the creator-
echo.
echo.
echo   Sup y'all, I'm Gabi, a 16 year old guy from Portugal.
echo   I love to code and I'm currently learning Web Development.
echo   Bellow, you can find my social and recent projects.
echo   I hope you enjoy my programs! - 27 December 2022
echo.
echo   Social:
echo    1) GitHub                      2) Twitter
echo    3) E-Mail                      4) YouTube
echo    5) Discord
echo.
echo   Recent projects:
echo    a) SPOTYdl                     b) IMC
echo    c) TAI                         d) BEditor
echo    e) YVD                         f) LePlayer
echo.
echo   Input the value that corresponds to your choice or hit [ENTER] to go back.
set /p choice=^>^> 
if not defined choice goto MoreOptions
if !choice!==1 (goto ByMeGitHub)
if !choice!==2 (goto ByMeTwitter)
if !choice!==3 (goto ByMeEmail)
if !choice!==4 (goto ByMeYoutube)
if !choice!==5 (goto ByMeDiscord)
if !choice!==a (goto ByMeSPOTYdl)
if !choice!==b (goto ByMeIMC)
if !choice!==c (goto ByMeTAI)
if !choice!==d (goto ByMeBEditor)
if !choice!==e (goto ByMeYtvd)
if !choice!==f (goto ByMeLePlayer)
call :invalid_input
goto ByMe


:ByMeGitHub
cls
echo.
echo                                -My Github-
echo.
echo.
echo   GitHub is my favourite place to store my projects.
echo.
echo   github.com/GabiBrawl
echo.
echo   Hit [ENTER] to go back, or type 1 to open my profile.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://github.com/GabiBrawl
goto ByMe


:ByMeTwitter
cls
echo.
echo                                -My Twitter-
echo.
echo.
echo   I post about my projects and other non related things over there!
echo  You can contact me there too!
echo.
echo   twitter.com/GabiBrawl
echo.
echo   Hit [ENTER] to go back, or type 1 to open my profile.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://twitter.com/GabiBrawl
goto ByMe


:ByMeEmail
cls
echo.
echo                                 -E-Mail-
echo.
echo.
echo   You can contact me through this E-Mail. I'm always open to suggestions and
echo  feedback!
echo.
echo   gabrielyt219@gmail.com
echo.
echo   Hit [ENTER] to go back, or type 1 to open your E-Mail client.
set /p choice=^>^>
if not defined choice goto ByMe
if !choice!==1 start mailto:gabrielyt219@gmail.com
goto ByMe


:ByMeYoutube
cls
echo.
echo                                -YouTube-
echo.
echo.
echo   I post videos about Tech at random times. Subscribe :D
echo.
echo   youtube.com/@gabibrawl
echo.
echo   Hit [ENTER] to go back, or type 1 to open my channel.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://youtube.com/@gabibrawl
goto ByMe


:ByMeDiscord
cls
echo.
echo                                -Discord-
echo.
echo.
echo   I'm always open to suggestions and feedback! You can contact join my
echo  Discord server and contact me there!
echo.
echo   My main server: discord.gg/fFv78cXAHW
echo.
echo   Hit [ENTER] to go back, or type 1 to open my server.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://discord.gg/fFv78cXAHW
goto ByMe


:ByMeSPOTYdl
cls
echo.
echo                                -SPOTYdl-
echo.
echo.
echo   SPOTYdl is a script that allows you to download songs from Spotify. It
echo  what you're using right now broo
echo.
echo   github.com/GabiBrawl/SPOTYdl
echo.
echo   Hit [ENTER] to go back, or type 1 to open the project's page.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://github.com/GabiBrawl/SPOTYdl
goto ByMe


:ByMeIMC
cls
echo.
echo                                -IMC-
echo.
echo.
echo   IMC is a script that backups a file that you're editing over time.
echo  Each time the imported file gets modified, it will copy it to the
echo  selected folder. It's as easy as a drag'n'drop process!
echo.
echo   github.com/GabiBrawl/IMC
echo.
echo   Hit [ENTER] to go back, or type 1 to open the project's page.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://github.com/GabiBrawl/IMC
goto ByMe


:ByMeTAI
cls
echo.
echo                                -TAI-
echo.
echo.
echo   This is a Windows Application that allows you to set an image
echo  with a transparent background in your profile picture, instead
echo  of the pure black the image turns to. It's as easy as a 2 step
echo  process!
echo.
echo   github.com/GabiBrawl/TAI
echo.
echo   Hit [ENTER] to go back, or type 1 to open the project's page.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://github.com/GabiBrawl/TAI
goto ByMe


:ByMeBEditor
cls
echo.
echo                                  -BEditor-
echo.
echo.
echo   BEditor is a script that allows you to open your files for fast editing.
echo   Just drag'n'drop the file you want to edit and it will open it in your
echo  preferred text editor!
echo.
echo   github.com/GabiBrawl/BEditor
echo.
echo   Hit [ENTER] to go back, or type 1 to open the project's page.
set /p choice=^>^> 
if not defined choice goto ByMe
if !choice!==1 start https://github.com/GabiBrawl/BEditor
goto ByMe


:ByMeYtvd
cls
echo.
echo                                -YVD-
echo.
echo.
echo   YVD is a script that allows you to download videos from YouTube.
echo.
echo   github.com/GabiBrawl/YVD
echo.
echo   Hit [ENTER] to go back, or type 1 to open the project's page.
set /p choice=^>^>
if not defined choice goto ByMe
if !choice!==1 start https://github.com/GabiBrawl/YVD
goto ByMe


:ByMeLePlayer
cls
echo.
echo                                -LePlayer-
echo.
echo.
echo   LePlayer is going to be a next gen Streaming Service, better than any
echo  you've ever seen. It's not yet live, but you can join my Discord server
echo  to get updates and special prizes! (first 100 members)
echo.
echo   LePlayer server: discord.gg/8eV557vYPR
echo.
echo   Hit [ENTER] to go back, or type 1 to open the server.
set /p choice=^>^>
if not defined choice goto ByMe
if !choice!==1 start https://https://discord.gg/8eV557vYPR


:NewsMenu
title SPOTYdl - NEWS
mode con: cols=66 lines=35
color 4e
if exist !TempDirectory!news.temp (del !TempDirectory!news.temp)
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/news.temp -Outfile !TempDirectory!news.temp" >nul
:ReadingNews
if not exist !TempDirectory!news.temp goto GitHubFail
cls
echo                               -NEWS-                             
type !TempDirectory!news.temp |More
echo.
echo.
echo       Congrats! You've read all available news for today.
echo          Press any key to go back to the main menu.
pause >nul
goto MoreOptions


:VersionMenu
call :dvfs
if not exist !SPOTYdlVersioningInfoDirectory! (md !SPOTYdlVersioningInfoDirectory!)
mode con: cols=51 lines=25
set swm=
set AvailableServerVersion=no_connection
set upd?=yes
set /p LastUpdated=<!SPOTYdlVersioningInfoDirectory!last_updated.dat
if not defined LastUpdated (set LastUpdated=not defined)
set /p AvailableServerVersion=<!TempDirectory!s.ver
set /p LastUpdatedServerVersion=<!TempDirectory!lastUpdated.ver
cls
echo.
echo                   -Version menu-
echo.
echo.
echo  Running Version: !SPOTYdlCurrentVersion!
echo    - updated on: !LastUpdated!
echo  Server Version: !AvailableServerVersion!
echo    - updated on: !LastUpdatedServerVersion!
echo  Update channel: !UpdateChannel!
echo.
echo  SPOTYdl related features:
::by GabiBrawl
if not !AvailableServerVersion!==no_connection (
	if not "!AvailableServerVersion!"=="!ver!" (
		if "!ver!" GTR "!AvailableServerVersion!" (
			echo   1^) Install updates
		) else (
			set upd?=no
			echo   1^) Stop using leaked builds
)) else (
	echo   1^) Reinstall SPOTYdl
)) else (
	echo   1^) No_connection
)

for /f %%b in ('dir !store! ^| find "File(s)"') do (set vdb=%%b)
if not !vdb!==0 (
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
if not defined swm goto MainMenu
if !swm!==1 (if !upd?!==yes (goto update) else (goto VersionMenu))
if !swm!==2 (if not !vdb!==0 (goto SwapMenu) else (goto NoAvailableSwapEntries))
if !swm!==3 (if !upd?!==yes (goto update_chnl) else (goto VersionMenu))
if !swm!==a (goto HelpFileVersionMenu)
if !swm!==b (goto ChangelogFileDownloadAndRun)
call :invalid_input
goto VersionMenu


:update
title SPOTdl - upgrade
cls
echo.
echo                       -DON'T CLOSE THIS WINDOW-
echo.
echo  Updating SPOTYdl installation files...
copy !ScriptFileName! !StoreDirectory!!ver!.dsv /y >nul
if !UpdateChannel!==Stable (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/script.bat -Outfile !TempDirectory!SPOTYdl.bat" >nul) else (powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bscript.bat -Outfile !TempDirectory!SPOTYdl.bat" >nul)
if !errorlevel!==1 (set gotoBack=VersionMenu && call GitHubFail)
echo !date!>!SPOTYdlVersioningInfoDirectory!last_updated.dat
echo @echo off>>.\setup.bat
echo title Finishing up>>.\setup.bat
echo del SPOTYdl.bat>>.\setup.bat
echo copy !TempDirectory!SPOTYdl.bat %%~dp0>>.\setup.bat
echo start SPOTYdl.bat>>.\setup.bat
echo exit>>.\setup.bat
start setup.bat
exit


:SwapMenu
set dc=
for /f %%b in ('dir !StoreDirectory! ^| find "File(s)"') do (set dmva=%%b)
if !dmva!==0 (goto NoAvailableSwapEntries)
set /a mcdm=!dmva!+15
mode con: cols=60 lines=!mcdm!
cls
echo.
echo                         -SWAP MENU-
echo.
echo  Here, you have all versions you ever had installed.
echo.
echo.
echo  All available swap versions: (current v!SPOTYdlCurrentVersion!)
for /R "!StoreDirectory!" %%A in (*) do (echo   -^> %%~nA ^(%%~zA bytes^))
echo.
echo  Input the codename of the version you wanna swap to.
echo      Not ready to SWAP? Press [ENTER] to go back.
set /p dc=^>^> 
if not defined dc (goto VersionMenu)
if not exist !StoreDirectory!!dc!.dsv goto nede
copy !SN! !StoreDirectory!!ver!.dsv /y /v >nul
copy !StoreDirectory!!dc!.dsv !cd!\sptdl.bat /y /v >nul
del !config! /f /q >nul
del !TempDirectory! /f /q >nul
echo @echo off>>.\setup.bat
echo title Swapping between versions>>.\setup.bat
echo del /f /q SPOTYdl.bat>>.\setup.bat
echo ren sptdl.bat SPOTYdl.bat>>.\setup.bat
echo start SPOTYdl.bat>>.\setup.bat
echo exit>>.\setup.bat
start setup.bat
exit


:NoAvailableSwapEntries
mode con: cols=51 lines=6
cls
echo.
echo  There ain't any swap versions available.
echo.
echo  This menu will be unlocked as soon as you update.
echo  Press any key to go back...
pause >nul
goto VersionMenu


:ChangelogFileDownloadAndRun
if exist !TempDirectory!changelog.txt (del !TempDirectory!changelog.txt)
echo|set /p "=Downloading the changelog now... " <nul
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/changelog.txt -Outfile !TempDirectory!changelog.txt" >nul
if !errorlevel!==1 (set gotoBack=VersionMenu && call GitHubFail)
echo Done!
timeout /t 1 >nul
start !TempDirectory!changelog.txt
goto VersionMenu


:GitHubFail
color 07
mode con: cols=45 lines=4
cls
echo.
echo  Could not establish connection with GitHub.
echo  Please try again later!
timeout /t 4 > nul
goto gotoBack


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
if "!chnl!"=="a" (set UpdateChannel=Stable && call dvfs)
if "!chnl!"=="b" (set UpdateChannel=Beta && call dvfs)
if "!chnl!"=="c" (goto VersionMenu)
if not defined chnl goto VersionMenu


:HelpFileVersionMenu
mode con: cols=62 lines=9
cls
echo.
echo                    -Version HELP file-
echo.
echo.
echo   Here you cand check and download new updates for SPOTYdl.
echo   The updating process takes no more than some milliseconds.
echo.
call:PressAnyKeyToContinue
goto VersionMenu


:ListSongsIntoFile
set ftl=
mode con: cols=72 lines=14
if exist "!DownloadsFolder!.spotdl-cache" (del "!DownloadsFolder!.spotdl-cache" >nul)
if exist SongList.txt (goto overwrite)
cls
echo.
echo                            -SONGS listing-
echo.
echo.
echo   Chose the option that corresponds to the folder you wanna list:
echo.
echo    1^) "!DownloadsFolderAssignedName!" folder
echo    2^) Select another folder
echo.
echo   Hit [ENTER] to go back.
echo.
set /p ftl=^>^> 
if not defined ftl goto MainMenu
if !ftl!==1 (
	set sfl=".\!DownloadsFolderAssignedName!\*"
	goto SongsListing
	)
if !ftl!==2 (goto sfsl)
call :invalid_input
goto ListSongsIntoFile


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
set sfl="%sfsl%\"
md %sfl% >nul
if not %errorlevel%==0 (goto SongsListing) else (
	echo You have to input a valid folder location.
	timeout /t 3 >nul
	goto sfsl
)
goto :SongsListing


:SongsListing
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
call :PressAnyKeyToContinue
goto MainMenu


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
	goto ListSongsIntoFile
)
if %o%==n (goto MainMenu)
cls
call :invalid_input
goto overwrite

::fdssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
::fdssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
::fdssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
::fdssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss

:SettingsMenu
mode con: cols=60 lines=24
if !BitrateRawValue!==64 (set BitrateRawValueWithSettingsDescriptor=64kbps - Low Audio Quality)
if !BitrateRawValue!==128 (set BitrateRawValueWithSettingsDescriptor=128kbps - Medium Audio Quality)
if !BitrateRawValue!==320 (set BitrateRawValueWithSettingsDescriptor=320kbps - Highest Audio Quality)
set choice=
cls
echo.
echo                           -Settings-
echo.
echo.
echo  Available tweakable settings:
echo   1) Default Bitrate: !BitrateRawValueWithSettingsDescriptor!
echo   2) Downloads Folder Name: !DownloadsFolderAssignedName!
echo   3) Directory in Title: !DirectoryInTitle!
echo   4) Lyrics Provider: !SelectedLyricsProvider!
echo   5) Check for Updates on Startup: !CheckForUpdatesOnStartup!
echo.
echo  Other options:
echo   a) Save changes ^& exit
echo   b) Exit without saving changes
echo   c) Reset the app configuration
echo   d) Help
echo.
echo  Input the value that corresponds to your choice
set /p choice=^>^> 
if not defined choice (
	call :blank_input
	goto SettingsMenu
)
if "!choice!"=="1" (if "!BitrateRawValue!"=="64" (set "BitrateRawValue=128") else if "!BitrateRawValue!"=="128" (set "BitrateRawValue=320") else (set "BitrateRawValue=64")) && goto SettingsMenu
if !choice!==2 (goto RenameDownloadsFolder)
if !choice!==3 (if !DirectoryInTitle!==enabled (set DirectoryInTitle=disabled) else (set DirectoryInTitle=enabled)) && goto SettingsMenu
if !choice!==4 (if !SelectedLyricsProvider!==genius (set SelectedLyricsProvider=musixmatch) else (if !SelectedLyricsProvider!==musixmatch (set SelectedLyricsProvider=azlyrics) else (if !SelectedLyricsProvider!==azlyrics (set SelectedLyricsProvider=genius)))) && goto SettingsMenu
if !choice!==5 (if !CheckForUpdatesOnStartup!==enabled (set CheckForUpdatesOnStartup=disabled) else (set CheckForUpdatesOnStartup=enabled)) && goto SettingsMenu
if !choice!==a (
	call :WriteConfig
	goto MainMenu
)
if !choice!==b (goto RestartScript)
if !choice!==c (goto ResetConfig)
if !choice!==d (goto SettingsHelp)
call :InvalidInput
goto SettingsMenu


:SettingsHelp
mode con: cols=75 lines=35
cls
echo.
echo                           -HELP file- 1/2
echo.
echo.
echo.
echo   Can seem big, but contains the info to almost all questions!
echo.
echo   Here you can change some configurations for the current logged user.
echo   Below you got a detailed explanation for each single setting.
echo.
echo   1) Default Bitrate:
echo        This setting will permit you to modify the default bitrate value
echo       when downloading songs. You will still be able to set it in the
echo       temporary choice from within the main menu.
echo       The higher the bitrate, the better the quality, but the bigger
echo       the file size. If you change it from within the main menu, it'll be a
echo       temporary change, and will be reverted to the default one when
echo       you exit the app.
echo   2) Downloads Folder Name:
echo        This setting will permit youto rename the folder where the
echo       downloaded songs are getting stored.
echo.
echo   Press any key to go to the next page...
pause >nul
cls
echo.
echo                           -HELP file- 2/2
echo.
echo.
echo   3) Directory in Title:
echo        If enabled, the directory from where the script is baing ran
echo       will be displayed in the title. If disabled, the title will
echo       be neater. Useful if downloading into multiple folders.
echo   4) Lyrics Provider:
echo        This setting will change the lyrics provider used to download
echo       lyrics. The default provider is genius. If you want to use
echo       musixmatch, you need to have spotDL v4 installed.
echo   5) Check for Updates on startup:
echo        This setting will enable or disable the automatic update
echo       check. If enabled, we will check for updates every time
echo       you run the script.
echo   a) Save changes ^& exit:
echo        This option will save the changes you made to the settings
echo       and exit the settings menu.
echo   b) Exit without saving changes:
echo        This option will exit the settings menu without saving the
echo       changes you made.
echo   c) Reset the app configuration:
echo        This option will reset the app configuration to the default
echo       one. This won't delete the history file nor songs.
echo   d) Help:
echo        This option will open this help file.
echo.
echo   Press any key to back to the settings menu...
pause >nul
goto SettingsMenu


:RenameDownloadsFolder
mode con: cols=50 lines=13
set nn=
cls
echo.
echo   Chose the new name for the Downloads folder.
echo       Please don't use spaces in the name.
echo              Hit ^[ENTER^] to go back
echo                 Use -r to reset
echo.
echo.
set /p nn=^>^> 
if not defined nn (goto installation_settings)
if "!nn!"=="!DownloadsFolderAssignedName!" (
	echo  The new name is the same as the old one...
	timeout /t 3 >nul
	goto RenameDownloadsFolder
)
set "containsSpaces=false"
for %%A in (!nn!) do (
    if "%%A"==" " (
        echo  The new name can't contain spaces. Try again^^^!
		timeout /t 3 >nul
		goto RenameDownloadsFolder
    )
)
if "!nn!"=="-r" (
	rename !DownloadsFolderAssignedName! Downloads
    set DownloadsFolderAssignedName=Downloads
	call:WriteConfig
	goto RestartScript
)
rename !DownloadsFolderAssignedName! !nn!
if !errorlevel!==1 (
	call :FolderRenamingTrouble
)
set DownloadsFolderAssignedName=!nn!
call:WriteConfig
goto RestartScript


:FolderRenamingTrouble
mode con: cols=75 lines=16
cls
echo.
echo                                -ERROR-
echo.
echo.
echo   There was an error while trying to rename the downloads folder.
echo.
echo   Check if there is any other folder with the same name or if any song
echo  is playing from your folder. To retry press r and hit [ENTER]. To
echo  set the download directory into an existing folder use y, to go back
echo  use n.
set /p input=y/n/r^>^> 
if !input!==y (set downloads_folder=!nn!&& goto write_config)
if !input!==n (goto settings)
if !input!==r (goto renaming_downloads_folder)
call :invalid_input
exit /b


::start of BSync-----------------------------------------------------------------------------------------------------
:BSync
set choice=
< !BSyncId! (
	set /p BluetoothDeviceIdRaw=
)
cls
echo.
echo                     -BSync-
echo.
echo.
echo  Main Options:
echo   1) Start Syncing
echo   b) Start Syncing (BETA, USE AT YOUR OWN RISK)
echo   2) Target Device ID: %BluetoothDeviceIdRaw%
echo.
echo  Other Options:
echo   a) Help
echo   [ENTER] Go Back
echo.
set /p choice=^>^> 
if not defined choice (goto more_options)
if !choice!==b (goto transfer)
if !choice!==1 (set goto=transfer_2 && goto device_id)
if !choice!==2 (set goto=BSync && goto device_id)
call :invalid_input
goto BSync


:device_id
set BluetoothDeviceIdRaw=
set device_id=
cls
echo.
echo                -Bluetooth Device ID-
echo.
echo.
echo   Please pair your target device, and type in the
echo  device's name.
set /p BluetoothDeviceIdRaw=^>^> 
if exist !devid! del !devid!
echo !BluetoothDeviceIdRaw!>!devid!
goto !goto!


:transfer
set synced=!users!!logged_username!\synced_!BluetoothDeviceIdRaw!.txt
if not exist !synced! (echo.> "!synced!")
if not exist !devid! (
	set goto=transfer
	goto device_id
)
cls
echo.
echo                             -Transferring-
echo.
echo.
echo   Check your target device for any incoming transfers!
for /f %%b in ('dir !curdir! ^| find "File(s)"') do (set ttl=%%b)
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
		btobex -n"!BluetoothDeviceIdRaw!" "!curdir!%%~nA%%~xA"
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
goto BSync


:transfer_2
set rmt=
echo.
echo                             -Transferring-
echo.
echo.
for /f %%b in ('dir !users! ^| find "File(s)"') do (set dmva=%%b)
set /a rmt=!dmva!+!dmva!
echo   This job will take around !rmt! minutes. Started on !time!  
btobex -n"!BluetoothDeviceIdRaw!" !curdir!*
echo  Done!
call:PressAnyKeyToContinue
goto MainMenu
::end of BSync-----------------------------------------------------------------------------------------------------
::start of manual audio matching----------------------------------------------------------------------------------------------------------------------------
:ManualAudioMatchingMenu
set echoNotDefinedText=  Hit [ENTER] to go back, or define the values 1 to 3 to download
set choice=
mode con: cols=80 lines=16
cls
echo.
echo                              -Manual Audio Matching-
echo.
echo.
echo   1) Audio file format: !format!
echo   2) YouTube URL: !YouTubeUrl!
echo   3) Spotify URL: !SpUrl!
echo.
if not defined choice (
	if "!format!"=="not defined" (echo !echoNotDefinedText!) else (
		if "!YouTubeUrl!"=="not defined" (echo !echoNotDefinedText!) else (
			if "!SpUrl!"=="not defined" (echo !echoNotDefinedText!) else (
				echo   Hit [ENTER] to start downloading.
			)
		)
	)
)
echo.
echo   Chose a value to define then hit [ENTER]:
set /p choice=^>^> 
if not defined choice (
	if "!format!"=="not defined" goto MainMenu else (
		if "!YouTubeUrl!"=="not defined" goto MainMenu else (
			if "!SpUrl!"=="not defined" goto MainMenu else (
				goto ManualAudioMatchingDownloading
			)
		)
	)
)
if !choice!==1 goto ManualAudioMatchingFormat
if !choice!==2 goto ManualAudioMatchingYtUrl
if !choice!==3 goto ManualAudioMatchingSpUrl
call :invalid_input
goto ManualAudioMatchingFormat


:ManualAudioMatchingFormat
set choice=
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
echo   3^) flac
echo.
echo  Input the value that corresponds to your choice.
set /p choice=^>^> 
if not defined choice goto ManualAudioMatchingMenu
if !choice!==1 (set format=mp3&& goto ManualAudioMatchingMenu)
if !choice!==2 (set format=m4a&& goto ManualAudioMatchingMenu)
if !choice!==3 (set format=flac&& goto ManualAudioMatchingMenu)
if !choice!==4 (set format=opus&& goto ManualAudioMatchingMenu)
if !choice!==5 (set format=ogg&& goto ManualAudioMatchingMenu)
call :invalid_input
goto ManualAudioMatchingFormat


:ManualAudioMatchingYtUrl
set YouTubeUrl=
cls
echo.
echo                              -Manual Audio Matching-
echo                                    YouTube URL
echo.
echo.
echo   Input the YouTube song URL. It's form there that we'll get the song
echo  downloaded from. To paste, use your mouse right button click.
echo.
set /p YouTubeUrl= YT^>^> 
if not defined YouTubeUrl goto ManualAudioMatchingMenu
echo "%YouTubeUrl%"|findstr /R "[%%#^&^^^^@^$~!]" 1>nul
if %errorlevel%==0 (
    echo.
    echo   Invalid song name: "%link%"
    echo   Please remove special symbols: "%#&^@$~!"
    timeout /t 6 >nul
	 goto ManualAudioMatchingYtUrl
)
if "x!YouTubeUrl:https://www.youtube.com/watch?v=!"=="x!YouTubeUrl!" call :invalidYoutubeUrl && goto ManualAudioMatchingYtUrl
if "x!YouTubeUrl:www.youtube.com/watch?v=!"=="x!YouTubeUrl!" call :invalidYoutubeUrl && goto ManualAudioMatchingYtUrl
if "x!YouTubeUrl:youtube.com/watch?v=!"=="x!YouTubeUrl!" call :invalidYoutubeUrl && goto ManualAudioMatchingYtUrl
goto ManualAudioMatchingMenu


:ManualAudioMatchingSpUrl
set SpUrl=
cls
echo.
echo                              -Manual Audio Matching-
echo                                    Spotify URL
echo.
echo.
echo   Input the Spotify song URL. It's form there that we'll get the metadata
echo  downloaded from. To paste, use your mouse right button click.
echo   If applicable, remove everything after ?= to get the song URL.
echo.
set /p SpUrl=SP^>^> 
if not defined SpUrl goto ManualAudioMatchingMenu
echo "%SpUrl%"|findstr /R "[%%#^&^^^^@^$~!]" 1>nul
if %errorlevel%==0 (
    echo.
	 echo   Invalid song name: "%link%"
	 echo   Please remove special symbols: "%#&^@$~!"
    timeout /t 6 >nul
	 goto ManualAudioMatchingSpUrl
)
setlocal enableextensions enabledelayedexpansion
if x!SpUrl:https://open.spotify.com/!==x!SpUrl! call :invalidSpotifyUrl && goto ManualAudioMatchingSpUrl
if x!SpUrl:open.spotify.com/!==x!SpUrl! call :invalidSpotifyUrl && goto ManualAudioMatchingSpUrl
endlocal
goto ManualAudioMatchingMenu
:invalidSpotifyUrl
echo  Only Spotify URLs are supported. Try again.
timeout /t 3 >nul
exit /b


:ManualAudioMatchingDownloading
cls
echo.
echo                   -Manual Audio Matching-
echo.
echo.
echo   We're now downloading the desired song, with the selected
echo  metadata. One moment plase...
echo.
cls
set ManualAudioDownloaderCommand="!YouTubeUrl!|!SpUrl!"
if !history!==true (echo !ManualAudioDownloaderCommand!>>!history_file!.txt)
if !spotDLVersion!==3 (
	if !DebugState!==true (echo spotdl !ManualAudioDownloaderCommand! --output-format !format! --output !DownloadsFolderDirectory! --lyrics !SelectedLyricsProvider! --log-level DEBUG)
	spotdl !ManualAudioDownloaderCommand! --output-format !format! --output !DownloadsFolderDirectory! --lyrics !SelectedLyricsProvider!
) else (
	if !DebugState!==true (echo spotdl download !ManualAudioDownloaderCommand! --format !format! --output !DownloadsFolderDirectory! --bitrate !kbps! --lyrics !SelectedLyricsProvider! --log-level DEBUG)
	spotdl download !ManualAudioDownloaderCommand! --format !format! --output !DownloadsFolderDirectory! --bitrate !kbps! --lyrics !SelectedLyricsProvider!
)
set NextGoto=MainMenu
if !errorlevel! == 0 goto CleanUp
if !errorlevel! == 1 goto Error1
goto spotDLTrouble
::end of manual audio matching----------------------------------------------------------------------------------------------------------------------------


:spotDLTrouble
mode con: cols=54 lines=14
cls
echo.
echo   Hey there! You can't simply run this script without
echo  installing spotDL first... There's a setup on the
echo  main menu to automate the installation!
echo.
echo.
echo   ERRC: #1
echo   ERROR: spotdl was not recognized as a command.
echo    - Maybe your settings are incorrect? Try changing
echo   the currently defined spotDL version. Current: v%spotDL_ver%
echo.
echo   Press any key to go to the main menu...
pause >nul
goto MainMenu


:reset
mode con: cols=46 lines=11
cls
set confirm1=
cls
echo.
echo         -CONFIRMATION TO RESET SPOTYdl-
echo.
echo.
echo   WARNING! THIS WILL ERASE ALL CONFIGURATIONS.
echo   THIS ACTION IS IRREVERSIBLE! CONFIRM? (y/n)
echo.
set /p confirm1=^>^> 
if %confirm1%==n (goto InitialVariableLoad)
if %confirm1%==y (goto reset_doublecheck)
call :invalid_input
goto reset
:reset_doublecheck
set confirm2=
set /p confirm2= Double check ^>^> 
if %confirm2%==n (goto InitialVariableLoad)
if %confirm2%==y (goto reset_confirmed)
call :invalid_input
goto reset_doublecheck
:reset_confirmed
set "%~n1="
cls
echo.
echo              -RESETTING THE SYSTEM-
echo.
echo.
echo   Deleting configuration files...
del /F /Q "!ConfigFile!" >nul
echo.
echo   Job done! Exiting...
timeout /t 2 >nul
exit


:FirstRun
mode con: cols=56 lines=12
if not exist "!StoreDirectory!" (md "!StoreDirectory!")
if not exist "!TempDirectory!" (md "!TempDirectory!")
cls
echo.
echo                   -Welcome to SPOTYdl-
echo                      Got 2 minutes?
echo.
echo.
echo   It's your first time running this app, so we gotta
echo  make some configurations to proceed.
echo   If your Windows username has spaces in it, you
echo  might have some trouble with this script.
echo.
echo   Press any key to start...
pause >nul
:NewUserQuestion1
set choice=
cls
mode con: cols=59 lines=8
cls
echo.
echo   Do you have python, spotDL and ffmpeg installed? (y/n)
echo   If you don't know what those mean, use n and hit [Enter].
echo.
set /p choice=^>^> 
if !choice!==y (goto SaveNewUserConfig)
if !choice!==n (goto NewUserDoesntHaveNeededTools)
call :InvalidInput
goto NewUserQuestion1
:NewUserDoesntHaveNeededTools
cls
mode con: cols=56 lines=16
set choice=
cls
echo.
echo   Do you want to run the setup now? (y/n)
echo  Administrative priviledges are required.
echo.
set /p choice=^>^>
if !choice!==y (goto SetupMenu)
if !choice!==n (
	echo   The script will now exit to avoid any possible
	echo  corruptions in the configurations. Please run the
	echo  setup when you're ready.
	echo.
	echo   Press any key to exit...
	pause >nul
	exit /b
)
call :InvalidInput
goto NewUserDoesntHaveNeededTools
:SaveNewUserConfig
md !DataDirectory!
set BitrateRawValue=128
set CheckForUpdatesOnStartup=enabled
set SelectedLyricsProvider=genius
set DirectoryInTitle=disabled
call :WriteConfig
mode con: cols=62 lines=15
cls
echo.
echo   Congrats! You have ended the initial configuration.
echo.
echo   Things to bear in mind:
echo   - You can change the configurations at any time by
echo    going to settings, in the main menu.
echo   - For extra help, visit the Help menu.
echo.
echo   Press any key to begin the app usage...
pause >nul
call :LoadConfig
goto RestartScript


::Calls lead to here
:LoadConfig
echo  - %time% Started Loading Configuration File
< !ConfigFile! (
	set /p BitrateRawValue=
	set /p DownloadsFolderAssignedName=
	set /p DirectoryInTitle=
	set /p CheckForUpdatesOnStartup=
	set /p SelectedLyricsProvider=
)
echo  - %time% Finished Loading Configuration File
exit /b
:WriteConfig
echo  - %time% Started Writing Configuration File
del !ConfigFile! /f /q
(
	echo !BitrateRawValue!
	echo !DownloadsFolderAssignedName!
	echo !DirectoryInTitle!
	echo !CheckForUpdatesOnStartup!
	echo !SelectedLyricsProvider!
) > !ConfigFile!
echo  - %time% Finished Writing Configuration File
exit /B
:ResetConfig
del !ConfigFile! /f /q
goto FirstRun
:CheckForUpdatesMenu
mode con: cols=60 lines=21
set AvailableServerVersion=no_connection
cls
set choice=
echo.
echo                    -Checking for Updates-
echo.
echo  Please wait a moment...
call :dvfs
if AvailableServerVersion==no_connection (exit /b)
set /p AvailableServerVersion=<!TempDirectory!s.ver
set /p LastUpdatedServerVersion=<!TempDirectory!lastUpdated.ver
if !SPOTYdlCurrentVersion! LSS !AvailableServerVersion! (
	cls
	echo.
	echo             - There is a NEW update available -
	echo.
	echo.
    echo  Current version: !SPOTYdlCurrentVersion!
    echo  Latest version: !AvailableServerVersion!
	echo   - released on: !LastUpdatedServerVersion!
    echo.
    echo  Would you like to update now?
    echo  ^(y/hit [ENTER] to cancel^)
    echo.
    set /p choice=^>^> 
    if !choice!==y (
		goto update
	) else (
		echo  Update cancelled.
		timeout /t 3 >nul
	)
)
exit /b
:dvfs
if exist !TempDirectory!s.ver (del !TempDirectory!s.ver)
if !UpdateChannel!==Stable (
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/s.ver -Outfile !TempDirectory!s.ver">nul
) else (
	powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/bs.ver -Outfile !TempDirectory!s.ver">nul
)
powershell -command "Invoke-WebRequest https://raw.githubusercontent.com/GabiBrawl/SPOTYdl/main/server/lastUpdated.ver -Outfile !TempDirectory!lastUpdated.ver">nul
exit /b
:InvalidInput
echo  The value you entered is invalid. Try again!
timeout /t 3 >nul
exit /b
:blank_input
echo  You can't leave this field in blank. Try again!
timeout /t 3 >nul
exit /b
:PressAnyKeyToContinue
echo  Press any key to go back...
pause >nul
exit /b
:invalid_url
echo  Invalid URL. Please try again.
timeout /t 3 >nul
exit /b
:invalidYoutubeUrl
echo   Only YouTube URLs are supported. Try again.
timeout /t 3 >nul
exit /b


:: This is the end of the script. If you want to add more features, do it here please.
:: No Copyrights, no license, no nothing. Just do whatever you want with it. By GabiBrawl, 24th December 2022. (yup, I do code in the most unextpected timings hehe)
