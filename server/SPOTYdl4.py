import os


SPOTYdlCurrentVersion = "3.0"
UpdateChannel = "Stable"
SPOTYdlSetupVersion = "3.4"
DebugState = False

# FUNCTIONS
clear = lambda: print("\033c", end="", flush=True)
def pause(message="Press Enter to continue..."): input(message)


# TEMPORARY VARIABLES
SPOTYdlCurrentVersion = "4.0.0"
total_downloaded_songs_count = 0
bitrate_value_description = "320 kbps"
pending_choice_name = "Pending Choice"
SPOTYdlSetupVersion = "4.0.0"


def StartUp():
    ## Initial variable loading
    DoodleCount = 0
    ScriptFileName = os.path.basename(__file__)
    script_path = os.path.dirname(os.path.abspath(__file__))
    SPOTYdlPath = script_path + "\\"
    os.chdir(SPOTYdlPath)
    # Directories
    DefaultDownloadDirectory = os.path.join(SPOTYdlPath, "Downloads")
    DataDirectory = os.path.join(os.getenv('APPDATA'), "GabiBrawl", "SPOTYdl")
    ConfigFile = os.path.join(DataDirectory, "config.txt")
    StoreDirectory = os.path.join(DataDirectory, "store")
    TempDirectory = os.path.join(DataDirectory, "temp")
    PackagesDirectory = os.path.join(DataDirectory, "packages")
    ToolsDirectory = os.path.join(DataDirectory, "tools")
    HistoryDirectory = os.path.join(DataDirectory, "history")
    SPOTYdlVersioningInfoDirectory = os.path.join(DataDirectory, "info")
    # Tools
    _7zipExecutable = os.path.join(ToolsDirectory, "7z.exe")
    PathedExecutable = os.path.join(ToolsDirectory, "pathed.exe")
    yt_dlpExecutable = os.path.join(ToolsDirectory, "yt-dlp_x86.exe")
    FFmpegExecutable = "C:\\ffmpeg\\ffmpeg.exe"
    # Actions
    ImportFileDefaultActionOnFinish = "none"
    # Files
    BSyncId = os.path.join(DataDirectory, "BluetoothSyncDevice.id")
    SelectedSaveFolder = os.path.join(DataDirectory, "SelectedSaveFolder.txt")
    HistoryFile = os.path.join(HistoryDirectory, "history")
    TempSetupFile = os.path.join(SPOTYdlPath, "setup.bat")
    # Import file related
    action = "none"
    # Others
    DownloadsFolderAssignedName = "Downloads"
    # Finish
    print(f" - {time.strftime('%H:%M:%S')} Initial Variable Load Complete")
    # Check if reset mode was prompted
    if len(os.sys.argv) > 1 and os.path.splitext(os.sys.argv[1])[0] == "reset":
        print(f" - {time.strftime('%H:%M:%S')} Reset Mode prompted??")
        reset_config()
    else:
        print(f" - {time.strftime('%H:%M:%S')} Reset Mode not prompted.")
    # Check if SetupMode was triggered
    if os.system(f'cacls {os.getenv("SYSTEMROOT")}\\system32\\config\\system > nul 2>&1') == 0:
        setup_menu()
    else:
        print(f" - {time.strftime('%H:%M:%S')} Setup Mode was not triggered")
    # Check if the config file is available
    if os.path.exists(DataDirectory) and not os.path.exists(ConfigFile):
        reset_config()
    elif not os.path.exists(DataDirectory):
        first_run()
    else:
        print(f" - {time.strftime('%H:%M:%S')} Config file is available")
        load_config()
        print(f" - {time.strftime('%H:%M:%S')} Config file loaded")
        if not os.path.exists(HistoryDirectory):
            os.makedirs(HistoryDirectory)
        if not os.path.exists(PackagesDirectory):
            os.makedirs(PackagesDirectory)
        if os.path.exists(TempSetupFile):
            os.remove(TempSetupFile)
        print(f" - {time.strftime('%H:%M:%S')} Config file checked")
    # Check for updates
    print(f" - {time.strftime('%H:%M:%S')} Check For Updates on startup started")
    if 'CheckForUpdatesOnStartup' in locals() and CheckForUpdatesOnStartup == "enabled":
        check_for_updates_menu()
    print(f" - {time.strftime('%H:%M:%S')} Check For Updates on startup ended")
    # Downloads Folder Check
    DownloadsFolder = os.path.join(SPOTYdlPath, DownloadsFolderAssignedName)
    if not os.path.exists(DownloadsFolder):
        os.makedirs(DownloadsFolder)
        with open(os.path.join(DownloadsFolder, "Desktop.ini"), "w") as desktop_ini:
            desktop_ini.write("[.ShellClassInfo]\n")
            desktop_ini.write("ConfirmFileOp=0\n")
            desktop_ini.write("IconResource=%SystemRoot%\\system32\\imageres.dll,-184\n")
            desktop_ini.write("[ViewState]\n")
            desktop_ini.write("Mode=\n")
            desktop_ini.write("Vid=\n")
            desktop_ini.write("FolderType=Music\n")
        os.system(f'attrib +S +H "{os.path.join(DownloadsFolder, "Desktop.ini")}"')
        os.system(f'attrib +R .\\{DownloadsFolderAssignedName}')
        subprocess.run(["ie4uinit.exe", "-show"], shell=True, cwd="C:\\Windows\\System32")
    print(f" - {time.strftime('%H:%M:%S')} Downloads Folder Check passed")
    # Import Check
    if len(os.sys.argv) > 1 and os.path.splitext(os.sys.argv[1])[0] != "reset":
        file_importing()
    else:
        print(f" - {time.strftime('%H:%M:%S')} Import Check passed. No imported files.")


# MENUS
def MainMenu():
    # Show menu
    clear()
    print("\n                                 -SPOTYdl v{}-".format(SPOTYdlCurrentVersion))
    print("                                {} songs so far\n\n".format(total_downloaded_songs_count))
    print("  Available audio file formats:")
    print("   1) mp3                      4) opus")
    print("   2) m4a                      5) ogg")
    print("   3) flac")
    print("\n  Other options:")
    print("   a) Help                     b) Toggle Bitrate: {}".format(bitrate_value_description))
    print("   c) Manual Audio Matching    d) Settings")
    print("   e) {}     f) Setup v{}".format(pending_choice_name, SPOTYdlSetupVersion))
    print("   g) Version                  h) Export downloaded songs to file")
    print("   i) YouTube only download    j) More options...\n")


def mp3():
    print("mp3")
    pause()



while True:
    MainMenu()
    choice = input("  Input the value that corresponds to your choice: ")
    
    if choice == "1":
        mp3()
        
    if choice == "2":
        print("m4a")
        pause()
        
    else:
        print("Invalid Option.")
        
        print()
